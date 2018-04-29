#include <StdAfx.h>
#include "CoopGruntMovementController.h"
#include <Coop\Actors\CoopGrunt.h>

// Summary:
//	Dummy target point verifier to prevent AI system based crashes on client.
class CDummyTargetPointVerifier
	: public IAnimationGraphTargetPointVerifier
{
public:
	CDummyTargetPointVerifier()
	{

	}

	virtual ~CDummyTargetPointVerifier()
	{

	}

	static CDummyTargetPointVerifier Instance;

	/// Returns true if the path can be modified to use request.targetPoint, and byproducts 
	/// of the test are cached in request.
	virtual ETriState CanTargetPointBeReached(class CTargetPointRequest &request) const { return ETriState::eTS_true; }
	/// Returns true if the request is still valid/can be used, false otherwise.
	virtual bool UseTargetPointRequest(const class CTargetPointRequest &request) { return true; }
	virtual void NotifyFinishPoint(const Vec3& pt){}
	virtual void NotifyAllPointsNotReachable() {}
};

CDummyTargetPointVerifier CDummyTargetPointVerifier::Instance = CDummyTargetPointVerifier();

// Summary:
//	Constructs a CCoopGruntMovementController class instance for the specified CCoopGrunt class instance.
CCoopGruntMovementController::CCoopGruntMovementController(CCoopGrunt* pGrunt)
	: CPlayerMovementController(pGrunt)
	, m_pGrunt(pGrunt)
	, m_bHadActorTarget(false)
	, m_nQueryStartID(0)
	, m_nQueryEndID(0)
	, m_pQueryStartID(&m_nQueryStartID)
	, m_pQueryEndID(&m_nQueryEndID)
{

}

// Summary:
//	Destructs a CCoopGruntMovementController class instance.
CCoopGruntMovementController::~CCoopGruntMovementController()
{
	
}

// Summary:
//	Specialized movement request handling for CCoopGrunt (for ActorTarget support!)
bool CCoopGruntMovementController::RequestMovement(CMovementRequest& request)
{
	if (!gEnv->bServer)
		m_pGrunt->GetAnimationGraphState()->SetTargetPointVerifier(&CDummyTargetPointVerifier::Instance);

	// Special ActorTarget handling for CCoopGrunt on server (RMI to client)
	// Only send if it has, or desires to remove the actor target!
	if (gEnv->bServer && request.HasActorTarget())
	{
		this->m_pGrunt->SendSpecialMovementRequest(request.m_flags, request.GetActorTarget());
		m_bHadActorTarget = true;
	}

	if (gEnv->bServer && request.RemoveActorTarget() && m_bHadActorTarget)
	{
		this->m_pGrunt->SendSpecialMovementRequest(request.m_flags, request.GetActorTarget());
		m_bHadActorTarget = false;
	}

	// Special ActorTarget handling for CCoopGrunt on clients.
	if (!gEnv->bServer && request.HasActorTarget())
	{
		const SActorTargetParams& p = request.GetActorTarget();

		SAnimationTargetRequest req;
		req.position = p.location;
		req.positionRadius = std::max(p.locationRadius, DEG2RAD(0.05f));
		static float minRadius = 0.05f;
		req.startRadius = std::max(minRadius, 2.0f*p.locationRadius);
		if (p.startRadius > minRadius)
			req.startRadius = p.startRadius;
		req.direction = p.direction;
		req.directionRadius = std::max(p.directionRadius, DEG2RAD(0.05f));
		req.prepareRadius = 3.0f;
		req.projectEnd = p.projectEnd;
		req.navSO = p.navSO;

		// This is the part that differs- the start and end IDs.
		IAnimationSpacialTrigger * pTrigger = m_pGrunt->GetAnimationGraphState()->SetTrigger(req, p.triggerUser, this->m_pQueryStartID, this->m_pQueryEndID);
		if (pTrigger)
		{
			if (!p.vehicleName.empty())
			{
				pTrigger->SetInput("Vehicle", p.vehicleName.c_str());
				pTrigger->SetInput("VehicleSeat", p.vehicleSeat);
			}
			if (p.speed >= 0.0f)
			{
				pTrigger->SetInput(m_inputDesiredSpeed, p.speed);
			}
			m_animTargetSpeed = p.speed;
			pTrigger->SetInput(m_inputDesiredTurnAngleZ, 0);
			if (!p.animation.empty())
			{
				pTrigger->SetInput(p.signalAnimation ? "Signal" : "Action", p.animation.c_str());
			}
			if (p.stance != STANCE_NULL)
			{
				m_targetStance = p.stance;
				pTrigger->SetInput(m_inputStance, m_pGrunt->GetStanceInfo(p.stance)->name);
			}
		}
	}
	else if (!gEnv->bServer && request.RemoveActorTarget())
	{
		if (m_pGrunt->GetAnimationGraphState())
			m_pGrunt->GetAnimationGraphState()->ClearTrigger(eAGTU_AI);
	}
	

	return CPlayerMovementController::RequestMovement(request);
}
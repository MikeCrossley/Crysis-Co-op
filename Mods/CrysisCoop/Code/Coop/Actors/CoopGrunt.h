#ifndef __COOPGRUNT_H__
#define __COOPGRUNT_H__

#if _MSC_VER > 1000
# pragma once
#endif

#include "Player.h"


class CCoopGrunt :	public CPlayer
{
public:
	CCoopGrunt();
	virtual ~CCoopGrunt();

	//CPlayer
	virtual bool Init( IGameObject * pGameObject );
	virtual void PostInit( IGameObject * pGameObject );
	virtual void Update(SEntityUpdateContext& ctx, int updateSlot);
	virtual bool NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags );
	virtual void ProcessEvent(SEntityEvent& event);
	virtual IActorMovementController * CreateMovementController();
	//~CPlayer

	enum CoopTimers
	{
		eTIMER_WEAPONDELAY	= 0x110
	};

    struct SSuitParams
    {
		SSuitParams() {};
		SSuitParams(int suit): 
			suitmode(suit) 
		{};
        int suitmode;
        void SerializeWith(TSerialize ser)
        {
            ser.Value("suitmode", suitmode);
        }
    };

	int GetAlertnessState() const { return m_nAlertness; }

	DECLARE_CLIENT_RMI_NOATTACH(ClChangeSuitMode, SSuitParams, eNRT_ReliableOrdered);

protected:
	static const EEntityAspects ASPECT_ALIVE = eEA_GameServerDynamic;
	static const EEntityAspects ASPECT_HIDE = eEA_GameServerStatic;

	void RegisterMultiplayerAI();
	void UpdateMovementState();
	void DrawDebugInfo();

protected:

	// Used to serialize special movement requests (e.g. SmartObject actortarget usage and such)
	struct SSpecialMovementRequestParams
	{
		SSpecialMovementRequestParams() {};
		SSpecialMovementRequestParams(uint32 reqFlags, const SActorTargetParams& actorTarget, const string& animation) 
			: flags(reqFlags)
			, targetParams(actorTarget)
		{
			// HACK: The structure copying is retarded and this needs to be done...
			//targetAnimation = animation;
		};

		uint32 flags;
		SActorTargetParams targetParams;
		//string targetAnimation; // why isnt it serializing?

		void SerializeWith(TSerialize ser)
		{

			ser.Value("flags", flags);

			//if ((flags & CMovementRequest::eMRF_ActorTarget))
			{

				ser.Value("location", targetParams.location);
				ser.Value("direction", targetParams.direction);
				ser.Value("vehicleName", targetParams.vehicleName);
				ser.Value("vehicleSeat", targetParams.vehicleSeat);
				ser.Value("speed", targetParams.speed);
				ser.Value("directionRadius", targetParams.directionRadius);
				ser.Value("locationRadius", targetParams.locationRadius);
				ser.Value("startRadius", targetParams.startRadius);
				ser.Value("signalAnimation", targetParams.signalAnimation);
				ser.Value("projectEnd", targetParams.projectEnd);
				ser.Value("navSO", targetParams.navSO);
				ser.Value("animation", targetParams.animation);
				ser.Value("stance", (int&)targetParams.stance);
				ser.Value("triggerUser", (int&)targetParams.triggerUser);
			}
			
		}
	};
	DECLARE_CLIENT_RMI_NOATTACH(ClSpecialMovementRequest, SSpecialMovementRequestParams, eNRT_ReliableOrdered);

public:

	void SendSpecialMovementRequest(uint32 reqFlags, const SActorTargetParams& targetParams);

private:
	Vec3 m_vMoveTarget;
	Vec3 m_vAimTarget;
	Vec3 m_vLookTarget;
	Vec3 m_vBodyTarget;
	Vec3 m_vFireTarget;

	float m_fPseudoSpeed;
	float m_fDesiredSpeed;

	int m_nAlertness;
	int m_nStance;
	int m_nSuitMode;

	bool m_bAllowStrafing;
	bool m_bHasAimTarget;
	bool m_bHasLookTarget;
	bool m_bHasBodyTarget;
	bool m_bHasFireTarget;
	bool m_bHasMoveTarget;

	bool m_bHidden;
};


#endif //__COOPGRUNT_H__
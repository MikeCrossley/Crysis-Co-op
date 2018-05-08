#include "StdAfx.h"
#include "CoopGrunt.h"
#include "PlayerMovementController.h"
#include "IVehicleSystem.h"
#include "Weapon.h"
#include "Movement\CoopGruntMovementController.h"
#include <Coop\Utilities\DedicatedServerHackScope.h>
#include <Coop/CoopSystem.h>
#include <Item.h>

CCoopGrunt::CCoopGrunt() :
	m_nStance(STANCE_RELAXED),
	m_vMoveTarget(Vec3(0,0,0)),
	m_vAimTarget(Vec3(0,0,0)),
	m_vLookTarget(Vec3(0,0,0)),
	m_vBodyTarget(Vec3(0,0,0)),
	m_vFireTarget(Vec3(0,0,0)),
	m_fPseudoSpeed(0.f),
	m_fDesiredSpeed(0.f),
	m_nAlertness(0.f),
	m_nSuitMode(3),
	m_nMovementNetworkFlags(0),
	m_nWeaponNetworkFlags(0),
	m_bHidden(false)
{
}

CCoopGrunt::~CCoopGrunt()
{
}

bool CCoopGrunt::Init(IGameObject * pGameObject)
{
	CPlayer::Init(pGameObject);

	return true;
}


void CCoopGrunt::PostInit( IGameObject * pGameObject )
{
	CPlayer::PostInit(pGameObject);
}

void CCoopGrunt::DrawDebugInfo()
{
	static float color[] = { 1,1,1,1 };

	if (gEnv->bServer)
		gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false, "IsServer");
	else
		gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false, "IsClient");

	gEnv->pRenderer->Draw2dLabel(5, 25, 2, color, false, "MoveTarget x%f y%f z%f Has: %d", m_vMoveTarget.x, m_vMoveTarget.y, m_vMoveTarget.z, this->HasMovementFlag(EAIMovementNetFlags::eHasMoveTarget) ? 1 : 0);
	gEnv->pRenderer->Draw2dLabel(5, 45, 2, color, false, "AimTarget x%f y%f z%f Has: %d", m_vAimTarget.x, m_vAimTarget.y, m_vAimTarget.z, this->HasMovementFlag(EAIMovementNetFlags::eHasAimTarget) ? 1 : 0);
	gEnv->pRenderer->Draw2dLabel(5, 65, 2, color, false, "LookTarget x%f y%f z%f Has: %d", m_vLookTarget.x, m_vLookTarget.y, m_vLookTarget.z, this->HasMovementFlag(EAIMovementNetFlags::eHasLookTarget) ? 1 : 0);
	gEnv->pRenderer->Draw2dLabel(5, 85, 2, color, false, "BodyTarget x%f y%f z%f Has: %d", m_vBodyTarget.x, m_vBodyTarget.y, m_vBodyTarget.z, this->HasMovementFlag(EAIMovementNetFlags::eHasBodyTarget) ? 1 : 0);
	gEnv->pRenderer->Draw2dLabel(5, 105, 2, color, false, "FireTarget x%f y%f z%f Has: %d", m_vFireTarget.x, m_vFireTarget.y, m_vFireTarget.z, this->HasMovementFlag(EAIMovementNetFlags::eHasFireTarget) ? 1 : 0);

	gEnv->pRenderer->Draw2dLabel(5, 145, 2, color, false, "PsuedoSpeed %f", m_fPseudoSpeed);
	gEnv->pRenderer->Draw2dLabel(5, 165, 2, color, false, "DesiredSpeed %f", m_fDesiredSpeed);

	gEnv->pRenderer->Draw2dLabel(5, 185, 2, color, false, "Alertness %d", m_nAlertness);
	gEnv->pRenderer->Draw2dLabel(5, 205, 2, color, false, "Stance %d", m_nStance);

	gEnv->pRenderer->Draw2dLabel(5, 225, 2, color, false, "Allow Strafing %d     HasAimTarget %d", (int)this->HasMovementFlag(EAIMovementNetFlags::eAllowStrafing), (int)this->HasMovementFlag(EAIMovementNetFlags::eHasAimTarget));
	if (GetNanoSuit())
		gEnv->pRenderer->Draw2dLabel(5, 265, 2, color, false, "Suit mode %d", GetNanoSuit()->GetMode());

	gEnv->pRenderer->Draw2dLabel(5, 305, 2, color, false, "Flashlight Active %d", (int)this->HasWeaponFlag(EAIWeaponNetFlags::eFlashlightActive));
	gEnv->pRenderer->Draw2dLabel(5, 325, 2, color, false, "Laser Active %d", (int)this->HasWeaponFlag(EAIWeaponNetFlags::eLaserActive));
}

void CCoopGrunt::Update(SEntityUpdateContext& ctx, int updateSlot)
{
	CPlayer::Update(ctx, updateSlot);
	
	// Movement reqeust stuff so proper anims play on client
	if (gEnv->bServer)
	{
		bool bStaticsChanged = false;

		CMovementRequest currMovement = static_cast<CPlayerMovementController*>(m_pMovementController)->GetMovementReqState();

		//Vec3
		m_vMoveTarget = currMovement.GetMoveTarget();
		m_vAimTarget = currMovement.GetAimTarget();
		m_vLookTarget = currMovement.GetLookTarget();
		m_vBodyTarget = currMovement.GetBodyTarget();
		m_vFireTarget = currMovement.GetFireTarget();
		
		// Float
		m_fPseudoSpeed = currMovement.GetPseudoSpeed();
		m_fDesiredSpeed = currMovement.GetDesiredSpeed();

		// Int
		int nPreviousStance = m_nStance;
		int nPreviousAlert = m_nAlertness;

		m_nStance = currMovement.GetStance();
		m_nAlertness = currMovement.GetAlertness();

		if (m_nAlertness != nPreviousAlert || m_nStance != nPreviousStance) { bStaticsChanged = true; }

		// Bool
		uint8 nOldMovementFlags = m_nMovementNetworkFlags;
		m_nMovementNetworkFlags = currMovement.AllowStrafing() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eAllowStrafing) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eAllowStrafing);
		m_nMovementNetworkFlags = currMovement.HasAimTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasAimTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasAimTarget);
		m_nMovementNetworkFlags = currMovement.HasBodyTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasBodyTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasBodyTarget);
		m_nMovementNetworkFlags = currMovement.HasLookTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasLookTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasLookTarget);
		m_nMovementNetworkFlags = currMovement.HasFireTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasFireTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasFireTarget);
		m_nMovementNetworkFlags = currMovement.HasMoveTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasMoveTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasMoveTarget);
		if (m_nMovementNetworkFlags != nOldMovementFlags) { bStaticsChanged = true; }

		// Weapons
		IItem* pItem = this->GetCurrentItem();
		IWeapon* pWeapon = nullptr;
		if (pItem) { pWeapon = pItem->GetIWeapon(); }
		uint8 nOldWeaponFlags = m_nWeaponNetworkFlags;
		if (pWeapon && GetHolsteredItem() != pItem)
		{
			m_nWeaponNetworkFlags = pWeapon->IsLamLightActivated() ? (m_nWeaponNetworkFlags | EAIWeaponNetFlags::eFlashlightActive) : (m_nWeaponNetworkFlags & ~EAIWeaponNetFlags::eFlashlightActive);
			m_nWeaponNetworkFlags = pWeapon->IsLamLaserActivated() ? (m_nWeaponNetworkFlags | EAIWeaponNetFlags::eLaserActive) : (m_nWeaponNetworkFlags & ~EAIWeaponNetFlags::eLaserActive);
		}
		else
		{
			m_nWeaponNetworkFlags = 0;
		}
		if (m_nWeaponNetworkFlags != nOldWeaponFlags) {	bStaticsChanged = true;	}

		if (GetNanoSuit())
		{
			if (GetNanoSuit()->GetMode() != m_nSuitMode)
			{
				m_nSuitMode = GetNanoSuit()->GetMode();
				GetGameObject()->InvokeRMI(ClChangeSuitMode(), SSuitParams(m_nSuitMode), eRMI_ToAllClients | eRMI_NoLocalCalls);
			}
		}

		// Update the rarely changing variables
		if (bStaticsChanged)
			GetGameObject()->ChangedNetworkState(ASPECT_STANCE);

		// Update the commonly changing variables
		if (GetHealth() > 0.f)
			GetGameObject()->ChangedNetworkState(ASPECT_ALIVE);
	}
	else
	{
		UpdateMovementState();
	}

	//this->DrawDebugInfo();

	if (IAnimationGraphState* pGraphState = this->GetAnimationGraphState())
	{
		// Only update on dedicated server.
		if (gEnv->bServer && !gEnv->bClient)
		{
			CDedicatedServerHackScope::Enter();
			pGraphState->Update();
			CDedicatedServerHackScope::Exit();
		}
	}
}

void CCoopGrunt::UpdateMovementState()
{
	CMovementRequest request;

	if (this->HasMovementFlag(EAIMovementNetFlags::eHasAimTarget))
	{
		request.SetAimTarget(m_vAimTarget);

		if (IVehicle* pVehicle = GetLinkedVehicle())
		{
			EntityId nWeaponEntity = pVehicle->GetCurrentWeaponId(GetEntityId());
			CWeapon* pWeapon = (CWeapon*)gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetItem(nWeaponEntity);
			if (pWeapon)
			{
				pWeapon->SetAimLocation(m_vAimTarget);
				pWeapon->SetTargetLocation(m_vAimTarget);
			}
		}
	}
	else
	{
		request.ClearAimTarget();
	}

	// Vec3
	if (this->HasMovementFlag(EAIMovementNetFlags::eHasMoveTarget))
		request.SetMoveTarget(m_vMoveTarget);
	else
		request.ClearMoveTarget();

	if (this->HasMovementFlag(EAIMovementNetFlags::eHasLookTarget))
		request.SetLookTarget(m_vLookTarget);
	else
		request.ClearLookTarget();

	if (this->HasMovementFlag(EAIMovementNetFlags::eHasLookTarget))
		request.SetFireTarget(m_vLookTarget);
	else
		request.ClearFireTarget();

	if (this->HasMovementFlag(EAIMovementNetFlags::eHasBodyTarget))
		request.SetBodyTarget(m_vBodyTarget);
	else
		request.ClearBodyTarget();

	// Float
	request.SetPseudoSpeed(m_fPseudoSpeed);
	request.SetDesiredSpeed(m_fDesiredSpeed);

	// Int
	request.SetAlertness(m_nAlertness);
	request.SetStance((EStance)m_nStance);

	// Bool
	request.SetAllowStrafing(this->HasMovementFlag(EAIMovementNetFlags::eAllowStrafing));
		
	GetMovementController()->RequestMovement(request);

	// Weapons

	IItem* pItem = this->GetCurrentItem();
	IWeapon* pWeapon = nullptr;
	if (pItem) { pWeapon = pItem->GetIWeapon(); }
	if (pWeapon)
	{
		if (this->HasWeaponFlag(EAIWeaponNetFlags::eFlashlightActive) && !pWeapon->IsLamLightActivated())
		{
			pWeapon->ActivateLamLight(true, true);
		}
		else if (!this->HasWeaponFlag(EAIWeaponNetFlags::eFlashlightActive) && pWeapon->IsLamLightActivated())
		{
			pWeapon->ActivateLamLight(false, true);
		}

		if (this->HasWeaponFlag(EAIWeaponNetFlags::eLaserActive) && !pWeapon->IsLamLaserActivated())
		{
			pWeapon->ActivateLamLaser(true, true);
		}
		else if (!this->HasWeaponFlag(EAIWeaponNetFlags::eLaserActive) && pWeapon->IsLamLaserActivated())
		{
			pWeapon->ActivateLamLaser(false, true);
		}
	}
}

void CCoopGrunt::ProcessEvent(SEntityEvent& event)
{
	CPlayer::ProcessEvent(event);

	switch(event.event)
	{
	case ENTITY_EVENT_HIDE:
		{
			if (gEnv->bServer)
			{
				m_bHidden = true;
				GetGameObject()->ChangedNetworkState(ASPECT_HIDE);
			}
			break;
		}
	case ENTITY_EVENT_UNHIDE:
		{
			if (gEnv->bServer)
			{
				m_bHidden = false;
				GetGameObject()->ChangedNetworkState(ASPECT_HIDE);

				IInventory* pInventory = GetInventory();
				if (pInventory && gEnv->bServer)
				{
					CryLogAlways("[%s] Synchronizing inventory...", GetEntity()->GetName());
					const int nItemCount = pInventory->GetCount();
					for (int nItem = 0; nItem < nItemCount; ++nItem)
					{
						EntityId nCurrentItemId = pInventory->GetCurrentItem();
						EntityId nItemId = pInventory->GetItem(nItem);

						if (IItem* pItem = gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetItem(nItemId))
						{
							// Only call if the item isn't client or server exclusive.
							if((pItem->GetEntity()->GetFlags() & (ENTITY_FLAG_CLIENT_ONLY | ENTITY_FLAG_SERVER_ONLY)) == 0)
								pItem->PickUp(GetEntityId(), false, nItemId == nCurrentItemId, false);
						}
					}
					
				}
			}
			break;
		}
	}
}

IActorMovementController* CCoopGrunt::CreateMovementController()
{
	return new CCoopGruntMovementController(this);
}

bool CCoopGrunt::NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags )
{
	if (!CActor::NetSerialize(ser, aspect, profile, flags))
		return false;

	bool bReading = ser.IsReading();

	if (aspect == EEntityAspects::eEA_GameServerStatic)
	{
		ser.Value("health", m_health, 'hlth');
		bool isFrozen = m_stats.isFrozen;
		ser.Value("frozen", isFrozen, 'bool');
		ser.Value("frozenAmount", m_frozenAmount, 'frzn');

		ser.Value("hide", m_bHidden, 'bool');

		if (bReading)
			GetEntity()->Hide(m_bHidden);

		//Int
		ser.Value("nAlert", m_nAlertness, 'i8');
		ser.Value("nStance", m_nStance, 'i8');
		ser.Value("nFlags", m_nMovementNetworkFlags, 'i8');
		ser.Value("nWep", m_nWeaponNetworkFlags, 'i8');
	}
	else if (aspect == EEntityAspects::eEA_GameServerDynamic)
	{
		//Vec3
		ser.Value("vMoveTarget", m_vMoveTarget, 'wrld');
		ser.Value("vAimTarget", m_vAimTarget, 'wrld');
		ser.Value("vLookTarget", m_vLookTarget, 'wrld');
		ser.Value("vBodyTarget", m_vBodyTarget, 'wrld');
		ser.Value("vFireTarget", m_vFireTarget, 'wrld');

		//Float
		ser.Value("fpSpeed", m_fPseudoSpeed);
		ser.Value("fdSpeed", m_fDesiredSpeed);
	}

	
	return true;
}


IMPLEMENT_RMI(CCoopGrunt, ClChangeSuitMode)
{
	if (GetNanoSuit())
		GetNanoSuit()->SetMode((ENanoMode)params.suitmode);

	return true;
}


IMPLEMENT_RMI(CCoopGrunt, ClSpecialMovementRequest)
{
	if (CCoopSystem::GetInstance()->GetDebugLog() >= 1)
	{
		if (params.targetParams.animation.c_str() != nullptr && params.targetParams.animation.c_str()[0] != 0)
			CryLogAlways("[%s] Received actor target with %s animation %s.", GetEntity()->GetName(), params.targetParams.signalAnimation ? "signal" : "action", params.targetParams.animation.c_str());
		else
			CryLogAlways("[%s] Received actor target removal.", GetEntity()->GetName());
	}

	if (!gEnv->bServer)
	{
		CMovementRequest movRequest = CMovementRequest();
		if ((params.flags & CMovementRequest::eMRF_ActorTarget) != 0)
		{
			movRequest.SetActorTarget(params.targetParams);
		}
		else if ((params.flags & CMovementRequest::eMRF_RemoveActorTarget) != 0)
		{
			movRequest.ClearActorTarget();
		}


		this->GetMovementController()->RequestMovement(movRequest);
	}
	

	return true;
}

void CCoopGrunt::SendSpecialMovementRequest(uint32 reqFlags, const SActorTargetParams& targetParams)
{
	if (CCoopSystem::GetInstance()->GetDebugLog() >= 1)
	{
		if (targetParams.animation.c_str() && targetParams.animation.c_str()[0] != 0)
			CryLogAlways("[%s] Sending actor target with %s animation %s.", GetEntity()->GetName(), targetParams.signalAnimation ? "signal" : "action", targetParams.animation.c_str());
		else
			CryLogAlways("[%s] Sending actor target removal.", GetEntity()->GetName());
	}
	
	GetGameObject()->InvokeRMI(ClSpecialMovementRequest(), SSpecialMovementRequestParams(reqFlags, targetParams, targetParams.animation), eRMI_ToAllClients | eRMI_NoLocalCalls);
}
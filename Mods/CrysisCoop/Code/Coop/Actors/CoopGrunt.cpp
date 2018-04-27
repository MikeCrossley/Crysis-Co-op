#include "StdAfx.h"
#include "CoopGrunt.h"
#include "PlayerMovementController.h"
#include "IVehicleSystem.h"
#include "Weapon.h"
#include "Movement\CoopGruntMovementController.h"
#include <Coop\Utilities\DedicatedServerHackScope.h>
#include <Coop/CoopSystem.h>

CCoopGrunt::CCoopGrunt() :
	m_nStance(STANCE_RELAXED),
	m_vMoveTarget(Vec3(0, 0, 0)),
	m_vAimTarget(Vec3(0, 0, 0)),
	m_vLookTarget(Vec3(0, 0, 0)),
	m_vBodyTarget(Vec3(0, 0, 0)),
	m_vFireTarget(Vec3(0, 0, 0)),
	m_fPseudoSpeed(0.f),
	m_fDesiredSpeed(0.f),
	m_nAlertness(0.f),
	m_nSuitMode(3),
	m_nMovementNetworkFlags(0),
	m_bHidden(false)
{
	this->RegisterEventListener();
}

CCoopGrunt::~CCoopGrunt()
{
	this->UnregisterEventListener();
}

// Summary:
//	Called before the game rules have reseted entities.
void CCoopGrunt::OnPreResetEntities()
{
	if (!gEnv->bServer || gEnv->bEditor)
		return;

	gEnv->bMultiplayer = false;
	if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
		CryLogAlways("[CCoopGrunt] Cleaning actor %s.", this->GetEntity()->GetName());

	// Unregister existing AI....
	if (IScriptTable* pScriptTable = this->GetEntity()->GetScriptTable())
	{
		gEnv->pScriptSystem->BeginCall(pScriptTable, "UnregisterAI");
		gEnv->pScriptSystem->PushFuncParam(pScriptTable);
		gEnv->pScriptSystem->EndCall(pScriptTable);
		assert(this->GetEntity()->GetAI() == nullptr);
	}

	// Clear existing inventory...
	if (IInventory* pInventory = this->GetInventory())
		pInventory->Clear();

	gEnv->bMultiplayer = true;
}

// Summary:
//	Called after the game rules have reseted entities and the coop system has re-created AI objects.
void CCoopGrunt::OnPostResetEntities()
{
	if (!gEnv->bServer || gEnv->bEditor)
		return;

	gEnv->bMultiplayer = false;
	if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
		CryLogAlways("[CCoopGrunt] Initializing actor %s.", this->GetEntity()->GetName());

	if (IScriptTable* pScriptTable = this->GetEntity()->GetScriptTable())
	{
		// Register the actor's AI on the server.
		gEnv->pScriptSystem->BeginCall(pScriptTable, "RegisterAI");
		gEnv->pScriptSystem->PushFuncParam(pScriptTable);
		gEnv->pScriptSystem->EndCall(pScriptTable);
		assert(this->GetEntity()->GetAI() != nullptr);

		// Equip the actor's equipment pack.
		SmartScriptTable pPropertiesTable = nullptr;
		if (pScriptTable->GetValue("Properties", pPropertiesTable))
		{
			int bNanosuit = 0;
			if (pPropertiesTable->GetValue("bNanoSuit", bNanosuit) && bNanosuit == 1)
				gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GiveItem(this, "NanoSuit", false, false, false);

			const char* sEquipmentPack = nullptr;
			if (pPropertiesTable->GetValue("equip_EquipmentPack", sEquipmentPack))
			{
				bool bResult = gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetIEquipmentManager()->GiveEquipmentPack(this, sEquipmentPack, true, true);
				if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
				{
					CryLogAlways(bResult ? "[CCoopGrunt] Succeeded giving actor %s equipment pack %s." : "[CCoopGrunt] Failed to give actor %s equipment pack %s.", this->GetEntity()->GetName(), sEquipmentPack);
				}
			}
		}
	}

	this->GetGameObject()->SetAIActivation(eGOAIAM_Always);

	if (!gEnv->bEditor)
		gEnv->bMultiplayer = true;
}

bool CCoopGrunt::Init(IGameObject * pGameObject)
{
	CPlayer::Init(pGameObject);

	return true;
}


void CCoopGrunt::PostInit(IGameObject * pGameObject)
{
	CPlayer::PostInit(pGameObject);



	if (gEnv->bServer)
		GetEntity()->SetTimer(eTIMER_WEAPONDELAY, 1000);

}

void CCoopGrunt::RegisterMultiplayerAI()
{
	/*if ((GetHealth() <= 0 && GetEntity()->GetAI()) || (GetEntity()->GetAI() && !gEnv->pAISystem->IsEnabled()))
	{
	gEnv->bMultiplayer = false;

	IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
	gEnv->pScriptSystem->BeginCall(pScriptTable, "UnregisterAI");
	gEnv->pScriptSystem->PushFuncParam(pScriptTable);
	gEnv->pScriptSystem->EndCall(pScriptTable);
	if (CCoopSystem::GetInstance()->GetDebugLog() > 0)
	CryLogAlways("AI Unregistered for Grunt %s", GetEntity()->GetName());

	gEnv->bMultiplayer = true;
	}
	else if (!GetEntity()->GetAI() && GetHealth() > 0 && gEnv->pAISystem->IsEnabled())
	{
	gEnv->bMultiplayer = false;

	IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
	gEnv->pScriptSystem->BeginCall(pScriptTable, "RegisterAI");
	gEnv->pScriptSystem->PushFuncParam(pScriptTable);
	gEnv->pScriptSystem->EndCall(pScriptTable);
	if (CCoopSystem::GetInstance()->GetDebugLog() > 0)
	CryLogAlways("AI Registered for Grunt %s", GetEntity()->GetName());

	gEnv->bMultiplayer = true;
	}*/
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
}

void CCoopGrunt::Update(SEntityUpdateContext& ctx, int updateSlot)
{
	CPlayer::Update(ctx, updateSlot);

	// Register AI System in MP
	if (gEnv->bServer && !gEnv->bEditor)
		RegisterMultiplayerAI();

	// Movement reqeust stuff so proper anims play on client
	if (gEnv->bServer)
	{
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
		m_nStance = currMovement.GetStance();
		m_nAlertness = currMovement.GetAlertness();

		// Bool
		m_nMovementNetworkFlags = currMovement.AllowStrafing() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eAllowStrafing) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eAllowStrafing);
		m_nMovementNetworkFlags = currMovement.HasAimTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasAimTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasAimTarget);
		m_nMovementNetworkFlags = currMovement.HasBodyTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasBodyTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasBodyTarget);
		m_nMovementNetworkFlags = currMovement.HasLookTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasLookTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasLookTarget);
		m_nMovementNetworkFlags = currMovement.HasFireTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasFireTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasFireTarget);
		m_nMovementNetworkFlags = currMovement.HasMoveTarget() ? (m_nMovementNetworkFlags | EAIMovementNetFlags::eHasMoveTarget) : (m_nMovementNetworkFlags & ~EAIMovementNetFlags::eHasMoveTarget);


		if (GetNanoSuit())
		{
			if (GetNanoSuit()->GetMode() != m_nSuitMode)
			{
				m_nSuitMode = GetNanoSuit()->GetMode();
				GetGameObject()->InvokeRMI(ClChangeSuitMode(), SSuitParams(m_nSuitMode), eRMI_ToAllClients | eRMI_NoLocalCalls);
			}
		}

		if (GetHealth() > 0.f)
			GetGameObject()->ChangedNetworkState(ASPECT_ALIVE);
	}
	else
	{
		UpdateMovementState();
	}

	//DrawDebugInfo();
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
}

void CCoopGrunt::ProcessEvent(SEntityEvent& event)
{
	CPlayer::ProcessEvent(event);

	switch (event.event)
	{
	case ENTITY_EVENT_HIDE:
	{
		if (gEnv->bServer)
		{
			//GetInventory()->Clear();
			m_bHidden = true;
			GetGameObject()->ChangedNetworkState(ASPECT_HIDE);
			OnPreResetEntities();
		}

		break;
	}
	case ENTITY_EVENT_UNHIDE:
	{
		if (gEnv->bServer)
		{
			GetEntity()->SetTimer(eTIMER_WEAPONDELAY, 1000);
			m_bHidden = false;
			GetGameObject()->ChangedNetworkState(ASPECT_HIDE);
			OnPostResetEntities();
		}

		break;
	}
	// Register AI when initializing for dynamically spawned AI, too.
	case ENTITY_EVENT_INIT:
	{
		if (gEnv->bServer)
		{
			OnPostResetEntities();
		}
	} break;
	// And clean state when the game is being started for non-hidden AI.
	// This is mostly a fallback for when everything else fails.
	case ENTITY_EVENT_START_GAME:
	{
		if (gEnv->bServer)
		{
			OnPreResetEntities();
			OnPostResetEntities();
		}
	} break;
	/*case ENTITY_EVENT_TIMER:
	{
	switch(event.nParam[0])
	{
	case eTIMER_WEAPONDELAY:
	IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
	SmartScriptTable props;
	if(pScriptTable->GetValue("Properties", props))
	{
	int bNanosuit ;
	char* equip;
	props->GetValue("bNanoSuit", bNanosuit);
	if (bNanosuit == 1)
	gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GiveItem(this, "NanoSuit", false, false, false);

	if (props->GetValue("equip_EquipmentPack", equip))
	gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetIEquipmentManager()->GiveEquipmentPack(this, equip, true, true);
	}

	break;
	}
	}
	break;*/
	}
}

IActorMovementController* CCoopGrunt::CreateMovementController()
{
	return new CCoopGruntMovementController(this);
}

bool CCoopGrunt::NetSerialize(TSerialize ser, EEntityAspects aspect, uint8 profile, int flags)
{
	if (!CPlayer::NetSerialize(ser, aspect, profile, flags))
		return false;

	bool bReading = ser.IsReading();

	switch (aspect)
	{
	case ASPECT_ALIVE:
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

		//Int
		ser.Value("nAlert", m_nAlertness, 'i8');
		ser.Value("nStance", m_nStance, 'i8');
		ser.Value("nFlags", m_nMovementNetworkFlags, 'i8');

		break;
	}
	case ASPECT_HIDE:
	{
		ser.Value("hide", m_bHidden, 'bool');

		if (bReading)
			GetEntity()->Hide(m_bHidden);

		break;
	}
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
	//if(params.targetParams.animation.c_str() != nullptr && params.targetParams.animation.c_str()[0] != 0)
	//	CryLogAlways("[%s] Received actor target with %s animation %s.", GetEntity()->GetName(), params.targetParams.signalAnimation ? "signal" : "action", params.targetParams.animation.c_str());

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
	//if(targetParams.animation.c_str() != nullptr && targetParams.animation.c_str()[0] != 0)
	//	CryLogAlways("[%s] Sending actor target to clients with %s animation %s.", GetEntity()->GetName(), targetParams.signalAnimation ? "signal" : "action", targetParams.animation.c_str());
	GetGameObject()->InvokeRMI(ClSpecialMovementRequest(), SSpecialMovementRequestParams(reqFlags, targetParams, targetParams.animation), eRMI_ToAllClients | eRMI_NoLocalCalls);
}
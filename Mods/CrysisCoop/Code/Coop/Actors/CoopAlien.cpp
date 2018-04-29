#include "StdAfx.h"
#include "CoopAlien.h"
#include "Coop\CoopSystem.h"

#include "CompatibilityAlienMovementController.h"
#include <Coop\Utilities\DedicatedServerHackScope.h>

CCoopAlien::CCoopAlien() :
	m_vLookTarget(Vec3(0,0,0)),
	m_vAimTarget(Vec3(0,0,0)),
	m_bHidden(false)
{
	this->RegisterEventListener();
}

CCoopAlien::~CCoopAlien()
{
	this->UnregisterEventListener();
}

// Summary:
//	Called before the game rules have reseted entities.
void CCoopAlien::OnPreResetEntities()
{
	if (!gEnv->bServer || gEnv->bEditor)
		return;

	gEnv->bMultiplayer = false;
	if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
		CryLogAlways("[CCoopAlien] Cleaning actor %s.", this->GetEntity()->GetName());

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
void CCoopAlien::OnPostResetEntities()
{
	if (!gEnv->bServer || gEnv->bEditor)
		return;

	gEnv->bMultiplayer = false;
	if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
		CryLogAlways("[CCoopAlien] Initializing actor %s.", this->GetEntity()->GetName());

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
			const char* sEquipmentPack = nullptr;
			if (pPropertiesTable->GetValue("equip_EquipmentPack", sEquipmentPack))
			{
				bool bResult = gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetIEquipmentManager()->GiveEquipmentPack(this, sEquipmentPack, true, true);
				if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
				{
					CryLogAlways(bResult ? "[CCoopAlien] Succeeded giving actor %s equipment pack %s." : "[CCoopAlien] Failed to give actor %s equipment pack %s.", this->GetEntity()->GetName(), sEquipmentPack);
				}
			}
		}

		// Call CheckWeaponAttachments to attach things.
		gEnv->pScriptSystem->BeginCall(pScriptTable, "CheckWeaponAttachments");
		gEnv->pScriptSystem->PushFuncParam(pScriptTable);
		gEnv->pScriptSystem->EndCall(pScriptTable);
	}

	this->GetGameObject()->SetAIActivation(eGOAIAM_Always);
	gEnv->bMultiplayer = true;
}

bool CCoopAlien::Init(IGameObject * pGameObject)
{
	CAlien::Init(pGameObject);

	return true;
}

void CCoopAlien::PostInit( IGameObject * pGameObject )
{
	CAlien::PostInit(pGameObject);

	pGameObject->SetAIActivation(eGOAIAM_Always);

	if (gEnv->bServer)
		GetEntity()->SetTimer(eTIMER_WEAPONDELAY, 1000);
}

void CCoopAlien::RegisterMultiplayerAI()
{
	if (!GetEntity()->GetAI() && GetHealth() > 0)
	{
		gEnv->bMultiplayer = false;

		IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
		gEnv->pScriptSystem->BeginCall(pScriptTable, "RegisterAI");
		gEnv->pScriptSystem->PushFuncParam(pScriptTable);
		gEnv->pScriptSystem->EndCall(pScriptTable);
		if (CCoopSystem::GetInstance()->GetDebugLog() > 0)
			CryLogAlways("AI Registered for Alien %s", GetEntity()->GetName());

		gEnv->bMultiplayer = true;
	}
}

void CCoopAlien::Update(SEntityUpdateContext& ctx, int updateSlot)
{
	CAlien::Update(ctx, updateSlot);

	// Register AI System in MP
	if (gEnv->bServer && !gEnv->bEditor)
		RegisterMultiplayerAI();

	// Movement reqeust stuff so proper anims play on client
	if (gEnv->bServer)
	{
		SMovementState currMovement = static_cast<CCompatibilityAlienMovementController*>(GetMovementController())->GetMovementReqState();
		CMovementRequest moveReq = static_cast<CCompatibilityAlienMovementController*>(GetMovementController())->GetMovementReq();

		//Vec3
		m_vMoveTarget = GetEntity()->GetWorldPos() + currMovement.movementDirection;
		m_vAimTarget = currMovement.eyePosition + currMovement.aimDirection;
		m_vLookTarget = currMovement.eyePosition + currMovement.eyeDirection;
		m_vFireTarget = currMovement.fireTarget;

		// Float
		m_fDesiredSpeed = m_moveRequest.velocity.GetLength();

		// Int
		m_nStance = (int)currMovement.stance;

		// Bool
		m_bHasAimTarget = currMovement.isAiming;

		if (GetHealth() > 0.f)
			GetGameObject()->ChangedNetworkState(ASPECT_ALIVE);
	}
	else
	{
		UpdateMovementState();
	}

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

	//this->DrawDebugInfo();
}

void CCoopAlien::DrawDebugInfo()
{
	static float color[] = { 1,1,1,1 };

	if (gEnv->bServer)
		gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false, "IsServer");
	else
		gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false, "IsClient");

	gEnv->pRenderer->Draw2dLabel(5, 25, 2, color, false, "MoveTarget x%f y%f z%f", m_vMoveTarget.x, m_vMoveTarget.y, m_vMoveTarget.z);
	gEnv->pRenderer->Draw2dLabel(5, 45, 2, color, false, "AimTarget x%f y%f z%f", m_vAimTarget.x, m_vAimTarget.y, m_vAimTarget.z);
	gEnv->pRenderer->Draw2dLabel(5, 65, 2, color, false, "LookTarget x%f y%f z%f", m_vLookTarget.x, m_vLookTarget.y, m_vLookTarget.z);
	gEnv->pRenderer->Draw2dLabel(5, 105, 2, color, false, "FireTarget x%f y%f z%f", m_vFireTarget.x, m_vFireTarget.y, m_vFireTarget.z);

	gEnv->pRenderer->Draw2dLabel(5, 165, 2, color, false, "DesiredSpeed %f", m_fDesiredSpeed);

	gEnv->pRenderer->Draw2dLabel(5, 205, 2, color, false, "Stance %d", m_nStance);

	gEnv->pRenderer->Draw2dLabel(5, 225, 2, color, false, "HasAimTarget %d", (int)m_bHasAimTarget);

	gEnv->pRenderer->Draw2dLabel(5, 305, 2, color, false, "m_input.movementVector x%f y%f z%f", m_input.movementVector.x, m_input.movementVector.y, m_input.movementVector.z);
	gEnv->pRenderer->Draw2dLabel(5, 325, 2, color, false, "m_stats.speed %f", m_stats.speed);

}

void CCoopAlien::UpdateMovementState()
{
	CMovementRequest request;
	request.SetMoveTarget(GetEntity()->GetPos() + m_vMoveTarget);
	request.SetLookTarget(m_vLookTarget);
	request.SetBodyTarget(GetEntity()->GetWorldRotation() * Vec3(0, 1, 0));
	request.SetFireTarget(m_vFireTarget);

	request.SetDesiredSpeed(m_fDesiredSpeed);
	m_stats.speed = m_fDesiredSpeed;
	m_stats.fireDir = Vec3(ZERO);

	request.SetStance((EStance)m_nStance);

	//if (m_bHasAimTarget)
	//	request.SetAimTarget(m_vAimTarget);
	//else
		request.ClearAimTarget();

	SetActorMovement(SMovementRequestParams(request));
}

void CCoopAlien::ProcessEvent(SEntityEvent& event)
{
	CAlien::ProcessEvent(event);

	switch(event.event)
	{
		case ENTITY_EVENT_HIDE:
		{
			if (gEnv->bServer)
			{
				GetInventory()->Clear();
				m_bHidden = true;
				GetGameObject()->ChangedNetworkState(ASPECT_HIDE);
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
			}

			break;
		}
	case ENTITY_EVENT_TIMER:
		{
			switch(event.nParam[0])
			{
			case eTIMER_WEAPONDELAY:
				IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
				SmartScriptTable props;
				if(pScriptTable->GetValue("Properties", props))
				{
					char* equip;
					if (props->GetValue("equip_EquipmentPack", equip))
						gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetIEquipmentManager()->GiveEquipmentPack(this, equip, true, true);
				}

				break;
			}
		}
		break;
	}
}

bool CCoopAlien::NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags )
{
	if (!CAlien::NetSerialize(ser, aspect, profile, flags))
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

			//Float
			ser.Value("fdSpeed", m_fDesiredSpeed);

			//Int
			ser.Value("nStance", m_nStance, 'i8');

			//Bool
			ser.Value("bTarget", m_bHasAimTarget, 'bool');

			break;
		}
		case ASPECT_HIDE:
		{
			ser.Value("bHide", m_bHidden, 'bool');

			if (bReading)
				GetEntity()->Hide(m_bHidden);

			break;
		}
	}

	return true;
}


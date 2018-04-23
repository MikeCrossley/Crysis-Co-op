#include "StdAfx.h"
#include "CoopHunter.h"
#include "Coop\CoopSystem.h"

#include "CompatibilityAlienMovementController.h"
#include <Coop\Utilities\DedicatedServerHackScope.h>

CCoopHunter::CCoopHunter() :
	m_vLookTarget(Vec3(0,0,0)),
	m_vAimTarget(Vec3(0,0,0)),
	m_bHidden(false)
{
}

CCoopHunter::~CCoopHunter()
{
}

bool CCoopHunter::Init(IGameObject * pGameObject)
{
	CHunter::Init(pGameObject);

	return true;
}

void CCoopHunter::PostInit( IGameObject * pGameObject )
{
	CHunter::PostInit(pGameObject);

	pGameObject->SetAIActivation(eGOAIAM_Always);

	if (gEnv->bServer)
		GetEntity()->SetTimer(eTIMER_WEAPONDELAY, 1000);
}

void CCoopHunter::RegisterMultiplayerAI()
{
	if (GetHealth() <= 0 && GetEntity()->GetAI())
	{
		gEnv->bMultiplayer = false;

		IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
		gEnv->pScriptSystem->BeginCall(pScriptTable, "UnregisterAI");
		gEnv->pScriptSystem->PushFuncParam(pScriptTable);
		gEnv->pScriptSystem->EndCall(pScriptTable);
		CryLogAlways("AI Unregistered for Hunter %s", GetEntity()->GetName());

		gEnv->bMultiplayer = true;
	}
	else if (!GetEntity()->GetAI() && GetHealth() > 0)
	{
		gEnv->bMultiplayer = false;

		IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
		gEnv->pScriptSystem->BeginCall(pScriptTable, "RegisterAI");
		gEnv->pScriptSystem->PushFuncParam(pScriptTable);
		gEnv->pScriptSystem->EndCall(pScriptTable);
		CryLogAlways("AI Registered for Hunter %s", GetEntity()->GetName());

		gEnv->bMultiplayer = true;
	}
}

void CCoopHunter::Update(SEntityUpdateContext& ctx, int updateSlot)
{
	CHunter::Update(ctx, updateSlot);

	// Register AI System in MP
	if (gEnv->bServer && !gEnv->bEditor)
		RegisterMultiplayerAI();

	// Movement reqeust stuff so proper anims play on client
	if (gEnv->bServer)
	{
		SMovementState currMovement = static_cast<CCompatibilityAlienMovementController*>(GetMovementController())->GetMovementReqState();

		m_vLookTarget = currMovement.eyePosition + currMovement.bodyDirection;
		m_vAimTarget = currMovement.eyePosition + currMovement.aimDirection;

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

}

void CCoopHunter::UpdateMovementState()
{
	CMovementRequest request;
	request.SetBodyTarget(m_vLookTarget);
	request.SetLookTarget(m_vLookTarget);
	request.SetAimTarget(m_vAimTarget);


	SetActorMovement(SMovementRequestParams(request));
}

void CCoopHunter::ProcessEvent(SEntityEvent& event)
{
	CHunter::ProcessEvent(event);

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

bool CCoopHunter::NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags )
{
	if (!CHunter::NetSerialize(ser, aspect, profile, flags))
		return false;

	bool bReading = ser.IsReading();

	switch (aspect)
	{
		case ASPECT_ALIVE:
		{
			ser.Value("vLookTarget", m_vLookTarget, 'wrld');
			ser.Value("vAimTarget", m_vAimTarget, 'wrld');
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


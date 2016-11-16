#include "StdAfx.h"
#include "CoopScout.h"
#include "Coop\CoopSystem.h"

#include "CompatibilityAlienMovementController.h"

CCoopScout::CCoopScout() :
	m_coopLookTarget(Vec3(0,0,0)),
	m_coopAimTarget(Vec3(0,0,0))
{
}

CCoopScout::~CCoopScout()
{
}

bool CCoopScout::Init(IGameObject * pGameObject)
{
	CScout::Init(pGameObject);

	return true;
}


void CCoopScout::PostInit( IGameObject * pGameObject )
{
	CScout::PostInit(pGameObject);
}

void CCoopScout::Update(SEntityUpdateContext& ctx, int updateSlot)
{
	CScout::Update(ctx, updateSlot);

	// Register Grunt to AI System in MP
	if (gEnv->bServer && !gEnv->bEditor)
	{
		if (GetHealth() <= 0 && GetEntity()->GetAI())
		{
			gEnv->bMultiplayer = false;

			IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
			gEnv->pScriptSystem->BeginCall(pScriptTable, "UnregisterAI");
			gEnv->pScriptSystem->PushFuncParam(pScriptTable);
			gEnv->pScriptSystem->EndCall(pScriptTable);


			CryLogAlways("AI Unregistered for Scout %s", GetEntity()->GetName());

			gEnv->bMultiplayer = true;
		}
		else if (!GetEntity()->GetAI() && GetHealth() > 0)
		{
			gEnv->bMultiplayer = false;

			IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
			gEnv->pScriptSystem->BeginCall(pScriptTable, "RegisterAI");
			gEnv->pScriptSystem->PushFuncParam(pScriptTable);
			gEnv->pScriptSystem->EndCall(pScriptTable);
			CryLogAlways("AI Registered for Scout %s", GetEntity()->GetName());

			gEnv->bMultiplayer = true;
		}
	}

	// Movement reqeust stuff so proper anims play on client
	if (gEnv->bServer)
	{
		CCompatibilityAlienMovementController* pMovement = static_cast<CCompatibilityAlienMovementController*>(GetMovementController());
		SMovementState currMovement = pMovement->GetMovementReqState();

		//Vec3
		m_coopLookTarget = currMovement.eyePosition + currMovement.bodyDirection;
		m_coopAimTarget = currMovement.eyePosition + currMovement.aimDirection;
	}
	else
	{
		CMovementRequest request;
		request.SetBodyTarget(m_coopLookTarget);
		request.SetLookTarget(m_coopLookTarget);
		request.SetAimTarget(m_coopAimTarget);


		SetActorMovement(SMovementRequestParams(request));
	}

	static float color[] = {1,1,1,1};   

	/*if (gEnv->bServer)
		gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false,"IsServer" );
	else
		gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false,"IsClient" );

	gEnv->pRenderer->Draw2dLabel(5, 65, 2, color, false,"LookDirection x%f y%f z%f", m_coopLookTarget.x, m_coopLookTarget.y, m_coopLookTarget.z );
	gEnv->pRenderer->Draw2dLabel(5, 85, 2, color, false,"AimDirection x%f y%f z%f", m_coopAimTarget.x, m_coopAimTarget.y, m_coopAimTarget.z );*/


	if (gEnv->bServer)
		GetGameObject()->ChangedNetworkState(ASPECT_ALIVE);
}

void CCoopScout::ProcessEvent(SEntityEvent& event)
{
	CScout::ProcessEvent(event);

	switch(event.event)
	{
	case ENTITY_EVENT_HIDE:
		{
			if (gEnv->bServer)
				GetInventory()->Clear();
		}
	case ENTITY_EVENT_UNHIDE:
		{
			if (gEnv->bServer)
				GetEntity()->SetTimer(eTIMER_WEAPONDELAY, 1000);
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
					{
						gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetIEquipmentManager()->GiveEquipmentPack(this, equip, true, true);
					}
				}

				break;
			}
		}
		break;
	}
}

bool CCoopScout::NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags )
{
	if (!CScout::NetSerialize(ser, aspect, profile, flags))
		return false;

	if (aspect == ASPECT_ALIVE)
	{
		//Vec3
		ser.Value("lookTrgt", m_coopLookTarget);
		ser.Value("aimTrgt", m_coopAimTarget);
	}
	return true;
}


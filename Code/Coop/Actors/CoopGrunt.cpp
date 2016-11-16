#include "StdAfx.h"
#include "CoopGrunt.h"
#include "PlayerMovementController.h"
#include "IVehicleSystem.h"
#include "Weapon.h"

CCoopGrunt::CCoopGrunt() :
	m_coopStance(STANCE_RELAXED),
	m_coopMoveTarget(Vec3(0,0,0)),
	m_coopAimTarget(Vec3(0,0,0)),
	m_coopLookTarget(Vec3(0,0,0)),
	m_coopBodyTarget(Vec3(0,0,0)),
	m_coopFireTarget(Vec3(0,0,0)),
	m_fPseudoSpeed(0.f),
	m_fcoopDesiredSpeed(0.f),
	m_coopAlertness(0.f),
	m_bAllowStrafing(false),
	m_bHasAimTarget(false),
	m_coopsuitMode(3)
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

	pGameObject->SetAIActivation(eGOAIAM_Always);

	IScriptTable* pScriptTable = GetEntity()->GetScriptTable();

	if (gEnv->bServer)
	{
		GetEntity()->SetTimer(eTIMER_WEAPONDELAY, 1000);
	}
	else
	{
		SetStance(STANCE_RELAXED);
	}
}

void CCoopGrunt::Update(SEntityUpdateContext& ctx, int updateSlot)
{
	CPlayer::Update(ctx, updateSlot);

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


			CryLogAlways("AI Unregistered for Grunt %s", GetEntity()->GetName());

			gEnv->bMultiplayer = true;
		}
		else if (!GetEntity()->GetAI() && GetHealth() > 0)
		{
			gEnv->bMultiplayer = false;

			IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
			gEnv->pScriptSystem->BeginCall(pScriptTable, "RegisterAI");
			gEnv->pScriptSystem->PushFuncParam(pScriptTable);
			gEnv->pScriptSystem->EndCall(pScriptTable);
			CryLogAlways("AI Registered for Grunt %s", GetEntity()->GetName());

			gEnv->bMultiplayer = true;
		}
	}

	// Movement reqeust stuff so proper anims play on client
	if (gEnv->bServer)
	{
		CPlayerMovementController* pMovement = static_cast<CPlayerMovementController*>(m_pMovementController);
		CMovementRequest currMovement = pMovement->GetMovementReqState();

		//Vec3
		m_coopMoveTarget = currMovement.GetMoveTarget();
		m_coopAimTarget = currMovement.GetAimTarget();
		m_coopLookTarget = currMovement.GetLookTarget();
		m_coopBodyTarget = currMovement.GetBodyTarget();
		m_coopFireTarget = currMovement.GetFireTarget();
		
		// Float
		m_fPseudoSpeed = currMovement.GetPseudoSpeed();
		m_fcoopDesiredSpeed = currMovement.GetDesiredSpeed();

		// Int
		m_coopAlertness = currMovement.GetAlertness();
		
		// Bool
		m_bAllowStrafing = currMovement.AllowStrafing();


		// RMI updates ( I Think these update faster so its good for the important stuff)

		int stance = currMovement.GetStance();
		if (stance != m_coopStance)
		{
			m_coopStance = stance;
			GetGameObject()->InvokeRMI(ClChangeStance(), SSuitParams(m_coopStance), eRMI_ToAllClients | eRMI_NoLocalCalls);
		}

		if (GetNanoSuit())
		{
			if (GetNanoSuit()->GetMode() != m_coopsuitMode)
			{
				m_coopsuitMode = GetNanoSuit()->GetMode();
				GetGameObject()->InvokeRMI(ClChangeSuitMode(), SSuitParams(m_coopsuitMode), eRMI_ToAllClients | eRMI_NoLocalCalls);
			}
		}

		bool hasAim = currMovement.HasAimTarget();
		if (m_bHasAimTarget != hasAim)
		{
			m_bHasAimTarget = hasAim;
			GetGameObject()->InvokeRMI(ClUpdateAiming(), SAimParams(hasAim), eRMI_ToAllClients | eRMI_NoLocalCalls);
		}

	}
	else
	{
		CMovementRequest request;

		if (m_coopAimTarget != Vec3(0,0,0) || m_coopLookTarget != Vec3(0,0,0) || m_coopMoveTarget != Vec3(0,0,0))
		{
			//Vec3
			request.SetMoveTarget(m_coopMoveTarget);

			if (m_bHasAimTarget)
			{
				request.SetAimTarget(m_coopAimTarget);
				request.SetBodyTarget(m_coopAimTarget);
			}
			else
			{
				request.SetBodyTarget(m_coopLookTarget);
				request.ClearAimTarget();
			}



			request.SetLookTarget(m_coopLookTarget);
			request.SetFireTarget(m_coopLookTarget);

			//Float
			request.SetPseudoSpeed(m_fPseudoSpeed);
			request.SetDesiredSpeed(m_fcoopDesiredSpeed);

			// Int
			request.SetAlertness(m_coopAlertness);
			request.SetStance((EStance)m_coopStance);

			//Bool
			request.SetAllowStrafing(m_bAllowStrafing);

			GetMovementController()->RequestMovement(request);

			if (IVehicle* pVehicle = GetLinkedVehicle())
			{
				EntityId nWeaponEntity = pVehicle->GetCurrentWeaponId(GetEntityId());
				CWeapon* pWeapon = (CWeapon*)gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GetItem(nWeaponEntity);
				if (pWeapon)
				{
					pWeapon->SetAimLocation(m_coopAimTarget);
					pWeapon->SetTargetLocation(m_coopAimTarget);
				}
			}

		} // ~ if (m_coopAimTarget != Vec3(0,0,0) && m_coopLookTarget != Vec3(0,0,0))
		else
		{
			CPlayerMovementController* pMovement = static_cast<CPlayerMovementController*>(m_pMovementController);
			CMovementRequest request = pMovement->GetMovementReqState();
			request.SetStance(STANCE_RELAXED);
			GetMovementController()->RequestMovement(request);
		}
	}

	/*static float color[] = {1,1,1,1};   

	if (strcmp(GetEntity()->GetName(), "CoopGrunt1") == 0)
	{
		if (gEnv->bServer)
			gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false,"IsServer" );
		else
			gEnv->pRenderer->Draw2dLabel(5, 5, 2, color, false,"IsClient" );

		gEnv->pRenderer->Draw2dLabel(5, 25, 2, color, false,"MoveTarget x%f y%f z%f", m_coopMoveTarget.x, m_coopMoveTarget.y, m_coopMoveTarget.z );
		gEnv->pRenderer->Draw2dLabel(5, 45, 2, color, false,"AimTarget x%f y%f z%f", m_coopAimTarget.x, m_coopAimTarget.y, m_coopAimTarget.z );
		gEnv->pRenderer->Draw2dLabel(5, 65, 2, color, false,"LookTarget x%f y%f z%f", m_coopLookTarget.x, m_coopLookTarget.y, m_coopLookTarget.z );
		gEnv->pRenderer->Draw2dLabel(5, 85, 2, color, false,"BodyTarget x%f y%f z%f", m_coopBodyTarget.x, m_coopBodyTarget.y, m_coopBodyTarget.z );
		gEnv->pRenderer->Draw2dLabel(5, 105, 2, color, false,"FireTarget x%f y%f z%f", m_coopFireTarget.x, m_coopFireTarget.y, m_coopFireTarget.z );

		gEnv->pRenderer->Draw2dLabel(5, 145, 2, color, false,"PsuedoSpeed %f", m_fPseudoSpeed );
		gEnv->pRenderer->Draw2dLabel(5, 165, 2, color, false,"DesiredSpeed %f", m_fcoopDesiredSpeed );

		gEnv->pRenderer->Draw2dLabel(5, 185, 2, color, false,"Alertness %d", m_coopAlertness );
		gEnv->pRenderer->Draw2dLabel(5, 205, 2, color, false,"Stance %d", m_coopStance );

		gEnv->pRenderer->Draw2dLabel(5, 225, 2, color, false,"Allow Strafing %d     HasAimTarget %d", (int)m_bAllowStrafing, (int)m_bHasAimTarget );
		if (GetNanoSuit())
			gEnv->pRenderer->Draw2dLabel(5, 265, 2, color, false,"Suit mode %d", GetNanoSuit()->GetMode() );
	}*/

	if (gEnv->bServer)
		GetGameObject()->ChangedNetworkState(ASPECT_ALIVE);
}

void CCoopGrunt::ProcessEvent(SEntityEvent& event)
{
	CPlayer::ProcessEvent(event);

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
					int bNanosuit ;
					props->GetValue("bNanoSuit", bNanosuit);
					if (bNanosuit == 1)
					{
						gEnv->pGame->GetIGameFramework()->GetIItemSystem()->GiveItem(this, "NanoSuit", false, false, false);
					}

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

bool CCoopGrunt::NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags )
{
	if (!CPlayer::NetSerialize(ser, aspect, profile, flags))
		return false;

	if (aspect == ASPECT_ALIVE)
	{
		//Vec3
		ser.Value("moveTrgt", m_coopMoveTarget, 'wrld');
		ser.Value("aimTrgt", m_coopAimTarget, 'wrld');
		ser.Value("lookTrgt", m_coopLookTarget, 'wrld'); 

		//Float
		ser.Value("peudoSpeed", m_fPseudoSpeed);
		ser.Value("desSpeed", m_fcoopDesiredSpeed);

		//Int
		ser.Value("alrt", m_coopAlertness, 'i8');

		//Bool
		ser.Value("Strafe", m_bAllowStrafing, 'bool');
	}
	
	return true;
}


IMPLEMENT_RMI(CCoopGrunt, ClChangeSuitMode)
{
	if (GetNanoSuit())
	{
		GetNanoSuit()->SetMode((ENanoMode)params.suitmode);
	}

	return true;
}

IMPLEMENT_RMI(CCoopGrunt, ClUpdateAiming)
{
	m_bHasAimTarget = params.bAiming;

	return true;
}

IMPLEMENT_RMI(CCoopGrunt, ClChangeStance)
{
	m_coopStance = params.suitmode;

	return true;
}
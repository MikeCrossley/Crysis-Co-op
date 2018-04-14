#include "StdAfx.h"
#include "Defib.h"
#include "Game.h"
#include "Item.h"
#include "Weapon.h"
#include "Player.h"
#include "GameCVars.h"
#include "GameRules.h"
#include <IEntitySystem.h>

#include <HUD/HUD.h>


//------------------------------------------------------------------------
CDefib::CDefib() :
	m_reviving(false)
	, m_delayTimer(0.0f)
	, m_fProgress(0.f)
{
}

//------------------------------------------------------------------------
CDefib::~CDefib()
{
}

//------------------------------------------------------------------------
void CDefib::Init(IWeapon *pWeapon, const struct IItemParamsNode *params)
{
	m_pWeapon = static_cast<CWeapon *>(pWeapon);

	if (params)
		ResetParams(params);

	m_reviving = false;
	m_soundId = INVALID_SOUNDID;
}

//------------------------------------------------------------------------
void CDefib::Update(float frameTime, uint frameId)
{
	FUNCTION_PROFILER( GetISystem(), PROFILE_GAME );

	if (!m_reviving)
		return;

	if (m_delayTimer > 0.0f)
	{
		m_delayTimer -= frameTime;

		if (m_delayTimer <= 0.0f)
		{
			m_delayTimer = 0.0f;

			if (m_pWeapon->IsClient())
			{
				m_pWeapon->PlayAction(m_workactions.prefire.c_str());

				if (m_soundId != INVALID_SOUNDID)
				{
					if (ISound *pSound = m_pWeapon->GetISound(m_soundId))
					{
						pSound->SetLoopMode(true);
						pSound->SetPaused(false);
					}
				}
			}
		}
	}

	IEntity* pEntity = this->CanRevive();

	// Force revive to end if entity no longer aimed at
	if (!pEntity && m_pWeapon->GetOwnerActor()->IsClient())
	{
		StopRevive();
	}

	// Revive player on completion
	if (m_fProgress > 100.f)
	{
		StopRevive();

		if (m_pWeapon->IsServer())
			m_pWeapon->GetGameObject()->InvokeRMI(CWeapon::ClStopFire(), CWeapon::EmptyParams(), eRMI_ToRemoteClients);
	}
	else
	{
		m_fProgress += frameTime * 20.f;
	}


	// Update HUD Progress
	if (m_pWeapon->GetOwnerActor() && pEntity)
	{
		if (m_pWeapon->GetOwnerActor()->IsClient())
		{
			if (CHUD* pHUD = g_pGame->GetHUD())
			{
				string sProgressString = ""; sProgressString.Format("Rebooting %s's Nanosuit", pEntity->GetName());

				pHUD->ShowProgress(CLAMP(m_fProgress, 0, 100), true, 400, 200, sProgressString);
			}
		}
	}
}

//------------------------------------------------------------------------
void CDefib::Release()
{
	delete this;
}

//------------------------------------------------------------------------
void CDefib::ResetParams(const struct IItemParamsNode *params)
{
	const IItemParamsNode *work = params?params->GetChild("work"):0;
	const IItemParamsNode *actions = params?params->GetChild("actions"):0;

	m_workparams.Reset(work);
	m_workactions.Reset(actions);
}

//------------------------------------------------------------------------
void CDefib::PatchParams(const struct IItemParamsNode *patch)
{
	const IItemParamsNode *work = patch->GetChild("work");
	const IItemParamsNode *actions = patch->GetChild("actions");

	m_workparams.Reset(work, false);
	m_workactions.Reset(actions, false);
}

//------------------------------------------------------------------------
void CDefib::Activate(bool activate)
{
	m_delayTimer = 0.0f;

	if (m_soundId!=INVALID_SOUNDID)
		m_pWeapon->StopSound(m_soundId);

	m_soundId=INVALID_SOUNDID;
}

//------------------------------------------------------------------------
bool CDefib::CanFire(bool considerAmmo) const
{
	return m_delayTimer<=0.0f;
}

//------------------------------------------------------------------------
void CDefib::StartFire()
{
	if (m_pWeapon->IsBusy() || !CanFire(false) || !CanRevive())
		return;

	m_pWeapon->EnableUpdate(true, eIUS_FireMode);

	StartRevive();

	if (!m_pWeapon->IsServer())
		m_pWeapon->RequestStartFire();
}

//------------------------------------------------------------------------
void CDefib::StopFire()
{
	if (m_reviving)
	{
		m_pWeapon->EnableUpdate(false, eIUS_FireMode);
		
		StopRevive();

		if (!m_pWeapon->IsServer())
			m_pWeapon->RequestStopFire();
	}
}

//------------------------------------------------------------------------
void CDefib::NetStartFire()
{
	m_pWeapon->EnableUpdate(true, eIUS_FireMode);

	StartRevive();
}

//------------------------------------------------------------------------
void CDefib::NetStopFire()
{
	m_pWeapon->EnableUpdate(false, eIUS_FireMode);

	StopRevive();
}

//------------------------------------------------------------------------
const char *CDefib::GetType() const
{
	return "Defib";
}

//------------------------------------------------------------------------
void CDefib::GetMemoryStatistics(ICrySizer * s)
{
	s->Add(*this);
	s->Add(m_name);
	m_workparams.GetMemoryStatistics(s);
	m_workactions.GetMemoryStatistics(s);
}

//------------------------------------------------------------------------
IEntity* CDefib::CanRevive()
{
	static Vec3 pos,dir; 
	
	CActor* pActor=m_pWeapon->GetOwnerActor();
	
	static IPhysicalEntity* pSkipEntities[10];
	int nSkip = CSingle::GetSkipEntities(m_pWeapon, pSkipEntities, 10);

	IEntity *pEntity=0;
	float range=m_workparams.range;
	
	IMovementController * pMC = pActor ? pActor->GetMovementController() : 0;
	if (pMC)
	{ 
		SMovementState info;
		pMC->GetMovementState(info);

		pos = info.weaponPosition;

		if (!pActor->IsPlayer())
		{
			dir = range * (info.fireTarget-pos).normalized();
		}
		else
		{
			dir = range * info.fireDirection;    

			// marcok: leave this alone
			if (g_pGameCVars->goc_enable && pActor->IsClient())
			{
				CPlayer *pPlayer = (CPlayer*)pActor;
				pos = pPlayer->GetViewMatrix().GetTranslation();
			}
		}
	}
	else
	{ 
		assert(0);
	}

	primitives::sphere sphere;
	sphere.center = pos;
	sphere.r = m_workparams.radius;
	
	geom_contact *pContact=0;
	float dst = gEnv->pPhysicalWorld->PrimitiveWorldIntersection(sphere.type, &sphere, dir, ent_all, &pContact, 0, (geom_colltype_player<<rwi_colltype_bit)|rwi_stop_at_pierceable, 0, 0, 0, pSkipEntities, nSkip);

	if (pContact && dst>=0.0f && pContact->t<1e8)
	{
		IPhysicalEntity *pCollider = gEnv->pPhysicalWorld->GetPhysicalEntityById(pContact->iPrim[0]);

		if(pCollider && pCollider->GetiForeignData() == PHYS_FOREIGN_ID_ENTITY)
		{
			if (pEntity = static_cast<IEntity *>(pCollider->GetForeignData(PHYS_FOREIGN_ID_ENTITY)))
			{
				if (IActor* pActor = gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor(pEntity->GetId()))
				{
					if (pActor->IsPlayer() && pActor->GetHealth() <= 0.f)
					{
						// Is Player?
						return pEntity;
					}
				}
			}
		}
	}

	return 0;
}

//------------------------------------------------------------------------
void CDefib::StartRevive()
{
	m_delayTimer = m_workparams.delay;
	m_pWeapon->SetBusy(true);

	m_soundId = m_pWeapon->PlayAction(m_workactions.work.c_str(), 0, true, CItem::eIPAF_Default | CItem::eIPAF_CleanBlending | CItem::eIPAF_SoundStartPaused);
	m_pWeapon->SetDefaultIdleAnimation(CItem::eIGS_FirstPerson, m_workactions.work.c_str());

	m_fProgress = 0.f;
	m_reviving = true;
}

//------------------------------------------------------------------------
void CDefib::StopRevive()
{
	m_pWeapon->PlayAction(m_workactions.postfire.c_str());
	m_pWeapon->PlayAction(m_workactions.idle.c_str(), 0, true, CItem::eIPAF_Default | CItem::eIPAF_CleanBlending);
	m_pWeapon->SetDefaultIdleAnimation(CItem::eIGS_FirstPerson, m_workactions.idle.c_str());

	if (m_soundId != INVALID_SOUNDID)
	{
		m_pWeapon->StopSound(m_soundId);
		m_soundId = INVALID_SOUNDID;
	}

	// Do Revive
	if (m_pWeapon->GetOwnerActor()->IsClient() && m_fProgress >= 100.f)
	{
		if (CGameRules *pGameRules = g_pGame->GetGameRules())
		{
			if (IScriptTable *pScriptTable = pGameRules->GetEntity()->GetScriptTable())
			{
				if (pScriptTable->GetValueType("DefibPlayer") == svtFunction)
				{
					IEntity* pEntity = this->CanRevive();

					if (pEntity)
					{
						CryLogAlways("Request Revive %s", pEntity->GetName());
						Script::CallMethod(pScriptTable, "DefibPlayer", ScriptHandle(pEntity->GetId()));
					}
				}
				else
				{
					CryLogAlways("[CDefib::StopRevive] FUNCTION: DefibPlayer not implemented for current gamerules.");
				}
			}
		}
	}

	if (m_pWeapon->GetOwnerActor())
	{
		if (m_pWeapon->GetOwnerActor()->IsClient())
		{
			if (CHUD* pHUD = g_pGame->GetHUD())
			{
				pHUD->ShowProgress();
			}
		}
	}

	m_fProgress = 0.f;
	m_pWeapon->SetBusy(false);
	m_reviving = false;
	m_delayTimer = 0.0f;
}
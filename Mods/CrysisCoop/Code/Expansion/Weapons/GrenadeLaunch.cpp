/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$

-------------------------------------------------------------------------
History:
- 10:10:2007   8:00 : Created by Denisz Polgár

*************************************************************************/
#include "StdAfx.h"
#include <ICryAnimation.h>
#include "Shotgun.h"
#include "GrenadeLaunch.h"
#include "Item.h"
#include "Weapon.h"
#include "Projectile.h"
#include "Actor.h"
#include "Player.h"
#include "Game.h"
#include "GameCVars.h"
#include "HUD/HUD.h"
#include "HUD/HUDRadar.h"
#include "WeaponSystem.h"
#include <IEntitySystem.h>
#include "ISound.h"
#include <IVehicleSystem.h>
#include <IMaterialEffects.h>
#include "GameRules.h"
#include <Cry_GeoDistance.h>

#include "IronSight.h"

#include "IRenderer.h"
#include "IRenderAuxGeom.h"	

class CGrenadeLaunch::CRotateDrumAction
{
	public:
		CRotateDrumAction(CGrenadeLaunch *_launcher, float _time, bool _reverse)
		{
			launcher = _launcher;
			time = _time;
			reverse = _reverse;
		}

		void execute(CItem *_this)
		{
			if (launcher)
			{
				launcher->RotateDrum(time, reverse);
			}
		}
	private:
		CGrenadeLaunch *launcher;
		float time;
		bool reverse;
};

CGrenadeLaunch::CGrenadeLaunch()
:	m_oldAmmo(NULL),
	m_magazineDrum(-1),
	m_reloadShell(-1),
	m_lastGrenadeId(0),
	m_rotateTime(0)
{
	m_magazineRotation=Quat::CreateIdentity();
}

CGrenadeLaunch::~CGrenadeLaunch()
{
}

void CGrenadeLaunch::Activate(bool activate)
{
	CShotgun::Activate(activate);

	ICharacterInstance *pCharacter = m_pWeapon ? m_pWeapon->GetEntity()->GetCharacter(0) : NULL;

	if (pCharacter) 
  {
		IAttachmentManager* pAttachMan = pCharacter->GetIAttachmentManager();
		m_magazineDrum=pAttachMan->GetIndexByName("magazine");

		m_reloadShell=pAttachMan->GetIndexByName(m_fireparams.ammo_type_class->GetName());
	}
	else
	{
		m_magazineDrum=-1;
		m_reloadShell=-1;
	}

	ResetShells();
}

void CGrenadeLaunch::Reload(int zoomed)
{
	CShotgun::Reload(zoomed);
}

void CGrenadeLaunch::EndReload(int zoomed)
{
	// Shoot or melee attack while reloading
	if (m_break_reload || m_reload_was_broken)
	{
		ResetShells();
	}

	CShotgun::EndReload(zoomed);
}

class CGrenadeLaunch::ScheduleReload
{
public:
	ScheduleReload(CWeapon *wep)
	{
		_pWeapon = wep;
	}
	void execute(CItem *item) 
	{
		_pWeapon->Reload();
	}
private:
	CWeapon *_pWeapon;
};

bool CGrenadeLaunch::Shoot(bool resetAnimation, bool autoreload/* =true */, bool noSound /* =false */)
{
	IEntityClass* spawn_ammo = m_grenadeLaunchParams.ammo_type_class;

	if (m_reloading)
	{
		if(m_pWeapon->IsBusy())
			m_pWeapon->SetBusy(false);
		
		if(CanFire(true) && !m_break_reload)
		{
			m_break_reload = true;
			m_pWeapon->RequestCancelReload();
		}
		return false;
	}
	
	bool res = InternalShoot(spawn_ammo, resetAnimation, autoreload, noSound);
	//bool res = CSingle::Shoot(resetAnimation, autoreload, noSound);

	if (m_grenadeLaunchParams.remote_detonated && m_projectileId && m_projectileId != m_lastGrenadeId)
	{
		/*if (m_launchedGrenades.size() >= m_fireparams.clip_size)
			StartSecondaryFire(0);*/

		m_launchedGrenades.push_back(m_projectileId);
		m_lastGrenadeId=m_projectileId;
	}

	if (res)
	{
		m_pWeapon->GetScheduler()->TimerAction(m_grenadeLaunchParams.shoot_delay, CSchedulerAction<CRotateDrumAction>::Create(CRotateDrumAction(this, m_grenadeLaunchParams.shoot_rotate, false)), false);
	}
	
	return res;
}

//------------------------------------------------------------------------
void CGrenadeLaunch::NetShootEx(const Vec3 &pos, const Vec3 &dir, const Vec3 &vel, const Vec3 &hit, float extra, int ph)
{
	IEntityClass* spawn_ammo = m_grenadeLaunchParams.ammo_type_class;

	InternalNetShootEx(spawn_ammo, pos, dir, vel, hit, extra, ph);
	//CSingle::NetShootEx(pos, dir, vel, hit, extra, ph);

	if (m_grenadeLaunchParams.remote_detonated && m_projectileId && m_projectileId != m_lastGrenadeId)
	{
		/*if (m_launchedGrenades.size() >= m_fireparams.clip_size)
			StartSecondaryFire(0);*/

		m_launchedGrenades.push_back(m_projectileId);
		m_lastGrenadeId=m_projectileId;
	}
}
//------------------------------------------------------------------------
void CGrenadeLaunch::StartSecondaryFire(EntityId shooterId)
{
	if (m_grenadeLaunchParams.remote_detonated)
	{
		m_pWeapon->RequestStartSecondaryFire();
	}
}
//------------------------------------------------------------------------
void CGrenadeLaunch::NetStartSecondaryFire()
{
	for(TLaunchedGrenades::const_iterator it=m_launchedGrenades.begin(); it != m_launchedGrenades.end(); ++it)
	{
		IEntity *pGrenade=gEnv->pEntitySystem->GetEntity(*it);
		//IGameObject *pBomb=gEnv->pGame->GetIGameFramework()->GetGameObject(*it);

		if (pGrenade)
		{
			// Trigger grenade explosion
			CProjectile *pGrenadeProjectile=g_pGame->GetWeaponSystem()->GetProjectile(pGrenade->GetId());

			if (pGrenadeProjectile)
			{
				pGrenadeProjectile->Explode(true);
			}
		}
	}

	m_launchedGrenades.resize(0);
}
//------------------------------------------------------------------------
void CGrenadeLaunch::ResetParams(const struct IItemParamsNode *params)
{
	CShotgun::ResetParams(params);

	const IItemParamsNode *grenade_launch = params?params->GetChild("grenade_launch"):0;
	m_grenadeLaunchParams.Reset(grenade_launch);
}

//------------------------------------------------------------------------
void CGrenadeLaunch::PatchParams(const struct IItemParamsNode *patch)
{
	CShotgun::PatchParams(patch);

	const IItemParamsNode *grenade_launch = patch->GetChild("grenade_launch");
	m_grenadeLaunchParams.Reset(grenade_launch, false);
}

//------------------------------------------------------------------------
void CGrenadeLaunch::EnterModify()
{
	m_launchedGrenades.resize(0);

	m_oldAmmo=m_fireparams.ammo_type_class;
}

//------------------------------------------------------------------------
void CGrenadeLaunch::ExitModify()
{
	IEntityClass* new_ammo=m_fireparams.ammo_type_class;
	if (m_oldAmmo && m_oldAmmo != new_ammo)
	{
		ResetShells();
	}
}

//------------------------------------------------------------------------
// Reload shells

void CGrenadeLaunch::ReloadShell(int zoomed)
{
	if(m_reload_was_broken)
		return;

	CActor* pOwner = m_pWeapon->GetOwnerActor();
	bool isAI = pOwner && (pOwner->IsPlayer() == false);
	int ammoCount = m_pWeapon->GetAmmoCount(m_fireparams.ammo_type_class);
	if ((ammoCount < m_fireparams.clip_size) && (m_max_shells>0) &&
		(isAI || (m_pWeapon->GetInventoryAmmoCount(m_fireparams.ammo_type_class) > 0)) ) // AI has unlimited ammo
	{
		m_pWeapon->GetScheduler()->TimerAction(m_grenadeLaunchParams.reload_delay, CSchedulerAction<CRotateDrumAction>::Create(CRotateDrumAction(this, m_grenadeLaunchParams.reload_rotate, true)), false);
		HideReloadShell(NULL, 0);
	}

	CShotgun::ReloadShell(zoomed);
}

void CGrenadeLaunch::RotateDrum(float _time, bool reverse)
{
	// Weapon relative attachments
	ICharacterInstance *pCharacter = m_pWeapon ? m_pWeapon->GetEntity()->GetCharacter(0) : NULL;
	IAttachmentManager *pAttachMan = pCharacter ? pCharacter->GetIAttachmentManager() : NULL;

	if (!pAttachMan || m_magazineDrum < 0)
		return;

	HideReloadShell(pAttachMan, 1);

	IAttachment *pMagazine=pAttachMan->GetInterfaceByIndex(m_magazineDrum);
	if (!pMagazine)
		return;

	int shot_count=m_fireparams.clip_size-GetAmmoCount();
	int shell_idx=shot_count-1;

	QuatT tr=pMagazine->GetAttRelativeDefault();
	tr.q=m_magazineRotation;
	pMagazine->SetAttRelativeDefault(tr);
	m_magazineRotation=reverse ? Quat::CreateRotationY((gf_PI/3)*(shot_count-1)) : Quat::CreateRotationY((gf_PI/3)*shot_count);
	m_magazineRotation.Normalize();
	m_rotateTime=_time/1000.0f;
	m_rotateState=0;

	// Magazine relative attachments
	CItem *pAccessory = m_pWeapon->GetAccessory(m_pWeapon->CurrentAttachment("magazine"));
	pCharacter = pAccessory ? pAccessory->GetEntity()->GetCharacter(0) : NULL;
	pAttachMan = pCharacter ? pCharacter->GetIAttachmentManager() : NULL;
	HideShell(pAttachMan, shell_idx, !reverse);

	m_pWeapon->RequireUpdate(eIUS_FireMode);
}

void CGrenadeLaunch::Update(float frameTime, uint frameId)
{
	CShotgun::Update(frameTime, frameId);

	if (m_rotateTime)
	{
		ICharacterInstance *pCharacter = m_pWeapon ? m_pWeapon->GetEntity()->GetCharacter(0) : NULL;
		IAttachmentManager *pAttachMan = pCharacter ? pCharacter->GetIAttachmentManager() : NULL;

		if (!pAttachMan || m_magazineDrum < 0)
			return;

		IAttachment *pMagazine=pAttachMan->GetInterfaceByIndex(m_magazineDrum);
		if (!pMagazine)
			return;

		m_rotateState+=frameTime;
		float ratio=m_rotateState/m_rotateTime;
		QuatT tr=pMagazine->GetAttRelativeDefault();
		Quat rot;

		//gEnv->pLog->Log(">>> Rotate ratio: %f", ratio);

		rot=Quat::CreateSlerp(tr.q, m_magazineRotation, min(ratio, 1.0f));
		tr.q=rot;
		pMagazine->SetAttRelativeDefault(tr);

		if (ratio >= 1)
		{
			m_rotateTime=0;

			Quat rot;
			tr.q=m_magazineRotation;
			pMagazine->SetAttRelativeDefault(tr);
		}
		else
		{
			Quat rot;
			rot=Quat::CreateSlerp(tr.q, m_magazineRotation, min(ratio, 1.0f));
			tr.q=rot;
			pMagazine->SetAttRelativeDefault(tr);

			m_pWeapon->RequireUpdate(eIUS_FireMode);
		}
	}
}

void CGrenadeLaunch::ResetShells()
{
	int shot_count=m_fireparams.clip_size-GetAmmoCount();

	// Weapon relative attachments
	ICharacterInstance *pCharacter = m_pWeapon ? m_pWeapon->GetEntity()->GetCharacter(0) : NULL;
	if (pCharacter) 
	{
		IAttachmentManager* pAttachMan = pCharacter->GetIAttachmentManager();
		// gEnv->pLog->Log(">>> Resetting shells at shot count: %d", shot_count);

		if (m_magazineDrum >= 0)
		{
			IAttachment *pMagazine=pAttachMan->GetInterfaceByIndex(m_magazineDrum);
			if (pMagazine)
			{
				m_rotateTime=0;
				QuatT tr=pMagazine->GetAttRelativeDefault();
				m_magazineRotation=Quat::CreateRotationY((gf_PI/3)*shot_count);
				tr.q=m_magazineRotation;
				pMagazine->SetAttRelativeDefault(tr);
			}
		}

		HideReloadShell(pAttachMan, 1);
	}

	// Magazine relative attachments
	CItem *pAccessory = m_pWeapon->GetAccessory(m_pWeapon->CurrentAttachment("magazine"));
	pCharacter = pAccessory ? pAccessory->GetEntity()->GetCharacter(0) : NULL;

	if (pCharacter) 
	{
		IAttachmentManager* pAttachMan = pCharacter->GetIAttachmentManager();

		// Request shell attachments and show/hide them according to ammo count
		m_grenadeShells.resize(0);

		for (int i=0; i<m_fireparams.clip_size; i++)
		{
			char attName[128];
			_snprintf(attName, sizeof(attName), "grenade_%d", i+1);
			attName[sizeof(attName)-1] = 0;

			int32 gidx=pAttachMan->GetIndexByName(attName);

			if (gidx > -1)
			{
				m_grenadeShells.push_back(gidx);
				HideShell(pAttachMan, i, i<shot_count);
			}
		}
	}
}

void CGrenadeLaunch::Serialize(TSerialize ser)
{
	CShotgun::Serialize(ser);

	if(ser.GetSerializationTarget() != eST_Network)
	{
		ser.BeginGroup("launchmode");
		ser.Value("launchedgrenades", m_launchedGrenades);
		ser.EndGroup();
	}
}

void CGrenadeLaunch::PostSerialize()
{
	CShotgun::PostSerialize();
}

void CGrenadeLaunch::HideReloadShell(IAttachmentManager* pAttachMan, uint32 hide)
{
	if (!pAttachMan)
	{
		ICharacterInstance *pCharacter = m_pWeapon ? m_pWeapon->GetEntity()->GetCharacter(0) : NULL;
		pAttachMan = pCharacter ? pCharacter->GetIAttachmentManager() : NULL;
	}

	if (!pAttachMan)
		return;

	if (m_reloadShell < 0)
		return;

	IAttachment *pAtt=pAttachMan->GetInterfaceByIndex(m_reloadShell);
	if (pAtt)
		pAtt->HideAttachment(hide);
}

void CGrenadeLaunch::HideShell(IAttachmentManager* pAttachMan, int idx, uint32 hide)
{
	if (!pAttachMan || idx < 0 || idx >= m_grenadeShells.size() || m_grenadeShells[idx] < 0)
		return;

	IAttachment *pAtt=pAttachMan->GetInterfaceByIndex(m_grenadeShells[idx]);
	if (pAtt)
		pAtt->HideAttachment(hide);
}
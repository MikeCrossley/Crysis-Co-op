/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: Special firemode for FGL40 grenade launcher

-------------------------------------------------------------------------
History:
- 10:10:2007   8:00 : Created by Denisz Polgár

*************************************************************************/
#ifndef __GRENADE_LAUNCH_H__
#define __GRENADE_LAUNCH_H__

#if _MSC_VER > 1000
# pragma once
#endif


class CGrenadeLaunch :
	public CShotgun
{
	class ScheduleReload;
	class CRotateDrumAction;
public:

protected:
	typedef struct SGrenadeLaunchParams
	{
		SGrenadeLaunchParams() { Reset(); };
		void Reset(const IItemParamsNode *params=0, bool defaultInit=true)
		{
			CItemParamReader reader(params);
			string ammo_type;
			ResetValue(ammo_type, "");
			if (defaultInit || !ammo_type.empty())
				ammo_type_class = gEnv->pEntitySystem->GetClassRegistry()->FindClass(ammo_type.c_str());

			ResetValue(remote_detonated, false);
			ResetValue(shoot_rotate, 280.0f);
			ResetValue(reload_rotate, 360.0f);

			ResetValue(shoot_delay, 240.0f);
			ResetValue(reload_delay, 720.0f);
		}

		IEntityClass* ammo_type_class;
		bool remote_detonated;
		float shoot_rotate;
		float reload_rotate;

		float shoot_delay;
    float reload_delay;

	} SGrenadeLaunchParams;

public:
	CGrenadeLaunch();
	virtual ~CGrenadeLaunch();

	virtual void Activate(bool activate);
	virtual void Reload(int zoomed);
	virtual void EndReload(int zoomed);

	virtual bool Shoot(bool resetAnimation, bool autoreload = true , bool noSound = false );
	virtual void NetShootEx(const Vec3 &pos, const Vec3 &dir, const Vec3 &vel, const Vec3 &hit, float extra, int ph);

	virtual void StartSecondaryFire(EntityId shooterId);
	virtual void NetStartSecondaryFire();

	virtual void ResetParams(const struct IItemParamsNode *params);
	virtual void PatchParams(const struct IItemParamsNode *patch);

	virtual void EnterModify();
	virtual void ExitModify();

	virtual const char *GetType() const { return "GrenadeLaunch"; }

	virtual void ReloadShell(int zoomed);
	virtual void Update(float frameTime, uint frameId);

	void RotateDrum(float _time, bool reverse);

	virtual void Serialize(TSerialize ser);
	virtual void PostSerialize();
	
protected:
	void ResetShells();

	void HideReloadShell(IAttachmentManager* pAttachMan, uint32 hide);
	void HideShell(IAttachmentManager* pAttachMan, int idx, uint32 hide);

	SGrenadeLaunchParams m_grenadeLaunchParams;
	IEntityClass* m_oldAmmo;

	typedef std::vector <EntityId> TLaunchedGrenades;
	typedef std::vector <int32> TGrenadeShells;

	TLaunchedGrenades m_launchedGrenades;
	EntityId m_lastGrenadeId;

	TGrenadeShells m_grenadeShells;
	int32 m_magazineDrum;
	int32 m_reloadShell;
	Quat m_magazineRotation;
	float m_rotateTime;
	float m_rotateState;
private:

	
};


#endif //__GRENADE_LAUNCH_H__

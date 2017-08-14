/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id:$
$DateTime$
Description:  Grenade implementation for grenade launcher - remote
							detonated grenades only!
-------------------------------------------------------------------------
History:
- 28:4:2008   10:07 : Created by Steve Humphreys

*************************************************************************/

#include "StdAfx.h"
#include "RemoteGrenade.h"

#include "Item.h"
#include "Player.h"

//------------------------------------------------------------------------
CRemoteGrenade::CRemoteGrenade()
{
}

//------------------------------------------------------------------------
CRemoteGrenade::~CRemoteGrenade()
{
	if(gEnv->bMultiplayer && gEnv->bServer)
	{
		IActor *pOwner = g_pGame->GetIGameFramework()->GetIActorSystem()->GetActor(m_ownerId);
		if(pOwner && pOwner->IsPlayer())
		{
			((CPlayer*)pOwner)->RecordExplosiveDestroyed(GetEntityId(), eET_LaunchedGrenade);
		}
	}

// 	if(g_pGame->GetHUD())
// 		g_pGame->GetHUD()->RecordExplosiveDestroyed(GetEntityId());
}

//------------------------------------------------------------------------
bool CRemoteGrenade::Init(IGameObject *pGameObject)
{
	bool ok = CProjectile::Init(pGameObject);

// 	if(g_pGame->GetHUD())
// 		g_pGame->GetHUD()->RecordExplosivePlaced(GetEntityId());

	return ok;
}

//------------------------------------------------------------------------

void CRemoteGrenade::Launch(const Vec3 &pos, const Vec3 &dir, const Vec3 &velocity, float speedScale)
{
	CProjectile::Launch(pos, dir, velocity, speedScale);

	if(gEnv->bMultiplayer && gEnv->bServer)
	{
		CActor* pOwner = GetWeapon()->GetOwnerActor();
		if(pOwner && pOwner->IsPlayer())
		{
			((CPlayer*)pOwner)->RecordExplosivePlaced(GetEntityId(), eET_LaunchedGrenade);
		}
	}
}

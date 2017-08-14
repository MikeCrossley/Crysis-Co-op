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
- 28:4:2008   10:09 : Created by Steve Humphreys

*************************************************************************/

#ifndef __REMOTEGRENADE_H__
#define __REMOTEGRENADE_H__

#if _MSC_VER > 1000
# pragma once
#endif


#include "Projectile.h"

class CRemoteGrenade : public CProjectile
{
public:
	CRemoteGrenade();
	virtual ~CRemoteGrenade();

	virtual bool Init(IGameObject *pGameObject);

	virtual void Launch(const Vec3 &pos, const Vec3 &dir, const Vec3 &velocity, float speedScale);
};


#endif // __REMOTEGRENADE_H__
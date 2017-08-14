#include "Projectile.h"
#pragma once

class CTagBullet :
	public CProjectile
{
public:
	CTagBullet(void);
	~CTagBullet(void);
	virtual void HandleEvent(const SGameObjectEvent &);
};

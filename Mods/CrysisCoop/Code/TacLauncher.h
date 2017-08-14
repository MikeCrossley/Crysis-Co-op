/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2008.
-------------------------------------------------------------------------
$Id:$
$DateTime$
Description:  Class for specific tac launcher functionality. 
							Based on CRocketLauncher
-------------------------------------------------------------------------
History:
- 08:06:2008: Created by Steve Humphreys

*************************************************************************/

#ifndef __TACLAUNCHER_H__
#define __TACLAUNCHER_H__

#if _MSC_VER > 1000
# pragma once
#endif
	

#include "Weapon.h"

class CTacLauncher : public CWeapon
{
public:
	CTacLauncher();
	virtual ~CTacLauncher() {};

	virtual void OnReset();
	virtual void Drop(float impulseScale, bool selectNext/* =true */, bool byDeath/* =false */);

	virtual bool CanPickUp(EntityId userId) const;

	virtual void FullSerialize( TSerialize ser );
	virtual void PostSerialize();

	virtual void AutoDrop();

private:
	int   m_smokeEffectSlot;
};


#endif // __TACLAUNCHER_H__
/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: TeamInstantAction specific HUD object

-------------------------------------------------------------------------
History:
- 03/18/2008: Created by Jan Neugebauer

*************************************************************************/

#ifndef HUD_INSTANTACTION_H
#define HUD_INSTANTACTION_H

# pragma once


#include "HUDObject.h"

#include "HUD.h"

class CGameFlashAnimation;

class CHUDInstantAction : public CHUDObject
{
	friend class CHUD;
public:

	CHUDInstantAction(CHUD *pHUD);
	~CHUDInstantAction();

	void Update(float fDeltaTime);
	void Reset();
	void Show(bool show);
	void SetHUDColor();
	void UpdateStats();

//	virtual bool IsFactoryType(EntityId entity, EBuyMenuPage type);

//	bool IsPlayerSpecial();

	int m_ownScore;

private:

	void PushToFlash();
	CGameFlashAnimation m_animIAScore;
	CHUD *g_pHUD;

	int m_roundTime;

};

#endif

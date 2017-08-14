/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: PowerStruggle mode HUD code (refactored from old HUD code)

-------------------------------------------------------------------------
History:
- 21:02:20067  20:00 : Created by Jan Müller

*************************************************************************/

#include "StdAfx.h"
#include "HUDInstantAction.h"

#include "HUD.h"
#include "GameFlashAnimation.h"
#include "../Game.h"
#include "../GameCVars.h"
#include "../GameRules.h"

CHUDInstantAction::CHUDInstantAction(CHUD *pHUD) : 
g_pHUD(pHUD)
{
	m_animIAScore.Load("Libs/UI/HUD_IAScore.gfx", eFD_Center, eFAF_ManualRender|eFAF_Visible);
	m_animIAScore.SetVisible(false);
}

CHUDInstantAction::~CHUDInstantAction()
{
	m_animIAScore.Unload();
}

void CHUDInstantAction::Reset()
{
	m_ownScore = 0;
	m_roundTime = 0;
}

void CHUDInstantAction::SetHUDColor()
{
	g_pHUD->SetFlashColor(&m_animIAScore);
}

void CHUDInstantAction::UpdateStats()
{

	CGameRules *pGameRules=g_pGame->GetGameRules();
	if(!pGameRules)
		return;

	IActor *pClientActor=g_pGame->GetIGameFramework()->GetClientActor();
	if(!pClientActor)
		return;

	IScriptTable *pGameRulesScript=pGameRules->GetEntity()->GetScriptTable();
	if(!pGameRulesScript)
		return;

	int ownScore = 0;
	int roundTime = 0;

	HSCRIPTFUNCTION pfnGetScoreFlags=0;
	if (pGameRulesScript->GetValue("GetPlayerScore", pfnGetScoreFlags))
	{
		ScriptHandle actorId(pClientActor->GetEntityId());
		Script::CallReturn(gEnv->pScriptSystem, pfnGetScoreFlags, pGameRulesScript, actorId, ownScore);
		gEnv->pScriptSystem->ReleaseFunc(pfnGetScoreFlags);
	}

	roundTime = floor(pGameRules->GetRemainingGameTime());

	if(	ownScore!=m_ownScore ||
			roundTime!=m_roundTime)
	{
		m_ownScore = ownScore;
		m_roundTime = roundTime;
		PushToFlash();
	}

}

void CHUDInstantAction::Show(bool show)
{
	m_animIAScore.SetVisible(show);
}

void CHUDInstantAction::PushToFlash()
{
	SFlashVarValue args[1] = {m_roundTime};
	m_animIAScore.Invoke("setValues", args, 1);
}

void CHUDInstantAction::Update(float fDeltaTime)
{
	if(!m_animIAScore.IsLoaded() || !m_animIAScore.GetVisible())
		return;

	UpdateStats();

	m_animIAScore.GetFlashPlayer()->Advance(fDeltaTime);
	m_animIAScore.GetFlashPlayer()->Render();
}
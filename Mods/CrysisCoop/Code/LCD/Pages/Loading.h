/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
Description: 	Game Logo

-------------------------------------------------------------------------
History:
- 01:11:2007: Created by Marco Koegler

*************************************************************************/
#ifndef __LOADING_H__
#define __LOADING_H__

#ifdef USE_G15_LCD
#include "../LCDPage.h"
#include <ILevelSystem.h>
#include <Game.h>
#include <GameRules.h>

class CLoading : public CLCDPage, public ILevelSystemListener
{
public:
	CLoading() 
	{
		g_pGame->GetIGameFramework()->GetILevelSystem()->AddListener(this);
	}

	virtual ~CLoading()
	{
		g_pGame->GetIGameFramework()->GetILevelSystem()->RemoveListener(this);
	}

	//ILevelSystemListener
	virtual void OnLevelNotFound(const char *levelName){}
	virtual void OnLoadingStart(ILevelInfo *pLevel)
	{
		if (pLevel)
		{
			MakeModifyTarget();
			UpdateGameMode();
			const char* mappedName = g_pGame->GetMappedLevelName(pLevel->GetName());

			if(gEnv->bMultiplayer)
			{
				mappedName = pLevel->GetDisplayName();
			}

			GetEzLcd()->SetText(m_mapText, mappedName);

			GetEzLcd()->SetProgressBarPosition(m_progressBar, 0.0f);
			GetG15LCD()->SetCurrentPage(GetPageId());
			GetG15LCD()->ShowCurrentPage();
			GetEzLcd()->Update();
		}
	}
	virtual void OnLoadingComplete(ILevel *pLevel)
	{
		GetG15LCD()->SetCurrentPage(GetG15LCD()->PlayerStatusPage);
	}
	virtual void OnLoadingError(ILevelInfo *pLevel, const char *error){}
	virtual void OnLoadingProgress(ILevelInfo *pLevel, int progressAmount)
	{
		if (pLevel)
		{
			MakeModifyTarget();
			GetEzLcd()->SetProgressBarPosition(m_progressBar, progressAmount/float(pLevel->GetDefaultGameType()->cgfCount)*100.0f);
			GetEzLcd()->Update();
		}
	}
	//~ILevelSystemListener

protected:
	virtual void OnAttach()
	{
		int verticalAlign = 30;
		m_serverNameLabel = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, verticalAlign);
		GetEzLcd()->SetOrigin(m_serverNameLabel, 0, 0);
		GetEzLcd()->SetText(m_serverNameLabel, "Server:");
		m_serverNameText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160 - verticalAlign);
		GetEzLcd()->SetOrigin(m_serverNameText, verticalAlign, 0);

		m_IPLabel = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, verticalAlign);
		GetEzLcd()->SetOrigin(m_IPLabel, 0, 10);
		GetEzLcd()->SetText(m_IPLabel, "IP:");
		m_IPText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160 - verticalAlign);
		GetEzLcd()->SetOrigin(m_IPText, verticalAlign, 10);

		m_gameTypeLabel = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, verticalAlign);
		GetEzLcd()->SetOrigin(m_gameTypeLabel, 0, 20);
		GetEzLcd()->SetText(m_gameTypeLabel, "Type:");
		m_gameTypeText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160 - verticalAlign);
		GetEzLcd()->SetOrigin(m_gameTypeText, verticalAlign, 20);

		m_mapLabel = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, verticalAlign);
		GetEzLcd()->SetOrigin(m_mapLabel, 0, 30);
		GetEzLcd()->SetText(m_mapLabel, "Map:");
		m_mapText = GetEzLcd()->AddText(LG_SCROLLING_TEXT, LG_SMALL, DT_LEFT, 160 - verticalAlign);
		GetEzLcd()->SetOrigin(m_mapText, verticalAlign, 30);

		m_progressBar = GetEzLcd()->AddProgressBar(LG_FILLED);
		GetEzLcd()->SetProgressBarSize(m_progressBar, 120, 3);
		GetEzLcd()->SetOrigin(m_progressBar, 20, 40);
		GetEzLcd()->SetProgressBarPosition(m_progressBar, 0.0f);
	}
private:
	void UpdateGameMode()
	{
		CGameRules* pGameRules = g_pGame->GetGameRules();
		if(!pGameRules)
			return;

		GetEzLcd()->SetVisible(m_serverNameLabel, gEnv->bMultiplayer);
		GetEzLcd()->SetVisible(m_serverNameText, gEnv->bMultiplayer);
		GetEzLcd()->SetVisible(m_IPLabel, gEnv->bMultiplayer);
		GetEzLcd()->SetVisible(m_IPText, gEnv->bMultiplayer);
		GetEzLcd()->SetVisible(m_gameTypeLabel, gEnv->bMultiplayer);
		GetEzLcd()->SetVisible(m_gameTypeText, gEnv->bMultiplayer);

		if (gEnv->bMultiplayer)
		{
			static string svr_name;
			static string svr_ip;

			g_pGame->GetGameRules()->GetSynchedGlobalValue(GLOBAL_SERVER_NAME_KEY, svr_name);
			g_pGame->GetGameRules()->GetSynchedGlobalValue(GLOBAL_SERVER_IP_KEY, svr_ip);

			GetEzLcd()->SetText(m_serverNameText, svr_name.c_str());
			GetEzLcd()->SetText(m_IPText, svr_ip.c_str());
			GetEzLcd()->SetText(m_gameTypeText, pGameRules->GetEntity()->GetClass()->GetName());
		}
	}
	HANDLE	m_serverNameLabel;
	HANDLE	m_serverNameText;
	HANDLE	m_IPLabel;
	HANDLE	m_IPText;
	HANDLE	m_gameTypeLabel;
	HANDLE	m_gameTypeText;
	HANDLE	m_mapLabel;
	HANDLE	m_mapText;
	HANDLE	m_progressBar;
};

#endif //USE_G15_LCD

#endif
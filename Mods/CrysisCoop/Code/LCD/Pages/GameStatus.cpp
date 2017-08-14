/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
*************************************************************************/
#include "StdAfx.h"
#include "resource.h"
#include "GameStatus.h"
#include "../../HUD/HUD.h"
#include "../../HUD/HUDScore.h"
#include "../../Weapon.h"
#include "../LCDImage.h"
#include <GameRules.h>
#include <GameCVars.h>

#ifdef USE_G15_LCD

bool CGameStatus::SScore::operator<(const SScore& entry) const
{
	if(entry.kills > kills)
		return false;
	else if(kills > entry.kills)
		return true;
	else
	{
		if(deaths < entry.deaths)
			return true;
		else if (deaths > entry.deaths)
			return false;
		else
		{
			IEntity *pEntity0=pActor->GetEntity();
			IEntity *pEntity1=entry.pActor->GetEntity();

			const char *name0=pEntity0?pEntity0->GetName():"";
			const char *name1=pEntity1?pEntity1->GetName():"";

			if (strcmp(name0, name1)<0)
				return true;
			else
				return false;
		}
	}
	return true;
}

CGameStatus::CGameStatus()
{
}

CGameStatus::~CGameStatus()
{
}

bool	CGameStatus::PreUpdate()
{
	if (GetEzLcd()->ButtonIsPressed(LG_BUTTON_1))
	{
		GetG15LCD()->SetCurrentPage(GetG15LCD()->PlayerStatusPage);
		return false;
	}
	return CLCDPage::PreUpdate();
}

void CGameStatus::Update(float frameTime)
{
	MakeModifyTarget();
	UpdateGameMode();
}

void CGameStatus::OnAttach()
{
	m_IPText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160);
	GetEzLcd()->SetOrigin(m_IPText, 0, 0);

	m_timeText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160);
	GetEzLcd()->SetOrigin(m_timeText, 0, 10);

	m_objectiveText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 80);
	GetEzLcd()->SetOrigin(m_objectiveText, 0, 0);
	GetEzLcd()->SetText(m_objectiveText, "Objectives");

	for(int i = 0; i < MAX_OBJECTIVE; ++i)
	{
		m_objectives[i] = GetEzLcd()->AddText(LG_SCROLLING_TEXT, LG_SMALL, DT_LEFT, 150);
		GetEzLcd()->SetOrigin(m_objectives[i], 10, (i+1) * 9);
		m_objectiveIcons[i] = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_OBJECTIVE), false);
		m_objectiveIcons[i]->SetOrigin(2, (i+1) * 9);
	}

	for(int i = 0; i < MAX_SCORES; ++i)
	{
		m_scoreRanks[i] = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_RIGHT, 10);
		GetEzLcd()->SetOrigin(m_scoreRanks[i], 0, (i+3)*9 - 1);
		m_scoreNames[i] = GetEzLcd()->AddText(LG_SCROLLING_TEXT, LG_SMALL, DT_CENTER, 95);
		GetEzLcd()->SetOrigin(m_scoreNames[i], 15, (i+3)*9 - 1);
		m_scoreScores[i] = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_CENTER, 45);
		GetEzLcd()->SetOrigin(m_scoreScores[i], 115, (i+3)*9 - 1);
	}

	m_ppPrestige = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 80);
	GetEzLcd()->SetOrigin(m_ppPrestige, 0, 20);
	m_ppMSP = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 80);
	GetEzLcd()->SetOrigin(m_ppMSP, 80, 20);
	m_ppRank = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 80);
	GetEzLcd()->SetOrigin(m_ppRank, 0, 30);
	m_ppNextRank = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 80);
	GetEzLcd()->SetOrigin(m_ppNextRank, 80, 30);
	m_ppProgress = GetEzLcd()->AddProgressBar(LG_FILLED);
	GetEzLcd()->SetProgressBarSize(m_ppProgress, 120, 3);
	GetEzLcd()->SetOrigin(m_ppProgress, 20, 40);
	GetEzLcd()->SetProgressBarPosition(m_ppProgress, 0.0f);

	m_teamUS = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160);
	GetEzLcd()->SetOrigin(m_teamUS, 0, 26);
	m_teamNK = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 160);
	GetEzLcd()->SetOrigin(m_teamNK, 0, 35);

	m_TIAScore = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 40);
	GetEzLcd()->SetOrigin(m_TIAScore, 0, 14);
	m_TIAKills = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 40);
	GetEzLcd()->SetOrigin(m_TIAKills, 45, 14);
	m_TIADeaths = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 40);
	GetEzLcd()->SetOrigin(m_TIADeaths, 80, 14);
	m_TIATeamKills = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_LEFT, 40);
	GetEzLcd()->SetOrigin(m_TIATeamKills, 115, 14);


	m_teamUSScore = GetEzLcd()->AddProgressBar(LG_FILLED);
	GetEzLcd()->SetProgressBarSize(m_teamUSScore, 110, 7);
	GetEzLcd()->SetOrigin(m_teamUSScore, 40, 26);
	GetEzLcd()->SetProgressBarPosition(m_teamUSScore, 0.0f);
	m_teamNKScore = GetEzLcd()->AddProgressBar(LG_FILLED);
	GetEzLcd()->SetProgressBarSize(m_teamNKScore, 110, 5);
	GetEzLcd()->SetOrigin(m_teamNKScore, 40, 36);
	GetEzLcd()->SetProgressBarPosition(m_teamNKScore, 0.0f);
}

void CGameStatus::UpdateGameMode()
{
	if (!g_pGame)
		return;

	m_pClientActor = g_pGame->GetIGameFramework()->GetClientActor();
	if (!m_pClientActor || !g_pGame->GetHUD())
		return;

	m_pLocalizationMan = gEnv->pSystem->GetLocalizationManager();
	if(!m_pLocalizationMan)
		return;

	m_pGameRules=g_pGame->GetGameRules();
	if(!m_pGameRules)
		return;

	m_pGameRulesScript = m_pGameRules->GetEntity()->GetScriptTable();
	if(!m_pGameRulesScript)
		return;

	EHUDGAMERULES hudGameRules = g_pGame->GetHUD()->GetCurrentGameRules();

	GetEzLcd()->SetVisible(m_IPText, hudGameRules != EHUD_SINGLEPLAYER);
	GetEzLcd()->SetVisible(m_objectiveText, hudGameRules == EHUD_SINGLEPLAYER);
	GetEzLcd()->SetVisible(m_ppProgress, false);
	GetEzLcd()->SetVisible(m_ppMSP, false);
	GetEzLcd()->SetVisible(m_ppPrestige, false);
	GetEzLcd()->SetVisible(m_ppRank, false);
	GetEzLcd()->SetVisible(m_ppNextRank, false);
	GetEzLcd()->SetVisible(m_timeText, false);
	GetEzLcd()->SetVisible(m_teamUS, false);
	GetEzLcd()->SetVisible(m_teamNK, false);
	GetEzLcd()->SetVisible(m_teamUSScore, false);
	GetEzLcd()->SetVisible(m_teamNKScore, false);
	GetEzLcd()->SetVisible(m_TIAScore, false);
	GetEzLcd()->SetVisible(m_TIAKills, false);
	GetEzLcd()->SetVisible(m_TIADeaths, false);
	GetEzLcd()->SetVisible(m_TIATeamKills, false);



	// always hide all objectives (they will get unhidden in UpdateSingleplayer
	for(int i = 0; i < MAX_OBJECTIVE; ++i)
	{
		GetEzLcd()->SetVisible(m_objectives[i], false);
		m_objectiveIcons[i]->SetVisible(false);
	}
	for(int i = 0; i < MAX_SCORES; ++i)
	{
		GetEzLcd()->SetVisible(m_scoreRanks[i], false);
		GetEzLcd()->SetVisible(m_scoreNames[i], false);
		GetEzLcd()->SetVisible(m_scoreScores[i], false);
	}

	switch(hudGameRules)
	{
	case EHUD_SINGLEPLAYER:
		UpdateSingleplayer();
		break;
	case EHUD_POWERSTRUGGLE:
		UpdateServerAndIP();
		UpdateTime();
		UpdatePowerStruggle();
		break;
	case EHUD_INSTANTACTION:
		UpdateServerAndIP();
		UpdateTime();
		UpdateInstantAction();
		break;
	case EHUD_TEAMINSTANTACTION:
		UpdateServerAndIP();
		//UpdateTime();
		UpdateTeamInstantAction();
		break;
	}
}

void CGameStatus::UpdateSingleplayer()
{
	string temp;
	ILocalizationManager* pLocalizationMan = gEnv->pSystem->GetLocalizationManager();

	const CHUD::THUDObjectiveList& hudObjectives = g_pGame->GetHUD()->GetHUDObjectiveList();
	CHUD::THUDObjectiveList::const_iterator it = hudObjectives.begin();
	CHUD::THUDObjectiveList::const_iterator end = hudObjectives.end();

	int currentObjective = 0;

	char buffer[128];
	for(; (currentObjective < MAX_OBJECTIVE) && (it != end); ++it)
	{
		CHUD::SHudObjective objective = it->second;
		if (objective.status == 1 || objective.status == 2)
		{
			GetEzLcd()->SetVisible(m_objectives[currentObjective], true);
			m_objectiveIcons[currentObjective]->SetVisible(true);
			pLocalizationMan->GetEnglishString(objective.description, temp);
			_snprintf(buffer, 128, "%s", temp.c_str());
			GetEzLcd()->SetText(m_objectives[currentObjective], buffer);
			++currentObjective;
		}
	}
}

void CGameStatus::UpdateServerAndIP()
{
	//static string name;
	static string ip;

	//m_pGameRules->GetSynchedGlobalValue(GLOBAL_SERVER_NAME_KEY, name);
	m_pGameRules->GetSynchedGlobalValue(GLOBAL_SERVER_IP_KEY, ip);

	char buffer[128];
	_snprintf(buffer, 128, "IP: %s", ip.c_str());
	GetEzLcd()->SetText(m_IPText, buffer);
}

void CGameStatus::UpdateTime()
{
	IEntityScriptProxy *pScriptProxy = static_cast<IEntityScriptProxy*>(m_pGameRules->GetEntity()->GetProxy(ENTITY_PROXY_SCRIPT));
	if (pScriptProxy)
	{
		char buffer[128];
		if (!stricmp(pScriptProxy->GetState(), "InGame") && m_pGameRules->IsTimeLimited())
		{
			int time = (int)(m_pGameRules->GetRemainingGameTime());

			int minutes=time/60;
			int seconds=time-(minutes*60);
			CryFixedStringT<64> msg;
			_snprintf(buffer, 128, "Remaining: %02d:%02d", minutes, seconds);
		}
		else
		{
			_snprintf(buffer, 128, "Remaining: N/A");
		}
		GetEzLcd()->SetVisible(m_timeText, true);
		GetEzLcd()->SetText(m_timeText, buffer);
	}
}

void CGameStatus::UpdateInstantAction()
{
	static int SCORE_KILLS_KEY = 0;
	if (!SCORE_KILLS_KEY)
		m_pGameRulesScript->GetValue("SCORE_KILLS_KEY", SCORE_KILLS_KEY);
	static int SCORE_DEATHS_KEY = 0;
	if (!SCORE_DEATHS_KEY)
		m_pGameRulesScript->GetValue("SCORE_DEATHS_KEY", SCORE_DEATHS_KEY);

	for(int i = 0; i < MAX_SCORES; ++i)
	{
		GetEzLcd()->SetVisible(m_scoreRanks[i], true);
		GetEzLcd()->SetVisible(m_scoreNames[i], true);
		GetEzLcd()->SetVisible(m_scoreScores[i], true);
	}


	m_scores.clear();

	IActorIteratorPtr it = g_pGame->GetIGameFramework()->GetIActorSystem()->CreateActorIterator();
	while (CActor* pActor = static_cast<CActor*>(it->Next()))
	{
		if (!pActor->IsPlayer())
			continue;

		if(pActor->GetSpectatorMode() && !g_pGame->GetGameRules()->IsPlayerActivelyPlaying(pActor->GetEntityId()))
			continue;

		int kills = 0;
		m_pGameRules->GetSynchedEntityValue(pActor->GetEntityId(), TSynchedKey(SCORE_KILLS_KEY), kills);
		int deaths = 0;
		m_pGameRules->GetSynchedEntityValue(pActor->GetEntityId(), TSynchedKey(SCORE_DEATHS_KEY), deaths);
		m_scores.push_back(SScore(pActor, kills, deaths));
	}

	std::sort(m_scores.begin(), m_scores.end());

	// find client
	std::vector<SScore>::const_iterator iter = m_scores.begin();
	std::vector<SScore>::const_iterator end = m_scores.end();

	bool hasClient = false;
	int clientRank = 1;
	for (; (iter != end) && !hasClient; ++iter)
	{
		if (iter->pActor == m_pClientActor)
		{
			hasClient = true;
		}
		else
		{
			clientRank++;
		}
	}

	if (m_scores.size() == 0)
	{
		SetScore(0, -1, "", 0);
		SetScore(1, -1, "", 0);
	}
	else if (m_scores.size() == 1)
	{
		SetScore(0, 1, m_scores[0].pActor->GetEntity()->GetName(), m_scores[0].kills);
		SetScore(1, -1, "", 0);
	}
	else
	{
		if (!hasClient)
		{
			SetScore(0, 1, m_scores[0].pActor->GetEntity()->GetName(), m_scores[0].kills);
			SetScore(1, 2, m_scores[1].pActor->GetEntity()->GetName(), m_scores[1].kills);
		}
		else
		{
			if (clientRank == 1)
			{
				SetScore(0, 1, m_scores[0].pActor->GetEntity()->GetName(), m_scores[0].kills);
				SetScore(1, 2, m_scores[1].pActor->GetEntity()->GetName(), m_scores[1].kills);
			}
			else
			{
				SetScore(0, clientRank-1, m_scores[clientRank-2].pActor->GetEntity()->GetName(), m_scores[clientRank-2].kills);
				SetScore(1, clientRank, m_scores[clientRank-1].pActor->GetEntity()->GetName(), m_scores[clientRank-1].kills);
			}
		}
	}
}

void CGameStatus::UpdateTeamInstantAction()
{
	static int SCORE_US_KEY = 0;
	if (!SCORE_US_KEY)
		m_pGameRulesScript->GetValue("TEAMSCORE_TEAM2_KEY", SCORE_US_KEY);
	static int SCORE_NK_KEY = 0;
	if (!SCORE_NK_KEY)
		m_pGameRulesScript->GetValue("TEAMSCORE_TEAM1_KEY", SCORE_NK_KEY);

	int scoreUS;
	m_pGameRules->GetSynchedGlobalValue(TSynchedKey(SCORE_US_KEY), scoreUS);
	int scoreNK;
	m_pGameRules->GetSynchedGlobalValue(TSynchedKey(SCORE_NK_KEY), scoreNK);

	int clientteam = m_pGameRules->GetTeam(m_pClientActor->GetEntityId());

	char buffer[128];

	if (m_pGameRules->IsPlayerActivelyPlaying(m_pClientActor->GetEntityId()))
	{

		int score;
		int kills;
		int deaths;
		int teamkills;

		HSCRIPTFUNCTION pfnGetScoreFlags=0;
		if (m_pGameRulesScript->GetValue("GetPlayerScore", pfnGetScoreFlags))
		{
			ScriptHandle actorId(m_pClientActor->GetEntityId());
			Script::CallReturn(gEnv->pScriptSystem, pfnGetScoreFlags, m_pGameRulesScript, actorId, score);
			gEnv->pScriptSystem->ReleaseFunc(pfnGetScoreFlags);
		}

		static int PLAYER_KILLS_KEY = 0;
		if (!PLAYER_KILLS_KEY)
			m_pGameRulesScript->GetValue("SCORE_KILLS_KEY", PLAYER_KILLS_KEY);
		m_pGameRules->GetSynchedEntityValue(m_pClientActor->GetEntityId(), TSynchedKey(PLAYER_KILLS_KEY), kills);

		static int PLAYER_DEATHS_KEY = 0;
		if (!PLAYER_DEATHS_KEY)
			m_pGameRulesScript->GetValue("SCORE_DEATHS_KEY", PLAYER_DEATHS_KEY);
		m_pGameRules->GetSynchedEntityValue(m_pClientActor->GetEntityId(), TSynchedKey(PLAYER_DEATHS_KEY), deaths);

		static int PLAYER_TEAMKILLS_KEY = 0;
		if (!PLAYER_TEAMKILLS_KEY)
			m_pGameRulesScript->GetValue("SCORE_TEAMKILLS_KEY", PLAYER_TEAMKILLS_KEY);
		m_pGameRules->GetSynchedEntityValue(m_pClientActor->GetEntityId(), TSynchedKey(PLAYER_TEAMKILLS_KEY), teamkills);

		GetEzLcd()->SetVisible(m_TIAScore, true);
		_snprintf(buffer, 128, "SC: %d", score);
		GetEzLcd()->SetText(m_TIAScore, buffer);

		GetEzLcd()->SetVisible(m_TIAKills, true);
		_snprintf(buffer, 128, "KI: %d", kills);
		GetEzLcd()->SetText(m_TIAKills, buffer);

		GetEzLcd()->SetVisible(m_TIADeaths, true);
		_snprintf(buffer, 128, "DE: %d", deaths);
		GetEzLcd()->SetText(m_TIADeaths, buffer);

		GetEzLcd()->SetVisible(m_TIATeamKills, true);
		_snprintf(buffer, 128, "TK: %d", teamkills);
		GetEzLcd()->SetText(m_TIATeamKills, buffer);
	}

	int scorelimit = g_pGameCVars->g_scorelimit;
	if(scorelimit==0)
	{
		if(scoreUS>100 || scoreNK>100)
		{
			scorelimit = max(scoreUS, scoreNK);
		}
		else
			scorelimit = 100;
	}
	if(clientteam==2)
	{
		GetEzLcd()->SetVisible(m_teamUS, true);
		GetEzLcd()->SetVisible(m_teamNK, true);
		_snprintf(buffer, 128, "US: %d", scoreUS);
		GetEzLcd()->SetText(m_teamUS, buffer);
		_snprintf(buffer, 128, "NK: %d", scoreNK);
		GetEzLcd()->SetText(m_teamNK, buffer);
		GetEzLcd()->SetVisible(m_teamUSScore, true);
		GetEzLcd()->SetProgressBarPosition(m_teamUSScore, (100 * scoreUS)/scorelimit);
		GetEzLcd()->SetVisible(m_teamNKScore, true);
		GetEzLcd()->SetProgressBarPosition(m_teamNKScore, (100 * scoreNK)/scorelimit);
	}
	else
	{
		GetEzLcd()->SetVisible(m_teamUS, true);
		GetEzLcd()->SetVisible(m_teamNK, true);
		_snprintf(buffer, 128, "NK: %d", scoreNK);
		GetEzLcd()->SetText(m_teamUS, buffer);
		_snprintf(buffer, 128, "US: %d", scoreUS);
		GetEzLcd()->SetText(m_teamNK, buffer);
		GetEzLcd()->SetVisible(m_teamUSScore, true);
		GetEzLcd()->SetProgressBarPosition(m_teamUSScore, (100 * scoreNK)/scorelimit);
		GetEzLcd()->SetVisible(m_teamNKScore, true);
		GetEzLcd()->SetProgressBarPosition(m_teamNKScore, (100 * scoreUS)/scorelimit);
	}

}

void CGameStatus::UpdatePowerStruggle()
{
	static int PP_AMOUNT_KEY = 0;
	if (!PP_AMOUNT_KEY)
		m_pGameRulesScript->GetValue("PP_AMOUNT_KEY", PP_AMOUNT_KEY);

	int playerPP=0;
	m_pGameRules->GetSynchedEntityValue(m_pClientActor->GetEntity()->GetId(), TSynchedKey(PP_AMOUNT_KEY), playerPP);

	int teamCount = m_pGameRules->GetTeamCount();
	if (teamCount > 1)
	{
		char buffer[128];

		if (m_pGameRules->IsPlayerActivelyPlaying(m_pClientActor->GetEntityId()))
		{
			// have prestige point stuff
			CHUDScore::SRankStats rankStats;
			rankStats.Update(m_pGameRulesScript, m_pClientActor);
			bool drawTeamScores=(rankStats.currentRank!=0); // if we got here it means we don't want to show the number of kills

			GetEzLcd()->SetVisible(m_ppPrestige, true);
			_snprintf(buffer, 128, "Prestige: %d", playerPP);
			GetEzLcd()->SetText(m_ppPrestige, buffer);

			GetEzLcd()->SetVisible(m_ppMSP, true);
			_snprintf(buffer, 128, "MSP: %d", rankStats.currentRankPP);
			GetEzLcd()->SetText(m_ppMSP, buffer);

			string temp;
			GetEzLcd()->SetVisible(m_ppRank, true);
			m_pLocalizationMan->GetEnglishString(rankStats.currentRankName, temp);
			_snprintf(buffer, 128, "Rank: %s", temp.c_str());
			GetEzLcd()->SetText(m_ppRank, buffer);

			GetEzLcd()->SetVisible(m_ppNextRank, true);
			m_pLocalizationMan->GetEnglishString(rankStats.nextRankName, temp);
			_snprintf(buffer, 128, "Next: %s", temp.c_str());
			GetEzLcd()->SetText(m_ppNextRank, buffer);

			GetEzLcd()->SetVisible(m_ppProgress, true);
			GetEzLcd()->SetProgressBarPosition(m_ppProgress, 100.0f * ((rankStats.playerCP - rankStats.currentRankCP) / float(rankStats.nextRankCP - rankStats.currentRankCP)));
		}
		else
		{
			// spectating
			GetEzLcd()->SetVisible(m_teamUS, true);
			_snprintf(buffer, 128, "Team US: %02d Players", m_pGameRules->GetTeamPlayerCount(2));
			GetEzLcd()->SetText(m_teamUS, buffer);
			GetEzLcd()->SetVisible(m_teamNK, true);
			_snprintf(buffer, 128, "Team NK: %02d Players", m_pGameRules->GetTeamPlayerCount(1));
			GetEzLcd()->SetText(m_teamNK, buffer);
		}
	}
}

void CGameStatus::SetScore(int slot, int rank, const char* name, int frags)
{
	if (slot >= MAX_SCORES)
		return;

	if (rank == -1)
	{
		GetEzLcd()->SetText(m_scoreRanks[slot], "-");
		GetEzLcd()->SetText(m_scoreNames[slot], "");
		GetEzLcd()->SetText(m_scoreScores[slot], "-");
		return;
	}

	char buffer[128];

	_snprintf(buffer, 128, "%d", rank);
	GetEzLcd()->SetText(m_scoreRanks[slot], buffer);

	_snprintf(buffer, 128, "%s", name);
	GetEzLcd()->SetText(m_scoreNames[slot], buffer);

	// see if we have a fraglimit
	if (g_pGameCVars->g_fraglimit)
	{
		_snprintf(buffer, 128, "%d/%d", frags, g_pGameCVars->g_fraglimit);
	}
	else
	{
		_snprintf(buffer, 128, "%d", frags);
	}

	GetEzLcd()->SetText(m_scoreScores[slot], buffer);
}

#endif
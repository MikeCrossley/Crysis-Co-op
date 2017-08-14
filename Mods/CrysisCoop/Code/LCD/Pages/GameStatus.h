/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
Description: 	Sits on slot 2

-------------------------------------------------------------------------
History:
- 02:11:2007: Created by Marco Koegler

*************************************************************************/
#ifndef __GAMESTATUS_H__
#define __GAMESTATUS_H__

#ifdef USE_G15_LCD
#include "../LCDPage.h"

class CGameRules;
class CPlayer;
struct IActor;
struct ILocalizationManager;
struct IScriptTable;

class CGameStatus : public CLCDPage
{
public:
	CGameStatus();
	virtual ~CGameStatus();

	virtual bool	PreUpdate();
	virtual void	Update(float frameTime);

protected:
	virtual void OnAttach();

private:
	void	UpdateGameMode();
	void	UpdateSingleplayer();
	void	UpdateServerAndIP();
	void	UpdateTime();
	void	UpdateInstantAction();
	void	UpdateTeamInstantAction();
	void	UpdatePowerStruggle();

	void SetScore(int slot, int rank, const char* name, int frags);

	HANDLE	m_IPText;
	HANDLE	m_timeText;
	HANDLE	m_objectiveText;
	const static int MAX_OBJECTIVE = 4;
	HANDLE	m_objectives[MAX_OBJECTIVE];
	_smart_ptr<CLCDImage>	m_objectiveIcons[MAX_OBJECTIVE];
	HANDLE	m_ppPrestige;
	HANDLE	m_ppMSP;
	HANDLE	m_ppRank;
	HANDLE	m_ppNextRank;
	HANDLE	m_ppProgress;

	HANDLE	m_teamUS;
	HANDLE	m_teamNK;

	HANDLE m_teamUSScore;
	HANDLE m_teamNKScore;
	HANDLE m_TIAScore;
	HANDLE m_TIAKills;
	HANDLE m_TIADeaths;
	HANDLE m_TIATeamKills;

	const static int MAX_SCORES = 2;
	HANDLE	m_scoreRanks[MAX_SCORES];
	HANDLE	m_scoreNames[MAX_SCORES];
	HANDLE	m_scoreScores[MAX_SCORES];

	// used for convenience during update
	mutable IActor*	m_pClientActor;
	mutable ILocalizationManager* m_pLocalizationMan;
	mutable CGameRules* m_pGameRules;
	mutable IScriptTable* m_pGameRulesScript;

	// for score sorting
	struct SScore
	{
		IActor* pActor;
		int kills;
		int deaths;

		SScore(IActor* _pActor, int _kills, int _deaths) : pActor(_pActor), kills(_kills), deaths(_deaths){}

		bool operator<(const SScore& entry) const;
	};

	std::vector<SScore> m_scores;
};

#endif //USE_G15_LCD

#endif
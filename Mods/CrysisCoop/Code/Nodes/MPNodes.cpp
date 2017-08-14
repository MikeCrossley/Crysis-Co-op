/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$

-------------------------------------------------------------------------
History:
- 26:04:2007   17.47: Created by Steve Humphreys

*************************************************************************/

#include "StdAfx.h"

#include "GameRules.h"
#include "GameCVars.h"
#include "Player.h"
#include "Nodes/G2FlowBaseNode.h"

#include <IVehicleSystem.h>

class CFlowNode_MP : public CFlowBaseNode, public CGameRules::SGameRulesListener
{
	enum INPUTS
	{
		EIP_GameEndTime = 0,
	};

	enum OUTPUTS
	{
		//EOP_GameStarted,
		EOP_EnteredGame,
		EOP_EndGameNear,
		EOP_EndGameInvalid,
		EOP_GameWon,
		EOP_GameLost,
		EOP_GameTied,
	};

public:
	CFlowNode_MP( SActivationInfo * pActInfo )
	{
		if(pActInfo && pActInfo->pGraph)
		{
			pActInfo->pGraph->SetRegularlyUpdated(pActInfo->myID, true);
		}

		m_localPlayerSpectatorMode = 0;
		m_endGameNear = false;
		m_timeRemainingTriggered = true;		// default to true so it won't be triggered again until player enters game.
		m_gameStarted = false;
	}

	~CFlowNode_MP()
	{
		CGameRules* pGameRules = g_pGame->GetGameRules();
		if(pGameRules)
			pGameRules->RemoveGameRulesListener(this);
	}

	IFlowNodePtr Clone(SActivationInfo* pActInfo)
	{
		return new CFlowNode_MP(pActInfo);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void GetConfiguration( SFlowNodeConfig& config )
	{
		static const SInputPortConfig in_ports[] = 
		{
			InputPortConfig<float>("GameEndTime", _HELP("Number of seconds remaining at which to trigger the EndGameNear output")),
			{0}
		};
		static const SOutputPortConfig out_ports[] = 
		{
			//OutputPortConfig_Void( "GameStarted", _HELP("Triggered when MP game begins")),
			OutputPortConfig_Void( "EnteredGame", _HELP("Triggered when local player enters the game")),
			OutputPortConfig_Void( "EndGameNear", _HELP("Triggered when game-ending condition is near")),
			OutputPortConfig_Void( "EndGameInvalid", _HELP("Triggered when game-ending condition is invalidated")),
			OutputPortConfig_Void( "GameWon", _HELP("Triggered when local player's team wins the game")),
			OutputPortConfig_Void( "GameLost", _HELP("Triggered when local player's team loses the game")),
			OutputPortConfig_Void( "GameTied", _HELP("Triggered when neither team wins the game")),
			{0}
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("MP MPNode");
		config.SetCategory(EFLN_APPROVED);
	}

	void ProcessEvent( EFlowEvent event, SActivationInfo *pActInfo )
	{
		switch (event)
		{
		case eFE_Initialize:
			{
				CGameRules* pGameRules = g_pGame->GetGameRules();
				if(pGameRules)
					pGameRules->AddGameRulesListener(this);

				CPlayer* pPlayer = static_cast<CPlayer*>(g_pGame->GetIGameFramework()->GetClientActor());
				if(pPlayer)
					m_localPlayerSpectatorMode = pPlayer->GetSpectatorMode();

				m_actInfo = *pActInfo;
			}
			break;
		case eFE_Activate:
			break;
		case eFE_Update:
			{
				CPlayer* pPlayer = static_cast<CPlayer*>(g_pGame->GetIGameFramework()->GetClientActor());
				if(!pPlayer)
					return;

				// first check: tac weapons trigger endgamenear / endgameinvalid
				if(m_MDList.empty() && m_endGameNear)
				{
					// if less than 3 min remaining don't return to normal
					bool cancel = true;
					if(g_pGame && g_pGame->GetGameRules() && g_pGame->GetGameRules()->IsTimeLimited() && m_timeRemainingTriggered)
					{
						float timeRemaining = g_pGame->GetGameRules()->GetRemainingGameTime();
						if(timeRemaining < GetPortFloat(pActInfo, EIP_GameEndTime) )
							cancel = false;
					}

					if(cancel)
					{
						if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
						{
							CryLog("MP flowgraph: EndGameInvalid");
						}
						ActivateOutput(&m_actInfo, EOP_EndGameInvalid, true);
						m_endGameNear = false;
					}
				}
				else if(!m_MDList.empty())
				{
					// go through the list of tac/sing weapons and check if they are still present
					std::list<EntityId>::iterator next;
					std::list<EntityId>::iterator it = m_MDList.begin();
					for(; it != m_MDList.end(); it = next)
					{
						next = it; ++next;
						if(gEnv->pEntitySystem->GetEntity(*it))
						{
							// entity exists so trigger loud music if not already done
							if(!m_endGameNear)
							{
								if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
								{
									CryLog("--MP flowgraph: EndGameNear");
								}
								ActivateOutput(&m_actInfo, EOP_EndGameNear, true);
								m_endGameNear = true;
							}

							// in the case of tanks, entity isn't removed for quite some time after destruction.
							//	Check vehicle health directly here...
							IVehicle* pVehicle = g_pGame->GetIGameFramework()->GetIVehicleSystem()->GetVehicle(*it);
							if(pVehicle && pVehicle->IsDestroyed())
							{
								m_MDList.erase(it);
							}
						}
						else
						{
							// entity no longer exists - remove from list.
 							m_MDList.erase(it);
						}
					}
				}

				// get the remaining time from game rules
				if(!m_timeRemainingTriggered && g_pGame->GetGameRules() && g_pGame->GetGameRules()->IsTimeLimited() && pPlayer->GetSpectatorMode() == 0 && !m_endGameNear)
				{
					float timeRemaining = g_pGame->GetGameRules()->GetRemainingGameTime();
					if(timeRemaining < GetPortFloat(pActInfo, EIP_GameEndTime) )
					{
						if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
						{
							CryLog("--MP flowgraph: EndGameNear");
						}
						ActivateOutput(&m_actInfo, EOP_EndGameNear, timeRemaining);
						m_timeRemainingTriggered = true;
						m_endGameNear = true;
					}
				}

				// also check whether the local player is in game yet
				bool inGame = false;
				IEntityScriptProxy *pScriptProxy=static_cast<IEntityScriptProxy *>(g_pGame->GetGameRules()->GetEntity()->GetProxy(ENTITY_PROXY_SCRIPT));
				if (pScriptProxy)
				{
					inGame = (stricmp(pScriptProxy->GetState(), "InGame") == 0);
				}

				if((pPlayer->GetSpectatorMode() == 0 && m_localPlayerSpectatorMode != 0)
					|| (!m_gameStarted && inGame) )
				{
					if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
					{
						CryLog("--MP flowgraph: EnteredGame");
					}
					ActivateOutput(&m_actInfo, EOP_EnteredGame, true);
					m_localPlayerSpectatorMode = pPlayer->GetSpectatorMode();
				}

				m_gameStarted = inGame;
			}
			break;
		}
	}

protected:
	virtual void GameOver(int localWinner, int winnerTeam, EntityId id)
		{
			switch(localWinner)
			{
				case 1:
					if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
					{
						CryLog("--MP flowgraph: GameWon");
					}
					ActivateOutput(&m_actInfo, EOP_GameWon,true);
					break;
			
				case -1:
					if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
					{
						CryLog("--MP flowgraph: GameLost");
					}
					ActivateOutput(&m_actInfo, EOP_GameLost,true);
					break;

				default:
					if(g_pGame->GetCVars()->i_debug_mp_flowgraph != 0)
					{
						CryLog("--MP flowgraph: GameTied");
					}
					ActivateOutput(&m_actInfo, EOP_GameTied, true);
					break;
			}
		}
		virtual void EnteredGame()
		{
// 			CPlayer* pPlayer = static_cast<CPlayer*>(g_pGame->GetIGameFramework()->GetClientActor());
// 			if(pPlayer && pPlayer->GetSpectatorMode() == 0)
// 			{
// 				ActivateOutput(&m_actInfo, EOP_EnteredGame,true);
// 				m_timeRemainingTriggered = false;
// 			}
		}
		virtual void EndGameNear(EntityId id)
		{
			if(id != 0)
			{
				m_MDList.push_back(id);
			}
		}

	SActivationInfo m_actInfo;
	int m_localPlayerSpectatorMode;
	bool m_endGameNear;
	bool m_timeRemainingTriggered;
	bool m_gameStarted;

	std::list<EntityId> m_MDList;
};

//----------------------------------------------------------------------------------------

class CFlowNode_MPGameType : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_GetGameMode = 0,
	};

	enum OUTPUTS
	{
		EOP_InstantAction = 0,
	//	EOP_TeamInstantAction,
		EOP_TeamAction,
		EOP_PowerStruggle,

		EOP_GameRulesName,
	};

public:
	CFlowNode_MPGameType( SActivationInfo * pActInfo )
	{
	}

	~CFlowNode_MPGameType()
	{
	}

	IFlowNodePtr Clone(SActivationInfo* pActInfo)
	{
		return new CFlowNode_MPGameType(pActInfo);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void GetConfiguration( SFlowNodeConfig& config )
	{
		static const SInputPortConfig in_ports[] = 
		{
			InputPortConfig_Void( "GetGameType", _HELP("Activate this to retrigger relevent outputs")),
			{0}
		};
		static const SOutputPortConfig out_ports[] = 
		{
			OutputPortConfig_Void( "InstantAction", _HELP("Triggered on level load if IA or TIA game")),
	//		OutputPortConfig_Void( "TeamInstantAction", _HELP("Triggered on level load if TeamInstantAction game")),
			OutputPortConfig_Void( "TeamAction", _HELP("Triggered on level load if TeamAction game")),
			OutputPortConfig_Void( "PowerStruggle", _HELP("Triggered on level load if PowerStruggle game")),
			OutputPortConfig<string>("GameRulesName", _HELP("Outputs the current game rules name")),
			{0}
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("MP GameTypeNode");
		config.SetCategory(EFLN_APPROVED);
	}

	void ProcessEvent( EFlowEvent event, SActivationInfo *pActInfo )
	{
		switch (event)
		{
		case eFE_Initialize:
			{
				m_actInfo = *pActInfo;
			}
			break;
		case eFE_Activate:
			{
				if(IsPortActive(pActInfo, EIP_GetGameMode))
				{
					TriggerGameTypeOutput();
				}
			}
			break;
		}
	}

	void TriggerGameTypeOutput()
	{
		if(g_pGame->GetGameRules())
		{
			const char* gameRulesName = g_pGame->GetGameRules()->GetEntity()->GetClass()->GetName();
			if(!strcmp(gameRulesName, "PowerStruggle"))
				ActivateOutput(&m_actInfo, EOP_PowerStruggle, true);
			else if(!strcmp(gameRulesName, "InstantAction"))
				ActivateOutput(&m_actInfo, EOP_InstantAction, true);
			else if(!strcmp(gameRulesName, "TeamInstantAction"))		// todo: does this need it's own output? For now just using the IA one.
				ActivateOutput(&m_actInfo, EOP_InstantAction, true);
			else if(!strcmp(gameRulesName, "TeamAction"))
				ActivateOutput(&m_actInfo, EOP_TeamAction, true);

			// output the name as well (for supporting any additional modes that might be added)
			ActivateOutput(&m_actInfo, EOP_GameRulesName, string(gameRulesName));
		}
	}

protected:
	SActivationInfo m_actInfo;
};

//----------------------------------------------------------------------------------------

class CFlowNode_MPGetTeam : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Trigger = 0,
	};

	enum OUTPUTS
	{
		EOP_TeamName = 0,
		EOP_IsNK,
		EOP_IsUS,
		EOP_IsNeutral,
	};

public:
	CFlowNode_MPGetTeam( SActivationInfo * pActInfo )
	{
	}

	~CFlowNode_MPGetTeam()
	{
	}

	IFlowNodePtr Clone(SActivationInfo* pActInfo)
	{
		return new CFlowNode_MPGetTeam(pActInfo);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void GetConfiguration( SFlowNodeConfig& config )
	{
		static const SInputPortConfig in_ports[] = 
		{
			InputPortConfig_Void( "Trigger", _HELP("Trigger the output")),
			{0}
		};
		static const SOutputPortConfig out_ports[] = 
		{
			OutputPortConfig<string>( "TeamName", _HELP("Outputs the name of the team (tan /black)")),
			OutputPortConfig_Void( "IsNK", _HELP("Triggered if the team is tan (NK)")),
			OutputPortConfig_Void( "IsUS", _HELP("Triggered if the team is black (US)")),
			OutputPortConfig_Void( "IsNeutral", _HELP("Triggered if the entity has no team")),
			{0}
		};
		config.nFlags |= EFLN_TARGET_ENTITY;
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("MP GetTeam node");
		config.SetCategory(EFLN_APPROVED);
	}

	void ProcessEvent( EFlowEvent event, SActivationInfo *pActInfo )
	{
		switch (event)
		{
		case eFE_Initialize:
			{
				m_actInfo = *pActInfo;
			}
			break;
		case eFE_Activate:
			{
				if(IsPortActive(pActInfo, EIP_Trigger))
				{
					if(!pActInfo || !pActInfo->pEntity)
						break;

					int team = g_pGame->GetGameRules()->GetTeam(pActInfo->pEntity->GetId());

					string teamName = "";
					switch(team)
					{
					case 0:
					default:
						ActivateOutput(pActInfo, EOP_IsNeutral, true);
						break;
						
					case 1:
						teamName = "tan";
						ActivateOutput(pActInfo, EOP_IsNK, true);
						break;

					case 2:
						teamName = "black";
						ActivateOutput(pActInfo, EOP_IsUS, true);
						break;
					}

					ActivateOutput(pActInfo, EOP_TeamName, teamName);
				}
			}
			break;
		}
	}

protected:
	SActivationInfo m_actInfo;
};

//----------------------------------------------------------------------------------------

class CFlowNode_MPSetTeam : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Trigger = 0,
		EIP_TeamId,
		EIP_TeamName,
	};

public:
	CFlowNode_MPSetTeam( SActivationInfo * pActInfo )
	{
	}

	~CFlowNode_MPSetTeam()
	{
	}

	IFlowNodePtr Clone(SActivationInfo* pActInfo)
	{
		return new CFlowNode_MPSetTeam(pActInfo);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void GetConfiguration( SFlowNodeConfig& config )
	{
		static const SInputPortConfig in_ports[] = 
		{
			InputPortConfig_Void( "Trigger", _HELP("Trigger the change of team")),
			InputPortConfig<int>( "TeamId", _HELP("Change the team (0 neutral, 1 NK, 2 US)")),
			InputPortConfig<string>( "TeamName", _HELP("Change the team by name ('neutral' / 'tan' / 'black'")),
			{0}
		};
		static const SOutputPortConfig out_ports[] = 
		{
			{0}
		};
		config.nFlags |= EFLN_TARGET_ENTITY;
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("MP SetTeam node");
		config.SetCategory(EFLN_APPROVED);
	}

	void ProcessEvent( EFlowEvent event, SActivationInfo *pActInfo )
	{
		switch (event)
		{
		case eFE_Initialize:
			{
				m_actInfo = *pActInfo;
			}
			break;
		case eFE_Activate:
			{
				if(!pActInfo || !pActInfo->pEntity)
					break;

				if(IsPortActive(pActInfo, EIP_Trigger))
				{
					string teamName = GetPortString(pActInfo, EIP_TeamName);
					int team = GetPortInt(pActInfo, EIP_TeamId);
					
					if(team == 0)
					{
						if(!strcmp(teamName, "tan"))
							team = 1;
						else if(!strcmp(teamName, "black"))
							team = 2;
					}

					g_pGame->GetGameRules()->SetTeam(team, pActInfo->pEntity->GetId()); 
				}
			}
			break;
		}
	}

protected:
	SActivationInfo m_actInfo;
};

REGISTER_FLOW_NODE("Multiplayer:MP",	CFlowNode_MP);
REGISTER_FLOW_NODE("Multiplayer:GameType", CFlowNode_MPGameType);
REGISTER_FLOW_NODE("Multiplayer:GetTeam", CFlowNode_MPGetTeam);
REGISTER_FLOW_NODE("Multiplayer:SetTeam", CFlowNode_MPSetTeam);
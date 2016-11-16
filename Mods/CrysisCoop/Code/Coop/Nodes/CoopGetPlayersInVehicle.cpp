#include <StdAfx.h>
#include <Nodes/G2FlowBaseNode.h>
#include <IEntitySystem.h>
#include <IVehicleSystem.h>
#include <IActorSystem.h>
#include <IGameRulesSystem.h>
#include <GameRules.h>

#include "Coop/Actors/CoopPlayer.h"

class CCoopFlowNode_GetPlayersInVehicle : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Get = 0,
	};

	enum OUTPUTS
	{
		EOP_All = 0,
		EOP_Count,
	};

public:
	CCoopFlowNode_GetPlayersInVehicle(SActivationInfo * pActInfo) : m_nVehicleEntityId(0) {}

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Get", _HELP("Gets the number of players in the vehicle.")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			OutputPortConfig_Void("All", _HELP("Called if all players are in the vehicle.")),
			OutputPortConfig<int>("Count", _HELP("The number of players in the vehicle.")),
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Gets if all players are in the specified vehicle, or the amount of players in the vehicle.");
		config.nFlags = EFLN_TARGET_ENTITY;
		config.SetCategory(EFLN_APPROVED);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (event == eFE_SetEntityId)
		{
			if (pActInfo->pEntity)
			{
				m_nVehicleEntityId = pActInfo->pEntity->GetId();
			}
		}

		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Get))
		{
			IVehicle* pVehicle = gEnv->pGame->GetIGameFramework()->GetIVehicleSystem()->GetVehicle(m_nVehicleEntityId);
			if (pVehicle)
			{
				int nPlayers = 0;
				int nSeats = pVehicle->GetSeatCount();
				for (int i = 0; i < nSeats; ++i)
				{
					IVehicleSeat* pSeat = pVehicle->GetSeatById(i);
					if (pSeat)
					{
						IActor* pPassenger = gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor(pSeat->GetPassenger());
						if (pPassenger && pPassenger->IsPlayer())
						{
							nPlayers++;
						}
					}
				}

				int spectatorCount = 0;

				IActorIteratorPtr it = g_pGame->GetIGameFramework()->GetIActorSystem()->CreateActorIterator();
				while (CActor* pActor = static_cast<CActor*>(it->Next()))
				{
					if (pActor->IsPlayer() && pActor->GetSpectatorMode() != 0)
					{
						spectatorCount++;
					}
				}

				CGameRules* pGameRules = (CGameRules*)gEnv->pGame->GetIGameFramework()->GetIGameRulesSystem()->GetCurrentGameRules();
				if (pGameRules)
				{
					int nConnected = pGameRules->GetPlayerCount(true);
					int inGamePlayerCount = nConnected - spectatorCount;
					if (nPlayers == inGamePlayerCount && inGamePlayerCount > 0 )
						ActivateOutput(pActInfo, EOP_All, 0);
					ActivateOutput(pActInfo, EOP_Count, nPlayers);
				}
			}
			//IVehicle* pVehicle = 

		}
	}


	EntityId m_nVehicleEntityId;
};



class CCoopFlowNode_SetPlayersGodMode : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Set = 0,
		EIP_God,
	};

	enum OUTPUTS
	{
	};

public:
	CCoopFlowNode_SetPlayersGodMode(SActivationInfo * pActInfo) {}

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Set", _HELP("Sets all players to the god mode number specified.")),
			InputPortConfig<int>("GodMode", _HELP("The type of godmode.")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Sets all players to the god mode number specified.");
		config.SetCategory(EFLN_WIP);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Set))
		{
			int godMode = GetPortInt(pActInfo, EIP_God);
			IActorIteratorPtr it = g_pGame->GetIGameFramework()->GetIActorSystem()->CreateActorIterator();
			while (CActor* pActor = static_cast<CActor*>(it->Next()))
			{
				if (pActor->IsPlayer())
				{
					//CCoopPlayer* pPlayer = static_cast<CCoopPlayer*>(pActor);
					//pPlayer->SetGodMode(godMode);
				}
			}
		}
	}

};

REGISTER_FLOW_NODE("Coop:GetPlayersInVehicle", CCoopFlowNode_GetPlayersInVehicle);
REGISTER_FLOW_NODE("Coop:SetPlayersGodMode", CCoopFlowNode_SetPlayersGodMode);
#include <StdAfx.h>
#include <Nodes/G2FlowBaseNode.h>
#include <IEntitySystem.h>
#include "Coop/Actors/CoopPlayer.h"

class CCoopFlowNode_RandomSpawnpoint : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_FindSpawns = 0,
		EIP_Get,
		EIP_SpawnName,
	};

	enum OUTPUTS
	{
		EOP_SpawnLocation = 0,
	};

public:
	CCoopFlowNode_RandomSpawnpoint(SActivationInfo * pActInfo) { }

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("FindSpawns", _HELP("Finds all the tagpoints with the specified name, call again if name changes")),
			InputPortConfig_Void("Get", _HELP("Gets a random spawn point.")),
			InputPortConfig<string>("SpawnName", _HELP("Name of the spawnpoint")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			OutputPortConfig<Vec3>("SpawnPoint", _HELP("The randomly chosen spoint point")),
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Selects a random tagpoint of the input name.");
		config.SetCategory(EFLN_APPROVED);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_FindSpawns))
		{
			if (m_entities.size() > 0)
				m_entities.clear();

			IEntityIt* iter = gEnv->pEntitySystem->GetEntityIterator();
			while (!iter->IsEnd())
			{
				if (IEntity* pEnt = iter->Next())
				{
					IEntityClass* pEntityClass = pEnt->GetClass();
					IEntityClass* pTagPointClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("TagPoint");

					if (pEntityClass == pTagPointClass)
					{
						string sEntityName = pEnt->GetName();
						string sSpawnName = GetPortString(pActInfo, EIP_SpawnName);

						int nSameCharacters = sEntityName.find_first_not_of(sSpawnName);

						if (nSameCharacters == sSpawnName.length())
						{
							m_entities.push_back(pEnt);
						}
					}
				}
			}
		}

		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Get))
		{
			if (m_entities.size() <= 0)
				return;

			int nSpawnRandom = int((cry_rand() / (float)RAND_MAX) * m_entities.size());

			IEntity* pEntity = m_entities[nSpawnRandom];

			ActivateOutput(pActInfo, EOP_SpawnLocation, pEntity->GetPos());
		}
	}

	std::vector<IEntity*> m_entities;

};

REGISTER_FLOW_NODE("Coop:GetRandomSpawn", CCoopFlowNode_RandomSpawnpoint);
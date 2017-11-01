#include <StdAfx.h>
#include <Nodes/G2FlowBaseNode.h>
#include <IEntitySystem.h>
#include "Coop/Actors/CoopPlayer.h"

class CCoopFlowNode_SpawnArchetype : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Spawn = 0,
		EIP_Archetype,
		EIP_Position,
		EIP_Rotation,
	};

	enum OUTPUTS
	{
		EOP_Succeeded = 0,
		EOP_Failed,
	};

public:
	CCoopFlowNode_SpawnArchetype(SActivationInfo * pActInfo) { }

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Spawn", _HELP("Spawns the archetype entity.")),
			InputPortConfig<string>("Archetype", _HELP("Archetype class of the entity.")),
			InputPortConfig<Vec3>("Position", _HELP("Position of the entity.")),
			InputPortConfig<Vec3>("Rotation", _HELP("Rotation of the entity.")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			OutputPortConfig<EntityId>("Succeeded", _HELP("Called if the entity was spawned, outputs the newly spawned entity's id.")),
			OutputPortConfig_Void("Failed", _HELP("Called if the entity was not spawned.")),
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Spawns an archetype entity.");
		config.SetCategory(EFLN_APPROVED);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Spawn))
		{
			IEntityArchetype* pEntityArch = gEnv->pEntitySystem->LoadEntityArchetype(GetPortString(pActInfo, EIP_Archetype));
			
			if (!pEntityArch)
				return;

			SEntitySpawnParams spawnParams;
			spawnParams.pArchetype = pEntityArch;
			spawnParams.vPosition = GetPortVec3(pActInfo, EIP_Position);
			spawnParams.qRotation = Quat::CreateRotationXYZ(Ang3(GetPortVec3(pActInfo, EIP_Rotation)));
			spawnParams.nFlags = ENTITY_FLAG_SPAWNED | ENTITY_FLAG_NET_PRESENT | ENTITY_FLAG_CASTSHADOW;
			
			IEntity* pEntity = gEnv->pEntitySystem->SpawnEntity(spawnParams);
			if (!pEntity)
			{
				ActivateOutput(pActInfo, EOP_Failed, 0);
			}
			else
			{
				ActivateOutput(pActInfo, EOP_Succeeded, pEntity->GetId());
			}
			
		}
	}
};

class CCoopFlowNode_GetSystemEnvironment : public CFlowBaseNode
{
    enum INPUTS
    {
        EIP_Get = 0,
    };
 
    enum OUTPUTS
    {
        EOP_Client = 0,
        EOP_Server,
        EOP_Editor,
        EOP_Dedicated,
    };
 
public:
    CCoopFlowNode_GetSystemEnvironment(SActivationInfo * pActInfo) { }
 
    void GetConfiguration(SFlowNodeConfig& config)
    {
        static const SInputPortConfig in_ports[] =
        {
            InputPortConfig_Void("Get", _HELP("Gets the system environment parameters.")),
            { 0 }
        };
        static const SOutputPortConfig out_ports[] =
        {
            OutputPortConfig_Void("Client", _HELP("Called if the engine is a client instance.")),
            OutputPortConfig_Void("Server", _HELP("Called if the engine is a server instance.")),
            OutputPortConfig_Void("Editor", _HELP("Called if the engine is a editor instance.")),
            OutputPortConfig_Void("Dedicated", _HELP("Called if the engine is a dedicated server instance.")),
            { 0 }
        };
        config.pInputPorts = in_ports;
        config.pOutputPorts = out_ports;
        config.sDescription = _HELP("Gets system runtime environment parameters.");
        config.SetCategory(EFLN_APPROVED);
    }
 
    virtual void GetMemoryStatistics(ICrySizer * s)
    {
        s->Add(*this);
    }
 
    void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
    {
        if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Get))
        {
			

			if (gEnv->bClient)
				ActivateOutput(pActInfo, EOP_Client, GetPortAny(pActInfo, EIP_Get));

			if (gEnv->bServer)
				ActivateOutput(pActInfo, EOP_Server, GetPortAny(pActInfo, EIP_Get));

			if (gEnv->bEditor)
				ActivateOutput(pActInfo, EOP_Editor, GetPortAny(pActInfo, EIP_Get));

			if (gEnv->bServer && !gEnv->bClient)
				ActivateOutput(pActInfo, EOP_Dedicated, GetPortAny(pActInfo, EIP_Get));
 
        }
    }
};

class CCoopFlowNode_ForceMusic : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Set = 0,
		EIP_IsForced,
		EIP_Intensity
	};

	enum OUTPUTS
	{
	};

public:
	CCoopFlowNode_ForceMusic(SActivationInfo * pActInfo) { }

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Set", _HELP("Sets the values for the player music system")),
			InputPortConfig<bool>("Force", _HELP("Force music to play at a certain intensity ignoring AI awareness")),
			InputPortConfig<float>("Intensity", _HELP("How intense the music is between 0 and 1.")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Sets the music intensity.");
		config.SetCategory(EFLN_APPROVED);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Set))
		{
			CCoopPlayer* pPlayer = NULL;
			IActor* pActor = gEnv->pGame->GetIGameFramework()->GetClientActor();

			if (pActor)
				pPlayer = static_cast<CCoopPlayer*>(pActor);

			bool bForce = GetPortBool(pActInfo, EIP_IsForced);
			float fIntensity = GetPortFloat(pActInfo, EIP_Intensity);
	
			if (pPlayer)
			{
				if (bForce)
					CryLogAlways("Music forced ON at %f intensity", fIntensity);
				else
					CryLogAlways("Music forced OFF");

				pPlayer->ForceMusicMood(fIntensity, bForce);
			}
		}
	}
};

REGISTER_FLOW_NODE("Coop:ForceMusicIntensity", CCoopFlowNode_ForceMusic);
REGISTER_FLOW_NODE("Coop:GetSystemEnvironment", CCoopFlowNode_GetSystemEnvironment);
REGISTER_FLOW_NODE("Coop:SpawnArchetype", CCoopFlowNode_SpawnArchetype);
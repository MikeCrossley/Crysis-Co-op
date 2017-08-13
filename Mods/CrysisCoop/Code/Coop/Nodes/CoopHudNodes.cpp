#include "StdAfx.h"
#include <Nodes/G2FlowBaseNode.h>

#include "IGameObject.h"
#include "Coop/Entities/HUDSynchronizer.h"
#include "HUD/HUD.h"
#include "GameCVars.h"

CHUDSynchronizer* GetHudSynchronizer()
{
	std::set<IEntityClass*> classNames;

	IEntityIt* iter = gEnv->pEntitySystem->GetEntityIterator();
	while (!iter->IsEnd())
	{
		if (IEntity* pEnt = iter->Next())
		{
			IEntityClass* pEntityClass = pEnt->GetClass();
			IEntityClass* pHUDClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("HUDSynchronizer");

			if (pEntityClass == pHUDClass)
			{
				if (IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(pEnt->GetId()))
				{
					return (CHUDSynchronizer*)pGameObject->QueryExtension("HUDSynchronizer");
				}
			}
		}
	}

	return NULL;
}

class CFlowOverlayNode : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Show = 0,
		EIP_Hide,
		EIP_Message,
		EIP_PosX,
		EIP_PosY,
		EIP_Color,
		EIP_Timeout,
	};

	enum OUTPUTS
	{
		EOP_Done = 0
	};

public:
	CFlowOverlayNode(SActivationInfo* pActInfo)
	{
		m_actInfo = *pActInfo;
		m_pHudSynchronizer = NULL;
	}

	~CFlowOverlayNode()
	{
		m_pHudSynchronizer = NULL;
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Show", _HELP("Show the message")),
			InputPortConfig_Void("Hide", _HELP("Hide the message")),
			InputPortConfig<string>("Message", _HELP("Message to show"), 0, _UICONFIG("dt=text")),
			InputPortConfig<int>("PosX", 400, _HELP("PosX")),
			InputPortConfig<int>("PosY", 300, _HELP("PosY")),
			InputPortConfig<Vec3>("Color", Vec3(1.0f,1.0f,1.0f), _HELP("Color"), 0, _UICONFIG("dt=clr")),
			InputPortConfig<float>("Timeout", 3.0f, _HELP("How long to show message")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Show Overlay Messages on the HUD which is networked to clients");
		config.SetCategory(EFLN_WIP);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (event != eFE_Activate)
			return;

		if (IsPortActive(pActInfo, EIP_Show))
		{
			if (!m_pHudSynchronizer)
				m_pHudSynchronizer = GetHudSynchronizer();

			if (!m_pHudSynchronizer)
			{
				CryLogAlways("[CFlowOverlayNode] HUD Synchronizer Not Found!");
				return;
			}

			const int nPosX = GetPortInt(pActInfo, EIP_PosX);
			const int nPosY = GetPortInt(pActInfo, EIP_PosY);
			const string sMsg = GetPortString(pActInfo, EIP_Message);
			const float fDuration = GetPortFloat(pActInfo, EIP_Timeout);
			const Vec3 vColor = GetPortVec3(pActInfo, EIP_Color);

			if (gEnv->bServer)
				m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClDisplayOverlayMsg(), CHUDSynchronizer::SHudOverlayParams(nPosX, nPosY, sMsg, fDuration, vColor), eRMI_ToAllClients);
				
		}
		else if (IsPortActive(pActInfo, EIP_Hide))
		{
			if (!m_pHudSynchronizer)
				m_pHudSynchronizer = GetHudSynchronizer();

			if (!m_pHudSynchronizer)
			{
				CryLogAlways("[CFlowOverlayNode] HUD Synchronizer Not Found!");
				return;
			}

			if (gEnv->bServer)
				m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClHideOverlayMsg(), CHUDSynchronizer::SHudControlParams(), eRMI_ToAllClients);
		}
	}
private:
	SActivationInfo m_actInfo;
	CHUDSynchronizer* m_pHudSynchronizer;
};

class CFlowHudControlNode : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Show = 0,
		EIP_Hide,
		EIP_Boot,
		EIP_Break,
		EIP_Reboot,
		EIP_AlienInterference,
		EIP_AlienInterferenceStrength,
		EIP_MapNotAvailable
	};

public:
	CFlowHudControlNode(SActivationInfo* pActInfo)
	{
		m_actInfo = *pActInfo;
		m_pHudSynchronizer = NULL;
	}

	~CFlowHudControlNode()
	{
		m_pHudSynchronizer = NULL;
	}

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Show",  _HELP("Trigger this port to show the HUD")),
			InputPortConfig_Void("Hide",  _HELP("Trigger this port to hide the HID")),
			InputPortConfig_Void("BootSeq",  _HELP("Trigger this port to show the Boot Sequence")),
			InputPortConfig_Void("BreakSeq", _HELP("Trigger this port to show the Break Sequence")),
			InputPortConfig_Void("RebootSeq", _HELP("Trigger this port to show the Reboot Sequence")),
			InputPortConfig<bool>("AlienInterference", false, _HELP("Trigger with boolean to enable/disable Alien interference effect")),
			InputPortConfig<float>("AlienInterferenceStrength", 1.0f, _HELP("Strength of Alien interference effect")),
			InputPortConfig<bool>("MapNotAvailable", false, _HELP("Trigger with boolean to enable/disable an animation when Minimap does not exist")),
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = 0;
		config.sDescription = _HELP("Trigger some HUD-specific visual effects.");
		config.SetCategory(EFLN_WIP);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (eFE_Activate == event)
		{
			if (!m_pHudSynchronizer)
				m_pHudSynchronizer = GetHudSynchronizer();

			if (!m_pHudSynchronizer)
			{
				CryLogAlways("[CFlowHudControlNode] HUD Synchronizer Not Found!");
				return;
			}

			if (gEnv->bServer)
			{
				if (IsPortActive(pActInfo, EIP_Show))
					m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClHudControl(), CHUDSynchronizer::SHudControlParams(EIP_Show), eRMI_ToAllClients);
				if (IsPortActive(pActInfo, EIP_Hide))
					m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClHudControl(), CHUDSynchronizer::SHudControlParams(EIP_Hide), eRMI_ToAllClients);
				if (IsPortActive(pActInfo, EIP_Boot))
					m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClHudControl(), CHUDSynchronizer::SHudControlParams(EIP_Boot), eRMI_ToAllClients);
				if (IsPortActive(pActInfo, EIP_Break))
					m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClHudControl(), CHUDSynchronizer::SHudControlParams(EIP_Break), eRMI_ToAllClients);
				if (IsPortActive(pActInfo, EIP_Reboot))
					m_pHudSynchronizer->GetGameObject()->InvokeRMI(CHUDSynchronizer::ClHudControl(), CHUDSynchronizer::SHudControlParams(EIP_Reboot), eRMI_ToAllClients);
			}
			else
			{
				if (IsPortActive(pActInfo, EIP_Show))
					SAFE_HUD_FUNC(Show(true));
				if (IsPortActive(pActInfo, EIP_Hide))
					SAFE_HUD_FUNC(Show(false));
				if (IsPortActive(pActInfo, EIP_Boot))
					SAFE_HUD_FUNC(ShowBootSequence());
				if (IsPortActive(pActInfo, EIP_Break))
					SAFE_HUD_FUNC(BreakHUD());
				if (IsPortActive(pActInfo, EIP_Reboot))
					SAFE_HUD_FUNC(RebootHUD());
				if (IsPortActive(pActInfo, EIP_AlienInterference))
					g_pGameCVars->hud_enableAlienInterference = GetPortBool(pActInfo, EIP_AlienInterference);
				if (IsPortActive(pActInfo, EIP_AlienInterferenceStrength))
					g_pGameCVars->hud_alienInterferenceStrength = GetPortFloat(pActInfo, EIP_AlienInterferenceStrength);
				if (IsPortActive(pActInfo, EIP_MapNotAvailable))
					SAFE_HUD_FUNC(SetMinimapNotAvailable(GetPortBool(pActInfo, EIP_MapNotAvailable)));
			}
		}
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}
private:
	SActivationInfo m_actInfo;
	CHUDSynchronizer* m_pHudSynchronizer;
};


REGISTER_FLOW_NODE( "Coop:OverlayMsg", CFlowOverlayNode );
REGISTER_FLOW_NODE( "Coop:HudControl", CFlowHudControlNode);



#include <StdAfx.h>
#include "EventSynchronizer.h"
#include <Nodes/G2FlowBaseNode.h>

CEventSynchronizer::CEventSynchronizer() : m_listeners()
{

}

CEventSynchronizer::~CEventSynchronizer()
{
	m_listeners.clear();
}

void CEventSynchronizer::SendEvent(bool bLocal, SEventSynchronizerEvent sEvent)
{
	if (gEnv->bServer)
	{
		CryLogAlways("SERVER: [%s] Sending event by name %s.", GetEntity()->GetName(), sEvent.sEventName.c_str());
		GetGameObject()->InvokeRMI(CEventSynchronizer::ClOnEvent(), sEvent, eRMI_ToAllClients | (bLocal ? 0 : eRMI_NoLocalCalls));
	}
}

void CEventSynchronizer::ClientSendEvent(SEventSynchronizerEvent sEvent)
{
	//if (gEnv->bServer)
	//{
		CryLogAlways("CLIENT: [%s] Sending event by name %s.", GetEntity()->GetName(), sEvent.sEventName.c_str());
		GetGameObject()->InvokeRMI(CEventSynchronizer::SvRequest(), sEvent, eRMI_ToServer);
	//}
}

IMPLEMENT_RMI(CEventSynchronizer, ClOnEvent)
{
	std::list<IEventSynchronizerListener*>::iterator it;
	for (it = m_listeners.begin(); it != m_listeners.end(); ++it)
	{
		(*it)->OnSynchronizedEventReceived(params);
	}
	CryLogAlways("CLIENT: [%s] Received event by name %s.", GetEntity()->GetName(), params.sEventName.c_str());
	return true;
}

IMPLEMENT_RMI(CEventSynchronizer, SvRequest)
{
	std::list<IEventSynchronizerListener*>::iterator it;
	for (it = m_listeners.begin(); it != m_listeners.end(); ++it)
	{
		(*it)->OnSynchronizedEventReceived(params);
	}
	CryLogAlways("SERVER: [%s] Received event by name %s.", GetEntity()->GetName(), params.sEventName.c_str());
	return true;
}

bool CEventSynchronizer::Init(IGameObject *pGameObject)
{
	SetGameObject(pGameObject);

	if (!GetGameObject()->BindToNetwork())
		return false;

	return true;
}

void CEventSynchronizer::Release()
{
	delete this;
}

// Nodes too!

class CEventSynchronizer_SendEventNode : public CFlowBaseNode
{
	enum INPUTS
	{
		EIP_Send = 0,
		EIP_SendToLocal,
		EIP_SendToServer,
		EIP_EventName,
		EIP_String1,
		EIP_String2,
		EIP_Integer1,
		EIP_Integer2,
		EIP_Float1,
		EIP_Float2,
		EIP_Vector1,
		EIP_Vector2,
		EIP_EntityId1,
	};

	enum OUTPUTS
	{
		EOP_Sent = 0,
	};

public:
	CEventSynchronizer_SendEventNode(SActivationInfo * pActInfo) : m_nEventSynchronizerId(0)
	{
		if (pActInfo->pEntity)
		{
			m_nEventSynchronizerId = pActInfo->pEntity->GetId();
		}
	}

	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig_Void("Send", _HELP("Sends the event.")),
			InputPortConfig<bool>("SendToLocal", _HELP("If true, the server doesn't exclude itself from the event.")),
			InputPortConfig<bool>("SendToServer", _HELP("If true, the client sends the event to the server (SendToLocal Does Nothing).")),
			InputPortConfig<string>("EventName", _HELP("The name of the event to send.")),
			InputPortConfig<string>("String1", _HELP("")),
			InputPortConfig<string>("String2", _HELP("")),
			InputPortConfig<int>("Integer1", _HELP("")),
			InputPortConfig<int>("Integer2", _HELP("")),
			InputPortConfig<float>("Float1", _HELP("")),
			InputPortConfig<float>("Float2", _HELP("")),
			InputPortConfig<Vec3>("Vector1", _HELP("")),
			InputPortConfig<Vec3>("Vector2", _HELP("")),
			InputPortConfig<EntityId>("EntityId1", _HELP("")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			OutputPortConfig_Void("Sent", _HELP("Called if the message has been sent.")),
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Sends an event to the specified EventSynchronizer.");
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
				m_nEventSynchronizerId = pActInfo->pEntity->GetId();
			}
			else
			{
				m_nEventSynchronizerId = 0;
			}
		}

		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Send))
		{
			IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(m_nEventSynchronizerId);
			if (pGameObject)
			{
				CEventSynchronizer* pSynchronizer = (CEventSynchronizer*)pGameObject->QueryExtension("EventSynchronizer");
				if (pSynchronizer)
				{
					SEventSynchronizerEvent sEvent;
					bool bLocal = GetPortBool(pActInfo, EIP_SendToLocal);
					bool bToServer = GetPortBool(pActInfo, EIP_SendToServer);
					sEvent.sEventName = GetPortString(pActInfo, EIP_EventName);
					sEvent.sEventStrings1 = GetPortString(pActInfo, EIP_String1);
					sEvent.sEventStrings2 = GetPortString(pActInfo, EIP_String2);
					sEvent.nEventInts1 = GetPortInt(pActInfo, EIP_Integer1);
					sEvent.nEventInts2 = GetPortInt(pActInfo, EIP_Integer2);
					sEvent.fEventFloats1 = GetPortFloat(pActInfo, EIP_Float1);
					sEvent.fEventFloats2 = GetPortFloat(pActInfo, EIP_Float2);
					sEvent.vEventVecs1 = GetPortVec3(pActInfo, EIP_Vector1);
					sEvent.vEventVecs2 = GetPortVec3(pActInfo, EIP_Vector2);
					sEvent.vEventVecs2 = GetPortVec3(pActInfo, EIP_Vector2);
					sEvent.nEntityId1 = GetPortEntityId(pActInfo, EIP_EntityId1);

					if (!bToServer)
						pSynchronizer->SendEvent(bLocal, sEvent);
					else
						pSynchronizer->ClientSendEvent(sEvent);

					ActivateOutput(pActInfo, EOP_Sent, 0);
				}
			}
			//IVehicle* pVehicle = 

		}
	}


	EntityId m_nEventSynchronizerId;
};

class CEventSynchronizer_ListenEventNode : public CFlowBaseNode, public IEventSynchronizerListener
{
	enum INPUTS
	{
		EIP_Listen = 0,
	};

	enum OUTPUTS
	{
		EOP_EventName = 0,
		EOP_String1,
		EOP_String2,
		EOP_Integer1,
		EOP_Integer2,
		EOP_Float1,
		EOP_Float2,
		EOP_Vector1,
		EOP_Vector2,
		EOP_EntityId1,
	};

public:
	CEventSynchronizer_ListenEventNode(SActivationInfo * pActInfo) : m_nEventSynchronizerId(0)
	{
		if (pActInfo->pEntity)
		{
			m_nEventSynchronizerId = pActInfo->pEntity->GetId();
			IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(m_nEventSynchronizerId);
			if (pGameObject)
			{
				CEventSynchronizer* pSynchronizer = (CEventSynchronizer*)pGameObject->QueryExtension("EventSynchronizer");
				if (pSynchronizer)
				{
					pSynchronizer->RegisterEventListener(this);
				}
			}
		}
	}

	virtual ~CEventSynchronizer_ListenEventNode()
	{
		IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(m_nEventSynchronizerId);
		if (pGameObject)
		{
			CEventSynchronizer* pSynchronizer = (CEventSynchronizer*)pGameObject->QueryExtension("EventSynchronizer");
			if (pSynchronizer)
			{
				pSynchronizer->UnregisterEventListener(this);
			}
		}
	}


	void GetConfiguration(SFlowNodeConfig& config)
	{
		static const SInputPortConfig in_ports[] =
		{
			InputPortConfig<bool>("Listen", _HELP("Sets whether to listen to events or not.")),
			{ 0 }
		};
		static const SOutputPortConfig out_ports[] =
		{
			OutputPortConfig<string>("EventName", _HELP("The name of the received event.")),
			OutputPortConfig<string>("String1", _HELP("")),
			OutputPortConfig<string>("String2", _HELP("")),
			OutputPortConfig<int>("Integer1", _HELP("")),
			OutputPortConfig<int>("Integer2", _HELP("")),
			OutputPortConfig<float>("Float1", _HELP("")),
			OutputPortConfig<float>("Float2", _HELP("")),
			OutputPortConfig<Vec3>("Vector1", _HELP("")),
			OutputPortConfig<Vec3>("Vector2", _HELP("")),
			OutputPortConfig<EntityId>("EntityId1", _HELP("")),
			{ 0 }
		};
		config.pInputPorts = in_ports;
		config.pOutputPorts = out_ports;
		config.sDescription = _HELP("Listens to events from the specified EventSynchronizer.");
		config.nFlags = EFLN_TARGET_ENTITY;
		config.SetCategory(EFLN_APPROVED);
	}

	virtual void OnSynchronizedEventReceived(SEventSynchronizerEvent sEvent)
	{
		ActivateOutput(&m_actInfo, EOP_EventName, sEvent.sEventName);
		ActivateOutput(&m_actInfo, EOP_String1, sEvent.sEventStrings1);
		ActivateOutput(&m_actInfo, EOP_String2, sEvent.sEventStrings2);
		ActivateOutput(&m_actInfo, EOP_Integer1, sEvent.nEventInts1);
		ActivateOutput(&m_actInfo, EOP_Integer2, sEvent.nEventInts2);
		ActivateOutput(&m_actInfo, EOP_Float1, sEvent.fEventFloats1);
		ActivateOutput(&m_actInfo, EOP_Float2, sEvent.fEventFloats2);
		ActivateOutput(&m_actInfo, EOP_Vector1, sEvent.vEventVecs1);
		ActivateOutput(&m_actInfo, EOP_Vector2, sEvent.vEventVecs2);
		ActivateOutput(&m_actInfo, EOP_EntityId1, sEvent.nEntityId1);
	}

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		if (event == eFE_Initialize)
		{
			m_actInfo = *pActInfo;
		}

		if (event == eFE_SetEntityId)
		{
			if (pActInfo->pEntity)
			{
				m_nEventSynchronizerId = pActInfo->pEntity->GetId();
				IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(m_nEventSynchronizerId);
				if (pGameObject)
				{
					CEventSynchronizer* pSynchronizer = (CEventSynchronizer*)pGameObject->QueryExtension("EventSynchronizer");
					if (pSynchronizer)
					{
						pSynchronizer->RegisterEventListener(this);
					}
				}
			}
			else
			{
				m_nEventSynchronizerId = 0;
			}
		}

		if (eFE_Activate == event && IsPortActive(pActInfo, EIP_Listen))
		{
			IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(m_nEventSynchronizerId);
			if (pGameObject)
			{
				CEventSynchronizer* pSynchronizer = (CEventSynchronizer*)pGameObject->QueryExtension("EventSynchronizer");
				if (pSynchronizer)
				{
					if (GetPortBool(pActInfo, EIP_Listen))
					{
						pSynchronizer->RegisterEventListener(this);
					}
					else
					{
						pSynchronizer->UnregisterEventListener(this);
					}
				}
			}
			//IVehicle* pVehicle = 

		}
	}

	SActivationInfo m_actInfo;
	EntityId m_nEventSynchronizerId;
};

REGISTER_FLOW_NODE("EventSynchronizer:EventSender", CEventSynchronizer_SendEventNode);
REGISTER_FLOW_NODE("EventSynchronizer:EventReceiver", CEventSynchronizer_ListenEventNode);


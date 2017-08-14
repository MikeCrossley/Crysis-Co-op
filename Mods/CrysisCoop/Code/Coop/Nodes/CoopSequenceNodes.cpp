#include "StdAfx.h"
#include <Nodes/G2FlowBaseNode.h>

#include "IGameObject.h"
#include "Coop/Entities/SequenceSynchronizer.h"

#include <ICryAnimation.h>
#include <IViewSystem.h>
#include <IMovieSystem.h>

CSequenceSynchronizer* GetSequenceSynchronizer()
{
	std::set<IEntityClass*> classNames;

	IEntityIt* iter = gEnv->pEntitySystem->GetEntityIterator();
	while (!iter->IsEnd())
	{
		if (IEntity* pEnt = iter->Next())
		{
			IEntityClass* pEntityClass = pEnt->GetClass();
			IEntityClass* pSequenceClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("SequenceSynchronizer");

			if (pEntityClass == pSequenceClass)
			{
				if (IGameObject* pGameObject = gEnv->pGame->GetIGameFramework()->GetGameObject(pEnt->GetId()))
				{
					return (CSequenceSynchronizer*)pGameObject->QueryExtension("SequenceSynchronizer");
				}
			}
		}
	}

	return NULL;
}

class CFlowPlaySequence : public CFlowBaseNode, public IMovieListener
{
	enum INPUTS
	{
		EIP_Sequence = 0,
		EIP_Trigger,
		EIP_Stop,
		EIP_BreakOnStop,
		EIP_BlendPosSpeed,
		EIP_BlendRotSpeed,
		EIP_PerformBlendOut,
		EIP_StartTime,
	};

	enum OUTPUTS
	{
		EOP_Started = 0,
		EOP_Done,
		EOP_Finished,
		EOP_Aborted,
	};

public:
	CFlowPlaySequence(SActivationInfo * pActInfo)
	{
		m_pSequenceSynchronizer = NULL;
		m_pSeq = 0;
		m_actInfo = *pActInfo;
		m_bPlaying = false;
	};

	virtual void GetMemoryStatistics(ICrySizer * s)
	{
		s->Add(*this);
	}

	~CFlowPlaySequence()
	{
		if (m_pSeq)
		{
			IMovieSystem *movieSys = gEnv->pMovieSystem;
			if (movieSys != 0)
				movieSys->RemoveMovieListener(m_pSeq, this);
		}
	};

	IFlowNodePtr Clone(SActivationInfo * pActInfo)
	{
		return new CFlowPlaySequence(pActInfo);
	}

	virtual void GetConfiguration(SFlowNodeConfig &config)
	{
		static const SInputPortConfig in_config[] = {
			InputPortConfig<string>("seq_Sequence_File",_HELP("Name of the Sequence"), _HELP("Sequence")),
			InputPortConfig_Void("Trigger",_HELP("Starts the sequence"), _HELP("StartTrigger")),
			InputPortConfig_Void("Stop", _HELP("Stops the sequence"), _HELP("StopTrigger")),
			InputPortConfig<bool>("BreakOnStop", false, _HELP("If set to 'true', stopping the sequence doesn't jump to end.")),
			InputPortConfig<float>("BlendPosSpeed", 0.0f, _HELP("Speed at which position gets blended into animation.")),
			InputPortConfig<float>("BlendRotSpeed", 0.0f, _HELP("Speed at which rotation gets blended into animation.")),
			InputPortConfig<bool>("PerformBlendOut", false, _HELP("If set to 'true' the cutscene will blend out after it has finished to the new view (please reposition player when 'Started' happens).")),
			InputPortConfig<float>("StartTime", 0.0f, _HELP("Start time from which the sequence'll begin playing.")),
			{ 0 }
		};
		static const SOutputPortConfig out_config[] = {
			OutputPortConfig_Void("Started", _HELP("Triggered when sequence is started")),
			OutputPortConfig_Void("Done", _HELP("Triggered when sequence is stopped [either via StopTrigger or aborted via Code]"), _HELP("Done")),
			OutputPortConfig_Void("Finished", _HELP("Triggered when sequence finished normally")),
			OutputPortConfig_Void("Aborted", _HELP("Triggered when sequence is aborted (Stopped and BreakOnStop true or via Code)")),
			{ 0 }
		};
		config.sDescription = _HELP("Plays a Trackview Sequence");
		config.pInputPorts = in_config;
		config.pOutputPorts = out_config;
		config.SetCategory(EFLN_APPROVED);
	}

	virtual void ProcessEvent(EFlowEvent event, SActivationInfo *pActInfo)
	{
		switch (event)
		{
		case eFE_Activate:
		{
			if (IsPortActive(pActInfo, EIP_Stop))
			{
				bool wasPlaying(m_bPlaying);
				const bool bLeaveTime = GetPortBool(pActInfo, EIP_BreakOnStop);
				StopSequence(pActInfo, false, true, bLeaveTime);
				// we trigger manually, as we unregister before the callback happens
				if (wasPlaying)
				{
					ActivateOutput(pActInfo, EOP_Done, true); // signal we're done
					ActivateOutput(pActInfo, EOP_Aborted, true); // signal it's been aborted
				}
			}
			if (IsPortActive(pActInfo, EIP_Trigger))
			{
				StartSequence(pActInfo, GetPortFloat(pActInfo, EIP_StartTime));
			}
			break;
		}

		case eFE_Initialize:
		{
			StopSequence(pActInfo);
		}
		break;
		};
	};

	virtual void OnMovieEvent(IMovieListener::EMovieEvent event, IAnimSequence* pSequence) {
		// CryLogAlways("CPlaySequence_Node::OnMovieEvent event=%d  seq=%p", event, pSequence);
		if (event == IMovieListener::MOVIE_EVENT_STOP)
		{
			ActivateOutput(&m_actInfo, EOP_Done, true);
			ActivateOutput(&m_actInfo, EOP_Finished, true);
			m_bPlaying = false;
		}
		else if (event == IMovieListener::MOVIE_EVENT_ABORTED)
		{
			ActivateOutput(&m_actInfo, EOP_Done, true);
			ActivateOutput(&m_actInfo, EOP_Aborted, true);
			m_bPlaying = false;
		}
	}

protected:

	void StopSequence(SActivationInfo* pActInfo, bool bUnRegisterOnly = false, bool bAbort = false, bool bLeaveTime = false)
	{
		if (!m_pSequenceSynchronizer)
			m_pSequenceSynchronizer = GetSequenceSynchronizer();

		if (!m_pSequenceSynchronizer)
		{
			CryLogAlways("[CFlowPlaySequence] Sequence Synchronizer Not Found!");
			return;
		}

		if (gEnv->bServer)
		{
			string sSequence = GetPortString(pActInfo, EIP_Sequence);
			float fStartTime = GetPortFloat(pActInfo, EIP_StartTime);
			bool bBreakOnStop = GetPortBool(pActInfo, EIP_BreakOnStop);

			m_pSequenceSynchronizer->StopSeqeunce(sSequence, fStartTime, bBreakOnStop);
		}

		IMovieSystem *movieSys = gEnv->pMovieSystem;
		if (!movieSys)
			return;

		if (m_pSeq)
		{
			// we remove first to NOT get notified!
			movieSys->RemoveMovieListener(m_pSeq, this);
			if (!bUnRegisterOnly && movieSys->IsPlaying(m_pSeq))
			{
				if (bAbort) // stops sequence and leaves it at current position
					movieSys->AbortSequence(m_pSeq, bLeaveTime);
				else
					movieSys->StopSequence(m_pSeq);
			}
			m_pSeq = 0;
		}
		m_bPlaying = false;
	}

	void StartSequence(SActivationInfo* pActInfo, float curTime = 0.0f, bool bNotifyStarted = true)
	{
		if (!m_pSequenceSynchronizer)
			m_pSequenceSynchronizer = GetSequenceSynchronizer();

		if (!m_pSequenceSynchronizer)
		{
			CryLogAlways("[CFlowPlaySequence] Sequence Synchronizer Not Found!");
			return;
		}

		if (gEnv->bServer)
		{
			string sSequence = GetPortString(pActInfo, EIP_Sequence);
			float fStartTime = GetPortFloat(pActInfo, EIP_StartTime);
			bool bBreakOnStop = GetPortBool(pActInfo, EIP_BreakOnStop);

			m_pSequenceSynchronizer->PlaySequence(sSequence, fStartTime, bBreakOnStop);
		}

		IMovieSystem *movieSys = gEnv->pMovieSystem;
		if (!movieSys)
			return;

		if (m_pSeq)
		{
			movieSys->RemoveMovieListener(m_pSeq, this);
			movieSys->StopSequence(m_pSeq);
			m_pSeq = 0;
			m_bPlaying = false;
		}

		m_pSeq = movieSys->FindSequence(GetPortString(pActInfo, EIP_Sequence));

		if (m_pSeq)
		{
			m_bPlaying = true;
			movieSys->AddMovieListener(m_pSeq, this);
			movieSys->PlaySequence(m_pSeq, true);

			if (curTime < m_pSeq->GetTimeRange().start)
				curTime = m_pSeq->GetTimeRange().start;
			else if (curTime > m_pSeq->GetTimeRange().end)
				curTime = m_pSeq->GetTimeRange().end;

			movieSys->SetPlayingTime(m_pSeq, curTime);

			// set blend parameters
			IViewSystem* pViewSystem = gEnv->pGame->GetIGameFramework()->GetIViewSystem();
			if (pViewSystem)
			{
				float blendPosSpeed = GetPortFloat(pActInfo, EIP_BlendPosSpeed);
				float blendRotSpeed = GetPortFloat(pActInfo, EIP_BlendRotSpeed);
				bool performBlendOut = GetPortBool(pActInfo, EIP_PerformBlendOut);
				pViewSystem->SetBlendParams(blendPosSpeed, blendRotSpeed, performBlendOut);
			}

			if (bNotifyStarted)
				ActivateOutput(pActInfo, EOP_Started, true);
		}
		else
		{
			GameWarning("[CFlowPlaySequence] Animations:PlaySequence: Sequence \"%s\" not found", GetPortString(pActInfo, 0).c_str());
		}
	}
protected:
	_smart_ptr<IAnimSequence> m_pSeq;
	SActivationInfo m_actInfo;
	bool m_bPlaying;

	CSequenceSynchronizer* m_pSequenceSynchronizer;
};

REGISTER_FLOW_NODE("Coop:PlaySequence", CFlowPlaySequence);

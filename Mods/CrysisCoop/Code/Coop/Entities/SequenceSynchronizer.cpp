#include <StdAfx.h>
#include "SequenceSynchronizer.h"

#include <ICryAnimation.h>
#include <IViewSystem.h>
#include <IMovieSystem.h>

CSequenceSynchronizer::CSequenceSynchronizer() :
	m_bInitialized(false)
{
}

CSequenceSynchronizer::~CSequenceSynchronizer()
{
}

bool CSequenceSynchronizer::Init(IGameObject *pGameObject)
{
	SetGameObject(pGameObject);

	if (!GetGameObject()->BindToNetwork())
		return false;

	return true;
}

void CSequenceSynchronizer::PostInit(IGameObject *pGameObject)
{
	m_bInitialized = true;
}

void CSequenceSynchronizer::Release()
{
	delete this;
}

void CSequenceSynchronizer::PlaySequence(string sSequence, float fStartTime, bool bBreakOnStop)
{
	if (!m_bInitialized || !gEnv->bServer) return;

	CryLogAlways("[CSequenceSynchronizer::PlaySequence] %s", sSequence);

	GetGameObject()->InvokeRMI(ClTrackviewSequence(), STrackviewSeqParams(true, sSequence, fStartTime, bBreakOnStop), eRMI_ToAllClients | eRMI_NoLocalCalls);
}

void CSequenceSynchronizer::StopSeqeunce(string sSequence, float fStartTime, bool bBreakOnStop)
{
	if (!m_bInitialized || !gEnv->bServer) return;

	CryLogAlways("[CSequenceSynchronizer::StopSequence] %s", sSequence);

	GetGameObject()->InvokeRMI(ClTrackviewSequence(), STrackviewSeqParams(false, sSequence, fStartTime, bBreakOnStop), eRMI_ToAllClients | eRMI_NoLocalCalls);
}

IMPLEMENT_RMI(CSequenceSynchronizer, ClTrackviewSequence)
{
	bool bStart = params.bStart;
	string sSequence = params.sSequence;
	float fStartTime = params.fStartTime;
	bool bLeaveTime = params.bBreakOnStop;

	IMovieSystem *pMovieSystem = gEnv->pMovieSystem;

	if (bStart)
	{
		IAnimSequence* pSeq = pMovieSystem->FindSequence(sSequence);

		if (pSeq)
		{
			CryLogAlways("Client Started Sequence");
			pMovieSystem->PlaySequence(pSeq, true);

			if (fStartTime < pSeq->GetTimeRange().start)
				fStartTime = pSeq->GetTimeRange().start;
			else if (fStartTime > pSeq->GetTimeRange().end)
				fStartTime = pSeq->GetTimeRange().end;

			pMovieSystem->SetPlayingTime(pSeq, fStartTime);


		}
	}
	else
	{
		IAnimSequence* pSeq = pMovieSystem->FindSequence(sSequence);

		if (pSeq)
		{
			if (pMovieSystem->IsPlaying(pSeq))
			{
				CryLogAlways("Client Stopped Sequence");
				pMovieSystem->AbortSequence(pSeq, bLeaveTime);
			}
		}

	}

	return true;
}
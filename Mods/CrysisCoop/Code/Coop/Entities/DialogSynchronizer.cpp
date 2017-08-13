#include <StdAfx.h>
#include "DialogSynchronizer.h"
#include <Nodes/G2FlowBaseNode.h>

#include "../CoopSystem.h"

#include "IActorSystem.h"
#include "Player.h"

CDialogSynchronizer::CDialogSynchronizer() :
	m_pDialogPlayer(NULL)
{
}

CDialogSynchronizer::~CDialogSynchronizer()
{
}

bool CDialogSynchronizer::Init(IGameObject *pGameObject)
{
	SetGameObject(pGameObject);

	m_pDialogPlayer = new CDialogPlayer();

	if (!GetGameObject()->BindToNetwork())
		return false;

	return true;
}

void CDialogSynchronizer::Release()
{
	SAFE_DELETE(m_pDialogPlayer);
	delete this;
}

bool CDialogSynchronizer::PlayDialog(string sDialog, EntityId* pActors, int nAIInterrupt, float fAwareDist, float fAwareAngle, float fAwareTimeOut, int nFlags, int nFromLine)
{
	if (!m_pDialogPlayer) return false;

	CryLogAlways("[CDialogSynchronizer::PlayDialog] %s", sDialog);
	
	if (gEnv->bServer)
		GetGameObject()->InvokeRMI(ClPlayDialog(), SDialogParams(sDialog, pActors, nAIInterrupt, fAwareDist, fAwareAngle, fAwareTimeOut, nFlags, nFromLine), eRMI_ToAllClients | eRMI_NoLocalCalls);
	
	if (gEnv->pSystem->IsDedicated()) return false;

	return m_pDialogPlayer->PlayDialog(sDialog, pActors, nAIInterrupt, fAwareDist, fAwareAngle, fAwareTimeOut, nFlags, nFromLine);
}

bool CDialogSynchronizer::StopDialog()
{
	if (!m_pDialogPlayer) return false;

	CryLogAlways("[CDialogSynchronizer::StopDialog]");

	if (gEnv->bServer)
		GetGameObject()->InvokeRMI(ClStopDialog(), SDialogStopParams(true), eRMI_ToAllClients | eRMI_NoLocalCalls);

	if (gEnv->pSystem->IsDedicated()) return false;

	return m_pDialogPlayer->StopDialog();
}


IMPLEMENT_RMI(CDialogSynchronizer, ClPlayDialog)
{
	EntityId* pActors = new EntityId[8];
	pActors[0] = params.nActor1;
	pActors[1] = params.nActor2;
	pActors[2] = params.nActor3;
	pActors[3] = params.nActor4;
	pActors[4] = params.nActor5;
	pActors[5] = params.nActor6;
	pActors[6] = params.nActor7;
	pActors[7] = params.nActor8;

	// TODO :: Smarter way of determining the slot the local player is using 
	for (int i = 0; i < 8; i++)
	{
		IActor* pActor = gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor(pActors[i]);
		if (pActors[i] == 0 || pActor->IsPlayer())
		{
			pActors[i] = gEnv->pGame->GetIGameFramework()->GetClientActorId();
		}
	}

	PlayDialog(params.sDialog, pActors, params.nAIInterrupt, params.fAwareDist, params.fAwareAngle, params.fAwareTimeOut, params.nFlags, params.nFromLine);

	SAFE_DELETE_ARRAY(pActors);
	return true;
}

IMPLEMENT_RMI(CDialogSynchronizer, ClStopDialog)
{
	StopDialog();

	return true;
}


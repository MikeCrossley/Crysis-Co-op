#include <StdAfx.h>
#include "CoopReadability.h"
#include "Actor.h"

#include <Coop/CoopSystem.h>
#include <Coop/Sound/CoopSoundSystem.h>

CCoopReadability::CCoopReadability()
{
	if (gEnv->pSoundSystem)
		gEnv->pSoundSystem->AddEventListener(this, false);
}

CCoopReadability::~CCoopReadability()
{
	if (gEnv->pSoundSystem)
		gEnv->pSoundSystem->RemoveEventListener(this);
}

void CCoopReadability::Initialize()
{
}

// Summary:
//	Listener for all sounds within the world, used for syncing AI sounds
void CCoopReadability::OnSoundSystemEvent( ESoundSystemCallbackEvent event,ISound *pSound )
{
	if (event == SOUNDSYSTEM_EVENT_ON_START && gEnv->bServer && !gEnv->pSystem->IsDedicated())
		SendSoundToClosestActor(pSound);
}

// Summary:
//	Direct sound sending for dedicated servesr
void CCoopReadability::SendSoundToActor(ISound* pSound, EntityId actorId)
{
	if (!pSound)
		return;

	ESoundSemantic sem = pSound->GetSemantic();

	if (sem == eSoundSemantic_AI_Readability)
	{
		if (CActor* pActor = static_cast<CActor*>(gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor(actorId)))
		{
			if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
				CryLogAlways("[CCoopReadability::SendSoundToActor] Actor Sound %s: for actor with Id: %d", pSound->GetName(), actorId);

			CActor::PlayReadabilitySoundParams params;
			params.sSoundEventName = pSound->GetName();
			// params.nSoundFlags = pSound->GetFlags();
			// params.vDirection = pSound->GetDirection();
			// params.vOffset = pSound->GetPosition() - pClosestActor->GetEntity()->GetPos();
			// params.nSemantic = pSound->GetSemantic();
			pActor->GetGameObject()->InvokeRMI(CActor::ClPlayReadabilitySound(), params, eRMI_ToAllClients | eRMI_NoLocalCalls);
		}
	}
}

// Summary:
//	Worky aroundy support for getting sounds on listen servers
bool CCoopReadability::SendSoundToClosestActor(ISound* pSound)
{
    if (!pSound)
        return false; // fag.

	ESoundSemantic sem = pSound->GetSemantic();
	if (sem == eSoundSemantic_AI_Readability)
	{
		CActor* pClosestActor = NULL;
		float fClosestDistance = 66666.6f;
 
		IActorIteratorPtr it = g_pGame->GetIGameFramework()->GetIActorSystem()->CreateActorIterator();
		while (CActor* pActor = static_cast<CActor*>(it->Next()))
		{
			if (!pActor->IsPlayer() && pActor->GetHealth() > 0)
			{
 
				float fDistance = (pActor->GetEntity()->GetPos() - pSound->GetPosition()).GetLengthSquared();
				if (fDistance < fClosestDistance)
				{
					pClosestActor = pActor;
					fClosestDistance = fDistance;
				}
			}
		}
 
		if (pClosestActor)
		{
			if (CCoopSystem::GetInstance()->GetDebugLog() > 1)
				CryLogAlways("[CCoopReadability::SendSoundToClosestActor] Actor Sound %s: for actor with Id: %d", pSound->GetName(), pClosestActor->GetEntity()->GetId());

			CActor::PlayReadabilitySoundParams params;
			params.sSoundEventName = pSound->GetName();
		   // params.nSoundFlags = pSound->GetFlags();
		   // params.vDirection = pSound->GetDirection();
		   // params.vOffset = pSound->GetPosition() - pClosestActor->GetEntity()->GetPos();
		   // params.nSemantic = pSound->GetSemantic();
			pClosestActor->GetGameObject()->InvokeRMI(CActor::ClPlayReadabilitySound(), params, eRMI_ToAllClients | eRMI_NoLocalCalls);
			return true;
		}
	}
    return false;
}
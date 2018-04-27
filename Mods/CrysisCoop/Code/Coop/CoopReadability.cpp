#include <StdAfx.h>
#include "CoopReadability.h"
#include "Actor.h"

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
	if (event == SOUNDSYSTEM_EVENT_ON_START && gEnv->bServer)
		SendSoundToClosestActor(pSound);
}

bool CCoopReadability::SendSoundToClosestActor(ISound* pSound)
{
    if (!pSound)
        return false; // fag.

	ESoundSemantic sem = pSound->GetSemantic();
	if (sem == eSoundSemantic_AI_Readability)
	{
		CryLogAlways("Actor Sound %s:", pSound->GetName());

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
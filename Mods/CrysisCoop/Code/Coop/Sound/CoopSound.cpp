#include <StdAfx.h>
#include "CoopSound.h"

#include <Coop/CoopSystem.h>
#include <Coop/Sound/CoopSoundSystem.h>

void CCoopSound::Play(float fVolumeScale, bool bForceActiveState, bool bSetRatio, IEntitySoundProxy *pEntitySoundProxy) 
{
	// Send sound through the system listener
	// Really we could actually use this to call on actors directly now?
	CCoopSystem::GetInstance()->GetSoundSystem()->OnEvent(ESoundSystemCallbackEvent::SOUNDSYSTEM_EVENT_ON_START, this);
}

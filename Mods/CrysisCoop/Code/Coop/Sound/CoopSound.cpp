#include <StdAfx.h>
#include "CoopSound.h"

#include <Coop/CoopSystem.h>
#include <Coop/Sound/CoopSoundSystem.h>

void CCoopSound::Play(float fVolumeScale, bool bForceActiveState, bool bSetRatio, IEntitySoundProxy *pEntitySoundProxy) 
{
	// Send sound through the system listener
	// Really we could actually use this to call on actors directly now?
	this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_START);
	this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_STOP);

	// Until we implement proper sound timing we need to get rid of the sound
	delete this;
}


void CCoopSound::OnEvent(ESoundCallbackEvent event)
{
	for (auto listener : m_lSoundEventListener)
	{
		listener->OnSoundEvent(event, this);
	}

	// Tell the Soundsystem about this
	CCoopSystem::GetInstance()->GetSoundSystem()->OnEvent((ESoundSystemCallbackEvent)event, this);
}
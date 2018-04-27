#include <StdAfx.h>
#include "CoopSoundSystem.h"

#include <Coop/Sound/CoopSound.h>

bool CCoopSoundSystem::Init()
{
	return true;
}

void CCoopSoundSystem::AddEventListener(ISoundSystemEventListener *pListener, bool bOnlyVoiceSounds) 
{
	m_lSoundSystemEventListener.push_back(pListener);
}

void CCoopSoundSystem::RemoveEventListener(ISoundSystemEventListener *pListener) 
{
	m_lSoundSystemEventListener.remove(pListener);
}

ISound* CCoopSoundSystem::CreateSound(const char *sGroupAndSoundName, uint32 nFlags)
{
	CCoopSound* pSound = new CCoopSound();
	pSound->SetName(sGroupAndSoundName);

	return pSound;
}

void CCoopSoundSystem::OnEvent(ESoundSystemCallbackEvent event, ISound *pSound)
{
	if (!pSound)
		return;

	// Send event to all listeners
	for (auto listener : m_lSoundSystemEventListener)
	{
		listener->OnSoundSystemEvent(event, pSound);
	}
}
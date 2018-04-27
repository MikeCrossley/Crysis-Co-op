#include <StdAfx.h>
#include "CoopSoundSystem.h"
#include <Coop\CoopSystem.h>
#include <Coop/Sound/CoopSound.h>

CCoopSoundSystem::CCoopSoundSystem()
	: m_lSoundSystemEventListener()
{
	for (int i = 0; i < COOP_SOUND_SYSTEM_MAXIMUM_SOUNDS; ++i)
	{
		m_pSounds[i] = CCoopSound();
		m_nSoundUsages[i] = 0;
	}
}
CCoopSoundSystem::~CCoopSoundSystem()
{
}

bool CCoopSoundSystem::Init()
{
	return true;
}

ISound* CCoopSoundSystem::GetSound(tSoundID nSoundID) const 
{
	int nIndex = (nSoundID & 0x0000FFFF) - 1;
	if (nIndex >= COOP_SOUND_SYSTEM_MAXIMUM_SOUNDS)
	{
		CryLogAlways("[CCoopSoundSystem] Invalid sound identifier (out of bounds index %d).", nIndex);
		return nullptr;
	}

	return (m_pSounds[nIndex].m_nIdentifier == nSoundID) ? (ISound*)(&m_pSounds[nIndex]) : nullptr; 
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
	if (CCoopSound* pSound = this->ReserveSound())
	{
		pSound->SetName(sGroupAndSoundName);
		pSound->SetFlags(nFlags);
		if(CCoopSystem::GetInstance()->GetDebugLog() == 2)
			CryLogAlways("[CCoopSoundSystem] Reserved sound %s to slot %d, reuse counter %d.", pSound->m_sSoundName.c_str(), (pSound->m_nIdentifier & 0xFFFF) - 1, (pSound->m_nIdentifier >> 16));
		return pSound;
	}
	CryLogAlways("[CCoopSoundSystem] Too many sound instances.");
	return nullptr;
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

CCoopSound* CCoopSoundSystem::ReserveSound()
{
	for (int i = 0; i < COOP_SOUND_SYSTEM_MAXIMUM_SOUNDS; ++i)
	{
		if (m_pSounds[i].m_nIdentifier == 0)
		{
			m_pSounds[i].m_nIdentifier = (((m_nSoundUsages[i]++) & 0xFFFF) << 16) | (i + 1); // Usage counter works as a 16-bit salt value.
			return &m_pSounds[i];
		}
	}

	return nullptr;
}

void CCoopSoundSystem::OnSoundReleased(CCoopSound& sound)
{
	if (CCoopSystem::GetInstance()->GetDebugLog() == 2)
		CryLogAlways("[CCoopSoundSystem] Releasing sound %s from slot %d, reuse counter %d.", sound.m_sSoundName.c_str(), (sound.m_nIdentifier & 0xFFFF) - 1, (sound.m_nIdentifier >> 16));
	sound.Reset();
	//sound.m_
}
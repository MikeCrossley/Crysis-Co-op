#include <StdAfx.h>
#include "CoopSound.h"

#include <Coop/CoopSystem.h>
#include <Coop/Sound/CoopSoundSystem.h>

CCoopSound::CCoopSound()
	: m_nIdentifier(0)
	, m_nReferenceCount(0)
	, m_lSoundEventListener()
	, m_nSoundSemantic(eSoundSemantic_None)
	, m_sSoundName()
{

}

CCoopSound::~CCoopSound()
{

}

void CCoopSound::Play(float fVolumeScale, bool bForceActiveState, bool bSetRatio, IEntitySoundProxy *pEntitySoundProxy)
{
	this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_START);
	this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_STOP);
}

void CCoopSound::Stop(ESoundStopMode eStopMode)
{
}


void CCoopSound::OnEvent(ESoundCallbackEvent event)
{
	// Prevent game from crashing on looping sounds
	if ((m_nFlags & FLAG_SOUND_LOOP) == FLAG_SOUND_LOOP)
		return;


	if (GetSemantic() == ESoundSemantic::eSoundSemantic_AI_Readability)
	{
		for (auto listener : m_lSoundEventListener)
		{
			listener->OnSoundEvent(event, this);
		}
	}

	// Tell the Soundsystem about this
	CCoopSystem::GetInstance()->GetSoundSystem()->OnEvent((ESoundSystemCallbackEvent)event, this);
}

int	CCoopSound::AddRef()
{
	int nReferenceCount = CryInterlockedIncrement(&m_nReferenceCount);
	return nReferenceCount;
}

int	CCoopSound::Release() 
{
	int nReferenceCount = CryInterlockedDecrement(&m_nReferenceCount);
	if (nReferenceCount <= 0)
	{
		CCoopSystem::GetInstance()->GetSoundSystem()->OnSoundReleased(*this);
	}
	return nReferenceCount;
}

void CCoopSound::Reset()
{
	this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_STOP);

	m_nIdentifier = 0;
	m_nReferenceCount = 0;
	m_nSoundSemantic = ESoundSemantic::eSoundSemantic_None;
	m_lSoundEventListener.clear();
	m_sSoundName = nullptr;
	m_nFlags = 0;
}
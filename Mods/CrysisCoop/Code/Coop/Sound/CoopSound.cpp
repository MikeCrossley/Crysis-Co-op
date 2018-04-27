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


void CCoopSound::OnEvent(ESoundCallbackEvent event)
{
	for (std::list<ISoundEventListener*>::iterator listener = m_lSoundEventListener.begin(); listener != m_lSoundEventListener.end(); ++listener)
	{
		(*listener)->OnSoundEvent(event, this);
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
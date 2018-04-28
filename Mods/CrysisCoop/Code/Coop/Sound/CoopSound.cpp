#include <StdAfx.h>
#include "CoopSound.h"

#include <Coop/CoopSystem.h>
#include <Coop/Sound/CoopSoundSystem.h>

CCoopSound::CCoopSound()
	: m_nIdentifier(0)
	, m_nReferenceCount(0)
	, m_nSoundSemantic(eSoundSemantic_None)
	, m_sSoundName()
	, m_fTimeLeft(0.1f)
{

}

CCoopSound::~CCoopSound()
{

}

void CCoopSound::Play(float fVolumeScale, bool bForceActiveState, bool bSetRatio, IEntitySoundProxy *pEntitySoundProxy)
{
	this->AddRef();
	this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_START);
	m_fTimeLeft = 0.1f;

	if (GetSemantic() == ESoundSemantic::eSoundSemantic_AI_Readability)
	{
		if (pEntitySoundProxy && pEntitySoundProxy->GetEntity())
		{
			CCoopSystem::GetInstance()->GetReadability()->SendSoundToActor(this, pEntitySoundProxy->GetEntity()->GetId());
		}
	}
}

void CCoopSound::Update(float fFrameTime)
{
	if (m_fTimeLeft <= 0.f)
	{
		this->OnEvent(ESoundCallbackEvent::SOUND_EVENT_ON_STOP);
		this->Release();
	}
	else
	{
		m_fTimeLeft -= fFrameTime;
	}
}

void CCoopSound::Stop(ESoundStopMode eStopMode)
{
	m_fTimeLeft = 0.f;
}

void CCoopSound::AddEventListener(ISoundEventListener *pListener, const char *sWho)
{ 
	// We only care about AI readability
	if (strcmp(sWho, "AIReadibilityManager") == 0)
	{
		TEventListenerInfoVector::iterator ItEnd = m_listeners.end();
		for (TEventListenerInfoVector::iterator it = m_listeners.begin(); it != ItEnd; ++it)
		{
			if (it->pListener == pListener)
				return;
		}

		SSoundEventListenerInfo ListenerInfo;
		ListenerInfo.pListener = pListener;
		m_listeners.push_back(ListenerInfo);
	}
}

void CCoopSound::RemoveEventListener(ISoundEventListener *pListener)
{ 
	TEventListenerInfoVector::iterator ItEnd = m_listenersToBeRemoved.end();
	for (TEventListenerInfoVector::iterator it = m_listenersToBeRemoved.begin(); it != ItEnd; ++it)
	{
		if (it->pListener == pListener)
			return;
	}

	SSoundEventListenerInfo ListenerInfo;
	ListenerInfo.pListener = pListener;
	ListenerInfo.sWho[0] = 'R';

	m_listenersToBeRemoved.push_back(ListenerInfo);
}

void CCoopSound::OnEvent(ESoundCallbackEvent event)
{
	// remove accumulated listeners that unregistered so far
	TEventListenerInfoVector::iterator ItREnd = m_listenersToBeRemoved.end();
	for (TEventListenerInfoVector::iterator ItR = m_listenersToBeRemoved.begin(); ItR != ItREnd; ++ItR)
	{
		//SSoundEventListenerInfo* pListenerInfo = (ItR);
		//stl::binary_erase(m_listeners, *pListenerInfo );
		TEventListenerInfoVector::iterator ItLEnd = m_listeners.end();
		for (TEventListenerInfoVector::iterator itL = m_listeners.begin(); itL != ItLEnd; ++itL)
		{
			if (itL->pListener == ItR->pListener)
			{
				m_listeners.erase(itL);
				break;
			}
		}
	}

	// send the event to listeners
	// for now work on copy because sending SoundEvent might end up in sending another event and that
	// would remove listener, so trashing the m_listener list and iterators. TODO this should be fixed
	// in a clean fashion in a different change
	if (!m_listeners.empty())
	{
		m_listenersTemp = m_listeners;
		//m_listenersTemp.reserve(m_listeners.size());
		//m_listenersTemp.assign(m_listeners.begin(), m_listeners.end());

		// first run through to call event listeners
		TEventListenerInfoVector::const_iterator ItEnd2 = m_listenersTemp.end();
		for (TEventListenerInfoVector::const_iterator It2 = m_listenersTemp.begin(); It2 != ItEnd2; ++It2)
		{
			It2->pListener->OnSoundEvent(event, this);
		}
	}

	// Tell the Soundsystem about this
	CCoopSystem::GetInstance()->GetSoundSystem()->OnEvent((ESoundSystemCallbackEvent)event, this);

	m_listenersTemp.resize(0);
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
	m_nIdentifier = 0;
	m_nReferenceCount = 0;
	m_nSoundSemantic = ESoundSemantic::eSoundSemantic_None;
	m_sSoundName = nullptr;

	if (!m_listeners.empty())
	{
		OnEvent(SOUND_EVENT_ON_STOP);
		m_listeners.clear();
	}

	m_listenersToBeRemoved.resize(0);

	m_nFlags = 0;
}
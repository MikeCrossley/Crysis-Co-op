////////////////////////////////////////////////////////////////////////////
//
//  Crytek Engine Source File.
//  Copyright (C), Crytek Studios, 2006.
// -------------------------------------------------------------------------
//  File name:   DialogActorContext.cpp
//  Version:     v1.00
//  Created:     07/07/2006 by AlexL
//  Compilers:   Visual Studio.NET
//  Description: Dialog System
// -------------------------------------------------------------------------
//  History:
//
////////////////////////////////////////////////////////////////////////////
#include "StdAfx.h"
#include "DialogActorContext.h"
#include "DialogSession.h"
#include "DialogCommon.h"
#include "ICryAnimation.h"
#include "IFacialAnimation.h"
#include "StringUtils.h"
#include "IMovementController.h"
//#include "ILocalizationManager.h"
//#include "IAIObject.h"
//#include "IAIActor.h"

#include "Cry_Camera.h"




static const float LOOKAT_TIMEOUT   = 1.0f;
static const float ANIM_TIMEOUT     = 1.0f;
static const float SOUND_TIMEOUT    = 1.0f;   
static const float PLAYER_CHECKTIME = 0.2f;    // check the player every 0.2 seconds

static const uint32 INVALID_FACIAL_CHANNEL_ID = ~0;

// returns ptr to static string buffer.
const char* CDialogActorContext::GetSoundKey(const string& soundName)
{
	static string buf;
	const char prefix[] = "Languages/dialog/";
	const size_t prefixLen = sizeof(prefix)-1; // minus terminating \0

	// check if it already starts Languages/dialog. then replace it
	if (strnicmp(soundName.c_str(), prefix, prefixLen) == 0)
	{
		buf.assign (soundName.c_str()+prefixLen);
	}
	else
	{
		buf.assign (soundName);
	}
	PathUtil::RemoveExtension(buf);
	return buf.c_str();
}

// returns ptr to static string buffer.
const char* CDialogActorContext::FullSoundName(const string& soundName, bool bWav)
{
	static string buf;
	const char* prefix = "Languages/dialog/";

	// check if it already starts with full path
	if (CryStringUtils::stristr(soundName.c_str(), prefix) == soundName.c_str())
	{
		buf = soundName;
	}
	else 
	{
		buf  = prefix;
		buf += soundName;
	}
	PathUtil::RemoveExtension(buf);
	if (bWav)
		buf += ".wav";
	return buf.c_str();
}

////////////////////////////////////////////////////////////////////////////
CDialogActorContext::CDialogActorContext(CDialogSession* pSession, CDialogScript::TActorID actorID)
{
	m_pSession   = pSession;
	m_actorID    = actorID;
	m_entityID   = pSession->GetActorEntityId(m_actorID);
	IEntity* pEntity = gEnv->pEntitySystem->GetEntity(m_entityID);
	const char* debugName = pEntity ? pEntity->GetName() : "<no entity>";
	m_pIActor = gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor(m_entityID);
	m_bIsLocalPlayer = m_pIActor != 0 && gEnv->pGame->GetIGameFramework()->GetClientActor() == m_pIActor;
	ResetState();
	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::ctor: %s 0x%p actorID=%d entity=%s entityId=%u",
		m_pSession->GetDebugName(), this, m_actorID, debugName, m_entityID);
}

////////////////////////////////////////////////////////////////////////////
CDialogActorContext::~CDialogActorContext()
{
	StopSound();
	CancelCurrent();
	IEntity* pEntity = gEnv->pEntitySystem->GetEntity(m_entityID);
	const char* debugName = pEntity ? pEntity->GetName() : "<no entity>";
	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::dtor: %s 0x%p actorID=%d entity=%s entityId=%d",
		m_pSession->GetDebugName(), this, m_actorID, debugName, m_entityID);
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::ResetState()
{
	m_pCurLine = 0;
	m_pAGState = 0;
	m_queryID = 0;
	m_bAnimStarted = false;
	m_bAnimUseAGSignal = false;
	m_bAnimUseEP = false;
	m_lookAtActorID = CDialogScript::NO_ACTOR_ID;
	m_stickyLookAtActorID = CDialogScript::NO_ACTOR_ID;
	m_bLookAtNeedsReset = false;
	m_goalPipeID = 0;
	m_exPosAnimPipeID = 0;
	m_phase = eDAC_Idle;
	m_soundID = INVALID_SOUNDID;
	m_bInCancel = false;
	m_bAbortFromAI = false;
	m_abortReason = CDialogSession::eAR_None;
	m_bIsAware = true;
	m_bIsAwareLooking = true;
	m_bIsAwareInRange = true;
	m_bSoundStopsAnim = false;
	m_checkPlayerTimeOut = 0.0f; // start to check player on start
	m_playerAwareTimeOut = m_pSession->GetPlayerAwarenessGraceTime(); // set timeout
	m_currentEffectorChannelID = INVALID_FACIAL_CHANNEL_ID;
	m_bNeedsCancel = false; // no cancel on start
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::BeginSession()
{
	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::BeginSession: %s Now=%f 0x%p actorID=%d ",
		m_pSession->GetDebugName(), m_pSession->GetCurTime(), this, m_actorID);	

	ResetState();

	IEntitySystem* pES = gEnv->pEntitySystem;
	pES->AddEntityEventListener( m_entityID, ENTITY_EVENT_AI_DONE, this );
	pES->AddEntityEventListener( m_entityID, ENTITY_EVENT_DONE, this );
	pES->AddEntityEventListener( m_entityID, ENTITY_EVENT_RESET, this );

	switch (GetAIBehaviourMode())
	{
	case CDialogSession::eDIB_InterruptAlways:
		ExecuteAI( m_goalPipeID, "ACT_ANIM" );
		break;
	case CDialogSession::eDIB_InterruptMedium:
		ExecuteAI( m_goalPipeID, "ACT_DIALOG" );
		break;
	case CDialogSession::eDIB_InterruptNever:
		break;
	}
	m_bNeedsCancel = true;
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::EndSession()
{
	CancelCurrent();
	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::EndSession: %s now=%f 0x%p actorID=%d ",
		m_pSession->GetDebugName(), m_pSession->GetCurTime(), this, m_actorID);
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::Update(float dt)
{
	if (IsAborted())
		return true;

	// FIXME: this should never happen, as we should get a notification before.
	//        temp leave in for tracking down a bug [AlexL: 23/11/2006]
	IEntity* pEntity = gEnv->pEntitySystem->GetEntity(m_entityID);
	if (pEntity == 0)
	{
		m_pIActor = 0;
		GameWarning("[DIALOG] CDialogActorContext::Update: %s Actor=%d (EntityId=%d) no longer existent.",
			m_pSession->GetDebugName(), m_actorID, m_entityID);
		AbortContext(true, CDialogSession::eAR_EntityDestroyed);
		return true;
	}

	float now = m_pSession->GetCurTime();

	if (!CheckActorFlags(CDialogSession::eDACF_NoActorDeadAbort) && m_pIActor && m_pIActor->GetHealth() <= 0)
	{
		if (!IsAborted())
		{
			DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Actor=%d (EntityId=%d) has died. Aborting.",
				m_pSession->GetDebugName(), m_actorID, m_entityID);
			AbortContext(true, CDialogSession::eAR_ActorDead);
			return true;
		}
	}

	if (m_bIsLocalPlayer)
	{
		// when the local player is involved in the conversation do some special checks
		if (DoLocalPlayerChecks(dt) == false)
		{
			DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Abort from LocalPlayer.", m_pSession->GetDebugName());
			AbortContext(true, m_bIsAwareInRange == false ? CDialogSession::eAR_PlayerOutOfRange : CDialogSession::eAR_PlayerOutOfView);
			return true;
		}
	}

	if (m_bAbortFromAI)
	{
		m_bAbortFromAI = false;
		if (!IsAborted())
		{
			DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Abort from AI.", m_pSession->GetDebugName());
			AbortContext(true, CDialogSession::eAR_AIAborted);
			return true;
		}
	}

	if (SessionAllowsLookAt())
	{
		DoStickyLookAt();
	}

	// updating sound position on static entities
	{
		IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
		if (pActorEntity)
		{
			IEntitySoundProxy* pActorSoundProxy = m_pSession->GetEntitySoundProxy(pActorEntity);
			if (pActorSoundProxy)
			{
				pActorSoundProxy->UpdateSounds();
			}
		}
	}

	int loop = 0;
	do 
	{
		// DiaLOG::Log("[DIALOG] DiaLOG::eAlways"CDialogActorContext::Update: %s now=%f actorId=%d loop=%d", m_pSession->GetDebugName(), now, m_actorID, loop);

		bool bAdvance = false;
		switch (m_phase)
		{
		case eDAC_Idle:
			break;

		case eDAC_NewLine:
			{
				m_bHasScheduled = false;
				m_lookAtTimeOut = LOOKAT_TIMEOUT;
				m_animTimeOut   = ANIM_TIMEOUT;
				m_soundTimeOut  = SOUND_TIMEOUT; // wait one second until sound is timed out
				m_bAnimScheduled = false;
				m_bAnimStarted   = false;
				m_bSoundScheduled = false;
				m_bSoundStarted   = false;
				m_soundLength   = 0.0f;

				if (m_pCurLine->m_flagResetLookAt)
				{
					m_stickyLookAtActorID = CDialogScript::NO_ACTOR_ID;
					m_lookAtActorID = CDialogScript::NO_ACTOR_ID;
				}
				// check if look-at sticky is set
				else if (m_pCurLine->m_lookatActor != CDialogScript::NO_ACTOR_ID)
				{
					if (m_pCurLine->m_flagLookAtSticky == false)
					{
						m_lookAtActorID = m_pCurLine->m_lookatActor;
						m_stickyLookAtActorID = CDialogScript::NO_ACTOR_ID;
					}
					else
					{
						m_stickyLookAtActorID = m_pCurLine->m_lookatActor;
						m_lookAtActorID = CDialogScript::NO_ACTOR_ID;
					}
				}

				bAdvance = true;

				// handle the first sticky look-at here
				if (SessionAllowsLookAt())
				{
					DoStickyLookAt();
				}









			}
			break;

		case eDAC_LookAt:
			{
				bool bWaitForLookAtFinish = true;
				bAdvance = true;
	
				if (SessionAllowsLookAt() == false)
				{
					break;
				}

				// Question: maybe do this although EP is requested
				if (bWaitForLookAtFinish && m_lookAtActorID != CDialogScript::NO_ACTOR_ID && m_pCurLine->m_flagAGEP == false) 
				{
					IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
					IEntity* pLookAtEntity = m_pSession->GetActorEntity(m_lookAtActorID);
					if (pActorEntity != 0)
					{
						m_lookAtTimeOut -= dt;
						bool bTargetReached;
						bool bSuccess = DoLookAt(pActorEntity, pLookAtEntity, bTargetReached);
						//DiaLOG::Log(DiaLOG::eDebugA, "[DIALOG] CDialogActorContext::Update: %s now=%f actorID=%d phase=eDAC_LookAt %d",
						//	m_pSession->GetDebugName(), now, m_actorID, bTargetReached);

						if (/* bSuccess == false || */ bTargetReached || m_lookAtTimeOut<=0.0f)
						{
							DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s now=%f actorID=%d phase=eDAC_LookAt %s",
								m_pSession->GetDebugName(), now, m_actorID, bTargetReached ? "Target Reached" : "Timed Out");
							m_lookAtActorID = CDialogScript::NO_ACTOR_ID;
						}
						else
							bAdvance = false;
					}
				}
			}
			break;

		case eDAC_Anim:
			{
				bAdvance = true;
				if (SessionAllowsLookAt() && m_lookAtActorID != CDialogScript::NO_ACTOR_ID) // maybe: don't do this when EP is requested [&& m_pCurLine->m_flagAGEP == false]
				{
					IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
					IEntity* pLookAtEntity = m_pSession->GetActorEntity(m_lookAtActorID);
					if (pActorEntity != 0)
					{
						m_lookAtTimeOut -= dt;
						bool bTargetReached;
						bool bSuccess = DoLookAt(pActorEntity, pLookAtEntity, bTargetReached);
						if (/* bSuccess == false || */ bTargetReached || m_lookAtTimeOut<=0.0f)
						{
							DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s now=%f actorID=%d phase=eDAC_Anim %s",
								m_pSession->GetDebugName(), now, m_actorID, bTargetReached ? "Target Reached" : "Timed Out");
							m_lookAtActorID = CDialogScript::NO_ACTOR_ID;
						}
						else
							bAdvance = false;
					}
				}
				const bool bHasAnim = !m_pCurLine->m_anim.empty();
				if (SessionAllowsAnim() && bHasAnim)
				{
					bAdvance = false;
					if (!m_bAnimScheduled)
					{
						m_bSoundStopsAnim = false; // whenever there is a new animation, no need for the still playing sound
						                           // to stop the animation
						m_bAnimStarted = false;
						m_bAnimScheduled = true;
						// schedule animation
						IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
						if (pActorEntity)
							DoAnimAction(pActorEntity, m_pCurLine->m_anim, m_pCurLine->m_flagAGSignal, m_pCurLine->m_flagAGEP);
						else
							bAdvance = true;
					}
					else
					{
						// we scheduled it already
						// wait until it starts or timeout
						m_animTimeOut-=dt;
						bAdvance = m_animTimeOut <= 0.0f || m_bAnimStarted;
						if (bAdvance)
						{
							DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Now=%f actorID=%d phase=eDAC_Anim %s",
								m_pSession->GetDebugName(), now, m_actorID, m_bAnimStarted ? "Anim Started" : "Anim Timed Out");
						}
					}
				}
			}
			break;

		case eDAC_ScheduleSoundPlay:
			{
				bAdvance = true;
				const bool bHasSound  = !m_pCurLine->m_sound.empty();
				if (bHasSound)
				{
					if (m_bSoundScheduled == false)
					{
						IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
						if (pActorEntity == 0)
							break;

						IEntitySoundProxy* pActorSoundProxy = m_pSession->GetEntitySoundProxy(pActorEntity);
						if (pActorSoundProxy == 0)
							break;

						// start a new sound
						int sFlags = CDialogActorContext::SOUND_FLAGS;
						if (CDialogSystem::sLoadSoundSynchronously != 0)
							sFlags |= FLAG_SOUND_LOAD_SYNCHRONOUSLY;
						
						// if it's the local player make the sound relative to the entity
						if (m_bIsLocalPlayer)
							sFlags |= FLAG_SOUND_RELATIVE;

						const char* soundKey = GetSoundKey(m_pCurLine->m_sound);
						ISound* pSound = 0;

						pSound = gEnv->pSoundSystem->CreateSound(soundKey, sFlags);

						DiaLOG::Log(DiaLOG::eDebugA, "[DIALOG] CDialogActorContex::Update: %s Now=%f actorID=%d phase=eDAC_ScheduleSoundPlay: Starting '%s' [key=%s]",
							m_pSession->GetDebugName(), now, m_actorID, m_pCurLine->m_sound.c_str(), soundKey);

						if (!pSound) 
						{
							GameWarning("[DIALOG] CDialogActorContext::Update: %s ActorID=%d: Cannot play sound '%s'",
								m_pSession->GetDebugName(), m_actorID, m_pCurLine->m_sound.c_str());
						}

						if (pSound)
						{
							if (m_bSoundStopsAnim)
							{
								m_bSoundStopsAnim = false;
								if (m_pAGState != 0)
								{
									ResetAGState();
									DiaLOG::Log(DiaLOG::eDebugA, "[DIALOG] CDialogActorContext::Update: %s Now=%f actorID=%d phase=eDAC_ScheduleSoundPlay: Stopping old animation",
										m_pSession->GetDebugName(), now, m_actorID);
								}
							}
							StopSound();
							m_soundID = pSound->GetId();
							m_bSoundStarted = false;
							m_bSoundScheduled = true;
							// tell the animation whether to stop on sound stop
							m_bSoundStopsAnim = m_pCurLine->m_flagSoundStopsAnim;

							DiaLOG::Log(DiaLOG::eDebugA, "[DIALOG] CDialogActorContext::Update: %s Now=%f actorID=%d phase=eDAC_ScheduleSoundPlay: Reg as listener on 0x%p '%s'",
								m_pSession->GetDebugName(), now, m_actorID, pSound, pSound->GetName());

							pSound->SetSemantic(eSoundSemantic_Dialog);
							pSound->AddEventListener(this, "DialogActor"); // event listener will set m_soundLength
							// sound proxy uses head pos on dialog sounds
							pActorSoundProxy->PlaySound(pSound, Vec3(ZERO), FORWARD_DIRECTION, 1.0f);
							// Fetch some localization info for the sound
							ILocalizationManager* pLocMgr = gEnv->pSystem->GetLocalizationManager();
							if (pLocMgr && CDialogSystem::sWarnOnMissingLoc != 0)
							{
								//SLocalizedInfoGame GameInfo = {0};
								//const bool bFound = pLocMgr->GetLocalizedInfoByKey(soundKey, GameInfo);

								ILocalizationManager::SLocalizedInfo GameInfo = {0};

								const bool bFound = pLocMgr->GetLocalizedInfo(soundKey, GameInfo);
								if (!bFound)
								{
									GameWarning("[DIALOG] CDialogActorContext::Update: '%s' DialogScript '%s': Localized info for '%s' not found!", 
										m_pSession->GetDebugName(), m_pSession->GetScript()->GetID().c_str(), m_pCurLine->m_sound.c_str());
								}
							}

							bAdvance = false; // don't advance
						}
						else
						{
							GameWarning("[DIALOG] CDialogActorContext::Update: %s ActorID=%d: Cannot play sound '%s' [SoundProxy returns invalid sound]",
								m_pSession->GetDebugName(), m_actorID, m_pCurLine->m_sound.c_str());
						}
					}
					else
					{
						// sound has been scheduled
						// wait for sound start or timeout
						m_soundTimeOut-=dt;
						const bool bTimedOut = m_soundTimeOut <= 0.0f;
						bAdvance = bTimedOut || m_bSoundStarted;
						if (bAdvance)
						{
							if (bTimedOut)
								StopSound(true); // unregister from sound as listener and free resource
							DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Now=%f actorID=%d phase=eDAC_ScheduleSoundPlay %s",
								m_pSession->GetDebugName(), now, m_actorID, m_bSoundStarted ? "Sound Started" : "Sound Timed Out");
						}
					}
				}
			}
			break;

		case eDAC_SoundFacial:
			{
				bAdvance = true;
				const bool bHasSound  = !m_pCurLine->m_sound.empty();
				const bool bHasFacial = !m_pCurLine->m_facial.empty() || m_pCurLine->m_flagResetFacial;
				if (bHasFacial)
				{
					IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
					if (pActorEntity)
						DoFacialExpression(pActorEntity, m_pCurLine->m_facial, m_pCurLine->m_facialWeight, m_pCurLine->m_facialFadeTime);
				}

				float delay = m_pCurLine->m_delay;
				if (bHasSound && m_bSoundStarted)
				{
					if (m_soundLength < 0.0f)
					{
						m_soundLength = Random(2.0f,6.0f);
						DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Now=%f actorID=%d phase=eDAC_SoundFacial Faking SoundTime to %f",
							m_pSession->GetDebugName(), now, m_actorID, m_soundLength);
					}

					DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Now=%f actorID=%d phase=eDAC_SoundFacial Delay=%f SoundTime=%f",
						m_pSession->GetDebugName(), now , m_actorID, delay, m_soundLength);
					delay += m_soundLength;
				}

				// schedule END
				if (delay < 0.0f)
					delay = 0.0f;
				m_pSession->ScheduleNextLine(delay);
				m_bHasScheduled = true;
			}
			break;

		case eDAC_EndLine:
			bAdvance = true;
			if (m_bHasScheduled == false)
			{
				m_bHasScheduled = true;
				m_pSession->ScheduleNextLine(m_pCurLine->m_delay);
			}
			break;
		}

		if (bAdvance)
		{
			AdvancePhase();
			dt = 0.0f;
			++loop;
			assert (loop <= eDAC_EndLine+1);
			if (loop > eDAC_EndLine+1)
			{
				DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::Update: %s Actor=%d InternalLoopCount=%d. Final Exit!",
					m_pSession->GetDebugName(), m_actorID, loop);
			}
		}
		else
			break;
	}
	while (true);

	return true;
}

static const char* PhaseNames[] =
{
	"eDAC_Idle",
	"eDAC_NewLine",
	"eDAC_LookAt",
	"eDAC_Anim",
	"eDAC_ScheduleSoundPlay",
	"eDAC_SoundFacial",
	"eDAC_EndLine"
};

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::AdvancePhase()
{
	const int oldPhase = m_phase;
	++m_phase;
	if (m_phase > eDAC_EndLine)
		m_phase = eDAC_Idle;

	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext:AdvancePhase: %s ActorID=%d %s->%s",
		m_pSession->GetDebugName(), m_actorID, PhaseNames[oldPhase], PhaseNames[m_phase]);
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::PlayLine(const CDialogScript::SScriptLine* pLine)
{
	m_pCurLine = pLine;
	m_phase = eDAC_NewLine;
	return true;
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::DoAnimAction(IEntity* pEntity, const string& action, bool bIsSignal, bool bUseEP)
{
	m_bAnimUseEP = bUseEP;
	m_bAnimUseAGSignal = bIsSignal;

	if (m_bAnimUseEP == false)
	{
		const bool bSuccess = DoAnimActionAG(pEntity, action.c_str());
		return bSuccess;
	}
	else
	{
		const bool bSuccess = DoAnimActionEP(pEntity, action.c_str());
		return bSuccess;
	}
	return false; // make some compilers happy
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::DoAnimActionAG(IEntity* pEntity, const char* sAction)
{
	IActor* pActor = gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor( m_entityID );
	if (pActor)
	{
		m_pAGState = pActor->GetAnimationGraphState();
		if (m_pAGState)
		{
			m_pAGState->AddListener( "dsctx", this );
			if (m_bAnimUseAGSignal)
			{
				DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext:DoAnimAction: %s ActorID=%d Setting signal to '%s'",
					m_pSession->GetDebugName(), m_actorID, sAction);
				m_pAGState->SetInput( "Signal", sAction, &m_queryID );
			}
			else
			{
				DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext:DoAnimAction: %s ActorID=%d Setting input to '%s'",
					m_pSession->GetDebugName(), m_actorID, sAction);
				m_pAGState->SetInput( "Action", sAction, &m_queryID );
			}
		}
	}
	return true;
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::DoAnimActionEP(IEntity* pEntity, const char* sAction)
{
	IAIObject* pAI = pEntity->GetAI();
	if (pAI == 0)
		return false;

	IPipeUser* pPipeUser = pAI->CastToIPipeUser();
	if (!pPipeUser)
	{
		return false;
	}

	Vec3 pos = pEntity->GetWorldPos();
	Vec3 dir = pAI->GetMoveDir();

	// EP Direction is either lookat direction or forward direction
	CDialogScript::TActorID lookAt = m_pCurLine->m_lookatActor;
	if (lookAt != CDialogScript::NO_ACTOR_ID)
	{
		IEntity* pLookAtEntity = m_pSession->GetActorEntity(lookAt);
		if (pLookAtEntity != 0)
		{
			dir = pLookAtEntity->GetWorldPos();
			dir -= pos;
			dir.z = 0;
			dir.NormalizeSafe(pAI->GetMoveDir());
		}
	}
	pPipeUser->SetRefPointPos(pos, dir);

	static const Vec3 startRadius (0.1f,0.1f,0.1f);
	static const float dirTolerance = 5.f;
	static const float targetRadius = 0.05f;

	IAISignalExtraData* pData = gEnv->pAISystem->CreateSignalExtraData();
	pData->iValue2 = m_bAnimUseAGSignal ? 1 : 0;
	pData->SetObjectName(sAction);
	pData->point = startRadius;
	pData->fValue = dirTolerance;
	pData->point2.x = targetRadius;

	const bool ok = ExecuteAI(m_exPosAnimPipeID, "ACT_ANIMEX", pData);
	return ok;
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::DoFacialExpression(IEntity *pEntity, const string& expression, float weight, float fadeTime)
{
	ICharacterInstance * pCharacter = pEntity->GetCharacter(0);
	if (!pCharacter)
		return false;
	IFacialInstance * pFacialInstance = pCharacter->GetFacialInstance();
	if (!pFacialInstance)
		return false;
	IFacialModel * pFacialModel = pFacialInstance->GetFacialModel();
	if (!pFacialModel)
		return false;
	IFacialEffectorsLibrary * pLibrary = pFacialModel->GetLibrary();
	if (!pLibrary)
		return false;

	IFacialEffector *pEffector = 0;
	if (!expression.empty())
	{
		pEffector = pLibrary->Find( expression.c_str() );
		if (!pEffector)
		{
			GameWarning("[DIALOG] CDialogActorContext::DoFacialExpression: %s Cannot find '%s' for Entity '%s'", m_pSession->GetDebugName(), expression.c_str(), pEntity->GetName());
			return false;
		}
	}

	if (m_currentEffectorChannelID != INVALID_FACIAL_CHANNEL_ID)
	{
		// we fade out with the same fadeTime as fade in
		pFacialInstance->StopEffectorChannel(m_currentEffectorChannelID, fadeTime*1000.0f);
		m_currentEffectorChannelID = INVALID_FACIAL_CHANNEL_ID;
	}

	if (pEffector)
	{
		m_currentEffectorChannelID = pFacialInstance->StartEffectorChannel(pEffector, weight, fadeTime*1000.0f); // facial instance wants ms
	}
	return true;
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::DoLookAt(IEntity *pEntity, IEntity *pLookAtEntity, bool& bReachedTarget)
{
	bReachedTarget = false;
	IAIObject* pAI = pEntity->GetAI();
	if (pAI == 0)
		return false;

	IPipeUser* pPipeUser = pAI->CastToIPipeUser();
	if (!pPipeUser)
	{
		return false;
	}

	if (pLookAtEntity == 0)
	{
		pPipeUser->ResetLookAt();
		bReachedTarget = true;
		m_bLookAtNeedsReset = false;
	}
	else
	{
		IAIObject* pTargetAI = pLookAtEntity->GetAI();
		Vec3 pos = pTargetAI ? pTargetAI->GetPos() : pLookAtEntity->GetWorldPos();
		bReachedTarget = pPipeUser->SetLookAtPoint(pos, true);
		m_bLookAtNeedsReset = true;
	}

	return true;
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::DoStickyLookAt()
{
	if (m_stickyLookAtActorID != CDialogScript::NO_ACTOR_ID)
	{
		IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
		IEntity* pLookAtEntity = m_pSession->GetActorEntity(m_stickyLookAtActorID);
		if (pActorEntity != 0)
		{
			bool bTargetReached;
			DoLookAt(pActorEntity, pLookAtEntity, bTargetReached);
		}
	}
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::CancelCurrent(bool bResetStates)
{
	if (!m_bNeedsCancel)
		return;

	assert (m_bInCancel == false);
	if (m_bInCancel == true)
		return;
	m_bInCancel = true;

	// remove from AG
	if (m_pAGState != 0)
	{
		m_pAGState->RemoveListener(this);
		if (bResetStates)
		{
			ResetAGState();
		}
		m_pAGState = 0;
	}
	m_queryID = 0;
	m_bAnimStarted = false;

	// reset lookat
	IEntity* pEntity = gEnv->pEntitySystem->GetEntity(m_entityID);
	if (pEntity)
	{
		IAIObject* pAI = pEntity->GetAI();
		if (pAI)
		{
			IPipeUser* pPipeUser = pAI->CastToIPipeUser();
			if (pPipeUser)
			{
				if (m_bLookAtNeedsReset)
				{
					pPipeUser->ResetLookAt();
					m_bLookAtNeedsReset = false;
				}
				if (m_goalPipeID > 0)
				{
					if (GetAIBehaviourMode() == CDialogSession::eDIB_InterruptMedium)
					{
						int dummyPipe = 0;
						ExecuteAI(dummyPipe, "ACT_DIALOG_OVER", 0, false);
					}
					pPipeUser->UnRegisterGoalPipeListener( this, m_goalPipeID );
					pPipeUser->RemoveSubPipe(m_goalPipeID, true);
					m_goalPipeID = 0;
				}
				if (m_exPosAnimPipeID > 0)
				{
					pPipeUser->UnRegisterGoalPipeListener( this, m_exPosAnimPipeID );
					pPipeUser->CancelSubPipe(m_exPosAnimPipeID);
					pPipeUser->RemoveSubPipe(m_exPosAnimPipeID, false);
					m_exPosAnimPipeID = 0;
				}
			}
		}
	}

	// facial expression is always reset
	// if (bResetStates)
	{
		// Reset Facial Expression
		IEntity* pActorEntity = m_pSession->GetActorEntity(m_actorID);
		if (pActorEntity)
		{
			DoFacialExpression(pActorEntity, "", 1.0f, 0.0f);
		}
	}

	// should we stop the current sound?
	// we don't stop the sound if the actor aborts and has eDACF_NoAbortSound set.
	// if actor died (entity destroyed) though, sound is stopped anyway
	const bool bDontStopSound = (IsAborted() == false && CheckActorFlags(CDialogSession::eDACF_NoAbortSound))
		|| (IsAborted() 
		&& CheckActorFlags(CDialogSession::eDACF_NoAbortSound)
		&& GetAbortReason() != CDialogSession::eAR_ActorDead
		&& GetAbortReason() != CDialogSession::eAR_EntityDestroyed);

	if (bDontStopSound == false)
	{
		// stop sound (this also forces m_soundId to be INVALID_SOUNDID) and markes Context as non-playing!
		// e.g. IsStillPlaying will then return false
		// we explicitly stop the sound in the d'tor if we don't take this path here
		StopSound(); 
	}

	IEntitySystem* pES = gEnv->pEntitySystem;
	pES->RemoveEntityEventListener( m_entityID, ENTITY_EVENT_AI_DONE, this );
	pES->RemoveEntityEventListener( m_entityID, ENTITY_EVENT_DONE, this );
	pES->RemoveEntityEventListener( m_entityID, ENTITY_EVENT_RESET, this );

	m_phase = eDAC_Idle;

	m_bInCancel = false;
	m_bNeedsCancel = false;
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::ResetAGState()
{
	if (!m_pAGState)
		return;

	if (m_bAnimUseAGSignal)
	{
		if (!m_bAnimStarted)
			m_pAGState->SetInput("Signal", "none");
	}
	else
		m_pAGState->SetInput("Action", "idle");
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::AbortContext(bool bCancel, CDialogSession::EAbortReason reason)
{
	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext:AbortContext: %s actorID=%d ", m_pSession->GetDebugName(), m_actorID);
	m_phase = eDAC_Aborted;
	m_abortReason = reason;
	if (bCancel)
		CancelCurrent();
	// need to set it again, as CancelCurrent might have changed them
	m_phase = eDAC_Aborted;
	m_abortReason = reason;
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::IsAborted() const
{
	return m_phase == eDAC_Aborted;
}

// IAnimationGraphStateListener
////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::SetOutput( const char * output, const char * value )
{
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::QueryComplete( TAnimationGraphQueryID queryID, bool succeeded )
{
	IEntity* pEntity = gEnv->pEntitySystem->GetEntity( m_entityID );
	if ( !pEntity )
		return;

	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext:QueryComplete: %s actorID=%d m_queryID=%d queryID=%d",
		m_pSession->GetDebugName(), m_actorID, m_queryID, queryID);

	if ( queryID != m_queryID )
		return;

	IAIObject* pAI = pEntity->GetAI();

	if ( succeeded || (m_bAnimStarted && !m_bAnimUseAGSignal))
	{
		if (m_bAnimStarted == false)
		{
			m_bAnimStarted = true;
			if (m_bAnimUseAGSignal)
			{
				m_pAGState->QueryLeaveState( &m_queryID );
			}
			else
			{
				m_pAGState->QueryChangeInput( "Action", &m_queryID );
			}
		}
		else
		{
			if (m_pAGState)
			{
				m_pAGState->RemoveListener(this);
				m_pAGState = 0;
				m_queryID = 0;
				m_bAnimStarted = false;
			}
		}
	}
	else
	{	
		;
	}
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::DestroyedState(IAnimationGraphState* )
{
	m_pAGState = 0;
	m_queryID = 0;
	m_bAnimStarted = false;
}

// ~IAnimationGraphStateListener

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::ExecuteAI(int& goalPipeID, const char* signalText, IAISignalExtraData* pExtraData, bool bRegisterAsListener)
{
	IEntitySystem* pSystem = gEnv->pEntitySystem;
	IEntity* pEntity = pSystem->GetEntity(m_entityID);
	if (pEntity == 0)
		return false;

	IAIObject* pAI = pEntity->GetAI();
	if (pAI == 0)
		return false;

	unsigned short nType=pAI->GetAIType();
	if ( nType != AIOBJECT_PUPPET )
	{
		if ( nType == AIOBJECT_PLAYER )
		{
			goalPipeID = -1;

			// not needed for player 
			// pAI->SetSignal( 10, signalText, pEntity, NULL ); // 10 means this signal must be sent (but sent[!], not set)
			// even if the same signal is already present in the queue
			return true;
		}

		// invalid AIObject type
		return false;
	}

	IPipeUser* pPipeUser = pAI->CastToIPipeUser();
	if (pPipeUser)
	{
		if (goalPipeID > 0)
		{
			pPipeUser->RemoveSubPipe(goalPipeID, true);
			pPipeUser->UnRegisterGoalPipeListener( this, goalPipeID );
			goalPipeID = 0;
		}
	}

	goalPipeID = gEnv->pAISystem->AllocGoalPipeId();
	if (pExtraData == 0)
		pExtraData = gEnv->pAISystem->CreateSignalExtraData();
	pExtraData->iValue = goalPipeID;
	
	if (pPipeUser && bRegisterAsListener)
	{
		pPipeUser->RegisterGoalPipeListener( this, goalPipeID, "CDialogActorContext::ExecuteAI");
	}

	IAIActor* pAIActor = CastToIAIActorSafe(pAI);
	if(pAIActor)
		pAIActor->SetSignal( 10, signalText, pEntity, pExtraData ); // 10 means this signal must be sent (but sent[!], not set)
	// even if the same signal is already present in the queue
	return true;
}

////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::StopSound(bool bUnregisterOnly)
{
	// Stop Sound
	if (m_soundID != INVALID_SOUNDID)
	{
		// Unregister as listener
		ISound* pSound = gEnv->pSoundSystem->GetSound(m_soundID);
		if (pSound)
		{
			pSound->RemoveEventListener(this);
			if (bUnregisterOnly==false)
				pSound->Stop();
		}
		m_soundID = INVALID_SOUNDID;
	}
}

bool CDialogActorContext::DoLocalPlayerChecks(const float dt)
{
	// don't check this every frame, but only every .2 secs
	m_checkPlayerTimeOut-=dt;
	if (m_checkPlayerTimeOut <= 0.0f)
	{
		do // a dummy loop to use break
		{
			float awareDistance;
			float awareDistanceSq;
			float awareAngle;
			m_pSession->GetPlayerAwarenessValues(awareDistance, awareAngle);
			awareDistanceSq=awareDistance*awareDistance;

			m_checkPlayerTimeOut = PLAYER_CHECKTIME;
			const float spotAngleCos = cry_cosf(DEG2RAD(awareAngle));
	
			const CDialogSession::TActorContextMap& contextMap = m_pSession->GetAllContexts();
			if (contextMap.size() == 1 && contextMap.begin()->first == m_actorID)
			{
				m_bIsAware = true;
				break;
			}
	
			// early out, when we don't have to do any checks
			if (awareDistance <= 0.0f && awareAngle <= 0.0f)
			{
				m_bIsAware = true;
				break;
			}

			IEntity* pThisEntity = m_pSession->GetActorEntity(m_actorID);
			if (!pThisEntity)
			{
				assert (false);
				m_bIsAware = true;
				break;
			}
			IMovementController* pMC = (m_pIActor != NULL) ? m_pIActor->GetMovementController() : NULL;
			if (!pMC)
			{
				assert (false);
				m_bIsAware = true;
				break;
			}
			SMovementState moveState;
			pMC->GetMovementState(moveState);
			Vec3 viewPos = moveState.eyePosition;
			Vec3 viewDir = moveState.eyeDirection;
			viewDir.z = 0.0f;
			viewDir.NormalizeSafe();
	
			// check the player's position
			// check the player's view direction
			AABB groupBounds;
			groupBounds.Reset();

			CDialogSession::TActorContextMap::const_iterator iter = contextMap.begin();
			CDialogScript::SActorSet lookingAt = 0;
			while (iter != contextMap.end())
			{
				if (iter->first != m_actorID)
				{
					IEntity* pActorEntity = m_pSession->GetActorEntity(iter->first);
					if (pActorEntity)
					{
						Vec3 vEntityPos = pActorEntity->GetWorldPos();
						AABB worldBounds;
						pActorEntity->GetWorldBounds(worldBounds);
						groupBounds.Add(worldBounds);
						// calc if we look at it somehow
						Vec3 vEntityDir = vEntityPos - viewPos;
						vEntityDir.z = 0.0f;
						vEntityDir.NormalizeSafe();
						if (viewDir.IsUnit() && vEntityDir.IsUnit())
						{
							const float dot = clamp_tpl(viewDir.Dot(vEntityDir),-1.0f,+1.0f); // clamping should not be needed
							if (spotAngleCos <= dot)
								lookingAt.SetActor(iter->first);
							DiaLOG::Log(DiaLOG::eDebugC, "Angle to actor %d is %f deg", iter->first, RAD2DEG(cry_acosf(dot)));
						}
					}
				}
				++iter;
			}

			const float distanceSq = pThisEntity->GetWorldPos().GetSquaredDistance(groupBounds.GetCenter());
			CCamera& camera=gEnv->pSystem->GetViewCamera();
			const bool bIsInAABB  = camera.IsAABBVisible_F(groupBounds);
			const bool bIsInRange = distanceSq <= awareDistanceSq;
			const bool bIsLooking = contextMap.empty() || lookingAt.NumActors() > 0;
			m_bIsAwareLooking = awareAngle <= 0.0f || (bIsInAABB || bIsLooking);
			m_bIsAwareInRange = awareDistance <= 0.0f || bIsInRange;
			m_bIsAware = m_bIsAwareLooking && m_bIsAwareInRange;

			DiaLOG::Log(DiaLOG::eDebugB, "[DIALOG] LPC: %s awDist=%f awAng=%f AABBVis=%d IsLooking=%d InRange=%d [Distance=%f LookingActors=%d] Final=%saware", 
				m_pSession->GetDebugName(), awareDistance, awareAngle, bIsInAABB, bIsLooking, bIsInRange, sqrt_tpl(distanceSq), lookingAt.NumActors(), m_bIsAware ? "" : "not ");
		
		} while (false);
	}

	if (m_bIsAware)
	{
		m_playerAwareTimeOut = m_pSession->GetPlayerAwarenessGraceTime();
	}
	else
	{
		m_playerAwareTimeOut-= dt;
		if (m_playerAwareTimeOut <= 0)
		{
			return false;
		}
	}

	return true;
}

////////////////////////////////////////////////////////////////////////////
bool CDialogActorContext::IsStillPlaying() const
{
	return m_soundID != INVALID_SOUNDID;
}

// IEntityEventListener
void CDialogActorContext::OnEntityEvent( IEntity *pEntity,SEntityEvent &event )
{
	switch (event.event)
	{
		case ENTITY_EVENT_RESET:
		case ENTITY_EVENT_DONE:
			AbortContext(true, CDialogSession::eAR_EntityDestroyed);
			break;
		default:
			break;
	}
}

// ~IEntityEventListener

const char* EventName(EGoalPipeEvent event)
{
	switch ( event )
	{
	case ePN_Deselected:
		return "ePN_Deselected";
	case ePN_Removed:
		return "ePN_Removed";
	case ePN_Finished:
		return "ePN_Finished";
	case ePN_Suspended:
		return "ePN_Suspended";
	case ePN_Resumed:
		return "ePN_Resumed";
	case ePN_AnimStarted:
		return "ePN_AnimStarted";
	case ePN_RefPointMoved:
		return "ePN_RefPointMoved";
	default:
		return "UNKNOWN GOAL PIPEEVENT";
	}
}

// IGoalPipeListener
////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::OnGoalPipeEvent( IPipeUser* pPipeUser, EGoalPipeEvent event, int goalPipeId )
{
	if (m_goalPipeID != goalPipeId && m_exPosAnimPipeID != goalPipeId)
		return;

#if 1
	DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::OnGoalPipeEvent: %s 0x%p actorID=%d goalPipe=%d m_goalPipeID=%d m_exPosAnimPipeID=%d event=%s",
		m_pSession->GetDebugName(), this, m_actorID, goalPipeId, m_goalPipeID, m_exPosAnimPipeID, EventName(event));
#endif

	switch (event)
	{
	case ePN_Deselected:
	case ePN_Removed:
		if (CheckActorFlags(CDialogSession::eDACF_NoAIAbort) == false)
		{
			if (m_goalPipeID == goalPipeId)
				m_bAbortFromAI = true;
		}
		break;
	case ePN_AnimStarted:
		m_bAnimStarted = true;
		break;
	default:
		break;
	}
}
// ~IGoalPipeListener

// ISoundEventListener
////////////////////////////////////////////////////////////////////////////
void CDialogActorContext::OnSoundEvent( ESoundCallbackEvent event,ISound *pSound )
{
	if (pSound == 0 || pSound->GetId() != m_soundID)
		return;

	switch (event)
	{
		case SOUND_EVENT_ON_START:
			m_soundLength = pSound->GetLengthMs() * 0.001f;
			m_bSoundStarted = true;

			DiaLOG::Log(DiaLOG::eAlways, "[DIALOG] CDialogActorContext::OnSoundEvent: %s Actor=%d Sound '%s' started with length %f",
				m_pSession->GetDebugName(), m_actorID, pSound->GetName(), m_soundLength);
			break;
		case SOUND_EVENT_ON_STOP:
			pSound->RemoveEventListener(this);
			m_soundID = INVALID_SOUNDID;
			if (m_bSoundStopsAnim)
			{
				m_bSoundStopsAnim = false;
				if (m_pAGState != 0)
				{
					ResetAGState();
					DiaLOG::Log(DiaLOG::eDebugA, "[DIALOG] CDialogActorContext::OnSoundEvent: %s Actor=%d Stopping ANIM because sound '%s' stopped.",
						m_pSession->GetDebugName(), m_actorID, pSound->GetName());
				}
			}
			break;
		default:
			break;
	}
}
// ~ISoundEventListener

void CDialogActorContext::GetMemoryStatistics(ICrySizer * s)
{
	s->Add(*this);
}

/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2004.
-------------------------------------------------------------------------
$Id$
$DateTime$

-------------------------------------------------------------------------
History:
- 12:10:2007   15:00 : Created by Márcio Martins

*************************************************************************/
#include "StdAfx.h"
#include "ShotValidator.h"
#include "GameRules.h"
#include "GameCVars.h"


//------------------------------------------------------------------------
CShotValidator::CShotValidator(CGameRules *pGameRules, IItemSystem *pItemSystem, IGameFramework *pGameFramework)
: m_pGameRules(pGameRules)
, m_pItemSystem(pItemSystem)
, m_pGameFramework(pGameFramework)
, m_doingHit(false)
{
}

//------------------------------------------------------------------------
CShotValidator::~CShotValidator()
{
}

//------------------------------------------------------------------------
void CShotValidator::AddShot(EntityId playerId, EntityId weaponId, uint16 seq, uint8 seqr)
{
	FUNCTION_PROFILER(GetISystem(), PROFILE_GAME);

	if (!playerId || !weaponId)
		return;

	CTimeValue now=gEnv->pTimer->GetFrameStartTime();
	int channelId=m_pGameRules->GetChannelId(playerId);
	int shotLife=3;

	TChannelHits::iterator chit=m_pendinghits.find(channelId);
	if (chit==m_pendinghits.end())
		return;

	TShot shot(seq, weaponId, now, shotLife);

	assert(chit!=m_pendinghits.end());
	THits &hits=chit->second;
	THits::iterator hit=hits.find(shot);

	while (shot.life>0 && hit!=hits.end() && shot==hit->first)
	{
		if(g_pGameCVars->g_debugShotValidator != 0)
			CryLogAlways("found a matching hit! seq: %d  id: %d  age: %.2f  size: %d", shot.seq, shot.weaponId, (now-hit->second.time).GetMilliSeconds(), hits.size());

		HitInfo info=hit->second.info;
		hits.erase(hit);

		m_doingHit=true;
		m_pGameRules->ServerHit(info);
		m_doingHit=false;
		
		--shot.life;
		hit=hits.find(shot);
	}

	if (shot.life>0)
	{
		TChannelShots::iterator csit=m_shots.find(channelId);
		assert(csit!=m_shots.end());
		TShots &shots=csit->second;
		shots.insert(shot);

		if(g_pGameCVars->g_debugShotValidator != 0)
			CryLogAlways("added shot! seq: %d  id: %d", shot.seq, shot.weaponId);
	}

	if (seqr>0)
	{
		uint16 nseq=seq+1;
		for (uint8 i=0;i<seqr;i++)
		{
			if (nseq==0)
				nseq=1;

			AddShot(playerId, weaponId, nseq++, 0);
		}
	}
}

//------------------------------------------------------------------------
bool CShotValidator::ProcessHit(const HitInfo &hitInfo)
{
	FUNCTION_PROFILER(GetISystem(), PROFILE_GAME);

	if (CanHit(hitInfo))
		return true;

	CTimeValue now=gEnv->pTimer->GetFrameStartTime();
	int channelId=m_pGameRules->GetChannelId(hitInfo.shooterId);

	// Crysis Co-op
	// Workaround: Early exit on AI shot bullets- we don't need to validate them because the AI system can obviously be trusted on server.
	if (IActor* pShooter = gEnv->pGame->GetIGameFramework()->GetIActorSystem()->GetActor(hitInfo.shooterId))
	{
		if (!pShooter->IsPlayer())
			return true;
	}
	// ~Crysis Co-op

	TShot shot(hitInfo.seq, hitInfo.weaponId, now, 0);
	
	TChannelShots::iterator csit=m_shots.find(channelId);
	if (csit!=m_shots.end())
	{
		TShots &shots=csit->second;
		TShots::iterator found=shots.find(shot);

		if (found!=shots.end())
		{
			if(g_pGameCVars->g_debugShotValidator != 0)
				CryLogAlways("found a matching shot! seq: %d  id: %d  age: %.2f  size: %d", shot.seq, shot.weaponId, (now-found->time).GetMilliSeconds(), shots.size());

			TShot &fshot=const_cast<TShot&>(*found);

			if (fshot.life>0)
				--fshot.life;
			else if(g_pGameCVars->g_debugShotValidator != 0)
				CryLogAlways("invalid shot consumption! seq: %d  id: %d", fshot.seq, fshot.weaponId);

			if (Expired(now, fshot))
			{
				if(g_pGameCVars->g_debugShotValidator != 0)
					CryLogAlways("expired shot found! seq: %d  id: %d  age: %.2f", fshot.seq, fshot.weaponId, (now-fshot.time).GetMilliSeconds());

				shots.erase(found);
			}

			return true;
		}
	}

	TChannelHits::iterator chit=m_pendinghits.find(channelId);
	assert(chit!=m_pendinghits.end());
	THits &hits=chit->second;
	hits.insert(THits::value_type(shot, THit(hitInfo, now)));

	if(g_pGameCVars->g_debugShotValidator != 0)
		CryLogAlways("hit pending! seq: %d  id: %d  age: %.2f  size: %d", shot.seq, shot.weaponId, 0.0f, hits.size());

	return false;
}

//------------------------------------------------------------------------
void CShotValidator::Connected(int channelId)
{
	Disconnected(channelId); // make sure it's cleaned up

	if(g_pGameCVars->g_debugShotValidator != 0)
		CryLogAlways("shot validator: channel %d connected", channelId);

	m_shots.insert(TChannelShots::value_type(channelId, TShots()));
	m_pendinghits.insert(TChannelHits::value_type(channelId, THits()));
}

//------------------------------------------------------------------------
void CShotValidator::Disconnected(int channelId)
{
	if(g_pGameCVars->g_debugShotValidator != 0)
		CryLogAlways("shot validator: channel %d disconnected", channelId);

	m_shots.erase(channelId);
	m_pendinghits.erase(channelId);
}

//------------------------------------------------------------------------
void CShotValidator::Reset()
{
	if(g_pGameCVars->g_debugShotValidator != 0)
		CryLogAlways("shot validator: reset deletes all shots/hits");

	TChannelShots::iterator csend=m_shots.end();
	for (TChannelShots::iterator csit=m_shots.begin(); csit!=csend; ++csit)
	{
		TShots &shots=csit->second;
		shots.clear();
	}

	TChannelHits::iterator chend=m_pendinghits.end();
	for (TChannelHits::iterator chit=m_pendinghits.begin(); chit!=chend; ++chit)
	{
		THits &hits=chit->second;
		hits.clear();
	}
}

//------------------------------------------------------------------------
void CShotValidator::Update()
{
	FUNCTION_PROFILER(GetISystem(), PROFILE_GAME);

	CTimeValue now=gEnv->pTimer->GetFrameStartTime();

	TChannelShots::iterator csend=m_shots.end();
	for (TChannelShots::iterator csit=m_shots.begin(); csit!=csend; ++csit)
	{
		TShots &shots=csit->second;

		for (TShots::iterator shot=shots.begin(); shot!=shots.end();)
		{
			if (!Expired(now, *shot))
			{
				++shot;
				continue;
			}
			if(g_pGameCVars->g_debugShotValidator != 0)
			{
				CryLogAlways("expired shot found! seq: %d  id: %d  age: %.2f", shot->seq, shot->weaponId, (now-shot->time).GetMilliSeconds());
			}

			TShots::iterator erasing=shot++;
			shots.erase(erasing);
		}
	}

	TChannelHits::iterator chend=m_pendinghits.end();
	for (TChannelHits::iterator chit=m_pendinghits.begin(); chit!=chend; ++chit)
	{
		THits &hits=chit->second;
		for (THits::iterator hit=hits.begin(); hit!=hits.end();)
		{
			if(g_pGameCVars->g_debugShotValidator != 0)
			{
				CryLogAlways("aged hit found...");
				CryLogAlways(" &hit = %p", &hit);
				CryLogAlways(" Shot seq=%d, weapon=%d, time=%.2f, life=%d", hit->first.seq, hit->first.weaponId, hit->first.time.GetSeconds(), hit->first.life);
				CryLogAlways(" Hit time=%.2f", hit->second.time.GetMilliSeconds());
			}

			if (!Expired(now, hit->second))
			{
				++hit;
				continue;
			}

			DeclareExpired(chit->first, hit->second.info);

			if(g_pGameCVars->g_debugShotValidator != 0)
			{
				CryLogAlways("aged hit found! seq: %d  id: %d  age: %.2f", hit->second.info.seq, hit->second.info.weaponId, (now-hit->second.time).GetMilliSeconds());
			}

			THits::iterator erasing=hit++;
			hits.erase(erasing);
		}
	}
}

//------------------------------------------------------------------------
bool CShotValidator::CanHit(const HitInfo &hit) const
{
	if (m_doingHit || (hit.shooterId==hit.targetId) || !hit.weaponId || !hit.shooterId
		|| !m_pGameRules->GetActorByEntityId(hit.shooterId)
		|| !m_pItemSystem->GetItem(hit.weaponId)
		|| m_pGameFramework->GetClientActorId()==hit.shooterId)
		return true;

	return false;
}

//------------------------------------------------------------------------
bool CShotValidator::Expired(const CTimeValue &now, const TShot &shot) const
{
	if ((now-shot.time).GetMilliSeconds()>2000.0f)
		return true;
	else if (shot.life<=0)
		return true;

	return false;
}

//------------------------------------------------------------------------
bool CShotValidator::Expired(const CTimeValue &now, const THit &hit) const
{
	if ((now-hit.time).GetMilliSeconds()>500.0f)
		return true;
	return false;
}

//------------------------------------------------------------------------
void CShotValidator::DeclareExpired(int channelId, const HitInfo &hit)
{
	TChannelExpiredHits::iterator it=m_expired.find(channelId);
	if (it==m_expired.end())
	{
		std::pair<TChannelExpiredHits::iterator, bool> ir=m_expired.insert(TChannelExpiredHits::value_type(channelId, 0));
		it=ir.first;
	}

	++it->second;
}
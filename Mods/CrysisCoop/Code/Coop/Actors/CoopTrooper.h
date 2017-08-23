#ifndef __COOPTROOPER_H__
#define __COOPTROOPER_H__

#if _MSC_VER > 1000
# pragma once
#endif

#include "Trooper.h"


class CCoopTrooper : public CTrooper
{
public:
	CCoopTrooper();
	virtual ~CCoopTrooper();

	enum CoopTimers
	{
		eTIMER_WEAPONDELAY	= 0x110
	};

	//CCoopTrooper
	virtual bool Init( IGameObject * pGameObject );
	virtual void PostInit( IGameObject * pGameObject );
	virtual void Update(SEntityUpdateContext& ctx, int updateSlot);
	virtual bool NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags );
	virtual void ProcessEvent(SEntityEvent& event);
	virtual bool IsAnimEvent(const char* sAnimSignal, string* sAnimEventName, float* fEventTime);
	//~CCoopTrooper

protected:
	static const EEntityAspects ASPECT_ALIVE = eEA_GameServerDynamic;
	static const EEntityAspects ASPECT_HIDE = eEA_GameServerStatic;

	void RegisterMultiplayerAI();
	void UpdateMovementState();

private:
	Vec3 m_vLookTarget;
	Vec3 m_vAimTarget;

	int m_nStance;

	bool m_bHidden;
};


#endif //__COOPTROOPER_H__
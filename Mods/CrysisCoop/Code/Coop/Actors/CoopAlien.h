#ifndef __COOPALIEN_H__
#define __COOPALIEN_H__

#if _MSC_VER > 1000
# pragma once
#endif

#include "Alien.h"


class CCoopAlien : public CAlien
{
public:
	CCoopAlien();
	virtual ~CCoopAlien();

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
	//~CCoopTrooper

protected:
	static const EEntityAspects ASPECT_ALIVE = eEA_GameServerDynamic;
	static const EEntityAspects ASPECT_HIDE = eEA_GameServerStatic;

	void RegisterMultiplayerAI();
	void UpdateMovementState();
	void DrawDebugInfo();

private:
	Vec3 m_vMoveTarget;
	Vec3 m_vAimTarget;
	Vec3 m_vLookTarget;
	Vec3 m_vFireTarget;

	float m_fDesiredSpeed;

	int m_nStance;

	bool m_bAllowStrafing;
	bool m_bHasAimTarget;

	bool m_bHidden;
};


#endif //__COOPALIEN_H__
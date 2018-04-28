#ifndef __COOPALIEN_H__
#define __COOPALIEN_H__

#if _MSC_VER > 1000
# pragma once
#endif

#include "Alien.h"
#include "..\CoopSystem.h"

class CCoopAlien 
	: public CAlien
	, protected ICoopSystemEventListener
{
public:
	CCoopAlien();
	virtual ~CCoopAlien();

	// ICoopSystemEventListener

	// Summary:
	//	Called before the game rules have reseted entities.
	virtual void OnPreResetEntities() override;

	// Summary:
	//	Called after the game rules have reseted entities and the coop system has re-created AI objects.
	virtual void OnPostResetEntities() override;

	// ~ICoopSystemEventListener

	void RegisterMultiplayerAI();

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
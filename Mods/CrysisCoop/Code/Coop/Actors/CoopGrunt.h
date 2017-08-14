#ifndef __COOPGRUNT_H__
#define __COOPGRUNT_H__

#if _MSC_VER > 1000
# pragma once
#endif

#include "Player.h"


class CCoopGrunt :	public CPlayer
{
public:
	CCoopGrunt();
	virtual ~CCoopGrunt();

	//CPlayer
	virtual bool Init( IGameObject * pGameObject );
	virtual void PostInit( IGameObject * pGameObject );
	virtual void Update(SEntityUpdateContext& ctx, int updateSlot);
	virtual bool NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags );
	virtual void ProcessEvent(SEntityEvent& event);
	//~CPlayer

	enum CoopTimers
	{
		eTIMER_WEAPONDELAY	= 0x110
	};

    struct SSuitParams
    {
		SSuitParams() {};
		SSuitParams(int suit): 
			suitmode(suit) 
		{};
        int suitmode;
        void SerializeWith(TSerialize ser)
        {
            ser.Value("suitmode", suitmode);
        }
    };

	int GetAlertnessState() const { return m_nAlertness; }

	DECLARE_CLIENT_RMI_NOATTACH(ClChangeSuitMode, SSuitParams, eNRT_ReliableOrdered);

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
	Vec3 m_vBodyTarget;
	Vec3 m_vFireTarget;

	float m_fPseudoSpeed;
	float m_fDesiredSpeed;

	int m_nAlertness;
	int m_nStance;
	int m_nSuitMode;

	bool m_bAllowStrafing;
	bool m_bHasAimTarget;

	bool m_bHidden;
};


#endif //__COOPGRUNT_H__
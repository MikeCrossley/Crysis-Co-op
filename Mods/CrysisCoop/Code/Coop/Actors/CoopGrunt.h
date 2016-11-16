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

    struct SAimParams
    {
		SAimParams() {};
		SAimParams(bool baiming): 
			bAiming(baiming) 
		{};
        bool bAiming;
        void SerializeWith(TSerialize ser)
        {
            ser.Value("bAiming", bAiming);
        }
    };

	int GetAlertnessState(){return m_coopAlertness;};

	DECLARE_CLIENT_RMI_NOATTACH(ClChangeSuitMode, SSuitParams, eNRT_ReliableOrdered);
 	DECLARE_CLIENT_RMI_NOATTACH(ClChangeStance, SSuitParams, eNRT_ReliableOrdered);
	DECLARE_CLIENT_RMI_NOATTACH(ClUpdateAiming, SAimParams, eNRT_ReliableOrdered);

protected:
	static const int ASPECT_ALIVE = eEA_GameServerDynamic;

private:
	Vec3 m_coopMoveTarget;
	Vec3 m_coopAimTarget;
	Vec3 m_coopLookTarget;
	Vec3 m_coopBodyTarget;
	Vec3 m_coopFireTarget;

	float m_fPseudoSpeed;
	float m_fcoopDesiredSpeed;

	int m_coopAlertness;
	int m_coopStance;
	int m_coopsuitMode;

	bool m_bAllowStrafing;
	bool m_bHasAimTarget;
};


#endif //__COOPGRUNT_H__
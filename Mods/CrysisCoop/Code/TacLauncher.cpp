/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2008.
-------------------------------------------------------------------------
$Id:$
$DateTime$
Description:  Class for specific tac launcher functionality. 
							Based on CRocketLauncher
-------------------------------------------------------------------------
History:
- 08:06:2008: Created by Steve Humphreys

*************************************************************************/

#include "StdAfx.h"
#include "TacLauncher.h"

#include "Actor.h"
#include "GameRules.h"

CTacLauncher::CTacLauncher()
{
	m_smokeEffectSlot = -1;
}

//========================================
void CTacLauncher::OnReset()
{
	CWeapon::OnReset();

	if(m_smokeEffectSlot!=-1)
	{
		GetEntity()->FreeSlot(m_smokeEffectSlot);
		m_smokeEffectSlot = -1;
	}
}

//========================================
void CTacLauncher::FullSerialize(TSerialize ser)
{
	CWeapon::FullSerialize(ser);

	int smoke = m_smokeEffectSlot;
	ser.Value("smokeEffect", m_smokeEffectSlot);

	if(ser.IsReading())
	{	
		if((smoke!=-1) && (m_smokeEffectSlot==-1))
			GetEntity()->FreeSlot(smoke);
	}
}

//=========================================
void CTacLauncher::PostSerialize()
{
	CWeapon::PostSerialize();

	if(m_smokeEffectSlot>-1)
		Pickalize(false,true);
}

void CTacLauncher::AutoDrop()
{
	if(m_fm)
	{
		CActor* pOwner = GetOwnerActor();
		// no need to auto-drop for AI
		if(pOwner && !pOwner->IsPlayer())
			return;

		if(GetAmmoCount(m_fm->GetAmmoType())<=0)
		{
			// kirill - need drop delay, so if using scope - player can see result
			if( pOwner )
				pOwner->SetDropWeaponTimer( GetEntityId(), 2.f);
			else if(!gEnv->bMultiplayer)
				g_pGame->GetGameRules()->ScheduleEntityRemoval(GetEntityId(),5.0f,true);
		}
	}
}

//========================================
void CTacLauncher::Drop(float impulseScale, bool selectNext, bool byDeath)
{
	bool empty = false;
	IEntityClass* pAmmo = m_fm->GetAmmoType();
	CActor* pOwner = GetOwnerActor();
	if(pAmmo && GetAmmoCount(pAmmo)<=0 && (!pOwner || pOwner->GetInventory()->GetAmmoCount(pAmmo)<=0))
		empty = true;

	// specifically move all ammo into the weapon
	for (TFireModeVector::iterator it=m_firemodes.begin(); it!=m_firemodes.end(); ++it)
	{
		IFireMode *fm=*it;
		if (!fm)
			continue;

		IEntityClass* ammo=fm->GetAmmoType();
		int invCount=GetInventoryAmmoCount(ammo);
		if (invCount)
		{
			SetInventoryAmmoCount(ammo, 0);
			m_bonusammo[ammo]=invCount;
		}
	}

	CWeapon::Drop(impulseScale,selectNext,byDeath);

	if(empty)
	{
		Pickalize(false,true);
		if(m_smokeEffectSlot==-1)
		{
			IParticleEffect * pEffect = gEnv->p3DEngine->FindParticleEffect("weapon_fx.LAW.empty");

			if(pEffect)
				m_smokeEffectSlot = GetEntity()->LoadParticleEmitter(-1,pEffect);
		}
	}
}

//=========================================
bool CTacLauncher::CanPickUp(EntityId userId) const
{
	CActor *pActor = GetActor(userId);
	IInventory *pInventory=GetActorInventory(pActor);

	if (m_params.pickable && m_stats.pickable && !m_stats.flying && !m_frozen &&(!m_ownerId || m_ownerId==userId) && !m_stats.selected && !GetEntity()->IsHidden())
	{
		if (pInventory && pInventory->FindItem(GetEntityId())!=-1)
			return false;
	}
	else
		return false;

//	uint8 uniqueId = m_pItemSystem->GetItemUniqueId(GetEntity()->GetClass()->GetName());

	//Can not pick up a tac launcher while I have one already 
// 	if(pInventory && (pInventory->GetCountOfUniqueId(uniqueId)>0))
// 	{
// 		if(pActor->IsClient())
// 			g_pGame->GetGameRules()->OnTextMessage(eTextMessageCenter, "@mp_CannotCarryMoreLAW");
// 		return false;
// 	}

	return true;
		
}

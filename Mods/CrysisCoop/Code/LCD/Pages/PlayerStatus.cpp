/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
*************************************************************************/
#include "StdAfx.h"
#include "resource.h"
#include "PlayerStatus.h"
#include "../../HUD/HUD.h"
#include "../../Weapon.h"
#include "../LCDImage.h"
#include "GameRules.h"

#ifdef USE_G15_LCD

CPlayerStatus::CPlayerStatus()
: m_healthProgress(0)
, m_energyProgress(0)
{
}

CPlayerStatus::~CPlayerStatus()
{
}

bool	CPlayerStatus::PreUpdate()
{
	CPlayer *pPlayer = static_cast<CPlayer*>(gEnv->pGame->GetIGameFramework()->GetClientActor());

	if ((pPlayer && !g_pGame->GetGameRules()->IsPlayerActivelyPlaying(pPlayer->GetEntityId())) || 
			GetEzLcd()->ButtonIsPressed(LG_BUTTON_2))
	{
		GetG15LCD()->SetCurrentPage(GetG15LCD()->GameStatusPage);
		return false;
	}
	return CLCDPage::PreUpdate();
}

//m_bigOverlayText
void CPlayerStatus::Update(float frameTime)
{
	MakeModifyTarget();

	CPlayer *pPlayer = static_cast<CPlayer*>(gEnv->pGame->GetIGameFramework()->GetClientActor());
	if(pPlayer)
	{
		const SPlayerStats stats = *(static_cast<SPlayerStats*>(pPlayer->GetActorStats()));
		float fHealth = (pPlayer->GetHealth() / float(pPlayer->GetMaxHealth())) * 100.0f;
		GetEzLcd()->SetProgressBarPosition(m_healthProgress, stats.spectatorMode?100.0f:fHealth);
		float fEnergy = pPlayer->GetNanoSuit()->GetSuitEnergy()*0.5f;
		GetEzLcd()->SetProgressBarPosition(m_energyProgress, fEnergy);

		bool hasGrenades = false;
		hasGrenades |= UpdateAmmoCountText(m_explosiveText, pPlayer, CItem::sExplosiveGrenade) != 0;
		hasGrenades |= UpdateAmmoCountText(m_flashbangText, pPlayer, CItem::sFlashbangGrenade) != 0;
		hasGrenades |= UpdateAmmoCountText(m_smokeText, pPlayer, CItem::sSmokeGrenade) != 0;
		hasGrenades |= UpdateAmmoCountText(m_nanoText, pPlayer, CItem::sEMPGrenade) != 0;

		UpdateWeapon(pPlayer);

		IItem *pOffhand = g_pGame->GetIGameFramework()->GetIItemSystem()->GetItem(pPlayer->GetInventory()->GetItemByClass(CItem::sOffHandClass));
		if(pOffhand)
		{
			m_pGrenadeSelect->SetVisible(false);
			int firemode = pOffhand->GetIWeapon()->GetCurrentFireMode();
			if(IFireMode *pFm = pOffhand->GetIWeapon()->GetFireMode(firemode))
			{
				if(pFm->GetAmmoType())
				{
					int x = -1;
					if (pFm->GetAmmoType() == CItem::sExplosiveGrenade)
					{
						x = 0;							
					}
					else if (pFm->GetAmmoType() == CItem::sSmokeGrenade)
					{
						x = 18;							
					}
					else if (pFm->GetAmmoType() == CItem::sFlashbangGrenade)
					{
						x = 39;							
					}
					else if (pFm->GetAmmoType() == CItem::sEMPGrenade)
					{
						x = 59;							
					}
					if (x != -1)
					{
						m_pGrenadeSelect->SetOrigin(x, 31);
						m_pGrenadeSelect->SetVisible(hasGrenades);
					}
				}
			}
		}

		CNanoSuit* pSuit = pPlayer->GetNanoSuit();
		if (pSuit)
		{
			ENanoMode currentMode = pSuit->GetMode();
			m_pSuitArmor->SetVisible(NANOMODE_DEFENSE == currentMode);
			m_pSuitCloak->SetVisible(NANOMODE_CLOAK == currentMode);
			m_pSuitSpeed->SetVisible(NANOMODE_SPEED == currentMode);
			m_pSuitStrength->SetVisible(NANOMODE_STRENGTH == currentMode);
		}
	}
}

void CPlayerStatus::OnAttach()
{
	m_pItemAY69 = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_AY69), false);
	m_pItemDSG1 = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_DSG1), false);
	m_pItemDualAY69 = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_DOUBLEAY69), false);
	m_pItemFY71 = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_FY71), false);
	m_pItemFists = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_FISTS), false);
	m_pItemFGL40 = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_FGL40), false);
	m_pItemGauss = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_GAUSS), false);
	m_pItemHurricane = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_HURRICANE), false);
	m_pItemLAW = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_LAW), false);
	m_pItemSCAR = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_SCAR), false);
	m_pItemShotgun = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_SHOTGUN), false);
	m_pItemSMG = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_SMG), false);
	m_pItemSOCOM = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_SOCOM), false);
	m_pItemDualSOCOM = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_DUALSOCOM), false);
	m_pItemTACGun = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_TACGUN), false);
	m_pItemTool = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_LOCKPICKKIT), false);
	m_pItemMOAR = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_MOAR), false);
	m_pItemMOAC = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_MOAC), false);
	m_pItemC4 = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_C4BLOCK), false);
	m_pItemClaymore = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_CLAY_MORE), false);
	m_pItemRadar = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_RADARKIT), false);
	m_pItemRepair = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_REPAIRTOOL), false);
	m_pItemMine = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ITEM_MINE), false);

	m_pCurrentVehicleDisplayed = NULL;
	m_vehicleIconMap.clear();
	CLCDImage *pLTVImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_LTVUS), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_ltv")] = pLTVImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_ltv")] = pLTVImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Civ_car1")] = pLTVImage;
	CLCDImage *pTankImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_TANK), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_tank")] = pTankImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_tank")] = pTankImage;
	CLCDImage *pAPCImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_APC), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_apc")] = pAPCImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_apc")] = pAPCImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_aaa")] = pAPCImage;
	CLCDImage *pTruckImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_TRUCK), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_truck")] = pTruckImage;
	CLCDImage *pBoatImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_BOAT), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_smallboat")] = pBoatImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Civ_speedboat")] = pBoatImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_patrolboat")] = pBoatImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_hovercraft")] = pBoatImage;
	CLCDImage *pHeliImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_HELICOPTER), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_vtol")] = pHeliImage;
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("Asian_helicopter")] = pHeliImage;
	CLCDImage *pASVImage = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_VEHICLE_ASV), false);
	m_vehicleIconMap[gEnv->pEntitySystem->GetClassRegistry()->FindClass("US_asv")] = pASVImage;

	m_ammoText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_RIGHT, 60);
	GetEzLcd()->SetOrigin(m_ammoText, 100, 19);

	m_pEnergy = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_ENERGY));
	m_pEnergy->SetOrigin(100, 27);

	m_energyProgress = GetEzLcd()->AddProgressBar(LG_FILLED);
	GetEzLcd()->SetProgressBarSize(m_energyProgress, 50, 5);
	GetEzLcd()->SetOrigin(m_energyProgress, 109, 28);
	GetEzLcd()->SetProgressBarPosition(m_energyProgress, 0.0f);

	m_pHealth = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_HEALTH));
	m_pHealth->SetOrigin(100, 35);

	m_healthProgress = GetEzLcd()->AddProgressBar(LG_FILLED);
	GetEzLcd()->SetProgressBarSize(m_healthProgress, 50, 5);
	GetEzLcd()->SetOrigin(m_healthProgress, 109, 36);
	GetEzLcd()->SetProgressBarPosition(m_healthProgress, 0.0f);

	m_pGrenadeExplosive = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_GRENADE_EXPLOSIVE));
	m_pGrenadeExplosive->SetOrigin(0,33);
	m_explosiveText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_CENTER, 10);
	GetEzLcd()->SetOrigin(m_explosiveText, 8, 34);

	m_pGrenadeSmoke = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_GRENADE_SMOKE));
	m_pGrenadeSmoke->SetOrigin(18, 33);
	m_smokeText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_CENTER, 10);
	GetEzLcd()->SetOrigin(m_smokeText, 28, 34);

	m_pGrenadeFlashbang = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_GRENADE_FLASHBANG));
	m_pGrenadeFlashbang->SetOrigin(39, 33);
	m_flashbangText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_CENTER, 10);
	GetEzLcd()->SetOrigin(m_flashbangText, 49, 34);

	m_pGrenadeNano = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_GRENADE_NANO));
	m_pGrenadeNano->SetOrigin(59, 33);
	m_nanoText = GetEzLcd()->AddText(LG_STATIC_TEXT, LG_SMALL, DT_CENTER, 10);
	GetEzLcd()->SetOrigin(m_nanoText, 68, 34);

	m_pGrenadeSelect = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_GRENADE_SELECT), false);

	m_pSuitArmor = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_SUIT_ARMOR), false);
	m_pSuitCloak = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_SUIT_CLOAK), false);
	m_pSuitSpeed = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_SUIT_SPEED), false);
	m_pSuitStrength = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_SUIT_STRENGTH), false);
}

int CPlayerStatus::UpdateAmmoCountText(HANDLE text, CPlayer* pPlayer, IEntityClass* pClass)
{
	int amount = pPlayer->GetInventory()->GetAmmoCount(pClass);
	if (amount)
	{
		char buffer[128];
		_snprintf(buffer, 128, "%d", amount);
		GetEzLcd()->SetText(text, buffer);
	}
	GetEzLcd()->SetVisible(text, amount != 0);
	return amount;
}

void CPlayerStatus::UpdateWeapon(CPlayer* pPlayer)
{
	IVehicle *pVehicle = pPlayer->GetLinkedVehicle();
	IItem *pItem = pPlayer->GetCurrentItem(false);
	int ammo = -1;
	int clipSize = -1;
	int restAmmo = -1;

	if(pItem)
	{
		if(CWeapon *pWeapon = static_cast<CWeapon*>(pItem->GetIWeapon()))
		{
			int fm = pWeapon->GetCurrentFireMode();
			if(IFireMode *pFM = pWeapon->GetFireMode(fm))
			{
				ammo = pFM->GetAmmoCount();
				if(IItem *pSlave = pWeapon->GetDualWieldSlave())
				{
					if(IWeapon *pSlaveWeapon = pSlave->GetIWeapon())
						if(IFireMode *pSlaveFM = pSlaveWeapon->GetFireMode(pSlaveWeapon->GetCurrentFireMode()))
							ammo += pSlaveFM->GetAmmoCount();
				}
				clipSize = pFM->GetClipSize();
				restAmmo = pPlayer->GetInventory()->GetAmmoCount(pFM->GetAmmoType());


				char buffer[128];
				if(!pVehicle)
					_snprintf(buffer, 128, "%03d / %03d", ammo, restAmmo);
				else
					_snprintf(buffer, 128, "");
				GetEzLcd()->SetText(m_ammoText, buffer);

				if(pFM->CanOverheat())
				{
					//int heat = int(pFM->GetHeat()*100.0f);
				}
			}
			static IEntityClass* sFY71Class = gEnv->pEntitySystem->GetClassRegistry()->FindClass("FY71");
			static IEntityClass* sHurricaneClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("Hurricane");
			static IEntityClass* sSCARClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("SCAR");
			static IEntityClass* sFGL40Class = gEnv->pEntitySystem->GetClassRegistry()->FindClass("FGL40");
			static IEntityClass* sShotgunClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("Shotgun");
			static IEntityClass* sSMGClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("SMG");
			static IEntityClass* sRadarClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("RadarKit");
			static IEntityClass* sRepairClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("RepairKit");
			static IEntityClass* sClaymoreClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("Claymore");
			static IEntityClass* sAVMine = gEnv->pEntitySystem->GetClassRegistry()->FindClass("AVMine");
			static IEntityClass* sLockPickClass = gEnv->pEntitySystem->GetClassRegistry()->FindClass("LockpickKit");
			IEntityClass* pCurrentClass = pItem->GetEntity()->GetClass();

			UpdateWeaponImage(m_pItemAVExplosive, CItem::sAVExplosiveClass, pCurrentClass);
			UpdateWeaponImage(m_pItemC4, CItem::sC4Class, pCurrentClass);
			UpdateWeaponImage(m_pItemClaymore, sClaymoreClass, pCurrentClass);
			UpdateWeaponImage(m_pItemDSG1, CItem::sDSG1Class, pCurrentClass);
			UpdateWeaponImage(m_pItemAY69, CItem::sAY69Class, pCurrentClass);
			UpdateWeaponImage(m_pItemFists, CItem::sFistsClass, pCurrentClass);
			UpdateWeaponImage(m_pItemFY71, sFY71Class, pCurrentClass);
			UpdateWeaponImage(m_pItemFGL40, sFGL40Class, pCurrentClass);
			UpdateWeaponImage(m_pItemGauss, CItem::sGaussRifleClass, pCurrentClass);
			UpdateWeaponImage(m_pItemHurricane, sHurricaneClass, pCurrentClass);
			UpdateWeaponImage(m_pItemLAW, CItem::sRocketLauncherClass, pCurrentClass);
			UpdateWeaponImage(m_pItemSCAR, sSCARClass, pCurrentClass);
			UpdateWeaponImage(m_pItemShotgun, sShotgunClass, pCurrentClass);
			UpdateWeaponImage(m_pItemSMG, sSMGClass, pCurrentClass);
			UpdateWeaponImage(m_pItemSOCOM, CItem::sSOCOMClass, pCurrentClass);
			UpdateWeaponImage(m_pItemRadar, sRadarClass, pCurrentClass);
			UpdateWeaponImage(m_pItemRepair, sRepairClass, pCurrentClass);
			UpdateWeaponImage(m_pItemMine, sAVMine, pCurrentClass);
			UpdateWeaponImage(m_pItemTool, sLockPickClass, pCurrentClass);

			// dual socom
			if (m_pItemSOCOM->GetVisible() && pWeapon->IsDualWield())
			{
				m_pItemSOCOM->SetVisible(0);
				UpdateWeaponImage(m_pItemDualSOCOM, CItem::sSOCOMClass, pCurrentClass);
			}
			else
				m_pItemDualSOCOM->SetVisible(false);

			// dual AY69s
			if (m_pItemAY69->GetVisible() && pWeapon->IsDualWield())
			{
				m_pItemAY69->SetVisible(0);
				UpdateWeaponImage(m_pItemDualAY69, CItem::sAY69Class, pCurrentClass);
			}
			else
				m_pItemDualAY69->SetVisible(false);

			//Alien weapons
			if (UpdateWeaponImage(m_pItemMOAR, CItem::sAlienMountClass, pCurrentClass))
			{
				//TODO: distinguish between MOAC and MOAR
			}

			if(!UpdateWeaponImage(m_pItemTACGun, CItem::sTACGunClass, pCurrentClass))
				UpdateWeaponImage(m_pItemTACGun, CItem::sTACGunFleetClass, pCurrentClass);
		}
	}

	//vehicle overwrites weapon
	if(pVehicle)
	{
		CLCDImage *pImage = stl::find_in_map(m_vehicleIconMap, pVehicle->GetEntity()->GetClass(), NULL);
		if(pImage && pImage != m_pCurrentVehicleDisplayed)
		{
			if(m_pCurrentVehicleDisplayed)
				m_pCurrentVehicleDisplayed->SetVisible(false);
			pImage->SetOrigin(100, 0);
			pImage->SetVisible(true);
			m_pCurrentVehicleDisplayed = pImage;
		}

		//remove ammo text
		char buffer[2];
		_snprintf(buffer, 2, "");
		GetEzLcd()->SetText(m_ammoText, buffer);
	}
	else if(m_pCurrentVehicleDisplayed)
	{
		m_pCurrentVehicleDisplayed->SetVisible(false);
		m_pCurrentVehicleDisplayed = NULL;
	}

}

bool CPlayerStatus::UpdateWeaponImage(CLCDImage* image, IEntityClass* pClass, IEntityClass* pCurrentItem)
{
	if (image)
	{
		image->SetVisible(false);
		if (pCurrentItem == pClass)
		{
			image->SetOrigin(100, 0);
			image->SetVisible(true);
			return true;
		}
	}
	return false;
}

#endif
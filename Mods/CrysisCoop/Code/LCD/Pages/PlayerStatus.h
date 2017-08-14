/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
Description:  - Player Status (player health, suit mode, grenades, weapon, etc..).
							- Things which are game mode independent.
							- Sits on slot 1
-------------------------------------------------------------------------
History:
- 13:11:2007: Created by Marco Koegler

*************************************************************************/
#ifndef __PLAYERSTATUS_H__
#define __PLAYERSTATUS_H__

#ifdef USE_G15_LCD
#include "../LCDPage.h"

class CPlayer;

class CPlayerStatus : public CLCDPage
{
public:
	CPlayerStatus();
	virtual ~CPlayerStatus();

	virtual bool	PreUpdate();
	virtual void	Update(float frameTime);

protected:
	virtual void OnAttach();

	int UpdateAmmoCountText(HANDLE text, CPlayer* pPlayer, IEntityClass* pClass);
	void UpdateWeapon(CPlayer* pPlayer);
	bool UpdateWeaponImage(CLCDImage* image, IEntityClass* pClass, IEntityClass* pCurrentItem);

private:
	_smart_ptr<CLCDImage>	m_pEnergy;
	HANDLE								m_energyProgress;
	_smart_ptr<CLCDImage> m_pHealth;
	HANDLE								m_healthProgress;
	HANDLE								m_ammoText;

	_smart_ptr<CLCDImage> m_pGrenadeExplosive;
	HANDLE								m_explosiveText;
	_smart_ptr<CLCDImage> m_pGrenadeSmoke;
	HANDLE								m_smokeText;
	_smart_ptr<CLCDImage> m_pGrenadeFlashbang;
	HANDLE								m_flashbangText;
	_smart_ptr<CLCDImage> m_pGrenadeNano;
	HANDLE								m_nanoText;

	_smart_ptr<CLCDImage> m_pGrenadeSelect;

	// weapons
	_smart_ptr<CLCDImage>	m_pItemAVExplosive;
	_smart_ptr<CLCDImage>	m_pItemC4;
	_smart_ptr<CLCDImage>	m_pItemClaymore;
	_smart_ptr<CLCDImage>	m_pItemAY69;
	_smart_ptr<CLCDImage>	m_pItemDSG1;
	_smart_ptr<CLCDImage>	m_pItemDualAY69;
	_smart_ptr<CLCDImage>	m_pItemFists;
	_smart_ptr<CLCDImage>	m_pItemFY71;
	_smart_ptr<CLCDImage>	m_pItemFGL40;
	_smart_ptr<CLCDImage>	m_pItemGauss;
	_smart_ptr<CLCDImage>	m_pItemHurricane;
	_smart_ptr<CLCDImage>	m_pItemLAW;
	_smart_ptr<CLCDImage>	m_pItemMOAR;
	_smart_ptr<CLCDImage>	m_pItemMOAC;
	_smart_ptr<CLCDImage>	m_pItemSCAR;
	_smart_ptr<CLCDImage>	m_pItemShotgun;
	_smart_ptr<CLCDImage>	m_pItemSMG;
	_smart_ptr<CLCDImage>	m_pItemSOCOM;
	_smart_ptr<CLCDImage>	m_pItemDualSOCOM;
	_smart_ptr<CLCDImage>	m_pItemTACGun;
	_smart_ptr<CLCDImage>	m_pItemTool;
	_smart_ptr<CLCDImage>	m_pItemRadar;
	_smart_ptr<CLCDImage>	m_pItemRepair;
	_smart_ptr<CLCDImage>	m_pItemMine;

	// vehicles
	CLCDImage* m_pCurrentVehicleDisplayed;
	std::map<IEntityClass*, _smart_ptr<CLCDImage>> m_vehicleIconMap;

	_smart_ptr<CLCDImage>	m_pSuitArmor;
	_smart_ptr<CLCDImage>	m_pSuitCloak;
	_smart_ptr<CLCDImage>	m_pSuitSpeed;
	_smart_ptr<CLCDImage>	m_pSuitStrength;
};

#endif //USE_G15_LCD

#endif
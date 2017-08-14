/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: PowerStruggle mode HUD (BuyMenu) code (refactored from old HUD code)

-------------------------------------------------------------------------
History:
- 21:02:20067  20:00 : Created by Jan M�ller

*************************************************************************/

#ifndef HUD_POWER_STRUGGLE_H
#define HUD_POWER_STRUGGLE_H

# pragma once


#include "HUDObject.h"

#include "HUD.h"

class CGameFlashAnimation;

class CHUDPowerStruggle : public CHUDObject
{
	friend class CHUD;
public:

	CHUDPowerStruggle(CHUD *pHUD, CGameFlashAnimation *pBuyMenu, CGameFlashAnimation *pHexIcon);
	~CHUDPowerStruggle();

	void Update(float fDeltaTime);
	void Reset();

	//buyable item types
	enum EBuyMenuPage
	{
		E_WEAPONS				= 1 << 0,
		E_VEHICLES			= 1 << 1,
		E_EQUIPMENT			= 1 << 2,
		E_AMMO					= 1 << 3,
		E_PROTOTYPES		= 1 << 4,
		E_LOADOUT				= 1 << 5
	};

	enum EHexIconState
	{
		E_HEX_ICON_NONE,
		E_HEX_ICON_EXPOSURE,
		E_HEX_ICON_CAPTURING,
		E_HEX_ICON_BUY,
		E_HEX_ICON_BUILDING,
		E_HEX_ICON_LAST
	};

	struct SItem
	{
		string strName;
		string strDesc;
		string strClass;
		string strCategory;
		int uniqueLoadoutGroup;
		int uniqueLoadoutCount;
		int iPrice;
		int isUnique;
		int iCount;
		int iMaxCount;
		int iInventoryID;
		float level;
		bool isWeapon;
		bool bAmmoType;
		bool bVehicleType;
		bool loadout;
		bool special;
	};

	struct SEquipmentPack
	{
		string strName;
		int iPrice;
		std::vector<SItem> itemArray;
	};

	virtual bool IsFactoryType(EntityId entity, EBuyMenuPage type);
	virtual bool CanBuild(IEntity *pEntity, const char *vehicle);
	virtual bool CanBuy(IEntity *pEntity, const char *classname);

	bool IsPlayerSpecial();

	void ObjectiveStatusChanged();

	void UpdateLastPurchase();
	void ResetBuyZones();
	void UpdateBuyZone(bool trespassing, EntityId zone);
	void UpdateServiceZone(bool trespassing, EntityId zone);
	void UpdateBuyList(const char *page = NULL);
	void Scroll(int direction);

	//	Swing-O-Meter interface
	// sets current client team
	void SetSOMTeam(int teamId);
	// hide/unhide SOM
	void HideSOM(bool hide);

	void DetermineCurrentBuyZone(bool sendToFlash = false, bool force = false);

	int GetTeamPower(int teamId);
	void ShowCaptureProgress(bool show);
	void SetCaptureProgress(float progress);
	void SetCaptureContested(bool contested);

	bool IsVehicle(const char *name);

	void ShowConstructionProgress(bool show, bool queued, float time);

	ILINE EHexIconState GetCurrentIconState() {return m_currentHexIconState; };
	
	ILINE void SetLastPurchase(const char* itemName)
	{
		SItem itemdef;
		if(GetItemFromName(itemName, itemdef))
		{
			itemdef.iInventoryID = 0;
			m_thisPurchase.itemArray.push_back(itemdef);
			m_thisPurchase.iPrice += itemdef.iPrice;
			g_pHUD->m_listBoughtItems.push_back(itemdef.strClass);
		}
	}
private:

	int GetPlayerPP();
	int GetPlayerTeamScore();
	void Buy(const char* item, bool reload = true);

	void DeletePackage(int index);
	void BuyPackage(int index);
	void BuyPackage(SEquipmentPack equipmentPackage);

	void InitEquipmentPacks();
	void SaveEquipmentPacks();
	SEquipmentPack LoadEquipmentPack(int index);
	void SavePackage(const char *name, int index = -1);
	void RequestNewLoadoutName(string &name, const char *bluePrint, int index = -1);
	bool CheckDoubleLoadoutName(const char *name, int index);
	void CreateItemFromTableEntry(IScriptTable *pItemScriptTable, SItem &item);
	bool GetItemFromName(const char *name, SItem &item);

	bool WeaponUseAmmo(CWeapon *pWeapon, IEntityClass* pAmmoType);
	bool CanUseAmmo(IEntityClass* pAmmoType);
	void GetItemList(EBuyMenuPage itemType, std::vector<SItem> &itemList, bool buyMenu = true );
	void PopulateBuyList();
	void UpdateEnergyBuyList(int energy_before, int energy_after);
	void UpdatePackageItemList(const char *page);
	EBuyMenuPage ConvertToBuyList(const char *page);
	void ActivateBuyMenuTabs();
	void UpdatePackageList();
	void UpdateCurrentPackage();
	void OnSelectPackage(int index);
	void UpdateModifyPackage(int index);
	void SetObjectiveMessage(const char* msg, const char* param = NULL, bool enemy = true);
	int IsCapturing(IEntity *site);
	bool IsUncapturing(IEntity *site);
	bool IsContested(IEntity *site);

	//****************************************** MEMBER VARIABLES ***********************************

	//current active buy zones
	std::vector<EntityId> m_currentBuyZones;
	//current active buy zones
	std::vector<EntityId> m_currentServiceZones;
	
	//standing in buy zone ? Or service zone ?
	bool m_bInBuyZone;
	bool m_bInServiceZone;
	//-2=inactive, -1=catch page, 1-0=catch item on page
	int m_iCatchBuyMenuPage;	
	//available equipment packs
	std::vector<SEquipmentPack> m_EquipmentPacks;
	//items bought between the last buy menu open and buy menu close
	SEquipmentPack m_lastPurchase;
	//items bought in a sequence after buy menu open
	SEquipmentPack m_thisPurchase;
	//current buy menu page
	EBuyMenuPage	m_eCurBuyMenuPage;
	//buy menu flash movie - managed by HUD
	CGameFlashAnimation *g_pBuyMenu;
	CGameFlashAnimation *g_pHexIcon;
	//swing-o-meter - managed here
	CGameFlashAnimation m_animSwingOMeter;
	//the main hud
	CHUD *g_pHUD;
	//currently available buy menu pages
	std::vector<bool> m_factoryTypes;
	std::vector<bool> m_serviceZoneTypes;
	
	//swing-o-meter setup
	bool	m_nkLeft;

	//new powerstruggle rules 
	std::vector<EntityId> m_powerpoints;
	std::vector<EntityId> m_hqs;
	std::vector<EntityId> m_endgameWeaponOwners;
	
	bool m_gotpowerpoints;
	EntityId m_protofactory;

	bool m_capturing;
	float m_captureProgress;

	bool m_constructing;
	bool m_constructionQueued;
	float m_constructionTime;
	float m_constructionTimer;
	int		m_lastConstructionTime;
	int		m_lastBuildingTime;
	EHexIconState m_currentHexIconState;

	int	m_aliens[5];
	int m_contested[5];
	int m_teamId;
	int m_factoryOwner;
	bool m_factoryContested;
	int m_time;
	int m_lastPowerTeam1, m_lastPowerTeam2;
	int m_lastEndgameTeam1, m_lastEndgameTeam2;

	int m_cheapestWMD;

	const char* m_currentObjective;
	const char* m_currentObjectiveParam;
	float m_lastObjectiveUpdate;
};

#endif

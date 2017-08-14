////////////////////////////////////////////////////////////////////////////
//
//  Crytek Engine Source File.
//  Copyright (C), Crytek Studios, 2006.
// -------------------------------------------------------------------------
//  File name:   EquipmentSystem.cpp
//  Version:     v1.00
//  Created:     07/07/2006 by AlexL
//  Compilers:   Visual Studio.NET
//  Description: Interface for Editor to access CryAction/Game specific equipments
// -------------------------------------------------------------------------
//  History:
//
////////////////////////////////////////////////////////////////////////////
#include "StdAfx.h"
#include "EquipmentSystemInterface.h"

#include <IGame.h>
#include <IGameFramework.h>
#include <IItemSystem.h>
#include "ItemParamReader.h"

CEquipmentSystemInterface::CEquipmentSystemInterface(CEditorGame* pEditorGame, IGameToEditorInterface *pGameToEditorInterface)
: m_pEditorGame(pEditorGame)
{
	m_pIItemSystem = gEnv->pGame->GetIGameFramework()->GetIItemSystem();
	m_pIEquipmentManager = m_pIItemSystem->GetIEquipmentManager();
	InitItems(pGameToEditorInterface);
}

CEquipmentSystemInterface::~CEquipmentSystemInterface()
{
}

class CEquipmentSystemInterface::CIterator : public IEquipmentSystemInterface::IEquipmentItemIterator
{
public:
	CIterator(CEquipmentSystemInterface* pESI, const char* type)
	{
		m_pESI  = pESI;
		m_nRefs = 0;
		m_type  = type;
		if (m_type.empty())
		{
			m_mapIterCur = m_pESI->m_itemMap.begin();
			m_mapIterEnd = m_pESI->m_itemMap.end();
		}
		else
		{
			m_mapIterCur = m_pESI->m_itemMap.find(type);
			m_mapIterEnd = m_mapIterCur;
			if (m_mapIterEnd != m_pESI->m_itemMap.end())
				++m_mapIterEnd;
		}
		if (m_mapIterCur != m_mapIterEnd)
		{
			m_itemIterCur = m_mapIterCur->second.begin();
			m_itemIterEnd = m_mapIterCur->second.end();
		}
	}
	void AddRef()
	{
		++m_nRefs;
	}
	void Release()
	{
		if (--m_nRefs <= 0)
			delete this;
	}
	bool Next(SEquipmentItem& outItem)
	{
		if (m_mapIterCur != m_mapIterEnd)
		{
			if (m_itemIterCur != m_itemIterEnd)
			{
				outItem.name = (*m_itemIterCur).c_str();
				outItem.type = m_mapIterCur->first.c_str();
				++m_itemIterCur;
				if (m_itemIterCur == m_itemIterEnd)
				{
					++m_mapIterCur;
					if (m_mapIterCur != m_mapIterEnd)
					{
						m_itemIterCur = m_mapIterCur->second.begin();
						m_itemIterEnd = m_mapIterCur->second.end();
					}
				}
				return true;
			}
		}
		outItem.name = "";
		outItem.type = "";
		return false;
	}

	int m_nRefs;
	CEquipmentSystemInterface* m_pESI;
	string m_type;
	TItemMap::const_iterator m_mapIterCur;
	TItemMap::const_iterator m_mapIterEnd;
	TNameArray::const_iterator m_itemIterCur;
	TNameArray::const_iterator m_itemIterEnd;
};

// return iterator with all available equipment items
IEquipmentSystemInterface::IEquipmentItemIteratorPtr 
CEquipmentSystemInterface::CreateEquipmentItemIterator(const char* type)
{
	return new CIterator(this, type);
}

// delete all equipment packs
void CEquipmentSystemInterface::DeleteAllEquipmentPacks()
{
	m_pIEquipmentManager->DeleteAllEquipmentPacks();
}

bool CEquipmentSystemInterface::LoadEquipmentPack(const XmlNodeRef& rootNode)
{
	return m_pIEquipmentManager->LoadEquipmentPack(rootNode);
}

namespace
{
	template <class Container> void ToContainer(const char** names, int nameCount, Container& container)
	{
		while (nameCount > 0)
		{
			container.push_back(*names);
			++names;
			--nameCount;
		}
	}
}

void CEquipmentSystemInterface::InitItems(IGameToEditorInterface* pGTE)
{
	// Get ItemParams from ItemSystem
	// Creates the following entries
	// "item"               All Item classes
	// "item_selectable"    All Item classes which can be selected
	// "item_givable",      All Item classes which can be given
	// "weapon"             All Weapon classes (an Item of class 'Weapon' or an Item which has ammo)
	// "weapon_selectable"  All Weapon classes which can be selected
	// "weapon_givable"     All Weapon classes which can be given
	// and for any weapon which has ammo
	// "ammo_WEAPONNAME"    All Ammos for this weapon

	IItemSystem* pItemSys = m_pIItemSystem;
	int maxCountItems = pItemSys->GetItemParamsCount();
	int maxAllocItems = maxCountItems+1; // allocate one more to store empty
	const char** allItemClasses = new const char*[maxAllocItems];
	const char** givableItemClasses = new const char*[maxAllocItems];
	const char** selectableItemClasses = new const char*[maxAllocItems];
	const char** allWeaponClasses = new const char*[maxAllocItems];
	const char** givableWeaponClasses = new const char*[maxAllocItems];
	const char** selectableWeaponClasses = new const char*[maxAllocItems];

	int numAllItems = 0;
	int numAllWeapons = 0;
	int numGivableItems = 0;
	int numSelectableItems = 0;
	int numSelectableWeapons = 0;
	int numGivableWeapons = 0;
	std::set<string> allAmmosSet;

	// store default "---" -> "" value
	{
		const char* empty = "";
		selectableWeaponClasses[numSelectableWeapons++] = empty;
		givableWeaponClasses[numGivableWeapons++] = empty;
		allWeaponClasses[numAllWeapons++] = empty;
		selectableItemClasses[numSelectableItems++] = empty;
		givableItemClasses[numGivableItems++] = empty;
		allItemClasses[numAllItems++] = empty;
		allAmmosSet.insert(empty);
	}

	for (int i=0; i<maxCountItems; ++i)
	{
		const char* itemName = pItemSys->GetItemParamName(i);
		allItemClasses[numAllItems++] = itemName;

		const IItemParamsNode* pItemRootParams = pItemSys->GetItemParams(itemName);

		if (pItemRootParams)
		{
			bool givable = false;
			bool selectable = false;
			bool uiWeapon = false;
			const IItemParamsNode *pChildItemParams = pItemRootParams->GetChild("params");
			if (pChildItemParams) 
			{
				CItemParamReader reader (pChildItemParams);

				//FIXME: the equipeable(?) flag is supposed to be used for weapons that are not givable (alien weapons)
				//but that are still needed to be in the equipment weapon list.
				bool equipeable = false;
				reader.Read("equipeable", equipeable);
				reader.Read("giveable", givable);
				givable |= equipeable;

				reader.Read("selectable", selectable);
				reader.Read("ui_weapon", uiWeapon);
			}

			if (givable)
				givableItemClasses[numGivableItems++] = itemName;
			if (selectable)
				selectableItemClasses[numSelectableItems++] = itemName;

			const IItemParamsNode* pAmmos = pItemRootParams->GetChild("ammos");
			if (pAmmos)
			{
				int maxAmmos = pAmmos->GetChildCount();
				int numAmmos = 0;
				const char** ammoNames = new const char*[maxAmmos];
				for (int j=0; j<maxAmmos; ++j)
				{
					const IItemParamsNode* pAmmoParams = pAmmos->GetChild(j);
					if (stricmp(pAmmoParams->GetName(), "ammo") == 0)
					{
						const char* ammoName = pAmmoParams->GetAttribute("name");
						if (ammoName)
						{
							ammoNames[numAmmos] = ammoName;
							++numAmmos;
							allAmmosSet.insert(ammoName);
						}
					}
				}
				if (numAmmos > 0)
				{
					// make it a weapon when there's ammo
					allWeaponClasses[numAllWeapons++] = itemName;
					if (selectable)
						selectableWeaponClasses[numSelectableWeapons++] = itemName;
					if (givable)
						givableWeaponClasses[numGivableWeapons++] = itemName;

					string ammoEntryName = "ammo_";
					ammoEntryName+=itemName;
					pGTE->SetUIEnums(ammoEntryName.c_str(), ammoNames, numAmmos);
				}
				delete[] ammoNames;
			}
			else
			{
				const char* itemClass = pItemRootParams->GetAttribute("class");
				if (uiWeapon || (itemClass != 0 && stricmp(itemClass, "weapon") == 0))
				{
					// make it a weapon when there's ammo
					allWeaponClasses[numAllWeapons++] = itemName;
					if (selectable)
						selectableWeaponClasses[numSelectableWeapons++] = itemName;
					if (givable)
						givableWeaponClasses[numGivableWeapons++] = itemName;
				}
			}
		}
	}

	int numAllAmmos = 0;
	const char** allAmmos = new const char*[allAmmosSet.size()];
	std::set<string>::const_iterator iter (allAmmosSet.begin());
	while (iter != allAmmosSet.end())
	{
		allAmmos[numAllAmmos++] = iter->c_str();
		++iter;
	}
	pGTE->SetUIEnums("ammos", allAmmos, numAllAmmos);
	ToContainer(allAmmos+1, numAllAmmos-1, m_itemMap["Ammo"]);
	delete[] allAmmos;

	pGTE->SetUIEnums("weapon_selectable", selectableWeaponClasses, numSelectableWeapons);
	pGTE->SetUIEnums("weapon_givable", givableWeaponClasses, numGivableWeapons);
	pGTE->SetUIEnums("weapon", allWeaponClasses, numAllWeapons);
	pGTE->SetUIEnums("item_selectable", selectableItemClasses, numSelectableItems);
	pGTE->SetUIEnums("item_givable", givableItemClasses, numGivableItems);
	pGTE->SetUIEnums("item", allItemClasses, numAllItems);

	ToContainer(allItemClasses+1,numAllItems-1,m_itemMap["Item"]);
	ToContainer(givableItemClasses+1,numGivableItems-1,m_itemMap["ItemGivable"]);
	ToContainer(allWeaponClasses+1,numAllWeapons-1,m_itemMap["Weapon"]);

	delete[] selectableWeaponClasses;
	delete[] givableWeaponClasses;
	delete[] allWeaponClasses;
	delete[] selectableItemClasses;
	delete[] givableItemClasses; 
	delete[] allItemClasses;
}

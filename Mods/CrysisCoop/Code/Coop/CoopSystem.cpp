#include <StdAfx.h>
#include <IAISystem.h>
#include <IGame.h>
#include <IGameFramework.h>
#include <IActorSystem.h>
#include <IAgent.h>
#include <IItemSystem.h>
#include "CoopSystem.h"
#include "CoopCutsceneSystem.h"

#include "Coop/DialogSystem/DialogSystem.h"

#include <IVehicleSystem.h>
#include <IConsole.h>
#include <INetworkService.h>

// Static CCoopSystem class instance forward declaration.
CCoopSystem CCoopSystem::s_instance = CCoopSystem();

CCoopSystem::CCoopSystem() :
m_nInitialized(0),
m_pReadability(NULL)
{
}

CCoopSystem::~CCoopSystem()
{
}

// Summary:
//	Initializes the CCoopSystem instance.
bool CCoopSystem::Initialize()
{
	gEnv->pGame->GetIGameFramework()->GetILevelSystem()->AddListener(this);
	m_pReadability = new CCoopReadability();

	CCoopCutsceneSystem::GetInstance()->Register();

	IScriptSystem *pSS = gEnv->pScriptSystem;
	if (pSS->ExecuteFile("Scripts/Coop/AI.lua", true, true))
	{
		pSS->BeginCall("Init");
		pSS->EndCall();
	}

	gEnv->pSystem->GetLocalizationManager()->LoadExcelXmlSpreadsheet("Languages/game_text_messages.xml");

	InitCvars();

	m_pDialogSystem = new CDialogSystem();
	m_pDialogSystem->Init();

	return true;
}

void CCoopSystem::InitCvars()
{
	ICVar* pAIUpdateAlways = gEnv->pConsole->GetCVar("ai_UpdateAllAlways");
	ICVar* pCheatCvar = gEnv->pConsole->GetCVar("sv_cheatprotection");
	ICVar* pGameRules = gEnv->pConsole->GetCVar("sv_gamerules");

	if (pAIUpdateAlways)
		pAIUpdateAlways->ForceSet("1");

	if (pCheatCvar)
		pCheatCvar->ForceSet("0");

	if (pGameRules)
		pGameRules->ForceSet("coop");

	// TODO :: Hijack the map command to force DX10 and immersiveness to be enabled

}

void CCoopSystem::CompleteInit()
{
	gEnv->pSystem->SetIDialogSystem(m_pDialogSystem);
}

// Summary:
//	Shuts down the CCoopSystem instance.
void CCoopSystem::Shutdown()
{
	IScriptSystem *pSS = gEnv->pScriptSystem;
	if (pSS->ExecuteFile("Scripts/Coop/AI.lua", true, true))
	{
		pSS->BeginCall("Shutdown");
		pSS->EndCall();
	}

	CCoopCutsceneSystem::GetInstance()->Unregister();

	gEnv->pGame->GetIGameFramework()->GetILevelSystem()->RemoveListener(this);
	SAFE_DELETE(m_pReadability);

	if (m_pDialogSystem)
		m_pDialogSystem->Shutdown();

	SAFE_DELETE(m_pDialogSystem);
}

// Summary:
//	Updates the CCoopSystem instance.
void CCoopSystem::Update(float fFrameTime)
{
	if (m_pDialogSystem)
		m_pDialogSystem->Update(fFrameTime);

	// Registers vehicles into the AI system
	if (gEnv->bServer)
	{
		IVehicleIteratorPtr iter = gEnv->pGame->GetIGameFramework()->GetIVehicleSystem()->CreateVehicleIterator();
		while (IVehicle* pVehicle = iter->Next())
		{
			if (IEntity *pEntity = pVehicle->GetEntity())
			{
				if (!pEntity->GetAI())
				{
					gEnv->bMultiplayer = false;

					HSCRIPTFUNCTION scriptFunction(0);
					IScriptSystem*	pIScriptSystem = gEnv->pScriptSystem;
					if (IScriptTable* pScriptTable = pEntity->GetScriptTable())
					{
						if (pScriptTable->GetValue("ForceCoopAI", scriptFunction))
						{
							Script::Call(pIScriptSystem, scriptFunction, pScriptTable, false);
							pIScriptSystem->ReleaseFunc(scriptFunction);
						}
					}


					gEnv->bMultiplayer = true;
				}
			}
		}
	}
	CCoopCutsceneSystem::GetInstance()->Update(fFrameTime);

	// Kill the cancer
	/*INetworkService* serv = gEnv->pNetwork->GetService("GameSpy");
	if (serv)
	{
		((CGameSpy*)serv)->m_loggedIn = true;
	}*/

	// Disable server time elapsing on the client ( server synced only )
	if (!gEnv->bServer)
	{
		ITimeOfDay::SAdvancedInfo advancedinfo;
		advancedinfo.fAnimSpeed = 0.f;
		gEnv->p3DEngine->GetTimeOfDay()->SetAdvancedInfo(advancedinfo);
	}
}

void CCoopSystem::OnLoadingStart(ILevelInfo *pLevel)
{
	if (gEnv->bEditor || !gEnv->bServer) return;

	m_nInitialized = 0;
	CryLogAlways("[CCoopSystem] Initializing AI System...");

	gEnv->bMultiplayer = false;
	if (!gEnv->pAISystem->Init())
		CryLogAlways("[CCoopSystem] AI System Initialization Failed");

	gEnv->pAISystem->FlushSystem();
	gEnv->pAISystem->Enable();
	//gEnv->pAISystem->ReloadSmartObjectRules();
	//gEnv->pAISystem->ReloadActions();
	gEnv->pAISystem->LoadNavigationData(pLevel->GetPath(), "mission0");

	ICVar* pSystemUpdate = gEnv->pConsole->GetCVar("ai_systemupdate");
	pSystemUpdate->SetFlags(pSystemUpdate->GetFlags() | EVarFlags::VF_NOT_NET_SYNCED); // This was actually broken before...
	if (gEnv->bServer)
		pSystemUpdate->Set(1);
	else
		pSystemUpdate->Set(0);
}

void CCoopSystem::OnLoadingComplete(ILevel *pLevel)
{
	m_pDialogSystem->Reset();

	if (CDialogSystem::sAutoReloadScripts != 0)
		m_pDialogSystem->ReloadScripts();



	/*std::set<IEntityClass*> classNames;

	IEntityIt* iter = gEnv->pEntitySystem->GetEntityIterator();
	while (!iter->IsEnd())
	{
	if (IEntity * pEnt = iter->Next())
	{
	string classname = pEnt->GetClass()->GetName();

	if (classNames.find(pEnt->GetClass()) == classNames.end())
	{
	classNames.insert(pEnt->GetClass());
	CryLogAlways("Class: %s", classname);
	}
	}
	}*/

	if (!gEnv->bEditor)
	{
	//	this->DumpEntityDebugInformation();
	}


	if (gEnv->bEditor) return;

	int nInitialized = 0;
	gEnv->bMultiplayer = false;
	m_nInitialized = 1;

	// Why?
	// gEnv->pAISystem->Reset(IAISystem::RESET_ENTER_GAME);
	gEnv->bMultiplayer = true;
}

// Summary:
//	Dumps debug information about entities to the console.
void CCoopSystem::DumpEntityDebugInformation()
{
	// List of used entity classes.
	std::list<string> stlUsedClasses = std::list<string>();

	#define AITypeCase(Name) case Name: sType = #Name; break;
	#define EntityFlagState(Name) if((nFlags & EEntityFlags::Name) != 0) sFlags += #Name " | ";
	IEntityIt* pIterator = gEnv->pEntitySystem->GetEntityIterator();
	while (!pIterator->IsEnd())
	{
		if (IEntity* pEntity = pIterator->This())
		{
			string sFlags = "";
			uint nFlags = pEntity->GetFlags();

			// Push entity class to the used entity classes list.
			stlUsedClasses.push_back(pEntity->GetClass()->GetName());

			EntityFlagState(ENTITY_FLAG_CASTSHADOW);
			EntityFlagState(ENTITY_FLAG_UNREMOVABLE);
			EntityFlagState(ENTITY_FLAG_GOOD_OCCLUDER);
			EntityFlagState(ENTITY_FLAG_WRITE_ONLY);
			EntityFlagState(ENTITY_FLAG_NOT_REGISTER_IN_SECTORS);
			EntityFlagState(ENTITY_FLAG_CALC_PHYSICS);
			EntityFlagState(ENTITY_FLAG_CLIENT_ONLY);
			EntityFlagState(ENTITY_FLAG_SERVER_ONLY);
			EntityFlagState(ENTITY_FLAG_CUSTOM_VIEWDIST_RATIO);
			EntityFlagState(ENTITY_FLAG_CALCBBOX_USEALL);
			EntityFlagState(ENTITY_FLAG_VOLUME_SOUND);
			EntityFlagState(ENTITY_FLAG_HAS_AI);
			EntityFlagState(ENTITY_FLAG_TRIGGER_AREAS);
			EntityFlagState(ENTITY_FLAG_NO_SAVE);
			EntityFlagState(ENTITY_FLAG_NET_PRESENT);
			EntityFlagState(ENTITY_FLAG_CLIENTSIDE_STATE);
			EntityFlagState(ENTITY_FLAG_SEND_RENDER_EVENT);
			EntityFlagState(ENTITY_FLAG_NO_PROXIMITY);
			EntityFlagState(ENTITY_FLAG_ON_RADAR);
			EntityFlagState(ENTITY_FLAG_UPDATE_HIDDEN);
			EntityFlagState(ENTITY_FLAG_NEVER_NETWORK_STATIC);
			EntityFlagState(ENTITY_FLAG_IGNORE_PHYSICS_UPDATE);
			EntityFlagState(ENTITY_FLAG_SPAWNED);
			EntityFlagState(ENTITY_FLAG_SLOTS_CHANGED);
			EntityFlagState(ENTITY_FLAG_MODIFIED_BY_PHYSICS);
			EntityFlagState(ENTITY_FLAG_OUTDOORONLY);
			EntityFlagState(ENTITY_FLAG_SEND_NOT_SEEN_TIMEOUT);
			EntityFlagState(ENTITY_FLAG_RECVWIND);
			EntityFlagState(ENTITY_FLAG_LOCAL_PLAYER);
			EntityFlagState(ENTITY_FLAG_AI_HIDEABLE);
			
			CryLogAlways("[Entity] Name: %s, Id: %d, Class: %s, Archetype: %s, Active: %s, Initialized: %s, Hidden: %s, Flags: %s", 
				pEntity->GetName(), 
				pEntity->GetId(), 
				pEntity->GetClass() ? pEntity->GetClass()->GetName() : "NULL", 
				pEntity->GetArchetype() ? pEntity->GetArchetype()->GetName() : "NULL",
				pEntity->IsActive() ? "Yes" : "No",
				pEntity->IsInitialized() ? "Yes" : "No",
				pEntity->IsHidden() ? "Yes" : "No",
				sFlags.c_str());

			
			if (IAIObject* pAI = pEntity->GetAI())
			{
				const char* sType = "Unknown";

				switch (pAI->GetAIType())
				{
					AITypeCase(AIOBJECT_NONE)
						AITypeCase(AIOBJECT_DUMMY)
						AITypeCase(AIOBJECT_AIACTOR)
						AITypeCase(AIOBJECT_CAIACTOR)
						AITypeCase(AIOBJECT_PIPEUSER)
						AITypeCase(AIOBJECT_CPIPEUSER)
						AITypeCase(AIOBJECT_PUPPET)
						AITypeCase(AIOBJECT_CPUPPET)
						AITypeCase(AIOBJECT_VEHICLE)
						AITypeCase(AIOBJECT_CVEHICLE)
						AITypeCase(AIOBJECT_AWARE)
						AITypeCase(AIOBJECT_ATTRIBUTE)
						AITypeCase(AIOBJECT_WAYPOINT)
						AITypeCase(AIOBJECT_HIDEPOINT)
						AITypeCase(AIOBJECT_SNDSUPRESSOR)
						AITypeCase(AIOBJECT_HELICOPTER)
						AITypeCase(AIOBJECT_CAR)
						AITypeCase(AIOBJECT_BOAT)
						AITypeCase(AIOBJECT_AIRPLANE)
						AITypeCase(AIOBJECT_2D_FLY)
						AITypeCase(AIOBJECT_MOUNTEDWEAPON)
						AITypeCase(AIOBJECT_GLOBALALERTNESS)
						AITypeCase(AIOBJECT_LEADER)
						AITypeCase(AIOBJECT_ORDER)
						AITypeCase(AIOBJECT_PLAYER)
						AITypeCase(AIOBJECT_GRENADE)
						AITypeCase(AIOBJECT_RPG)
				}
				
				CryLogAlways("[AI] Name: %s, Type: %s", pAI->GetName(), sType);
			}

			CryLogAlways("[SmartObject] %s", pEntity->GetSmartObject() ? "Yes" : "No");
			CryLogAlways("[Network] Bound: %s", gEnv->pGame->GetIGameFramework()->GetNetContext()->IsBound(pEntity->GetId()) ? "Yes" : "No");
		}
		pIterator->Next();
	}

	stlUsedClasses.unique();
	stlUsedClasses.sort();

	CryLogAlways("[Classes]");
	for (std::list<string>::iterator it = stlUsedClasses.begin(); it != stlUsedClasses.end(); ++it)
	{
		CryLogAlways(" - %s", it->c_str());
	}

}
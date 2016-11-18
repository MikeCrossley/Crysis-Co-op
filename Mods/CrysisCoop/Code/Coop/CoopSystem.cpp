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

	ICVar* pAIUpdateAlways = gEnv->pConsole->GetCVar("ai_UpdateAllAlways");
	ICVar* pCheatCvar = gEnv->pConsole->GetCVar("sv_cheatprotection");

	if (pAIUpdateAlways)
		pAIUpdateAlways->ForceSet("1");

	if (pCheatCvar)
		pCheatCvar->ForceSet("0");

	m_pDialogSystem = new CDialogSystem();
	m_pDialogSystem->Init();

	return true;
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

bool bReinited = false;


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
			if(IEntity *pEntity = pVehicle->GetEntity())
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
}

void CCoopSystem::OnLoadingStart(ILevelInfo *pLevel)
{
	if (gEnv->bEditor) return;
	if (!gEnv->bServer) return;

	m_nInitialized = 0;
	CryLogAlways("[CCoopSystem] Initializing AI System...");

	gEnv->bMultiplayer = false;
	if (!gEnv->pAISystem->Init())
		CryLogAlways("[CCoopSystem] AI System Initialization Failed");

	gEnv->pAISystem->FlushSystem();
	gEnv->pAISystem->Enable();

	gEnv->pAISystem->LoadNavigationData(pLevel->GetPath(), "mission0");
	gEnv->bMultiplayer = true;

	ICVar* pSystemUpdate = gEnv->pConsole->GetCVar("ai_systemupdate");
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

	if (gEnv->bEditor) return;

	int nInitialized = 0;
	gEnv->bMultiplayer = false;
	m_nInitialized = 1;
	
	gEnv->pAISystem->Reset(IAISystem::RESET_ENTER_GAME);
	gEnv->bMultiplayer = true;
}

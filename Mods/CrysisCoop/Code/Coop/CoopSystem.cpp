#include <StdAfx.h>
#include <IAISystem.h>
#include <IGame.h>
#include <IGameFramework.h>
#include <IActorSystem.h>
#include <IAgent.h>
#include <IItemSystem.h>
#include "CoopSystem.h"
#include "CoopCutsceneSystem.h"

#include <IGameRulesSystem.h>

#include "Coop/DialogSystem/DialogSystem.h"
#include <Coop/Sound/CoopSoundSystem.h>

#include <IVehicleSystem.h>
#include <IConsole.h>
#include <INetworkService.h>
#include <IEntityClass.h>
#include <IGameTokens.h>

// Static CCoopSystem class instance forward declaration.
CCoopSystem CCoopSystem::s_instance = CCoopSystem();

CCoopSystem::CCoopSystem() 
	: m_nInitialized(0)
	, m_pReadability(NULL)
{
}

CCoopSystem::~CCoopSystem()
{
}

// Clean this up
#include <CryLibrary.h>
#include <CryCooperative\ICooperativeSystem.h>

static HMODULE hCryCooperativeModule = 0;
static ICooperativeSystem* pCooperativeSystem = 0;

// Summary:
//	Initializes the CCoopSystem instance.
bool CCoopSystem::Initialize()
{
	if (gEnv->bEditor)
		return true;

	if (gEnv->pSystem->IsDedicated())
	{
		m_pSoundSystem = new CCoopSoundSystem();
		m_pSoundSystem->Init();

		gEnv->pSoundSystem = m_pSoundSystem;
	}

	gEnv->pGame->GetIGameFramework()->GetILevelSystem()->AddListener(this);
	m_pReadability = new CCoopReadability();

	CCoopCutsceneSystem::GetInstance()->Register();

	IScriptSystem *pSS = gEnv->pScriptSystem;
	if (pSS->ExecuteFile("Scripts/Coop/AI.lua", true, true))
	{
		pSS->BeginCall("Init");
		pSS->EndCall();
	}

	typedef ICooperativeSystem* (__cdecl *PTR_CreateCooperativeSystem)();
	hCryCooperativeModule = CryLoadLibrary("CryCooperative.dll");
	PTR_CreateCooperativeSystem CreateCooperativeSystem = (PTR_CreateCooperativeSystem)GetProcAddress(hCryCooperativeModule, "CreateCooperativeSystem");
	pCooperativeSystem = CreateCooperativeSystem();
	pCooperativeSystem->Initialize(gEnv->pSystem);

	InitCvars();

	m_pDialogSystem = new CDialogSystem();
	m_pDialogSystem->Init();

	return true;
}

void CCoopSystem::InitCvars()
{
	IConsole* pConsole = gEnv->pConsole;

	if (!pConsole) return;

	
	ICVar* pAIUpdateAlways = pConsole->GetCVar("ai_UpdateAllAlways");
	ICVar* pCheatCvar = pConsole->GetCVar("sv_cheatprotection");
	ICVar* pGameRules = pConsole->GetCVar("sv_gamerules");

	if (pAIUpdateAlways)	{ pAIUpdateAlways->ForceSet("1"); }
	if (pCheatCvar)			{ pCheatCvar->ForceSet("0"); }
	if (pGameRules)			{ pGameRules->ForceSet("coop"); }

	pConsole->Register("coop_log", &m_nDebugLog, 1, 0, "Determine wether or not to log coop debug information to the console.");

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
	pCooperativeSystem->Shutdown();

	CryFreeLibrary(hCryCooperativeModule);

	SAFE_DELETE(m_pReadability);

	if (m_pDialogSystem)
		m_pDialogSystem->Shutdown();

	SAFE_DELETE(m_pDialogSystem);
}

// Summary:
//	Updates the CCoopSystem instance.
void CCoopSystem::Update(float fFrameTime)
{
	gEnv->pAISystem->Enable(gEnv->bServer);
	if (m_pDialogSystem)
		m_pDialogSystem->Update(fFrameTime);

	CCoopCutsceneSystem::GetInstance()->Update(fFrameTime);

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
	// Shared initialization.
	ICVar* pSystemUpdate = gEnv->pConsole->GetCVar("ai_systemupdate");
	pSystemUpdate->SetFlags(pSystemUpdate->GetFlags() | EVarFlags::VF_NOT_NET_SYNCED);
	pSystemUpdate->Set(gEnv->bServer ? 1 : 0);
}

void CCoopSystem::OnLoadingComplete(ILevel *pLevel)
{
	m_pDialogSystem->Reset();

	if (CDialogSystem::sAutoReloadScripts != 0)
		m_pDialogSystem->ReloadScripts();
}

// Summary:
//	Called before the game rules have reseted entities.
void CCoopSystem::OnPreResetEntities()
{
	// Reset the game tokens
	gEnv->pGame->GetIGameFramework()->GetIGameTokenSystem()->Reset();
	ILevel* pLevel = gEnv->pGame->GetIGameFramework()->GetILevelSystem()->GetCurrentLevel();
	if (pLevel)
		gEnv->pGame->GetIGameFramework()->GetIGameTokenSystem()->LoadLibs(pLevel->GetLevelInfo()->GetPath() + string("/GameTokens/*.xml"));
}

// Summary:
//	Called after the game rules have reseted entities.
void CCoopSystem::OnPostResetEntities()
{
	if (gEnv->bEditor)
		return;

	// RaZoR: Doubt this is needed anymore, leaving it in for now just in case.
	gEnv->pAISystem->Enable();
}

// Summary:
//	Returns if the current gamerules being played is cooperative.
bool CCoopSystem::IsCoop()
{
	const char* gameRulesName = gEnv->pGame->GetIGameFramework()->GetIGameRulesSystem()->GetCurrentGameRules()->GetEntity()->GetClass()->GetName();
	return (strcmp(gameRulesName, "Coop") == 0);
}
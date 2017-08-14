#include <StdAfx.h>
#include "HUDSynchronizer.h"

#include "../CoopSystem.h"

#include "IActorSystem.h"
#include "Player.h"
#include "HUD\HUD.h"


CHUDSynchronizer::CHUDSynchronizer()
{
}

CHUDSynchronizer::~CHUDSynchronizer()
{
}

bool CHUDSynchronizer::Init(IGameObject *pGameObject)
{
	SetGameObject(pGameObject);

	if (!GetGameObject()->BindToNetwork())
		return false;

	return true;
}

void CHUDSynchronizer::Release()
{
	delete this;
}

IMPLEMENT_RMI(CHUDSynchronizer, ClDisplayOverlayMsg)
{
	CHUD* pHud = g_pGame->GetHUD();
	
	if (pHud)
		pHud->DisplayBigOverlayFlashMessage(params.sMsg, params.fDuration, params.nPosX, params.nPosY, params.vColor);

	return true;
}

IMPLEMENT_RMI(CHUDSynchronizer, ClHideOverlayMsg)
{
	CHUD* pHud = g_pGame->GetHUD();
	
	if (pHud)
		pHud->FadeOutBigOverlayFlashMessage();

	return true;
}

IMPLEMENT_RMI(CHUDSynchronizer, ClHudControl)
{
	int nParams = params.nEnum;

	if (nParams == 0)
		SAFE_HUD_FUNC(Show(true));
	if (nParams == 1)
		SAFE_HUD_FUNC(Show(false));
	if (nParams == 2)
		SAFE_HUD_FUNC(ShowBootSequence());
	if (nParams == 3)
		SAFE_HUD_FUNC(BreakHUD());
	if (nParams == 4)
		SAFE_HUD_FUNC(RebootHUD());

	return true;
}

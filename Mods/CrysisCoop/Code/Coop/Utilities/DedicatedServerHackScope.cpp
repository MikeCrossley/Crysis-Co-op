#include <StdAfx.h>
#include "DedicatedServerHackScope.h"
#include <Cry_Camera.h>

void CDedicatedServerHackScope::Enter()
{
	bool* pDedicatedFlagAddress = &((bool*)(&gEnv->pSystem->GetViewCamera()))[sizeof(CCamera) + 13];
	gEnv->bClient = true;
	*pDedicatedFlagAddress = false;
}

void CDedicatedServerHackScope::Exit()
{
	bool* pDedicatedFlagAddress = &((bool*)(&gEnv->pSystem->GetViewCamera()))[sizeof(CCamera) + 13];
	*pDedicatedFlagAddress = true;
	gEnv->bClient = false;
}
#include <StdAfx.h>
#include "DedicatedServerHackScope.h"
#include <Cry_Camera.h>

static int nScopeCounter = 0;

CDedicatedServerHackScope::CDedicatedServerHackScope()
	: m_bActive(true)
{
	if (++nScopeCounter > 0)
	{
		bool* pDedicatedFlagAddress = &((bool*)(&gEnv->pSystem->GetViewCamera()))[sizeof(CCamera) + 13];
		gEnv->bClient = true;
		*pDedicatedFlagAddress = false;
	}
}

CDedicatedServerHackScope::~CDedicatedServerHackScope()
{
	if (m_bActive)
	{
		if (--nScopeCounter < 0)
		{
			bool* pDedicatedFlagAddress = &((bool*)(&gEnv->pSystem->GetViewCamera()))[sizeof(CCamera) + 13];
			*pDedicatedFlagAddress = true;
			gEnv->bClient = false;
		}
	}
}

void CDedicatedServerHackScope::Exit()
{
	if (m_bActive)
	{
		if (--nScopeCounter < 0)
		{
			bool* pDedicatedFlagAddress = &((bool*)(&gEnv->pSystem->GetViewCamera()))[sizeof(CCamera) + 13];
			*pDedicatedFlagAddress = true;
			gEnv->bClient = false;
		}
		m_bActive = false;
	}
}
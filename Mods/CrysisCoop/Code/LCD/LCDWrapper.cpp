/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
*************************************************************************/
#include "StdAfx.h"
#include "LCDWrapper.h"

#ifdef USE_G15_LCD
#include "EZ_LCD.h"
#include "resource.h"
#include "LCDPage.h"
#include "LCDImage.h"
#include "Pages/Logo.h"
#include "Pages/Loading.h"
#include "Pages/GameStatus.h"
#include "Pages/PlayerStatus.h"
#include <GameCVars.h>

CG15LCD::CG15LCD()
: m_pImpl(new CEzLcd())
, m_currentPage(0)
, m_tick(0.0f)
, LogoPage(-1)
, LoadingPage(-1)
, GameStatusPage(-1)
, PlayerStatusPage(-1)
{
}

CG15LCD::~CG15LCD()
{
	std::for_each(m_pages.begin(), m_pages.end(), stl::container_object_deleter());
	SAFE_DELETE(m_pImpl);
}

bool CG15LCD::Init()
{
	if (m_pImpl->InitYourself(_T("Crysis Wars")) == E_FAIL)
		return false;

	m_pImpl->SetDeviceFamilyToUse(LGLCD_DEVICE_FAMILY_KEYBOARD_G15);

	LogoPage = AddPage(new CLogo(), 0);
	LoadingPage = AddPage(new CLoading());
	GameStatusPage = AddPage(new CGameStatus());
	PlayerStatusPage = AddPage(new CPlayerStatus());

	m_currentPage = LogoPage;

	Update(0.0f);

	return true;
}

void CG15LCD::Update(float frameTime)
{
	FUNCTION_PROFILER(GetISystem(),PROFILE_GAME);
	if (g_pGameCVars->cl_g15lcdEnable == 0)
		return;

	m_tick -= frameTime;
	if (m_tick < 0)
	{
		if (g_pGameCVars->cl_g15lcdTick > 0)
			m_tick = g_pGameCVars->cl_g15lcdTick/1000.0f;
		else
			m_tick = 0;

		if (IsConnected() && m_currentPage != -1)
		{
			if(m_currentPage > 1 && !g_pGame->GetIGameFramework()->IsGameStarted())
				m_currentPage = 0;
			else if(m_currentPage == 0 && g_pGame->GetIGameFramework()->IsGameStarted())
				m_currentPage = 2;

			if (m_pages[m_currentPage]->PreUpdate())
			{
				m_pages[m_currentPage]->Update(frameTime);
				m_pImpl->ShowPage(m_currentPage);
			}
		}
		m_pImpl->Update();
	}
}

bool CG15LCD::IsConnected()
{
	return m_pImpl->IsConnected()!=FALSE;
}

CLCDImage* CG15LCD::CreateImage(const char* name, bool visible)
{
	CLCDImage* pImage = new CLCDImage(this);

	if (name)
	{
		if (pImage->Load(name))
		{
			pImage->SetVisible(visible);
		}
	}

	return pImage;
}

int CG15LCD::AddPage(CLCDPage* pPage, int pageId)
{
	if (pageId == -1)
	{
		// generate a new number
		pageId = m_pImpl->AddNewPage()-1;
	}

	pPage->Attach(this, pageId);
	m_pages.push_back(pPage);
	return m_pages.size() - 1;
}

void CG15LCD::SetCurrentPage(int pageId)
{
	m_currentPage = pageId;
	m_tick = 0.0f; //essentially forces an update
}

void CG15LCD::ShowCurrentPage()
{
	m_pImpl->ShowPage(m_currentPage);
}

#endif //USE_G15_LCD

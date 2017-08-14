/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
*************************************************************************/
#include "StdAfx.h"
#include "LCDPage.h"

#ifdef USE_G15_LCD

CLCDPage::CLCDPage()
:	m_pLCD(0)
, m_pageId(-1)
{
}

CLCDPage::~CLCDPage()
{
}

void CLCDPage::Attach(CG15LCD* pLCD, int pageId)
{
	m_pLCD = pLCD;
	m_pageId = pageId;

	MakeModifyTarget();
	OnAttach();
}

void CLCDPage::MakeModifyTarget()
{
	if (m_pageId != -1)
	{
		GetEzLcd()->ModifyControlsOnPage(m_pageId);
	}
}

#endif //USE_G15_LCD

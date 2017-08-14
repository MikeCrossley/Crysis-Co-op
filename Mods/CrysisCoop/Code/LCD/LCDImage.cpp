/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
*************************************************************************/
#include "StdAfx.h"
#include "LCDImage.h"

#ifdef USE_G15_LCD

CLCDImage::CLCDImage(CG15LCD* pLCD)
: m_pLCD(pLCD)
, m_hBitmap(0)
, m_hHandle(0)
, m_bVisible(false)
{
}

CLCDImage::~CLCDImage()
{
	::DeleteObject(m_hBitmap);
}

bool CLCDImage::Load(const char* name)
{
	m_hBitmap = (HBITMAP)::LoadImage((HINSTANCE)g_hInst, name, IMAGE_BITMAP, 0, 0, LR_SHARED);
	if (!m_hBitmap)
		return false;

	BITMAP bm;
	::GetObject(m_hBitmap, sizeof(BITMAP), &bm);
	m_hHandle = GetEzLcd()->AddBitmap(bm.bmWidth, bm.bmHeight);
	GetEzLcd()->SetBitmap(m_hHandle, m_hBitmap);
	SetOrigin(0, 0);

	return true;
}

void CLCDImage::SetOrigin(int x, int y)
{
	GetEzLcd()->SetOrigin(m_hHandle, x, y);
}

void CLCDImage::SetVisible(bool bVisible)
{
	GetEzLcd()->SetVisible(m_hHandle, bVisible);
	m_bVisible = bVisible;
}

bool CLCDImage::GetVisible()
{
	return m_bVisible;
}

#endif //USE_G15_LCD
/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
Description: 	Wrapper around a bitmap image used for the G15 LCD Display

-------------------------------------------------------------------------
History:
- 08:11:2007: Created by Marco Koegler

*************************************************************************/
#ifndef __LCDIMAGE_H__
#define __LCDIMAGE_H__

#ifdef USE_G15_LCD

#include "LCDWrapper.h"
#include "EZ_LCD.h"

class CLCDImage : public _reference_target_t
{
public:
	CLCDImage(CG15LCD* pLCD);
	virtual ~CLCDImage();

	bool Load(const char* name);

	HBITMAP GetHBitmap() const {	return m_hBitmap;	}
	HANDLE GetHandle() const {	return m_hHandle;	}

	void SetOrigin(int x, int y);
	void SetVisible(bool bVisible);
	bool GetVisible();

protected:
	CEzLcd*		GetEzLcd() const	{	return m_pLCD ? m_pLCD->GetEzLcd() : 0;	};
	CG15LCD*	GetG15LCD() const	{	return m_pLCD ;	};

private:
	CG15LCD*	m_pLCD;
	HBITMAP		m_hBitmap;
	HANDLE		m_hHandle;
	bool			m_bVisible;
};

#endif //USE_G15_LCD

#endif
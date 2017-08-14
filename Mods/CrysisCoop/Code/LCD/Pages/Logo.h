/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
Description: 	Game Logo

-------------------------------------------------------------------------
History:
- 01:11:2007: Created by Marco Koegler

*************************************************************************/
#ifndef __LOGO_H__
#define __LOGO_H__

#ifdef USE_G15_LCD
#include "../LCDPage.h"

class CLogo : public CLCDPage
{
public:
	CLogo() 
	{
	}

	virtual ~CLogo()
	{
	}
protected:
	virtual void OnAttach()
	{
		m_pLogo = GetG15LCD()->CreateImage(MAKEINTRESOURCE(IDB_CRYSIS));
	}
private:
	_smart_ptr<CLCDImage> m_pLogo;
};

#endif //USE_G15_LCD

#endif
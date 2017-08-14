/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
Description: 	A page of controls for the Logitech G15 LCD

-------------------------------------------------------------------------
History:
- 01:11:2007: Created by Marco Koegler

*************************************************************************/
#ifndef __LCDPAGE_H__
#define __LCDPAGE_H__

#ifdef USE_G15_LCD

#include "LCDWrapper.h"
#include "EZ_LCD.h"

class CLCDPage
{
public:
	CLCDPage();
	virtual ~CLCDPage();

	void	Attach(CG15LCD* pLCD, int pageId);
	
	virtual bool	PreUpdate() {	return true;	}
	virtual void	Update(float frameTime) {}

	void	MakeModifyTarget();
	int		GetPageId() const {	return m_pageId;	}

protected:
	virtual void OnAttach(){}

	CEzLcd*		GetEzLcd() const	{	return m_pLCD ? m_pLCD->GetEzLcd() : 0;	};
	CG15LCD*	GetG15LCD() const	{	return m_pLCD ;	};

private:
	CG15LCD*	m_pLCD;
	int				m_pageId;
};

#endif //USE_G15_LCD

#endif
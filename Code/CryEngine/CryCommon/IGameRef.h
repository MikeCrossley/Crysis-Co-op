/*************************************************************************
  Crytek Source File.
  Copyright (C), Crytek Studios, 2001-2004.
 -------------------------------------------------------------------------
  $Id$
  $DateTime$
  Description: 
  
 -------------------------------------------------------------------------
  History:
  - 2:8:2004   10:59 : Created by M�rcio Martins

*************************************************************************/
#ifndef __IGAMEMODPTR_H__
#define __IGAMEMODPTR_H__

#if _MSC_VER > 1000
#	pragma once
#endif


struct IGame;
struct IGameRef
{
	IGameRef(): m_ptr(0) {}
	IGameRef(IGame **ptr): m_ptr(ptr) {};
	~IGameRef() {};

	IGame *operator ->() const { return m_ptr ? *m_ptr : 0; };
	operator IGame*() const { return m_ptr ? *m_ptr : 0; };
	IGameRef &operator =(IGame **ptr) { m_ptr = ptr; return *this; };

private:
	IGame **m_ptr;
};

#endif //__IGAMEMODPTR_H__
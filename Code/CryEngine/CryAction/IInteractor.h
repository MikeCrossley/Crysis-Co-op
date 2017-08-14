/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2004.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: Interactor interface.

-------------------------------------------------------------------------
History:
- 26:6:2006   17:06 : Created by M�rcio Martins

*************************************************************************/
#ifndef __IINTERACTOR_H__
#define __IINTERACTOR_H__

#pragma once


struct IInteractor : public IGameObjectExtension
{
	virtual bool IsUsable(EntityId entityId) const = 0;
	virtual bool IsLocked() const = 0;
	virtual int GetLockIdx() const = 0;
	virtual int GetLockedEntityId() const = 0;
};

#endif // __IINTERACTOR_H__
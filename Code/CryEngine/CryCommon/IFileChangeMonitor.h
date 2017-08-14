////////////////////////////////////////////////////////////////////////////
//
//  Crytek Engine Source File.
//  Copyright (C), Crytek Studios, 2006-2007.
// -------------------------------------------------------------------------
//  File name:   IFileChangeMonitor.h
//  Version:     v1.00
//  Created:     27/07/2007 by Adam Rutkowski
//  Compilers:   Visual Studio.NET 2005
//  Description: 
// -------------------------------------------------------------------------
//  History:
//
////////////////////////////////////////////////////////////////////////////

#ifndef _IFILECHANGEMONITOR_H_
#define _IFILECHANGEMONITOR_H_
#pragma once

struct IFileChangeListener
{
	virtual void OnFileChange( const char* sFilename ) = 0;
};

struct IFileChangeMonitor
{
	// Register the path of a file or directory to monitor
	// Path is relative to game directory, e.g. "Libs/WoundSystem/" or "Libs/WoundSystem/HitLocations.xml"
	virtual bool RegisterListener(IFileChangeListener *pListener, const char* sMonitorItem ) = 0;
	virtual bool UnregisterListener(IFileChangeListener *pListener) = 0;
};

#endif //_IFILECHANGEMONITOR_H_

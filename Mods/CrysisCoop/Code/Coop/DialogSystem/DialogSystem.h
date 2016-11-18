////////////////////////////////////////////////////////////////////////////
//
//  Crytek Engine Source File.
//  Copyright (C), Crytek Studios, 2006.
// -------------------------------------------------------------------------
//  File name:   DialogSystem.h
//  Version:     v1.00
//  Created:     07/07/2006 by AlexL
//  Compilers:   Visual Studio.NET
//  Description: Dialog System
// -------------------------------------------------------------------------
//  History:
//
////////////////////////////////////////////////////////////////////////////

#ifndef __DIALOGSYSTEM_H__
#define __DIALOGSYSTEM_H__

#pragma once

#include "DialogScript.h"
#include <IDialogSystem.h>
#include <SerializeFwd.h>
#include "ILevelSystem.h"

class CDialogSession;

class CDialogSystem  : public IDialogSystem, ILevelSystemListener
{
public:
	typedef int SessionID;

	CDialogSystem();
	virtual ~CDialogSystem();

	void GetMemoryStatistics(ICrySizer * s);

	// Later go into IDialogSystem i/f
	virtual bool Init();
	void Update(const float dt);
	virtual void Shutdown();
	virtual void Serialize(TSerialize ser);   // serializes load/save. After load serialization PostLoad needs to be called

	// IDialogSystem
	void Reset();
	IDialogScriptIteratorPtr CreateScriptIterator();
	virtual bool ReloadScripts() { return true; }
	bool ReloadScriptsNew(const char *levelName = NULL);
	// ~IDialogSystem

	// ILevelSystemListener
	virtual void OnLevelNotFound(const char *levelName) {};
	virtual void OnLoadingStart(ILevelInfo *pLevel);
	virtual void OnLoadingComplete(ILevel *pLevel) {};
	virtual void OnLoadingError(ILevelInfo *pLevel, const char *error) {};
	virtual void OnLoadingProgress(ILevelInfo *pLevel, int progressAmount) {};
	// ~ILevelSystemListener

	SessionID CreateSession(const string& scriptID);
	bool      DeleteSession(SessionID id);
	CDialogSession* GetSession(SessionID id) const;
	const CDialogScript* GetScriptByID(const string& scriptID) const;

	bool IsEntityInDialog(EntityId entityId) const;
	bool FindSessionAndActorForEntity(EntityId entityId, SessionID& outSessionID, CDialogScript::TActorID& outActorId) const;

	// called from CDialogSession
	bool AddSession(CDialogSession* pSession);
	bool RemoveSession(CDialogSession* pSession);

	// Debug dumping
	void Dump(int verbosity = 0);
	void DumpSessions();

	static int sDiaLOGLevel;    // CVar ds_LogLevel
	static int sPrecacheSounds; // CVar ds_PrecacheSounds
	static int sAutoReloadScripts; // CVar to reload scripts when jumping into GameMode
	static int sLoadSoundSynchronously;
	static int sLoadExcelScripts; // CVar to load legacy Excel based Dialogs
	static int sWarnOnMissingLoc; // CVar ds_WarnOnMissingLoc

protected:
	void ReleaseScripts();
	void ReleaseSessions();
	void ReleasePendingDeletes();
	void RestoreSessions();
	CDialogSession* InternalCreateSession(const string& scriptID, SessionID sessionID);

protected:
	class CDialogScriptIterator;
	typedef std::map<SessionID, CDialogSession*> TDialogSessionMap;
	typedef std::vector<CDialogSession*> TDialogSessionVec;

	int               m_nextSessionID;
	TDialogScriptMap  m_dialogScriptMap;
	TDialogSessionMap m_allSessions;
	TDialogSessionVec m_activeSessions;
	TDialogSessionVec m_activeSessionsTemp;
	TDialogSessionVec m_pendingDeleteSessions;
	std::vector<SessionID> m_restoreSessions;
};

#endif

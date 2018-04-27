#ifndef _CoopSystem_H_
#define _CoopSystem_H_

#include <ILevelSystem.h>
#include "CoopReadability.h"

class CCoopSoundSystem;
class CDialogSystem;

// Summary:
//	Interface for listening to coop system events.
struct ICoopSystemEventListener
{
protected:
	// Summary:
	//	Registers the ICoopSystemEventListener implementation instance to the coop system.
	void RegisterEventListener();

	// Summary:
	//	Unregisters the ICoopSystemEventListener implementation instance from the coop system.
	void UnregisterEventListener();
public:
	// Summary:
	//	Called before the game rules have reseted entities.
	virtual void OnPreResetEntities() {};

	// Summary:
	//	Called after the game rules have reseted entities and the coop system has re-created AI objects.
	virtual void OnPostResetEntities() {};
};

class CCoopSystem 
	: public ILevelSystemListener
{
	friend struct ICoopSystemEventListener;
private:
	// Static CCoopSystem class instance forward declaration.
	static CCoopSystem s_instance;

	CCoopSystem();
	~CCoopSystem();

public:
	// Summary:
	//	Gets an pointer to the static CCoopSystem instance.
	static inline CCoopSystem* GetInstance() {
		return &s_instance;
	}

	// Summary:
	//	Initializes the CCoopSystem instance.
	bool Initialize();

	// Summary:
	//	Initializes the Coop related CVars
	void InitCvars();

	// Summary:
	//	Initialize Complete
	void CompleteInit();

	// Summary:
	//	Shuts down the CCoopSystem instance.
	void Shutdown();

	// Summary:
	//	Updates the CCoopSystem instance.
	void Update(float fFrameTime);


	// Summary:
	//	Called before the game rules have reseted entities.
	void OnPreResetEntities();

	// Summary:
	//	Called after the game rules have reseted entities.
	void OnPostResetEntities();

	// ILevelSystemListener
	virtual void OnLevelNotFound(const char *levelName) { };
	virtual void OnLoadingStart(ILevelInfo *pLevel);
	virtual void OnLoadingComplete(ILevel *pLevel);
	virtual void OnLoadingError(ILevelInfo *pLevel, const char *error) { };
	virtual void OnLoadingProgress(ILevelInfo *pLevel, int progressAmount) { };
	// ~ILevelSystemListener

	// Summary:
	//	Dumps debug information about entities to the console.
	void DumpEntityDebugInformation();

	// Summary:
	//	Returns the debug log mode the coopsystem is currently using.
	int GetDebugLog() { return m_nDebugLog; }

	// Summary:
	//	Returns if the current gamerules being played is cooperative.
	bool IsCoop();

	CDialogSystem* GetDialogSystem() { return m_pDialogSystem; }
	CCoopSoundSystem* GetSoundSystem() { return m_pSoundSystem; }

	CCoopReadability* m_pReadability;


public:


private:
	int					m_nInitialized;
	IEntityClass*		m_pEntityClassPlayer;
	IEntityClass*		m_pEntityClassGrunt;
	IEntityClass*		m_pEntityClassAlien;
	IEntityClass*		m_pEntityClassScout;
	IEntityClass*		m_pEntityClassTrooper;
	IEntityClass*		m_pEntityClassHunter;

private:
	CCoopSoundSystem* m_pSoundSystem;
	CDialogSystem*	m_pDialogSystem;
	int				m_nDebugLog;

	std::list<ICoopSystemEventListener*> m_eventListeners;
};

#endif // _CoopSystem_H_
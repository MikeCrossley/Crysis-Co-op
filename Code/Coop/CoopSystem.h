#ifndef _CoopSystem_H_
#define _CoopSystem_H_

#include <ILevelSystem.h>
#include "CoopReadability.h"

class CCoopSystem 
	: public ILevelSystemListener
{
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
	//	Shuts down the CCoopSystem instance.
	void Shutdown();

	// Summary:
	//	Updates the CCoopSystem instance.
	void Update(float fFrameTime);


	// ILevelSystemListener
	virtual void OnLevelNotFound(const char *levelName) { };
	virtual void OnLoadingStart(ILevelInfo *pLevel);
	virtual void OnLoadingComplete(ILevel *pLevel);
	virtual void OnLoadingError(ILevelInfo *pLevel, const char *error) { };
	virtual void OnLoadingProgress(ILevelInfo *pLevel, int progressAmount) { };
	// ~ILevelSystemListener

	CCoopReadability* m_pReadability;

private:
	int					m_nInitialized;

	IEntityClass* m_pEntityClassPlayer;
	IEntityClass* m_pEntityClassGrunt;
	IEntityClass* m_pEntityClassAlien;
	IEntityClass* m_pEntityClassScout;
	IEntityClass* m_pEntityClassTrooper;
	IEntityClass* m_pEntityClassHunter;

private:

};

#endif // _CoopSystem_H_
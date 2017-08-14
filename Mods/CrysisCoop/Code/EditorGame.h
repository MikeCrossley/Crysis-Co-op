/*************************************************************************
  Crytek Source File.
  Copyright (C), Crytek Studios, 2001-2004.
 -------------------------------------------------------------------------
  $Id$
  $DateTime$
  Description: Implements the Editor->Game communication interface.
  
 -------------------------------------------------------------------------
  History:
  - 30:8:2004   11:17 : Created by Márcio Martins

*************************************************************************/
#ifndef __EDITORGAME_H__
#define __EDITORGAME_H__

#if _MSC_VER > 1000
# pragma once
#endif


#include <IGameRef.h>
#include <IEditorGame.h>

struct IGameStartup;
class CEquipmentSystemInterface;

class CEditorGame :
	public IEditorGame
{
public:
	CEditorGame();
	virtual ~CEditorGame();

	virtual bool Init(ISystem *pSystem,IGameToEditorInterface *pGameToEditorInterface);
	virtual int Update(bool haveFocus, unsigned int updateFlags);
	virtual void Shutdown();
	virtual bool SetGameMode(bool bGameMode);
	virtual IEntity * GetPlayer();
	virtual void SetPlayerPosAng(Vec3 pos,Vec3 viewDir);
	virtual void HidePlayer(bool bHide);
	virtual void OnBeforeLevelLoad();
	virtual void OnAfterLevelLoad(const char *levelName, const char *levelFolder);

	virtual IFlowSystem * GetIFlowSystem();
	virtual IGameTokenSystem* GetIGameTokenSystem();
	virtual IEquipmentSystemInterface* GetIEquipmentSystemInterface();

private:
	void InitUIEnums(IGameToEditorInterface* pGTE);
	void InitGlobalFileEnums(IGameToEditorInterface* pGTE);
	void InitActionEnums(IGameToEditorInterface* pGTE);
	bool ConfigureNetContext( bool on );
	static void OnChangeEditorMode( ICVar * );
	void EnablePlayer(bool bPlayer);
	static void ResetClient(IConsoleCmdArgs*);

	IGameRef			m_pGame;
	IGameStartup	*m_pGameStartup;
	CEquipmentSystemInterface* m_pEquipmentSystemInterface;

	bool          m_bEnabled;
	bool          m_bGameMode;
	bool          m_bPlayer;

	static ICVar  *s_pEditorGameMode;
	static CEditorGame * s_pEditorGame;
};


#endif //__EDITORGAME_H__

/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2006.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: Parachute Item implementation

-------------------------------------------------------------------------
History:
- 07:02:2006   12:50 : Created by Michael Rauh 
                      (ported from Julien's CVehicleMovementParachute)

*************************************************************************/
#ifndef __PARACHUTE_H__
#define __PARACHUTE_H__

#include <IItemSystem.h>
#include "Item.h"
#include "VehicleMovementAerodynamic.h"

class CParachute : public CItem, public CVehicleMovementAerodynamic
{
public:
  CParachute();
  virtual ~CParachute();

  // IItem, IGameObjectExtension
  virtual bool Init(IGameObject * pGameObject);      
  virtual void Update(SEntityUpdateContext& ctx, int);    
  virtual void OnAction(EntityId actorId, const char *actionName, int activationMode, float value);
  virtual void UpdateFPView(float frameTime);
  virtual void OnReset();
  virtual void Release();
  // ~IItem

  // IGameObjectPhysics
  virtual bool SetProfile( uint8 profile );
  // ~IGameObjectPhysics

private:
  void ProcessMovement(const float deltatime);
  int AddCel(IPhysicalEntity* pPhysics,int,SWing *);
    
  inline bool IsOpened(){ return m_isOpened; }
  void Open();
  void Close(bool drop=false);
  void PhysicalizeCanvas(bool enable);

  TPointsMap m_LiftPointsMap;
  TPointsMap m_DragPointsMap;
  SWing m_aCels[7];
  std::vector<int> m_paraPhysIds;
  
  EntityId m_actorId;
  bool m_isOpened;  
  float m_inAir;

  EntityId m_canvasId;
};


#endif //__PARACHUTE_H__

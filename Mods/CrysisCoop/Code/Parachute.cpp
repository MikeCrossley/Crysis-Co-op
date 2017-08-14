/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2004.
-------------------------------------------------------------------------
$Id$
$DateTime$

-------------------------------------------------------------------------
History:
- 07:02:2006   11:26 : Created by Michael Rauh

*************************************************************************/

#include "StdAfx.h"
#include "Parachute.h"


//------------------------------------------------------------------------
namespace 
{
  void EnablePhysics(IEntity* pEnt, bool enable)
  {
    if (!pEnt)
      return;

    IEntityPhysicalProxy *pPhysicsProxy = (IEntityPhysicalProxy*)pEnt->GetProxy(ENTITY_PROXY_PHYSICS);

    if (pPhysicsProxy)
    {
      CryLog("EnablePhysics(%i)", enable);
      pPhysicsProxy->EnablePhysics(enable);
    }
  }
}


//------------------------------------------------------------------------
CParachute::CParachute()
: m_isOpened( false )
, m_actorId(0)
, m_canvasId(0)
{
  ReadFile("Game\\Scripts\\Entities\\Vehicles\\FlightDynamics\\ParachuteLift.txt",&m_LiftPointsMap);
  ReadFile("Game\\Scripts\\Entities\\Vehicles\\FlightDynamics\\ParachuteDrag.txt",&m_DragPointsMap);
}

//------------------------------------------------------------------------
CParachute::~CParachute()
{
}

//------------------------------------------------------------------------
bool CParachute::Init(IGameObject * pGameObject)
{
  if (!CItem::Init(pGameObject))
    return false;
    
  m_actorId = 0;
	m_canvasId = 0;

  /*
  float fSizeY = 1.9f;
  float fPosY = 0.25f;

  m_aCels[0].vSize = Vec3(0.6f,fSizeY,0.2f);
  m_aCels[1].vSize = Vec3(0.6f,fSizeY,0.2f);
  m_aCels[2].vSize = Vec3(0.6f,fSizeY,0.2f);
  m_aCels[3].vSize = Vec3(1.1f,fSizeY,0.2f);
  m_aCels[4].vSize = Vec3(0.6f,fSizeY,0.2f);
  m_aCels[5].vSize = Vec3(0.6f,fSizeY,0.2f);
  m_aCels[6].vSize = Vec3(0.6f,fSizeY,0.2f);

  m_aCels[0].vPos = Vec3(-3.7f,fPosY,5.2f);
  m_aCels[1].vPos = Vec3(-2.7f,fPosY,5.7f);
  m_aCels[2].vPos = Vec3(-1.6f,fPosY,6.0f);
  m_aCels[3].vPos = Vec3(+0.0f,fPosY,6.1f);
  m_aCels[4].vPos = Vec3(+1.6f,fPosY,6.0f);
  m_aCels[5].vPos = Vec3(+2.7f,fPosY,5.7f);
  m_aCels[6].vPos = Vec3(+3.7f,fPosY,5.2f);

  m_aCels[0].fAngleX = 7.0f;
  m_aCels[1].fAngleX = 7.0f;
  m_aCels[2].fAngleX = 7.0f;
  m_aCels[3].fAngleX = 7.0f;
  m_aCels[4].fAngleX = 7.0f;
  m_aCels[5].fAngleX = 7.0f;
  m_aCels[6].fAngleX = 7.0f;

  m_aCels[0].fAngleY = +29.0f;
  m_aCels[1].fAngleY = +23.0f;
  m_aCels[2].fAngleY = +10.0f;
  m_aCels[3].fAngleY = 0.0f;
  m_aCels[4].fAngleY = -10.0f;
  m_aCels[5].fAngleY = -23.0f;
  m_aCels[6].fAngleY = -29.0f;

  m_aCels[0].fAngleZ = 0.0f;
  m_aCels[1].fAngleZ = 0.0f;
  m_aCels[2].fAngleZ = 0.0f;
  m_aCels[3].fAngleZ = 0.0f;
  m_aCels[4].fAngleZ = 0.0f;
  m_aCels[5].fAngleZ = 0.0f;
  m_aCels[6].fAngleZ = 0.0f;

  m_aCels[0].fMass = 1.0f;
  m_aCels[1].fMass = 1.0f;
  m_aCels[2].fMass = 2.0f;
  m_aCels[3].fMass = 2.0f;
  m_aCels[4].fMass = 2.0f;
  m_aCels[5].fMass = 1.0f;
  m_aCels[6].fMass = 1.0f;
 

  // spawn canvas entity
  SEntitySpawnParams sp;
  sp.pClass = m_pEntitySystem->GetClassRegistry()->FindClass("BasicEntity");
  sp.sName = "Parachute_Canvas";
  sp.nFlags |= ENTITY_FLAG_NO_PROXIMITY;
  
  IEntity* pCanvas = m_pEntitySystem->SpawnEntity(sp);
  if (!pCanvas)
  {
    GameWarning("[Parachute]: Failed to spawn canvas!");
    return false;
  }
  m_canvasId = pCanvas->GetId();  
  CVehicleMovementAerodynamic::m_pEntity = pCanvas;

  pCanvas->SetWorldTM( GetEntity()->GetWorldTM() );
  PhysicalizeCanvas(true);
  EnablePhysics(pCanvas, false);
  */

  return true;
}


//------------------------------------------------------------------------
bool CParachute::SetProfile( uint8 profile )
{ 
  if (!CItem::SetProfile(profile))
    return false;
  
  return true;
}

//------------------------------------------------------------------------
void CParachute::PhysicalizeCanvas(bool enable)
{
  IEntity* pCanvas = m_pEntitySystem->GetEntity(m_canvasId);
  if (!pCanvas)
    return;

  if (enable)
  {
    SEntityPhysicalizeParams params;
    params.type = PE_RIGID;
    params.mass = 0;
    pCanvas->Physicalize(params);

    IPhysicalEntity* pPhysics = pCanvas->GetPhysics();
    if (!pPhysics)
      return;
    
    // add parachute physics geometry        
    m_paraPhysIds.clear();
    m_paraPhysIds.resize(8);

    for(int iCel=0; iCel<7; iCel++)
    {
      SWing *pCel = &m_aCels[iCel];

      m_paraPhysIds.push_back( AddCel(pPhysics, iCel+1, pCel) );

      pCel->fSurface = pCel->vSize.x * pCel->vSize.y;

      pCel->pLiftPointsMap = &m_LiftPointsMap;
      pCel->pDragPointsMap = &m_DragPointsMap;
    }    
    Vec3 minExt(0.0f,0.0f,0.95f), maxExt(0.5f,0.3f,1.9f);
    m_paraPhysIds.push_back( AddBox(&minExt, &maxExt, 70.0f) );
    
    pe_params_part pp;
    pp.partid = m_paraPhysIds.back();
    pp.flagsAND = ~(geom_collides);    
    pPhysics->SetParams(&pp);

    pe_status_dynamics stats;    
    pPhysics->GetStatus(&stats);
    CryLog("Parachute mass: %f", stats.mass);
  }
  else 
  {
    IPhysicalEntity* pPhysics = pCanvas->GetPhysics();
    if (pPhysics)
    {
      // remove parachute geometry
      for (std::vector<int>::iterator it = m_paraPhysIds.begin(); it != m_paraPhysIds.end(); ++it)
      {
        pPhysics->RemoveGeometry(*it);
      }
    }    
    m_paraPhysIds.clear();    
  }
}

//------------------------------------------------------------------------
void CParachute::OnReset()
{ 
  //Close(true);
  //EnablePhysics(m_pEntitySystem->GetEntity(m_canvasId), false);  

  CItem::OnReset();

	m_canvasId = 0;
}

//------------------------------------------------------------------------
void CParachute::OnAction(EntityId actorId, const char* actionId, int activationMode, float value)
{
  CItem::OnAction(actorId, actionId, activationMode, value);

  /*
  if (IsOpened())
  {
    if (0 == strcmp(actionId, "zoom"))
      Close(false);
    else if (0 == strcmp(actionId, "rotateyaw"))
      m_movementAction.rotateYaw = value;
    else if (0 == strcmp(actionId, "rotatepitch"))
      m_movementAction.rotatePitch = value;    
  }
  else if (0 == strcmp(actionId, "attack1"))
  {
    Open();
  }
  */
} 


//------------------------------------------------------------------------
void CParachute::Open()
{
  // not used any more
  return;

  IEntity* pCanvas = m_pEntitySystem->GetEntity(m_canvasId);

  // enable canvas physics 
  EnablePhysics(pCanvas, true);

  if (!pCanvas->GetPhysics())
  {
    CryLog("[Parachute] Canvas physics enabling failed!");
    return;
  }

  // set canvas to players pos
  IEntity* pOwner = GetOwner();
  pCanvas->SetWorldTM(pOwner->GetWorldTM());
  pCanvas->AttachChild(pOwner);
  m_actorId = pOwner->GetId();

  // attach player to canvas
  GetOwnerActor()->LinkToVehicle(m_canvasId);

  m_isOpened = true;
  EnableUpdate(true, eIUS_General);

  pe_action_awake awake;
  awake.bAwake = true;
  pCanvas->GetPhysics()->Action(&awake);

  if (pOwner->GetPhysics())
  {
    pe_status_dynamics dyn;
    if (pOwner->GetPhysics()->GetStatus(&dyn))
    {
      // set parachute to player's speed
      pe_action_set_velocity vel;
      vel.v = 0.75f*dyn.v;
      pCanvas->GetPhysics()->Action(&vel);
    }
  }
}

//------------------------------------------------------------------------
void CParachute::Close(bool drop/*=false*/)
{
  // not used any more
  return;

  CryLog("Closing Parachute..");

  if (m_actorId)
  {
    IEntity* pEnt = m_pEntitySystem->GetEntity(m_actorId);
    if (pEnt && pEnt->GetParent()->GetId() == m_canvasId)
    {
      pEnt->DetachThis();
    }    
    m_actorId = 0;
  }  
  
  CActor* pActor = GetOwnerActor();
  if (pActor)
  {    
    pActor->LinkToVehicle(0);
    if (IsOpened())
    {
      if (drop)
        pActor->DropItem(GetEntity()->GetId(), 1.0f, false);
    }
  }

  m_isOpened = false;
}

//------------------------------------------------------------------------
void CParachute::Update( SEntityUpdateContext& ctx, int slot)
{
  CItem::Update(ctx, slot);

  // check ground contact. release on landing
  /*if (IsOpened())
  {
    CActor* pActor = GetOwnerActor();
    if (pActor->GetActorStats()->inAir > 0) //&& contact)
    { 
      //Close(false);
    }
    m_inAir = pActor->GetActorStats()->inAir;
  }*/

  if (IsOpened())
    ProcessMovement(ctx.fFrameTime);

  m_movementAction.Clear();
}

//------------------------------------------------------------------------
void CParachute::UpdateFPView(float frameTime)
{
  //if (!IsOpened())
  CItem::UpdateFPView(frameTime);
}

//------------------------------------------------------------------------
void CParachute::Release()
{
  m_pEntitySystem->RemoveEntity(m_canvasId);
  
  CItem::Release();
}

//-----------------------------------------------------------------------------------------------------

void CParachute::ProcessMovement(const float deltatime)
{
#define MetersPerSecondToKilometersPerHour(fValue) (fValue*3.6f)
#define SquareFeetToSquareMeters(fValue) (fValue*0.0929f)
    
  IPhysicalEntity* pPhysics = GetEntity()->GetPhysics();
  if (!pPhysics)
    return;
  
  float fDeltaTime = min(deltatime,0.1f);
  
  pe_status_dynamics statusDynamics;
  if (!pPhysics->GetStatus(&statusDynamics))
    return;
  
  ResetTextPos();

  DumpVector("Velocity",			&statusDynamics.v);
  DumpVector("AVelocity",			&statusDynamics.w);
  DumpVector("Acceleration",	&statusDynamics.a);
  DumpVector("WAcceleration",	&statusDynamics.wa);

  DumpText("DeltaTime=%f",fDeltaTime);
  DumpText("Velocity=%f m/s",statusDynamics.v.len());
  DumpText("Velocity=%f km/h",MetersPerSecondToKilometersPerHour(statusDynamics.v.len()));
  DumpText("Yaw=%f",	m_movementAction.rotateYaw);
  DumpText("Pitch=%f",m_movementAction.rotatePitch);
  DumpText("Roll=%f",	m_movementAction.rotateRoll);

  /*	Vec3 p1 = GetEntity()->GetWorldTM().GetColumn(3);
  Vec3 p2 = p1 + statusDynamics.v * 10.0f;
  gEnv->pRenderer->GetIRenderAuxGeom()->DrawLine(p1,ColorF(1,1,0,1),p2,ColorF(1,1,0,1));
  gEnv->pRenderer->GetIRenderAuxGeom()->DrawSphere(p1,0.6f,ColorF(0,0,1,1));*/

  if(m_movementAction.rotatePitch > 0.0f)
  {
    pe_action_impulse actionImpulse;
    actionImpulse.impulse = Vec3(0,0,5000*fDeltaTime);
    pPhysics->Action(&actionImpulse);
  }
  else if(statusDynamics.v.z < 0.0f)
  {
    for(int iCel=0; iCel<7; iCel++)
    {
      SWing *pCel = &m_aCels[iCel];

      pCel->fCl = 1.0f;
      pCel->fCd = 1.0f;

      float fPosY = 0.25f;

      m_aCels[0].vPos = Vec3(-3.7f,fPosY,5.2f);
      m_aCels[1].vPos = Vec3(-2.7f,fPosY,5.7f);
      m_aCels[2].vPos = Vec3(-1.6f,fPosY,6.0f);
      m_aCels[3].vPos = Vec3(+0.0f,fPosY,6.1f);
      m_aCels[4].vPos = Vec3(+1.6f,fPosY,6.0f);
      m_aCels[5].vPos = Vec3(+2.7f,fPosY,5.7f);
      m_aCels[6].vPos = Vec3(+3.7f,fPosY,5.2f);

      m_aCels[0].fAngleX = 7.0f;
      m_aCels[1].fAngleX = 7.0f;
      m_aCels[2].fAngleX = 7.0f;
      m_aCels[3].fAngleX = 7.0f;
      m_aCels[4].fAngleX = 7.0f;
      m_aCels[5].fAngleX = 7.0f;
      m_aCels[6].fAngleX = 7.0f;

      if(m_movementAction.rotateYaw < 0.0f)
      {
        m_aCels[0].fCl = 1.3f;
        //				m_aCels[1].fCl = 1.3f;
        //				m_aCels[2].fCl = 1.2f;

        m_aCels[0].fCd = 2.9f;
        //				m_aCels[1].fCd = 2.2f;
        //				m_aCels[2].fCd = 2.1f;
      }
      else if(m_movementAction.rotateYaw > 0.0f)
      {
        //				m_aCels[4].fCl = 1.2f;
        //				m_aCels[5].fCl = 1.3f;
        m_aCels[6].fCl = 1.3f;

        //				m_aCels[4].fCd = 2.1f;
        //				m_aCels[5].fCd = 2.2f;
        m_aCels[6].fCd = 2.9f;
      }
      else if(m_movementAction.rotatePitch < 0.0f)
      {
        /*				m_aCels[0].vPos = Vec3(-3.6f,fPosY,4.6f);
        m_aCels[1].vPos = Vec3(-2.6f,fPosY,5.3f);
        m_aCels[2].vPos = Vec3(-1.6f,fPosY,5.9f);

        m_aCels[0].fAngleX = -15.0f;
        m_aCels[1].fAngleX = -8.0f;
        m_aCels[2].fAngleX = 0.0f;

        m_aCels[4].vPos = Vec3(+1.6f,fPosY,5.9f);
        m_aCels[5].vPos = Vec3(+2.6f,fPosY,5.3f);
        m_aCels[6].vPos = Vec3(+3.6f,fPosY,4.6f);

        m_aCels[4].fAngleX = 0.0f;
        m_aCels[5].fAngleX = -8.0f;
        m_aCels[6].fAngleX = -15.0f;*/

        m_aCels[0].fCl = 1.1f;
        m_aCels[1].fCl = 1.2f;
        m_aCels[2].fCl = 1.3f;

        m_aCels[0].fCd = 2.1f;
        m_aCels[1].fCd = 2.2f;
        m_aCels[2].fCd = 2.3f;

        m_aCels[4].fCl = 1.3f;
        m_aCels[5].fCl = 1.2f;
        m_aCels[6].fCl = 1.1f;

        m_aCels[4].fCd = 2.3f;
        m_aCels[5].fCd = 2.2f;
        m_aCels[6].fCd = 2.1f;
      }

      UpdateWing(pCel,0,fDeltaTime);
    }
  }
}


//-----------------------------------------------------------------------------------------------------

int CParachute::AddCel(IPhysicalEntity* pPhysics, int _iID,SWing *_pCel)
{
  IPhysicalWorld *pPhysicalWorld = gEnv->pPhysicalWorld;

  primitives::box geomBox;
  geomBox.Basis = Matrix33::CreateRotationXYZ(Ang3(DEG2RAD(_pCel->fAngleX),DEG2RAD(_pCel->fAngleY),0.0f));
  geomBox.bOriented = 1;
  geomBox.center.Set(0.0f,0.0f,0.0f);
  geomBox.size = _pCel->vSize;
  IGeometry *pGeom = pPhysicalWorld->GetGeomManager()->CreatePrimitive(primitives::box::type,&geomBox);
  phys_geometry *physGeom = pPhysicalWorld->GetGeomManager()->RegisterGeometry(pGeom);
  pGeom->Release();

  pe_geomparams partpos;
  partpos.pos		= _pCel->vPos;
  partpos.mass	= _pCel->fMass;
  int id = pPhysics->AddGeometry(physGeom,&partpos);
    
  pPhysicalWorld->GetGeomManager()->UnregisterGeometry(physGeom);

  return id;
}



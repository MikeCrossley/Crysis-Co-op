#include "StdAfx.h"
#include "Tornado.h"
#include "../Game.h"
#include "../Actor.h"
#include "Environment/FlowTornado.h"
#include <IMaterialEffects.h>
#include <IEffectSystem.h>
#include <IVehicleSystem.h>

#include <IRenderAuxGeom.h>

//------------------------------------------------------------------------
CTornado::CTornado() :
	m_pPhysicalEntity(0),
	m_pFunnelEffect(0),
	m_pCloudConnectEffect(0),
	m_pTopEffect(0),
	m_pGroundEffect(0),
	m_pTargetEntity(0)
{
}

//------------------------------------------------------------------------
CTornado::~CTornado()
{
	if (m_pGroundEffect)
		delete m_pGroundEffect;
}

//------------------------------------------------------------------------
bool CTornado::Init(IGameObject *pGameObject)
{
	SetGameObject(pGameObject);

	GetGameObject()->EnablePhysicsEvent(true, eEPE_OnCollisionLogged);

	if (!Reset())
		return false;

	if(!GetGameObject()->BindToNetwork())
		return false;

	return true;
}

bool CTornado::Reset()
{
	//Initialize default values before (in case ScriptTable fails)
	m_wanderSpeed = 10.0f;
	m_cloudHeight = 376.0f;
	m_radius = 300.0f;

	m_spinImpulse = 9.0f;
	m_attractionImpulse = 13.0f;
	m_upImpulse = 18.0f;

	const char* funnelEffect = 0;

	SmartScriptTable props;
	IScriptTable* pScriptTable = GetEntity()->GetScriptTable();
	if(!pScriptTable || !pScriptTable->GetValue("Properties", props))
		return false;

	props->GetValue("fWanderSpeed", m_wanderSpeed);
	props->GetValue("fCloudHeight", m_cloudHeight);
	props->GetValue("Radius", m_radius);
		
	props->GetValue("fSpinImpulse", m_spinImpulse);
	props->GetValue("fAttractionImpulse", m_attractionImpulse);
	props->GetValue("fUpImpulse", m_upImpulse);
  
	props->GetValue("FunnelEffect", funnelEffect);
	if (!UseFunnelEffect(funnelEffect))
		return false;

	Matrix34 m = GetEntity()->GetWorldTM();
	m_wanderDir = m.GetColumn(1)*0.414214f;

	m_isOnWater = false;
	m_isInAir = false;

	m_nextEntitiesCheck = 0;

	Vec3 pos = GetEntity()->GetWorldPos();
	gEnv->pLog->Log("TORNADO INIT POS: %f %f %f", pos.x, pos.y, pos.z);
	m_points[0] = pos;
	m_points[1] = pos + Vec3(0,0,m_cloudHeight/8.0f);
	m_points[2] = pos + Vec3(0,0,m_cloudHeight/2.0f);
	m_points[3] = pos + Vec3(0,0,m_cloudHeight);
	for (int i=0; i<4; ++i)
		m_oldPoints[i] = m_points[i];

	m_currentPos = GetEntity()->GetWorldPos();
	GetGameObject()->ChangedNetworkState(POSITION_ASPECT);
	
	UpdateTornadoSpline();

	return true;
}

//------------------------------------------------------------------------
void CTornado::PostInit(IGameObject *pGameObject)
{
	GetGameObject()->EnableUpdateSlot(this, 0);
}

//------------------------------------------------------------------------
void CTornado::Release()
{
	delete this;
}

//------------------------------------------------------------------------
void CTornado::FullSerialize(TSerialize ser)
{
	ser.Value("InAir", m_isInAir);
	ser.Value("OnWater", m_isOnWater);
	ser.Value("Direction", m_wanderDir);
	ser.Value("Speed", m_wanderSpeed);
}

//------------------------------------------------------------------------
bool CTornado::NetSerialize( TSerialize ser, EEntityAspects aspect, uint8 profile, int flags )
{
	if (aspect == POSITION_ASPECT)
	{
		ser.Value("Pos", m_currentPos, 'wrld');
	}
	return true;
}

//------------------------------------------------------------------------
void CTornado::Update(SEntityUpdateContext &ctx, int updateSlot)
{
	if (g_pGame->GetIGameFramework()->IsEditing())
		return;

	// wandering
	Matrix34 m = GetEntity()->GetWorldTM();
	Vec3 dir(m.GetColumn(1));
	Vec3 pos(GetEntity()->GetWorldPos());

	if(!gEnv->bServer)
		pos = m_currentPos;

	Vec3 wanderPos(dir * 1.414214f);
	float wanderStrength(1.0f);
	float wanderRate(0.6f);
	Vec3 wanderOffset;
	wanderOffset.SetRandomDirection();
	wanderOffset.z = 0.0f;
	wanderOffset.NormalizeSafe(Vec3(1,0,0));
	m_wanderDir += wanderOffset * wanderRate + (m_wanderDir - wanderPos) * wanderStrength;
	m_wanderDir = (m_wanderDir - wanderPos).GetNormalized() + wanderPos;

	Vec3 wanderSteer = (dir + m_wanderDir * gEnv->pTimer->GetFrameTime());
	wanderSteer.z = 0;
	wanderSteer.NormalizeSafe(Vec3(1,0,0));

	Vec3 targetSteer(0,0,0);
	// go to target
	if (m_pTargetEntity)
	{
		Vec3 target = m_pTargetEntity->GetWorldPos() - pos;
		if (target.GetLength() < 10.0f)
		{
			// emit target reached event
			SEntityEvent event( ENTITY_EVENT_SCRIPT_EVENT );
			event.nParam[0] = (INT_PTR)"TargetReached";
			event.nParam[1] = IEntityClass::EVT_BOOL;
			bool bValue = true;
			event.nParam[2] = (INT_PTR)&bValue;
			GetEntity()->SendEvent( event );
			if (m_pTargetCallback)
				m_pTargetCallback->Done();

			m_pTargetEntity = 0;
			m_pTargetCallback = 0;
		}

		targetSteer = (target - dir);
		targetSteer.z = 0;
		targetSteer.NormalizeSafe(Vec3(1,0,0));
	}

	Vec3 steerDir = (0.4f * wanderSteer + 0.6f * targetSteer).GetNormalized();
	Matrix34 tm = Matrix34(Matrix33::CreateRotationVDir(steerDir));
	pos = pos + steerDir * gEnv->pTimer->GetFrameTime() * m_wanderSpeed;
	pos.z = gEnv->p3DEngine->GetTerrainElevation(pos.x, pos.y);
	float waterLevel = gEnv->p3DEngine->GetWaterLevel(&pos);

	bool prevIsOnWater = m_isOnWater;
	m_isOnWater = (pos.z < waterLevel);
	if (m_isOnWater)
	{
		pos.z = waterLevel;
	}

	// raycast does not work for oceans
	if (prevIsOnWater != m_isOnWater && m_isOnWater)
	{
			m_pGroundEffect->SetParticleEffect("wind.tornado.water");
	}
	else if (!m_isOnWater)
	{		
		IMaterialEffects *mfx = gEnv->pGame->GetIGameFramework()->GetIMaterialEffects();
		Vec3 down = Vec3(0,0,-1.0f);
		int matID = mfx->GetDefaultSurfaceIndex();

		static const int objTypes = ent_all;    
		static const unsigned int flags = rwi_stop_at_pierceable|rwi_colltype_any;
		ray_hit hit;
		int col = gEnv->pPhysicalWorld->RayWorldIntersection(pos, (down * 5.0f), objTypes, flags, &hit, 1, GetEntity()->GetPhysics());
		if (col)
		{
			matID = hit.surface_idx;
		}

		if (m_curMatID != matID)
		{
			TMFXEffectId effectId = mfx->GetEffectId("tornado", matID);
			
			SMFXResourceListPtr pList = mfx->GetResources(effectId);
			if (pList && pList->m_particleList)
			{
				m_pGroundEffect->SetParticleEffect(pList->m_particleList->m_particleParams.name);
			}
			m_curMatID = matID;
		}
	}

	if(gEnv->bServer)
	{
		tm.SetTranslation(pos);
		m_currentPos = pos;
		GetGameObject()->ChangedNetworkState(POSITION_ASPECT);
		GetEntity()->SetWorldTM(tm);
	}
	else
	{
		tm.SetTranslation(m_currentPos);
		GetEntity()->SetWorldTM(tm);
	}

	UpdateParticleEmitters();
	UpdateTornadoSpline();

	UpdateFlow();
}

//------------------------------------------------------------------------
void CTornado::HandleEvent(const SGameObjectEvent &event)
{
}

//------------------------------------------------------------------------
void CTornado::ProcessEvent(SEntityEvent &event)
{
	switch (event.event)
	{
	case ENTITY_EVENT_RESET:
		Reset();
		break;
	}
}

//------------------------------------------------------------------------
void CTornado::SetAuthority(bool auth)
{
}

void CTornado::SetTarget(IEntity *pTargetEntity, CFlowTornadoWander *pCallback)
{
	m_pTargetEntity = pTargetEntity;
	m_pTargetCallback = pCallback;
}


bool CTornado::UseFunnelEffect(const char* effectName)
{
	m_pFunnelEffect = gEnv->p3DEngine->FindParticleEffect(effectName);

	if (!m_pFunnelEffect)
		return false;

	// move particle slot to the helper position+offset
	GetEntity()->LoadParticleEmitter(0, m_pFunnelEffect, 0, false);
	Matrix34 tm = IParticleEffect::ParticleLoc(Vec3(0,0,0));
	GetEntity()->SetSlotLocalTM(0, tm);
	GetEntity()->SetSlotFlags(0, GetEntity()->GetSlotFlags(0)|ENTITY_SLOT_RENDER);
	IParticleEmitter* pEmitter = GetEntity()->GetParticleEmitter(0);
	assert(pEmitter);
	pEmitter->Prime();

	// init the first time
	if (!m_pCloudConnectEffect)
	{
		m_pCloudConnectEffect = gEnv->p3DEngine->FindParticleEffect("wind.tornado.cloud_connection");
		if (m_pCloudConnectEffect)
		{
			GetEntity()->LoadParticleEmitter(1, m_pCloudConnectEffect, 0, true);
		}
	}
	if (!m_pTopEffect)
	{
		m_pTopEffect = gEnv->p3DEngine->FindParticleEffect("wind.tornado.top_part");
		if (m_pTopEffect)
		{
			GetEntity()->LoadParticleEmitter(2, m_pTopEffect, 0, true);
		}
	}

	if (!m_pGroundEffect)
	{
		m_pGroundEffect = g_pGame->GetIGameFramework()->GetIEffectSystem()->CreateGroundEffect(GetEntity());
		m_pGroundEffect->SetParticleEffect("wind.tornado.leaves");
	}

	UpdateParticleEmitters();
	return true;
}

void CTornado::UpdateParticleEmitters()
{
	Matrix34 tm;
	Vec3 pos(0,0,0);
	pos.z = (GetEntity()->GetWorldPos()).z;
	Vec3 cloudOffset(pos);

	if (m_pCloudConnectEffect)
	{
		cloudOffset.z = m_cloudHeight - pos.z;
		tm = IParticleEffect::ParticleLoc(cloudOffset);
		GetEntity()->SetSlotLocalTM(1, tm);
		GetEntity()->SetSlotFlags(1, GetEntity()->GetSlotFlags(1)|ENTITY_SLOT_RENDER);
	}

	if (m_pTopEffect)
	{
		Vec3 topOffset(cloudOffset);
		topOffset.z -= 140.0f;

		tm = IParticleEffect::ParticleLoc(topOffset);
		GetEntity()->SetSlotLocalTM(2, tm);
		GetEntity()->SetSlotFlags(2, GetEntity()->GetSlotFlags(2)|ENTITY_SLOT_RENDER);
	}

	m_pGroundEffect->Update();
}

void CTornado::UpdateTornadoSpline()
{
	SEntityPhysicalizeParams pparams;
	pe_params_area gravityParams;
	SEntityPhysicalizeParams::AreaDefinition areaDef;

	Vec3 pos = GetEntity()->GetWorldPos();
	//gEnv->pLog->Log("TORNADO DELTA: %f %f %f", deltaPos.x, deltaPos.y, deltaPos.z);
	float fac = 0.0f;
	
	m_points[0] = pos;
	fac = 0.5f * gEnv->pTimer->GetFrameTime();
	m_points[1] = m_oldPoints[1] + fac * (pos + Vec3(0,0,m_cloudHeight/8.0f) - m_oldPoints[1]);
	fac = 0.2f * gEnv->pTimer->GetFrameTime();
	m_points[2] = m_oldPoints[2] + fac * (pos + Vec3(0,0,m_cloudHeight/2.0f) - m_oldPoints[2]);
	fac = 0.05f * gEnv->pTimer->GetFrameTime();
	m_points[3] = m_oldPoints[3] + fac * (pos + Vec3(0,0,m_cloudHeight) - m_oldPoints[3]);

	//for (int i=0; i<4; ++i)
	//	gEnv->pLog->Log("TORNADO %d: %f %f %f", i, m_points[i].x, m_points[i].y, m_points[i].z);

	for (int i=0; i<4; ++i)
		m_oldPoints[i] = m_points[i];


	pparams.type = PE_AREA;
	pparams.pAreaDef = &areaDef;
	areaDef.areaType = SEntityPhysicalizeParams::AreaDefinition::AREA_SPLINE;
	areaDef.fRadius = m_radius;
	areaDef.nNumPoints = 4;
	areaDef.pPoints = m_points;
	areaDef.pGravityParams = &gravityParams;
	gravityParams.gravity.Set(0,0,-9.81f);
	gravityParams.size = ZERO;
	gravityParams.falloff0 = -1.0f;	// ?: was NAN. CPhysicalProxy::PhysicalizeArea sets to 'unused' if less than zero...
	//gravityParams.gravity.Set(0,0,0);
	
	gravityParams.bUniform = 1;
	gravityParams.bUseCallback = 0;
	gravityParams.damping = 0.0f;

	GetEntity()->Physicalize(pparams);
}

void CTornado::UpdateFlow()
{
	IVehicleSystem* pVehicleSystem = g_pGame->GetIGameFramework()->GetIVehicleSystem();
	assert(pVehicleSystem);

	float frameTime(gEnv->pTimer->GetFrameTime());

	IPhysicalWorld *ppWorld = gEnv->pPhysicalWorld;

	Vec3 pos(GetEntity()->GetWorldPos());

	//first, check the entities in range
	m_nextEntitiesCheck -= frameTime;
	if (m_nextEntitiesCheck<0.0f)
	{
		m_nextEntitiesCheck = 1.0f;
		
		Vec3 radiusVec(m_radius,m_radius,0);
		
		IPhysicalEntity **ppList = NULL;

		int	numEnts = ppWorld->GetEntitiesInBox(pos-radiusVec,pos+radiusVec+Vec3(0,0,m_cloudHeight*0.5f),ppList,ent_sleeping_rigid|ent_rigid|ent_living);

		m_spinningEnts.clear();
		for (int i=0;i<numEnts;++i)
		{
			// add check for spectating players...
			EntityId id = ppWorld->GetPhysicalEntityId(ppList[i]);
			CActor* pActor = static_cast<CActor*>(g_pGame->GetIGameFramework()->GetIActorSystem()->GetActor(id));
			if(!pActor || !pActor->GetSpectatorMode())
			{
				m_spinningEnts.push_back(id);
			}
		}
		//OutputDistance();
	}

	//mess entities around
	for (int i=0;i<m_spinningEnts.size();++i)
	{
		IPhysicalEntity *ppEnt = ppWorld->GetPhysicalEntityById(m_spinningEnts[i]);
		if (ppEnt)
		{
			pe_status_pos spos;
			pe_status_dynamics sdyn;

			if (!ppEnt->GetStatus(&spos) || !ppEnt->GetStatus(&sdyn))
				continue;
		
			//gEnv->pRenderer->GetIRenderAuxGeom()->DrawSphere(spos.pos,2.0f,ColorB(255,0,255,255));
						
			Vec3 delta(pos - spos.pos);
			delta.z = 0.0f;

			float dLen(delta.len());
			float forceMult(max(0.0f,(m_radius-dLen)/m_radius));

			if (dLen>0.001f)
				delta /= dLen;
			else
				delta.zero();

			Vec3 upVector(0,0,1);

			float spinImpulse(m_spinImpulse);
			float attractionImpulse(m_attractionImpulse);
			float upImpulse(m_upImpulse);

			//FIXME:kind of workaround, living entities needs some "help" to get out of the vortex
			if (ppEnt->GetType() == PE_LIVING)
			{
				upImpulse *= 0.75f;
				attractionImpulse *= 0.35f;
				spinImpulse *= 1.5f;
			}

			
			if (IVehicle* pVehicle = pVehicleSystem->GetVehicle(m_spinningEnts[i]))
			{
				IVehicleMovement* pMovement = pVehicle->GetMovement();

				if (pMovement && pMovement->GetMovementType() == IVehicleMovement::eVMT_Air)
				{
					SVehicleMovementEventParams params;
					params.fValue = forceMult;
					pMovement->OnEvent(IVehicleMovement::eVME_Turbulence, params);
				}
			}

			Vec3 spinForce( (delta % upVector) * spinImpulse );
			Vec3 attractionForce(delta * attractionImpulse);
			Vec3 upForce(0,0,upImpulse);

			pe_action_impulse aimpulse;

			aimpulse.impulse = (spinForce + attractionForce + upForce) * (forceMult * sdyn.mass * frameTime);
			aimpulse.angImpulse = (upVector + (delta % upVector)) * (gf_PI * 0.33f * forceMult * sdyn.mass * frameTime);

			aimpulse.iApplyTime = 0;
			ppEnt->Action(&aimpulse);

			//gEnv->pRenderer->GetIRenderAuxGeom()->DrawLine(spos.pos,ColorB(255,0,255,255),spos.pos+aimpulse.impulse.GetNormalizedSafe(ZERO),ColorB(255,0,255,255));
		}
	}
}

void CTornado::OutputDistance()
{
	IActor *pClient = g_pGame->GetIGameFramework()->GetClientActor();
	if (!pClient)
		return;

	IEntity *pEntity = GetEntity(); 

	HSCRIPTFUNCTION scriptEvent(NULL);	
	if(pEntity->GetScriptTable())
		pEntity->GetScriptTable()->GetValue("ScriptEvent", scriptEvent);

	if (scriptEvent)
	{
		Vec3 deltaToClient(pClient->GetEntity()->GetWorldPos() - pEntity->GetWorldPos());
		deltaToClient.z = 0;

		Script::Call(gEnv->pScriptSystem,scriptEvent,pEntity->GetScriptTable(),"outputDistance",deltaToClient.len(),0);
	}

	gEnv->pScriptSystem->ReleaseFunc(scriptEvent);
}

void CTornado::GetMemoryStatistics(ICrySizer * s)
{
	s->Add(*this);
	s->AddContainer(m_spinningEnts);
}

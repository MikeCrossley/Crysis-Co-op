--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Scout
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--	- 15/01/2007   : Separated as the MOAC Scout by Tetsuji Iwasaki
--------------------------------------------------------------------------
local minUpdateTime = 0.4;
local	fSCOUTMOACPATROL_DONOTHING			= 0;
local fSCOUTMOACPATROL_PATROL1			  = 1;
local fSCOUTMOACPATROL_PATROL2 				= 2;
local fSCOUTMOACPATROL_PATROL3 				= 3;

--------------------------------------------------------------------------
AIBehaviour.ScoutMOACPatrol = {
	Name = "ScoutMOACPatrol",
	Base = "ScoutMOACDefault",
	alertness = 1,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )


		entity:Event_UnCloak();
		local vDown = { x=0, y=0.5, z = -1 };
		NormalizeVector( vDown );
		entity:SetSearchBeamDir(vDown);  

		entity.AI.deltaTSystem = System.GetCurrTime();
		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.cosinOp = 0.0;
		entity.AI.CurrentHook = fSCOUTMOACPATROL_DONOTHING;
		entity.AI.bBlockSignal = false;

		entity.AI.vMyPosRsv = {};
		entity.AI.vTargetRsv = {};
		entity.AI.vDirectionRsv = {};

		CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
		CopyVector( entity.AI.vTargetRsv, entity:GetPos() );
		CopyVector( entity.AI.vDirectionRsv, entity:GetPos() );

		AI.SetForcedNavigation( entity.id, entity.AI.vZero );

		entity.AI.vPatrolOffset = {};
		CopyVector( entity.AI.vPatrolOffset, entity.AI.vZero );
		local groupCount = AI.GetGroupCount( entity.id, GROUP_ENABLED );
		if ( groupCount > 1 ) then
			for i= 1,groupCount do
				local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
				if( member ~= nil and member.id == entity.id ) then
					if ( i == 1 ) then
						entity.AI.vPatrolOffset.x = 0;
						entity.AI.vPatrolOffset.y = 0;
						entity.AI.vPatrolOffset.z = 0;
					elseif ( i == 2 ) then
						entity.AI.vPatrolOffset.x = 50.0;
						entity.AI.vPatrolOffset.y = 0;
						entity.AI.vPatrolOffset.z = 0;
					else
						entity.AI.vPatrolOffset.x = 0;
						entity.AI.vPatrolOffset.y = 50.0;
						entity.AI.vPatrolOffset.z = 0;
					end
				end
			end
		end

		AI.CreateGoalPipe("ScoutPatrolDefault");
		AI.PushGoal("ScoutPatrolDefault","firecmd",0,0);
		AI.PushGoal("ScoutPatrolDefault","timeout",1,10.0);
		entity:SelectPipe(0,"ScoutPatrolDefault");

		AI.CreateGoalPipe("ScoutMOACLookAtRef");
		AI.PushGoal("ScoutMOACLookAtRef","firecmd",0,0);
		AI.PushGoal("ScoutMOACLookAtRef","locate",0,"refpoint");
		AI.PushGoal("ScoutMOACLookAtRef","lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACLookAtRef","timeout",1,60.0);

		AI.CreateGoalPipe("ScoutMOACLookAt");
		AI.PushGoal("ScoutMOACLookAt","locate",0,"atttarget");
		AI.PushGoal("ScoutMOACLookAt","+lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACLookAt","timeout",1,60.0);

		if ( entity.AI.ascensionScout ~= true ) then
			self:SCOUTMOACPATROL_PATROL1_START( entity );
		end

		entity.AI.scoutTimer2 = 1;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.ScoutMOACPatrol.SCOUTMOACPATROL_UPDATE", entity );

	end,

	--------------------------------------------------------------------------
	Destructor = function ( self, entity, data )
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		entity:EnableSearchBeam(false);
		if ( entity.AI.scoutTimer2 ~= nil ) then
			entity.AI.scoutTimer2 = nil;
		end
	end,

	--------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		if ( entity.AI.bBlockSignal == false ) then
			entity.AI.bBlockSignal = true;
			self:SCOUTMOACPATROL_PATROL3_START( entity );
		end
	end,
	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity );
	end,
	--------------------------------------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		local targetEntity;
		if ( data and data.id ) then
			targetEntity = System.GetEntity( data.id );
			if ( targetEntity ) then
				CopyVector( entity.AI.vLastEnemyPosition, targetEntity:GetPos() );
				CopyVector( g_SignalData.point, targetEntity:GetPos() );
				AI.Signal(SIGNALFILTER_GROUPONLY, 1, "SCOUTMOACPATROL_CHANGEPATROLLPOSITION",entity.id,g_SignalData);
			else
				return;
			end
		end

	end,
	--------------------------------------------------------------------------
	SCOUTMOACPATROL_CHANGEPATROLLPOSITION = function ( self, entity, sender, data )
		CopyVector( entity.AI.vLastEnemyPosition, data.point );
	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_UPDATE = function( entity )

		if ( entity.AI == nil or entity.AI.scoutTimer2 == nil or entity:GetSpeed() == nil ) then
			local myEntity = System.GetEntity( entity.id );
			if ( myEntity ) then
				local vZero = {x=0.0,y=0.0,z=0.0};
				AI.SetForcedNavigation( entity.id, vZero );
			end
			return;
		end

		if ( entity.id and System.GetEntity( entity.id ) ) then
		else
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_IDLE",entity.id);
			return;
		end

		if ( entity:IsActive() ) then
		else
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_IDLE",entity.id);
			return;
		end

		local dt = System.GetCurrTime() - entity.AI.deltaTSystem;
		entity.AI.deltaTSystem = System.GetCurrTime();
			
		entity.AI.scoutTimer2 = 1;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.ScoutMOACPatrol.SCOUTMOACPATROL_UPDATE", entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			AIBehaviour.ScoutMOACPatrol:OnPlayerSeen( entity, 0 );
		end

		entity.AI.cosinOp = entity.AI.cosinOp + 10.0*3.1416 / 180.0;
		if ( entity.AI.cosinOp > 3.1416*2.0 ) then
			entity.AI.cosinOp = entity.AI.cosinOp - 3.1416*2.0;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACPATROL_DONOTHING ) then
			AIBehaviour.ScoutMOACPatrol:SCOUTMOACPATROL_DONOTHING( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACPATROL_PATROL1 ) then
			AIBehaviour.ScoutMOACPatrol:SCOUTMOACPATROL_PATROL1( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACPATROL_PATROL2 ) then
			AIBehaviour.ScoutMOACPatrol:SCOUTMOACPATROL_PATROL2( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACPATROL_PATROL3 ) then
			AIBehaviour.ScoutMOACPatrol:SCOUTMOACPATROL_PATROL3( entity );
		else
			AIBehaviour.ScoutMOACPatrol:SCOUTMOACPATROL_DONOTHING( entity );
		end		

	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_DONOTHING  = function ( self, entity )
	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_PATROL1_START  = function ( self, entity )

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

		local vTmp = {};
		FastSumVectors( vTmp, entity.AI.vLastEnemyPosition, entity.AI.vPatrolOffset );
		SubVectors( vTmp, vTmp, entity.AI.vMyPosRsv );
		if ( LengthVector( vTmp ) < 1.0 ) then
			CopyVector( vTmp, entity:GetDirectionVector(1) );
		end
		vTmp.z = 0;
		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, 15.0 );

		FastSumVectors( entity.AI.vTargetRsv, vTmp, entity.AI.vLastEnemyPosition );
		FastSumVectors( entity.AI.vTargetRsv, entity.AI.vTargetRsv, entity.AI.vPatrolOffset );

		entity.AI.CurrentHook = fSCOUTMOACPATROL_PATROL1;
		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.bLock = System.GetCurrTime();
		
		CopyVector( vTmp, entity:GetPos() );
		vTmp.x = entity.AI.vTargetRsv.x;
		vTmp.y = entity.AI.vTargetRsv.y;
		vTmp.z = vTmp.z - 3.0;
		AI.SetRefPointPosition( entity.id, vTmp );
	
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"ScoutMOACLookAtRef");

	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_PATROL1  = function ( self, entity )

		local actionAngle = 10.0 * 3.1416 / 180.0;
		local vVel = {};
		local vVelRot = {};

		SubVectors( vVel, entity:GetPos(), entity.AI.vTargetRsv );
		if ( LengthVector( vVel ) < 1.0 ) then
			CopyVector( vVel, entity:GetDirectionVector(1) );
		end
		vVel.z =0;
		NormalizeVector( vVel );
		FastScaleVector( vVel, vVel, 15.0 );

		RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle * minUpdateTime * -1.0 );

		FastSumVectors( vVelRot, vVelRot, entity.AI.vTargetRsv );
		SubVectors( vVelRot, vVelRot, entity:GetPos() );
		vVelRot.z =0;
		NormalizeVector( vVelRot );
		FastScaleVector( vVelRot, vVelRot, 5.0 );

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );
		if ( vMyPos.z > entity.AI.vLastEnemyPosition.z + 30.0 ) then
			vVelRot.z = -5.0;
		end

		if ( vMyPos.z < entity.AI.vLastEnemyPosition.z + 15.0 ) then
			vVelRot.z = 3.0;
		end

	--	vVelRot.z = vVelRot.z + ( math.cos( entity.AI.cosinOp ) * 1.0 );

		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity , vVelRot , 1, 2.5 );
		AI.SetForcedNavigation( entity.id, vVelRot );

		if ( System.GetCurrTime() - entity.AI.bLock > 7.0 ) then
			entity:PlaySoundEvent("Sounds/alien:scout:searching", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
			entity:EnableSearchBeam(entity.AI.bEnableBeam);
			entity.AI.bLock = System.GetCurrTime();
		end

		if ( System.GetCurrTime() - entity.AI.circleSec > 20.0 ) then
			self:SCOUTMOACPATROL_PATROL2_START( entity );
			return;
		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_PATROL2_START  = function ( self, entity )

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

		local vTmp = {};
		FastSumVectors( vTmp, entity.AI.vLastEnemyPosition, entity.AI.vPatrolOffset );
		SubVectors( vTmp, vTmp, entity.AI.vMyPosRsv );
		if ( LengthVector( vTmp ) < 1.0 ) then
			CopyVector( vTmp, entity:GetDirectionVector(1) );
		end
		vTmp.z = 0;
		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, -15.0 );

		FastSumVectors( entity.AI.vTargetRsv, vTmp, entity.AI.vLastEnemyPosition );
		FastSumVectors( entity.AI.vTargetRsv, entity.AI.vTargetRsv, entity.AI.vPatrolOffset );

		entity.AI.CurrentHook = fSCOUTMOACPATROL_PATROL2;
		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.bLock = System.GetCurrTime()-4.0;

		CopyVector( vTmp, entity:GetPos() );
		vTmp.x = entity.AI.vTargetRsv.x;
		vTmp.y = entity.AI.vTargetRsv.y;
		vTmp.z = vTmp.z - 3.0;
		AI.SetRefPointPosition( entity.id, vTmp );

		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"ScoutMOACLookAtRef");

	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_PATROL2  = function ( self, entity )

		local actionAngle = -10.0 * 3.1416 / 180.0;
		local vVel = {};
		local vVelRot = {};
		
		SubVectors( vVel, entity:GetPos(), entity.AI.vTargetRsv );
		if ( LengthVector( vVel ) < 1.0 ) then
			CopyVector( vVel, entity:GetDirectionVector(1) );
		end
		vVel.z =0;
		NormalizeVector( vVel );
		FastScaleVector( vVel, vVel, 15.0 );

		RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle * minUpdateTime * -1.0 );

		FastSumVectors( vVelRot, vVelRot, entity.AI.vTargetRsv );
		SubVectors( vVelRot, vVelRot, entity:GetPos() );
		vVelRot.z =0;
		NormalizeVector( vVelRot );
		FastScaleVector( vVelRot, vVelRot, 5.0 );

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );
		if ( vMyPos.z > entity.AI.vLastEnemyPosition.z + 30.0 ) then
			vVelRot.z = -5.0;
		end

		if ( vMyPos.z < entity.AI.vLastEnemyPosition.z + 15.0 ) then
			vVelRot.z = 3.0;
		end

	--	vVelRot.z = vVelRot.z + ( math.cos( entity.AI.cosinOp ) * 1.0 );

		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity , vVelRot , 1, 2.5 );
		AI.SetForcedNavigation( entity.id, vVelRot );

		if ( System.GetCurrTime() - entity.AI.bLock > 10.0 ) then
			entity:PlaySoundEvent("Sounds/alien:scout:searching", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
			entity:EnableSearchBeam(entity.AI.bEnableBeam);
			entity.AI.bLock = System.GetCurrTime();
		end

		if ( System.GetCurrTime() - entity.AI.circleSec > 20.0 ) then
			self:SCOUTMOACPATROL_PATROL1_START( entity );
			return;
		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_PATROL3_START  = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 150.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACPATROL_PATROL3;
			entity.AI.circleSec = System.GetCurrTime();

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACLookAt");

			entity:EnableSearchBeam(false);

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACPATROL_PATROL3  = function ( self, entity )

		if ( System.GetCurrTime() - entity.AI.circleSec < 1.0 ) then
			local vTmp = { x=0.0, y=0.0, z=7.0 };
			AI.SetForcedNavigation( entity.id, vTmp );
		elseif ( System.GetCurrTime() - entity.AI.circleSec < 2.0 ) then
			local vTmp = { x=0.0, y=0.0, z=1.0 };
			AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_ATTACK", entity.id);
		end

	end,

}

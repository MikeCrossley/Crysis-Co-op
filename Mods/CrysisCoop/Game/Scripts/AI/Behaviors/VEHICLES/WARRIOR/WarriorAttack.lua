--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  
--------------------------------------------------------------------------
--  History:
--  - 06/02/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------


AIBehaviour.WarriorAttack = {
	Name = "WarriorAttack",
	alertness = 2,

	------------------------------------------------------------------------------------------
	-- SYSTEM HANDLERS
	------------------------------------------------------------------------------------------
	Constructor = function(self , entity )

		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.Tank);		

		AI.CreateGoalPipe("warrior_attack_start");
		AI.PushGoal("warrior_attack_start","timeout",1,0.5);
		AI.PushGoal("warrior_attack_start","signal",0,1,"WARRIOR_ATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"warrior_attack_start");

		entity.AI.shootCounter =0;
		entity.AI.bShootNexttime = false;
		entity.AI.bUseMachineGun = false;
		entity.AI.lastAnchor = nil;
		entity.AI.bMemoryCount = 0;

		entity.AI.vRefPointRsv = {};
		entity.AI.vMemoryPos = {};
		entity.AI.vLastPos = {};
		CopyVector( entity.AI.vMemoryPos, entity:GetPos() );
		CopyVector( entity.AI.vLastPos, entity:GetPos() );
		CopyVector( entity.AI.vRefPointRsv, AI.GetRefPointPosition(entity.id) );

	end,

	------------------------------------------------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
	end,	

	-----------------------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,

	-----------------------------------------------------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )



	end,

	------------------------------------------------------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	------------------------------------------------------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			CopyVector( entity.AI.vMemoryPos, target:GetPos() ); 
		else
			CopyVector( entity.AI.vMemoryPos, entity:GetPos() ); 
		end
	
	end,
	
	------------------------------------------------------------------------------------------
	OnTargetTooClose = function( self, entity, sender, data )
	end,

	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...

		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,
	
	------------------------------------------------------------------------------------------
	-- FG HANDLERS
	------------------------------------------------------------------------------------------
	REFPOINT_REACHED = function(self,entity,sender)
	end,

	GO_TO = function( self, entity, fDistance )
	end,

	ACT_GOTO = function( self, entity )
	end,

	------------------------------------------------------------------------------------------
	-- Behaviors
	------------------------------------------------------------------------------------------
	WARRIOR_ATTACK_START = function( self, entity, sender )

		local	anchorname = AI.GetAnchor(entity.id,100,AIAnchorTable.TANK_SPOT,AIANCHOR_RANDOM_IN_RANGE);
		if ( anchorname ) then
			local anchor = System.GetEntityByName(anchorname);
			if ( anchor ) then
				AI.SetRefPointPosition( entity.id , anchor:GetPos() );

				AI.CreateGoalPipe("warrior_backoff");
				AI.PushGoal("warrior_backoff","run",0,0);	
				AI.PushGoal("warrior_backoff","continuous",0,1);	
				AI.PushGoal("warrior_backoff","+locate",0,"refpoint");
				AI.PushGoal("warrior_backoff","+approach",0,3.0,AILASTOPRES_USE);	

				AI.PushGoal("warrior_backoff","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("warrior_backoff","timeout",1,0.5);
				AI.PushGoal("warrior_backoff","branch",1,-2);

				AI.PushGoal("warrior_backoff","signal",0,1,"WARRIOR_LOOK_AT_TARGET",SIGNALFILTER_SENDER);
				AI.PushGoal("warrior_backoff","timeout",1,0.1);
				AI.PushGoal("warrior_backoff","signal",0,1,"WARRIOR_ATTACK_START",SIGNALFILTER_SENDER);

				entity:SelectPipe(0,"warrior_backoff");
				return;
			end
		end
		
		AI.CreateGoalPipe("warrior_wait");
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.5);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_LOOK_AT_TARGET",SIGNALFILTER_SENDER);
		AI.PushGoal("warrior_wait","timeout",1,0.1);
		AI.PushGoal("warrior_wait","signal",0,1,"WARRIOR_ATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"warrior_wait");
		
	end,

	---------------------------------------------
	WARRIOR_LOOK_AT_TARGET = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vDirToTarget = {};
			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			
			NormalizeVector( vDirToTarget );
			FastScaleVector( vDirToTarget, vDirToTarget, 10.0 );
			FastSumVectors( vDirToTarget, vDirToTarget, entity:GetPos() );
			AI.SetRefPointPosition( entity.id , vDirToTarget );

			AI.CreateGoalPipe("warrior_lookat_target");
			AI.PushGoal("warrior_lookat_target","continuous",0,0);	
			AI.PushGoal("warrior_lookat_target","+locate",0,"refpoint");
			AI.PushGoal("warrior_lookat_target","+approach",1,3.0,AILASTOPRES_USE);	
			entity:InsertSubpipe(0,"warrior_lookat_target");

		end
	
	end,

	---------------------------------------------
	WARRIOR_CHECK_SHOOT = function( self, entity )

		local bStartFire = false;

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetType = AI.GetTargetType( entity.id );
			if( targetType ~= AITARGET_MEMORY ) then
				CopyVector( entity.AI.vLastPos, entity:GetPos() ); 
				entity.AI.bMemoryCount = 0;
			end
		
			local enemyPos = {};
			local randomFactor;
			CopyVector( enemyPos, target:GetPos() );

			if ( enemyPos.z - System.GetTerrainElevation( enemyPos ) > 10.0 ) then
				randomFactor =1; -- for more frequesnt shot for the air target.
			else
				randomFactor =6;
			end

			if ( entity.AI.shootCounter == 0 ) then
				if ( random( 1, randomFactor ) == 1 or entity.AI.bShootNexttime == true) then
					entity.AI.bShootNexttime = false;
					if ( entity.AI.bUseMachineGun ~=true ) then
						local vDirToTarget = {};
						local vMyDir = {};
						SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
						CopyVector( vMyDir, entity:GetDirectionVector(YAxis) );
						vDirToTarget.z = 0.0;
						vMyDir.z =0;
						NormalizeVector( vDirToTarget );
						NormalizeVector( vMyDir );
						local t = dotproduct3d( vDirToTarget, vMyDir );
						local inFOV = math.cos( 70.0 * 3.1415 / 180.0 );
						if ( t > inFOV  ) then
							entity.AI.shootCounter = 1;
						end
					end
				end
			end
		end

		if ( entity.AI.shootCounter > 0 ) then
			entity.AI.shootCounter = entity.AI.shootCounter + 1;
			if ( entity.AI.shootCounter == 2 ) then
				AI.CreateGoalPipe("tank_fire");
				AI.PushGoal("tank_fire","firecmd",0,1);
				entity:InsertSubpipe(0,"tank_fire");
			end
			if ( entity.AI.shootCounter > 12 ) then
				AI.CreateGoalPipe("tank_nofire");
				AI.PushGoal("tank_nofire","firecmd",0,0);
				AI.PushGoal("tank_nofire","timeout",1,0.5);
				entity:InsertSubpipe(0,"tank_nofire");
				entity.AI.shootCounter = 0;
			end
		end

	end,



}


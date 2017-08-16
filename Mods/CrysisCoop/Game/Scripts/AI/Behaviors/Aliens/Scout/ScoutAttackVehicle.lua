--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple outdoor indoor alien behavior
--  
--------------------------------------------------------------------------
--  History:
--	- 31/05/2006   : Created  by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutAttackVehicle = {
	Name = "ScoutAttackVehicle",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )


		entity.AI.normalSpeedRsv = entity.gameParams.stance[1].normalSpeed;
		entity.AI.maxSpeedRsv = entity.gameParams.stance[1].maxSpeed;

		entity.gameParams.stance[1].normalSpeed = entity.gameParams.stance[1].normalSpeed * 1.7;
		entity.gameParams.stance[1].maxSpeed = entity.gameParams.stance[1].normalSpeed * 1.7;
		entity.AI.actor:SetParams(entity.gameParams);

		-- called when the behaviour is selected

		AI.CreateGoalPipe("scoutAttackVehicle");
		AI.PushGoal("scoutAttackVehicle","timeout",1,0.1);
		AI.PushGoal("scoutAttackVehicle","signal",0,1,"SC_SCOUT_ATTACKVEHICLE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutAttackVehicle");

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
	
		entity.gameParams.stance[1].normalSpeed = entity.AI.normalSpeedRsv;
		entity.gameParams.stance[1].maxSpeed = entity.AI.maxSpeedRsv;
		entity.actor:SetParams(entity.gameParams);

		entity.actor:SetParams(entity.gameParams);
		entity:SelectPipe(0,"do_nothing");

		scoutSelected = nil;

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_ATTACKVEHICLE_WAIT", entity.id);
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnCloseContact= function( self, entity )
		-- called when AI gets at close distance to an enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,


	--------------------------------------------------------------------------
	SC_SCOUT_ATTACKVEHICLE = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- if the target is on the ground, start quitting the behavior.
			if ( AI.IsPointInWaterRegion( target:GetPos() ) < 0.5 ) then
				self:SC_SCOUT_ATTACKVEHICLE_WAIT( entity );
				return;
			end

			-- if the target is not on the vehicle
			local vehicleId = target.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
			else
				self:SC_SCOUT_ATTACKVEHICLE_WAIT( entity );
				return;
			end

			local vRefPos = {};
			local vUpTarget = {}
			local vFwdTarget = {}
			local vWngTarget = {}
			local	vehicle;
			
			if ( vehicleId ) then
				vehicle = System.GetEntity( vehicleId );
				if( vehicle ) then
				else
					self:SC_SCOUT_ATTACKVEHICLE_WAIT( entity );
					return;
				end
			end

			CopyVector( vRefPos, target:GetPos() );
			CopyVector( vUpTarget, vehicle:GetDirectionVector(2) );
			CopyVector( vWngTarget, vehicle:GetDirectionVector(0) );
			CopyVector( vFwdTarget, vehicle:GetDirectionVector(1) );
			FastScaleVector( vUpTarget, vUpTarget, 12.0 );
			FastScaleVector( vFwdTarget, vFwdTarget, 80.0 );
			FastScaleVector( vWngTarget, vWngTarget, random(-5,5) );
			
			FastSumVectors( vRefPos, vRefPos, vUpTarget );
			FastSumVectors( vRefPos, vRefPos, vFwdTarget );
			FastSumVectors( vRefPos, vRefPos, vWngTarget );

			AI.SetRefPointPosition( entity.id, vRefPos );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 12.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

			local vDirToTarget = {};

			SubVectors( vDirToTarget, entity:GetPos(), target:GetPos() );
			NormalizeVector( vDirToTarget );
			local s = dotproduct3d( vDirToTarget, vehicle:GetDirectionVector(1) );
			local inFov = math.cos( 60.0 * 3.1416 / 180.0 );


			if ( random(1,3) < 3 or s < inFov ) then

				AI.CreateGoalPipe("scoutAttackVehicle");
				AI.PushGoal("scoutAttackVehicle","run",0,1);	
				AI.PushGoal("scoutAttackVehicle","continuous",0,0);	
				AI.PushGoal("scoutAttackVehicle","locate",0,"refpoint");		
				AI.PushGoal("scoutAttackVehicle","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutAttackVehicle","signal",0,1,"SC_SCOUT_ATTACKVEHICLE",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackVehicle");

			else

				AI.CreateGoalPipe("scoutAttackVehicle2");
				AI.PushGoal("scoutAttackVehicle2","firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("scoutAttackVehicle2","timeout",1,3.0);
				AI.PushGoal("scoutAttackVehicle2","firecmd",0,0);
				AI.PushGoal("scoutAttackVehicle2","locate",0,"refpoint");		
				AI.PushGoal("scoutAttackVehicle2","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutAttackVehicle2","signal",0,1,"SC_SCOUT_ATTACKVEHICLE",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackVehicle2");

			end

		else
		
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);

		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_ATTACKVEHICLE_WAIT = function( self, entity )

		AI.CreateGoalPipe("scoutAttackVehicleWait");
		AI.PushGoal("scoutAttackVehicleWait","timeout",1,3.0);	
		AI.PushGoal("scoutAttackVehicleWait","signal",0,1,"SC_SCOUT_ATTACKVEHICLE_WAIT_END",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutAttackVehicleWait");

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_ATTACKVEHICLE_WAIT_END = function( self, entity )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
	
			if ( AI.IsPointInWaterRegion( target:GetPos() ) < 0.5 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
				return;
			end
			
			local vehicleId = target.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
				return;
			end
			
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
			return;
		end

		AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_ATTACKVEHICLE", entity.id);

	end,

	--------------------------------------------------------------------------
}
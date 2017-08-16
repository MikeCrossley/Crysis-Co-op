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
--  - 10/07/2006   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


--------------------------------------------------------------------------

AIBehaviour.TankFixedFollow = {
	Name = "TankFixedFollow",
	Base = "Car_follow",	
	alertness = 0,

	---------------------------------------------

	INVEHICLE_REQUEST_START_FIRE = function( self, entity, sender )
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			if ( AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity ) == true ) then
				AIBehaviour.TANKDEFAULT:request2ndGunnerShoot( entity );
				AI.CreateGoalPipe("tank_fire");
				AI.PushGoal("tank_fire","firecmd",0,1);
				entity:InsertSubpipe(0,"tank_fire");
			else
				AI.CreateGoalPipe("tank_fire");
				AI.PushGoal("tank_fire","firecmd",0,1);
				entity:InsertSubpipe(0,"tank_fire");
			end
		else
			self:INVEHICLE_REQUEST_STOP_FIRE2( entity );
		end
	end,

	INVEHICLE_REQUEST_STOP_FIRE = function( self, entity, sender )
		AI.CreateGoalPipe("tank_fire_stop");
		AI.PushGoal("tank_fire_stop","firecmd",0,0);
		AI.PushGoal("tank_fire_stop","timeout",1,0.1);
		AI.PushGoal("tank_fire_stop","signal",0,1,"INVEHICLE_REQUEST_STOP_FIRE_NEXT",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"tank_fire_stop");
	end,

	INVEHICLE_REQUEST_STOP_FIRE2 = function( self, entity, sender )
		AI.CreateGoalPipe("tank_fire_stop2");
		AI.PushGoal("tank_fire_stop2","firecmd",0,0);
		entity:InsertSubpipe(0,"tank_fire_stop2");
	end,

	INVEHICLE_REQUEST_STOP_FIRE_NEXT = function( self, entity, sender )
		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
				  if (seat.isDriver) then
						AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLE_CONTROL_START", member.id );
						return;
					end
				end
			end
		end	
	end,


	OnNoTarget = function( self, entity )
		self:INVEHICLE_REQUEST_STOP_FIRE( entity );
	end,

	-- SYSTEM EVENTS			-----
	OnPlayerSeen = function( self, entity, fDistance )

		-- called when the AI sees a living enemy
		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then
						AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLE_REQUEST_CONTROL", member.id );
						return;
					end
			
				end
			end
		end	

	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
		self:OnPlayerSeen( entity, 0.0 );
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender )	
		self:OnPlayerSeen( entity, 0.0 );
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
	end,

}

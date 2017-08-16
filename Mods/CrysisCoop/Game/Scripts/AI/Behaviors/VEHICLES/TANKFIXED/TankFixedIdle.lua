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


AIBehaviour.TankFixedIdle = {
	Name = "TankFixedIdle",
	Base = "VehicleIdle",	
	alertness = 0,

	---------------------------------------------
	Constructor = function(self , entity )
		
		AI.SetAdjustPath(entity.id,1);
		
		entity.vDefultPos = {};
		CopyVector ( entity.vDefultPos, entity:GetPos() );

		AIBehaviour.VehicleIdle:Constructor( entity );

		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,1);

	end,

	---------------------------------------------

	INVEHICLE_REQUEST_START_FIRE = function( self, entity, sender )
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

		local targetPos ={};
		CopyVector( targetPos, target:GetPos() );
		local height = targetPos.z - System.GetTerrainElevation( target:GetPos() );

			if ( height > 10.0 ) then -- flying target.
				AI.CreateGoalPipe("aaa_fire");
				AI.PushGoal("aaa_fire","firecmd",0,FIREMODE_CONTINUOUS);
				entity:InsertSubpipe(0,"aaa_fire");
			else
				if ( AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity ) == true ) then
					AIBehaviour.TANKDEFAULT:request2ndGunnerShoot( entity );
					AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
					AI.CreateGoalPipe("tank_fire");
					AI.PushGoal("tank_fire","firecmd",0,FIREMODE_SECONDARY);
					entity:InsertSubpipe(0,"tank_fire");
				else
					AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true )
					AI.CreateGoalPipe("tank_fire");
					AI.PushGoal("tank_fire","firecmd",0,1);
					entity:InsertSubpipe(0,"tank_fire");
				end
			end

		else
			self:INVEHICLE_REQUEST_STOP_FIRE2( entity );
		end
	end,

	INVEHICLE_REQUEST_STOP_FIRE = function( self, entity, sender )
		AI.CreateGoalPipe("tank_fire_stop");
		AI.PushGoal("tank_fire_stop","firecmd",0,0);
		AI.PushGoal("tank_fire_stop","locate",0,"atttarget");
		AI.PushGoal("tank_fire_stop","lookat",0,0,0,true,1);
		AI.PushGoal("tank_fire_stop","devalue",1,0,1);
		AI.PushGoal("tank_fire_stop","timeout",1,0.1);
		AI.PushGoal("tank_fire_stop","signal",0,1,"INVEHICLE_REQUEST_STOP_FIRE_NEXT",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"tank_fire_stop");
	end,

	INVEHICLE_REQUEST_STOP_FIRE2 = function( self, entity, sender )
		AI.CreateGoalPipe("tank_fire_stop2");
		AI.PushGoal("tank_fire_stop2","firecmd",0,0);
		AI.PushGoal("tank_fire_stop2","locate",0,"atttarget");
		AI.PushGoal("tank_fire_stop2","lookat",0,0,0,true,1);
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
		self:INVEHICLE_REQUEST_STOP_FIRE2( entity );
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
	OnEnemyDamage = function ( self, entity, sender,data)
		if ( AI.GetAIParameter( entity.id, AIPARAM_PERCEPTIONSCALE_VISUAL ) > 0.0 ) then
			if ( data and data.id == entity.id ) then
			else
				self:OnPlayerSeen( entity, 0.0 );
			end
		end
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)	
		if ( AI.GetAIParameter( entity.id, AIPARAM_PERCEPTIONSCALE_VISUAL ) > 0.0 ) then
			if ( data and data.id == entity.id ) then
			else
				self:OnPlayerSeen( entity, 0.0 );
			end
		end
	end,


}

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a common vehicle idle stuff
--  
--------------------------------------------------------------------------
--  History:
--  - 13/07/2005   : Created by Kirill Bulatsev
--	
--
--------------------------------------------------------------------------


AIBehaviour.VehicleIdle = {
	Name = "VehicleIdle",
	Base = "VehicleAct",	


	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )
		AIBehaviour.VehicleAct:Constructor( entity );
	end,
	---------------------------------------------
	---------------------------------------------
	---------------------------------------------
	OnSomebodyDied = function( self, entity, sender )
	end,

	OnGroupMemberDied = function( self, entity, sender )
	end,

	OnGroupMemberDiedNearest = function( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
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
	OnBulletRain = function ( self, entity, sender, data )	
		self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity, sender, data );
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
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
	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------
	---------------------------------------------
	--------------------------------------------
	DRIVER_IN = function( self,entity, sender )
	end,	
	
	--------------------------------------------
	
	---------------------------------------------
	---------------------------------------------
	STOP_VEHICLE = function(self,entity,sender,data)
--		entity:SignalDriver("VEHICLE_REFPOINT_REACHED");
		if ( data ~= nil ) then
			-- HACK : ask me the reason 24/04/2006 Tetsuji --
			entity:AIDriver(0);
			if(entity.AI.bInConvoy and entity.AI.convoyNext) then
				AI.Signal(SIGNALFILTER_SENDER,0,"STOP_VEHICLE",entity.AI.convoyNext.id)
			end
		else
			entity:SignalCrew("EXIT_VEHICLE_STAND");			
			entity:AIDriver(0);
			if(entity.AI.bInConvoy and entity.AI.convoyNext) then
				AI.Signal(SIGNALFILTER_SENDER,0,"STOP_VEHICLE",entity.AI.convoyNext.id)
			end
		end
	end,
	
	---------------------------------------------
	READY_FOR_CONVOY_START = function(self,entity,sender,data)
		-- sent by a convoy member to the convoy leader
		if(entity.AI.isConvoyLeader) then 
			entity.AI.convoyReadyUnits = entity.AI.convoyReadyUnits +1;
--			System.Log(System.GetEntity(data.id):GetName().." ready for convoy - units = "..entity.AI.convoyReadyUnits.." out of "..entity.AI.convoyUnits );
			
			if(entity.AI.convoyReadyUnits >= entity.AI.convoyUnits) then
				AI.Signal(SIGNALFILTER_SENDER,0,"START_MOVING",entity.id);
			end
		end
		
		entity.AI.VehicleConvoyRequester = sender; -- for the convoy requested by FG 18/07/2006 Tetsuji

	end,

	TRY_TO_MOVE_AT_DISTANCE	= function(self,entity,sender)
		-- move to right distance
		if(AI.GetAttentionTargetOf(entity.id)) then
			AI.GetAttentionTargetPosition(entity.id,g_Vectors.temp);
			AI.SetBeaconPosition(entity.id,g_Vectors.temp);

			local fDistance = AI.GetAttentionTargetDistance(entity.id);
--			System.Log("TANKIE: mindist="..fMinDist.." maxdist="..fMaxDist.." desireddist="..fDesiredDist.." distance="..fDistance);
--	TO DO: use this when it'll move correctly
--			if( math.abs(fDistance - fDesiredDist)>2 and entity:SetFireSpot(g_Vectors.temp,fDesiredDist)) then 
--				entity:SelectPipe(0,"t_approach_refpoint");
--			else
				entity:SelectPipe(0,"do_nothing");
				entity:InsertSubpipe(0,"start_fire");			
--			end	
		end
	end,
	
	

	
}

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a common vehicle goto stuff
--  
--------------------------------------------------------------------------
--  History:
--  - 13/07/2005   : Created by Kirill Bulatsev
--	
--
--------------------------------------------------------------------------


AIBehaviour.VehicleGoto = {
	Name = "VehicleGoto",
	Base = "VehicleAct",	
	
	

	---------------------------------------------
	Constructor = function(self , entity )
		-- no need to enable the vehicle! it's already enabled since we are here
		-- entity:AIDriver(1);
		--AI.LogEvent(entity:GetName().." VehicleGoto Constructor ");
		if(entity.AI.bInConvoy) then 
			AI.Signal( SIGNALFILTER_SENDER, 1, "READY_FOR_CONVOY_START",entity.AI.convoyLeader.id,entity.id);
			-- AI.LogEvent(entity:GetName().." VehicleGoto Constructor READY_FOR_CONVOY_START:");
		else			
			-- entity:InsertSubpipe(0,"vehicle_goto");
		end
	end,
	---------------------------------------------
	OnActivate = function(self, entity )
		self.allowed = 1;
	end,
	
	OnEndPathOffset = function(self, entity)
		AI.LogEvent(entity:GetName().." couldn't reach the goto destination");
	end,
	---------------------------------------------
	OnNoTarget = function(self, entity )
--		entity:SelectPipe(0,"return_to_start");
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )

--		entity:TriggerEvent(AIEVENT_REJECT);

	end,

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--		entity:TriggerEvent(AIEVENT_REJECT);

	end,

	--------------------------------------------------------------------------
	OnSomebodyDied = function( self, entity, sender )
	end,

	OnGroupMemberDied = function( self, entity, sender )
		if ( entity.AI.vehicleIgnorantIssued and entity.AI.vehicleIgnorantIssued == true ) then
		else
			if ( entity.AI.VehicleConvoyRequester ~= nil ) then
				entity:SelectPipe(0,"do_nothing");
				entity.AI.VehicleConvoyRequester = nil;
				entity:SignalCrew("SHARED_LEAVE_ME_VEHICLE");
				AI.Signal(0, 1, "DRIVER_OUT",entity.id);		
			end
		end
	end,

	OnGroupMemberDiedNearest = function( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
	end,

	---------------------------------------------
	OnPlayerMemory = function(self, entity )
	end,
	---------------------------------------------
	OnEnemySeen = function(self, entity )
	end,
	---------------------------------------------
	OnDeadFriendSeen = function(self,entity )
	end,
	---------------------------------------------
	OnGranateSeen = function(self, entity )
	
		entity:InsertSubpipe(0,"c_grenade_run_away" );	
	
	end,
	---------------------------------------------
	OnDied = function( self,entity )
	end,
	---------------------------------------------
	---------------------------------------------
	

	-- CUSTOM
	---------------------------------------------
	REFPOINT_REACHED = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_SENDER,0,"STOP_VEHICLE",entity.id);		
	end,


	---------------------------------------------
	DRIVER_OUT = function( self,entity,sender )
--printf( "car patol  -------------- driver out" );	
		entity:SelectPipe(0,"c_brake" );
	end,	

--	STOP_AND_EXIT = function( self,entity,sender )
--		entity:SelectPipe(0,"c_brake" );
--		entity:SignalCrew("EXIT_VEHICLE_STAND");			
--	end,
	--------------------------------------------
	
	START_MOVING = function( self,entity,sender )
		entity:InsertSubpipe(0,"vehicle_goto");
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------
	--
	--	FlowGraph	actions 
	--
	---------------------------------------------------------------------------------------------------------------------------------------
	
}

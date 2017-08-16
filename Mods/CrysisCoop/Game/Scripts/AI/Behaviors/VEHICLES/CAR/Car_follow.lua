--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple non-combat car path 
--  
--------------------------------------------------------------------------
--  History:
--  - 29/11/2004   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------


AIBehaviour.Car_follow = {
	Name = "Car_follow",

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )
--		AI.LogEvent( "CAR_FOLLOW: (" .. entity.Properties.leaderName .. ") d:" .. entity.Properties.followDistance );		

--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "SHARED_ENTER_ME_VEHICLE",entity.id);
		-- no need to enable the vehicle! it's already enabled since we are here
		-- entity:AIDriver(1);
		local followed = entity.AI.convoyPrev;
		if(followed) then
		
		
			local wmin, wmax = entity:GetLocalBBox();
			local wmin2, wmax2 = followed:GetLocalBBox();
			local length = math.floor(wmax.y-wmin.y + wmax2.y-wmin2.y) ;
			-- to do: Join formation instead of follow
			-- for formations, first they must be decoupled from the CLeader
			
			-- follow distance should be passed with signal or being set in properties (editor), not hardcoded
			length = 30;
			
			g_StringTemp1 = "follow_vehicle"..length;
			AI.CreateGoalPipe(g_StringTemp1);
			AI.PushGoal(g_StringTemp1,"acqtarget",1,"");
			AI.PushGoal(g_StringTemp1,"follow",1,length);

			AI.LogEvent( entity:GetName().." following vehicle "..followed:GetName().." at "..length.."m distance" );	

			entity:InsertSubpipe(0,g_StringTemp1,followed.id);	--:GetName());
		else
			AI.Warning(entity:GetName().." has no vehicle to follow in convoy");
			
		end			
		
		if(entity.AI.bInConvoy and entity.AI.convoyLeader) then 
			AI.Signal( SIGNALFILTER_SENDER, 1, "READY_FOR_CONVOY_START",entity.AI.convoyLeader.id,entity.id);
		end


	end,
	---------------------------------------------
	Destructor = function(self , entity )
	
	end,	
	---------------------------------------------
	---------------------------------------------
	---------------------------------------------
	OnSomebodyDied = function( self, entity, sender )
	end,

	OnGroupMemberDied = function( self, entity, sender )
		if ( entity.AI.vehicleIgnorantIssued and entity.AI.vehicleIgnorantIssued ==true ) then
		else

			AI.Signal( 0, 1, "unload",entity.id);
--		AI.LogEvent( "SENDING NotifyDriverDied" );
--		AI.Commander:NotifyDriverDied(entity);
		
-- 	stop if the driver is killed
--	if( sender == entity.AI.driver ) then
--		AI.Signal( 0, 1, "STOP_VEHICLE",entity.id);
--	end	

		end
	end,

	OnGroupMemberDiedNearest = function( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
	end,

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--printf( "Vehicle -------------- RejectPlayer" );	

--		entity:TriggerEvent(AIEVENT_REJECT);

	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------
	---------------------------------------------
	--------------------------------------------
	DRIVER_IN = function( self,entity, sender )
--		local pipeName = "follow_"..entity:GetName();
--		
--		-----------------------------------------------------
--		AI.CreateGoalPipe( pipeName );
--		AI.PushGoal( pipeName, "locate", 1, entity.Properties.leaderName );
--		AI.PushGoal( pipeName, "acqtarget", 1, "" );
--		AI.PushGoal( pipeName, "follow", 1, entity.Properties.followDistance );
--		AI.PushGoal( pipeName, "signal", 0, 1, "next_point" , 0 );	-- get next point in path
--
--		entity:SelectPipe( 0, pipeName );
	end,	
	
	--------------------------------------------
	next_point = function( self,entity, sender )	
	
--		AI.LogEvent("CAR_FOLLOW -> done");		
	
	end,



	---------------------------------------------
	unload = function( self,entity,sender )

--		AI.Signal(SIGNALFILTER_SENDER, 1, "SHARED_LEAVE_ME_VEHICLE",entity.id);
		entity:SignalCrew("SHARED_LEAVE_ME_VEHICLE");
		AI.Signal(0, 1, "DRIVER_OUT",entity.id);		
		
	-- Disable the AI driver.
	-- Note: This should be handled in when AI driver leaves the car, not here!

	end,
	---------------------------------------------
}

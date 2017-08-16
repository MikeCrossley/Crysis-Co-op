--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple generic vehicle path linear
--  
--------------------------------------------------------------------------
--  History:
--  - 29/11/2004   : Created by Kirill Bulatsev
--	- Moved
--
--------------------------------------------------------------------------


AIBehaviour.Vehicle_Path = {
	Name = "Vehicle_Path",
	

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )

		entity.AI.PathStep = -1;
		entity.AI.FirstStep = true;
--		AI.Signal( 0, 1, "DRIVER_IN",entity.id);
--		local firstpoint = System.GetEntityByName(entity.PropertiesInstance.AI.PathName.."0");
--		if(firstpoint) then
--			AI.LogEvent("Vehicle "..entity:GetName().." following linear path "..entity.PropertiesInstance.AI.PathName);
--			CopyVector(g_SignalData.point,firstpoint:GetWorldPos());
--			g_SignalData.id = entity.id;
--			g_SignalData.iValue = AIGOALTYPE_PATH;
--			self.circularPath = false;
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "ORDER_ENTER_VEHICLE", entity.id,g_SignalData);
--		else
--			AI.Warning("Vehicle "..self:GetName().." has wrong path name or first path point is missing");
--		end
--		-- no need to enable the vehicle! it's already enabled since we are here
--		-- entity:AIDriver(1);
		if(entity.AI.bInConvoy) then 
			AI.Signal( SIGNALFILTER_SENDER, 1, "READY_FOR_CONVOY_START",entity.AI.convoyLeader.id,entity.id);
		else			
			AI.Signal( 0, 1, "next_point",entity.id);					
		end

	end,

	---------------------------------------------
	OnSomebodyDied = function( self,entity,sender,data )
--		if( data.id == entity.AI.driver.id ) then				-- stop if the driver is killed
--			AI.Signal( 0, 1, "STOP_VEHICLE",entity.id);
--		end	
	end,	

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------

	DRIVER_IN = function( self,entity, sender )

	end,	
	
	--------------------------------------------
	next_point = function( self,entity, sender )	
	
		entity.AI.PathStep = entity.AI.PathStep + 1;

		local name = entity.PropertiesInstance.AI.PathName;	
		local tpname = name..entity.AI.PathStep;
		local TagPoint = System.GetEntityByName(tpname);

		if (TagPoint==nil) then 		
			if (entity.AI.PathStep == 0) then 
				AI.Warning(" Entity "..entity:GetName().." has a path job but no specified path points.");
				do return end
			else
				-- end of path, all out
				if(entity.PropertiesInstance.bCircularPath ==0) then 
					AI.Signal( 0, 1, "STOP_VEHICLE",entity.id);
					entity:SelectPipe(0,"do_nothing");
					return;
				end
			end
			entity.AI.PathStep = 0;
			tpname = name..entity.AI.PathStep;
		end

		AI.LogEvent("VEHICLE PATH -> Approaching point "..tpname);		
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"vehicle_path",tpname);
		if(entity.AI.FirstStep) then
			entity:InsertSubpipe(0,"clear_all");
			entity.AI.FirstStep = nil;
		end
	
	end,

	
	---------------------------------------------
	START_MOVING = function( self,entity,sender )
		AI.Signal(SIGNALFILTER_SENDER,1,"next_point",entity.id);
	end,
	
	---------------------------------------------
	
}

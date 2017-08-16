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


AIBehaviour.Car_path = {
	Name = "Car_path",
	

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )

		entity.AI.PathStep = 0;
		if(entity.AI.bInConvoy) then 
			AI.Signal( SIGNALFILTER_SENDER, 1, "READY_FOR_CONVOY_START",entity.AI.convoyLeader.id);
		else			
			AI.Signal( 0, 1, "START_MOVING",entity.id);
		end
	end,

	---------------------------------------------
	OnSomebodyDied = function( self,entity,sender,data )
		if( data.id == entity.AI.driver.id ) then				-- stop if the driver is killed
			AI.Signal( 0, 1, "DRIVER_OUT",entity.id);
		end	
	end,	

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------

	START_MOVING = function( self,entity, sender )
		AI.Signal( 0, 1, "next_point",entity.id);					
	end,	
	
	--------------------------------------------
	next_point = function( self,entity, sender )	
	
		local name = entity.Properties.AI.PathName;	

		local TagPoint = System.GetEntityByName(name..entity.AI.PathStep);
		if (TagPoint) then 		
			tpname = name..entity.AI.PathStep;
		else
			if (entity.AI.PathStep == 0) then 
				AI.Warning(" Entity "..entity:GetName.." has a path job but no specified path points.");
				do return end
			end
			entity.AI.PathStep = 0;
		end

		AI.LogEvent("CAR_PATH -> Approaching point "..tpname);		
		entity:SelectPipe(0,"car_path",tpname);

		entity.AI.PathStep = entity.AI.PathStep + 1;
	
	end,

	---------------------------------------------
	DRIVER_OUT = function( self,entity,sender )
		entity:SelectPipe(0,"c_brake" );
		entity:DropPeople();
	end,	

	---------------------------------------------
}

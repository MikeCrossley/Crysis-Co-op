--------------------------------------------------
--   Created By: Luciano
--   Description: the behavior for the driver going to a predetermined destination 
--------------------------

AIBehaviour.DriverGoto = {
	Name = "DriverGoto",
	Base = "InVehicle",


	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	
 	---------------------------------------------
 	OnQueryUseObject = function ( self, entity, sender, extraData )
 		-- ignore this signal, execute DEFAULT
 		AIBehaviour.DEFAULT:OnQueryUseObject( entity, sender, extraData );
 	end,
	--------------------------------------------------		
	VEHICLE_REFPOINT_REACHED = function( self,entity, sender )
		-- called by vehicle when it reaches the reference Point 
		--entity.AI.theVehicle:SignalCrew("exited_vehicle");
		AI.Signal(SIGNALFILTER_SENDER,0,1,"DRIVER_OUT",entity.AI.theVehicle.id);
		entity.AI.theVehicle:SignalCrew("EXIT_VEHICLE");

	end,

	--------------------------------------------------
	PASSENGER_SPOTTED_PLAYER = function( self,entity, sender )
		-- called when a passenger/gunner sees the player
	end,
	
	--------------------------------------------------
	PASSENGER_SPOTTED_ENEMY = function( self,entity, sender )
		-- called when a passenger/gunner sees an enemy
	end,
	
	--------------------------------------------------
	EVERYONE_OUT = function( self,entity, sender )
		entity.AI.theVehicle:SignalCrew("exited_vehicle");
	end,
	
}	--------------------------------------------------

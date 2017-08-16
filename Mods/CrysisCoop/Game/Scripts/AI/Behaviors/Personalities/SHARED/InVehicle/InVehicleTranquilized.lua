--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
--------------------------------------------------------------------------
--   Description: Guy falls asleep inside a vehicle
--  Same as HBaseTranquilized, except that he goes back to PREVIOUS 
--------------------------------------------------------------------------
--  History:
--  - May 2007   : Created by Dejan Pavlovski
--------------------------------------------------------------------------



AIBehaviour.InVehicleTranquilized = {
	Name = "InVehicleTranquilized",
	Base = "HBaseTranquilized",
	alertness = 0,
	exclusive = 1,
	
	Constructor = function(self,entity,data)
		if(AIBehaviour.HBaseTranquilized.Constructor) then 
			AIBehaviour.HBaseTranquilized:Constructor(entity,data);
		end
		AI.SetIgnorant(entity.id,1);
	end,
	
	Destructor = function(self,entity)
		if(AIBehaviour.HBaseTranquilized.Destructor) then 
			AIBehaviour.HBaseTranquilized:Destructor(entity,data);
		end
		AI.SetIgnorant(entity.id,0);
	end
}

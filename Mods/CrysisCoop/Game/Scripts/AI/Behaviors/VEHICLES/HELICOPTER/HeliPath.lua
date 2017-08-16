--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Helocipter Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 09/06/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------
AIBehaviour.HeliPath = {
	Name = "HeliPath",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )


		entity.AI.PathStep = 0;

		AI.Signal(SIGNALFILTER_SENDER, 1, "PatrolPath",entity.id);

	end,
	
	---------------------------------------------
	---------------------------------------------
	----------------------------------------------------FUNCTIONS 
	PatrolPath = function (self, entity, sender)
		-- select next tagpoint for patrolling
		local name = entity:GetName();
		local tpname = name.."_P"..entity.AI.PathStep;
		local TagPoint = System.GetEntityByName(tpname);
		if (TagPoint== nil) then 		
			entity.AI.PathStep = 0;
			tpname = name.."_P"..entity.AI.PathStep;
AI.LogEvent(">>>>helipath looping "..tpname);
		end
AI.LogEvent(">>>>helipath selecting "..tpname);		
		entity:SelectPipe(0,"h_goto",tpname);
		entity.AI.PathStep = entity.AI.PathStep + 1;
	end,
	

	---------------------------------------------
}

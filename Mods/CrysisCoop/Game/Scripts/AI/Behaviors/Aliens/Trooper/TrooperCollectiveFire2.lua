--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper Collective fire 2: the troopers shoots in cascade
--------------------------------------------------------------------------
--  History:
--  - Feb 2006     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperCollectiveFire2 = {
	Name = "TrooperCollectiveFire2",
	Base = "TrooperGroupCombat",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		-- data.iValue = progression number
		-- data.id = enemy target id;
		local myProgressionNumber = data.iValue;
		local numUnits = AI.GetUnitCount(entity.id,UPR_COMBAT_GROUND);
		g_StringTemp1 = "tr_cascade_fire"..myProgressionNumber;
		AI.CreateGoalPipe(g_StringTemp1);
		AI.PushGoal(g_StringTemp1,"acqtarget",1,"");
		if(myProgressionNumber>0) then 
			AI.PushGoal(g_StringTemp1,"timeout",1,myProgressionNumber*0.15);
		end
		AI.PushGoal(g_StringTemp1,"firecmd",1,FIREMODE_CONTINUOUS);
		AI.PushGoal(g_StringTemp1,"timeout",1,1.2);
		AI.PushGoal(g_StringTemp1,"firecmd",1,0);
		AI.PushGoal(g_StringTemp1,"timeout",1,(numUnits - myProgressionNumber)*0.15+0.8)
		
		entity:SelectPipe(0,g_StringTemp1,data.id);
			
	end,

	---------------------------------------------
	Destructor = function (self, entity,data)
		if(entity.iTimer) then
			Script.KillTimer(entity.iTimer);
			entity.iTimer = nil;
		end
	end,

	---------------------------------------------
	VISIBILITY_POINT_REACHED = function(self,entity,sender)
		-- to do: switch the beam on
		local leader = AI.GetLeader(entity.id);
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);

	end,	
	
	
}
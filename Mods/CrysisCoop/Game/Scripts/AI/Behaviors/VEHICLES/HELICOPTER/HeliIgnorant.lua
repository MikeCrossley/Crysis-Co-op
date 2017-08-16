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
--  - 15/02/2007   : the first implementation by Tetsuji
--
--------------------------------------------------------------------------

AIBehaviour.HeliIgnorant = {
	Name = "HeliIgnorant",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity, sender, data )
		entity:SelectPipe(0,"do_nothing");
		entity.AI.vehicleIgnorantIssued = true;
		AI.SetIgnorant(entity.id,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,0.0);	
	end,
	
	ACT_DUMMY = function( self, entity, sender, data )
		AI.CreateGoalPipe("resetHelicopter");
		AI.PushGoal("resetHelicopter","lookat",1,-500);
		AI.PushGoal("resetHelicopter","signal",1,1,"TO_HELI_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"resetHelicopter",nil,data.iValue);
	end,

}

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

AIBehaviour.HeliUnIgnorant = {
	Name = "HeliUnIgnorant",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity, sender, data )
		entity:SelectPipe(0,"do_nothing");
	end,
	
	ACT_DUMMY = function( self, entity, sender, data )
		AI.CreateGoalPipe("resetHelicopter");
		AI.PushGoal("resetHelicopter","clear",0,1);
		AI.PushGoal("resetHelicopter","signal",1,1,"RESETIGNORANT",SIGNALFILTER_SENDER);
		AI.PushGoal("resetHelicopter","signal",1,1,"TO_HELI_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"resetHelicopter",nil,data.iValue);
	end,

	RESETIGNORANT = function( self, entity )
		AI.SetIgnorant(entity.id,0);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange);	
		entity.AI.vehicleIgnorantIssued = false;
	end,	

}

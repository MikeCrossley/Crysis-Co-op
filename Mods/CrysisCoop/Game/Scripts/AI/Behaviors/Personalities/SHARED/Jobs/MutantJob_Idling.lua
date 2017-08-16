-- Created by Petar; 
--------------------------


AIBehaviour.MutantJob_Idling = {
	Name = "MutantJob_Idling",
	JOB = 1,
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnSpawn = function(self,entity )
		entity:SelectPipe(0,"mutant_idling");
		entity:InsertSubpipe(0,"setup_idle");	-- get in correct stance
	end,
	----------------------------------------------------FUNCTIONS 
	DO_SOMETHING_IDLE = function (self, entity, sender)
		entity:MakeRandomIdleAnimation();
	end,

}
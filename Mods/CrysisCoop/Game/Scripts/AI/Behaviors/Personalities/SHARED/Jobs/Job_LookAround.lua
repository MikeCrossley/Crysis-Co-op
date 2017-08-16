-- stand still and look around
--------------------------

AIBehaviour.Job_LookAround = {
	Name = "Job_LookAround",				
	JOB = 1,	
	---------------------------------------------

	Constructor = function(self,entity )
		AI.CreateGoalPipe("m11_look_around");
		AI.PushGoal("m11_look_around", "lookaround", 1, 90);
		AI.PushGoal("m11_look_around", "timeout", 1, 0.4, 2);

		entity:InitAICombat();
		entity:SelectPipe(0,"m11_look_around");
		entity:InsertSubpipe(0,"clear_all"); -- to allow receive again onplayerseen 

		AI.Signal(SIGNALFILTER_SENDER, 0, "HOLSTERITEM_FALSE", entity.id);
	end,
}

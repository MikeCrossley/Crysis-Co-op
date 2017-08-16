-- linear patroling behaviour - 
-- This behavior uses paths for patrolling. Paths do not have to be closed and the characters will approach the path from 
-- beginning to end and start the path again.
--
-- created by sten: 		18-09-2002
-- last modified by petar
--------------------------
-- will patrol a path and just stops, 
-- if finding an AIANCHOR_IDLE in a range of 3 meters close to a path point

AIBehaviour.Job_PatrolPath = {
	Name = "Job_PatrolPath",
	JOB = 1,
		
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();

		entity:CheckWalkFollower();

		AI.CreateGoalPipe("JobPatrolPath");
		AI.PushGoal("JobPatrolPath","pathfind",1,entity:GetName().."_PATH");
		AI.PushGoal("JobPatrolPath","trace",1,1,1);
		AI.PushGoal("JobPatrolPath","signal",0,1,"DO_SOMETHING_IDLE",0);
		AI.PushGoal("JobPatrolPath","branch",1,-2);
				
		entity:SelectPipe(0,"JobPatrolPath");
		entity:InsertSubpipe(0,"setup_idle");
	end,
	
	---------------------------------------------
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
	end,
	------------------------------------------------------------------------
	-- GROUP SIGNALS
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	
}
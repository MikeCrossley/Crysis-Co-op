-- patroling behaviour that will form a formation - 
-- created by sten: 		18-09-2002
-- last modified by sten:	22-10-2002
--------------------------
-- will patrol a path and just stop, 
-- if finding an AIANCHOR_IDLE in a range of 3 meters close to a path point


AIBehaviour.Job_PatrolPathFormation = {
	Name = "Job_PatrolPathFormation",
	JOB = 1,
		
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		-- start patrolling and reset to first tagpoint
		entity.cnt.AnimationSystemEnabled = 1;
		self:PatrolPath(entity,sender);
	end,
	---------------------------------------------
	OnActivate = function(self,entity )
--		self:PatrolPath(entity,sender);
	end,
	---------------------------------------------		
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
	end,
	----------------------------------------------------FUNCTIONS -------------------------------------------------------------
	GoOn = function (self, entity, sender)
		-- restart path 
		entity:MakeIdle();
		self:PatrolPath(entity,sender);
	end,
	------------------------------------------------------------------------
	IdleStart = function (self, entity, sender)
		-- start idle
		if  (AI.FindObjectOfType(entity:GetPos(),2,AIAnchorTable.AIANCHOR_IDLE)) then
				entity:InsertSubpipe(0,"PatrolIdle");
				entity:InsertSubpipe(0,"LookIdleAnchor");
				AI.Signal(SIGNALFILTER_GROUPONLY,1,"BREAK_AND_IDLE",entity.id);
		end
	end,
	------------------------------------------------------------------------
	IdleLook = function (self, entity, sender)
		-- random look around
		if (random(1,2)==1) then
			entity:InsertSubpipe(0,"LookLeft");
		else
			entity:InsertSubpipe(0,"LookRight");
		end
	end,
	------------------------------------------------------------------------
	IdleRandom = function (self, entity, sender)
		-- pick random animation
		local MyAnim = IdleManager:GetIdle();
			-----	
			AI.CreateGoalPipe(MyAnim.Name.."AIS_IdleDelay");
			AI.PushGoal(MyAnim.Name.."AIS_IdleDelay","timeout",1,MyAnim.duration);
			-----
		entity:StartAnimation(0,MyAnim.Name);							
		entity:InsertSubpipe(0,MyAnim.Name.."AIS_IdleDelay");
	end,
	------------------------------------------------------------------------
	IdleEnd = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	PatrolPath = function (self, entity, sender)
		-- select path to patrol
		-- entity.cnt.AnimationSystemEnabled = 1;
		
		AI.CreateGoalPipe("JobPatrolPathFormation"..entity.Properties.pathname);
		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"run",1,0);
		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"bodypos",1,0);
		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"pathfind",1,entity.Properties.pathname);
		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"signal",0,1,"MOVE_IN_FORMATION",SIGNALFILTER_GROUPONLY);
		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"trace",1,1);
--		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"signal",0,1,"IdleStart",0);
--		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"signal",0,1,"REGAIN_FORMATION",SIGNALFILTER_GROUPONLY);
--		AI.PushGoal("JobPatrolPathFormation"..entity.Properties.pathname,"branch",1,-3);
		
		entity:SelectPipe(0,"JobPatrolPathFormation"..entity.Properties.pathname);
		entity:InsertSubpipe(0,"FormWoodwalk");
	end,
	------------------------------------------------------------------------
	-- GROUP SIGNALS
	------------------------------------------------------------------------
	MOVE_IN_FORMATION = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	
}

 
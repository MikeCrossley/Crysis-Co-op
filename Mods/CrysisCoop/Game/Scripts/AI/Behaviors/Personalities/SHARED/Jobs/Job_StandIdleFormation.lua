-- stand still and run thru random idles but will keep formation - 
-- modified by sten: 		15-10-2002
-- based on Job_StandIdle	
--------------------------

AIBehaviour.Job_StandIdleFormation = {
	Name = "Job_StandIdleFormation",		
	JOB = 1,
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity.cnt.AnimationSystemEnabled = 1;
		entity:SelectPipe(0,"PatrolIdle");
	end,
	----------------------------------------------------FUNCTIONS -------------------------------------------------------------
	GoOn = function (self, entity, sender)
		entity:SelectPipe(0,"PatrolIdle");
	end,
	------------------------------------------------------------------------
	IdleStart = function (self, entity, sender)
		entity:SelectPipe(0,"PatrolIdle");
		entity:InsertSubpipe(0,"LookIdleAnchor");
	end,
	------------------------------------------------------------------------
	IdleLook = function (self, entity, sender)
		self:IdleRandom(entity,sender);
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
		entity:SelectPipe(0,"PatrolIdle");
	end,
	------------------------------------------------------------------------
	-- GROUP SIGNALS
	------------------------------------------------------------------------
	MOVE_IN_FORMATION = function (self, entity, sender)
		-- the leader wants everyone to move in formation
		AI.LogEvent(entity:GetName()..":received MOVE_IN_FORMATION");
		entity:SelectPipe(0,"PatrolFormation");
	end,
	------------------------------------------------------------------------
	REGAIN_FORMATION = function (self, entity, sender)
		-- the leader wants to provide the formation again
		AI.LogEvent(entity:GetName()..":received REGAIN_FORMATION");
		entity:SelectPipe(0,"RegainFormation");
	end,
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
		-- the leader wants everyone break the formation
		AI.LogEvent(entity:GetName()..":received BREAK_AND_IDLE");
		self:IdleStart(entity,sender);
	end,
	------------------------------------------------------------------------
}



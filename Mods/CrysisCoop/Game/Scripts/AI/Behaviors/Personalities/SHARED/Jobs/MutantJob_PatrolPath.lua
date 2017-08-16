-- node patroling behaviour - 
-- version 1 - amanda 2003-01-18
--------------------------


AIBehaviour.MutantJob_PatrolPath = {
	Name = "MutantJob_PatrolPath",
	JOB = 1,
	
	---------------------------------------------
	-- SYSTEM EVENTS			
	---------------------------------------------
	OnSpawn = function(self,entity )
--	AI.LogEvent("\003["..entity:GetName() .."]++++++++++++spawned MutantJob_PatrolPath");
		entity.cnt.AnimationSystemEnabled = 1;
		
		AI.CreateGoalPipe("JobPatrolPath"..entity.Properties.pathname);
		AI.PushGoal("JobPatrolPath"..entity.Properties.pathname,"run",1,0);
		AI.PushGoal("JobPatrolPath"..entity.Properties.pathname,"bodypos",1,0);
		AI.PushGoal("JobPatrolPath"..entity.Properties.pathname,"pathfind",1,entity.Properties.pathname);
		AI.PushGoal("JobPatrolPath"..entity.Properties.pathname,"trace",1,1,1);
		AI.PushGoal("JobPatrolPath"..entity.Properties.pathname,"signal",0,1,"IDLE_ANIMATION",0);
		AI.PushGoal("JobPatrolPath"..entity.Properties.pathname,"branch",1,-2);
		
		self:PatrolPath(entity,sender);
	end,
	---------------------------------------------		
	OnBored = function (self, entity)
	
	end,
	---------------------------------------------
	OnActivate = function(self,entity )
 		self:PatrolPath(entity,sender);
	end,
	------------------------------------------------------------------------
	IDLE_ANIMATION = function (self, entity)
	--occasionaly choose a random idle
		local MyAnim = Mutant_IdleManager:GetIdle(entity);
		if ( MyAnim) then
			
 --			AI.LogEvent("\003["..entity:GetName() .."]+++++++++++++ifle anim ["..MyAnim.Name.."]");
			-----	
			AI.CreateGoalPipe(MyAnim.Name.."Delay");
			AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
			AI.PushGoal(MyAnim.Name.."Delay","timeout",1,0.5,1.5);
			AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"PatrolPath",0);
			-----
			entity:StartAnimation(0,MyAnim.Name);							
			entity:InsertSubpipe(0,MyAnim.Name.."Delay");
		else
			self:PatrolPath(entity,sender);
		end

	end,
	------------------------------------------------------------------------
	PatrolPath = function (self, entity, sender)			
		entity:SelectPipe(0,"JobPatrolPath"..entity.Properties.pathname);
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

 
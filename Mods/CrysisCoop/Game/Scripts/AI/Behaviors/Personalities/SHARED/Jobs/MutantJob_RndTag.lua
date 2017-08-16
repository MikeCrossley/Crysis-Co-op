-- node patroling behaviour - 
-- should be retired now same as job_patrolNode.lua
-- version 1 - amanda 2003-01-18
--------------------------


AIBehaviour.MutantJob_RndTag = {
	Name = "MutantJob_RndTag",
	JOB = 1,
	
	---------------------------------------------
	-- SYSTEM EVENTS			
	---------------------------------------------
	OnSpawn = function(self,entity )
--	AI.LogEvent("\003["..entity:GetName() .."]++++++++++++spawned MutantJob_RndTag");
		entity.cnt.AnimationSystemEnabled = 1;
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
			entity:SelectPipe(0,MyAnim.Name.."Delay");
		else
			self:PatrolPath(entity,sender);
		end

	end,
	------------------------------------------------------------------------
	PatrolPath = function (self, entity, sender)
		
		local rnd=random(entity.Properties.pathstart,entity.Properties.pathsteps);
--		AI.LogEvent("\003["..entity:GetName() .."]+++++++++++++path step ["..entity.Properties.pathname..rnd.."]");
		entity:SelectPipe(0,"job_tagSet",entity.Properties.pathname..rnd);
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

 
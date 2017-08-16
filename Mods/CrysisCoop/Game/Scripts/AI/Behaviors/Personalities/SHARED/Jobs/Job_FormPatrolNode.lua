-- node patroling behaviour - 
-- Randomly move between points in a tag set, at each point run an idle animation.
--
---- OnBored will start a conversation if you have placed a AIANCHOR_RANDOM_TALK near where he is bored
-- created by sten: 		18-09-2002
-- @version 3 2003-02-05 amanda replaced with simpler version same behaviour
-- petar finished simplifying
--------------------------
AIBehaviour.Job_FormPatrolNode = {
	Name = "Job_FormPatrolNode",
	JOB = 1,
	
	---------------------------------------------
	-- SYSTEM EVENTS			
	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();
		entity.AI.PathStep = 0;

		local name = entity:GetName();
			
		-- find highest number of tagpoints
		while System.GetEntityByName(name.."_P"..entity.AI.PathStep) do		
			entity.AI.PathStep=entity.AI.PathStep+1;
		end

		self:PatrolPath(entity);		
	end,

	OnJobContinue = function(self,entity )
		entity:InitAIRelaxed();
		self:PatrolPath(entity);
	end,
	---------------------------------------------		
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
	end,
	------------------------------------------------------------------------
	PatrolPath = function (self, entity, sender)
		
		local rnd=random(0,entity.AI.PathStep);
		entity:SelectPipe(0,"patrol_approach_to",entity:GetName().."_P"..rnd);
		entity:InsertSubpipe(0,"make_formation");
	end,
	------------------------------------------------------------------------
	-- GROUP SIGNALS
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	
}
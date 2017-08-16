-- circular patroling behaviour - 
--Each character will patrol a set of TagPoints in a circular way. ie 1 2 3 4 5 1 2 3 4 5 etc.

--The character will approach each TagPoint sequentialy, look in the direction of the current TagPoint, 
--make some idles and look around. After the last TagPoint he will return to his first point and start again.

---- OnBored will start a conversation if you have placed a AIANCHOR_RANDOM_TALK near where he is bored

-- created by sten: 		18-09-2002
-- last modified by sten:	17-10-2002
-- last modified by petar
---------------------------------


AIBehaviour.Job_FormPatrolCircle = {
	Name = "Job_FormPatrolCircle",
	JOB = 1,

	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();
		entity.AI.PathStep = 0;
		self:PatrolPath(entity);
	end,
	---------------------------------------------		
	OnJobContinue = function(self,entity )
		entity:InitAIRelaxed();
		self:PatrolPath(entity);
	end,
	---------------------------------------------		
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
	end,
	----------------------------------------------------FUNCTIONS 
	PatrolPath = function (self, entity, sender)
		-- select next tagpoint for patrolling
		local name = entity:GetName();

		local tpname = name.."_P0";	

		local TagPoint = System.GetEntityByName(name.."_P"..entity.AI.PathStep);		
		if (TagPoint) then 		
			tpname = name.."_P"..entity.AI.PathStep;
		else
			if (entity.AI.PathStep == 0) then 
				AI.Warning(" Entity "..name.." has a path job but no specified path points.");
				do return end
			end
			entity.AI.PathStep = 0;
		end

		
		entity:SelectPipe(0,"patrol_approach_to",tpname);
		entity:InsertSubpipe(0,"make_formation");

		entity.AI.PathStep = entity.AI.PathStep + 1;
	end,
	
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------	
}

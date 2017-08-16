--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: simple behaviour for testing 3d navigation
--  
--------------------------------------------------------------------------
--  History:
--  - 2/12/2004   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------


AIBehaviour.Job_3D = {
	Name = "Job_3D",
	JOB = 1,

	
	-- SYSTEM EVENTS			-----
	---------------------------------------------

--	OnSpawn = Job_3D,
	Constructor = function(self,entity )
		AI.LogEvent("AIBehaviour.Job_3D OnSpawn");
	
		AI.CreateGoalPipe("find3d");
		AI.PushGoal("find3d","acqtarget",0,"");		
--		AI.PushGoal("find3d","approach",0,1);	
		AI.PushGoal("find3d","pathfind",1,"");
----		AI.PushGoal("find3d","trace",0,1);
		AI.PushGoal("find3d","timeout",1,.1);
--		AI.PushGoal("find3d","clear",1);		
		local name = entity:GetName().."_P0";
--		entity:SelectPipe(0,"find3d","thing");
		entity:SelectPipe(0,"find3d",name);		

	end,
	---------------------------------------------		
	
	
	Job_3D = function(self,entity )
	
	
	AI.LogEvent("AIBehaviour.Job_3D constructor");
	
		entity:InitAIRelaxed();
		entity.AI_PathStep = 0;
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

--		local TagPoint = Game:GetTagPoint(name.."_P"..entity.AI_PathStep);
		local TagPoint = System.GetEntityByName(name.."_P"..entity.AI_PathStep);
		if (TagPoint) then 		
			tpname = name.."_P"..entity.AI_PathStep;
		else
			if (entity.AI_PathStep == 0) then 
				AI.Warning(" Entity "..name.." has a path job but no specified path points.");
				do return end
			end
			entity.AI_PathStep = 0;
		end


--	AI.CreateGoalPipe("patrol_test");
--	AI.PushGoal("patrol_test","acqtarget",1,"");
--	AI.PushGoal("patrol_test","approach",1,1.1);
--	entity:SelectPipe(0,"patrol_test",tpname);


		
		entity:SelectPipe(0,"patrol_approach_to",tpname);

		entity.AI_PathStep = entity.AI_PathStep + 1;
	end,
	
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------	
}

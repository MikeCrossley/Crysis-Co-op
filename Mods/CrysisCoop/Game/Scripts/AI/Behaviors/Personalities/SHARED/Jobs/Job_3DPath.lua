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


AIBehaviour.Job_3DPath = {
	Name = "Job_3DPath",
	JOB = 1,

	
	-- SYSTEM EVENTS			-----
	---------------------------------------------

	Constructor = function(self,entity )
		AI.LogEvent("AIBehaviour.Job_3DPath Constructor");
	
		AI.CreateGoalPipe("path3d");
		AI.PushGoal("path3d","acqtarget",0,"");		
		AI.PushGoal("path3d","run",0,2);	
		AI.PushGoal("path3d","approach",1,2.0);	
--		AI.PushGoal("path3d","pathfind",1,"");
----		AI.PushGoal("path3d","trace",0,1);
--		AI.PushGoal("path3d","timeout",1,.1);
--		AI.PushGoal("path3d","clear",1);		
		AI.PushGoal("path3d","signal",0,1,"next_point",SIGNALFILTER_SENDER);	-- get next point in path
		
--		entity:SelectPipe(0,"path3d","thing");

		entity.AI_PathStep = 0;
		AI.Signal( SIGNALFILTER_SENDER, 1, "next_point",entity.id);


	end,
	---------------------------------------------		
	
	
	---------------------------------------------		
	
	--------------------------------------------
	next_point = function( self,entity, sender )	
	
		local name = entity:GetName();
		local tpname = name.."_P0";	

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

--		AI.LogEvent("Job_3DPath -> Approaching point "..tpname);		
		entity:SelectPipe(0,"path3d",tpname);

		entity.AI_PathStep = entity.AI_PathStep + 1;
	
	end,	
	------------------------------------------------------------------------	
}

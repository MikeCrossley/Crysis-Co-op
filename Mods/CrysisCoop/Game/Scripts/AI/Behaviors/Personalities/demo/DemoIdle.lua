----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: the idle (default) behaviour for the Cover
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 08:nov:2005   : Created by Kirill Bulatsev
--
----------------------------------------------------------------------------------------------------´


AIBehaviour.DemoIdle = {
	Name = "DemoIdle",
	Base = "Dumb",		
	
	Constructor = function (self, entity)

		-- this checks for mounted weapons around and uses them
--		AIBehaviour.DEFAULT:SHARED_FIND_USE_MOUNTED_WEAPON( entity );

--	local target = System.GetEntityByName("DEST");
--	CopyVector(g_SignalData.point, target:GetWorldPos());	
--	AI.CommEvent(entity.id, SOUND_THREATENING, g_SignalData.point);
--	do return end

local pipeName = "test_pipe";
AI.BeginGoalPipe("der_pipe");
AI.PushGoal("bodypos", 0, BODYPOS_STAND);
AI.BeginGroup();
	AI.PushGoal("locate", 0, "DEST");
	AI.PushGoal("approach", 0, 2);
	AI.PushGoal("timeout", 0, 3, 4);
AI.EndGroup();
AI.PushGoal("wait", 0, WAIT_ANY_2);
AI.PushGoal("clear", 0, 0); -- stops approaching - 0 means keep att. target
AI.PushGoal("timeout", 1, 5);
AI.EndGoalPipe();

entity:SelectPipe(0,"der_pipe");
do return end


	local pipeName = "diver";

	AI.CreateGoalPipe(pipeName);
	
	AI.PushGoal(pipeName,"bodypos",1,BODYPOS_CROUCH,1);
	AI.PushGoal(pipeName,"strafe",0,0,0,0);		
	AI.PushGoal(pipeName,"locate",1,"POINT");
	AI.PushGoal(pipeName, "approach",1,1,AILASTOPRES_USE);
	
	
--	AI.PushGoal(pipeName,"bodypos",1,BODYPOS_PRONE,1);
--	AI.PushGoal(pipeName,"bodypos",1,BODYPOS_STAND);
--	AI.PushGoal(pipeName,"locate",1,"POINT");
--	AI.PushGoal(pipeName, "+approach",1,1,AILASTOPRES_USE);
--	AI.PushGoal(pipeName,"locate",1,"POINT1");
--	AI.PushGoal(pipeName, "approach", 1, 1);	-- check hide	
--	AI.PushGoal(pipeName,"firecmd",0,1);
--	AI.PushGoal(pipeName,"timeout",1,10,12);
		
		
	entity:SelectPipe(0,pipeName);
--   	entity:InsertSubpipe(0, "throw_grenade");
--		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.sightrange*1.5);
		
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		entity:MakeAlerted();
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"melee_close");
	end,
	
	
	

}

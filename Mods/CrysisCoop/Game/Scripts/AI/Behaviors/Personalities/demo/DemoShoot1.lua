----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: 
-- hardcoding behavior for video recording
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 08:nov:2005   : Created by Kirill Bulatsev
--
----------------------------------------------------------------------------------------------------´


AIBehaviour.DemoShoot1 = {

	Name = "DemoShoot1",
	Base = "Dumb",		


	Constructor = function (self, entity)
		entity:MakeAlerted();


		-- this checks for mounted weapons around and uses them
--		AIBehaviour.DEFAULT:SHARED_FIND_USE_MOUNTED_WEAPON( entity );

	local pipeName = "demo_"..entity:GetName();
	AI.CreateGoalPipe(pipeName);
	AI.PushGoal(pipeName,"firecmd",0,1);
	AI.PushGoal(pipeName,"timeout",1,1,2);
	AI.PushGoal(pipeName,"bodypos",0,BODYPOS_CROUCH);	
		
		
		
		
		entity:SelectPipe(0,pipeName);
--   	entity:InsertSubpipe(0, "throw_grenade");
--		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.sightrange*1.5);
		
	end,

}

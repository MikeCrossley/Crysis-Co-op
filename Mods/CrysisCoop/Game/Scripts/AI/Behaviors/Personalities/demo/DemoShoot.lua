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


AIBehaviour.DemoShoot = {

	Name = "DemoShoot",
	Base = "Dumb",		


	Constructor = function (self, entity)
		entity:MakeAlerted();

--		entity:SelectPipe(0,"cv_scramble");
--		entity:InsertSubpipe(0,"melee_far");
--entity:InsertSubpipe(0,"cv_cqb_melee");
--do return end



--AI.Signal(SIGNALFILTER_SENDER,1,"SMART_THROW_GRENADE",entity.id);
--do return end

local pipeName = "demo_"..entity:GetName();
AI.CreateGoalPipe(pipeName);
AI.PushGoal(pipeName,"bodypos", 0, BODYPOS_STAND);
--AI.PushGoal(pipeName,"bodypos", 0, BODYPOS_CROUCH);
AI.PushGoal(pipeName,"firecmd", 1, FIREMODE_BURST, 0);
AI.PushGoal(pipeName,"timeout", 1, .2);
entity:SelectPipe(0,pipeName);


do return end



		-- this checks for mounted weapons around and uses them
--		AIBehaviour.DEFAULT:SHARED_FIND_USE_MOUNTED_WEAPON( entity );

	local pipeName = "demo_"..entity:GetName();
	AI.CreateGoalPipe(pipeName);
--	AI.PushGoal(pipeName,"firecmd",0,1);
	AI.PushGoal(pipeName,"hide",1,20,HM_NEAREST);
	AI.PushGoal(pipeName,"usecover",1,COVER_HIDE, 5);
	AI.PushGoal(pipeName,"firecmd",0,1);	
	AI.PushGoal(pipeName,"usecover",1,COVER_UNHIDE, 4);	
	AI.PushGoal(pipeName,"firecmd",0,0);	


--	local pipeName = "demo_"..entity:GetName();
--	AI.CreateGoalPipe(pipeName);
--	AI.PushGoal(pipeName,"firecmd",0,1);
--	AI.PushGoal(pipeName,"animation",0,AIANIM_ACTION,"peekLeft",5);	
--	AI.PushGoal(pipeName,"timeout",1,1,2);
		
		entity:SelectPipe(0,pipeName);
--   	entity:InsertSubpipe(0, "throw_grenade");
--		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.sightrange*1.5);
		
--		entity:InsertSubpipe(0,"throw_grenade_execute");			
		
	end,
	
	THROW_GRENADE_DONE = function (self, entity)	
		local pipeName = "demo_"..entity:GetName();
		AI.CreateGoalPipe(pipeName);
		AI.PushGoal(pipeName,"bodypos", 0, BODYPOS_CROUCH);
		AI.PushGoal(pipeName,"firecmd",0,1);	
		AI.PushGoal(pipeName,"timeout", 1, 0.7, 1.4);
		entity:SelectPipe(0,pipeName);
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"melee_close");
	end,


}

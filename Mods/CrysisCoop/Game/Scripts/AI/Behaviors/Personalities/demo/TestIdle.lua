
AIBehaviour.TestIdle = {
	Name = "TestIdle",
	Base = "Dumb",		

	Constructor = function (self, entity)

		entity:MakeAlerted();

		---------------------------------------------
		AI.CreateGoalPipe("test123");
		AI.PushGoal("test123","bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("test123","locate",0,"testi");
		AI.PushGoal("test123","acqtarget",0,"");
--		AI.PushGoal("test123","strafe",0,2,2);
--		AI.PushGoal("test123","run",0,1);
--		AI.PushGoal("test123","timeout",1,1);
--		AI.PushGoal("test123","approach",1,1);

		AI.PushGoal("test123","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("test123","bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("test123","run",0,1);
		AI.PushGoal("test123","strafe",0,2,2);

		AI.PushGoal("test123","hide",1,10,HM_NEAREST);
		AI.PushGoal("test123","usecover",1,COVER_HIDE,1,1,1);
		AI.PushGoal("test123","usecover",1,COVER_UNHIDE,3,3,1);
		AI.PushGoal("test123","usecover",1,COVER_HIDE,3,3,1); 
		AI.PushGoal("test123","usecover",1,COVER_UNHIDE,3,3,1); 
		AI.PushGoal("test123","usecover",1,COVER_HIDE,3,3,1); 
		AI.PushGoal("test123","usecover",1,COVER_UNHIDE,3,3,1);

		---------------------------------------------
		AI.BeginGoalPipe("test1");
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("timeout",1,4);
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("timeout",1,4);
			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
			AI.PushGoal("timeout",1,4);
			AI.PushGoal("bodypos",1,BODYPOS_PRONE);
			AI.PushGoal("timeout",1,4);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test0");
--			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("timeout",1,4);
			AI.PushGoal("firecmd",0,FIREMODE_OFF);
			AI.PushGoal("timeout",1,0.5);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test3");
			AI.PushGoal("bodypos",1,BODYPOS_PRONE);
			AI.PushGoal("timeout",1,4);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test4");
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("firecmd",0,FIREMODE_AIM);

			AI.PushGoal("timeout",1,0.5); --0.2,0.5);

			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("adjustaim",0,0,1);

--			AI.PushGoal("bodypos",1,BODYPOS_STAND);
--			AI.PushGoal("timeout",1,20);
--			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
			AI.PushGoal("timeout",1,100);
--			AI.PushGoal("bodypos",1,BODYPOS_PRONE);
--			AI.PushGoal("timeout",1,4);

			AI.PushGoal("clear",0,0);
			
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test6");

			AI.BeginGroup();
				AI.PushGoal("locate",0,"testi");
				AI.PushGoal("approach",0,12,AILASTOPRES_USE,10.0);
				AI.PushGoal("timeout",0,2);
			AI.EndGroup();
			AI.PushGoal("wait", 1, WAIT_ANY_2);
			AI.PushGoal("clear",0,0);

			AI.PushGoal("timeout",1,2);

		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test7");
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("timeout",1,60);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test8123");
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");

			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			
			AI.PushGoal("hide",1,30,HM_NEAREST+HM_INCLUDE_SOFTCOVERS);
--			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("usecover",1,COVER_HIDE,4,4,1);
--			AI.PushGoal("firecmd",0,FIREMODE_AIM);
--			AI.PushGoal("usecover",1,COVER_UNHIDE,7,7,1);
--			AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("usecover",1,COVER_HIDE,4,4,1);
--			AI.PushGoal("firecmd",0,FIREMODE_AIM);
--			AI.PushGoal("usecover",1,COVER_UNHIDE,7,7,1);

--			AI.PushGoal("timeout",1,60);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test9");
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("timeout",1,0.5);
			AI.PushGoal("firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("timeout",1,6);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test10");
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");

			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			
			AI.PushGoal("timeout",1,0.5);

			AI.PushGoal("bodypos",1,BODYPOS_PRONE);
			AI.PushGoal("timeout",1,3);

			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("timeout",1,3);

			AI.PushGoal("bodypos",1,BODYPOS_PRONE);
			AI.PushGoal("timeout",1,3);

			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
			AI.PushGoal("timeout",1,3);

			AI.PushGoal("bodypos",1,BODYPOS_PRONE);
			AI.PushGoal("timeout",1,3);

		AI.EndGoalPipe();


		---------------------------------------------
		AI.BeginGoalPipe("test11");
			AI.PushGoal("locate", 0, "testi");
			AI.PushGoal("+animtarget", 0, 1, "jumpHigh", 0.5, 5.0, 0.5);
			AI.PushGoal("+approach", 0, 0.0, AILASTOPRES_USE);
			AI.PushGoal("+timeout", 1, 6);
			AI.PushGoal("animation", 1, AIANIM_SIGNAL, "salute");
			AI.PushGoal("timeout", 1, 100);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test12");
			AI.PushGoal("timeout", 1, 0.5);
			AI.PushGoal("locate",0,"testi");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("signal",0,1,"TEST_POS",0);
			AI.PushGoal("timeout", 1, 0.5);
			AI.PushGoal("locate", 0, "refpoint");
			AI.PushGoal("approach", 1, 1.0, AILASTOPRES_USE);
--			AI.PushGoal("timeout", 1, 3);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test13");
			AI.PushGoal("timeout", 1, 0.5);
--			AI.PushGoal("locate",0,"look");
--			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("run",0,1);
			AI.PushGoal("strafe",0,0,0,2);
			AI.PushGoal("locate", 0, "move");
			AI.PushGoal("approach", 1, 1.0, AILASTOPRES_USE);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test14");
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("locate",0,"Dude");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("timeout", 1, 10);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test14b");
			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("timeout", 1, 0.5);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("testAdvance");
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("run", 0, 1);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("locate", 0, "refpoint");
			AI.PushGoal("approach", 1, 1.0, AILASTOPRES_USE);
			AI.PushGoal("adjustaim",0,0,1);
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("timeout", 1, 10);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("testGather");
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("run", 0, 1);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("locate", 0, "refpoint");
			AI.PushGoal("approach", 1, 3.0, AILASTOPRES_USE);
			AI.PushGoal("timeout", 1, 10);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("testSearch");
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("run", 0, 2);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("locate", 0, "refpoint");
			AI.PushGoal("stick",1,0.5,AILASTOPRES_USE);
--			AI.PushGoal("approach", 1, 1.0, AILASTOPRES_USE+AILASTOPRES_LOOKAT);
--			AI.PushGoal("timeout", 1, 10);
		AI.EndGoalPipe();


--		entity.AI.tryingToReload = false;

--		entity.actor:SelectItemByName("SOCOM");

--		entity:SelectPipe(0,"test14");

--		entity:SelectPipe(0,"sn_close_combat_group");
--		entity:SelectPipe(0,"test0");¨

	end,

	--------------------------------------------------
	PROTO_RELOAD_START = function (self,entity, sender)
		entity:SelectPipe(0,"test14b");
	end,

	--------------------------------------------------
	PROTO_RELOAD_DONE = function (self,entity, sender)
		entity:SelectPipe(0,"test14");
	end,

	--------------------------------------------------
	TEST_POS = function (self,entity, sender)
		local advancePoint = AI.GetGroupTacticPoint(entity.id, 0, GE_SEEK_POS);
		AI.SetRefPointPosition(entity.id, advancePoint);
	end,

	--------------------------------------------------
	OnCoverCompromised = function (self,entity, sender)
--		entity:SelectPipe(0,"test8");		
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		-- Do melee at close range.
--		if(AI.CanMelee(entity.id)) then
--			entity:SelectPipe(0,"melee_close");
--		end
	end,


	COVER_NORMALATTACK = function (self,entity, sender)
		entity:SelectPipe(0,"test7");		
	end,
	
--
--	--------------------------------------------------
--	OnOutOfAmmo = function (self,entity, sender)
--		if(entity.AI.tryingToReload) then
--			entity:Reload();
--			entity.AI.tryingToReload = false;
--			AI.Signal(SIGNALFILTER_SENDER,1,"COVER_NORMALATTACK",entity.id);
--		else
--			entity:SelectPipe(0,"sn_use_cover_reload");
--			entity.AI.tryingToReload = true;
--		end
--	end,

	---------------------------------------------
	OnAdvanceFormationTest = function (self, entity, sender, data)
		AI.SetRefPointPosition(entity.id, data.point);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"testAdvance");
	end,

	---------------------------------------------
	OnGatherTest = function (self, entity, sender, data)
		AI.SetRefPointPosition(entity.id, data.point);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"testGather");
	end,

	---------------------------------------------
	OnSearchTest = function (self, entity, sender, data)
--		AI.SetRefPointPosition(entity.id, data.point);
--		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"testSearch");
	end,

}

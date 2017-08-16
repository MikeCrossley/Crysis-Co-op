--------------------------------------------------
-- SuitAttack
-- this is modifyed Cover2Attack behavior
-- AI with nano suit
--------------------------
--   created: Kirill Bulatsev 25-10-2006


AIBehaviour.SuitAttack = {
	Name = "SuitAttack",
	alertness = 2,

	-----------------------------------------------------
	Constructor = function (self, entity)

		---------------------------------------------
		AI.BeginGoalPipe("su_fast_close_range");
			AI.PushGoal("signal",0,1,"SETUP_CQB",0);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("strafe",0,10,10);
			AI.PushGoal("run",0,0);--1);
			AI.PushGoal("firecmd",0,1);

			AI.PushGoal("signal",0,1,"SET_REFPOINT_CQB",0);
			
			AI.PushGoal("branch", 1, "HIDE", IF_SEES_TARGET, 20.0, BODYPOS_CROUCH);
			AI.PushGoal( "branch", 1, "MOVE", BRANCH_ALWAYS);

			AI.PushLabel("HIDE");
				AI.PushGoal("locate",0,"probtarget");
				AI.PushGoal("+seekcover", 1, COVER_HIDE, 6.0, 3, 1+2);

			AI.PushLabel("MOVE");
				-- still not exposed to target, try to move a bit.
				AI.PushGoal("branch", 1, "OTHER_DIST", IF_RANDOM, 0.5);
					AI.PushGoal("locate",0,"refpoint");
					AI.PushGoal("+approach",1,-3,AILASTOPRES_USE,15.0);
					AI.PushGoal( "branch", 1, "DONE", BRANCH_ALWAYS);
				AI.PushLabel("OTHER_DIST");
					AI.PushGoal("branch", 1, "OTHER_DIST2", IF_RANDOM, 0.5);
					AI.PushGoal("locate",0,"refpoint");
					AI.PushGoal("+approach",1,-5,AILASTOPRES_USE,15.0);
					AI.PushGoal( "branch", 1, "DONE", BRANCH_ALWAYS);
				AI.PushLabel("OTHER_DIST");
					AI.PushGoal("locate",0,"refpoint");
					AI.PushGoal("+approach",1,-7,AILASTOPRES_USE,15.0);

			AI.PushLabel("DONE");
			AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("su_fast_close_range_dodge");
			AI.PushGoal("signal",0,1,"SETUP_CQB",0);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("strafe",0,10,10);
			AI.PushGoal("run",0,1);
			AI.PushGoal("firecmd",0,1);

			AI.PushGoal("signal",0,1,"SET_REFPOINT_CQB",0);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+approach",1,-5,AILASTOPRES_USE,15.0);
			AI.PushGoal( "branch", 1, "DONE", BRANCH_ALWAYS);

			AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("su_fast_seek");
			AI.PushGoal("signal",0,1,"SETUP_CQB",0);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("run",0,1);
			AI.PushGoal("locate", 0,"probtarget_in_territory");
			AI.PushGoal("+approach",1,15,AILASTOPRES_USE,15.0);

			AI.PushGoal("run",0,0);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("strafe",0,10,10);
			AI.PushGoal("bodypos",0,BODYPOS_STEALTH,1);
			AI.PushGoal("locate", 0,"probtarget_in_territory");
			AI.PushGoal("+approach",1,1,AILASTOPRES_USE,15.0);

			AI.PushGoal("signal",0,1,"SET_REFPOINT_CQB",0);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+approach",1,-7,AILASTOPRES_USE,15.0);

			AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("su_sniper");
			AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);
			AI.PushGoal("firecmd",0,FIREMODE_BURST_DRAWFIRE);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,0,1);
			AI.PushGoal("timeout",1,5,7);
			AI.PushGoal("clear",0,0);
			AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
			AI.PushGoal("firecmd",0,0);

			AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("run",0,1);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);
			
			AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("su_sniper_move");
			AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
			AI.PushGoal("bodypos",0,BODYPOS_STEALTH,1);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("run",0,1);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);

			AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("su_sniper_seek");
			AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("run",0,1);
			AI.PushGoal("approach",1,-15,AILASTOPRES_USE,15.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);

			AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,0,1);
			AI.PushGoal("timeout",1,2,3);
			AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
			AI.PushGoal("firecmd",0,0);

			AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
		AI.EndGoalPipe();
		
		
		
		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastTargetSeenTime = _time;
		
		entity.AI.seek = false;
		entity.AI.sniper = true;
		
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);

		self:COVER_NORMALATTACK(entity);
	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
	end,
	
	---------------------------------------------
	SET_REFPOINT_SNIPER = function (self, entity, sender)
		AI.SetRefpointToMoveAwayFromGroup(entity.id, 20.0, 45.0);
	end,

	---------------------------------------------
	SET_REFPOINT_CQB = function (self, entity, sender)
		AI.SetRefpointToMoveAwayFromGroup(entity.id, 20.0, 15.0);
	end,
	
	---------------------------------------------
	SETUP_SNIPER = function (self, entity, sender)
		entity.actor:SelectItemByName("DSG1");
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, true);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 20);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 15);
	end,

	---------------------------------------------
	SETUP_CQB = function (self, entity, sender)
		entity.actor:SelectItemByName("SOCOM");
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, true);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 90);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 90);
	end,

	---------------------------------------------
	UNDO_SNIPER = function (self, entity, sender)
		entity.actor:SelectItemByName("DSG1");
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 90);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 90);
	end,
	
	---------------------------------------------
	FOUND_CLOSE_CONTANT = function (self, entity, sender)
		entity.AI.sniper = false;
	end,
	
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		
		local dt = _time - entity.AI.lastTargetSeenTime;

		if (AI.GetTargetType(entity.id) ~= AITARGET_NONE) then
			if (AI.GetAttentionTargetDistance(entity.id) < 25.0) then
				if (entity.AI.shiter == true) then
					AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "FOUND_CLOSE_CONTANT",entity.id);
				end
				entity.AI.sniper = false;
			end
		end
		
		if (entity.AI.sniper == true) then
--			if (AI.GetTargetType(entity.id) ~= AITARGET_ENEMY and dt > 10.0) then
--				entity:Readibility("taunt",1,1,0.3,6);
--				entity:SelectPipe(0,"su_sniper_seek");
--				entity.AI.seek = true;
--			else
				entity:Readibility("during_combat",1,1,0.3,6);
				entity:SelectPipe(0,"su_sniper");
				entity.AI.seek = false;
--			end
		else
			if (AI.GetTargetType(entity.id) ~= AITARGET_ENEMY and dt > 4.0) then
				entity:Readibility("taunt",1,1,0.3,6);
				entity:SelectPipe(0,"su_fast_seek");
				entity.AI.seek = true;
			else
				entity:Readibility("during_combat",1,1,0.3,6);
				entity:SelectPipe(0,"su_fast_close_range");
				entity.AI.seek = false;
			end
		end
		
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);

	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		
		if (entity.AI.sniper == true) then
			if (entity.AI.seek == true) then
				entity:SelectPipe(0,"su_sniper");
				entity.AI.seek = false;
			end
		else
			entity:Readibility("during_combat",1,1,0.3,6);
			if (entity.AI.seek == true) then
				entity:SelectPipe(0,"su_fast_close_range");
				entity.AI.seek = false;
			end
		end
		
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity.AI.lastTargetSeenTime = _time;
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		-- Do melee at close range.
--		if(AI.CanMelee(entity.id)) then
--			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );
--			entity:SelectPipe(0,"melee_close");
--		end
	end,
	
	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		if (entity.AI.sniper == true) then
			entity:Readibility("taunt",1,1,0.3,6);
			entity:SelectPipe(0,"su_sniper_seek");
			entity.AI.seek = true;
		else
			entity:Readibility("taunt",1,1,0.3,6);
			entity:SelectPipe(0,"su_fast_seek");
			entity.AI.seek = true;
		end
	
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		entity:Readibility("taunt",1,1,0.3,6);
		entity:SelectPipe(0,"su_fast_seek");
		entity.AI.seek = true;
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
		if (entity.AI.sniper == true) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			if(dt > 4.0) then
				entity:Readibility("taking_fire",1);
				entity.AI.lastBulletReactionTime = _time;
				entity:SelectPipe(0,"su_sniper_move");
			end
		else
			entity:SelectPipe(0,"su_fast_close_range_dodge");
			entity.AI.seek = false;
		end
	end,
	
	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		if (entity.AI.sniper == true) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			if(dt > 4.0) then
				entity:Readibility("taking_fire",1);
				entity.AI.lastBulletReactionTime = _time;
				entity:SelectPipe(0,"su_sniper_move");
			end
		end
	end,

	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
		if (entity.AI.sniper == true) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			if(dt > 4.0) then
				entity:Readibility("taking_fire",1);
				entity.AI.lastBulletReactionTime = _time;
				entity:SelectPipe(0,"su_sniper_move");
			end
		end
	end,

	
}

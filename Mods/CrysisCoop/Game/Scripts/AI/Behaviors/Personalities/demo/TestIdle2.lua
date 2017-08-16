
AIBehaviour.TestIdle2 = {
	Name = "TestIdle2",
--	Base = "Dumb",

	Constructor = function (self, entity)

		entity:MakeAlerted();

		---------------------------------------------
		AI.BeginGoalPipe("test2_move");
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("run",0,1);
			AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
			AI.PushGoal("hide", 1, 17, HM_NEAREST_TOWARDS_REFPOINT, 0, 5);
			AI.PushGoal("branch", 1, "HIDE_OK", IF_CAN_HIDE);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-15,AILASTOPRES_USE,15);
			AI.PushLabel("HIDE_OK");

			AI.PushGoal("branch", 1, "SKIP_UNHIDE", IF_SEES_TARGET, 20.0);
				AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 2);
				AI.PushGoal("branch", 1, "SKIP_SHOOT", NOT+IF_SEES_TARGET, 20.0);
			AI.PushLabel("SKIP_UNHIDE");
				AI.PushGoal("locate",0,"probtarget");
				AI.PushGoal("+adjustaim",0,0,1);
				AI.PushGoal("timeout",1,2,3);
--				AI.PushGoal("clear",0,0,1); -- clear adjustaim
			AI.PushLabel("SKIP_SHOOT");
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test2_seek");
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("run",0,1);
			AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+approach",1,-20,AILASTOPRES_USE,15);
			AI.PushGoal("run",0,0);
			AI.PushGoal("approach",1,2,0,15);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test2_stand");
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,0,1);
			AI.PushGoal("timeout",1,1,2);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test2_bullet_reaction");
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("run", 0, 2);
			AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
			AI.PushGoal("strafe",0,4,2);
--			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("hide", 1, 10, HM_NEAREST_TOWARDS_REFPOINT, 0, 3);
			AI.PushGoal("branch", 1, "SKIP_BACKOFF", IF_CAN_HIDE);
				AI.PushGoal("locate",0,"probtarget");
				AI.PushGoal("+seekcover", 1, COVER_HIDE, 10.0, 3, 1+2); -- 2=towards refpoint
			AI.PushLabel("SKIP_BACKOFF");
			AI.PushGoal("signal",1,1,"HIDE_DONE",0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,0,1);
			AI.PushGoal("timeout",1,0.3,1);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test2_dir");
			AI.PushGoal("locate",0,"enemy");
			AI.PushGoal("acqtarget",0,"");
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
			AI.PushGoal("timeout",1,2);
			AI.PushGoal("bodypos",1,BODYPOS_STAND,1);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 10.0, 3, 1+2); -- 2=towards refpoint
		AI.EndGoalPipe();

		entity.AI.reactionInterval = 1.0;
		entity.AI.lastBulletReactionTime = _time;
		entity.AI.hiding = 0;
		entity.AI.firstContact = 1;

--		local pt = System.GetEntityByName("target");
--		AI.SetRefPointPosition(entity.id, pt:GetPos());
--		entity:SelectPipe(0,"test2_dir");
	end,

	--------------------------------------------------
	OnCoverCompromised = function (self,entity, sender)
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	HIDE_DONE = function(self, entity)
		entity:SelectPipe(0,"test2_move");
		entity.AI.hiding = 0;
	end,

	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self, entity)
		if (entity.AI.hiding == 0 and entity.AI.firstContact == 1) then
			entity:SelectPipe(0,"test2_move");
			entity.AI.firstContact = 0;
		end
	end,
	
	---------------------------------------------
	OnPlayerSeen = function(self, entity, fDistance, data)
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		if (entity.AI.hiding == 0) then
			entity:SelectPipe(0,"test2_move");
		end
		entity.AI.firstContact = 0;
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function(self, entity)
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function(self, entity)
	end,
	
	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
		entity:SelectPipe(0,"test2_stand");
	end,
	
	---------------------------------------------
	OnGroupMemberMutilated = function(self, entity)
	end,
	
	---------------------------------------------
	OnCloseCollision = function(self, entity, data)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > entity.AI.reactionInterval) then
			entity.AI.lastBulletReactionTime = _time;
			entity.AI.hiding = 1;
			entity:SelectPipe(0,"test2_bullet_reaction");
		end
	end,

	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > entity.AI.reactionInterval) then
			entity.AI.lastBulletReactionTime = _time;
			entity.AI.hiding = 1;
			entity:SelectPipe(0,"test2_bullet_reaction");
		end
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
		if (entity.AI.hiding == 0) then
			entity:SelectPipe(0,"test2_seek");
		end
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > entity.AI.reactionInterval) then
			if(AI.Hostile(entity.id, sender.id)) then
				entity.AI.lastBulletReactionTime = _time;
				entity.AI.hiding = 1;
				entity:SelectPipe(0,"test2_bullet_reaction");
			end
		end
	end,

	---------------------------------------------
	OnNearMiss = function(self, entity, sender)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > entity.AI.reactionInterval) then
			if(AI.Hostile(entity.id, sender.id)) then
				entity.AI.lastBulletReactionTime = _time;
				entity.AI.hiding = 1;
				entity:SelectPipe(0,"test2_bullet_reaction");
			end
		end
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > entity.AI.reactionInterval) then
			entity.AI.lastBulletReactionTime = _time;
			entity.AI.hiding = 1;
			entity:SelectPipe(0,"test2_bullet_reaction");
		end
	end,

}

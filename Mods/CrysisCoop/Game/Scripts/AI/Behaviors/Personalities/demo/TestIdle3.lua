
AIBehaviour.TestIdle3 = {
	Name = "TestIdle3",

	Constructor = function (self, entity)

		AI.ChangeMovementAbility(entity.id, AIMOVEABILITY_TELEPORTENABLE, 1);

		entity:MakeAlerted();

		---------------------------------------------
		AI.BeginGoalPipe("test3_move");
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("run", 0, 2);
			AI.PushGoal("locate", 0, "refpoint");
			AI.PushGoal("stick",1,0.5,AILASTOPRES_USE,STICK_SHORTCUTNAV+STICK_BREAK,15.0);
			AI.PushGoal("signal",1,1,"ON_SPOT",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test3_followFast");
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("run", 0, 2);
			AI.PushGoal("locate", 0, "refpoint");
			AI.PushGoal("stick",1,0,AILASTOPRES_USE,STICK_SHORTCUTNAV,15.0);
--			AI.PushGoal("move",1, 0.5, 3.0, AILASTOPRES_USE);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test3_fight");
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("adjustaim",0,0,1);
			AI.PushGoal("timeout", 1,4);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("test3_hide");
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("run", 0, 1);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 10.0, 3, 1);
			AI.PushGoal("signal",1,1,"ON_SPOT",0);
		AI.EndGoalPipe();

		entity:SelectPipe(0,"test3_fight");

		entity.AI.lastBulletReactionTime = _time;

		if (entity.Properties.species > 0) then
			entity.reactionTime = 1.5;
		else
			entity.reactionTime = 4;
		end

	end,

	--------------------------------------------------
	OnFollowFast = function (self, entity)
		entity:SelectPipe(0,"test3_followFast");
	end,

	--------------------------------------------------
	OnMoveToTacPt = function (self, entity)
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"test3_move");
	end,

	--------------------------------------------------
	ON_SPOT = function (self, entity)
		entity:SelectPipe(0,"test3_fight");
	end,

	--------------------------------------------------
	CONTINUE_COMBAT = function (self, entity)
		entity:SelectPipe(0,"test3_move");
	end,

	--------------------------------------------------
	OnCoverCompromised = function (self,entity, sender)
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	OnPlayerSeen = function(self, entity, fDistance, data)
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function(self, entity)
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function(self, entity)
	end,
	
	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,
	
	---------------------------------------------
	OnGroupMemberMutilated = function(self, entity)
	end,
	
	---------------------------------------------
	OnCloseCollision = function(self, entity, data)
	end,

	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
	end,

	---------------------------------------------
	OnNearMiss = function(self, entity, sender)
--		if (entity.Properties.species > 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			if(dt > entity.reactionTime) then
				if(AI.Hostile(entity.id, sender.id)) then
					entity.AI.lastBulletReactionTime = _time;
					entity:SelectPipe(0,"test3_hide");
				end
			end
--		end
	end,
	
	---------------------------------------------
	OnBulletRain = function(self, entity, sender)
--		if (entity.Properties.species > 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			if(dt > entity.reactionTime) then
				if(AI.Hostile(entity.id, sender.id)) then
					entity.AI.lastBulletReactionTime = _time;
					entity:SelectPipe(0,"test3_hide");
				end
			end
--		end
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
--		if (entity.Properties.species > 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			if(dt > entity.reactionTime) then
				if(AI.Hostile(entity.id, sender.id)) then
					entity.AI.lastBulletReactionTime = _time;
					entity:SelectPipe(0,"test3_hide");
				end
			end
--		end
	end,
	
	
	

}

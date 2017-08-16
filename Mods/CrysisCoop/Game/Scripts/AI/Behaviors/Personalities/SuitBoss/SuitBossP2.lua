--------------------------------------------------
-- SuitAttack phase 2 - camping
-- this is modifyed Cover2Attack behavior
-- AI with nano suit
--------------------------
--   created: Kirill Bulatsev 25-10-2006


AIBehaviour.SuitBossP2 = {
	Name = "SuitBossP2",
	Base = "SuitAttack",	
	alertness = 2,

	retreatDist = 10,

	Constructor = function (self, entity)

		AI.SmartObjectEvent( "CallReinforcement", entity.id );

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 0);

		entity.AI.suitPhase = 2;

		entity.AI.changeCoverLastTime = _time;
		entity.AI.changeCoverInterval = random(2,5);
		entity.AI.fleeLastTime = _time;
		entity.AI.lastLiveEnemyTime = _time;
		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastFriendInWayTime = _time - 10;
		
--		-- set armor mode if not cloaked, othervice stay cloaked
--		if(entity.AI.curSuitMode ~= BasicAI.SuitMode.SUIT_CLOAK) then
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );
--		end

--		AIBehaviour.SuitIdle:CheckStealth(entity);		
--		entity.AI.checkStealthTimer = Script.SetTimer(3*1000,AIBehaviour.SuitIdle.CheckStealth,entity);
		self:COVER_NORMALATTACK(entity);
		
	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
		if (entity.AI.checkStealthTimer) then
			Script.KillTimer(entity.AI.checkStealthTimer);
			entity.AI.checkStealthTimer = nil;
		end
	end,
	
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)

		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);

		if(target==AITARGET_ENEMY) then
			entity.AI.lastLiveEnemyTime = _time;
		end
		
		if(target==AITARGET_ENEMY and targetDist < self.retreatDist) then
			-- close quarter combat
	
			-- try to find anchor to advance to
			if (AI.SetRefpointToAnchor(entity.id, 2.0, 55.0, AIAnchorTable.SUIT_SPOT, AIANCHOR_FARTHEST+AIANCHOR_SEES_TARGET+AIANCHOR_BEHIND)) then
					-- If found attack anchor, goto to the anchor.
				entity:SelectPipe(0,"sb_retreat_refpoint");
				do return end;
			elseif	(AI.SetRefpointToAnchor(entity.id, 1.0, 55.0, AIAnchorTable.COMBAT_PROTECT_THIS_POINT, AIANCHOR_NEAREST+AIANCHOR_SEES_TARGET)) then
					-- If found attack anchor, goto to the anchor.
				entity:SelectPipe(0,"sb_retreat_refpoint");
				do return end;
			end
		end
		entity:SelectPipe(0,"sb_backoff");
		do return end;

	end,

	---------------------------------------------
	OnTargetApproaching = function (self, entity, sender, data)

		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);

		if(targetDist < self.retreatDist) then
			-- close quarter combat
			entity:Readibility("during_combat",1,3,0.1,0.4);
			entity:SelectPipe(0,"sb_backoff");
		end
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
	
		local healthPrc=entity:GetHealthPercentage();
		if(healthPrc < AIBehaviour.SuitBossAttack.ToPhase3) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_PHASE_3",entity.id);		
		end
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	
		-- when player aimes at me - go to armor mode
		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );		
	
--		if(AI.GetNavigationType(entity.id) ~= NAV_WAYPOINT_HUMAN) then
		if(entity.AI.lastPlayerLookingTime and (_time - entity.AI.lastPlayerLookingTime) > 6.0) then
			entity:Readibility("during_combat",1,1,0.6,1);
			local r = random(1,20);
			if(r < 5) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_short_shoot");
			elseif(r < 10) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_shoot");
			elseif(r < 15) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_short_shoot");
			else
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_shoot");
			end
			entity.AI.lastPlayerLookingTime = _time;
		end
	end,

	-- ignore bullet rain, near misses, etc - suit propets you
	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
	end,
	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
	end,
	---------------------------------------------


	---------------------------------------------
	SELECT_ADVANCE_POINT = function (self, entity, sender)
		local advancePoint = AI.GetGroupTacticPoint(entity.id, 0, GE_ADVANCE_POS);
		if(advancePoint) then
			AI.SetRefPointPosition(entity.id,advancePoint);
		else
--			if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
				entity:SelectPipe(0,"sn_use_cover_safe");
--			else
--				entity:SelectPipe(0,"sn_close_combat");
--			end
		end
	end,

	--------------------------------------------------
	OnOutOfAmmo = function(self,entity,sender)
--		entity:SelectPipe(0,"do_nothing");
--		entity:Readibility("reloading",1,0.1,0.4);
		entity:Reload();
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"fire_pause");		
	end,

	-- no searching
	--------------------------------------------------
	OnNoTargetVisible = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnNoHidingPlace	= function(self,entity,sender)
	end,

	--------------------------------------------------
	--------------------------------------------------	
	--------------------------------------------------	
	--------------------------------------------------
	--------------------------------------------------	
}

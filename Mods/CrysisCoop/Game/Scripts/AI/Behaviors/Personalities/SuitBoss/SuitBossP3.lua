--------------------------------------------------
-- SuitAttack phase 3 - offensive
-- this is modifyed Cover2Attack behavior
-- AI with nano suit
--------------------------
--   created: Kirill Bulatsev 25-10-2006


AIBehaviour.SuitBossP3 = {
	Name = "SuitBossP3",
	Base = "SuitAttack",	
	alertness = 2,


	Constructor = function (self, entity)

		AI.SmartObjectEvent( "CallReinforcement", entity.id );

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);

  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 0);

		self:COVER_NORMALATTACK(entity);

--entity:SelectPipe(0,"stealth_advance");

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
		entity.AI.checkStealthTimer = Script.SetTimerForFunction(3*1000,"AIBehaviour.SuitIdle.CheckStealth",entity);
		
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

		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );			
		entity:SelectPipe(0,"sb_melee_far");
		do return end

	

		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
--		local range = entity.Properties.combatDistance/2;
--		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
--			range = range / 2;
--		end

		if(target==AITARGET_ENEMY) then
			entity.AI.lastLiveEnemyTime = _time;
		end
		
		local range	= 15
		
		if(target==AITARGET_ENEMY and targetDist < range) then
			-- close quarter combat
			entity:Readibility("during_combat",1,3,0.1,0.4);
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );			
			entity:SelectPipe(0,"sb_melee_far");
		else
		
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );			
		
			local state = AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
			local needAdvance = AI.GetGroupTacticState(entity.id, 0, GE_ADVANCE_POS);
			local dt = _time - entity.AI.changeCoverLastTime;
			local dtLive = _time - entity.AI.lastLiveEnemyTime;
			
			if(dt > entity.AI.changeCoverInterval and needAdvance) then -- and state == GS_ADVANCE) then
				-- Advance to new point
				entity:Readibility("suppressing_fire",1,3,0.1,0.4);
				entity:SelectPipe(0,"sn_advance_to_target");
				entity.AI.changeCoverLastTime = _time;
				entity.AI.changeCoverInterval = random(3,5); --random(7,11);
			elseif(state == GS_SEEK) then
				-- Goto seek
				AI.RecComment(entity.id, "COVER_NORMALATTACK/GS_SEEK");
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
			else
				-- take cover
				entity:Readibility("taunt",1,3,0.1,0.4);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"sn_use_cover");
			end
		end
	end,
	
	---------------------------------------------
	SUIT_POWER = function (self, entity, sender, data)
		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );
	end,
	
	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
	
		--AI.Signal(SIGNALFILTER_SENDER, 1, "TO_PHASE_3",entity.id);
		do return end
	
	
--		entity:Readibility("taking_fire",1);
--		entity:SelectPipe(0,"do_nothing");
--		entity:SelectPipe(0,"sn_bullet_reaction");
		-- avoid this poit for some time.
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 2);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 15);
		end
		-- Allow to change cover quickly.
		entity.AI.changeCoverInterval = 0;

		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );
		
		AIBehaviour.SuitIdle:CheckHide(entity);		
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
	OnCloseContact = function(self,entity,sender)
--		entity:SelectPipe(0,"do_nothing");
--		entity:Readibility("reloading",1,0.1,0.4);
--		entity:Reload();
	end,

	--------------------------------------------------
	OnOutOfAmmo = function(self,entity,sender)
--		entity:SelectPipe(0,"do_nothing");
--		entity:Readibility("reloading",1,0.1,0.4);
		entity:Reload();
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"fire_pause");		
	end,

	--------------------------------------------------
	--------------------------------------------------	
	--------------------------------------------------	
	--------------------------------------------------
	--------------------------------------------------	
}

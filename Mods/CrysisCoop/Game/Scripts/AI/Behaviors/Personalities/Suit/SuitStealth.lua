--------------------------------------------------
-- SuitStealth
-- AI with nano-suit in stealth mode
--------------------------
--   created: Kirill Bulatsev 31-10-2006


AIBehaviour.SuitStealth = {
	Name = "SuitStealth",
	Base = "Cover2Attack",	
	alertness = 2,

	Constructor = function (self, entity)

--		AI.SmartObjectEvent( "CallReinforcement", entity.id );

		entity:MakeAlerted();
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);

		local range = entity.Properties.preferredCombatDistance;
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
			radius = 2.5;
		end
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, range/2);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, range/2);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, -radius);

--		AI.RecComment(entity.id, "dist="..targetDist.." range="..range.." target="..target);

		if(target==AITARGET_ENEMY and targetDist < range) then
			-- close quarter combat
			entity:SelectPipe(0,"sn_close_combat");

--			AI.RecComment(entity.id, "dist="..targetDist.." range="..range.." target="..target);

--			if(target==AITARGET_ENEMY and AI.IsAgentInTargetFOV(entity.id, 60.0) == 0) then
--				entity:Readibility("taunt",1,3,0.1,0.4);
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_attack_taunt");
--			end

		else
			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"sn_fast_advance_to_target");			
			entity:SelectPipe(0,"stealth_advance");
--			entity:SelectPipe(0,"sn_use_cover");
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_short_cover_fire");
		end

		entity.AI.changeCoverLastTime = _time;
		entity.AI.changeCoverInterval = random(7,11);
		entity.AI.fleeLastTime = _time;
		entity.AI.lastLiveEnemyTime = _time;
		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastFriendInWayTime = _time - 10;
		
		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_CLOAK );
		
	end,
	
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
	
--		AIBehaviour.SuitIdle:CheckStealth(entity, true);
	
		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
		local range = entity.Properties.preferredCombatDistance/2;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
		end

		if(target==AITARGET_ENEMY) then
			entity.AI.lastLiveEnemyTime = _time;
		end
		
		if(target==AITARGET_ENEMY and targetDist < range) then
			-- close quarter combat
			entity:Readibility("during_combat",1,3,0.1,0.4);
			entity:SelectPipe(0,"sn_close_combat");
		else
		
			entity:SelectPipe(0,"stealth_advance");		
			do return end
		
			local state = AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
			local needAdvance = AI.GetGroupTacticState(entity.id, 0, GE_ADVANCE_POS);
			local dt = _time - entity.AI.changeCoverLastTime;
			local dtLive = _time - entity.AI.lastLiveEnemyTime;
			
			if(dt > entity.AI.changeCoverInterval and needAdvance) then -- and state == GS_ADVANCE) then
				-- Advance to new point
				entity:Readibility("suppressing_fire",1,3,0.1,0.4);
				entity:SelectPipe(0,"sn_advance_to_target");
				entity.AI.changeCoverLastTime = _time;
				entity.AI.changeCoverInterval = random(7,11);
			elseif(dtLive > 3.0) then
				-- try to goto nearest guy who has target.
				local nearestBuddy = AI.GetNearestInGroupWithTarget(entity.id);

			AI.SetRefPointPosition(entity.id,advancePoint);

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
	OnEnemyDamage = function (self, entity, sender, data)
----		entity:Readibility("taking_fire",1);
----		entity:SelectPipe(0,"do_nothing");
----		entity:SelectPipe(0,"sn_bullet_reaction");
--		-- avoid this poit for some time.
--		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
--			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 2);
--		else
--			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 15);
--		end
--		-- Allow to change cover quickly.
--		entity.AI.changeCoverInterval = 0;
--
--		AI.Signal(SIGNALFILTER_SENDER,1,"NANOSUIT_ARMOR",entity.id);
--		-- suit guy hides only if health is low
--		if(entity:GetHealthPercentage()<50) then
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HIDE",entity.id);
--		end
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	
		-- when player aimes at me - go to normal attack mode
--		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );				
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	
----		if(AI.GetNavigationType(entity.id) ~= NAV_WAYPOINT_HUMAN) then
--		if(entity.AI.lastPlayerLookingTime and (_time - entity.AI.lastPlayerLookingTime) > 6.0) then
--			entity:Readibility("during_combat",1,1,0.6,1);
--			local r = random(1,20);
--			if(r < 5) then
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_short_shoot");
--			elseif(r < 10) then
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_shoot");
--			elseif(r < 15) then
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_short_shoot");
--			else
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_shoot");
--			end
--			entity.AI.lastPlayerLookingTime = _time;
--		end
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
----System.Log(">>>> default OnOutOfAmmo " );
--	-- player would not have Reload implemented
		if(entity.Reload == nil)then
--	--	System.Log(">>>> no reload available for "..entity:GetName() );
			do return end
		end
		entity:Reload();
	end,
	--------------------------------------------------	
}

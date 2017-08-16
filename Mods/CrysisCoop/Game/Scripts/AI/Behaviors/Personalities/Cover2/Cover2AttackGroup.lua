--------------------------------------------------
-- SneakerAttack
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.Cover2AttackGroup = {
	Name = "Cover2AttackGroup",
	alertness = 2,

	Constructor = function (self, entity)

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);

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
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_REF_POINT, 0);

--		if(targetDist < range) then

		entity.AI.lastBulletReactionTime = _time - 10;

		if (entity.AI.pendingAdvance and entity.AI.pendingAdvance == true) then
			entity.AI.pendingAdvance = nil;
			entity.AI.pendingSeek = nil;
			entity.AI.pendingSearch = nil;
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
			
			AI.SetRefPointPosition(entity.id, entity.AI.pendingAdvancePos);
			
			if (entity.AI.pendingAdvanceType == 1) then
				entity:SelectPipe(0,"sn_advance_group_PROTO");
			else
				entity:SelectPipe(0,"sn_advance_group_direct_PROTO");
			end
		else
			if(entity.AI.firstContact == true) then
	--			entity:SelectPipe(0,"sn_bullet_reaction_group");
				entity:SelectPipe(0,"sn_first_contact_attack");
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
			else
				-- close quarter combat
				entity:SelectPipe(0,"sn_close_combat_group");
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
				
				if(target==AITARGET_ENEMY and AI.IsAgentInTargetFOV(entity.id, 60.0) == 0) then
					entity:Readibility("taunt",1,3,0.1,0.4);
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_attack_taunt");
				end
			end
		end

		entity.AI.firstContact = false;

		entity.AI.changeCoverLastTime = _time;
		entity.AI.changeCoverInterval = random(7,11);
		entity.AI.lastLiveEnemyTime = _time;
		entity.AI.lastFriendInWayTime = _time - 10;
		entity.AI.lastGroupReadabilityTime = _time - 10;
	end,
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
	
		if (entity.AI.pendingAdvance and entity.AI.pendingAdvance == true) then
			entity.AI.pendingAdvance = nil;
			entity.AI.pendingSeek = nil;
			entity.AI.pendingSearch = nil;
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
			
			AI.SetRefPointPosition(entity.id, entity.AI.pendingAdvancePos);
			
			if (entity.AI.pendingAdvanceType == 1) then
				entity:SelectPipe(0,"sn_advance_group_PROTO");
			else
				entity:SelectPipe(0,"sn_advance_group_direct_PROTO");
			end
		else

			local target = AI.GetTargetType(entity.id);
			local targetDist = AI.GetAttentionTargetDistance(entity.id);
			local range = entity.Properties.preferredCombatDistance/2;
			if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
				range = range / 2;
			end
	
			if(target==AITARGET_ENEMY) then
				entity.AI.lastLiveEnemyTime = _time;
			end
		
			local dtLive = _time - entity.AI.lastLiveEnemyTime;
	
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
			entity:SelectPipe(0,"sn_close_combat_group");
	
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
	
			if (AI_Utils:CanThrowGrenade(entity) == 1) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_throw_grenade");
			end
		end

--		if(dtLive > 5.0) then
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
--			AI.SetRefPointPosition(entity.id, data.point);
--			entity:SelectPipe(0,"sn_advance_group");
--		else
--			entity:SelectPipe(0,"sn_close_combat_group");
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
--		end
		
--		if(target==AITARGET_ENEMY and targetDist < range) then
--			-- close quarter combat
--			entity:Readibility("during_combat",1,3,0.1,0.4);
--			entity:SelectPipe(0,"sn_close_combat_group");
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
--		else
--			-- take cover
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
--			entity:Readibility("taunt",1,3,0.1,0.4);
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"sn_use_cover_group");
--		end
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
--		AI.RecComment(entity.id, "OnNoTargetVisible");
		if (AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) < 2) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,

	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		if (AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) < 2) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,

	---------------------------------------------
	NOTIFY_ADVANCING = function (self, entity, sender)
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
	end,
	---------------------------------------------
	NOTIFY_COVERING = function (self, entity, sender)
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_COVERING);
	end,
	---------------------------------------------
	COMBAT_READABILITY = function (self, entity, sender)
		if(random(1,10) < 5) then
			entity:Readibility("during_combat",1,3,0.1,0.4);
		end
	end,
	---------------------------------------------
	ADVANCE_DONE_READABILITY = function (self, entity, sender)
	end,
	---------------------------------------------
	SELECT_ADVANCE_POINT = function (self, entity, sender)
		local advancePoint = AI.GetGroupTacticPoint(entity.id, 0, GE_ADVANCE_POS);
		if(advancePoint) then
			AI.SetRefPointPosition(entity.id,advancePoint);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
			entity:SelectPipe(0,"sn_use_cover_safe");
		end
	end,
	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
--		--AI.LogEvent(entity:GetName().." OnTargetApproaching");
--		local range = entity.Properties.preferredCombatDistance/2;
--		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
--			range = range / 2;
--		end
--		if(AI.GetAttentionTargetDistance(entity.id) < range) then
--			entity:Readibility("during_combat",1);
--			entity:SelectPipe(0,"sn_close_combat_group");
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
--		end
	end,
	---------------------------------------------
	OnTargetFleeing	= function (self, entity)
	end,
	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
--		entity:Readibility("during_combat",1,1,0.6,1);
--		entity:SelectPipe(0,"cv_short_cover_fire_signal");
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);

		if(not entity.AI.lastCompromisedCover) then
			entity.AI.lastCompromisedCover = _time - 10;
		end
		
		local dt = _time - entity.AI.lastCompromisedCover;
		
		if(dt > 5.0) then
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
--			entity:SelectPipe(0,"sn_force_cover_compromised");
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
			entity:SelectPipe(0,"sn_close_combat_group");
		end

	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if (data.iValue == AITSR_SEE_STUNT_ACTION) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			AI_Utils:ChooseStuntReaction(entity);
		elseif (data.iValue == AITSR_SEE_CLOAKED) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			entity:SelectPipe(0,"sn_target_cloak_reaction");
		else
			entity:Readibility("during_combat",1,1,0.3,6);
		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity.AI.lastLiveEnemyTime = _time;
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function(self, entity)
		-- called when a member of the group dies
--		entity:SelectPipe(0,"sn_use_cover_safe");
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);

		entity:SelectPipe(0,"sn_near_bullet_reaction_slow");
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);

	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function (self, entity, sender, data)
		entity:Readibility("ai_down",1,1,0.3,0.6);
--		entity:SelectPipe(0,"sn_use_cover_safe");

		entity:SelectPipe(0,"sn_near_bullet_reaction_slow");
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
		
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "OnGroupMemberDied",entity.id, data);
	end,
	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		-- only react to hostile bullets.
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > 1.5) then
			if(AI.Hostile(entity.id, sender.id)) then -- and distToHit < 4.0) then
--				entity:SelectPipe(0,"sn_bullet_reaction_group");
				entity:Readibility("bulletrain",1,0.1,0.4);
				entity.AI.lastBulletReactionTime = _time;
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"sn_near_bullet_reaction_slow");
--				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			end
		end
	end,
	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
--		-- only react to hostile bullets.
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > 1.5) then
			if(AI.Hostile(entity.id, sender.id)) then -- and distToHit < 4.0) then
--				entity:SelectPipe(0,"sn_bullet_reaction_group");
				entity:Readibility("bulletrain",1,0.1,0.4);
				entity.AI.lastBulletReactionTime = _time;
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"sn_near_bullet_reaction_slow");
--				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			end
		end
	end,
	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		entity:Readibility("taking_fire",1);
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > 1.5) then
--			entity:SelectPipe(0,"sn_bullet_reaction_group");
			entity:SelectPipe(0,"sn_near_bullet_reaction");
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
			entity.AI.lastBulletReactionTime = _time;
		end
		-- avoid this poit for some time.
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 2);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 15);
		end
		-- Allow to change cover quickly.
		entity.AI.changeCoverInterval = 0;
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	------------------------------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	end,
	------------------------------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self,entity,sender)
	end,
	---------------------------------------------
	OnBadHideSpot = function ( self, entity, sender,data)
--		Log(entity:GetName().." OnBadHideSpot");
--		entity:SelectPipe(0,"sn_close_combat_group");
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
--		Log(entity:GetName().." OnNoHidingPlace");
--		entity:SelectPipe(0,"sn_close_combat_group");
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
	end,	
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
--		Log(entity:GetName().." OnNoPathFound");
		entity:SelectPipe(0,"sn_close_combat_group");
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_WEAK_COVERING);
	end,	
	--------------------------------------------------
--	OnOutOfAmmo = function (self,entity, sender)
--		-- Try to choose secondary weapon first.
--		if(entity:CheckCurWeapon(1) == 0 and entity:HasSecondaryWeapon() == 1) then
--			entity:SelectPipe(0,"sn_change_secondary_weapon_pause");
--			return;
--		end
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_RELOAD",entity.id);
--	end,

	--------------------------------------------------
	OnFriendInWay = function(self, entity)
--		if(entity.AI.lastFriendInWayTime and (_time - entity.AI.lastFriendInWayTime) > 6.0) then
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
--			entity.AI.lastFriendInWayTime = _time;
--		end
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
--		if(AI.GetNavigationType(entity.id) ~= NAV_WAYPOINT_HUMAN) then
--		if(entity.AI.lastPlayerLookingTime and (_time - entity.AI.lastPlayerLookingTime) > 10.0) then
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
	OnCloseContact = function ( self, entity, sender,data)
		-- Do melee at close range.
--		if(AI.CanMelee(entity.id)) then
--			entity:SelectPipe(0,"melee_close");
--		end
	end,

}

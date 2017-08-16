--------------------------------------------------
-- SneakerAttack
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.Cover2Attack = {
	Name = "Cover2Attack",
	alertness = 2,

	Constructor = function (self, entity)

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
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
 -- 	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, range/2);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, -radius);

		--self:COVER_NORMALATTACK(entity);
		-- Call the derived behavior attack logic
		AI.Signal(SIGNALFILTER_SENDER,1,"COVER_NORMALATTACK",entity.id);

		if(target==AITARGET_ENEMY and targetDist < range) then
			if(target==AITARGET_ENEMY and AI.IsAgentInTargetFOV(entity.id, 60.0) == 0) then
				entity:Readibility("taunt",1,3,0.1,0.4);
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_attack_taunt");
			end
		end

		entity.AI.lastAdvanceTime = _time;
		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.firstContact = false;

	end,
	---------------------------------------------
	Destructor = function (self, entity)
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
	end,
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		local target = AI.GetTargetType(entity.id);
		local state = GS_ADVANCE;

		if (target ~= AITARGET_ENEMY) then
			state = AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
		end
		
		local throwingGrenade = 0;
		
		if (state == GS_SEEK) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		elseif (state == GS_SEARCH or state == GS_ALERTED or state == GS_IDLE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
		else
		
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);

			local tacPoint = AI.GetGroupTacticPoint(entity.id, 0, GE_DEFEND_POS);
			if (not tacPoint) then
				AI.Warning(" Entity "..entity:GetName().." returned invalid group defend pos.");
				AI.SetRefPointPosition(entity.id,entity:GetPos());
				entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cm_defend");
				entity.AI.lastAdvanceTime = _time;
			else
				if (AI.GetGroupTacticState(entity.id, 0, GE_MOST_LOST_UNIT) == 1) then
					entity:Readibility("cover_me",1,3,0.1,0.4);
					entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_cohesion");
				else
					local signal = AI.GetGroupTacticState(entity.id, 0, GE_MOVEMENT_SIGNAL);
					if (signal ~= 0) then
						if (signal == -1) then
							entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_signal_advance_left");
						else
							entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_signal_advance_right");
						end
					else
						entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_advance");
						entity.AI.lastAdvanceTime = _time;
					end
				end
			end

			if (AI_Utils:CanThrowGrenade(entity) == 1) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_throw_grenade");
				throwingGrenade = 1;
			end
		end

		if(throwingGrenade == 0 and target ~= AITARGET_ENEMY and entity:CheckCurWeapon() == 1) then
			entity:SelectPrimaryWeapon();
		end
		
	end,
	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
	end,
	---------------------------------------------
	COMBAT_READABILITY = function (self, entity, sender)
		if(random(1,10) < 5) then
			entity:Readibility("during_combat",1,3,0.1,0.4);
		end
	end,
	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
	end,
	---------------------------------------------
	OnTargetFleeing	= function (self, entity)
	end,
	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:Readibility("during_combat",1,1,0.3,6);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		
		if (data.iValue == AITSR_SEE_STUNT_ACTION) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			AI_Utils:ChooseStuntReaction(entity);
		elseif (data.iValue == AITSR_SEE_CLOAKED) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			entity:SelectPipe(0,"sn_target_cloak_reaction");
		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	---------------------------------------------
	OnGroupMemberDied = function(self, entity)
		entity.AI.lastBulletReactionTime = _time;
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"cv_bullet_reaction");
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function (self, entity, sender, data)
		entity:Readibility("ai_down",1,1,0.3,0.6);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "OnGroupMemberDied",entity.id, data);

		entity.AI.lastBulletReactionTime = _time;
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"cv_bullet_reaction");
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
--		local dta = _time - entity.AI.lastAdvanceTime;
--		if (dta > 3.0) then
--		if (AI.IsMoving(entity.id,2) == 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			local reactionTime = 0.5;
			if (AI.IsMoving(entity.id,1) == 1) then
				reactionTime = 1.5;
			end
			if(dt > reactionTime) then
				entity.AI.lastBulletReactionTime = _time;
				entity:Readibility("bulletrain",1,2, 0,0.2);
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"cv_bullet_reaction");
			end
--		end
		AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS);
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
--		local dta = _time - entity.AI.lastAdvanceTime;
--		if (dta > 3.0) then
--		if (AI.IsMoving(entity.id,2) == 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			local reactionTime = 0.5;
			if (AI.IsMoving(entity.id,1) == 1) then
				reactionTime = 1.5;
			end
			if(dt > reactionTime) then
				entity:Readibility("taking_fire",1,2);
				entity.AI.lastBulletReactionTime = _time;
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"cv_bullet_reaction");
			end
--		end
		AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS);
	end,

	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	end,
	------------------------------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self,entity,sender)
	end,
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
--		Log(entity:GetName().." OnNoPathFound");
--		entity:SelectPipe(0,"sn_close_combat");
	end,	
	--------------------------------------------------
	OnFriendInWay = function(self, entity)
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		-- Do melee at close range.
		if(AI.CanMelee(entity.id)) then
			entity:Readibility("during_combat",1,3,0.1,0.4);
			entity:SelectPipe(0,"melee_close");
		end
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		entity:Readibility("reload",1,4,0.1,0.4);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
		if (targetDist) then
			if(targetDist < 20 and entity:CheckCurWeapon(1) == 0 and entity:HasSecondaryWeapon() == 1) then
				entity:SelectSecondaryWeapon();
				return;
			end
		end
		entity:Reload();
	end,
	--------------------------------------------------
	OnGroupChanged = function (self, entity)
	end,

}

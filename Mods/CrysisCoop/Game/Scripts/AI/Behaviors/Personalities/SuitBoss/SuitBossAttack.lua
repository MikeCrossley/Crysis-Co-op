--------------------------------------------------
-- SuitAttack
-- this is modifyed Cover2Attack behavior
-- AI with nano suit
--------------------------
--   created: Kirill Bulatsev 25-10-2006


AIBehaviour.SuitBossAttack = {
	Name = "SuitBossAttack",
	Base = "SuitAttack",	
	alertness = 2,

	-- health thresholds (% of health left) to switch phases
									-- phase 1 - static turret
	ToPhase1b = 75,	-- phase 1b - pressing
	ToPhase2 = 50,	-- phase 2 - fleeing 
	ToPhase3 = 25,	-- phase 3 - berserk

	Constructor = function (self, entity)

		AI.SmartObjectEvent( "CallReinforcement", entity.id );

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
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
		if(entity.AI.curSuitMode == BasicAI.SuitMode.SUIT_CLOAK) then
			range = range / 4;
		end	
		
		self:COVER_NORMALATTACK(entity);
		
--entity:SelectPipe(0,"stealth_advance");

		entity.AI.lastLiveMeleeTime = 0;
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
	
		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );
	
		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
		local range = entity.Properties.combatDistance/2;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
		end

		if(target==AITARGET_ENEMY) then
			entity.AI.lastLiveEnemyTime = _time;
		end

		-- close range - do melee or close range attack
		if(target==AITARGET_ENEMY and targetDist < range) then
			-- close quarter combat
			entity:Readibility("during_combat",1,3,0.1,0.4);
			
			if(_time - entity.AI.lastLiveMeleeTime > 7) then
				entity.AI.lastLiveMeleeTime = _time;
				entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );			
				entity:SelectPipe(0,"melee_far");
			else	
				entity:SelectPipe(0,"sb_close_combat");
			end
			do return end;
		end
	
		-- far enough - find anchor to advance to
		local anchorName = AI.GetAnchor(entity.id,AIAnchorTable.SUIT_SPOT,1000,AIANCHOR_RANDOM_IN_RANGE);
		if( anchorName ) then
			local anchor = System.GetEntityByName( anchorName );
			if( anchor ) then
				-- If found attack anchor, goto to the anchor.				
				AI.SetRefPointPosition( entity.id, anchor:GetPos() );
				AI.SetRefPointDirection( entity.id, anchor:GetDirectionVector() );
				entity:SelectPipe(0,"sb_advance_anchor");
				do return end;
			end
		end
			
		-- no anchor - use hide-spots
		entity:Readibility("suppressing_fire",1,3,0.1,0.4);
		entity:SelectPipe(0,"sb_advance");
		
		do return end;
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
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
		if(entity.AI.curSuitMode == BasicAI.SuitMode.SUIT_POWER) then
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );		
		end	
	
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


	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		-- Do melee at close range.
		if(AI.CanMelee(entity.id)) then
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );
			entity:SelectPipe(0,"melee_close");
		end
	end,

	---------------------------------------------
	SELECT_ADVANCE_POINT = function (self, entity, sender)
		local advancePoint = AI.GetGroupTacticPoint(entity.id, 0, GE_ADVANCE_POS);
		if(advancePoint) then
			AI.SetRefPointPosition(entity.id,advancePoint);
		else
--			if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
				entity:SelectPipe(0,"sb_advance");
--			else
--				entity:SelectPipe(0,"sn_close_combat");
--			end
		end
	end,

	--------------------------------------------------
	--------------------------------------------------	
--	OnOutOfAmmo = function (self,entity, sender)
----System.Log(">>>> default OnOutOfAmmo " );
--	-- player would not have Reload implemented
--		if(entity.Reload == nil)then
--	--	System.Log(">>>> no reload available for "..entity:GetName() );
--			do return end
--		end
--		entity:Reload();
--	end,
	--------------------------------------------------	
	
}

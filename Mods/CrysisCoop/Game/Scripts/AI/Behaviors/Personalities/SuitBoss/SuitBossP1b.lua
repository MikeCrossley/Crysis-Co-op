--------------------------------------------------
-- SuitAttack phase 1 moving
-- this is modifyed Cover2Attack behavior
-- AI with nano suit
--------------------------
--   created: Kirill Bulatsev 25-10-2006


AIBehaviour.SuitBossP1b = {
	Name = "SuitBossP1b",
	Base = "SuitAttack",	
	alertness = 2,

	Constructor = function (self, entity)

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);

--		local range = entity.Properties.combatDistance;
--		local radius = 4.0;
--		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
--			range = range / 2;
--			radius = 2.5;
--		end
--		
--  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, range/2);
--  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, range/2);
--  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);
--  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, -radius);
--
----		AI.RecComment(entity.id, "dist="..targetDist.." range="..range.." target="..target);
--		if(entity.AI.curSuitMode == BasicAI.SuitMode.SUIT_CLOAK) then
--			range = range / 4;
--		end	
		
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 35);		
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

		entity:SelectPipe(0,"sb_press");
		do return end;
	
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
	
		local healthPrc=entity:GetHealthPercentage();
		if(healthPrc < AIBehaviour.SuitBossAttack.ToPhase2) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_PHASE_2",entity.id);		
		end
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	
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
	OnPlayerSeen = function(self,entity,sender)
		self:COVER_NORMALATTACK(entity);
	end,

	--------------------------------------------------
	OnNoTarget = function(self,entity,sender)
		if (AI.SetRefpointToAnchor(entity.id, 1.0, 25.0, AIAnchorTable.COMBAT_PROTECT_THIS_POINT, AIANCHOR_NEAREST+AIANCHOR_SEES_TARGET)) then		
			-- If found attack anchor, goto to the anchor.				
			entity:SelectPipe(0,"sb_static_move");
			do return end;
		end
	end,

	--------------------------------------------------
	OnNoTargetVisible = function(self,entity,sender)

		entity:SelectPipe(0,"sb_advance");
		do return end
		
	end,

	--------------------------------------------------
	OnEnemyMemory = function(self,entity,sender)

		self:COVER_NORMALATTACK(entity);
--		self:OnNoTargetVisible(entity);
	end,

	--------------------------------------------------
	OnOutOfAmmo = function(self,entity,sender)
--		entity:SelectPipe(0,"do_nothing");
--		entity:Readibility("reloading",1,0.1,0.4);
		entity:Reload();
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"fire_pause");		
	end,


	---------------------------------------------
	--------------------------------------------------
	--------------------------------------------------	
	
}

--------------------------------------------------
--    Created By: Luciano
--   Description: 	Cover goes hiding under fire
--------------------------
--

AIBehaviour.CamperHide = {
	Name = "CamperHide",
--	Base = "CamperAttack",
	alertness = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
		entity:GettingAlerted();
		
--		entity.AI.changeCoverLastTime = _time;
--		entity.AI.changeCoverInterval = random(7,11);
--		entity.AI.fleeLastTime = _time;
--		entity.AI.lastLiveEnemyTime = _time;
--		entity.AI.lastBulletReactionTime = _time - 10;
--		entity.AI.lastFriendInWayTime = _time - 10;

		entity.AI.coverCompromized = false;	
		entity.AI.lastHideTime = _time - 100;
		
		self:HandleThreat(entity,true);
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	-----------------------------------------------------
	HandleThreat = function(self, entity, resetTimer)

		local target = AI.GetTargetType(entity.id);

		local dt = _time - entity.AI.lastHideTime;
		local dist = AI.GetAttentionTargetDistance(entity.id);

		if(dt < 5.0) then
			return;
		end

		entity:SelectPipe(0,"do_nothing");

		-- keep on hiding no matter what, and after the timer has fired, try to come out of cover.
		local target = AI.GetTargetType(entity.id);
		if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
			-- Hide from attention target
			entity:SelectPipe(0,"sn_keep_hiding");
		else
			-- Hide from beacon
			entity:SelectPipe(0,"sn_keep_hiding_beacon");
		end

	end,

	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
		self:HandleThreat(entity,false);
	end,

	-----------------------------------------------------
	HIDE_DONE = function(self, entity)
		--AI.LogEvent(entity:GetName().." OnUnhideTimer");
		local target = AI.GetTargetType(entity.id);
		if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
			if(AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) > 0) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK_GROUP",entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
			end
		else
			if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
				entity.AI.hurryInStandby = 1;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
			end
		end
	end,

	--------------------------------------------------
	OnNoHidingPlace = function(self, entity, sender,data)
		local target = AI.GetTargetType(entity.id);

		if(target~=AITARGET_NONE) then 
			-- If the grunt has target and the is far away enough, try proning.
			-- in worst case, just shoot!
			if(AI.GetAttentionTargetDistance(entity.id) > 30.0) then
				entity:SelectPipe(0,"cv_short_prone_hide");
			else
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE, "cv_short_cover_fire");
			end
			entity:Readibility("during_combat_group",1);
		else
			-- If not target known assume the prone is the best choice.
			entity:SelectPipe(0,"cv_short_prone_hide");
		end
	end,

	--------------------------------------------------
	END_PRONE_HIDE = function(self,entity,sender)
		self:HandleThreat(entity,false);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
		self:HandleThreat(entity,false);
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		self:HandleThreat(entity,false);

		if(AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) > 0) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK_GROUP",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		end
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
--		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)

		entity.AI.coverCompromized = true;

		-- called when the enemy is damaged
		self:HandleThreat(entity,true);
		
		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		end
		
		entity:Readibility("taking_fire",1);
		
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,

	--------------------------------------------------
	END_HIDE = function(self,entity,sender)
	end,

	--------------------------------------------------
	HEADS_UP_GUYS = function(self,entity,sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
}

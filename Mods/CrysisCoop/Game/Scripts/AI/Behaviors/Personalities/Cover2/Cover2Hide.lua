--------------------------------------------------
--    Created By: Luciano
--   Description: 	Cover goes hiding under fire
--------------------------
--

AIBehaviour.Cover2Hide = {
	Name = "Cover2Hide",
--	Base = "Cover2Attack",
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

		entity.AI.lastBulletReactionTime = _time - 10;
		
		entity:Readibility("taking_fire",1,1, 0.1,0.4);
		self:HandleThreat(entity);
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	-----------------------------------------------------
	HandleThreat = function(self, entity, sender)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > 0.5) then
			if(not sender or AI.Hostile(entity.id, sender.id)) then
				entity.AI.lastBulletReactionTime = _time;
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"cv_hide_unknown");
			end
		end
		
	end,

	-----------------------------------------------------
	COVER_NORMALATTACK = function(self, entity)
		-- Choose proper action after being interrupted.
		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
--		self:HandleThreat(entity);
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		
		AI_Utils:CommonEnemySeen(entity, data);
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
--		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------		
	OnSommethingSeen = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)

		entity.AI.coverCompromized = true;

		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		end

		-- called when the enemy is damaged
		self:HandleThreat(entity, shooter);
		
		entity:Readibility("taking_fire",1,1, 0.1,0.4);
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		entity:Readibility("bulletrain",1,1, 0.1,0.4);
		self:HandleThreat(entity, sender);

		local shooter = System.GetEntity(sender.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		end
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
}

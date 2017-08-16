--------------------------------------------------
-- Cover2ThreatenedStandby
-- Trheatened behavrio when approaching the target is not permitted.
--------------------------
--   created: Mikko Mononen 13-9-2006

AIBehaviour.Cover2ThreatenedStandby = {
	Name = "Cover2ThreatenedStandby",
	alertness = 1,

	---------------------------------------------
	Constructor = function (self, entity)

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);

		-- store original position.
		if(not entity.AI.idlePos) then
			entity.AI.idlePos = {x=0, y=0, z=0};
			CopyVector(entity.AI.idlePos, entity:GetPos());
		end

		entity:MakeAlerted();

		local range = entity.Properties.preferredCombatDistance/2;
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
			radius = 2.5;
		end
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);

--		entity.AI.first = true;
		entity.AI.LastStandbyTime = _time - 100;
		entity.AI.firstContact = true;
		entity.AI.firstCheck = 1;

		self:ChooseStandbyPos(entity);
	end,

	---------------------------------------------
	Destructor = function (self, entity)
	end,

	---------------------------------------------
	ChooseStandbyPos = function(self, entity)

		local target = AI.GetTargetType(entity.id);

--		if(not entity.AI.StandbyValid) then
--			entity:SelectPipe(0,"cv_look_standby");
--			if(target == AITARGET_NONE) then
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_acquire_beacon");
--			end
--			AI.RecComment(entity.id, "return1");
--			return
--		end

		if (AI_Utils:IsTargetOutsideStandbyRange(entity) == 0) then
			AI_Utils:CheckThreatened(entity, 15.0);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ALERTED);
			entity:SelectPipe(0,"sn_look_closer_standby");
		end


--		if(entity.AI.firstCheck == 1 or AI_Utils:IsTargetOutsideStandbyRange(entity) == 0) then
--			entity:SelectPipe(0,"sn_look_closer_standby");
--			entity.AI.firstCheck = 0;
--			return;
--		end
--
--		entity.AI.firstCheck = 0;
--
--		local	pos = g_Vectors.temp_v1;
--		if(target == AITARGET_NONE) then
--			if(not AI.GetBeaconPosition(entity.id, pos)) then
--				-- no attention target and no beacon, bail out
--				entity:SelectPipe(0,"cv_look_standby");
--				if(target == AITARGET_NONE) then
--					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_acquire_beacon");
--				end
----				AI.RecComment(entity.id, "return2");
--				return
--			end
--		else
--			CopyVector(pos, AI.GetProbableTargetPosition(entity.id));
--		end
--
--		local standbySpot = "";
--		if(entity.AI.StandbyShape) then
--			standbySpot = AI.FindStandbySpotInShape(entity.id, entity.AI.StandbyShape, pos, AIAnchorTable.ALERT_STANDBY_SPOT);
--		elseif(entity.AI.TerritoryShape) then
--			standbySpot = AI.FindStandbySpotInShape(entity.id, entity.AI.TerritoryShape, pos, AIAnchorTable.ALERT_STANDBY_SPOT);
--		end
--		
--		if(standbySpot) then
--			if(entity.AI.LastStandbySpot) then
--				local dt = _time - entity.AI.LastStandbyTime;
--				-- if the standby spot is the same, assume that we have pretty good spot already.
--				if(entity.AI.LastStandbySpot == standbySpot and dt < 6.0) then
--	--				AI.RecComment(entity.id, "return4");
--					return;
--				end
--			else
--				entity.AI.LastStandbySpot = standbySpot;
--			end
--
--			local spot = System.GetEntityByName(standbySpot);	
--			if(spot) then
--				CopyVector(pos, spot:GetPos());
--				AI.SetRefPointRadius(entity.id, AI.GetObjectRadius(spot.id));
--			else
--				AI.SetRefPointRadius(entity.id, 15.0);
--			end
--		end
--
--		if(entity.AI.StandbyShape) then
--			CopyVector(pos, AI.ConstrainPointInsideGenericShape(pos, entity.AI.StandbyShape, 1));
--		end
--		if(entity.AI.TerritoryShape) then
--			CopyVector(pos, AI.ConstrainPointInsideGenericShape(pos, entity.AI.TerritoryShape, 1));
--		end
--		AI.SetRefPointPosition(entity.id, pos);
--
--		entity:SelectPipe(0,"cv_approach_standby");
--		if(entity.AI.hurryInStandby and entity.AI.hurryInStandby == 1) then
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_it_running");
--		else
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_it_walking");
--		end

--		if(target == AITARGET_NONE) then
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_acquire_beacon");
--		end
	end,

	---------------------------------------------
	INVESTIGATE_CONTINUE = function( self, entity )
		entity:SelectPipe(0,"cv_investigate_threat_closer");
	end,

	---------------------------------------------
	OnNoTarget = function (self, entity)
--		AI.SetRefPointPosition(entity.id,entity.AI.idlePos);
--		entity:SelectPipe(0,"cv_get_back_to_idlepos");
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE",entity.id);
	end,

	---------------------------------------------
	INVESTIGATE_DONE = function (self, entity)
		self:ChooseStandbyPos(entity);
	end,

	---------------------------------------------
	APPROACH_DONE = function (self, entity)
		self:ChooseStandbyPos(entity);
	end,

	---------------------------------------------
	SEEK_KILLER = function (self, entity)
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		-- called when the enemy sees a living player
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		AI_Utils:CommonEnemySeen(entity, data);
	end,

	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,

	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,

	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
--		entity:TriggerEvent(AIEVENT_CLEAR);
--		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
--		self:CheckToChangeTarget(entity);
	end,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
--		entity:TriggerEvent(AIEVENT_CLEAR);
		-- called when the enemy hears a scary sound
		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		self:ChooseStandbyPos(entity);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:Readibility("alert_interest_see",1,1,0.3,0.6);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		self:ChooseStandbyPos(entity);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		entity:Readibility("alert_interest_see",1,1,0.3,0.6);
		self:ChooseStandbyPos(entity);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
	end,
	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
	end,

	--------------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
		self:ChooseStandbyPos(entity);
	end,
}

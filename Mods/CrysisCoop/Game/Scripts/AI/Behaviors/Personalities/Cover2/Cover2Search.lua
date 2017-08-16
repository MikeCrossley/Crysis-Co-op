--------------------------------------------------
-- SneakerSearch
--------------------------
--   created: Mikko Mononen 21-6-2006

AIBehaviour.Cover2Search = {
	Name = "Cover2Search",
	alertness = 1,

	---------------------------------------------
	Constructor = function(self, entity)
		entity:Readibility("searching_for_enemy",1,1,0.3,1.0);

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEEKING);

		-- check if the AI is at the edge of the territory and cannot move.
		if(AI_Utils:IsTargetOutsideTerritory(entity) == 1) then
			-- at the edge, wait, aim and shoot.
			entity:SelectPipe(0,"sn_wait_and_aim");
		else
			-- enough space, search.
			entity:SelectPipe(0,"cv_seek_target_random");
		end
		
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEARCHING);
		
		entity.AI.lastLookAtTime = _time;
	end,

	---------------------------------------------
	Destructor = function(self, entity)
		entity.anchor = nil;
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		-- called when the enemy sees a living player
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		AI_Utils:CommonEnemySeen(entity, data);
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
--		AI.SetRefPointPosition(entity.id,entity.AI.idlePos);
--		entity:SelectPipe(0,"cv_get_back_to_idlepos");
--		entity:Readibility("alert_idle_relax",1,1,0.3,0.6);
--		AI.Signal(SIGNALFILTER_SENDER,1,"RETURN_TO_FIRST",entity.id);
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity)
		-- check if the AI is at the edge of the territory and cannot move.
		if(AI_Utils:IsTargetOutsideTerritory(entity) == 1) then
			-- at the edge, wait, aim and shoot.
			entity:SelectPipe(0,"sn_wait_and_aim");
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEEKING);
			-- enough space, search.
			entity:SelectPipe(0,"cv_seek_target_random");
		end
	end,

	---------------------------------------------
	OnReload = function( self, entity )
--		entity:Readibility("reloading",1);
	end,

	--------------------------------------------------
	HIDE_FAILED = function (self, entity, sender)
		-- no hide points, goto group combat location to avoid clustering
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEEKING);
		entity:SelectPipe(0,"cv_seek_target_nocover");
	end,

	--------------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- check if the AI is at the edge of the territory and cannot move.
		if(AI_Utils:IsTargetOutsideTerritory(entity) == 1) then
			-- at the edge, wait, aim and shoot.
			entity:SelectPipe(0,"sn_wait_and_aim");
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEEKING);
			-- enough space, search.
			entity:SelectPipe(0,"cv_seek_target_random");
		end
	end,	

	--------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
		-- there is still some room for moving.
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
		-- there is still some room for moving.
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	INVESTIGATE_CONTINUE = function( self, entity )
		entity:SelectPipe(0,"cv_investigate_threat_closer");
	end,
	
	---------------------------------------------
	INVESTIGATE_DONE = function( self, entity )
		self:COVER_NORMALATTACK(entity);
	end,

}

----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: the idle (default) behaviour for the Cover
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 08:nov:2005   : Created by Kirill Bulatsev
--
----------------------------------------------------------------------------------------------------´


AIBehaviour.WatchTowerGuardAlerted = {
	Name = "WatchTowerGuardAlerted",
	alertness = 1,
	exclusive = 1,

	Constructor = function (self, entity)

		entity:MakeAlerted();

		---------------------------------------------
		AI.BeginGoalPipe("wtg_watch_interested");
			-- approach the watch pos anchor
			AI.PushGoal("approach",1,0,AILASTOPRES_USE);
			-- look at the direction of the anchor (set as refpoint)
--			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("bodypos",0,BODYPOS_STAND);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
--			AI.PushGoal("lookat",0,0,0,1);
			AI.PushGoal("timeout",1,2,3);
			AI.PushGoal("clear",0,0);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("lookaround",1,45,3,4,7,AI_BREAK_ON_LIVE_TARGET);
			AI.PushGoal("signal",0,1,"CHOOSE_WATCH_SPOT_INTERESTED",0);
		AI.EndGoalPipe();

		self:CHOOSE_WATCH_SPOT_INTERESTED(entity);

	end,

	--------------------------------------------------
	CHOOSE_WATCH_SPOT_INTERESTED = function (self, entity)

		local	objectPos = g_Vectors.temp_v1;
		local	objectDir = g_Vectors.temp_v2;

		local anchorName = AI.FindObjectOfType(entity.id, 10.0, AIAnchorTable.COMBAT_ATTACK_DIRECTION,
														AIFO_FACING_TARGET+AIFO_NONOCCUPIED+AIFO_NONOCCUPIED_REFPOINT+AIFO_USE_BEACON_AS_FALLBACK_TGT+AIFO_NO_DEVALUE,
														objectPos, objectDir);

		if(not anchorName) then
			entity:SelectPipe(0,"sn_close_combat");
			return;
		end

		AI.SetRefPointPosition(entity.id, objectPos);

		entity:SelectPipe(0,"wtg_watch_interested", anchorName);
	
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:Readibility("first_contact",1,3,0.1,0.4);
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		entity.AI.firstContact = true;

		if (AI_Utils:IsTargetFound(entity) == 0) then
			AI_Utils:SetTargetFound(entity, 1);
			entity:SelectPipe(0,"wtg_signal_target_found_combat");
		else
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"ENEMYSEEN_DURING_COMBAT",entity.id);
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_WATCH_TOWER_COMBAT",entity.id);
		end
	end,

	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
--		entity:SelectPipe(0,"sn_close_combat");
	end,

	---------------------------------------------
	OnNoTarget = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_WATCH_TOWER_IDLE",entity.id);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("idle_interest_see",1,1,0.6,1);
--		self:CHOOSE_WATCH_SPOT_INTERESTED(entity, true);
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- check if we should check the sound or not.
		entity:Readibility("idle_interest_hear",1,1,0.6,1);
--		self:CHOOSE_WATCH_SPOT_INTERESTED(entity, true);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		self:CHOOSE_WATCH_SPOT_INTERESTED(entity, true);
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:Readibility("taking_fire",1,1,0.3,0.5);
		entity:GettingAlerted();
	end,

	--------------------------------------------------
	DUCK_AND_HIDE_DONE = function (self, entity, sender)
		self:CHOOSE_WATCH_SPOT_INTERESTED(entity, true);
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		entity:GettingAlerted();
		
		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
		else
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
		
		entity:SelectPipe(0,"wtg_duck_and_hide");
		entity.AI.lastDuckTime = _time;
	end,

	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
		if(AI.Hostile(entity.id, sender.id)) then
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
			entity:GettingAlerted();
			
			if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
				local	closestCover = AI.GetNearestHidespot(entity.id, 3, 15, sender:GetPos());
				if(closestCover~=nil) then
					AI.SetBeaconPosition(entity.id, closestCover);
				else
					AI.SetBeaconPosition(entity.id, sender:GetPos());
				end
			else
				entity:TriggerEvent(AIEVENT_DROPBEACON);
			end
			
			if(not entity.AI.lastDuckTime) then
				entity.AI.lastDuckTime = _time - 10;
			end
			local dt = _time - entity.AI.lastDuckTime;
			if(dt > 8.0) then
				entity:SelectPipe(0,"wtg_duck_and_hide");
				entity.AI.lastDuckTime = _time;
			end
		end
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		if(AI.Hostile(entity.id, sender.id)) then
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
			entity:GettingAlerted();
			
			if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
				local	closestCover = AI.GetNearestHidespot(entity.id, 3, 15, sender:GetPos());
				if(closestCover~=nil) then
					AI.SetBeaconPosition(entity.id, closestCover);
				else
					AI.SetBeaconPosition(entity.id, sender:GetPos());
				end
			else
				entity:TriggerEvent(AIEVENT_DROPBEACON);
			end
			
			if(not entity.AI.lastDuckTime) then
				entity.AI.lastDuckTime = _time - 10;
			end
			local dt = _time - entity.AI.lastDuckTime;
			if(dt > 8.0) then
				entity:SelectPipe(0,"wtg_duck_and_hide");
				entity.AI.lastDuckTime = _time;
			end
		end
	end,

	--------------------------------------------------
	INVESTIGATE_BEACON = function (self, entity, sender)
	end,

	---------------------------------------------
	SEEK_KILLER = function(self, entity)
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
	end,

	--------------------------------------------------
	OnFriendInWay = function(self, entity)
	end,

	--------------------------------------------------
	OnGroupMemberDied = function(self, entity, sender, data)
		entity:GettingAlerted();
		if(not entity.AI.lastDuckTime) then
			entity.AI.lastDuckTime = _time - 10;
		end
		local dt = _time - entity.AI.lastDuckTime;
		if(dt > 8.0) then
			entity:SelectPipe(0,"wtg_duck_and_hide");
			entity.AI.lastDuckTime = _time;
		end
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function (self, entity, sender, data)
		entity:GettingAlerted();
		if(not entity.AI.lastDuckTime) then
			entity.AI.lastDuckTime = _time - 10;
		end
		local dt = _time - entity.AI.lastDuckTime;
		if(dt > 8.0) then
			entity:SelectPipe(0,"wtg_duck_and_hide");
			entity.AI.lastDuckTime = _time;
		end
	end,
}

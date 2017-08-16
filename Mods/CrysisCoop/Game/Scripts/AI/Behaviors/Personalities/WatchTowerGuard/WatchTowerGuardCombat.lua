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


AIBehaviour.WatchTowerGuardCombat = {
	Name = "WatchTowerGuardCombat",
	alertness = 2,
	exclusive = 1,

	Constructor = function (self, entity)

		entity:MakeAlerted();

		local currentWeapon = entity.inventory:GetCurrentItem();
		if(currentWeapon~=nil and currentWeapon.class=="LAW") then 
			entity.AI.hasRPG = 1;
		else
			entity.AI.hasRPG = nil;	
		end		

		self.CheckCloseRange(entity);
		self:CHOOSE_WATCH_SPOT_COMBAT(entity);

		self:CHOOSE_WATCH_SPOT_COMBAT(entity);

	end,

	--------------------------------------------------
	CHOOSE_WATCH_SPOT_COMBAT = function (self, entity, notAlerted)

		local	objectPos = g_Vectors.temp_v1;
		local	objectDir = g_Vectors.temp_v2;

		local anchorName = AI.FindObjectOfType(entity.id, 10.0, AIAnchorTable.COMBAT_ATTACK_DIRECTION,
															AIFO_FACING_TARGET+AIFO_NONOCCUPIED+AIFO_NONOCCUPIED_REFPOINT+AIFO_USE_BEACON_AS_FALLBACK_TGT+AIFO_NO_DEVALUE,
															objectPos, objectDir);

		if(not anchorName) then
			AI.LogComment("no anchorName");
			if(notAlerted) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_WATCH_TOWER_ALERT",entity.id);
			else
				entity:SelectPipe(0,"sn_close_combat");
			end
			return;
		end

		-- if in close range - don't change weapon/pipe
		if(entity.AI.closeRange==1) then
			return
		end

--local currentWeapon = self.inventory:GetCurrentItem();
		AI.SetRefPointPosition(entity.id, objectPos);
		entity:SelectPrimaryWeapon();
		if(entity.AI.hasRPG)then
			entity:SelectPipe(0,"wtg_combat_RPG", anchorName);
		else		
			entity:SelectPipe(0,"wtg_combat", anchorName);
		end
	
	end,

	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
--		entity:SelectPipe(0,"sn_close_combat");
		self:CHOOSE_WATCH_SPOT_COMBAT(entity);
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:MakeAlerted();
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"HEADS_UP_GUYS",entity.id);
	end,

	---------------------------------------------
	CheckCloseRange	= function (entity)
	
		entity.AI.attackTimer = Script.SetTimerForFunction(500,"AIBehaviour.WatchTowerGuardCombat.CheckCloseRange",entity);
		local targetDist = AI.GetAttentionTargetDistance(entity.id)
		if(targetDist and targetDist<5) then
			entity:SelectSecondaryWeapon();
			entity:SelectPipe(0,"wtg_combat_very_close");
			entity.AI.closeRange=1;
			return 1;
		elseif(entity.AI.closeRange==nil and targetDist and targetDist<15) then
			entity:SelectSecondaryWeapon();
--			local anchorName = AI.FindObjectOfType(entity.id, 10.0, AIAnchorTable.COMBAT_ATTACK_DIRECTION,
--															AIFO_FACING_TARGET+AIFO_NONOCCUPIED+AIFO_NONOCCUPIED_REFPOINT+AIFO_USE_BEACON_AS_FALLBACK_TGT+AIFO_NO_DEVALUE,
--															objectPos, objectDir);
			entity:SelectPipe(0,"wtg_combat_close");--, anchorName);
			entity.AI.closeRange=1;
			return 1;
		end
		entity.AI.closeRange=nil;
		return nil
	end,

	--------------------------------------------------
	CHOOSE_WATCH_SPOT_STRAFE = function (self, entity, notAlerted)

		local	objectPos = g_Vectors.temp_v1;
		local	objectDir = g_Vectors.temp_v2;

		local anchorName = AI.FindObjectOfType(entity.id, 10.0, AIAnchorTable.COMBAT_ATTACK_DIRECTION,
															AIFO_FACING_TARGET+AIFO_CHOOSE_RANDOM+AIFO_NONOCCUPIED
															+AIFO_NONOCCUPIED_REFPOINT+AIFO_USE_BEACON_AS_FALLBACK_TGT+AIFO_NO_DEVALUE,
															objectPos, objectDir);

		if(not anchorName) then
--			AI.LogComment("no anchorName");
			return;
		end

		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"wtg_combat_no_shot");
	end,



	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_WATCH_TOWER_ALERT",entity.id);
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
		-- empty
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,

	--------------------------------------------------
	DUCK_AND_HIDE_DONE = function (self, entity, sender)
		self:CHOOSE_WATCH_SPOT_COMBAT(entity, true);
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

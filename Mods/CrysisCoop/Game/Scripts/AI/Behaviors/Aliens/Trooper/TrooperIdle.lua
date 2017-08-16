--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Idle behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/1/2005     : Created by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.TrooperIdle = {
	Name = "TrooperIdle",
	Base = "TROOPERDEFAULT",
	--alertness = 2,

	hasConversation = true,
	
	Constructor = function(self,entity)
		AI.LogEvent(entity:GetName().." TROOPERIDLE constructor");
		local leader = AI.GetLeader(entity.id);
		if(leader) then 
			g_SignalData.iValue = UPR_COMBAT_GROUND;
			AI.Signal(SIGNALFILTER_LEADER, 10, "OnSetUnitProperties", entity.id,g_SignalData);
			if(leader.AI.bIsLeader) then 
				-- enter TrooperGroupIdle behavior only if the leader has TrooperLeader character
				AI.Signal(SIGNALFILTER_SENDER, 1, "JOIN_TEAM", entity.id);
			end
		end
		entity:DrawWeaponNow(1);
		AIBehaviour.TROOPERDEFAULT.Constructor(self,entity);
		AI.SetStance(entity.id,BODYPOS_STAND);
		Trooper_SetAccuracy(entity);
		Trooper_SetConversation(entity);

	end,	
	
	OnDamage = function(self,entity,bender)
		
	end,
	
	OnPlayerSeen = function( self, entity, distance )
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target and target.id) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
		local target = AI.GetAttentionTargetEntity(entity.id)
		if(target) then 
			targetNavType = AI.GetNavigationType(target.id);
			if(not AI.GetLeader(entity.id)) then 
				-- not important who the leader is associated to here
				AI.SetLeader(entity.id); 
			end
--			if(Trooper_CheckAttackChase(entity,target)) then 
--				return;
--			end			
		end
	--	do return end
		
		
		entity:ReadibilityContact();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_ATTACK",entity.id);
	end,
	
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		
		local target = AI.GetAttentionTargetEntity(entity.id)
		if(target) then 
			targetNavType = AI.GetNavigationType(target.id);
			if(not AI.GetLeader(entity.id)) then 
				-- not important who the leader is associated to here
				AI.SetLeader(entity.id); 
			end
--			if(Trooper_CheckAttackChase(entity,target)) then 
--				return;
--			end			
		end

--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_wait_response_from_other_groups"); 
		AIBehaviour.TrooperIdle:OnInterestingSoundHeard(entity);
	end,
	
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		
		-- only non grouped behaviour
		local targetName = AI.GetAttentionTargetOf(entity.id);
		if(targetName  and AI.Hostile(entity.id,targetName)) then
			-- target is flesh and blood and enemy
			local target = System.GetEntityByName(targetName);
			local dist = entity:GetDistance(target.id);
			if(dist >50) then
				entity:SelectPipe(0,"tr_just_shoot");
			elseif(dist >10) then
				entity:SelectPipe(0,"tr_just_shoot");
				if( dist < 5 ) then
					entity:InsertSubpipe(0,"tr_backoff");
				end
			end
			return;
		end
		--no interesting target
--		entity:SelectPipe(0,"tr_random_hide_wider");
--		entity:InsertSubpipe(0,"tr_random_short_timeout");
	end,	

	
	---------------------------------------------
	GET_ALERTED = function( self, entity )
		entity:Readibility("IDLE_TO_THREATENED");
		entity:SelectPipe(0,"tr_pindown");
		entity:DrawWeaponDelay(0.6);
	end,
	
	---------------------------------------------
	DRAW_GUN = function( self, entity )
		AI.LogEvent(entity:GetName().." DRAWING GUN");
		if(not entity.inventory:GetCurrentItemId()) then
			entity:HolsterItem(false);
		end
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target and AI.Hostile(entity.id,target.id)) then 
--			AI.LogEvent(entity:GetName().." OnInterestingSound heard");
--			entity:Readibility("IDLE_TO_INTERESTED",1);
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_wait_response_from_other_groups"); 
--		end
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"GO_TO_INTERESTED",entity.id);
		AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
		g_SignalData.fValue = AI.GetAttentionTargetDistance(entity.id);
		AI.Signal(SIGNALFILTER_NEARESTINCOMM,0,"LOOK_CLOSER",entity.id,g_SignalData);
		if(AI.GetTargetType(entity.id) == AITARGET_ENEMY and AI.GetAttentionTargetDistance(entity.id)<18) then
			entity:ReadibilityContact();
		else
			entity:Readibility("IDLE_TO_INTERESTED",0,0,0.3,0.5);
		end
		--entity:Readibility("curious",0,0,0.3,0.5)
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		AI.LogEvent(entity:GetName().." OnTHREATENINGSound heard");

		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		entity:Readibility("first_contact_group",1);

		--AI.Signal(0,1,"GO_THREATEN",entity.id);

--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_wait_response_from_other_groups"); 
		entity:SelectPipe(0,"tr_investigate_threat"); 
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_it_walking");
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_threatened"); 
		entity:GettingAlerted();

	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,


	--------------------------------------------------
	OnCollision = function(self,entity,sender,data)
		if(AI.Hostile(entity.id,data.id) and AI.GetAttentionTargetEntity(entity.id) ~= System.GetEntity(data.id)) then 
			--entity:ReadibilityContact();
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"short_look_at_lastop",data.id);
		end
	end,	

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		--if (entity.AI.lastEnemyDamageTime==nil or (_time - entity.AI.lastEnemyDamageTime > 1)) then 
			entity.AI.lastEnemyDamageTime = _time;
			AIBlackBoard.lastTrooperDamageTime = _time;
			Trooper_GoToThreatened(entity,data.point,data.id);
		--end
	end,

--	---------------------------------------------
--	END_REACT_AND_SEARCH = function ( self, entity, sender)
--		CopyVector(g_SignalData.point,entity.AI.shooterPos);
--		g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
--		g_SignalData.iValue2 = AIAnchorTable.SEARCH_SPOT;
--		g_SignalData.fValue = 20; --search distance
--		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
--	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
--		if(AI.Hostile(entity.id,data.id) and (entity.AI.lastEnemyDamageTime==nil or (_time - entity.AI.lastEnemyDamageTime > 1))) then 
--		if(AI.Hostile(entity.id,data.id) and not Trooper_IsThreateningBullet(entity,data.point)) then 
--			entity.AI.lastEnemyDamageTime	 = _time;
--			AIBlackBoard.lastTrooperDamageTime = _time;
--			Trooper_GoToThreatened(entity,data.point);
--		end				
		Trooper_GoToThreatened(entity,data.point,data.id);
	end,

	--------------------------------------------------
	OnBulletHit = function ( self, entity, sender,data)
--		if(AI.Hostile(entity.id,data.id) and (entity.AI.lastEnemyDamageTime==nil or (_time - entity.AI.lastEnemyDamageTime > 1))) then 
		Trooper_GoToThreatened(entity,data.point);
		entity.AI.lastBulletHitTime = _time;
	end,
	
	---------------------------------------------
	OnNearMiss = function ( self, entity, sender,data)
		-- to do: OnNearMiss is managed in total different way than bullet rain
		-- sender ==entity, no data...
		--AIBehaviour.TrooperIdle:OnBulletRain(entity,sender,data);
	end,
	
	---------------------------------------------
	SEARCH_IF_NO_TARGET = function ( self, entity, sender)
		local targetType= AI.GetTargetType(entity.id);
		if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then 
			entity:SelectPipe(0,"tr_approach_beacon_15m");	
		else
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_THREATEN",entity.id);
		end
	end,
	
	---------------------------------------------
	BEACON_APPROACHED = function ( self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER, 1, "GO_TO_SEARCH",entity.id);
	end,
	
	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
		if(entity.Properties.Perception.sightrange > 0) then

	 		if(AI.Hostile(entity.id,sender.id)) then
	 			return
	 		end
	 		
		 	if (entity ~= sender) then
		 		if(AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
	--	 			entity:SelectPipe(0,"tr_not_so_random_hide_from","atttarget");
	--				entity:InsertSubpipe(0,"tr_backoff_from",sender.id);
	--				entity:InsertSubpipe(0,"DRAW_GUN");
	--				entity:InsertSubpipe(0,"tr_setup_combat");		
	--				entity:InsertSubpipe(0,"tr_random_very_short_timeout");		
		 		else
	--	 			entity:SelectPipe(0,"tr_random_hide");
	--				entity:InsertSubpipe(0,"tr_backoff_from",sender.id);
	--				entity:InsertSubpipe(0,"DRAW_GUN");
	--				entity:InsertSubpipe(0,"tr_setup_combat");		
	--				entity:InsertSubpipe(0,"tr_random_very_short_timeout");		
	--				entity:InsertSubpipe(0,"acquire_target",sender.id);
	--				entity:InsertSubpipe(0,"tr_random_very_short_timeout");		
		 		end
	--			entity:MakeAlerted();
		 	end
		end
	end,


	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"tr_investigate_threat");		
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		local targetType = AI.GetTargetType(entity.id);
		if(targetType==AITARGET_ENEMY) then 
			Trooper_StickPlayerAndShoot(entity);
		else
			entity:SelectPipe(0,"tr_stick_close");
			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
				entity:InsertSubpipe(0,"acquire_target","beacon");
			end
		end

	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
--		local targetType = AI.GetTargetType(entity.id);
--		if(targetType==AITARGET_ENEMY) then 
--			Trooper_StickPlayerAndShoot(entity);
--		else
--			entity:SelectPipe(0,"tr_stick_close");
--			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"acquire_target","beacon");
--			end
--		end
	end,

	---------------------------------------------	
	THREAT_TOO_CLOSE = function (self, entity, sender)
		entity:SelectPipe(0,"tr_investigate_threat"); 
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_it_running");
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_threatened"); 
	end,
	

	---------------------------------------------
	ACT_FOLLOW = function( self, entity,sender,data )
		entity:SelectPipe(0,"stay_in_formation_moving");
		entity:InsertSubpipe(0,"do_it_very_slow");
	end,
	
	---------------------------------------------
	LOOK_CLOSER = function( self, entity,sender,data )
		local targetType = AI.GetTargetType(entity.id);
		if(targetType ~= AITARGET_SOUND) then 
			entity:SelectPipe(0,"tr_look_closer");
			if(data.fValue<8) then 
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_it_very_slow");
			end
--			AI.SetRefPointPosition(entity.id,data.point);
--			entity:InsertSubpipe(0,"acquire_target","refpoint");
		end
	end,
	

	---------------------------------------------
	GO_TO_ATTACK = function(self , entity, sender)
--		entity:Readibility("clear",1);
--		local targetType = AI.GetTargetType(entity.id);
--		if(targetType==AITARGET_ENEMY) then 
--			--entity:SelectPipe(0,"tr_just_shoot");
--			Trooper_StickPlayerAndShoot(entity);
--		else
--			entity:SelectPipe(0,"tr_stick_close");
--			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
--				entity:InsertSubpipe(0,"acquire_target","beacon");
--			end
--		end
	end,
	
	---------------------------------------------
	PLAYER_NOT_ENGAGED = function(self , entity, sender)
		local targetType = AI.GetTargetType(entity.id);
		local distance = AI.GetAttentionTargetDistance(entity.id);
		if(targetType == AITARGET_ENEMY and distance<30) then
		
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
			
		elseif(targetType == AITARGET_ENEMY or targetType == AITARGET_SOUND or targetType == AITARGET_MEMORY) then
					
			AI.Signal(SIGNALFILTER_GROUPONLY,0,"GO_TO_INTERESTED",entity.id);
			AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
			g_SignalData.fValue = distance;
			AI.Signal(SIGNALFILTER_NEARESTINCOMM,0,"LOOK_CLOSER",entity.id,g_SignalData);
		end
	end,

	------------------------------------------------------------------------
	PLAYER_ENGAGED= function (self, entity, sender)
		-- let the other group engage the player
		entity:CancelSubpipe();
		entity:SelectPipe(0,"do_nothing");
	end,
	
	--------------------------------------------------
	JUMP_ON_ROCK = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,
	

}

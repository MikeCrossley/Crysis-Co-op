--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Group Idle behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/1/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperGroupIdle = {
	Name = "TrooperGroupIdle",
	Base = "TROOPERDEFAULT",

	Constructor = function(self,entity)
		AI.LogEvent(entity:GetName().." TROOPERGROUPIDLE constructor");
		entity:InitAIRelaxed();
		g_SignalData.iValue = UPR_COMBAT_GROUND;
		AI.Signal(SIGNALFILTER_LEADER, 10, "OnSetUnitProperties", entity.id,g_SignalData);
		--entity:Cloak(1);
		entity:SelectPipe(0,"do_nothing");
		local anchorName = AI.FindObjectOfType(entity.id, 20, AIAnchorTable.ALIEN_AMBUSH_AREA);
		if(anchorName and anchorName~="") then 
			AI.Signal(SIGNALFILTER_SUPERGROUP,1,"GO_TO_AMBUSH",entity.id);
		end
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange);	

	end,	

	Destructor = function(self,entity)
		-- in most of the cases, exiting from this behavior means going into alerted/combat state
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange * 1.5);	
		entity:Readibility("clear",1);

	end,
	
	OnPlayerSeen = function( self, entity, fDistance )
		
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target and target.id) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
		
		entity:Readibility("FIRST_HOSTILE_CONTACT",0,1);

		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if(target and target.id) then 
			g_SignalData.id = target.id;
		else
			g_SignalData.id = NULL_ENTITY;
		end
		g_SignalData.fValue = fDistance;
		AI.Signal(SIGNALFILTER_LEADERENTITY, 1, "OnEnemySeenByUnit",entity.id,g_SignalData);
		
	end,
	
	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		AI.LogEvent(entity:GetName().." >>> my target just died ");
	end,
	
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("IDLE_TO_INTERESTED");
		entity:SelectPipe(0,"tr_look_closer");
--		entity:InsertSubpipe(0,"tr_setup_stealth"); 
		entity:MakeAlerted();
	end,
	

	
	---------------------------------------------
	GET_ALERTED = function( self, entity )
--		entity:Readibility("IDLE_TO_THREATENED");
--		entity:SelectPipe(0,"tr_pindown");
--		entity:DrawWeaponDelay(0.6);
	end,
	
	---------------------------------------------
--	DRAW_GUN = function( self, entity )
--		AI.LogEvent(entity:GetName().." DRAWING GUN");
--		if(not entity.currentItemId) then
--			entity:HolsterItem(false);
--		end
--	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		AI.LogEvent(entity:GetName().." OnInterestingSound heard");
		entity:Readibility("IDLE_TO_INTERESTED");

--		entity:SelectPipe(0,"tr_look_closer");
--		entity:InsertSubpipe(0,"setup_stealth"); 
--		entity:DrawWeaponDelay(0.6);
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"GO_TO_INTERESTED",entity.id);
		AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
		AI.Signal(SIGNALFILTER_NEARESTINCOMM,0,"LOOK_CLOSER",entity.id,g_SignalData);
		entity:DrawWeaponDelay(0.6);

	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target and target.id) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
--		
		entity:Readibility("IDLE_TO_THREATENED");

		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if(target and target.id) then 
			g_SignalData.id = target.id;
		else
			g_SignalData.id = NULL_ENTITY;
		end
		g_SignalData.fValue = fDistance;
		AI.Signal(SIGNALFILTER_LEADERENTITY, 1, "OnEnemySeenByUnit",entity.id, g_SignalData);

	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		-- data.id = shooter id
		-- data.point = shooter position
		entity:Cloak(0);
		AI.Signal(SIGNALFILTER_LEADERENTITY,1,"OnUnitDamaged",entity.id,data);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		--entity:SelectPipe(0,"tr_scramble");
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
		-- called when detect weapon fire around AI

		entity:Readibility("BULLETRAIN_IDLE");
--		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);

--		AI.SetRefPointPosition(entity.id,data.point);
--		entity:SelectPipe(0,"tr_random_hide","refpoint");

	end,

	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			AI.LogEvent("OnObjectSeen() GRENADE "..entity:GetName());
			if (fDistance <= 40) then
				--entity:Readibility("GRENADE_SEEN",1);
				if (not entity.Behaviour.alertness) then
					entity:SelectPipe(0, "do_nothing");
				end
				entity:InsertSubpipe(0, "tr_grenade_seen");
			end
		end
	end,
	
	---------------------------------------------
	OnCloseContact = function(self,entity,sender)
		entity:SelectPipe(0,"tr_just_shoot");
--		entity:InsertSubpipe(0,"tr_backoff_fire");
	end,
	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)

 		if(AI.Hostile(entity.id,sender.id)) then
 			return
 		end
 		--AI.Signal(SIGNALFILTER_LEADERENTITY,0,"OnSomebodyDied",sender.id);
	end,
	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)

 		AI.Signal(SIGNALFILTER_LEADERENTITY,0,"OnGroupMemberDied",sender.id);
	end,

	------------------------------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
--		entity.AI.InSquad = 0;
--		g_SignalData.iValue = LAS_ATTACK_FRONT;
--		AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
		AI.LogEvent("OnLeaderDied TROOPER GROUPIDLE");
 	 	CopyVector(g_SignalData.point,AI.GetRefPointPosition(sender.id));
		g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
		g_SignalData.fValue = 20; --search distance
		g_SignalData.iValue2 = AIAnchorTable.SEARCH_SPOT;
		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
		AI.Signal(SIGNALFILTER_SENDER,1,"GOTO_SEARCH",entity.id);
		entity.AI.InSquad = 0;
		
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
		-- forward the message to the coordinator
 		AI.Signal(SIGNALFILTER_LEADERENTITY,0,"OnGroupMemberDied",sender.id,data);
		
	end,

	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"tr_pindown");
	end,

	--------------------------------------------------
	COVER_RELAX = function (self, entity, sender)
		entity:SelectPipe(0,"tr_standing_there");
	end,

	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"tr_investigate_threat");		
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
--		if (entity ~= sender) then
--			entity:DrawWeaponDelay(0.6);
--			entity:GettingAlerted();
--			AI.Signal(SIGNALFILTER_SENDER,0,"RUN_TO_FRIEND",entity.id);
--			entity:SelectPipe(0,"tr_beacon_pindown");
--		end
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		if (entity ~= sender) then
			-- wait for the orders, clear 
--			entity:SelectPipe(0,"do_nothing"); 
		end
	end,

	---------------------------------------------	
	THREAT_TOO_CLOSE = function (self, entity, sender)
		entity:SelectPipe(0,"tr_investigate_threat"); 
		entity:InsertSubpipe(0,"do_it_running");
		entity:InsertSubpipe(0,"tr_threatened"); 
	end,
	
	---------------------------------------------
	GO_THREATEN = function(self , entity, sender, data)
		entity:Cloak(0);
--		entity.actor:QueueAnimationState("trooper_threaten");
--		entity:Readibility("IDLE_TO_THREATENED",1);
	end,

	---------------------------------------------
	GO_TO_ATTACK = function(self , entity, sender)
		AI.LogEvent(entity:GetName().." CLEARING THREATEN");
--		entity:Readibility("clear",1);
	end,
}

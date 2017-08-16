--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Group Ambush behavior for Alien Trooper. 
-- 		Trooper waits cloaked for the enemy, and attacks it only when he receives the signal
--  
--------------------------------------------------------------------------
--  History:
--  - 7/1/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAmbush = {
	Name = "TrooperAmbush",
	Base = "TrooperGroupIdle",

	Constructor = function(self,entity)
		entity.AI.InSquad = 1;
		entity:Cloak(1);
	end,	
	
	OnPlayerSeen = function( self, entity, fDistance )
		-- dont react, wait the START_AMBUSH signal
	end,
	
	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		AI.LogEvent(entity:GetName().." >>> my target just died ");
	end,
	
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
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
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )

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
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		--entity:SelectPipe(0,"tr_scramble");
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when detect weapon fire around AI

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

	------------------------------------------------------------------------
	START_AMBUSH = function(self,entity,sender,data)
		local targetType = AI.GetTargetType(entity.id);
		if(data.id ~= NULL_ENTITY and AI.Hostile(entity.id,data.id)) then
			g_SignalData.id = data.id;
			entity:InsertSubpipe(0,"acquire_target",data.id);
		else
			g_SignalData.id = NULL_ENTITY;
		end
		g_SignalData.fValue = entity:GetDistance(data.id);
		AI.Signal(SIGNALFILTER_LEADERENTITY, 1, "OnEnemySeenByUnit",entity.id,g_SignalData);
	end,
	
	--------------------------------------------------
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)

	end,

	---------------------------------------------	
--	OnLeaderDied = function(self,entity,sender)
--		if(AI.GetGroupTarget(entity.id)) then
--			entity:SelectPipe(0,"tr_confused");
--		else
--			AIBehaviour.TrooperGroupIdle:OnLeaderDied(entity,sender);
--		end
--		entity.AI.InSquad = 0;
--	end,
--	
}

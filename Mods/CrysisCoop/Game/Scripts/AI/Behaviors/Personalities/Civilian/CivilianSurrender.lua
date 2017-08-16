--------------------------------------------------
--   Description: the Surrender behaviour for a Civilian
-- Created by: Luciano Morpurgo
--------------------------



AIBehaviour.CivilianSurrender = {
	Name = "CivilianSurrender",
	Base = "CivilianIdle",
	alertness = 0,
	-- TASK = 1, 

	Constructor = function(self, entity)
 		entity:SelectPipe(0,"do_nothing");
 		entity:InsertSubpipe(0,"civ_surrender");
 		--entity:Event_EnableUsable();
	end,	

	---------------------------------------------
	Destructor = function(self,entity)
		if(entity.iLookTimer) then 
			Script.KillTimer(entity.iLookTimer);
			entity.iLookTimer = nil;
		end
 		AI.SetIgnorant(entity.id,0);
 		entity:Event_DisableUsable();
		
	end,

	---------------------------------------------

	OnCloseContact = function( self, entity, sender )
--		if(AI.GetAttentionTargetEntity(entity.id) == g_localActor) then
--			g_SignalData.id = entity.id;
--			AI.ChangeParameter(entity.id,AIPARAM_GROUPID,0);
--			AI.SetSmartObjectState(entity.id,"Captured");
--	 		AI.SetIgnorant(entity.id,1);
--		-- let the player create a formation if there's no one
--			AI.Signal(SIGNALFILTER_SENDER, 1,"CAPTURE_ME",g_localActor.id,g_SignalData);
--		end
	end,

	---------------------------------------------
	USED = function( self, entity, sender )
		g_SignalData.id = entity.id;
		AI.ChangeParameter(entity.id,AIPARAM_GROUPID,0);
 		AI.SetIgnorant(entity.id,1);
	-- let the player create a formation if there's no one
		AI.Signal(SIGNALFILTER_SENDER, 1,"CAPTURE_ME",g_localActor.id,g_SignalData);
	end,

	---------------------------------------------
	ORDER_FOLLOW = function( self, entity, sender )
--		AI.ModifySmartObjectStates(entity.id,"Captured");
--		entity:SelectPipe(0,"civ_captured");
-- 		entity:InsertSubpipe(0,"ignore_all");
-- 		entity:Event_DisableUsable();
	end,
	---------------------------------------------
	FORMATION_REACHED = function( self, entity, sender )
		
	end,
	---------------------------------------------
	
	OnTargetDead = function( self, entity, sender )
	end,

	
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
		
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	
	---------------------------------------------
	END_TIMEOUT = function( self, entity, sender )
	
	end,
	
	---------------------------------------------
	COME_HERE = function( self, entity, sender )
		
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player


	end,
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
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the entity is damaged by enemy fire
		-- data.id = shooter id
		-- data.fValue = received damage
		entity:Readibility("GETTING_SHOT_AT",1);
		
--		if(not entity.bIgnoreEnemy) then 
--			entity:SelectPipe(0,"random_reacting_timeout");
--			entity:InsertSubpipe(0,"notify_enemy_seen");
--		end
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender,data)
--		entity:Readibility("GETTING_SHOT_AT",1);
		-- TO DO
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when detect weapon fire around AI
		--entity:MakeAlerted();
	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
		entity:Readibility("GRENADE_SEEN",1);

	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		-- call the default to do stuff that everyone should do

	end,

	---------------------------------------------	

	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)
		AIBehaviour.SquadIdle:ORDER_ENTER_VEHICLE(entity,sender,data);
	end,
	ORDER_EXIT_VEHICLE	= function (self, entity, sender,data)
		AIBehaviour.SquadIdle:ORDER_EXIT_VEHICLE(entity,sender,data);
	end,

	---------------------------------------------	
	ORDER_HOLD = function ( self, entity, sender, data ) 
	end,

	
	--------------------------------------------------------------
	FOLLOW_LEADER = function(self,entity,sender,data)
	end,

	---------------------------------------------
	LOOK_LEFT = function(self,entity,sender)
	end,
	---------------------------------------------
	LOOK_RIGHT = function(self,entity,sender)
	end,
	---------------------------------------------
	CheckLook = function (entity,timerId)
		--Script.KillTimer(timerId);
		if (entity.lookLeft ==nil) then
			entity.lookLeft = false;
		end
		entity.lookLeft = not entity.lookLeft;
		if(entity.lookLeft) then
			entity.Behaviour:LOOK_LEFT(entity,entity);
		else
			entity.Behaviour:LOOK_RIGHT(entity,entity);
		end

		entity.iLookTimer = Script.SetTimerForFunction(math.random(3000,4500),"AIBehaviour.HostageIdle.CheckLook",entity)
		
	end,
	
	---------------------------------------------
	OnPlayerLooking = function(self,entity,sender,data)
	end,
	---------------------------------------------
	OnPlayerLookingAway = function(self,entity,sender,data)
	end,
	---------------------------------------------
	OnPlayerSticking = function(self,entity,sender,data)
	end,
	---------------------------------------------
	OnPlayerLeaving = function(self,entity,sender,data)
	end,

}

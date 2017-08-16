--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Attack Flank behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - Aug 2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAttackFlank = {
	Name = "TrooperAttackFlank",
	Base = "TROOPERDEFAULT",
	alertness = 2,
	TASK = 1,

	---------------------------------------------
	Constructor = function (self, entity,data)
		AI.SetRefPointPosition(entity.id,data.point);
		local distTarget = AI.GetAttentionTargetDistance(entity.id);
		local targetPos = g_Vectors.temp;
		local targetDir = g_Vectors.temp_v1;
		AI.GetAttentionTargetPosition(entity.id, targetPos);
		FastDifferenceVectors(targetDir,targetPos,data.point);
		local distFlank = LengthVector(targetDir);
		local distToKeep = math.max(distFlank,distTarget*0.7);
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, distToKeep);

		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"ignore_none");
		entity:InsertSubpipe(0,"tr_approach_refpoint");
--		entity:SelectPipe(0,"tr_hide_near","refpoint");
		entity:InsertSubpipe(0,"do_it_running");
		entity:InsertSubpipe(0,"ignore_all");
		-- set a maximum duration for flank manoeuver
		entity.iTimer = Script.SetTimerForFunction(8000+random(1,5000),"AIBehaviour.TrooperAttackFlank.OnBehaviourTimeout",entity);
--		entity:Event_Cloak();
		entity:Cloak(0);
	end,

	Destructor = function (self, entity)
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
		if(	entity.iTimer ) then
			Script.KillTimer(entity.iTimer);
			entity.iTimer = nil;
		end
--		entity:Event_UnCloak();
	end,

	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		entity:SelectPipe(0,"tr_shoot_timeout");
	end,	

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
		entity:SelectPipe(0,"tr_dig_in_shoot_on_spot_timeout");
	end,

	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	end,

	---------------------------------------------
	REFPOINT_REACHED = function(self,entity,sender)
--		local targetType = AI.GetAttentionTargetType(entity.id);
--		if(targetType == AIOBJECT_PUPPET or targetType == AIOBJECT_VEHICLE or targetType == AIOBJECT_PLAYER) then 
--			entity:SelectPipe(0,"tr_hide_flank");
--		else
--			entity:SelectPipe(0,"tr_seek_target");
--			entity:InsertSubpipe(0,"ignore_none");
--			if(targetType == AIOBJECT_NONE) then
--				entity:InsertSubpipe(0,"acquire_target","beacon");
--			end
--		end
--		entity:InsertSubpipe(0,"ignore_none");
----		entity:Event_UnCloak();
		if(entity.iTimer) then 
			Script.KillTimer(entity.iTimer);
			entity.iTimer = nil;
		end
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	
	---------------------------------------------
	END_FLANK = function(self,entity,sender)
	--	AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		--entity:SelectPipe("do_nothing");
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:Readibility("ENEMY_TARGET_LOST");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--		entity:SelectPipe(0,"tr_hide_near","refpoint");
--		entity:InsertSubpipe(0,"tr_short_cover_fire","atttarget");

	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )

	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
--		entity:InsertSubpipe(0,"tr_do_it_prone");
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,

	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
--		entity:SelectPipe(0,"tr_scramble");
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,



	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
--		entity:SelectPipe(0,"tr_scramble");
		-- call default handling
		AIBehaviour.TROOPERDEFAULT:OnDamage(entity,sender,data);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
--		entity:SelectPipe(0,"tr_scramble");
		-- call default handling
		AIBehaviour.TROOPERDEFAULT:OnDamage(entity,sender,data);
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	--------------------------------------------------
--	OnCloseContact = function ( self, entity, sender)
--		-- called when the enemy is damaged
--		entity:SelectPipe(0,"tr_scramble");
--	end,

	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
--		entity:SelectPipe(0,"tr_scramble");
	end,
	
	--------------------------------------------------
	
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	
	
	------------------------------------------------------------------------
	HEADS_UP_GUYS = function(self,entity,sender)
	
	end,

	------------------------------------------------------------------------
	CHECK_FOR_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"tr_seek_target");
	end,	

	------------------------------------------------------------------------
	OnBehaviourTimeout = function(entity,timerid)
		entity.iTimer = nil;
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
}

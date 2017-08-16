--------------------------------------------------
--   Created By: Luciano
--------------------------

AIBehaviour.LeaderFollow = {
	Name = "LeaderFollow",
	--TASK = 1,

	
	Constructor = function( self, entity )	
		entity:HolsterItem(false);

		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"squad_form");
		--entity:InsertSubpipe(0,"reserve_spot");
		entity:InsertSubpipe(0,"setup_combat");
		entity:InsertSubpipe(0,"short_wait");
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender)
		entity:Readibility("GETTING_SHOT_AT",1);
		--readability
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		entity:Readibility("GETTING_SHOT_AT",1);
--		entity:SelectPipe(0,"random_reacting_timeout");
--		entity:InsertSubpipe(0,"notify_player_seen");
	
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:Readibility("ENEMY_TARGET_LOST"); -- you will go to alert from here
	--	AIBehaviour.SquadIdle:OnNoTarget(entity);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);

		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"notify_player_seen");
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- TO DO: investigate memory target
		entity:SelectPipe(0,"squad_form");
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	--	entity:SelectPipe(0,"cover_scramble");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies

		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- select random attack pipe		
		--NOCOVER:SelectAttack(entity);
		entity:Readibility("THREATEN",1);
	end,	

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
		--entity:SelectPipe(0,"cover_scramble");
	end,

	--------------------------------------------------
	OnVehicleDanger = function(self, entity, sender, signalData)
		-- just ignore this signal and avoid default processing.
		-- we don't want to "scare" them now by their own vehicles
	end,
	--------------------------------------------------

	OnSpeedUp = function ( self, entity, sender,data)
		-- data.fValue = distance from formation point
		entity:InsertSubpipe(0,"do_it_running");
	end,
	--------------------------------------------------

	OnSlowDown = function ( self, entity, sender)
		entity:InsertSubpipe(0,"do_it_walking");
	end,
	--------------------------------------------------
	
--	LEADER_CROUCH = function(self,entity,sender)
--		entity:InsertSubpipe(0,"random_very_short_timeout");
--		entity:InsertSubpipe(0,"do_it_crouched");
--		
--	end,
--	
--	LEADER_STAND = function(self,entity,sender)
--		entity:InsertSubpipe(0,"random_very_short_timeout");
--		entity:InsertSubpipe(0,"do_it_standing");
--	end,
--	
--	LEADER_PRONE = function(self,entity,sender)
--		entity:InsertSubpipe(0,"random_very_short_timeout");
--		entity:InsertSubpipe(0,"do_it_prone");
--	end,

	--------------------------------------------------


	-- ignore these signals when following
--	CONVERSATION_START = function (self,entity, sender)
--	end,
--	--------------------------------------------------
--	CONVERSATION_REQUEST = function (self,entity, sender)
--	end,
--	--------------------------------------------------
--	CONVERSATION_REQUEST_INPLACE = function (self,entity, sender)
--	end,



	
	
}
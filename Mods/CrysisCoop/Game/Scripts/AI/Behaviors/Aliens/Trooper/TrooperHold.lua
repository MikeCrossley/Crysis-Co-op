--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Hold behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/1/2005     : Created by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.TrooperHold = {
	Name = "TrooperHold",
	Base = "TROOPERDEFAULT",
	alertness = 1,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"tr_not_so_random_hide_from",data.id);
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:SelectPipe(0,"tr_confirm_targetloss");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		
		local targetName = AI.GetAttentionTargetOf(entity.id);
		local target;
		local dist = -1;
		if(targetName) then
			target = System.GetEntityByName(targetName);
		end	
		if(target ) then
			-- target is flesh and blood and enemy
			dist = entity:GetDistance(target.id);
		else
			--try the beacon
			local beacon = g_Vectors.temp;
			if( AI.GetBeaconPosition( entity.id ,beacon) ) then
				dist = DistanceSqVectors(entity:GetWorldPos(),beacon);
			end
		end			
		
		if(dist <0) then	
			entity:SelectPipe(0,"tr_just_shoot");
		elseif(dist >10) then
			entity:SelectPipe(0,"do_nothing");	-- reset the goalpipe to allow to select the same pipe again.
			entity:SelectPipe(0,"tr_not_so_random_hide_from");
		else
			entity:SelectPipe(0,"tr_just_shoot");
			entity:InsertSubpipe(0,"tr_backoff_fire");
		end

		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
		-- try to re-establish contact
		entity:SelectPipe(0,"tr_seek_target");
		entity:InsertSubpipe(0,"reload");
--		entity:InsertSubpipe(0,"do_it_prone");
		
		if (fDistance > 5) then 
			entity:InsertSubpipe(0,"do_it_running");
		else
			entity:InsertSubpipe(0,"do_it_walking");
		end
		
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
--		System.Log(entity:GetName().." TrooperHold onInterestingSoundHeard");
		self:OnEnemyMemory(entity,1);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- ignore this
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,


	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- he is not trying to hide in this behaviour
	end,	

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		AIBehaviour.TROOPERDEFAULT:OnReceivingDamage(entity,sender);

		entity:SelectPipe(0,"tr_scramble");
		entity:InsertSubpipe(0,"pause_shooting");
	end,

	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
		entity:SelectPipe(0,"tr_scramble");
		entity:InsertSubpipe(0,"take_cover");
	end,

	COVER_NORMALATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"tr_pindown");
	end,

	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,

	---------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- do nothing on this signal
		entity:SelectPipe(0,"look_around");
	end,	

	---------------------------------------------	
	GET_ALERTED = function( self, entity )
	end,

}
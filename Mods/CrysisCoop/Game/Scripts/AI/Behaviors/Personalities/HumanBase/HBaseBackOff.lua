--------------------------------------------------
--   Created By: Kirill
--   Description: This is the combat backOff behaviour - to be used when enemy is too close


AIBehaviour.HBaseBackOff = {
	Name = "HBaseBackOff",
	alertness = 2,
	base = "CoverAttack",

	Constructor = function (self, entity)
		entity.backing_to_anchor=nil	
		entity:SelectPipe(0,"backoff_hide");
--		entity:SelectPipe(0,"backoff_firing");		
	end,

	---------------------------------------------
	FindBackOffSpot  = function (self, entity)
			local anchorName = AI.GetAnchor(entity.id,AIAnchorTable.COMBAT_RETREAT_HERE,{min=9,max=50},AIANCHOR_BEHIND_IN_RANGE);
			if( anchorName ) then
--				local anchor = System.GetEntityByName( anchorName );
				entity.backing_to_anchor=1;
				entity:SelectPipe(0,"backoff_anchor", anchorName);
				return 1
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "BACKOFF_DONE",entity.id);
				return nil
			end
	end,


	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	OnSomebodyDied = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	checking_dead = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)

		--entity:SelectPipe(0,"do_nothing");--in case it was already in dig_in_attack
		entity:SelectPipe(0,"low_hide_shoot");
--		entity:SelectPipe(0,"dig_in_shoot_on_spot");

	end,
	
	---------------------------------------------	
	OnNoHidingPlace = function( self, entity, sender)
		self:FindBackOffSpot(entity)
	end,
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:Readibility("ENEMY_TARGET_LOST"); -- you will go to alert from here
		
--		if(entity:SetRefPointAroundBeaconRandom(8)) then
--			entity:SelectPipe(0,"cover_refpoint_investigate");
--		else
--			entity:SelectPipe(0,"cover_beacon_investigate");
--		end

--		entity:SelectPipe(0,"search_for_target");
--		if(entity:SetRefPointAtDistanceFromTarget(8)) then
--			entity:SelectPipe(0,"approach_target_at_distance");
--		end
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnTargetDead	 = function( self, entity )
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"stop_fire");
				
	end,
	---------------------------------------------
	---------------------------------------------
	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

		entity:SelectPipe(0,"cover_scramble");

		-- call default handling
		AIBehaviour.DEFAULT:OnDamage(entity,sender,data);
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity:Readibility("BULLETRAIN_COMBAT");	
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"cover_pindown");
		entity:InsertSubpipe(0,"reload");
	end,
	---------------------------------------------
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
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
	end,	
	
	---------------------------------------------
	SUPRESSED = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	-- nowhere to hide - get down and shoot
	OnBadHideSpot = function ( self, entity, sender,data)
	
	end,

	---------------------------------------------
	-- backed off - let's waite here a bit
	BACKOFF_DONE = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:SelectPipe(0,"cover_scramble");
		entity:InsertSubpipe(0,"random_short_timeout");
	end,
	
	---------------------------------------------
	-- can't back of - path unawailable, go back to attack
	OnNoPathFound = function ( self, entity, sender,data)
		if(entity.backing_to_anchor==nil) then	
			-- try to back off to the anchor
			AI.Signal(SIGNALFILTER_SENDER, 1, "OnNoHidingPlace",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "BACKOFF_DONE",entity.id);		
		end
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,
	

	
	---------------------------------------------
	BACKOFF  = function ( self, entity, sender,data)
	end,

	
	}

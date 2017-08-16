--------------------------------------------------
--   Created By: Dejan
--   Description: This is the hide from tank behaviour
--   Used by the infantry units without grenades or RPG
--   when then have no higher priority targets


AIBehaviour.HBaseHideFromTank = {
	Name = "HBaseHideFromTank",
	alertness = 2,

	Constructor = function (self, entity)
	end,
	
	Destructor = function (self, entity)
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
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnTankSeen = function( self, entity, fDistance )
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
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
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
	-- can't back of - path unawailable, go back to attack
	OnNoPathFound = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,

}

--------------------------------------------------
--   Created By: amanda
--   Description: run to alarm anchor
--------------------------

AIBehaviour.RunToAlarm = {
	Name = "RunToAlarm",
	NOPREVIOUS = 1,
	alertness = 1,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)	
	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
	end,
	

	OnGroupMemberDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,

	EXIT_RUNTOALARM = function (self,entity,sender)
		AI.SetIgnorant(entity.id,0);
		entity:SelectPipe(0,"just_shoot");
		entity:InsertSubpipe(0,"shoot_cover");
	end,
	
}
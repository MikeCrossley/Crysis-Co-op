--------------------------------------------------
--   Created By: petar
--   Description: this is used to run to help a mate who called for help
--------------------------

AIBehaviour.RunToFriend = {
	Name = "RunToFriend",
	NOPREVIOUS = 1,
	alertness = 2,
	
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:SelectPipe(0,"cover_beacon_pindown");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		--entity:InsertSubpipe(0,"check_it_out");
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		entity:TriggerEvent(AIEVENT_CLEAR);
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
	
	---------------------------------------------	
	OnSomebodyDied = function( self, entity, sender)	
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." OnPlayerdied in CoverAttack");
		entity:CheckReinforcements();
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
	---------------------------------------------
	MOVE_IN_FORMATION = function (self, entity, sender)
	end,

	FINISH_RUN_TO_FRIEND = function (self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	
}
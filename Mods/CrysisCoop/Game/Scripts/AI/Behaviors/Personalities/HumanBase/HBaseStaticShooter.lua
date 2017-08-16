--------------------------------------------------
--   Created By: Kirill
--   Description: ignore everything, just stay at current location and shoot when see target


AIBehaviour.HBaseStaticShooter = {
	Name = "HBaseStaticShooter",
	alertness = 2,
	base = "Dumb",

	Constructor = function (self, entity)
--		entity:SelectPipe(0,"camper_fire");
--   	entity:InsertSubpipe(0, "throw_grenade");

		entity:SelectPipe(0,"just_shoot");
		
	end,
	---------------------------------------------
	---------------------------------------------
 	OnQueryUseObject = function ( self, entity, sender, extraData )
 	end,
 	---------------------------------------------
 	
	START_VEHICLE = function(self,entity,sender)
	end,
	---------------------------------------------
--	VEHICLE_REFPOINT_REACHED = function( self,entity, sender )
--		-- called by vehicle when it reaches the reference Point 
--		--entity.AI.theVehicle:SignalCrew("exited_vehicle");
--		AI.Signal(SIGNALFILTER_SENDER,1,"STOP_AND_EXIT",entity.AI.theVehicle.id);
--	end,

	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	
		--AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GunnerLostTarget",entity.id);
		
		--AI.LogEvent("\001 gunner in vehicle lost target ");
		-- caLled when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	
		-- called when the enemy sees a living player
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
		
	end,
	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,
	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------
	OnDeath = function( self,entity )

	end,
	
	---------------------------------------------
	---------------------------------------------	--------------------------------------------------
	-- CUSTOM
	--------------------------------------------
	
	--------------------------------------------------
	SHARED_ENTER_ME_VEHICLE = function( self,entity, sender )
	
	-- in vehicle already - don't do anything

	end,

	--------------------------------------------------

	--------------------------------------------------
	SHARED_LEAVE_ME_VEHICLE = function( self,entity, sender )

	end,

	exited_vehicle = function( self,entity, sender )
--		AI.Signal(0, 1, "DRIVER_OUT",sender.id);
	end,

	
	
	---------------------------------------------
	---------------------------------------------	--------------------------------------------------
	-- old FC stuff - to be revised	
	---------------------------------------------	--------------------------------------------------
	

	exited_vehicle_investigate = function( self,entity, sender )

	end,

	--------------------------------------------
	do_exit_vehicle = function( self,entity, sender )
	end,


	-- no need to run away from cars
	OnVehicleDanger = function(self,entity,sender)
	end,

	EXIT_VEHICLE_STAND = function(self,entity,sender)
	end,
	
	
	ORDER_EXIT_VEHICLE = function(self,entity,sender)
	end,

 	---------------------------------------------
	-- ignore this orders when in vehicle
	ORDER_FOLLOW = function(self,entity,sender)
	end,
	ORDER_HIDE = function(self,entity,sender)
	end,
	ORDER_FIRE = function(self,entity,sender)
	end,

	ACT_FOLLOW = function(self,entity,sender)
	end,

	OnDamage = function(self,entity,sender)
	end,

	OnCloseContact = 	function(self,entity,sender)
	end,

	OnGrenadeSeen = 	function(self,entity,sender)
	end,
	
	OnSomebodyDied = 	function(self,entity,sender)
	end,

	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	KEEP_FORMATION = function (self, entity, sender)
	end,
	---------------------------------------------	
	MOVE_IN_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to move in formation
	end,
	---------------------------------------------	
	BREAK_FORMATION = function (self, entity, sender)
		-- the team can split
	end,
	---------------------------------------------	
	SINGLE_GO = function (self, entity, sender)
		-- the team leader has instructed this group member to approach the enemy
	end,
	---------------------------------------------	
	GROUP_COVER = function (self, entity, sender)
		-- the team leader has instructed this group member to cover his friends
	end,
	---------------------------------------------	
	IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
	end,
	
	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
	end,
	---------------------------------------------	
	PHASE_BLACK_ATTACK = function (self, entity, sender)
		-- team leader instructs black team to attack
	end,
	---------------------------------------------	
	GROUP_MERGE = function (self, entity, sender)
		-- team leader instructs groups to merge into a team again
	end,
	---------------------------------------------	
	CLOSE_IN_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	ASSAULT_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	GROUP_NEUTRALISED = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,	
	---------------------------------------------
	}

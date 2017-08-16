--------------------------------------------------
--    Created By: Petar
--   Description: <short_description>
--------------------------
--

AIBehaviour.Swim = {
	Name = "Swim",
	NOPREVIOUS = 1,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnSpawn = function( self, entity )
		-- called when enemy spawned or reset
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		self:SWIM_TO_ANOTHER_SPOT(entity);
	end,
	---------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
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
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------

	-- GROUP SIGNALS
	---------------------------------------------	
	STOP_SWIMMING = function (self, entity, sender)
		AI:MakePuppetIgnorant(entity.id,0);
		entity.EventToCall = "OnSpawn";
		entity:TriggerEvent(AIEVENT_CLEAR);
		-- the team leader wants everyone to keep formation
	end,

	---------------------------------------------	
	SWIM_TO_ANOTHER_SPOT = function (self, entity, sender)
		local dh = AI:FindObjectOfType(entity.id,30,AIAnchorTable.SWIM_HERE);

		if (dh) then
			entity:SelectPipe(0,"standingthere");
			entity:SelectPipe(0,"swim_inplace");
			entity:InsertSubpipe(0,"swim_to",dh);
		end
	end,

	NOW_DIE = function (self, entity, sender)
		entity:Event_Die(entity);
	end,


}
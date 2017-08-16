--------------------------------------------------
--    Created By: Dejan Pavlovski
--   Description: Vehicle driver and passenger should use this behavior to protect their vehicle
--------------------------
--

AIBehaviour.ProtectVehicle = {
	Name = "ProtectVehicle",

	Constructor = function ( self, entity )
	  AI.LogEvent("Constructor of ProtectVehicle "..entity:GetName());
		
 	  entity:SelectPipe(0, "do_nothing");		-- clear all current goals
--		entity:SelectPipe(0, "protect_vehicle");
		self:SELECT_RANDOM_ANCHOR( entity );
	end,


	SELECT_RANDOM_ANCHOR = function ( self, entity, sender )
		local anchor = AI.GetAnchor(entity.id, AIAnchorTable.HIDE_BEHIND_VEHICLE, 15, AIANCHOR_RANDOM_IN_RANGE);
		if (anchor) then
			anchor = System.GetEntityByName(anchor);
			if (anchor) then
				entity:SelectPipe(0, "protect_vehicle", anchor.id);
				return;
			end
		end
		entity:SelectPipe(0, "protect_vehicle");
	end,
	
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
	end,
	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnSpawn = function( self, entity )
		-- called when enemy spawned or reset
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
	end,
	---------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance <= 40) then
				entity:InsertSubpipe(0, "grenade_seen");
			end
		end
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees something that it cant identify
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
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
}
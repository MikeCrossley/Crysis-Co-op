--------------------------------------------------
--    Created By: Petar
--   Description: 	This gets called when the guy knows something has happened (he is getting shot at, does not know by whom), or he is hit. Basically
--  			he doesnt know what to do, so he just kinda sticks to cover and tries to find out who is shooting him
--------------------------
--

AIBehaviour.MountedGuy = {
	Name = "MountedGuy",
	NOPREVIOUS = 1,
	alertness = 2,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	--------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player

		if (entity.AI_AtWeapon) then
			if (fDistance>7) then 
				entity:SelectPipe(0,"use_mounted_weapon");
			else
				if(entity.current_mounted_weapon) then
					entity.current_mounted_weapon:AbortUse();
				end					
				entity:TriggerEvent(AIEVENT_CLEAR);
				AI.Signal(0,1,"RETURN_TO_NORMAL",entity.id);
				entity.AI_AtWeapon = nil;
			end
		else
			entity:SelectPipe(0,"goto_mounted_weapon");
			--entity.AI_AtWeapon = 1;
		end
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
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
	OnGroupMemberDiedNearest = function( self, entity )
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
	--------------------------------------------------
	HEADS_UP_GUYS = function ( self, entity, sender)
	end,
	--------------------------------------------------
	KEEP_FORMATION = function ( self, entity, sender)
	end,


	
	RETURN_TO_NORMAL = function ( self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
		entity:SelectPipe(0,"just_shoot");
		if(entity.current_mounted_weapon) then
			entity.current_mounted_weapon:AbortUse();
		end	
	end,


	USE_MOUNTED_WEAPON = function (self, entity, sender)
		
		AI.SetIgnorant(entity.id,0);
	
		local mounted = AI.FindObjectOfType(entity.id,3,AIOBJECT_MOUNTEDWEAPON);

		if (mounted) then		
	
			local gun = System.GetEntityByName(mounted);

			if (gun.user) then	
				AI.Signal(0,1,"RETURN_TO_NORMAL",entity.id);
				do return end
			end

			if (gun) then
				gun:SetGunner( entity );
			end

			entity.AI_AtWeapon = 1;
	
			entity:SelectPipe(0,"use_mounted_weapon");
		else
			AI.Signal(0,1,"RETURN_TO_NORMAL",entity.id);
		end
		
	end,


}
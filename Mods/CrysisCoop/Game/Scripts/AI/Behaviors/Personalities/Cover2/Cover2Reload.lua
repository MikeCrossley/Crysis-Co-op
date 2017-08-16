--------------------------------------------------
--    Created By: Mikko
--   Description: Handle reloading during combat.
--------------------------
--

AIBehaviour.Cover2Reload = {
	Name = "Cover2Reload",
	alertness = 2,

	-----------------------------------------------------
	Constructor = function(self,entity)

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING); --GN_NOTIFY_UNAVAIL);

		entity:GettingAlerted();
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 0);

--		Log(entity:GetName().." Out of ammo");

		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
		local range = entity.Properties.preferredCombatDistance/2;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
		end
		
		if(target==AITARGET_ENEMY and targetDist < range and random(1,10) < 4 and not entity.AI.lastOutOfAmmoMelee) then
--		if(target==AITARGET_ENEMY and not entity.AI.lastOutOfAmmoMelee) then
			--Log(" - melee");
			-- Try melee
			entity.AI.lastPlayerLookingTime = _time + 5.0;
			entity.AI.lastFriendInWayTime = _time + 5.0;
			entity:SelectPipe(0,"melee_far_during_reload");
			entity.AI.lastOutOfAmmoMelee = true;
		elseif(entity:CheckCurWeapon( ) == 1) then
			-- ran out of ammo on secondary weapon, run to cover
			-- Just reloaded secondary weapon, choose primary too and make sure it is loaded too.
--			entity:SelectPrimaryWeapon();
			-- goto cover and reload more
			entity:SelectPipe(0,"sn_take_cover_reload");
			entity.AI.tryingToReload = true;
			entity.AI.lastOutOfAmmoMelee = false;
		else
			-- Reload
--			Log(" - try reload in cover");
			entity:SelectPipe(0,"sn_take_cover_reload");
			entity.AI.tryingToReload = true;
			entity.AI.lastOutOfAmmoMelee = false;
		end
		
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
	end,
	---------------------------------------------
	OnTargetFleeing	= function (self, entiTy)
	end,
	--------------------------------------------------
	OnAdvanceTargetCompromised = function(self, entity, sender, data)
	end,
	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
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
	OnThreateningSeen = function( self, entity )
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender, data )
		entity:Readibility("ai_down",1,1,0.3,0.6);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id, data );
	end,
	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
	end,
	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		entity:Readibility("taking_fire",1);
		-- avoid this poit for some time.
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 2);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 15);
		end
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	end,
	------------------------------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self,entity,sender)
	end,
	---------------------------------------------
	OnBadHideSpot = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
	end,	
	--------------------------------------------------
	OnOutOfAmmo = function (self,entity, sender)
		-- trying to reload while... trying to reload, just do it!
--		Log(" - reload now");
--		entity:Readibility("reloading",1);
--		AI_Utils:SafeReload(entity);
--		if(target == AITARGET_ENEMY or target == AITARGET_MEMORY) then
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
--		else
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
--		end
	end,

	------------------------------------------------------------------------
	DO_MELEE = function(self,entity,sender)
		if(AI.GetAttentionTargetDistance(entity.id) < 3.0) then
			local	enemyName = AI.GetAttentionTargetOf(entity.id);
			if(enemyName) then
				entity:Readibility("taunt",1,3,0.1,0.4);
				local enemy = System.GetEntityByName(enemyName);
				AI_Utils:AlienMeleePush(entity, enemy, 500.0)
			end
		end
	end,
	
	------------------------------------------------------------------------
	HANDLE_RELOAD = function(self,entity,sender)
		entity:SelectPipe(0,"do_nothing");
		entity:Readibility("reloading",1,3, 0.0,0.2);
		entity:Reload();
	end,

	------------------------------------------------------------------------
	PRI_WEAPON_SELECTED = function(self,entity)
--		entity:SelectPipe(0,"sn_use_cover_reload");
		entity:SelectPipe(0,"do_nothing");
		entity:Readibility("reloading",1,3, 0.0,0.2);
		entity:Reload();
		entity.AI.tryingToReload = true;
	end,

	---------------------------------------------
	SELECT_PRI_WEAPON = function (self, entity)
		Log(entity:GetName().." SELECT_PRI_WEAPON");
		entity:SelectPrimaryWeapon();
	end,

	------------------------------------------------------------------------
	RELOAD_PAUSE_DONE = function(self,entity)
		local target = AI.GetTargetType(entity.id);

		if(target ~= AITARGET_ENEMY and entity:CheckCurWeapon( ) == 1) then
			-- Reload done and target not visible, switch to primary weapon and reload.
			-- Just reloaded secondary weapon, choose primary too and make sure it is loaded too.
			entity:SelectPipe(0,"sn_change_primary_weapon_pause");
		else
		
			if (entity.AI.reloadReturnToSeek and entity.AI.reloadReturnToSeek == true) then
				entity.AI.reloadReturnToSeek = nil;
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
			else
				local target = AI.GetTargetType(entity.id);
				if (target == AITARGET_ENEMY) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
				elseif (target == AITARGET_MEMORY) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SEEK",entity.id);
				else
					if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
						entity.AI.hurryInStandby = 0;
						AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
					else
						AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
					end
				end
			end
		end

	end,

	------------------------------------------------------------------------
	OnReloadDone = function(self,entity)

		entity:SelectPipe(0,"sn_reload_pause");

	end,

	--------------------------------------------------
	OnFriendInWay = function(self, entity)
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		-- no automatic melee on close contact when reloading
	end,
}

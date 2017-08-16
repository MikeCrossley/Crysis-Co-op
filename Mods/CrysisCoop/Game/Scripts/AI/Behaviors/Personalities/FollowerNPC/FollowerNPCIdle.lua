
AIBehaviour.FollowerNPCIdle = {
	Name = "FollowerNPCIdle",
	alertness = 0,
	
	-----------------------------------------------------
	Constructor = function (self, entity)

		if (not entity.AI.noRelax) then
			entity:InitAIRelaxed();
		end
		entity.AI.noRelax = nil;

		AI.ChangeParameter(entity.id, AIPARAM_COMBATCLASS, AICombatClasses.FriendlyNPC);

		AI.SetPFBlockerRadius(entity.id, PFB_PLAYER, 2);


		AI.NotifyGroupTacticState(entity.id, 1, GN_INIT);

		entity.AI.following = false;
		entity.AI.followDistance = 0;
		entity:SelectPipe(0,"do_nothing");
		AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_UNAVAIL);

		entity.AI.allowedToFire = false;
		entity.AI.heavyWeapon = false;
		entity.AI.bulletReactionTime = _time - 10.0;
		entity.AI.meleeBlockTime = _time;

	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		if (fDistance < 6.0) then
			entity.AI.allowedToFire = true;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		end
	end,

	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,

	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	

	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender, data)

		if(data.id == g_localActor.id) then 
		
			local health = entity.actor:GetHealth();
			local maxHealth = entity.actor:GetMaxHealth();
		
			if (health < maxHealth * 0.9) then
				entity:Readibility("friendly_fire",1,2, 0.6,1);
--				AI.Signal(SIGNALFILTER_GROUPONLY, 1, "SHOT_BY_PLAYER", entity.id);

--				AI.ChangeParameter(entity.id, AIPARAM_SPECIES, 5);
--				AI.ChangeParameter(entity.id, AIPARAM_GROUPID, 1);
			end
		end
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)

		entity:Readibility("taking_fire",1,2, 0.3,0.5);
		entity:GettingAlerted();

		local dt = _time - entity.AI.bulletReactionTime;
		if (dt > 6.0) then
			entity:SelectPipe(0,"fl_simple_bulletreaction");
			entity.AI.bulletReactionTime = _time;
		else
			self:CheckWeapon(entity);
			if (entity.AI.following == false) then
				entity:SelectPipe(0,"fl_just_shoot");
			else
				if (entity.AI.allowedToFire == false) then
					if (entity.AI.heavyWeapon == true) then
						entity:SelectPipe(0,"fl_combat_follow_heavy");
					else
						entity:SelectPipe(0,"fl_combat_follow");
					end
				end
			end
		end
		entity.AI.allowedToFire = true;

	end,

	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
		-- only react to hostile bullets.
		entity:Readibility("bulletrain",1,2, 0.1,0.4);
	end,

	---------------------------------------------
	OnPlayerTeamKill = function(self,entity,sender,data)
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
--		AIBehaviour.FriendlyNPCIdle:OnNearMiss(entity,sender);
		entity:Readibility("bulletrain",1,2, 0.1,0.4);
	end,

	--------------------------------------------------
	OnCollision = function(self,entity,sender,data)
	end,	
	
	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)

		-- Do melee at close range.
		local dt = _time - entity.AI.meleeBlockTime;
		if(AI.CanMelee(entity.id) and dt > 7.0) then
--			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );
--			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 40);
--			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 100);
--			AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);
			entity:SelectPipe(0,"fl_melee");
			entity.AI.meleeBlockTime = _time;
		else
			if (entity.AI.following == true) then
				if (entity.AI.allowedToFire == false) then
					if (entity.AI.heavyWeapon == true) then
						entity:SelectPipe(0,"fl_combat_follow_heavy");
					else
						entity:SelectPipe(0,"fl_combat_follow");
					end
				end
			end
		end
		entity.AI.allowedToFire = true;
	end,

	---------------------------------------------
	OnMeleeExecuted = function (self, entity)
		entity:SelectPipe(0,"fl_melee_pause");
	end,

	---------------------------------------------
	MELEE_DONE = function (self, entity)
		self:ContinueCombat(entity);
	end,

	--------------------------------------------------
	OnGroupMemberDied = function(self, entity, sender, data)
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function(self, entity, sender, data)
	end,

	---------------------------------------------
	OnShapeEnabled = function (self, entity, sender, data)
	end,

	--------------------------------------------------
	OnCallReinforcements = function (self, entity, sender, data)
	end,

	--------------------------------------------------
	OnGroupChanged = function (self, entity)
	end,

	--------------------------------------------------
	OnExposedToFlashBang = function (self, entity, sender, data)
--		entity:SelectPipe(0,"su_fast_threat_reaction");
--
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
--
		if (data.iValue == 1) then
			-- near
			entity:SelectPipe(0,"sn_flashbang_reaction_flinch");
		else
			-- visible
			entity:SelectPipe(0,"sn_flashbang_reaction");
		end
	end,

	--------------------------------------------------
	FLASHBANG_GONE = function (self, entity)
		self:ContinueCombat(entity);
	end,

	--------------------------------------------------
	OnExposedToSmoke = function (self, entity)
		entity:Readibility("cough",1,115, 0.1,4.5);
	end,

	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
		if (entity.AI.following == true) then
			entity:SelectPipe(0,"fl_simple_flinch");
		end
--		entity:Readibility("incoming",0);
--		entity:SelectPipe(0,"su_fast_threat_reaction");
	end,

	---------------------------------------------
	OnGroupMemberMutilated = function(self, entity)
	end,

	---------------------------------------------
	OnTargetCloaked = function(self, entity)
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		-- player would not have Reload implemented
		if (entity.Reload == nil) then
--			System.Log("  - no reload available");
			do return end
		end
		entity:Reload();
	end,

	---------------------------------------------
	OnGrenadeDanger = function( self, entity, sender, signalData )	
		if (entity.AI.following == true) then
			local dist = AI.SetRefPointToGrenadeAvoidTarget(entity.id, signalData.point, 15.0);
			if (dist > 0.0) then
				entity:SelectPipe(0,"cv_backoff_from_explosion");
				entity:Readibility("incoming",0,5);
			end
		end
	end,

	---------------------------------------------
	END_BACKOFF = function(self, entity, data)
		self:ContinueCombat(entity);
	end,
	
	---------------------------------------------
	ContinueCombat = function(self, entity)
		if (entity.AI.following == true) then
			AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_ADVANCING, entity.AI.followDistance);
			self:CheckWeapon(entity);
			if (entity.AI.allowedToFire == true) then
				if (entity.AI.heavyWeapon == true) then
					entity:SelectPipe(0,"fl_combat_follow_heavy");
				else
					entity:SelectPipe(0,"fl_combat_follow");
				end
			else
				entity:SelectPipe(0,"fl_simple_follow");
			end
			entity:Readibility("ok_movement_whispered",1,3, 0.6,1);
		else
			entity:SelectPipe(0,"do_nothing");
			AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_UNAVAIL);
		end
	end,

	---------------------------------------------
	OnCloseCollision = function(self, entity, data)
		if (entity.AI.following == true) then
			entity:SelectPipe(0,"fl_simple_flinch");
		end
	end,

	---------------------------------------------
	OnFollowTargetFired = function(self, entity, data)
		if (entity.AI.following == true) then
			if (entity.AI.allowedToFire == false) then
				self:CheckWeapon(entity);
				if (entity.AI.heavyWeapon == true) then
					entity:SelectPipe(0,"fl_combat_follow_heavy");
				else
					entity:SelectPipe(0,"fl_combat_follow");
				end
			end
		end
		entity.AI.allowedToFire = true;
	end,

	---------------------------------------------
	FOLLOW_START = function(self, entity, sender, data)
		entity.AI.following = true;

		entity:DrawWeaponNow();

--		if (entity.AI.allowedToFire == true) then
--			entity:SelectPipe(0,"fl_combat_follow");
--		else
--			entity:SelectPipe(0,"fl_simple_follow");
--		end
		entity.AI.followDistance = data.fValue;
--		AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_ADVANCING, data.fValue);
--		self:CheckWeapon(entity);

		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
	end,
		
	---------------------------------------------
	CheckWeapon = function(self, entity)

		local currentWeapon = entity.inventory:GetCurrentItem();
		if (currentWeapon == nil) then return nil end
--		System.Log("weapon class: "..currentWeapon.class);
		if (currentWeapon.class == "AlienMount" or currentWeapon.class == "Hurricane") then

			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 30);
			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 25);
			AI.ChangeParameter(entity.id, AIPARAM_LOOKIDLE_TURNSPEED, 30);
			AI.ChangeParameter(entity.id, AIPARAM_LOOKCOMBAT_TURNSPEED, 40);
			entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
			AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);
			entity.AI.heavyWeapon = true;
		else

			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, entity.AIMovementAbility.aimTurnSpeed);
			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, entity.AIMovementAbility.fireTurnSpeed);
			AI.ChangeParameter(entity.id, AIPARAM_LOOKIDLE_TURNSPEED, entity.AIMovementAbility.lookIdleTurnSpeed);
			AI.ChangeParameter(entity.id, AIPARAM_LOOKCOMBAT_TURNSPEED, entity.AIMovementAbility.lookCombatTurnSpeed);
			entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
			AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);
			entity.AI.heavyWeapon = false;
		end	
		
	end,

	---------------------------------------------
	FOLLOW_STOP = function(self, entity, data)
	
		entity:HolsterItem(true);
	
		entity.AI.following = false;
		entity:SelectPipe(0,"do_nothing");
		AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_UNAVAIL);

		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, entity.AIMovementAbility.aimTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, entity.AIMovementAbility.fireTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKIDLE_TURNSPEED, entity.AIMovementAbility.lookIdleTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKCOMBAT_TURNSPEED, entity.AIMovementAbility.lookCombatTurnSpeed);
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
		AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);

		entity.AI.noRelax = 1; -- do not change to relaxed in constructor
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE",entity.id);

	end,

	---------------------------------------------
	FOLLOW_STOP_NOHOLSTER = function(self, entity, data)
	
		entity.AI.following = false;
		entity:SelectPipe(0,"do_nothing");
		AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_UNAVAIL);

		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, entity.AIMovementAbility.aimTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, entity.AIMovementAbility.fireTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKIDLE_TURNSPEED, entity.AIMovementAbility.lookIdleTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKCOMBAT_TURNSPEED, entity.AIMovementAbility.lookCombatTurnSpeed);
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
		AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);

		entity.AI.noRelax = 1; -- do not change to relaxed in constructor
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE",entity.id);

	end,

	---------------------------------------------
	OnFallAndPlayWakeUp = function( self, entity )
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);

--		local following = entity.AI.following;
--		local allowedToFire = entity.AI.allowedToFire;
--		local heavyWeapon = entity.AI.heavyWeapon;
--		local followDistance = entity.AI.followDistance;

--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE",entity.id);	-- switch behavior

--		AI.NotifyGroupTacticState(entity.id, 1, GN_NOTIFY_ADVANCING, followDistance);

--		entity.AI.following = following;
--		entity.AI.allowedToFire = allowedToFire;
--		entity.AI.heavyWeapon = heavyWeapon;
--		entity.AI.followDistance = followDistance;
	
--		self:ContinueCombat(entity);

	end,

}

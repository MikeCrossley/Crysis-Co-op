--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Test
--  
--------------------------------------------------------------------------
--  History:
--------------------------------------------------------------------------

AIBehaviour.GuardNeueIdle = {
	Name = "GuardNeueIdle",
	Base = "GUARDDEFAULT",
	alertness = 0,

	---------------------------------------------
	Constructor = function(self,entity,data)

--		AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 10);

		entity.AI.dodgeHealthDec = entity.actor:GetMaxHealth() / 4;
		entity.AI.dodgeHealthThr = entity.actor:GetHealth() - entity.AI.dodgeHealthDec;
		

		entity.AI.blocking = 0;
		entity.AI.allowMelee = 1;
		entity.AI.allowDodge = 1;

		entity.AI.lastHideTime = _time - 10;
		entity.AI.lastDodgeTime = _time - 10;

		entity.AI.noThreaten = 0;

		-- See if weapon is awailable
		entity.AI.hasWeapon = 0;
		local weaponId = entity.inventory:GetItemByClass(entity.primaryWeapon);
		if(weaponId ~= nil) then
			entity.AI.hasWeapon = 1;
		end

	end,

	---------------------------------------------
	Destructor = function(self , entity )
		-- remove melee flag
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		AI.SetPFBlockerRadius(entity.id, PFB_BETWEEN_NAV_TARGET, 10);

		local	attPos = g_Vectors.temp_v1;
		AI.GetAttentionTargetPosition(entity.id, attPos);
		local targetShape = AI.GetEnclosingGenericShapeOfType(attPos, AIAnchorTable.ALERT_STANDBY_IN_RANGE, 1);
		if (targetShape) then
--			System.Log("###targetShape="..targetShape);
			if (entity.AI.hasWeapon == 1) then
				entity:Readibility("scare",1, 2);
				entity:SelectPipe(0,"grn_RangeAttackLong");
			else
				if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0) == 1) then
					entity:Readibility("threaten",1, 2, 0,3);
					entity:SelectPipe(0,"do_nothing");
					entity:SelectPipe(0,"grn_AlienHide");
					entity.AI.blocking = 1;
				end
			end
		else
			if (entity.AI.noThreaten and entity.AI.noThreaten == 1) then
	
				local dist = AI.GetAttentionTargetDistance(entity.id);
	
				if (dist < 10) then
					entity:Readibility("scare",1, 115);
					entity:SelectPipe(0,"grn_MeleeShort");
					AI.SetPFBlockerRadius(entity.id, PFB_BETWEEN_NAV_TARGET, 0);  -- special case, remove nav blocker.
				else
					entity:Readibility("scare",1, 3);
					entity:SelectPipe(0,"grn_Melee");
				end

				entity.AI.allowMelee = 1;
				entity.AI.blocking = 1;
			else
				if (entity.AI.blocking == 0) then
					local dt = _time - AIBehaviour.GuardNeueCombat.lastMeleeTime;
					if (dt > AIBehaviour.GuardNeueCombat.meleeFrequency and entity.AI.allowMelee == 1) then

						if (entity.AI.hasWeapon == 1) then
							entity:Readibility("scare",1, 2);
							entity:SelectPipe(0,"grn_RangeAttack");
						else
							entity:Readibility("scare",1, 3);
							entity:SelectPipe(0,"grn_MeleePause");
						end
						entity.AI.allowMelee = 1;
						entity.AI.blocking = 1;
		
						AIBehaviour.GuardNeueCombat.lastMeleeTime = _time;
					else
						if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0) == 1) then
							entity:Readibility("threaten",1, 2, 0,3);
							entity:SelectPipe(0,"do_nothing");
							entity:SelectPipe(0,"grn_AlienHide");
							entity.AI.blocking = 1;
						else
							-- cannot hide, melee
							if (entity.AI.hasWeapon == 1) then
								entity:Readibility("scare",1, 2);
								entity:SelectPipe(0,"grn_RangeAttack");
							else
								entity:Readibility("scare",1, 3);
								entity:SelectPipe(0,"grn_MeleePause");
							end
							entity.AI.allowMelee = 1;
							entity.AI.blocking = 1;
							AIBehaviour.GuardNeueCombat.lastMeleeTime = _time;
						end
					end
				end
			end
		end
		
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_COMBAT",entity.id);
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity, fDistance )
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if (entity.AI.blocking == 0) then
--			System.Log("OnThreateningSoundHeard "..entity:GetName());
			entity:Readibility("curious",1, 1);
			entity:SelectPipe(0,"grn_MoveToAttTarget");
			entity.AI.allowMelee = 1;
		end
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnEnemyDamage = function (self,entity,sender,data)

		local targetDist = 100000;
		if (AI.GetTargetType(entity.id) ~= AITARGET_NONE) then
			targetDist = AI.GetAttentionTargetDistance(entity.id);
		end

		if (entity.AI.allowMelee == 1) then
			local health = entity.actor:GetHealth();
--			System.Log(">>>OnEnemyDamage "..entity:GetName()..": melee=1 health="..health.." thr="..entity.AI.dodgeHealthThr);
--			if (targetDist < 5.0) then
--				if (health < (entity.AI.dodgeHealthThr + entity.AI.dodgeHealthDec/2)) then
--					entity.AI.dodgeHealthThr = entity.AI.dodgeHealthThr - entity.AI.dodgeHealthDec/2;
--					self:Hide(entity);
--					return;
--				end
--			else
				if (health < entity.AI.dodgeHealthThr) then
					entity.AI.dodgeHealthThr = entity.AI.dodgeHealthThr - entity.AI.dodgeHealthDec;
					self:Hide(entity);
					return;
				end
--			end
			
			if (entity.AI.allowDodge == 1) then
				-- The damage thr was not crossed, just dodge to the side.
				local dt = _time - entity.AI.lastDodgeTime;
				if (dt > 1.5) then
				
					local sound = GetRandomSound(entity.voiceTable.accelerate);
					entity.actor:PlayNetworkedSoundEvent(sound[1], g_Vectors.v000, g_Vectors.v010, SOUND_DEFAULT_3D, SOUND_SEMANTIC_LIVING_ENTITY);
				
					entity:SelectPipe(0,"grn_MeleeDodge");
					entity.AI.lastDodgeTime = _time;
					return;
				end
			end
			
		else

			if (entity.AI.allowDodge == 1) then
				local dt = _time - entity.AI.lastDodgeTime;
				if (dt > 2.5) then
				
					local sound = GetRandomSound(entity.voiceTable.accelerate);
					entity.actor:PlayNetworkedSoundEvent(sound[1], g_Vectors.v000, g_Vectors.v010, SOUND_DEFAULT_3D, SOUND_SEMANTIC_LIVING_ENTITY);
				
					entity:SelectPipe(0,"grn_HideDodge");
					entity.AI.lastDodgeTime = _time;
					return;
				end
			end

			local dt = _time - entity.AI.lastDodgeTime;
--			System.Log(">>>OnEnemyDamage "..entity:GetName()..": melee=0 dt="..dt);
			if ((dt > 3.0 and targetDist < 10.0) or dt > 15.0) then
				self:Hide(entity);
			end
		end
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		if (entity.AI.allowMelee == 0) then
			local dt = _time - entity.AI.lastHideTime;
--			System.Log(">>>OnBulletRain "..entity:GetName()..": melee=0 dt="..dt);
			if (dt > 15.0) then
				self:Hide(entity);
			end
		end
	end,

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,

	--------------------------------------------------
	Hide = function(self, entity)
--		System.Log(">>>Dodge "..entity:GetName());
		if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0)) then
			entity:SelectPipe(0,"grn_AlienHide");		
			entity.AI.blocking = 1;
			entity.AI.allowMelee = 0;
			entity.AI.lastHideTime = _time;
		end
	end,

	---------------------------------------------
	CONTINUE_MELEE = function (self, entity)
--		entity:Readibility("anticipation",1, 6);
		if (entity.AI.hasWeapon == 1) then
			entity:SelectPipe(0,"grn_RangeAttack");
		else
			entity:SelectPipe(0,"grn_Melee");		
		end
	end,

	---------------------------------------------
	CONTINUE_HIDE = function (self, entity)
		self:Hide(entity);
	end,

	---------------------------------------------
	TRACK_TARGET = function (self, entity)
		entity:Readibility("anticipation",1, 6);

--		System.Log("TRACK_TARGET (idle) "..entity:GetName());
		entity:SelectPipe(0,"grn_MoveToAttTarget");		
		entity.AI.allowMelee = 1;

		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_COMBAT",entity.id);
	end,

	---------------------------------------------
	NO_THREATEN = function (self, entity)
		entity.AI.noThreaten = 1;
	end,

	---------------------------------------------
	CHECK_MELEE = function (self, entity)
		
		if (AI.IsAgentInTargetFOV(entity.id, 50.0) == 0) then
--			System.Log("*************************** CHECK_MELEE "..entity:GetName());
			entity:SelectPipe(0,"grn_MeleeShortPause");		
		end
		
		entity.AI.allowDodge = 0;
	end,

	---------------------------------------------
	BLOCK_DODGE = function (self, entity)
		entity.AI.allowDodge = 0;
	end,

	---------------------------------------------
	UNBLOCK_DODGE = function (self, entity)
		entity.AI.allowDodge = 1;
	end,

	---------------------------------------------
	ACC_READABILITY = function (self, entity)
		local sound = GetRandomSound(entity.voiceTable.accelerate);
		entity.actor:PlayNetworkedSoundEvent(sound[1], g_Vectors.v000, g_Vectors.v010, SOUND_DEFAULT_3D, SOUND_SEMANTIC_LIVING_ENTITY);
	end,

	---------------------------------------------
	MARK_HIDESPOT_UNREACHABLE = function (self, entity)
		AI.MarkAlienHideSpotUnreachable(entity.id);
	end,

}

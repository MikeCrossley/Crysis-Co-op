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

AIBehaviour.GuardNeueCombat = {
	Name = "GuardNeueCombat",
	Base = "GuardNeueIdle",
	alertness = 2,

	lastMeleeTime = 0,
	meleeFrequency = 4.0,

	---------------------------------------------
	Constructor = function(self,entity,data)

--		AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 3);

--		AI.SetPFBlockerRadius(entity.id, PFB_REF_POINT, 15);

		-- Hack... the stuff in idle constructor does not seem to be always called... I bet autodisable.
		entity.AI.dodgeHealthDec = entity.actor:GetMaxHealth() / 4;
		entity.AI.dodgeHealthThr = entity.actor:GetHealth() - entity.AI.dodgeHealthDec;

		entity.AI.lastDodgeTime = _time - 10;

	end,

	---------------------------------------------
	Destructor = function(self , entity )
		-- remove melee flag
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	
		if (entity.AI.blocking == 0) then
		
			AI.SetPFBlockerRadius(entity.id, PFB_BETWEEN_NAV_TARGET, 10);
		
			local	attPos = g_Vectors.temp_v1;
			AI.GetAttentionTargetPosition(entity.id, attPos);
			local targetShape = AI.GetEnclosingGenericShapeOfType(attPos, AIAnchorTable.ALERT_STANDBY_IN_RANGE, 1);
			if (targetShape) then
--				System.Log("###targetShape="..targetShape);
				if (entity.AI.hasWeapon == 1) then
					entity:Readibility("scare",1, 2);
					entity:SelectPipe(0,"grn_RangeAttack");
					entity.AI.dodgeHealthThr = entity.actor:GetHealth() - entity.AI.dodgeHealthDec;
				else
					if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0) == 1) then
						entity:Readibility("threaten",1, 2, 0,3);
						entity:SelectPipe(0,"do_nothing");
						entity:SelectPipe(0,"grn_AlienHide");
						entity.AI.blocking = 1;
					end
				end
			else
			
				local dt = _time - AIBehaviour.GuardNeueCombat.lastMeleeTime;
				if (dt > AIBehaviour.GuardNeueCombat.meleeFrequency and entity.AI.allowMelee == 1) then

					if (entity.AI.hasWeapon == 1) then
						entity:Readibility("scare",1, 3);
						entity:SelectPipe(0,"grn_RangeAttack");
					else
						if (AI.GetAttentionTargetDistance(entity.id) < 15.0) then
							entity:Readibility("scare",1, 115);
							entity:SelectPipe(0,"grn_MeleePause");
						else
							entity:Readibility("scare",1, 3);
							entity:SelectPipe(0,"grn_Melee");
						end

					end
					entity.AI.dodgeHealthThr = entity.actor:GetHealth() - entity.AI.dodgeHealthDec;

					entity.AI.allowMelee = 1;
					entity.AI.blocking = 1;
					AIBehaviour.GuardNeueCombat.lastMeleeTime = _time;

				else
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
				end
			end
		end
	end,

	---------------------------------------------
	TARGET_CLOSE = function(self, entity)
		self:OnPlayerSeen(entity);
	end,

	---------------------------------------------
--	START_MELEE = function(self, entity)
		--AIBehaviour.GUARDDEFAULT:StartMeleeAttack(entity);
--		entity:SelectPipe(0,"grn_Melee");
--	end,

	---------------------------------------------
	THREATEN_READ = function(self, entity)
		entity:Readibility("scare_close",1, 6);
	end,

	---------------------------------------------
	UNBLOCK = function(self, entity)
		entity.AI.blocking = 0;
		entity.AI.allowMelee = 1;
		local target = AI.GetTargetType(entity.id);
		if (target == AITARGET_ENEMY) then
			if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0) == 1) then
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"grn_AlienHide");		
				entity.AI.blocking = 1;
			else
				-- cannot hide, melee
				if (entity.AI.hasWeapon == 1) then
					entity:Readibility("scare",1, 3);
					entity:SelectPipe(0,"grn_RangeAttack");
				else
					entity:Readibility("scare",1, 3);
					entity:SelectPipe(0,"grn_Melee");
				end
				entity.AI.dodgeHealthThr = entity.actor:GetHealth() - entity.AI.dodgeHealthDec;

				entity.AI.allowMelee = 1;
				entity.AI.blocking = 1;
				AIBehaviour.GuardNeueCombat.lastMeleeTime = _time;
				
			end
		else
--			entity:SelectPipe(0,"do_nothing");
		end
	end,
	
	---------------------------------------------
	END_ATTACK = function (self, entity)

		entity.AI.allowDodge = 1;
		
		if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0)) then
			entity:SelectPipe(0,"grn_AlienHide");
			entity.AI.blocking = 1;
			entity.AI.allowMelee = 0;
		else
			entity:SelectPipe(0,"do_nothing");
			entity.AI.blocking = 0;
		end
	end,

	---------------------------------------------
	SEEK_TARGET = function (self, entity)
		entity:Readibility("anticipation",1, 3);
		if (AI.SetRefpointToAlienHidespot(entity.id, 10.0, 150.0)) then
			entity:SelectPipe(0,"grn_SeekHide");		
		end
	end,
	
	---------------------------------------------
	TRACK_TARGET = function (self, entity)
		entity:Readibility("anticipation",1, 6);

--		System.Log("TRACK_TARGET "..entity:GetName());
		entity:SelectPipe(0,"grn_MoveToAttTarget");		
		
		entity.AI.blocking = 0;
		entity.AI.allowMelee = 1;
	end,
	
	---------------------------------------------
	OnNoTargetVisible = function (self, entity)

--		System.Log("OnNoTargetVisible "..entity:GetName());
		entity:SelectPipe(0,"grn_MoveToAttTarget");
		
		entity.AI.blocking = 0;
		entity.AI.allowMelee = 1;
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

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,

}

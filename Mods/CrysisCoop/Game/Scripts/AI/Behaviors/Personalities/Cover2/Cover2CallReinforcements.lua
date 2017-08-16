--------------------------------------------------
--    Created By: Mikko
--   Description: Handle calling reinforcements during combat.
--------------------------
--

AIBehaviour.Cover2CallReinforcements = {
	Name = "Cover2CallReinforcements",
	alertness = 1,
	exclusive = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);

		entity:GettingAlerted();
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 0);

		entity.AI.reinfLastHide = _time - 5;

		self:SETUP_REINF(entity);

	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
		entity.AI.reinfSpotId = nil;
		entity.AI.reinfType = nil;
		entity.AI.reinfLastHide = nil;
		
		AI.NotifyReinfDone(entity.id, 0);
		
		-- Make sure we have the primary weapon selected.
		entity:SelectPrimaryWeapon();
	end,

	-----------------------------------------------------
	SETUP_REINF = function(self, entity)
		
		if (entity.AI.reinfType == nil) then
			self:ContinueAfterReinf(entity);
			return;
		end

		local spot = System.GetEntity(entity.AI.reinfSpotId);
		if (not spot) then
			AI.LogEvent("Warning: "..entity:GetName().." Cannot find entity mathing entity id ("..tostring(entity.AI.reinfSpotId)..").");
			self:ContinueAfterReinf(entity);
			return;
		end

		if (entity.AI.reinfType == 0) then
			-- Wave
			AI.SetRefPointPosition(entity.id, spot:GetPos());
			AI.SetRefPointDirection(entity.id, spot:GetDirectionVector(1));
			AI.SetRefPointRadius(entity.id, spot.Properties.AvoidWhenTargetInRadius);
			entity:SelectPipe(0,"sn_callreinf_wave");
		elseif (entity.AI.reinfType == 1) then
			-- Radio
			entity:SelectPipe(0,"sn_callreinf_radio");
			entity.AI.reinfType = nil;
		elseif (entity.AI.reinfType == 2) then
			-- Flare
			AI.SetRefPointPosition(entity.id, spot:GetPos());
			AI.SetRefPointDirection(entity.id, spot:GetDirectionVector(1));
			AI.SetRefPointRadius(entity.id, spot.Properties.AvoidWhenTargetInRadius);
			entity:SelectPipe(0,"sn_callreinf_flare");
		elseif (entity.AI.reinfType == 3) then
			-- Smoke grenade
			if (AI_Utils:CanThrowGrenade(entity, 1) == 1) then			
				AI.SetRefPointPosition(entity.id, spot:GetPos());
				entity:SelectPipe(0,"sn_throw_grenade_smoke");
--			AI.NotifyReinfDone(entity.id, 1);				
			else
				AI.NotifyReinfDone(entity.id, 0);			
				entity.AI.reinfSpotId = nil;
				self:REINF_DONE(entity);
			end	
		end
	end,
	
	---------------------------------------------
	CHOOSE_PISTOL = function (self, entity)
		local pistolId = entity.inventory:GetItemByClass("SOCOM");
		-- see if pistol weapon is awailable
		if (pistolId) then
			entity.actor:SelectItemByName("SOCOM");
		end
	end,
	
	---------------------------------------------
	DO_FLARE	= function (self, entity)
		-- Use hard coded values since the bone position cannot be trusted when the
		-- character is not rendered.
		local pos = entity:GetPos();
		pos.z = pos.z + 1.9;
		local dir = entity:GetDirectionVector(1);
		dir.x = dir.x * 0.2;
		dir.y = dir.y * 0.2;
		dir.z = dir.z * 0.2;
		dir.z = 0.99;
		Particle.SpawnEffect("explosions.flare.a", pos, dir, 1.0);
	end,

	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
	end,
	---------------------------------------------
	OnTargetFleeing	= function (self, entiTy)
	end,
	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		if (data.iValue == AITSR_SEE_STUNT_ACTION) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			AI_Utils:ChooseStuntReaction(entity);
		elseif (data.iValue == AITSR_SEE_CLOAKED) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			entity:SelectPipe(0,"sn_target_cloak_reaction");
		end
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
		local dt = _time - entity.AI.reinfLastHide;
		if (dt > 5.0) then
			entity:SelectPipe(0,"sn_callreinf_short_hide");
			entity.AI.reinfLastHide = _time;
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
	------------------------------------------------------------------------
	OnReloadDone = function(self,entity)
	end,
	--------------------------------------------------
	OnFriendInWay = function(self, entity)
	end,
	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	end,
	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnSmokeGrenadeThrown = function (self,entity, sender)
		-- if throwing smoke grenade
		if (entity.AI.reinfType == 3) then
			entity:SelectPipe(0,"sn_throw_grenade_done");	
		end
		
	end,
	--------------------------------------------------
	GRENADE_FAIL = function (self,entity, sender)
		entity.AI.reinfSpotId = nil;
		AI.NotifyReinfDone(entity.id, 0);
		self:ContinueAfterReinf(entity);		
	end,
	
	--------------------------------------------------
	REINF_DONE = function (self,entity, sender)
		if (entity.AI.reinfSpotId) then
			local spot = System.GetEntity(entity.AI.reinfSpotId);
			entity.AI.reinfSpotId = nil;
			if (spot and spot.Alarm) then
				spot:Alarm();
			end
		end
		
		entity.AI.reinfSpotId = nil;

		AI.LogEvent(">>> "..entity:GetName().." REINF_DONE");
		self:ContinueAfterReinf(entity);
		AI.NotifyReinfDone(entity.id, 1);
	end,

	--------------------------------------------------
	TARGET_TOO_CLOSE = function (self, entity)
		AI.LogEvent(">>> "..entity:GetName().." TARGET_TOO_CLOSE");
		self:ContinueAfterReinf(entity);
	end,

	--------------------------------------------------
	ContinueAfterReinf = function (self, entity)
		-- Choose proper action after being interrupted.
		AI_Utils:CommonContinueAfterReaction(entity);
	end,
	
	--------------------------------------------------
	MOUNTED_WEAPON_USABLE = function(self,entity,sender,data)
		-- sent by smart object rule
		if(data and data.id) then 
			local weapon = System.GetEntity(data.id);
			if(weapon) then
				AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
			end
		end
		AI.ModifySmartObjectStates(entity.id,"-Busy");				
	end,

}

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Berserk behavior for Alien Trooper (attack in non group situation)
--  
--------------------------------------------------------------------------
--  History:
--  - Oct 2005 - Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperBerserk = {
	Name = "TrooperBerserk",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity.AI.bStrafe = false;
		local targetType = AI.GetTargetType(entity.id);
		if(targetType==AITARGET_ENEMY) then 
			AIBehaviour.TROOPERDEFAULT:StickPlayerAndShoot(entity);
		else
			entity:SelectPipe(0,"tr_stick_close");
			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
				entity:InsertSubPipe(0,"acquire_target","beacon");
			end
		end
		entity:Event_UnCloak();
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);
--		if(not entity.AI.bStrafe) then 
--			local health = entity.actor:GetHealth();
--			local prevHealth = health+data.fValue;
--			if(math.floor(health/10) ~= math.floor(prevHealth/10)) then 
--				-- make the trooper move a bit once every 10 points damage
--				g_SignalData.fValue = 1.5;
--				AI.Signal(SIGNALFILTER_SENDER,1,"DODGE",entity.id,g_SignalData);
--			end
--		end	
	
	end,

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
		--entity:SelectPipe(0,"tr_dig_in_shoot_on_spot");
	end,

	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:Readibility("ENEMY_TARGET_LOST");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		local rnd=random(1,10);
		if (rnd < 5) then 
			entity:Readibility("THREATEN",1);			
		end

		entity:SelectPipe(0,"just_shoot");
		entity:InsertSubpipe(0,"tr_stick_close");
	end,

	---------------------------------------------
	OnFriendInWay = function(self,entity,sender)
		if(not entity.AI.bStrafe) then 
			entity.AI.bStrafe = true;
			AIBehaviour.TROOPERDEFAULT:DODGE(entity,2.5);
		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		if(entity:SetRefPointAtDistanceFromTarget(2)) then 
			entity:SelectPipe(0,"tr_approach_target_at_distance");
		else
			entity:SelectPipe(0,"tr_seek_target");
			entity:InsertSubpipe(0,"tr_random_short_timeout");
		end
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:Readibility("RELOADING",1);
		entity:SelectPipe(0,"tr_seek_target");
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:SelectPipe(0,"tr_seek_target");
		entity:InsertSubpipe(0,"tr_random_short_timeout");
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

	end,	

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		-- call default handling
		AIBehaviour.TROOPERDEFAULT:OnDamage(entity,sender,data);
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	--------------------------------------------------
--	OnCloseContact = function ( self, entity, sender)
--		-- called when the enemy is damaged
--		entity:SelectPipe(0,"tr_scramble");
--	end,

	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	
	
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	
	------------------------------------------------------------------------
	
	DODGE2_FAILED = function(self,entity,sender)
		entity.AI.bStrafe = false;
		self:Constructor(entity);
	end,

	------------------------------------------------------------------------
	DODGE_SUCCESSFUL = function(self,entity,sender)
		entity.AI.bStrafe = false;
		self:Constructor(entity);
	end,
}

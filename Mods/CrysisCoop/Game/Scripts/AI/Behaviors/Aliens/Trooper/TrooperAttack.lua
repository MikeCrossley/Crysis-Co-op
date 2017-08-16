--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Attack behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAttack = {
	Name = "TrooperAttack",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity.AI.bStrafe = false;
--		entity:SelectPipe(0,"tr_just_shoot");
		local weapon = entity.inventory:GetCurrentItem();
		if(weapon~=nil and (weapon.class=="MOAR" or weapon.class=="FastLightMOAR" or weapon.class=="Freezer")) then
			entity.AI.FireMode = 1;
		else	
			entity.AI.FireMode = 0;
		end
		entity:DrawWeaponNow(1);
		entity:SetFireMode();
		entity:Cloak(0);

		Trooper_SetAccuracy(entity,2);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 7);

--		local targetType = AI.GetTargetType(entity.id);
--		if(targetType==AITARGET_ENEMY) then 
--			Trooper_StickPlayerAndShoot(entity);
--		else
--			entity:SelectPipe(0,"tr_stick_close");
--			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
--				entity:InsertSubpipe(0,"acquire_target","beacon");
--			end
--		end

		Trooper_ChooseAttack(entity);
		entity.AI.bFormationReached = false;
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		--entity:Readibility("GETTING_SHOT_AT",1);

		local shooter = System.GetEntity(data.id);

		if(Trooper_LowHealth(entity)) then 
			--entity:SelectPipe(0,"tr_hide_away_from_lastop",data.id);
			if(not entity.AI.lastHideTime) then 
				entity.AI.lastHideTime = _time - 4;
			end
			if(_time - entity.AI.lastHideTime> 3) then 
				entity.AI.lastHideTime = _time;
				entity:SelectPipe(0,"tr_hide_away_from_lastop",shooter.id);
				if(entity:GetDistance(shooter.id)<5) then 
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_backoff_fire_lastop",shooter.id);
				end
				return;
			end
		end
		if(Trooper_ReevaluateShooterTarget(entity,shooter)) then 
			g_SignalData.id = shooter.id;
			AI.Signal(SIGNALFILTER_SENDER,1,"PURSUE",entity.id,g_SignalData);
		else
			-- boh
		end
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
--		entity:Readibility("ENEMY_TARGET_LOST");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--		local rnd=random(1,10);
--		if (rnd < 5) then 
--			entity:Readibility("THREATEN",1);			
--		end

--		entity:SelectPipe(0,"do_nothing");
		--local pos = g_Vectors.temp;
		Trooper_ChooseAttack(entity);
		--entity:TriggerEvent(AIEVENT_DROPBEACON);
		
	end,

	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		entity:PlayAccelerationSound();
		
	end,

	---------------------------------------------
	OnFriendInWay = function(self,entity,sender)
--		g_SignalData.fValue = 2;
--		g_SignalData.iValue = -1;-- navType - ignore it in this case
--		CopyVector(g_SignalData.point,g_Vectors.v000);
--		AI.Signal(SIGNALFILTER_SENDER,1,"DODGE",entity.id,g_SignalData);
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
--		if(entity:SetRefPointAtDistanceFromTarget(2)) then 
--			entity:SelectPipe(0,"tr_approach_target_at_distance");
--		else
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_seek_target");
		entity:InsertSubpipe(0,"tr_random_short_timeout");
		--entity:TriggerEvent(AIEVENT_DROPBEACON);
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
--		end
	end,

	---------------------------------------------
	
	OnNoTargetAwareness= function( self, entity )
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_seek_target");
		entity:InsertSubpipe(0,"tr_random_short_timeout");
	end,
	---------------------------------------------
	
	OnNoTargetVisible= function( self, entity )
		entity:Readibility("target_lost",1,0);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_seek_target");
		entity:InsertSubpipe(0,"tr_random_short_timeout");
	end,
	
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
--		entity:Readibility("RELOADING",1);
		entity:SelectPipe(0,"do_nothing");--to reset the tr_seek_target goalpipe if it was already in there
		entity:SelectPipe(0,"tr_seek_target");
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_seek_target");--to reset the tr_seek_target goalpipe if it was already in there
		entity:InsertSubpipe(0,"tr_random_short_timeout");
		entity:TriggerEvent(AIEVENT_DROPBEACON);
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
	OnNoPathFound = function ( self, entity, sender)
--		entity:SelectPipe(0,"tr_just_shoot");
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	--------------------------------------------------
	OnEndPathOffset = function ( self, entity, sender)
--		entity:SelectPipe(0,"tr_just_shoot");
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	
	--------------------------------------------------
	OnCloseContact = function ( self, entity, target)
		if(not Trooper_CheckMelee(entity,target,2)) then
		 entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_backoff_fire");
		end
	end,

	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	
	---------------------------------------------
	JUMP_ON_ROCK = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	---------------------------------------------
--	END_LOOK_CLOSER = function (self, entity, sender)
--		-- go to search - see AIcharacter
--	end,
	
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	
	------------------------------------------------------------------------
	
	OnPlayerLooking = function(self,entity,sender)
		
	end,
	
	TRY_MELEE_JUMP	= function(self,entity,sender)
		if(random(1,100)<50) then 
			local targetPos = g_Vectors.temp_v1;
			if(AI.GetAttentionTargetPosition(entity.id,targetPos)) then 
				local dir = g_Vectors.temp;
				FastDifferenceVectors(dir,targetPos,entity:GetPos());
				local distance = LengthVector(dir);
				if(distance>0) then 
					
					--dir.z = dir.z + 10*distance;
					--ScaleVectorInPlace(dir,15);
					NormalizeVector(dir);
					dir.z = dir.z + 0.2;
					local velocity = g_Vectors.temp_v1;
					--if(AI.CanJumpToPoint(entity.id,targetPos,2,velocity)) then 
						entity:SelectPipe(0,"tr_melee_jump");
--					entity:AddImpulse(-1,nil,dir,distance*500,1);
					--entity:SetPhysicParams(PHYSICPARAM_VELOCITY, dir);
						AI.Animation(entity.id,AIANIM_SIGNAL,"meleeJumpAttack");
					--end
				end
			end
		end
	end,
	
	END_MELEE_JUMP	= function(self,entity,sender)
		entity:SelectPipe(0,"tr_stick_shooting0");
--		entity:InsertSubpipe(0,"tr_random_short_timeout");
	end,	

	--------------------------------------------------
	OnNavTypeChanged= function(self,entity,sender,data)
	end,

	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
		local targetNavType = data.iValue2;
		if(targetNavType ==	NAV_WAYPOINT_HUMAN or targetNavType== NAW_WAYPOINT_TRIANGULAR) then 
			entity.AI.navType = data.iValue;
			entity.AI.targetNavType = targetNavType;
	
			if(targetNavType ~= NAV_WAYPOINT_HUMAN) then
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			end
		end
	end,
	

	--------------------------------------------------
	OnLand = function(self,entity,sender)
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_lower_target");
		entity.AI.JumpType = nil;
	end,
	
	--------------------------------------------------
	END_JUMP_ON_SPOT = function(self,entity,sender)
		AI.ModifySmartObjectStates(entity.id,"-ShootSpotFound");
		Trooper_ChooseAttack(entity);
	end,
	
	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
		entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"tr_backoff_fire");
		--Trooper_ChooseAttack(entity);
	end,
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
		entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"tr_backoff_fire");
--		Trooper_ChooseAttack(entity);
	end,

	--------------------------------------------------
	END_BACKOFF = function(self,entity,sender)
		Trooper_ChooseAttack(entity);
	end,

	--------------------------------------------------
	GO_TO_SEARCH = function(self,entity,sender)
		g_SignalData.point.x = 0;
		g_SignalData.point.y = 0;
		g_SignalData.point.z = 0;
		g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
		g_SignalData.iValue2 = AIAnchorTable.SEARCH_SPOT;
		g_SignalData.fValue = 20; --search distance
		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
	end,
	
	--------------------------------------------------
	END_LOOK_CLOSER = function(self,entity,sender)
		AIBehaviour.TrooperAttack:GO_TO_SEARCH(entity,sender);
	end,

	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
		if(Trooper_CheckMeleeFinal(entity)) then 
			return;
		end
		Trooper_StickPlayerAndShoot(entity);
		entity:InsertSubpipe(0,"tr_backoff");
	end,
	
	--------------------------------------------------
	END_SHOOT_ON_ROCK = function( self, entity, sender)
		Trooper_ChooseAttack(entity);
	end,

	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,

}

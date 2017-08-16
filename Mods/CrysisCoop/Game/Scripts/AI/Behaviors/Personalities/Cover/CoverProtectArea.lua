--------------------------------------------------
--   Created By: Luciano
--   Description: Cover goes into this behaviour when there is a spot to protect
-- 		He will be hiding around this point
--------------------------

AIBehaviour.CoverProtectArea = {
	Name = "CoverProtectArea",
--	Base = "CoverHold",
	alertness = 1,

	Constructor = function(self,entity,data)
		entity.protectSpot = data.ObjectName;
		if(entity.protectSpot and entity.protectSpot~="") then 
			AI.LogEvent(entity:GetName().." protecting area around "..entity.protectSpot);
			entity:SelectPipe(0,"hide_around_from_target",entity.protectSpot);
			local spotEntity = System.GetEntityByName(entity.protectSpot);
			if(spotEntity) then
				spotEntity:Event_Disable();
			end
		else
			AI.Warning(entity:GetName().." has no area to protect!");
		end
		entity.bHidden = false;
	end,
	
	---------------------------------------------
	Destructor = function(self,entity)
		local spotEntity = System.GetEntityByName(entity.protectSpot);
		if(spotEntity) then
			spotEntity:Event_Enable();
		end
		entity.protectSpot = nil;
		entity:InsertSubpipe(0,"stop_fire");
		entity:InsertSubpipe(0,"clear_devalued");
		entity.bHidden = false;
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged
		entity.bHidden = false;
		entity:SelectPipe(0,"hide_around_from_target",entity.protectSpot);
		entity:InsertSubpipe(0,"acquire_target",data.id);
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		if(entity.bHidden) then 
			entity:SelectPipe(0,"long_timeout");
		end
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		

		if(not NOCOVER:SelectAttack(entity)) then
			local targetName = AI.GetAttentionTargetOf(entity.id);
			local target;
			local dist = -1;
			if(targetName) then
				target = System.GetEntityByName(targetName);
			end	
			if(target ) then
				-- target is flesh and blood and enemy
				dist = entity:GetDistance(target.id);
			else
				--try the beacon
				local beacon = g_Vectors.temp;
				if( AI.GetBeaconPosition( entity.id ,beacon) ) then
					dist = DistanceSqVectors(entity:GetWorldPos(),beacon);
				end
			end			
			
			entity.bHidden = false;
			if(dist <0) then	
				entity:SelectPipe(0,"just_shoot");
			elseif(dist >10) then
				entity:SelectPipe(0,"hide_around_from_target",entity.protectSpot);
				entity:InsertSubpipe(0,"stop_fire");
				entity:InsertSubpipe(0,"just_shoot");
			else
				entity:SelectPipe(0,"just_shoot");
				entity:InsertSubpipe(0,"backoff_fire");
			end
		end

		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		-- drop beacon and shoot like crazy
--		local rnd = random(1,10);
--		if (rnd < 2) then 
--			NOCOVER:SelectAttack(entity);
--		else
--			entity:SelectPipe(0,"just_shoot");
--			entity:InsertSubpipe(0,"setup_crouch");
--			entity:TriggerEvent(AIEVENT_DROPBEACON);
--		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
		-- set a timeout before switching to alert
		if( entity.bHidden) then 
			entity:SelectPipe(0,"long_timeout");
		end
	end,
	
	---------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
		entity.bHidden = true;
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- forget about the timeout, something is still around and don't switch off this behaviour
		entity.bHidden = false;
		entity:SelectPipe(0,"seek_target");		
		entity:InsertSubpipe(0,"do_it_standing");
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- forget about the timeout, something is still around and don't switch off this behaviour
		entity.bHidden = false;
		entity:SelectPipe(0,"hide_around_from_target",entity.protectSpot);	
	end,
	---------------------------------------------
	OnReload = function( self, entity )

	end,
	---------------------------------------------
--	OnNoHidingPlace = function( self, entity, sender )
--	
--		if(AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
--			entity:InsertSubpipe(0,"start_fire");
--		end
--		entity:SelectPipe(0,"approach_at_distance",entity.protectSpot);
--		
--	end,	
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged

	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity:Readibility("BULLETRAIN_COMBAT");	
	end,
	--------------------------------------------------
--	OnClipNearlyEmpty = function ( self, entity, sender)
--		entity:SelectPipe(0,"cover_scramble");
--		entity:InsertSubpipe(0,"take_cover");
--	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)

	end,
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	---------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- do nothing on this signal
		entity:SelectPipe(0,"look_around");
	end,	
-----------------------------
	GET_ALERTED = function( self, entity )
	end,
	------------------------------------------------------------------------
	TARGET_REACHED = function(self,entity,sender)
		entity.bHidden = false;
		entity:SelectPipe(0,"hide_around_from_target",entity.protectSpot);
	end,
	
	------------------------------------------------------------------------
	END_TIMEOUT = function(self,entity,sender)
		entity:SelectPipe(0,"lookaround_protect",entity.protectSpot);
		--AI.Signal(SIGNALFILTER_SENDER,1,"BACK_TO_ALERT",entity.id);
	end,

	------------------------------------------------------------------------
	END_HIDE = function(self,entity,sender)
		local targetName = AI.GetAttentionTargetOf(entity.id);
		if(targetName) then 
			local target = System.GetEntityByName(targetName);
			if (target and AI.Hostile(entity.id,target.id)) then 
				self:OnPlayerSeen(entity,target,entity:GetDistance(target.id));
			else 
				entity:SelectPipe(0,"seek_target");
				entity:InsertSubpipe(0,"do_it_standing");
				entity:InsertSubpipe(0,"random_short_timeout");
			end
		end

	end,

}
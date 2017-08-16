--------------------------------------------------
--   Created By: Petar
--   Description: Cover goes into this behaviour when there is no more cover, so he holds his ground
--------------------------

AIBehaviour.CoverHold = {
	Name = "CoverHold",
	alertness = 1,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"not_so_random_hide_from",data.id);
--		entity:InsertSubpipe(0,"pause_shooting");
	end,

	---------------------------------------------
	KEEP_FORMATION = function (self, entity, sender)
		entity:SelectPipe(0,"cover_hideform");
	end,


	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:SelectPipe(0,"confirm_targetloss");
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		
		if(entity.IN_SQUAD ==1) then
			entity:SelectPipe(0,"random_reacting_timeout");
			entity:InsertSubpipe(0,"notify_player_seen");
			do return end;
		end
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
			
			if(dist <0) then	
				entity:SelectPipe(0,"just_shoot");
			elseif(dist >10) then
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"not_so_random_hide_from");
--				entity:InsertSubpipe(0,"attack_get_in_range");
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
		-- try to re-establish contact
		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"reload");
		entity:InsertSubpipe(0,"do_it_standing");
		
		if (fDistance > 10) then 
			entity:InsertSubpipe(0,"do_it_running");
		else
			entity:InsertSubpipe(0,"do_it_walking");
		end
		
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		System.Log(entity:GetName().." CoverHold onInterestingSoundHeard");
		self:OnEnemyMemory(entity,1);
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- ignore this
	end,
	---------------------------------------------
	OnReload = function( self, entity )

	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		
		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);	
	
		-- PETAR : Cover in attack should not care who died or not. He is too busy 
		-- watching over his own ass :)
	
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- he is not trying to hide in this behaviour
	end,	
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		AIBehaviour.DEFAULT:OnReceivingDamage(entity,sender);

		entity:SelectPipe(0,"cover_scramble");
		entity:InsertSubpipe(0,"pause_shooting");
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
	OnClipNearlyEmpty = function ( self, entity, sender)
		entity:SelectPipe(0,"cover_scramble");
		entity:InsertSubpipe(0,"take_cover");
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"cover_pindown");
	end,
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
		entity.RunToTrigger = 1;
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

	---------------------------------------------	
	PHASE_BLACK_ATTACK = function (self, entity, sender)
		-- team leader instructs black team to attack
		entity.Covering = nil;
		entity:SelectPipe(0,"black_cover_pindown");
	end,

	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
		entity.Covering = nil;
		entity:SelectPipe(0,"red_cover_pindown");
	end,
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	------------------------------------------------------------------------

}
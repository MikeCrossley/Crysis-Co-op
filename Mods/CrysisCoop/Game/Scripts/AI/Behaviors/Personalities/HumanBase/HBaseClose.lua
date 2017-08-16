--------------------------------------------------
--   Created By: Kirill
--   Description: This is the combat behaviour when enemy is too close - just shoot, always facing enemy, move to cover


AIBehaviour.HBaseClose = {
	Name = "HBaseClose",
	alertness = 2,
	base = "CoverAttack",

	Constructor = function (self, entity)
	
AI.LogEvent(entity:GetName().." HBaseClose constructor");	
--		entity:SelectPipe(0,"camper_fire");
--   	entity:InsertSubpipe(0, "throw_grenade");

		entity:SelectPipe(0,"just_shoot");
		entity:InsertSubpipe(0,"do_it_standing");
		
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	
		entity:Supress( 3 );
	end,


	OnLeftLean  = function( self, entity, sender)
	end,
	---------------------------------------------
	OnRightLean  = function( self, entity, sender)
	end,
	--------------------------------------------------
	STRAFE_POINT_REACHED = function(self,entity,sender)
	end,
	--------------------------------------------------
	STRAFE_POINT_NOT_REACHED = function(self,entity,sender)
		-- this happens after strafing the obstacle
		entity:SelectPipe(0,"cover_pindown");
	end,

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	
		entity:SelectPipe(0,"lowhide_fire");
		entity:InsertSubpipe(0,"random_short_timeout");
		entity:InsertSubpipe(0,"do_it_crouched");
	
	
--		entity.lowHide = nil;
--		entity:SelectPipe(0,"camper_fire");
--		entity:InsertSubpipe(0,"random_timeout");
--		local stc=entity:SelectStance();
--		if (stc == 1 ) then 
--			entity:InsertSubpipe(0,"do_it_prone");
--		else	
--				entity:InsertSubpipe(0,"do_it_crouched");
--		end	
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:Readibility("ENEMY_TARGET_LOST"); -- you will go to alert from here
--		entity:SelectPipe(0,"look_around_quick");
		entity:SelectPipe(0,"look_at_beacon");		
		entity:InsertSubpipe(0,"do_it_standing");
		entity:InsertSubpipe(0,"get_out_of_cover_timeout");		
		
		
--		entity:SelectPipe(0,"search_for_target");
--		if(entity:SetRefPointAtDistanceFromTarget(8)) then
--			entity:SelectPipe(0,"approach_target_at_distance");
--		end
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	do return end

		--AI.SetRefPointPosition(entity.id,entity:GetWorldPos());

		local rnd=random(1,10);
		if (rnd < 5) then 
			entity:Readibility("THREATEN",1);			
		end
		
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
		entity:SelectPipe(0,"camper_fire");
		local stc=entity:SelectStance();
		if (stc == 1 ) then 
			entity:InsertSubpipe(0,"do_it_prone");
		else	
				entity:InsertSubpipe(0,"do_it_crouched");
		end	
		
--		local rnd=random(1,10);
--		if (rnd < 3) then 
--			entity:InsertSubpipe(0,"do_it_crouched");
--		else
--			entity:InsertSubpipe(0,"do_it_prone");
--		end	
		
		do return end

--		if (fDistance>20) then
			entity:SelectPipe(0,"cover_pindown");
			entity:InsertSubpipe(0, "short_crouch_cover_fire");
--		else
--			entity:SelectPipe(0,"cover_scramble");
--		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )

	do return end	
			entity:SelectPipe(0,"look_around_quick");		
			entity:InsertSubpipe(0,"do_it_standing");
----				entity:SelectPipe(0,"seek_target");
			entity:InsertSubpipe(0,"random_short_timeout");
			entity:InsertSubpipe(0,"do_it_crouched");
			entity:InsertSubpipe(0,"stop_fire");
			entity:InsertSubpipe(0,"random_timeout");						
			entity:InsertSubpipe(0,"just_shoot");
			entity:InsertSubpipe(0,"do_it_standing");
			entity:InsertSubpipe(0,"random_short_timeout");				
			--
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:Readibility("RELOADING",1);
		entity:SelectPipe(0,"look_around");		
--		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"do_it_standing");
	end,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
--		System.Log("--------OnReload");
		entity:SelectPipe(0,"hide_now");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." OnPlayerdied in HBaseClose");
		entity:CheckReinforcements();
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);	
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- select random attack pipe		
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
					dist = DistanceVectors(entity:GetWorldPos(),beacon);
				end
			end			
		
			if(dist <0) then	
				entity:SelectPipe(0,"just_shoot");
			elseif(dist >50) then
				entity:SelectPipe(0,"attack_get_in_range");
			else
				entity:SelectPipe(0,"just_shoot");
--				if(dist <10) then
--					entity:InsertSubpipe(0,"backoff_fire");
--				end
			end
		end
		local rnd=random(1,10);
		if (rnd < 7) then 
			entity:Readibility("THREATEN",1);			
		end
	end,	
	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

		entity:Supress( 2 );

		entity:SelectPipe(0,"hide_now");

		-- call default handling
		AIBehaviour.DEFAULT:OnDamage(entity,sender,data);
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	
		entity:Supress( 2 );	
		entity:Readibility("BULLETRAIN_COMBAT");	
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
		entity:SelectPipe(0,"hide_now");
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"cover_pindown");
		entity:InsertSubpipe(0,"reload");
	end,
	---------------------------------------------
	AISF_GoOn = function (self, entity, sender)
		entity:SelectPipe(0,"cover_scramble");
	end,
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
--		entity.RunToTrigger = 1;
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	KEEP_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
	end,
	---------------------------------------------	
	BREAK_FORMATION = function (self, entity, sender)
		-- the team can split
	end,
	---------------------------------------------	
	SINGLE_GO = function (self, entity, sender)
		-- the team leader has instructed this group member to approach the enemy
	end,
	---------------------------------------------	
	GROUP_COVER = function (self, entity, sender)
		-- the team leader has instructed this group member to cover his friends
	end,
	---------------------------------------------	
	IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
	end,
	---------------------------------------------	
	GROUP_SPLIT = function (self, entity, sender)
		-- team leader instructs group to split
	end,
	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
	end,
	---------------------------------------------	
	PHASE_BLACK_ATTACK = function (self, entity, sender)
		-- team leader instructs black team to attack
	end,
	---------------------------------------------	
	GROUP_MERGE = function (self, entity, sender)
		-- team leader instructs groups to merge into a team again
	end,
	---------------------------------------------	
	CLOSE_IN_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	ASSAULT_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	GROUP_NEUTRALISED = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
   	entity:InsertSubpipe(0, "throw_grenade");
	end,
	------------------------------------------------------------------------
	END_HIDE = function(self,entity,sender)
	
			entity:SelectPipe(0,"cover_pindown");
			entity:InsertSubpipe(0,"random_short_timeout");
do return end	
	
		local targetName = AI.GetAttentionTargetOf(entity.id);
		if(AI.Hostile(entity.id,targetName) and System.GetEntityByName(targetName)) then
			entity:SelectPipe(0,"cover_pindown");
			entity:InsertSubpipe(0,"random_short_timeout");
		elseif(targetName) then
			entity:SelectPipe(0,"seek_target");
			entity:InsertSubpipe(0,"do_it_standing");
			entity:InsertSubpipe(0,"random_short_timeout");
		end
	end,
	------------------------------------------------------------------------
	END_PINDOWN = function(self,entity,sender)
	
		local targetName = AI.GetAttentionTargetOf(entity.id);
		if(AI.Hostile(entity.id,targetName) and System.GetEntityByName(targetName)) then
			-- Calculate strafe point and set it to ref point.
			if( entity:SetRefPointToStrafeObstacle() ) then
				entity:SelectPipe(0,"strafe_obstacle");
				entity:InsertSubpipe(0,"start_fire");
				entity:InsertSubpipe(0,"do_it_standing");
				entity:InsertSubpipe(0,"do_it_running");
			end
		else
		
entity:SelectPipe(0,"not_so_random_hide_from");		
entity:InsertSubpipe(0,"medium_timeout");			
do return end
		
			entity:SelectPipe(0,"seek_target");
			entity:InsertSubpipe(0,"do_it_standing");
			if(targetName=="" or targetName==nil) then
				-- no target at all, use beacon
				entity:InsertSubpipe(0,"acquire_beacon");
			end
		end
		entity:InsertSubpipe(0,"random_short_timeout");
	end,
	
	------------------------------------------------------------------------
	HEADS_UP_GUYS = function(self,entity,sender)
	
	end,
	------------------------------------------------------------------------
	CHECK_FOR_TARGET = function (self, entity, sender)
			entity:SelectPipe(0,"seek_target");
			entity:InsertSubpipe(0,"do_it_standing");
	end,	
	
	---------------------------------------------
	SUPRESSED = function ( self, entity, sender,data)
--		AI.LogEvent(entity:GetName().." I'm supressed HBaseLowHide");
----		entity:Readibility("GETTING_SHOT_AT",1);
--		if(entity.badHide) then
--			entity.badHide = nil;	
--			entity:SelectPipe(0,"hide_now_anywhere");
--		else
--			entity:SelectPipe(0,"hide_now");
--		end
	end,

	---------------------------------------------
	-- nowhere to hide - get down and shoot
	OnBadHideSpot = function ( self, entity, sender,data)
	
			entity.badHide = 1;	
	
			entity:SelectPipe(0,"camper_fire");
			
		local stc=entity:SelectStance();
		if (stc == 1 ) then 
			entity:InsertSubpipe(0,"do_it_prone");
		else	
				entity:InsertSubpipe(0,"do_it_crouched");
		end	
do return end			
			
			local rnd=random(1,10);
			if (rnd < 2) then 
				entity:InsertSubpipe(0,"do_it_crouched");
			else
				entity:InsertSubpipe(0,"do_it_prone");
			end	
	end,

	---------------------------------------------
	SpotCompromized = function( self, entity, fDistance )

--		entity:SelectPipe(0,"camper_fire");
		entity:SelectPipe(0,"hide_now");		
		local stc=entity:SelectStance();
		if (stc == 1 ) then 
			entity:InsertSubpipe(0,"do_it_prone");
		else	
				entity:InsertSubpipe(0,"do_it_crouched");
		end	
	end,
	
	---------------------------------------------
	NoTarget = function( self, entity, fDistance )

		entity:SelectPipe(0,"camper_fire");
		local stc=entity:SelectStance();
		if (stc == 1 ) then 
			entity:InsertSubpipe(0,"do_it_prone");
		else	
				entity:InsertSubpipe(0,"do_it_crouched");
		end	
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,



	
	}

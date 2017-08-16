--------------------------------------------------
--   Created By: Petar
--   Description: This is the combat behaviour of the Cover


AIBehaviour.CoverAttack = {
	Name = "CoverAttack",
	alertness = 2,

	Constructor = function (self, entity)
		entity:CheckReinforcements();
		entity:MakeAlerted();

entity:TriggerEvent(AIEVENT_DROPBEACON);
AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);

		-- this checks for mounted weapons around and uses them
--		AIBehaviour.DEFAULT:SHARED_FIND_USE_MOUNTED_WEAPON( entity );
--   	entity:InsertSubpipe(0, "throw_grenade");
  	
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		AI.LogEvent(entity:GetName().." ONENEMY DAMAGE CoverAttack");
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"check_hide");
		return;
		
--		local mytargetName = AI.GetAttentionTargetOf(entity.id);
--		if (mytargetName) then 
--			local mytarget = System.GetEntityByName(mytargetName);
--			if (mytarget==nil) then
--				entity:SelectPipe(0,"retaliate_damage",data.id);
--			else
--				local shooter = System.GetEntity(data.id);
--				if(shooter~=nil) then
--					-- shooter is an enemy, otherwise it wouldn't be in this signal
--					entity:SelectPipe(0,"retaliate_damage",data.id);
--				end
--			end
--		end
	end,

	---------------------------------------------
	-- hide spot is available - let's hide!
	HIDE_AVAILABLE = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:SelectPipe(0,"not_so_random_hide_from",data.id);
	end,

	---------------------------------------------
	-- nowhere to hide - let's prone or backoff
	HIDE_UNAVAILABLE = function ( self, entity, sender,data)
	
		local stc=entity:SelectStance();
		if (stc == 1 ) then 
			entity:InsertSubpipe(0,"do_it_prone");
		end	
		entity:InsertSubpipe(0,"backoff_underfire");
	end,

	---------------------------------------------
	OnLeftLean  = function( self, entity, sender)
		if (entity.Properties.special==1) then 
			do return end
		end
		local rnd=random(1,10);
		if (rnd > 5) then 
--TO DO: restore it when there is animation
--		AI.Signal(0,1,"LEFT_LEAN_ENTER",entity.id);
		end
	end,
	---------------------------------------------
	OnRightLean  = function( self, entity, sender)
		if (entity.Properties.special==1) then 
			do return end
		end

		local rnd=random(1,10);
		if (rnd > 5) then 
--TO DO: restore it when there is animation
--		AI.Signal(0,1,"RIGHT_LEAN_ENTER",entity.id);
		end
	end,
	--------------------------------------------------
	STRAFE_POINT_REACHED = function(self,entity,sender)
		-- this happens after strafing the obstacle

		entity:SelectPipe(0,"cover_pindown");
		entity:InsertSubpipe(0,"short_timeout");
		entity:InsertSubpipe(0, "short_crouch_cover_fire");
		
--entity:SelectPipe(0,"setup_crouch");		
--entity:InsertSubpipe(0,"medium_timeout");			
--do return end
		
--		entity:SelectPipe(0,"seek_target");
--		entity:InsertSubpipe(0,"stop_fire");
	end,
	--------------------------------------------------
	STRAFE_POINT_NOT_REACHED = function(self,entity,sender)
		-- this happens after strafing the obstacle
		entity:SelectPipe(0,"cover_pindown");
		
	end,

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)

		--entity:SelectPipe(0,"do_nothing");--in case it was already in dig_in_attack
		entity:SelectPipe(0,"low_hide_shoot");
--		entity:SelectPipe(0,"dig_in_shoot_on_spot");

	end,
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	
			entity:SelectPipe(0,"cover_pindown");
			entity:InsertSubpipe(0,"random_short_timeout");
	
	
--		local targetName = AI.GetAttentionTargetOf(entity.id);
--		if(AI.Hostile(entity.id,targetName) and System.GetEntityByName(targetName)) then
--			entity:SelectPipe(0,"cover_pindown");
--			entity:InsertSubpipe(0,"random_short_timeout");
--		elseif(targetName) then
--			entity:SelectPipe(0,"seek_target");
--			entity:InsertSubpipe(0,"do_it_standing");
--			entity:InsertSubpipe(0,"random_short_timeout");
--		end
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:Readibility("ENEMY_TARGET_LOST"); -- you will go to alert from here
		
--		if(entity:SetRefPointAroundBeaconRandom(8)) then
--			entity:SelectPipe(0,"cover_refpoint_investigate");
--		else
--			entity:SelectPipe(0,"cover_beacon_investigate");
--		end

--		entity:SelectPipe(0,"search_for_target");
--		if(entity:SetRefPointAtDistanceFromTarget(8)) then
--			entity:SelectPipe(0,"approach_target_at_distance");
--		end
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		if(entity:IsEnemyClose( fDistance )) then
			do return end
		end	

		local rnd=random(1,10);
		if (rnd < 5) then 
			entity:Readibility("THREATEN",1);			
		end
		
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
--		if (fDistance>20) then
		entity:SelectPipe(0,"cover_pindown");
		entity:InsertSubpipe(0, "short_crouch_cover_fire");
--		else
--			entity:SelectPipe(0,"cover_scramble");
--		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	
		entity:SelectPipe(0,"dumb_shoot_timout");	
--		do return end
--		entity:SelectPipe(0,"look_at_beacon");
		entity:InsertSubpipe(0,"get_out_of_cover");
		do return end
	
		if(entity:SetRefPointAtDistanceFromTarget(8)) then 
			entity:SelectPipe(0,"approach_target_at_distance");
			entity:InsertSubpipe(0,"throw_grenade");
		else
			if(entity:GetSpeed()<0.1) then 
				-- to do: do a better test to check if it was me or the target who caused the target loss
				entity:Readibility("RELOADING",1);
				entity:SelectPipe(0,"seek_target");
--
--				local rnd=random(1,10);
--				if (rnd < 3) then 
--					entity:SelectPipe(0,"seek_target_left");
--				else if (rnd < 5) then 
--					entity:SelectPipe(0,"seek_target_left2");
--				else if (rnd < 7) then 
--					entity:SelectPipe(0,"seek_target_right");
--				else 
--					entity:SelectPipe(0,"seek_target_right2");
--				end
				entity:InsertSubpipe(0,"do_it_crouched");
				entity:InsertSubpipe(0,"random_short_timeout");
			end					
		end
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:Readibility("RELOADING",1);
		entity:SelectPipe(0,"dumb_shoot_timout");
		entity:InsertSubpipe(0,"get_out_of_cover");
--		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"do_it_standing");
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
--		entity:InsertSubpipe(0,"get_out_of_cover");
		entity:InsertSubpipe(0,"devalue_target");
		
	end,
	---------------------------------------------
	OnTargetDead	 = function( self, entity )
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"stop_fire");
				
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
--		System.Log("--------OnReload");
		entity:SelectPipe(0,"cover_scramble");
--		entity:InsertSubpipe(0, "reload_combat");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." OnPlayerdied in CoverAttack");
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
				entity:InsertSubpipe(0,"do_it_crouched");				
			elseif(dist >50) then
				entity:SelectPipe(0,"attack_get_in_range");
			else
				entity:SelectPipe(0,"just_shoot");
				entity:InsertSubpipe(0,"do_it_crouched");
				if(dist <10) then
					entity:InsertSubpipe(0,"backoff_fire");
				end
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

		entity:SelectPipe(0,"cover_scramble");

		-- call default handling
		AIBehaviour.DEFAULT:OnDamage(entity,sender,data);
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity:Readibility("BULLETRAIN_COMBAT");	
	end,
	--------------------------------------------------
	WPN_OUT_OF_AMMO	= function ( self, entity, sender)
		entity:SelectPipe(0,"cover_scramble");
	end,
	--------------------------------------------------	
--	OnClipNearlyEmpty = function ( self, entity, sender)
--		entity:SelectPipe(0,"cover_scramble");
--	end,
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
	
		if(AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then
			entity:SelectPipe(0,"cover_pindown");
			entity:InsertSubpipe(0,"look_at_beacon");
		end
		
	end,
	
	------------------------------------------------------------------------
	CHECK_FOR_TARGET = function (self, entity, sender)
			entity:SelectPipe(0,"seek_target");
			entity:InsertSubpipe(0,"do_it_standing");
	end,	
	
	---------------------------------------------
	SUPRESSED = function ( self, entity, sender,data)
		AI.LogEvent(entity:GetName().." I'm supressed CoverAttack");
--		entity:Readibility("GETTING_SHOT_AT",1);
		if(entity.badHide) then
			entity.badHide = nil;	
			entity:SelectPipe(0,"hide_now_anywhere",data.id);
		else
			entity:SelectPipe(0,"hide_now",data.id);
		end
	end,

	---------------------------------------------
	-- nowhere to hide - get down and shoot
	OnBadHideSpot = function ( self, entity, sender,data)
	
			entity.badHide = 1;	
	
		entity:SelectPipe(0,"not_so_random_hide_from");		
		do return end
	
			entity:SelectPipe(0,"cover_fire");
			
		local stc=entity:SelectStance();
		if (stc == 1 ) then 
			entity:InsertSubpipe(0,"do_it_prone");
		else	
				entity:InsertSubpipe(0,"do_it_crouched");
		end	
	end,

	OnEndPathOffset = function ( self, entity, sender,data)
	end,
	
	}

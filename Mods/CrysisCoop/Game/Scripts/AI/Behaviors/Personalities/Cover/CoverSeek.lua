--------------------------------------------------
--   Created By: Kirill
--   Description: This is the combat search target behaviour of the Cover


AIBehaviour.CoverSeek = {
	Name = "CoverSeek",
	Base = "CoverAttack",	
	alertness = 2,


	Constructor = function (self, entity)
--			entity:SelectPipe(0,"approach_target_at_distance");		
--			entity:SelectPipe(0,"cover_beacon_investigate");		

		-- not everybody goes searching - only first 3 dudes
		if(AIBlackBoard.searcherCounter==nil) then
			AIBlackBoard.searcherCounter = 0;
		end	
		if(AIBlackBoard.searcherCounter>3) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "HOLD_POSITION",entity.id);
		end
		AIBlackBoard.searcherCounter = AIBlackBoard.searcherCounter + 1;		

		local p = g_Vectors.temp_v1;
		AI.GetBeaconPosition(entity.id, p);
		if(IsNullVector(p)) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "GO_TO_SEARCH",entity.id);
			return;
		end
		AI.SetRefPointPosition(entity.id, p);
		entity:SelectPipe(0,"cover_refpoint_investigate");

--		if(entity:SetRefPointAroundBeaconRandom(4)~=nil) then
--			entity:SelectPipe(0,"cover_refpoint_investigate");
--		else
--			entity:SelectPipe(0,"cover_beacon_investigate");
--		end
		entity:InsertSubpipe(0,"throw_grenade_at_beacon");
		
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		AI.LogEvent(entity:GetName().." ONENEMY DAMAGE CoverAttack");
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"check_hide");
--		entity:SelectPipe(0,"not_so_random_hide_from",data.id);
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

	--------------------------------------------------
	STRAFE_POINT_REACHED = function(self,entity,sender)
	end,
	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)

	end,
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	
--			entity:SelectPipe(0,"cover_pindown");
--			entity:InsertSubpipe(0,"random_short_timeout");
	
	
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
--		entity:SelectPipe(0,"search_for_target");
--		if(entity:SetRefPointAtDistanceFromTarget(8)) then
--			entity:SelectPipe(0,"approach_target_at_distance");
--		end
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		AIBlackBoard.searcherCounter = 0;

		local rnd=random(1,10);
		if (rnd < 5) then 
			entity:Readibility("THREATEN",1);			
		end
	
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
		
		if (fDistance>20) then
			entity:SelectPipe(0,"cover_pindown");
--			entity:InsertSubpipe(0, "short_crouch_cover_fire");
		else
			entity:SelectPipe(0,"cover_pindown");
--			entity:InsertSubpipe(0, "short_crouch_cover_fire");
			entity:InsertSubpipe(0, "short_cover_fire");
		end
	end,
	---------------------------------------------
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:Readibility("RELOADING",1);
		entity:SelectPipe(0,"seek_target");
--		entity:InsertSubpipe(0,"do_it_standing");
		entity:InsertSubpipe(0,"do_it_crouched");		
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"do_it_crouched");
	end,
	---------------------------------------------	
	OnSomethingSeen	= function( self, entity )
		-- called when the enemy hears a scary sound
		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"do_it_crouched");		
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

	OnNoHidingPlace = function ( self, entity, sender)
		entity:InsertSubpipe(0,"look_around");
	end,

	OnBadHideSpot = function ( self, entity, sender)
--		entity:InsertSubpipe(0,"look_around");
	end,

	TARGET_DISTANCE_REACHED = function ( self, entity, sender,data)
		self:LOOK_FOR_TARGET(entity, sender,data);
	end,

	FINISH_RUN_TO_FRIEND = function ( self, entity, sender,data)
		self:LOOK_FOR_TARGET(entity, sender,data);
	end,
	
	LOOK_FOR_TARGET	= function ( self, entity, sender,data)
		entity:SelectPipe(0,"seek_target_random");
--		entity:InsertSubpipe(0,"look_around_quick");
		entity:InsertSubpipe(0,"look_around_quick");		
		entity:InsertSubpipe(0,"look_around_quick");		
	end,

	HEADS_UP_GUYS = function (self, entity, sender)
			entity:SelectPipe(0,"cover_pindown");
			entity:InsertSubpipe(0,"look_at_beacon");
	end,
	
	}

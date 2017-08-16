--------------------------------------------------
--   Created By: Petar
--   Description: This behaviour activates as a response to an island-wide alarm call, or in response to a group death
--------------------------------------------------
--   last modified by: sten 23-10-2002

AIBehaviour.CoverAlert = {
	Name = "CoverAlert",
	alertness = 1,


	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:CheckReinforcements();
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		AI.LogEvent(entity:GetName().." ONENEMY DAMAGE CoverAlert");
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);
		entity:Readibility("GETTING_SHOT_AT",1);
		local spot = entity:ProtectSpot();
		if(spot) then
			AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
			return
		end
		entity:SelectPipe(0,"not_so_random_hide_from",data.id);
	end,
		
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
--		entity:SelectPipe(0,"search_for_target");
--		entity:SetRefPointAtDistanceFromTarget(8);
--		entity:SelectPipe(0,"approach_target_at_distance");

	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
		-- REVIEWED

		if(entity:IsEnemyClose( fDistance )) then
			do return end
		end	

		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if(entity.IN_SQUAD==1) then 
			entity:RequestVehicle(AIGOALTYPE_ATTACK);
		end
		
		entity:Readibility("ENEMY_TARGET_REGAIN");
		if (AI.GetGroupCount(entity.id) > 1) then
			-- only send this signal if you are not alone
			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "wakeup",entity.id);
			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "HEADS_UP_GUYS",entity.id);
			local spot = entity:ProtectSpot();
			if(spot) then
				AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
				return
			end
	
			entity:SelectPipe(0,"cover_scramble_beacon");
		else

			local spot = entity:ProtectSpot();
			if(spot) then
				AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
				return
			end

			-- you are on your own
			entity:SelectPipe(0,"cover_scramble");
		end

		if (entity.RunToTrigger == nil) then
			entity:RunToAlarm();
		end	
		
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		local spot = entity:ProtectSpot();
		if(spot) then
			AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
			return
		end
		if(entity:SetRefPointAtDistanceFromTarget(8)) then 
			entity:SelectPipe(0,"approach_target_at_distance");
		end
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:SelectPipe(0,"cover_look_closer");
		entity:TriggerEvent(AIEVENT_DROPBEACON); 
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
--		entity:MakeAlerted();

		local spot = entity:ProtectSpot();
		if(spot) then
			AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
			return
		end
		entity:SelectPipe(0,"cover_investigate_threat"); 



		if (fDistance > 20) then 
			entity:InsertSubpipe(0,"do_it_running");
		else
			entity:InsertSubpipe(0,"do_it_walking");
		end

		entity:InsertSubpipe(0,"cover_threatened"); 
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		entity:SelectPipe(0,"cover_scramble");
	end,
	---------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender,data)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0,"getting_shot_at");
	end,
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
		local targetName = AI.GetAttentionTargetOf(entity.id);
		
		if(AI.Hostile(entity.id,targetName) and System.GetEntityByName(targetName)) then
			entity:SelectPipe(0,"cover_pindown");
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_ATTACK",entity.id);
		elseif(targetName) then
		
			-- start looking for target after some delay
			entity:SelectPipe(0,"delayed_notarget");
			
--			AI.Signal(SIGNALFILTER_SENDER,0,"OnNoTarget",entity.id);
--			entity:SelectPipe(0,"seek_target");
--			entity:InsertSubpipe(0,"do_it_standing");
--			entity:InsertSubpipe(0,"random_short_timeout");
		end
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
		entity:Readibility("BULLETRAIN_IDLE");		
		local spot = entity:ProtectSpot();
		if(spot) then
			AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
			return
		end
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"cover_investigate_threat");		
	end,
	---------------------------------------------	


--	OnGroupMemberDied = function( self, entity, sender)
--		-- called when a member of the group dies
--		entity:CheckReinforcements();		
--		 if (sender.groupid == entity.groupid) then
--		 	if (entity ~= sender) then
--		 		entity:SelectPipe(0,"TeamMemberDiedLook");
--		 	end
--		 else
--		 	entity:SelectPipe(0,"randomhide");
--		 end
--	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)

		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);

		entity:SelectPipe(0,"TeamMemberDiedBeaconGoOn",sender.id);
	end,
	---------------------------------------------
	Cease = function( self, entity, fDistance )
		entity:SelectPipe(0,"cover_cease_approach"); -- in PipeManagerShared.lua			 
	end,
	---------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"lookaround_30seconds");
	end,
	---------------------------------------------
	DEATH_CONFIRMED = function (self, entity, sender)

		entity:SelectPipe(0,"ChooseManner");
	end,
	---------------------------------------------
	ChooseManner = function (self, entity, sender)

		local XRandom = random(1,3);
		if (XRandom == 1) then
			entity:InsertSubpipe(0,"LookForThreat");			
		elseif (XRandom == 2) then
			entity:InsertSubpipe(0,"RandomSearch");			
		elseif (XRandom == 3) then
			entity:InsertSubpipe(0,"ApproachDeadBeacon");
		end
	end,
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
--	INCOMING_FIRE = function (self, entity, sender)
--		if (entity ~= sender) then
--			entity:SelectPipe(0,"randomhide");
--		end
--	end,
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
	------------------------------ Animation -------------------------------
	target_lost_animation = function (self, entity, sender)
		entity:StartAnimation(0,"enemy_target_lost",0);
	end,
	------------------------------------------------------------------------
	confused_animation = function (self, entity, sender)
		entity:StartAnimation(0,"_headscratch1",0);
	end,
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
		local spot = entity:ProtectSpot();
		if(spot) then
			AI.Signal(SIGNALFILTER_SENDER,0,"PROTECT_THIS_POINT",entity.id,spot);
			return
		end
	end,
	------------------------------------------------------------------------
--	HEADS_UP_GUYS = function (self, entity, sender)
--		-- do nothing on this signal
--	end,
}

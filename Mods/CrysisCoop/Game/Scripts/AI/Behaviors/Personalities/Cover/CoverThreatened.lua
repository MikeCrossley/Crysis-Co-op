--------------------------------------------------
--    Created By: Petar
--   Description: This behaviour is called after the guy hears a scary sound. He is aggitated and know that there
--			is imminent danger.
--------------------------
--   modified by: sten 23-10-2002

AIBehaviour.CoverThreatened = {
	Name = "CoverThreatened",
	alertness = 1,

	Constructor = function (self, entity)
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
		entity:Readibility("ENEMY_TARGET_LOST");
		entity:SelectPipe(0,"search_for_target");
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player

		entity:Readibility("FIRST_HOSTILE_CONTACT",1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if (AI.GetGroupCount(entity.id) > 1) then
			-- only send this signal if you are not alone

			if (entity:NotifyGroup()==nil) then
				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "HEADS_UP_GUYS",entity.id);
				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "wakeup",entity.id);
			end

			entity:SelectPipe(0,"cover_scramble_beacon");
		else
			-- you are on your own
			entity:SelectPipe(0,"cover_scramble");
		end


		if (entity.RunToTrigger == nil) then
			entity:RunToAlarm();
		else
	   	entity:InsertSubpipe(0, "throw_grenade");
		end

	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,
	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	 	entity:SelectPipe(0,"cover_investigate_threat"); 
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,
	OnThreateningSoundHeard = function( self, entity )
		entity:InsertSubpipe(0,"take_cover");
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters

		-- entity:SelectPipe(0,"ApproachSound");
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:InsertSubpipe(0,"hide_sometime");
		
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)	
		entity:Readibility("BULLETRAIN_IDLE");	
	end,

--	---------------------------------------------
--	OnEnemyDamage = function ( self, entity, sender,data)
--		-- called when the enemy is damaged
--
--		AI.LogEvent(entity:GetName().." ONENEMY DAMAGE CoverThreatened");
--		entity:Readibility("GETTING_SHOT_AT",1);
--		if (AI.GetGroupCount(entity.id) > 1) then
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
--		end
--
--		entity:SelectPipe(0,"not_so_random_hide_from",data.id);
--		entity:InsertSubpipe(0,"DropBeaconAt",sender.id);
--	end,


	

	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
		-- called when a member of the group dies

	 	if (entity ~= sender) then
			entity:SelectPipe(0,"AIS_PatrolRunNearCoverGoOn");
	 	end
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)

		-- called for the nearest when a member of the group dies
		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);

		-- do cover stuff here
		-- investigate corpse
		entity:SelectPipe(0,"RecogCorpse",sender.id);
		
		--entity:SelectPipe(0,"AIS_PatrolRunNearCoverGoOn");
		--entity:InsertSubpipe(0,"DropBeaconAt",sender.id);
		
	end,
	---------------------------------------------
	Cease = function( self, entity, fDistance )
		entity:SelectPipe(0,"cover_cease_approach"); -- in PipeManagerShared.lua			 
	end,
	--------------------------------------------------
	AISF_GoOn = function (self, entity, sender)
		entity:SelectPipe(0,"ApproachSound");
	end,
	--------------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"lookaround_30seconds");
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		if (entity ~= sender) then
			AI.SetRefPointPosition(entity.id,sender:GetWorldPos());
			entity:SelectPipe(0,"randomhide","refpoint");
		end
	end,
	---------------------------------------------		
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
	------------------------------ Animation -------------------------------
	target_lost_animation = function (self, entity, sender)
		entity:StartAnimation(0,"enemy_target_lost",0);
	end,
	------------------------------------------------------------------------
	confused_animation = function (self, entity, sender)
		entity:StartAnimation(0,"_headscratch1",0);
	end,
	------------------------------------------------------------------------
}
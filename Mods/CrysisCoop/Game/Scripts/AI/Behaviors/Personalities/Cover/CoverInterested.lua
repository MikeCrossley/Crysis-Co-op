--------------------------------------------------
--    Created By: Petar
--   Description: Activates when the guy feels some movement around him, but is not necesarilly scared
--------------------------
--   last modified by: sten 23-10-2002

AIBehaviour.CoverInterested = {
	Name = "CoverInterested",
	alertness = 1,
	
	
	Constructor = function (self, entity)
		entity:MakeAlerted( 1 );
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		entity:SelectPipe(0,"disturbance_let_it_go");
		entity:InsertSubpipe(0,"HOLSTER_GUN");
	end,


	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		entity:MakeAlerted();

		entity:Readibility("FIRST_HOSTILE_CONTACT");
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if (AI.GetGroupCount(entity.id) > 1) then
			-- only send this signal if you are not alone
			entity:SelectPipe(0,"cover_scramble_beacon");
			entity:InsertSubpipe(0, "notify_player_seen");--for the leader if there is one
			
			if (entity:NotifyGroup()==nil) then
				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "HEADS_UP_GUYS",entity.id);
				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "wakeup",entity.id);
			end

		else
			-- you are on your own
			entity:SelectPipe(0,"cover_pindown");
		end


		if (entity.RunToTrigger == nil) then
			entity:RunToAlarm();
		end


		entity:GettingAlerted();
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	-- use same as CoverIdle
--	OnThreateningSoundHeard = function( self, entity,fDistance )
--		-- called when the enemy hears a scary sound
--		entity:MakeAlerted();
--		entity:SelectPipe(0,"cover_investigate_threat"); 
--		if (fDistance > 20) then 
--			entity:InsertSubpipe(0,"do_it_running");
--		else
--			entity:InsertSubpipe(0,"do_it_walking");
--		end
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		entity:GettingAlerted();
--		entity:Blind_RunToAlarm();
--	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)

		AI.LogEvent(entity:GetName().." ONENEMY DAMAGE CoverInterested");
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0,"cover_goforcover");
		
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0,"cover_goforcover");
		
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)	
		entity:Readibility("BULLETRAIN_IDLE");	
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0,"cover_goforcover");
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
--	OnGroupMemberDied = function( self, entity, sender)
--		-- called when a member of the group dies
--		AIBehaviour.DEFAULT:OnGroupMemberDied(entity,sender);
--
--		if (sender.groupid == entity.groupid) then
--			if (entity ~= sender) then
--		 		entity:SelectPipe(0,"TeamMemberDiedLook");
--		 	end
--		else
--		 	entity:SelectPipe(0,"randomhide");
--		end
--	end,

	--------------------------------------------------
--	OnGroupMemberDiedNearest = function ( self, entity, sender)
--		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);
--		entity:SelectPipe(0,"RecogCorpse",sender.id);
--	end,

	---------------------------------------------
	Cease = function( self, entity, fDistance )
		entity:SelectPipe(0,"cover_cease_investigation"); -- in PipeManagerShared.lua			 
	end,
	---------------------------------------------
	AISF_GoOn = function (self, entity, sender)
		entity:SelectPipe(0,"InvestigateSound");
	end,
	---------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"lookaround_30seconds");
	end,
	--------------------------------------------------
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
	Soundheard = function (self, entity, sender)
		entity:StartAnimation(0,"sSoundheard",0);
	end,
	------------------------------------------------------------------------
	confused_animation = function (self, entity, sender)
		entity:StartAnimation(0,"_chinrub",0);
	end,
	------------------------------------------------------------------------
}
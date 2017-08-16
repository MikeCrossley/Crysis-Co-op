--------------------------------------------------
--    Created By: Petar
--   Description: <short_description>
--------------------------
--

AIBehaviour.CoverRedIdle = {
	Name = "CoverRedIdle",
	alertness = 2,
	

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		AI.Signal(SIGNALFILTER_SUPERGROUP,1,"MEMBER_CONTACT",entity.id);
		if (entity.Covering) then
			entity:SelectPipe(0,"just_shoot");
		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		if (entity.UpdatedHide == nil) then
			entity:InsertSubpipe(0,"hide_forward");
			entity.UpdatedHide = 1;
		end
	end,	
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged	
		if (entity.Covering) then
			entity:SelectPipe(0,"cover_scramble");
		end
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,


	COVER_NORMALATTACK = function (self, entity, sender)
--		local attack_pipe = NOCOVER.GetPipe();
--		entity:SelectPipe(0,"cover_close_wrapper");
--		entity:InsertSubpipe(0,attack_pipe);
	end,

	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		entity.RunToTrigger = 1;
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,

	SELECT_RED = function (self, entity, sender)
	end,

	SELECT_BLACK = function (self, entity, sender)
	end,

	-- GROUP SIGNALS
	---------------------------------------------	
	FORM_RED = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
		entity.Covering = nil;

		entity:SelectPipe(0,"look_at_beacon");
		entity:InsertSubpipe(0,"cover_red_form");
--		if (entity.AI_GunOut==nil) then 
--			entity:InsertSubpipe(0,"DRAW_GUN");
--		end
		entity:HolsterItem(false);
	end,
	---------------------------------------------	
	FORM_BLACK = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
	end,
	---------------------------------------------	
	KEEP_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
	end,
	---------------------------------------------	
	BREAK_FORMATION = function (self, entity, sender)
		-- the team can split
		entity:SelectPipe(0,"cover_scramble");
	end,
	---------------------------------------------	
	SINGLE_GO = function (self, entity, sender)
		-- the team leader has instructed this group member to approach the enemy
	end,
	---------------------------------------------	
	RED_COVER = function (self, entity, sender)
		-- the team leader has instructed this group member to cover his friends
		entity:TriggerEvent(AIEVENT_CLEAR);
		entity:SelectPipe(0,"dumb_shoot");
	end,
	---------------------------------------------	
	RED_IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
		if (entity == sender) then
			entity.Covering = 1;
--			local attack_pipe = NOCOVER.GetPipe();
--			entity:SelectPipe(0,"cover_close_wrapper");
--			entity:InsertSubpipe(0,attack_pipe);
		end
	end,
	---------------------------------------------	
	BLACK_IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
	end,
	---------------------------------------------	
	GROUP_SPLIT = function (self, entity, sender)
		-- team leader instructs group to split
	end,
	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
		entity.Covering = nil;
		entity.UpdatedHide = nil;
		entity:SelectPipe(0,"red_cover_pindown");
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
}
--------------------------------------------------
--    Created By: Petar
--   Description: <short_description>
--------------------------
--

AIBehaviour.CoverForm = {
	Name = "CoverForm",


	OnLowHideSpot = function( self, entity, sender)
		entity:SelectPipe(0,"dig_in_attack");
	end,

	---------------------------------------------
	HOLD_POSITION = function( self, entity, sender )
		-- select random attack pipe		
		NOCOVER:SelectAttack(entity);
		entity:Readibility("THREATEN",1);
	end,	



	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnSpawn = function( self, entity )
		-- called when enemy spawned or reset
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
	--	if (entity.AI_COVERING==nil) then
	--		entity:InsertSubpipe(0,"shoot_cover");
	--	end
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
		entity:SelectPipe(0,"cover_hideform");
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
	OnDeath = function( self, entity )
		-- called when a member of the group dies
		AI:Signal(SIGNALFILTER_GROUPONLY,1,"OnGroupMemberDied",entity.id);
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	---------------------------------------------
	OnNoFormationPoint = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
		entity:SelectPipe(0,"shoot_cover");
		entity:InsertSubpipe(0,"cover_form_wait");
	end,	
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"take_cover");
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
		entity:InsertSubpipe(0,"take_cover");
	end,
	--------------------------------------------------
	OnVehicleDanger = function(self, entity, sender, signalData)
		-- just ignore this signal and avoid default processing.
		-- we don't want to "scare" them now by their own vehicles
	end,
	--------------------------------------------------


	COVER_NORMALATTACK = function ( self, entity, sender)
	end,


	COVER_FORM_ATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"cover_form_comeout");
		entity.AI_COVERING = 1;
	end,

	FORM_STOP_COVERING = function (self, entity, sender)
		entity.AI_COVERING = nil;
		entity:SelectPipe(0,"cover_crouchfire");
	end,

	WaitForTarget = function (self, entity, sender)
		entity:SelectPipe(0,"cover_crouchfire");
	end,


	-- GROUP SIGNALS
	---------------------------------------------	
	KEEP_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
		entity:Readibility("ORDER_RECEIVED",1);
		entity:SelectPipe(0,"cover_hideform");
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
}
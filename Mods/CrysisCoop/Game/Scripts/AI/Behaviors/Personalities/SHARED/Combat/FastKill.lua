--------------------------------------------------
-- FastKill
--------------------------
--   created: Kirill Bulatsev 27-10-2006
--
--------------------------	
--   Description: 	Just eleminate target as fast as possible - no hiding/moving, just shoot/kill 
--------------------------

AIBehaviour.FastKill = {
	Name = "FastKill",
	Base = "Dumb",
	alertness = 1,

	-----------------------------------------------------
	Constructor = function (self, entity)

		AI.SmartObjectEvent( "CallReinforcement", entity.id );

		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);

		entity:SelectPipe(0,"just_shoot_kill");
	end,


	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	-----------------------------------------------------
	FASTKILL_DONE = function(self,entity)
		entity:SelectPipe(0,"just_shoot_done");
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
	end,
	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
--		AI.Signal(SIGNALFILTER_SENDER,1,"FASTKILL_DONE",entity.id);	
	end,
	---------------------------------------------
	COMBAT_READABILITY = function (self, entity, sender)
	end,
	---------------------------------------------
	SELECT_ADVANCE_POINT = function (self, entity, sender)
	end,
	---------------------------------------------
	ADVANCE_NOPATH = function (self, entity, sender)
	end,
	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
	end,
	---------------------------------------------
	OnTargetFleeing	= function (self, entity)
	end,
	--------------------------------------------------
	OnAdvanceTargetCompromised = function(self, entity, sender, data)
	end,
	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
--		AI.Signal(SIGNALFILTER_SENDER,1,"FASTKILL_DONE",entity.id);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:SelectPipe(0,"just_shoot_kill");	
	end,
	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT	= function( self, entity, fDistance )
		entity:SelectPipe(0,"just_shoot_kill");	
	end,
	
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:SelectPipe(0,"just_shoot_advance");	
	end,
	---------------------------------------------
	OnNoTargetVisible = function( self, entity )
		entity:SelectPipe(0,"just_shoot_advance");	
	end,
	
	
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
--		AI.Signal(SIGNALFILTER_SENDER,1,"FASTKILL_DONE",entity.id);	
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function(self, entity)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function (self, entity, sender, data)
	end,
	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
	end,
	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	------------------------------------------------------------------------
	HEADS_UP_GUYS = function(self,entity,sender)
	end,
	---------------------------------------------
	OnBadHideSpot = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
	end,	
	--------------------------------------------------
	OnOutOfAmmo = function (self,entity, sender)
		entity:Reload();	
	end,
	--------------------------------------------------
	OnFriendInWay = function(self, entity)
--		if(AI.GetNavigationType(entity.id) ~= NAV_WAYPOINT_HUMAN) then
		if(entity.AI.lastFriendInWayTime and (_time - entity.AI.lastFriendInWayTime) > 4.0) then
			entity:Readibility("during_combat",1,1,0.6,1);
			local r = random(1,20);
			if(r < 5) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_short_shoot");
			elseif(r < 10) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_shoot");
			elseif(r < 15) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_short_shoot");
			else
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_shoot");
			end
			entity.AI.lastFriendInWayTime = _time;
		end
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
--		if(AI.GetNavigationType(entity.id) ~= NAV_WAYPOINT_HUMAN) then
		if(entity.AI.lastPlayerLookingTime and (_time - entity.AI.lastPlayerLookingTime) > 6.0) then
			entity:Readibility("during_combat",1,1,0.6,1);
			local r = random(1,20);
			if(r < 5) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_short_shoot");
			elseif(r < 10) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_right_shoot");
			elseif(r < 15) then
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_short_shoot");
			else
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_adjust_pos_left_shoot");
			end
			entity.AI.lastPlayerLookingTime = _time;
		end
	end,

	--------------------------------------------------
	MAN_DOWN = function(self, entity)
	end,

	--------------------------------------------------
	FASTKILL = function(self, entity)
		entity:SelectPipe(0,"just_shoot_kill");	
	end,
	
	-----------------------------------------------------
}

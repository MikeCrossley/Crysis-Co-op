--------------------------------------------------
--    Created By: Dejan Pavlovski
--   Description: <short_description>
--------------------------
--

AIBehaviour.GroupSearch = {
	Name = "GroupSearch",
	TASK = 1,
	alertness = 1,

	Constructor = function ( self, entity )
	  AI.LogEvent("Constructor of GroupSearch "..entity:GetName());

		entity:HolsterItem(false);
		
 	  entity:SelectPipe(0, "stay_hidden");--clear all current goals
 	  entity:SelectPipe(0, "random_look_around");
    entity:InsertSubpipe(0, "order_search");
	end,


--	NotifyPlayerSeen = function( self, entity, sender )
		-- TODO: something
--	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- data.id: the shooter
		entity:InsertSubpipe(0, "bodypos_crouch_or_prone");
		do return end;
	end,

	CORD_ATTACK = function( self, entity, sender )
		-- Ignore this order!
	end,

	---------------------------------------------	
	-- Orders --
	---------------------------------------------

	ORDER_SEARCH = function ( self, entity, sender, data )
	  AI.LogEvent("ORDER_SEARCH received in GroupSearch of "..entity:GetName());
		AI.SetRefPointPosition(entity.id, data.point);
 	  entity:SelectPipe(0, "stay_hidden");--clear all current goals
 	  entity:SelectPipe(0, "random_look_around");
    entity:InsertSubpipe(0, "order_search");
	end,



	ORD_DONE = function( self, entity, sender )
		AI.LogEvent("ORD_DONE received: "..entity:GetName());
	end,

	order_search_begin = function( self, entity, sender )
	  AI.LogEvent("order_search BEGIN "..entity:GetName());
	end,

	order_search_end = function( self, entity, sender )
	  AI.LogEvent("order_search END "..entity:GetName());
	end,

	order_timeout_begin = function( self, entity, sender )
	  AI.LogEvent("order_timeout BEGIN "..entity:GetName());
	end,

	order_timeout_end = function( self, entity, sender )
	  AI.LogEvent("order_timeout END "..entity:GetName());
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
		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);
		entity:InsertSubpipe(0, "notify_player_seen");
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees something that it cant identify
		entity:InsertSubpipe(0, "notify_threatened");
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
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." received OnGroupMemberDied");
		entity:CheckReinforcements();
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	
	---------------------------------------------
	OnLeaderDied = function ( self, entity, sender)
		entity.AI.InSquad = 0;
		entity:SelectPipe(0,"cover_pindown");
	end,

	--------------------------------------------------

	-- GROUP SIGNALS
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
}
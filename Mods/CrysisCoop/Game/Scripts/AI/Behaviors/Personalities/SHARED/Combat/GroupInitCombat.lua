--------------------------------------------------
--    Created By: Dejan Pavlovski
--   Description: <short_description>
--------------------------
--

AIBehaviour.GroupInitCombat = {
	Name = "GroupInitCombat",
	TASK = 1,
	alertness = 2,

	Constructor = function ( self, entity )

 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
		entity:SelectPipe(0, "random_reacting_timeout");
--   	entity:InsertSubpipe(0, "throw_grenade");
    entity:InsertSubpipe(0, "order_initial_fire");
    entity:CheckReinforcements();
		entity:MakeAlerted();
--		if (random(1,2) == 1) then
--			entity:InsertSubpipe(0, "bodypos_crouch");
--		else
--			entity:InsertSubpipe(0, "bodypos_prone");
--		end
	end,

	Destructor = function ( self, entity )
		entity:InsertSubpipe(0, "bodypos_crouch");
	end,


	NotifyPlayerSeen = function( self, entity, sender )
		-- Already notified
	end,

	---------------------------------------------
	OnDamage = function( self, entity, sender )
		entity:Readibility("GETTING_SHOT_AT",1);

	end,
	
	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender, data)
		entity:Readibility("GETTING_SHOT_AT",1);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		entity:InsertSubpipe(0, "bodypos_crouch_or_prone");
	end,

	CORD_ATTACK = function( self, entity, sender )
		-- Ignore this order!
	end,

	---------------------------------------------	
	-- Orders --
	---------------------------------------------



	ORD_DONE = function( self, entity, sender )
		AI.LogEvent("ORD_DONE received: "..entity:GetName());
	end,

	order_hide_begin = function( self, entity, sender )
	  AI.LogEvent("order_hide BEGIN "..entity:GetName());
	end,

	order_hide_end = function( self, entity, sender )
	  AI.LogEvent("order_hide END "..entity:GetName());
	end,

	order_fire_begin = function( self, entity, sender )
	  AI.LogEvent("order_fire BEGIN "..entity:GetName());
	end,

	order_fire_end = function( self, entity, sender )
	  AI.LogEvent("order_fire END "..entity:GetName());
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
--		entity:InsertSubpipe(0, "DropBeaconAt");
	end,
	---------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees something that it cant identify
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
		entity:InsertSubpipe(0, "reload_combat");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
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
	end,

	---------------------------------------------
	OnLeaderActionCompleted = function(self,entity,sender,data)
		-- sent by CLeader when the action is completed
		-- in this case it would be LeaderAction_Attack
		-- data.id = group's live attention target 
		-- data.ObjectName = group's attention target name
		if(data.id ==NULL_ENTITY) then
			g_SignalData.point.x = 0;
			g_SignalData.point.y = 0;
			g_SignalData.point.z = 0;
			g_SignalData.iValue = UPR_COMBAT_GROUND;
			AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
		end
	end,

}
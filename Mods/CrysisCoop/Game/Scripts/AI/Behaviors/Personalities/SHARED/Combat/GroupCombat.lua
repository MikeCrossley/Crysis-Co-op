--------------------------------------------------
--    Created By: Dejan Pavlovski
--   Description: <short_description>
--------------------------
--

AIBehaviour.GroupCombat = {
	Name = "GroupCombat",
	TASK = 1,
	alertness = 2,

	Constructor = function ( self, entity )
	  AI.LogEvent("Constructor of GroupCombat "..entity:GetName());

 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
		entity:SelectPipe(0, "stay_hidden");
    entity:InsertSubpipe(0, "order_hide");
    entity:CheckReinforcements();
		entity:MakeAlerted();
  --  if (entity.Properties.bIsLeader == false) then
	--	end
	end,

	
	---------------------------------------------
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
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:InsertSubpipe(0, "bodypos_crouch_or_prone");
		do return end;

--		local shooter = System.GetEntity(data.id);
--		if (shooter ~= nil) then
--			-- shooter is an enemy, otherwise it wouldn't be in this signal
--			local pos1 = shooter:GetPos();
--			local pos2 = entity:GetPos();
--			
--			local x = pos1.x - pos2.x;
--			local y = pos1.y - pos2.y;
--			local z = pos1.z - pos2.z;
--			local fDistance2 = x*x+y*y+z*z;
--			if (fDistance2 < 400) then
--	  	  entity:SelectPipe(0, "do_nothing");--clear all current goals
--				entity:SelectPipe(0, "stay_hidden");
--    		entity:InsertSubpipe(0, "order_hide");
----				entity:InsertSubpipe(0, "hide_from_new_target", shooter.id);
--			else
--  		  entity:SelectPipe(0, "do_nothing");--clear all current goals
--				entity:SelectPipe(0, "stay_hidden");
--    		entity:InsertSubpipe(0, "order_hide");
----				entity:InsertSubpipe(0, "hide_from_new_target", shooter.id);
--			end
--		end

	end,

	CORD_ATTACK = function( self, entity, sender )
		-- Ignore this order!
	end,

	---------------------------------------------	
	-- Orders --
	---------------------------------------------



	ORDER_FIRE = function( self, entity )
		-- this checks for mounted weapons around and uses them
--		AIBehaviour.DEFAULT:SHARED_FIND_USE_MOUNTED_WEAPON( entity );
		
	  entity:SelectPipe(0, "do_nothing");--clear all current goals
		entity:SelectPipe(0, "random_reacting_timeout");
   	entity:InsertSubpipe(0, "throw_grenade");
   	entity:InsertSubpipe(0, "order_fire");
  end,

	ORDER_HIDE = function( self, entity, sender, data )
--		System.Log(entity:GetName().." HIDING AT "..Vec2Str(data.point));
		AI.SetRefPointPosition(entity.id, data.point);
 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
		entity:SelectPipe(0, "stay_hidden");
    entity:InsertSubpipe(0, "order_hide");
		entity:InsertSubpipe(0, "clear_all");
	end,

--	ORD_DONE = function( self, entity, sender )
--		AI.LogEvent("ORD_DONE received: "..entity:GetName());
--	end,
--
--	order_hide_begin = function( self, entity, sender )
--	  AI.LogEvent("order_hide BEGIN "..entity:GetName());
--	end,
--
--	order_hide_end = function( self, entity, sender )
--	  AI.LogEvent("order_hide END "..entity:GetName());
--	end,
--
--	order_fire_begin = function( self, entity, sender )
--	  AI.LogEvent("order_fire BEGIN "..entity:GetName());
--	end,
--
--	order_fire_end = function( self, entity, sender )
--	  AI.LogEvent("order_fire END "..entity:GetName());
--	end,
--
--	order_timeout_begin = function( self, entity, sender )
--	  AI.LogEvent("order_timeout BEGIN "..entity:GetName());
--	end,
--
--	order_timeout_end = function( self, entity, sender )
--	  AI.LogEvent("order_timeout END "..entity:GetName());
--	end,


	-- SYSTEM EVENTS			-----
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);

		-- called when the enemy sees a living player
		entity:InsertSubpipe(0, "DropBeaconAt");
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
		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);

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
		AI.LogEvent(entity:GetName().." received OnGroupMemberDied");
		entity:CheckReinforcements();

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
--		entity:InsertSubpipe(0, "hide_on_bullet_rain");
	end,
	
	---------------------------------------------
	OnLeaderDied = function ( self, entity, sender)
		entity.AI.InSquad = 0;
		entity:SelectPipe(0,"cover_pindown");
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
	
	---------------------------------------------
	INCOMING_FIRE = function(self, entity, sender)
	end,

}
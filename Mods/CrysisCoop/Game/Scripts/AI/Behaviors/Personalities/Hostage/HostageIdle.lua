--------------------------------------------------
--   Description: the idle behaviour for an Hostage
-- Created by: Luciano Morpurgo
--------------------------



AIBehaviour.HostageIdle = {
	Name = "HostageIdle",
	Base = "HBaseIdle",
	-- TASK = 1, 

	Constructor = function(self, entity)
	
	--	AI.SetSpeciesThreatMultiplier(entity.id,0);	
		entity:SelectPipe(0,"do_nothing");
--		entity:InsertSubpipe(0,"ignore_all");
		entity:InsertSubpipe(0,"do_it_standing");
		entity.AI.Cower = false;
		AI.SetPFProperties(entity.id, AIPATH_HUMAN_COVER);
		AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Civilian );

	end,	

	---------------------------------------------
	Destructor = function(self,entity)
		if(entity.iLookTimer) then 
			Script.KillTimer(entity.iLookTimer);
			entity.iLookTimer = nil;
		end
	end,

	--------------------------------------------------
	OnCloseContact = function( self, entity, bender )
	
	end,
	
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		AI.LogEvent("OnNoObjectSeen ivalue="..signalData.iValue);

		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance <= 40) then
				--entity:Readibility("GRENADE_SEEN",1);
				AI.LogEvent("GRENADE SEEN");
				entity:InsertSubpipe(0, "grenade_seen");
			end
		end
	end,
	
	---------------------------------------------

	
	OnPlayerDied = function( self, entity, sender )
		entity:Readibility("CAPTAIN_YOU_OK", 1);
	end,
	
	OnSquadmateDied = function( self, entity, sender )
		entity:Readibility("MAN_DOWN", 1);
	end,
	
	OnTargetDead = function( self, entity, sender )
	end,

	
	HANG_ON = function( self, entity, sender )
	end,
	
	---------------------------------------------

	RESUME_FOLLOWING = function(self,entity)
		self:ORDER_FORM(entity);
	end,

	---------------------------------------------
	ORDER_FORM = function( self, entity )	
		entity.AI.InSquad = 1;
	end,

	---------------------------------------------

	ORDER_MOVE = function( self, entity,sender,data )
		if(data and data.point) then
			AI.SetRefPointPosition(entity.id,data.point);
		end
		if(data and data.iValue==1) then
			entity:SelectPipe(0,"order_move_MT",data.ObjectName);
		else
			entity:SelectPipe(0,"order_move");
		end
		entity:InsertSubpipe(0,"do_it_running");
		entity:InsertSubpipe(0,"clear_all");
	end,

	---------------------------------------------

	OnSeenByEnemy = function( self, entity, sender )
--		entity:Readibility("THEY_SAW_US", 1);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player	

		entity:Readibility("first_contact_whispered", 1);


	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player

		entity:Readibility("IDLE_TO_INTERESTED");

	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:Readibility("IDLE_TO_INTERESTED");
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound

		entity:Readibility("IDLE_TO_THREATENED",1);
--		if(not entity.bIgnoreEnemy) then 
--			entity:SelectPipe(0,"random_reacting_timeout");
--			entity:InsertSubpipe(0,"notify_enemy_seen");
--		end

	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the entity is damaged by enemy fire
		-- data.id = shooter id
		-- data.fValue = received damage
		entity:Readibility("GETTING_SHOT_AT",1);
		entity.AI.Cower = true;
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_cower");
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender,data)
		entity.AI.Cower = true;
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_cower");
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity.AI.Cower = true;
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_cower");
	end,

	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		-- call the default to do stuff that everyone should do

	end,

	---------------------------------------------	
	OnSomebodyDied	 = function( self, entity, sender)
	
	end,
	--------------------------------------------------
	
	FORMATION_REACHED = function (self, entity, sender)
		entity:SelectPipe(0,"stay_in_formation");
	end,

	---------------------------------------------	

	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)
		AIBehaviour.SquadIdle:ORDER_ENTER_VEHICLE(entity,sender,data);
	end,
	ORDER_EXIT_VEHICLE	= function (self, entity, sender,data)
		AIBehaviour.SquadIdle:ORDER_EXIT_VEHICLE(entity,sender,data);
	end,

--	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)
--		-- data.id = vehicle id
--		-- data.point = vehicle destination point
--		--AI.LogEvent(entity:GetName().." ENTERING VEHICLE");
--		-- hostage can't be the driver
--		entity.AI.theVehicle = System.GetEntity(data.id);
--	 	if(entity.AI.theVehicle==nil) then
--	 		-- no vehicle found
--	 		do return end
--	 	end
--		
--		entity.AI.mySeat = entity.AI.theVehicle:RequestSeatByPosition(entity.id);
--		if(entity.AI.mySeat==nil) then
--			AI.Signal(SIGNALFILTER_LEADER, 0,"EnterVehicleAborted",entity.id);
--			AI.Signal(SIGNALFILTER_SENDER, 0,"GOTO_FIRST",entity.id);
--			do return end
--		end
--		
--		AI.SetRefPointPosition(entity.id,entity.AI.theVehicle:GetSeatPos(entity.AI.mySeat));		
--
--		AI.Signal(SIGNALFILTER_SENDER, 0,"ENTERING_VEHICLE",entity.id);
--
--	end,

	
	--------------------------------------------------------------
	FOLLOW_LEADER = function(self,entity,sender,data)
		entity.AI.InSquad= 1;
		g_SignalData.ObjectName = "line_follow2";--formation to be used if not in follow mode
		g_SignalData.iValue = 1;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnJoinTeam",entity.id,g_SignalData);
	end,

	---------------------------------------------
	ACT_FOLLOW = function( self, entity,sender,data )
		AIBehaviour.SquadIdle:ACT_FOLLOW(entity,sender,data )
	end,
	---------------------------------------------
	LOOK_LEFT = function(self,entity,sender)
	end,
	---------------------------------------------
	LOOK_RIGHT = function(self,entity,sender)
	end,
	---------------------------------------------
	CheckLook = function (entity,timerId)
		--Script.KillTimer(timerId);
		if (entity.lookLeft ==nil) then
			entity.lookLeft = false;
		end
		entity.lookLeft = not entity.lookLeft;
		if(entity.lookLeft) then
			entity.Behaviour:LOOK_LEFT(entity,entity);
		else
			entity.Behaviour:LOOK_RIGHT(entity,entity);
		end

		entity.iLookTimer = Script.SetTimerForFunction(math.random(3000,4500),"AIBehaviour.HostageIdle.CheckLook",entity)
		
	end,
	
	---------------------------------------------
	OnPlayerLooking = function(self,entity,sender,data)
		-- data.fValue = player distance
--		AI.LogEvent("Player looking at "..entity:GetName());
		if(DialogSystem.IsEntityInDialog(entity.id)) then return end		
		if(data.fValue<6) then 
			-- react, readability
			entity:Readibility("staring",1,0,1,2);
			entity:SelectPipe(0,"look_at_player");			
		end
	end,

	---------------------------------------------
	OnPlayerLookingAway = function(self,entity,sender,data)
--		-- data.fValue = player distance
--		AI.LogEvent("Player looking away from "..entity:GetName());
		if(DialogSystem.IsEntityInDialog(entity.id)) then return end		
		entity:SelectPipe(0,"stand_only");
		entity:InsertSubpipe(0,"clear_all");
		entity:InsertSubpipe(0,"reset_lookat");
		entity:InsertSubpipe(0,"random_timeout");
	end,

	---------------------------------------------
	OnPlayerSticking = function(self,entity,sender,data)
		-- data.fValue = player distance
--		AI.LogEvent("Player sticking to "..entity:GetName());
		if(DialogSystem.IsEntityInDialog(entity.id)) then return end
			-- react, readability
		entity:Readibility("staring",1,0,1,2);
		entity:SelectPipe(0,"look_at_player");			
	end,

	----------------------------------
	OnPlayerGoingAway = function(self,entity,sender,data)
--		-- data.fValue = player distance
		AI.LogEvent("Player going away from "..entity:GetName());
		AIBehaviour.SquadIdle:OnPlayerLookingAway(entity,sender,data);
	end,
}

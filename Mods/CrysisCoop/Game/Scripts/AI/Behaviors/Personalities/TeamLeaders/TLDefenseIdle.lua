--------------------------------------------------
--    Created By: Petar
--   Description: <short_description>
--------------------------
--

AIBehaviour.TLDefenseIdle = {
	Name = "TLDefenseIdle",
	switched = 0,

	Constructor = function( self, entity )
--		if (self.Properties.bIsLeader == 1) then
			AI.Signal(SIGNALFILTER_SUPERGROUP, 0, "JOIN_TEAM", entity.id);
--		end
	end,

	OnStartPanicking = function( self, entity, sender)
		AI.Signal(SIGNALFILTER_LEADER, 1, "OnAbortAction", entity.id);
		entity:SelectPipe(0, "bridge_destroyed");
		entity:InsertSubpipe(0, "bridge_destroyed_init");
	end,
	
	OnStopPanicking = function( self, entity, sender)
		entity:SelectPipe(0, "bridge_destroyed_wait");
		AI.Commander:NC_PanicDone( entity );
	end,
	
	NotifyPlayerSeen = function( self, entity, sender )
		AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id);
		AI.Signal(SIGNALFILTER_SUPERSPECIES, 1, "NC_PlayerSeen", entity.id);
	end,
	
	NotifyThreatened = function( self, entity, sender )

		AI.Commander:StopVehicles();
		AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_SEARCH", entity.id);
	end,


	-- COMMANDER ORDERS --
	----------------------
	
	CORD_FOLLOW = function( self, entity )
	end,
	
	CORD_ATTACK = function( self, entity )
		-- for GroupCombat:
		
--	AI.CreateGoalPipe("force_player_pos");
--	AI.PushGoal("force_player_pos", "locate",1,"player");
--	AI.PushGoal("force_player_pos", "acqtarget",1,"");	
		
		
		AI.LogEvent("\nSignal CORD_ATTACK received!!! "..entity:GetName().."\n");
--		entity:SelectPipe(0, "random_reacting_timeout");
--		entity:InsertSubpipe(0, "notify_player_seen");
--		entity:InsertSubpipe(0, "force_player_pos");
		AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id);
	
	end,
	
	CORD_GOTO = function( self, entity, position )
		AI.LogEvent("\nSignal CORD_GOTO received!!!\nposition = "..tostring(position).."\n");
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
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		local groupCount=AI.GetGroupCount(entity.id);

		-- dont say anything if no group left alive
		if (groupCount >= 2) then
			AI.Signal(SIGNALID_READIBILITY, 1, "LO_DEFENSIVE",entity.id);	
		end

--		local protection = AI.FindObjectOfType(entity:GetPos(),20,AIAnchorTable.AIANCHOR_PROTECT_THIS_POINT);
----		if (protection==nil) then
----			Hud:AddMessage("[AIWARNING] Defensive leader "..entity:GetName().." has no spot to protect");
----			--do return end;
----		end
----
--
--		entity:SelectPipe(0,"defense_keepcovered");
--		if (entity.AI.PlayerEngaged ==nil ) then 		
--			if (protection) then
--				entity:InsertSubpipe(0,"defend_point",protection);
--			else
--				entity:InsertSubpipe(0,"defend_point");
--			end
--			entity:InsertSubpipe(0,"setup_combat");
--			entity:InsertSubpipe(0,"DRAW_GUN");
--		end

		entity.AI.PlayerEngaged = 1;	
			
		-- for GroupCombat:
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"notify_player_seen");

	end,
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance <= 40) then
				--entity:Readibility("GRENADE_SEEN",1);
				if (not entity.Behaviour.alertness) then
					entity:SelectPipe(0, "do_nothing");
				end
				entity:InsertSubpipe(0, "grenade_seen");
			end
		end
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)
		entity:SelectPipe(0, "random_look_around");
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
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		entity:InsertSubpipe(0,"take_cover");
	end,
	---------------------------------------------
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." received OnGroupMemberDied");
		entity:CheckReinforcements();

	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- select random attack pipe		
		NOCOVER:SelectAttack(entity);
		entity:Readibility("THREATEN",1);
	end,	

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity:SelectPipe(0, "random_look_around");
		entity:InsertSubpipe(0, "notify_threatened");
	end,
	--------------------------------------------------
	
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	

	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnDeath = function ( self, entity)
		AIBehaviour.DEFAULT:OnDeath(entity,sender);
		-- called when the enemy is damaged
		AI.Signal(SIGNALFILTER_SUPERGROUP,1,"BREAK_FORMATION",entity.id);
	end,
	---------------------------------------------
	KeepToSameCover = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:SelectPipe(0,"defense_keepcovered");
		
	end,


	-- GROUP SIGNALS
	---------------------------------------------	
	KEEP_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
		entity:SelectPipe(0,"standfire");
	end,

	---------------------------------------------	
	HEADS_UP_GUYS = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
		self:OnPlayerSeen(entity,0);
	end,


	-- ORDER SIGNALS
	------------------------------------------------
	ORDER_TRANSPORT_ITEM = function (self, entity, sender,data)

		AI.LogEvent("ORDER_TRANSPORT_ITEM received");
		if(data==nil or data.id==nil or data.id==0 or data.point==nil or data.ObjectName==nil or data.ObjectName=="") then
			AI.Warning("Wrong data type in leader's ORDER_TRANSPORT");
			do return end
		end

		entity.transportedItem  = System:GetEntityByName(data.ObjectName);
		if(entity.transportedItem  ==nil) then
			AI.Warning("Transportable item not found in leader's ORDER_TRANSPORT");
			do return end
		end

		entity.OrderData = new(data);

		local vehicle = System:GetEntity(entity.orderData.id);
		local numPeople = VC.GetNumberOfSeats(vehicle)-1;-- -> including leader
		
		entity.myTeamList = new(g_Tables.nullList);
		
		numPeople = BasicAI:FormGroup(entity,entity.myTeamList, numPeople, AI:GetGroupOf(entity.id), AIOBJECTFILTER_SAMESPECIES + AIOBJECTFILTER_SAMEGROUP);

		-- TO DO: manage the number of people required to bring the item (using anchors on the item,
		-- selecting the first N guys closest to the item etc)

		local myGroupID = AI.GetGroupOf(entity.id);
	

		local i;
		local teammate;			
		local picker;
		local driver;

		if(numPeople > 0) then
			-- at least another guy who can execute my order
		
			entity.selectedMember = nil;
			local vpos = entity.transportedItem:GetWorldPos();
			local minDist = 100000;

			entity.currentOrder = AITaskPlans.TransportItem;

			--  find the closest guy to the item
			for i=1,numPeople do
				teammate = entity.myTeamList[i];
--				AI.LogEvent(sprintf("Changing group ID of entity %s to %i",teammate:GetName(),myGroupID));
				--AI.ChangeParameter( teammate.id, AIPARAM_GROUPID,myGroupID);

				local dist = LengthSqVector(DifferenceVectors(teammate:GetPos(),vpos));
				if(dist < minDist) then
					minDist = dist;
					picker = teammate;
				end
			end

			--  find the closest guy to the vehicle - TO DO: to the driver seat
		
			local vpos =  vehicle:GetWorldPos();
			local minDist = 100000;
	
			for i=1,numPeople do
				teammate = entity.myTeamList[i];
	--				AI.LogEvent(sprintf("Changing group ID of entity %s to %i",teammate:GetName(),myGroupID));
				--AI.ChangeParameter( teammate.id, AIPARAM_GROUPID,myGroupID);
				if(teammate ~= picker) then
					local dist = LengthSqVector(DifferenceVectors(teammate:GetPos(),vpos));
					if(dist < minDist) then
						minDist = dist;
						driver = teammate;
					end
				end
			end
			
			OrderIssuerIDs[1] = picker.id;
			OrderIssuerIDs[2] = driver.id;
						
						
--			if(entity.selectedMember~=nil) then
--				AI.Signal(SIGNALFILTER_SENDER,0,"ORDER_LOAD_VEHICLE",entity.selectedMember.id, data);
--			end
				
--		else
--			AI.LogEvent("Not enough team members to execute order transport");
		end
		
	end,
	
	-----------------------------------------------------------------------
	FORMATION_REACHED = function (self, entity, sender)
	
		entity:SelectPipe(0,"stay_in_formation_moving");
		entity:InsertSubpipe(0,"do_it_walking");
	end,
	
	-----------------------------------------------------------------------
	STOP_FORMATION = function (self, entity, sender)
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"stop_formation_delay");
	end,
	
	STOP_MOVING = function (self, entity, sender)
		AI.LogEvent("STOOOOOOOOOOOOOOOOOOOOP");
		entity:Readibility("STOP_MOVING",1);
	end,
}

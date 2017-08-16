--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--   Description: the base idle (default) behaviour for humans. All the human classes should derive their 
--	idles from this
--  
--------------------------------------------------------------------------
--  History:
--  - 08/nov/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------



AIBehaviour.HBaseIdle = {
	Name = "HBaseIdle",

	Constructor = function(self,entity)
		AI.LogEvent(entity:GetName().." HBaseIdle constructor");
		entity:InitAIRelaxed();
		if(AI.GetLeader(entity.id)) then 
	--		g_SignalData.iValue = UPR_COMBAT_GROUND;
	--		AI.Signal(SIGNALFILTER_LEADER, 10, "OnSetUnitProperties", entity.id,g_SignalData);
			entity.AI.InSquad = 1;
--			AI.Signal(SIGNALFILTER_SENDER, 1, "JOIN_TEAM", entity.id);
		end
		
		-- set combat class
		if ( entity.inventory:GetItemByClass("LAW") ) then
			AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.InfantryRPG );
		else
			AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Infantry );
		end
	end,	
	
	Destructor = function(self,entity)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitResumed",entity.id);
	end,
	
	OnQueryUseObject = function ( self, entity, sender, extraData )
--AI.LogEvent("OnQueryUseObject "..entity:GetName());
		local weapon = System.GetEntity( extraData.id );
		if (weapon) then
--AI.LogEvent("    using mounted weapon "..sender:GetName());
--if(sender.Use)then
--AI.LogEvent("<<<<<< sender has use");
--end
--			if(weapon.reserved ==nil) then 
--				weapon.reserved = entity;
--				entity.AI.current_mounted_weapon = weapon;
--				AI.Signal(SIGNALFILTER_SENDER, 0, "USE_MOUNTED_WEAPON", entity.id);
--			end
--AI.LogEvent(" a  "..entity:GetName().." will use MOUNTED WEAPON!!!");
		end
	end,

	OnStartPanicking = function( self, entity, sender)
		entity:SelectPipe(0, "bridge_destroyed");
		entity:InsertSubpipe(0, "bridge_destroyed_init");
	end,
	
	OnStopPanicking = function( self, entity, sender)
		entity:SelectPipe(0, "bridge_destroyed_wait");
	end,

	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
		entity:SelectPipe(0,"just_shoot");
		entity:InsertSubpipe(0,"do_it_standing");
	end,
		
	--------------------------------------------
	MOUNTED_WEAPON_DAMAGE_ALERT = function(self,entity,sender,data)
		-- data: see OnEnemyDamage
		AIBehaviour.HBaseIdle:OnEnemyDamage(entity,sender,data);
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ALERT",entity.id);
	end,
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		-- data.iValue = target AIObject type
		-- data.id = target.id
		-- data.point = target position
		-- data.point2 = target velocity

		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

		if (signalData.iValue == AIOBJECT_GRENADE) then

			if(AI_Utils:ReactToDanger(entity, signalData.point, signalData.point2)) then
				entity:InsertSubpipe(0,"devalue_target");
			end
		end
	end,

	--------------------------------------------------
	OnGrenadeDanger = function( self, entity, sender, signalData )
		-- called when grenade collides within 20m
		-- data.point = (predicted, or actual) grenade position
		-- data.point2 = grenade velocity (zero if position is predicted)
		-- data.id = grenade entity id
--		if(signalData) then
			AI_Utils:ReactToDanger(entity, signalData.point);
			entity:Readibility("incoming",0,5);
--		else	-- when this comes thro SendAnonymousSignal - there is no sender, so signalData will be in the sender table
--			AI_Utils:ReactToDanger(entity, sender.point, sender.point2, g_Vectors.v000);		
--		end
	end,
	
	--------------------------------------------------
	OnVehicleDanger = function(self, entity, sender, data)
		if(sender and sender~=entity) then
			if(IsNotNullVector(data.point2)) then 
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
				if (AI.Hostile(entity.id, sender.id)) then
					entity:SelectPipe(0,"vehicle_danger");
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_AVOIDVEHICLE",entity.id);
				else
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE, "vehicle_danger");
				end
			end
		end
	end,
	
	--------------------------------------------------
	END_VEHICLE_DANGER = function(self, entity, sender)
		-- empty
	end,

	--------------------------------------------------
	LeaveMG = function(self,entity)
		if(AI.GetAttentionTargetOf(entity.id)) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,

	---------------------------------------------
	OnExplosionDanger = function(self,entity,sender,data)
		--data.id = exploding entity
--		Log(entity:GetName().." OnExplosionDanger");
		local	ent = System.GetEntity(data.id);
		if(ent) then
			local targetPos = g_Vectors.temp;
			ZeroVector(targetPos);
			if(not AI.GetAttentionTargetPosition(entity.id,targetPos)) then 
				AI.GetBeaconPosition(entity.id,targetPos);
			end
			if(DistanceSqVectors(targetPos,entity:GetPos())>400) then
				ZeroVector(targetPos);
			end			
			targetPos.z = ent:GetPos().z;
			AI_Utils:ReactToDanger(entity, ent:GetPos());
			entity:Readibility("explosion_imminent",0,5);
			if(entity.AI.theVehicle ==ent) then
				-- to do: schedule the react to danger after exiting vehicle animation 
				-- has ended (inserting timeout subpipe?)
				entity.AI.theVehicle:LeaveVehicle(entity.id);
				entity.AI.theVehicle = nil;
				AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
			end
		end
	end,
	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
		-- empty
	end,
	
	--------------------------------------------------
	OnBodyFallSound = function(self, entity, sender, data)

		-- ignore this if current behavior is alerted
		if(entity.Behaviour.alertness and entity.Behaviour.alertness>0) then return end

		-- Let the others know too...
--		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "OnGroupMemberDied",entity.id,data);

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);

		-- approach the location
		local deadPos = sender:GetWorldPos();
		AI.SetRefPointPosition(entity.id, deadPos);
		entity:SelectPipe(0,"approach_dead");
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_INTERESTED",entity.id);

	end,

	-----------------------------------------------------------------------------	
	
	
	
	--------------------------------------------------
	OnGroupMemberDiedNearest = function(self, entity, sender, data)

		local targetIsSleeping=0;
		
		if (sender.actor:GetHealth() > 0) then
			targetIsSleeping = 1;
		else
			-- Let the others know too...
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "OnGroupMemberDied",entity.id,data);
		end	

		-- go check dead body
		entity:MakeAlerted();
		entity.AI.killerPos = {};
		entity.AI.deadBodyId = sender.id;

		AI_Utils:IncGroupDeadCount(entity);
		
		local enemyRefPoint = AI.GetRefPointPosition(sender.id);

		if(enemyRefPoint) then
			-- Don't cheat too much, choose closest hidespots near by instead of the actual enemy position.
			local	closestCover = AI.GetNearestHidespot(entity.id, 3, 25, enemyRefPoint);
			if(closestCover) then
				CopyVector(entity.AI.killerPos, closestCover);
			else
				CopyVector(entity.AI.killerPos, enemyRefPoint);
			end

			local bodyPos = sender:GetPos();
			local bodyCount = AI_Utils:GetGroupDeadCount(entity);
			local friendCount = AI.GetGroupCount(entity.id, GROUP_ENABLED);
--			Log("friends:"..friendCount);
			
--			if(friendCount > 1) then
				if(bodyCount > 1) then
					AI.SetBeaconPosition(entity.id, bodyPos);
					local groupId = AI.GetGroupOf(entity.id);
					AI_Utils:VerifyGroupBlackBoard(groupId);		
					if (not AIBlackBoard[groupId].lastThreatPos) then
						AIBlackBoard[groupId].lastThreatPos = {x=0, y=0, z=0};
						AIBlackBoard[groupId].lastCheckedTime = 0;
					end
					CopyVector(AIBlackBoard[groupId].lastThreatPos, bodyPos);
					AIBlackBoard[groupId].lastCheckedTime = _time;
					
--					AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 10, "SEEK_KILLER",entity.id,g_SignalData);
				end
			
				-- know approx position of the shooter
				local deadPos = sender:GetWorldPos();
				AI.SetRefPointPosition(entity.id, deadPos);	
				
--		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "SEEK_KILLER",entity.id);
--		entity:MakeAlerted();
				
				
				if (targetIsSleeping == 1) then
					entity:SelectPipe(0,"check_sleeping");
				else
					entity:SelectPipe(0,"check_dead");
				end	
				entity:Readibility("find_body",0);
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_CHECKDEAD",entity.id);
--			else
--				-- Alone... just hide.
--				AI.SetBeaconPosition(entity.id, bodyPos);
--				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_HIDE",entity.id);
--			end
		else
--			Log("- NO REFPOINT!");
		end					
	end,

	-----------------------------------------------------------------------------	
	ORDER_FOLLOW = function (self, entity, sender)
		entity:SelectPipe(0,"squad_form");
		entity:InsertSubpipe(0,"do_it_running");
	end,
	
	-----------------------------------------------------------------------------	
	FORMATION_REACHED = function (self, entity, sender)
		entity:SelectPipe(0,"stay_in_formation_moving");
		entity:InsertSubpipe(0,"do_it_walking");
	end,
	
	-----------------------------------------------------------------------------	
	SEARCH_AROUND = function(self,entity,sender)
		entity.Properties.IdleSequence = "SearchAround";
	end,

	-----------------------------------------------------------------------------	
	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)
		-- data.id = vehicle id
		-- data.iValue = goal type (AIGOALTYPE_*)
		-- data.iValue2 = 0 = request closest seat, 1 - request most prioritary seat
		-- data.fValue = seat index (if>0)
		-- data.point = vehicle destination point
		--AI.LogEvent(entity:GetName().." ENTERING VEHICLE");
		entity.AI.theVehicle = System.GetEntity(data.id);
	 	if(entity.AI.theVehicle==nil) then
	 		-- no vehicle found
			AI.LogEvent(entity:GetName().." couldn't find a vehicle to enter");
	 		return
	 	end

		local numSeats = count(entity.AI.theVehicle.Seats);
		local numMembers = AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET);

		local seatIndex = data.fValue;
		if(seatIndex<1 or seatIndex>numSeats) then
			if(data.iValue2==0) then 
				entity.AI.mySeat = entity.AI.theVehicle:RequestClosestSeat(entity.id);
			else
				entity.AI.mySeat = entity.AI.theVehicle:RequestMostPrioritarySeat(entity.id);
			end
		else
			entity.AI.mySeat = seatIndex;
		end
		
		if(entity.AI.mySeat==nil) then
			AI.LogEvent(entity:GetName().." aborting enter vehicle "..entity.AI.theVehicle:GetName());
			--AI.Signal(SIGNALFILTER_LEADER, 0,"EnterVehicleAborted",entity.id);
			AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
			--AI.Signal(SIGNALFILTER_SENDER, 0,"GOTO_FIRST",entity.id);
			return
		end
--		AI.LogEvent(entity:GetName().." entering vehicle "..entity.AI.theVehicle:GetName().." Goal Type = "..data.iValue);
		
		entity.AI.theVehicle:ReserveSeat(entity.id,entity.AI.mySeat);
		
		AI.SetRefPointPosition(entity.id,entity.AI.theVehicle:GetSeatPos(entity.AI.mySeat));		

AI.LogEvent(">>>> ORDER_ENTER_VEHICLE ");

--		if(entity.AI.theVehicle:IsDriver(entity.id)) then
--AI.LogEvent(">>>> ORDER_ENTER_VEHICLE >> the driver");		
			-- I'm the driver
--			entity.AI.theVehicle.AI.driver = entity;
--			entity.AI.theVehicle.AI.countVehicleCrew = 0;
--			
----AI.LogEvent(entity:GetName().." numSeats "..numSeats.." NumMembers "..numMembers);
--			
--			
--			if(numSeats<numMembers) then
--				entity.AI.theVehicle.vehicleCrewNumber = numSeats;
--			else
--				entity.AI.theVehicle.vehicleCrewNumber = numMembers;
--			end			
--		end
		
		entity.AI.theVehicle.AI.goalType	= data.iValue;
		AI.LogEvent(entity:GetName().." is going to enter vehicle "..entity.AI.theVehicle:GetName().." with goal type = "..entity.AI.theVehicle.AI.goalType);
		AI.Signal(SIGNALFILTER_SENDER, 0,"ENTERING_VEHICLE",entity.id);

	end,

	---------------------------------------------
	ORDER_EXIT_VEHICLE = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
	end,

	---------------------------------------------
	-- being shot with the sleep bullet	
	OnFallAndPlay	= function( self, entity, data )
		AI.SetRefPointPosition(entity.id, data.point);
		if (entity.DoPainSounds) then
			entity:DoPainSounds();
		end
--		if (AI.GetGroupCount(entity.id) > 1) then
--			-- tell your nearest that someone you have died only if you were not the only one
--			AI.SetRefPointPosition(entity.id, data.point);
--			AI.Signal(SIGNALFILTER_NEARESTINCOMM, 10, "OnGroupMemberDiedNearest",entity.id); 
--		end
	end,
	
	--------------------------------------------------
	CIVILIAN_SPOTTED_ENEMY = function( self, entity, sender )
		g_SignalData.id = entity.id;
		local al = entity.Behaviour.alertness;
		if(al==nil or al==0) then 
			AI.ModifySmartObjectStates(entity.id,"WaitingCivilian");
			AI.Signal(SIGNALFILTER_SENDER,1,"COME_HERE",sender.id,g_SignalData);
		end
	end,
	
	--------------------------------------------------
	REPORT_CONTACT = function( self, entity, sender )
		AI.ModifySmartObjectStates(entity.id,"-WaitingCivilian");
		AI.Signal(SIGNALFILTER_GROUPONLY,1,"GET_ALERTED",entity.id);
	end,


	---------------------------------------------
	OnExposedToExplosion = function (self, entity, sender)
		entity:Readibility("bulletrain",1,1,0.1,0.4);
	end,

	---------------------------------------------
	OnChangeStance = function(self,entity,sender,data)
		local stance = data.iValue;
		if(stance==BODYPOS_RELAXED) then 
			entity:InsertSubpipe(0,"do_it_relaxed");
		elseif(stance==BODYPOS_STAND) then 
			entity:InsertSubpipe(0,"do_it_standing");
		elseif(stance==BODYPOS_CROUCH) then 
			entity:InsertSubpipe(0,"do_it_crouched");
		elseif(stance==BODYPOS_PRONE) then 
			entity:InsertSubpipe(0,"do_it_prone");
		end
	end,

	-------------------------------------------------------
	-- debug
	CHECK_TROOPER_GROUP = function(self,entity,sender)
		AI.Warning(entity:GetName().. " IS IN SAME GROUP WITH TROOPER "..sender:GetName()..", groupid = "..AI.GetGroupOf(entity.id));
	end,

}

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Player simple behaviour, actually meant to be a signal callback container
--  
--------------------------------------------------------------------------
--  History:
--  - 2/2006     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.PlayerIdle = {
	Name = "PlayerIdle",

	---------------------------------------------
	Constructor = function (self, entity)
		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition
		entity.AI.navType = AI.GetNavigationType(entity.id);
		if(entity.AI.Follow) then 
			self:Follow(entity);
		end
		
		AI.ChangeParameter(entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Player);
--		entity.AI.WeaponAccessoryTable = {};
	end,
	---------------------------------------------
	Destructor = function (self, entity,data)
		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
	end,

	---------------------------------------------
	LEADER_STAND = function(self, entity)
		AI.ScaleFormation(entity.id,1);
		if(AI.GetGroupTarget(entity.id,true)) then
			entity.AI.FollowStance = BODYPOS_STAND;
		else
			entity.AI.FollowStance = BODYPOS_RELAX;
		end
	end,

	---------------------------------------------
	LEADER_CROUCH = function(self, entity)
		AI.ScaleFormation(entity.id,1);
		entity.AI.FollowStance = BODYPOS_CROUCH;
	end,
	---------------------------------------------
	LEADER_PRONE = function(self, entity)
		AI.ScaleFormation(entity.id,1.5);
		entity.AI.FollowStance = BODYPOS_PRONE;
	end,

	---------------------------------------------
	OnSeenByEnemy = function ( self, entity, sender)
		-- use it as signal in order to execute it once even if squadmates send it
		if(AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET)>0) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"START_ATTACK",entity.id);
			AI.Signal(SIGNALFILTER_GROUPONLY,1,"CheckCoverBlown",entity.id);
		end
	end,
	
	---------------------------------------------
	OnThreateningSoundHeardByEnemy = function ( self, entity, sender)
		if(AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET)>0) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"START_ATTACK",entity.id);
			AI.Signal(SIGNALFILTER_GROUPONLY,1,"CheckCoverBlown",entity.id);
		end
	end,
	
	---------------------------------------------
	START_ATTACK = function ( self, entity, sender)
		self:StartAttack(entity);
	end,
	
	---------------------------------------------
	StartAttack = function(self,entity,navType)
		navType = navType or AI.GetNavigationType(entity.id);
		entity.AI.navType = navType;
		if(navType ~= NAV_WAYPOINT_HUMAN and navType ~= NAV_WAYPOINT_3DSURFACE) then 
			g_SignalData.ObjectName = "wedge_rev";
		else
			g_SignalData.ObjectName = "squad_indoor_combat";
		end
		g_SignalData.iValue = LAS_ATTACK_FOLLOW_LEADER;
		g_SignalData.iValue2 = UPR_COMBAT_GROUND;
		g_SignalData.fValue = 6;-- duration without group target
		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_ATTACK",entity.id, g_SignalData);
	end,	
	---------------------------------------------
	OnLeaderActionCompleted = function(self,entity,sender,data)
		-- data.iValue = Leader action type
		-- data.iValue2 = Leader action subtype
		-- data.id = group's live attention target 
		-- data.ObjectName = group's attention target name
		-- data.fValue = target distance
		-- data.point = enemy average position
		if(entity.AI.Follow) then 	
			local avgPos = g_Vectors.temp;
			AI.GetGroupAveragePosition(entity.id,UPR_COMBAT_GROUND,avgPos);
			local dist = DistanceVectors(avgPos,entity:GetPos());
			if(dist<100) then 
				AIBehaviour.PlayerIdle:Follow(entity);
			end
		end
	end,

	---------------------------------------------
	OnLeaderActionFailed  = function(self,entity,sender,data)
		self:OnLeaderActionCompleted(entity,sender,data);
	end,
	---------------------------------------------
	ACT_ENTERVEHICLE = function( self, entity, sender, data )
		local vehicle = entity.AI.theVehicle;
		if ( entity.AI.theVehicle ) then
			-- fail if already inside a vehicle
			--Log( "Player is already inside a vehicle" );
			return;
		end

		-- get the vehicle
		entity.AI.theVehicle = System.GetEntity( data.id );
		local vehicle = entity.AI.theVehicle;
	 	if ( vehicle == nil ) then
	 		-- no vehicle found
	 		return;
	 	end

		local numSeats = count( vehicle.Seats );

		if ( data.fValue<1 or data.fValue>numSeats ) then
			entity.AI.mySeat = vehicle:RequestClosestSeat( entity.id );
		else
			entity.AI.mySeat = data.fValue;
		end
		
		if ( entity.AI.mySeat==nil ) then
			Log( "Can't find the seat" );
			return;
		end
		
		vehicle:ReserveSeat( entity.id, entity.AI.mySeat );
		
		-- always do fast entering on the player
		vehicle:EnterVehicle( entity.id, entity.AI.mySeat, false );
		if(vehicle:IsDriver(entity.id)) then 
			AI.Signal(SIGNALFILTER_LEADER,1,"OnDriverEntered",entity.id);
		end
		vehicle.AI.goalType = AIGOALTYPE_UNDEFINED;
	end,	
	
	---------------------------------------------------
	CAPTURE_ME = function(self,entity,sender,data)
		g_SignalData.ObjectName = "wedge_follow";
		BasicAI.CreateFormation(entity,nil,true);
		AI.Signal(SIGNALFILTER_SENDER,1,"ORDER_FOLLOW",data.id);
	end,
	
	---------------------------------------------------
	FREE_ME = function(self,entity,sender,data)
		AI.Signal(SIGNALFILTER_SENDER,1,"SET_FREE",data.id);
	end,
	
	---------------------------------------------------
	FOLLOWING = function(self,entity,sender) 
		entity.AI.Follow = true;		
	end,
	---------------------------------------------------
	ORD_LEAVE_VEHICLE = function(self,entity,sender)
		if(entity.AI.Follow) then 
			AIBehaviour.PlayerIdle:Follow(entity);
		end
	end,

	---------------------------------------------------
	OnSwitchWeaponAccessory = function ( self, entity, sender,data)
		local acc = data.ObjectName;
		--AI.LogEvent(entity:GetName().." switching weapon accessory: "..acc.." on:"..data.iValue);
		if(acc =="Silencer" or acc =="Flashlight" or acc =="SCARIncendiaryAmmo" or acc == "SCARNormalAmmo") then 
			local entityAccessoryTable = entity.AI.WeaponAccessoryTable;
			if(acc =="SCARIncendiaryAmmo") then  
				entityAccessoryTable[acc] = 2;
				entityAccessoryTable["SCARNormalAmmo"] = 0;
			elseif(acc == "SCARNormalAmmo") then 
				entityAccessoryTable[acc] = 2;
				entityAccessoryTable["SCARIncendiaryAmmo"] = 0;
			else
				local myAcc = entityAccessoryTable[acc];
				if(myAcc) then 
					local mount = 1 - entityAccessoryTable[acc];
					entityAccessoryTable[acc] = mount;
					if(acc=="Silencer") then 
						if(mount==1) then 
							entity.AI.Silencer = true;
						else
							entity.AI.Silencer = false;
						end
					end
				end
			end
		end

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"CheckNextWeaponAccessory",entity.id);
	end,

	---------------------------------------------
	OnNanoSuitMode = function(self,entity,par1,par2)
		if(par2 and par2.iValue) then 
			entity.AI.NanoSuitMode = par2.iValue;
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"CheckNanoSuit",entity.id);
		elseif(par1 and par1.iValue) then
			entity.AI.NanoSuitMode = par1.iValue;
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"CheckNanoSuit",entity.id);
		end		
	end,
	
	---------------------------------------------
	OnNanoSuitCloak = function(self,entity,sender)
		entity.AI.NanoSuitCloak = true;
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"CheckNanoSuit",entity.id);
	end,
	
	---------------------------------------------
	OnNanoSuitUnCloak = function(self,entity,sender)
		entity.AI.NanoSuitCloak = false;
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"CheckNanoSuit",entity.id);
	end,

	---------------------------------------------
	OnNavTypeChanged= function(self,entity,sender,data)
		local navType = data.iValue;
		entity.AI.navType = navType;
		if(navType ~= NAV_WAYPOINT_HUMAN and navType ~= NAV_WAYPOINT_3DSURFACE) then 
			AI.ChangeFormation(entity.id,"wedge_follow");
		else
			AI.ChangeFormation(entity.id,"squad_indoor_follow");
		end
	end,
	
	---------------------------------------------
	Follow = function(self,entity)
		g_StringTemp1 ="";
		g_SignalData.iValue = 0;
		local navType = entity.AI.navType;
		if(navType ~= NAV_WAYPOINT_HUMAN and navType ~= NAV_WAYPOINT_3DSURFACE) then 
			g_SignalData.ObjectName = "wedge_follow";
		else
			g_SignalData.ObjectName = "squad_indoor_follow";
		end
		BasicAI.CreateFormation(entity,nil,true);
		g_aimode	= 1;
	end,

	---------------------------------------------
	ACT_ANIM = function( self, entity, sender )
	end,
}

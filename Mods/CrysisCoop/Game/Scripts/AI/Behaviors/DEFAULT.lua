-- Default behaviour - implements all the system callbacks and does something
-- this is so that any enemy has a behaviour to fallback to
--------------------------
-- DO NOT MODIFY THIS BEHAVIOUR

AIBehaviour.DEFAULT = {
	Name = "DEFAULT",

	-- this signal is sent when a smart object should be used
	OnUseSmartObject = function ( self, entity, sender, extraData )
		-- by default we just execute the requested action
		-- note: extraData.iValue is Action id and sender is the Object which should be used
		AI.ExecuteAction( extraData.ObjectName, entity.id, sender.id, extraData.iValue );
	end,
	
	-- send this signal to abort all actions
	ABORT_ALL_ACTIONS = function( self, entity )--, sender, data )
		AI.AbortAction( entity.id );
	end,
	
	-- this signal should be sent only by smart objects
	OnReinforcementRequested = function ( self, entity, sender, extraData )
		local pos = {};
		AI.GetBeaconPosition( extraData.id, pos );
		AI.SetBeaconPosition( entity.id, pos );
		AI.Signal( SIGNALFILTER_SENDER, 1, "GO_TO_SEEK", entity.id, sender.id );
	end,
	
	-- this is not a signal handler, but only a shared function
	SignalToNearestDirectional = function ( self, entity, signal )
		local nearest = entity:GetNearestInGroup();
		if ( nearest ) then
			local dir = {}; -- direction vector to nearest in group
			FastDifferenceVectors( dir, nearest:GetWorldPos(), entity:GetWorldPos() );

			local x = dotproduct3d( entity:GetDirectionVector(0), dir );
			local y = dotproduct3d( entity:GetDirectionVector(1), dir );
			if (y >= x and y >= -x) then
				-- front
				AI.Signal(SIGNALID_READIBILITY, 1, signal.."_FRONT", entity.id);
			elseif (x > y and x > -y) then
				-- left
				AI.Signal(SIGNALID_READIBILITY, 1, signal.."_LEFT", entity.id);
			elseif (x < y and x < -y) then
				-- right
				AI.Signal(SIGNALID_READIBILITY, 1, signal.."_RIGHT", entity.id);
			else --if (y <= x and y <= -x) then
				-- back
				AI.Signal(SIGNALID_READIBILITY, 1, signal.."_BACK", entity.id);
			end
		end
	end,

	SignalToNearest_InPosition = function ( self, entity, sender )
		self:SignalToNearestDirectional( entity, "IN_POSITION" );
	end,

	OnQueryUseObject = function ( self, entity, sender, extraData )
--	--	System.Log("OnQueryUseObject in DEFAULT");
--		sender = System.GetEntity( extraData.id );
--		if (sender and sender.listPotentialUsers) then
--			i = 1;
--			repeat
--				while (entity) do
--					if (entity.id == sender.listPotentialUsers[i].id) then
--						entity = nil;
--					end
--					i = i+1;
--				end
--				if ( i <= count(sender.listPotentialUsers) ) then
--					entity = sender.listPotentialUsers[i];
--				end
--			until (entity == nil) or entity:IsTargetAimable( sender );
--			if (entity) then
--			--	System.Log("    delegating to "..entity:GetName());
--				AI.Signal( SIGNALFILTER_SENDER, 10, "OnQueryUseObject", entity.id, sender.id );
--			else
--			--	System.Log("    no more candidates");
--				sender.listPotentialUsers = nil;
--			end
--		end
	end,

	---------------------------------------------
	OnLeaderDied = function ( self, entity, sender)
		entity.AI.InSquad = 0;
	end,

	---------------------------------------------
	OnExplosionDanger = function(self,entity,sender,data)
		--data.id = exploding entity
		if(data and data.id ~=NULL_ENTITY) then 
		--	AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitBusy",entity.id);
			entity:InsertSubpipe(0,"backoff_from_explosion",data.id);
		end
	end,
	

	---------------------------------------------
	SHARED_USE_THIS_MOUNTED_WEAPON = function( self, entity )
		local weapon = entity.AI.current_mounted_weapon;
		if(entity:GetDistance(weapon.id)<3) then 
			--AI.LogEvent(entity:GetName().." Uses mounted weapon |>>><| "..entity.AI.current_mounted_weapon:GetName());
			entity:HolsterItem( true );
			local mwitem = entity.AI.current_mounted_weapon.item;
			if(mwitem and not mwitem:IsUsed()) then 
				mwitem:StartUse( entity.id );		
			end
			weapon.listPotentialUsers = nil;
		else
			-- something went wrong with reaching weapon
			AI.Signal(SIGNALFILTER_SENDER,1,"TOO_FAR_FROM_WEAPON",entity.id);
			entity:DrawWeaponNow();
		end
		entity.AI.approachingMountedWeapon = false;
		local targettype = AI.GetTargetType(entity.id);
		if(targettype==AITARGET_ENEMY) then 
			entity:SelectPipe(0,"fire_mounted_weapon");
		else
			entity:SelectPipe(0,"mounted_weapon_look_around");
		end
--		elseif(targettype~=AITARGET_NONE and targettype~=AITARGET_FRIENDLY) then 
--			entity:SelectPipe(0,"near_mounted_weapon_blind_fire");
--		end
	end,
	
	LOOK_AT_MOUNTED_WEAPON_DIR = function(self,entity,sender)
			local pos = g_Vectors.temp;
			-- workaround to make the guy not snap the MG orientation
			local weapon = entity.AI.current_mounted_weapon;
			if ( weapon == nil ) then
				AI.LogEvent("WARNING: weapon is nil in LOOK_AT_MOUNTED_WEAPON_DIR for "..entity:GetName());
			else
				FastSumVectors(pos,weapon:GetPos(),weapon.item:GetMountedDir());
				FastSumVectors(pos,pos,weapon.item:GetMountedDir());
				AI.SetRefPointPosition(entity.id,pos);
				AI.SetRefPointDirection(entity.id,weapon.item:GetMountedDir());
				local targetType = AI.GetTargetType(entity.id);
	--			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then 
	--				entity:SelectPipe(0,"mounted_weapon_look_around");
	--			else
	--				entity:SelectPipe(0,"do_nothing");
	--			end
	--	   	entity:InsertSubpipe(0, "look_at_refpoint_if_no_target");
				AI.Signal(SIGNALFILTER_SENDER, 1, "SHARED_USE_THIS_MOUNTED_WEAPON", entity.id);
			end
	end,
	
	SET_MOUNTED_WEAPON_PERCEPTION = function(self,entity,sender)
			local perceptionTable = entity.Properties.Perception;
			local newSightRange = perceptionTable.sightrange * 2;

			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 1 );

			-- make bigger sight-range/attack-range; mounted weapon has to shoot a lot
 			AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE, newSightRange);	-- add 100% to sight range
--			AI.ChangeParameter(entity.id,AIPARAM_ATTACKRANGE,entity.Properties.attackrange*2);	-- 
			AI.ChangeParameter(entity.id,AIPARAM_ATTACKRANGE, newSightRange);	
			AI.ChangeParameter(entity.id,AIPARAM_FOVSECONDARY, perceptionTable.FOVPrimary);
	end,
	
	MOUNTED_WEAPON_USABLE = function(self,entity,sender,data) 
		-- sent by smart object rule
		local weapon = System.GetEntity(data.id);
		-- if use RPG - can not use MG
		local curWeapon = entity.inventory:GetCurrentItem();
		if(curWeapon and curWeapon.class=="LAW") then
			weapon = nil;
		end	
		
		-- if MG SO class assigned not to weapon but something else (designers mistake) - this will happen
		if(weapon and weapon.item==nil) then
			AI.LogEvent("trying to use "..weapon:GetName().." as weapon. Please check SO class");
			weapon = nil;
		end

		if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7,entity.AI.SkipTargetCheck)) then 
			weapon.reserved = entity;
			entity.AI.current_mounted_weapon = weapon;
			local parent = weapon:GetParent();
			if(parent and parent.vehicle) then 
				-- the weapon is mounted on a vehicle
				g_SignalData.fValue = mySeat;
				g_SignalData.id = parent.id;
				g_SignalData.iValue2 = 0; -- no "fast entering"
				g_SignalData.iValue = -148; -- this is just a random number used as goal pipe id
				AI.Signal(SIGNALFILTER_SENDER, 1, "ACT_ENTERVEHICLE", entity.id, g_SignalData);
			else
				AI.Signal(SIGNALFILTER_SENDER, 0, "USE_MOUNTED_WEAPON", entity.id);
			end
			AI.ModifySmartObjectStates(entity.id,"Busy");				
		else
			if(weapon) then 
				AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
			end
			AI.ModifySmartObjectStates(entity.id,"-Busy");			
		end
	end,



--	MOUNTED_WEAPON_USABLE_OLD = function(self,entity,sender,data) 
--		-- sent by smart object rule
--		local weapon = System.GetEntity(data.id);
--		local useweapon = false;
--		local mySeat;
--		-- if use RPG - can not use MG
--		local curWeapon = entity.inventory:GetCurrentItem();
--		if(curWeapon~=nil and curWeapon.class=="LAW") then
--			weapon = nil;
--		end	
--		
--		-- if MG SO class assigned not to weapon but something else (designers mistake) - this will happen
--		if(weapon and weapon.item==nil) then
--			AI.LogEvent("trying to use "..weapon:GetName().." as weapon. Please check SO class");
--			weapon = nil;
--		end
--
--		if(weapon) then 
--			useweapon = true;
--			local parent = weapon:GetParent();
--			if(parent) then
----				AI.LogEvent("Weapon "..weapon:GetName().." mounted on vehicle "..parent:GetName());
--				-- TO DO: check possible vehicle types (only ground vehicles)
----				if(parent.vehicleType ~= "wheeled" and 	parent.vehicleType ~= "tracked") then
----					System.Log("wrong parent vehicle type = "..parent.vehicleType);
----					useweapon = false;
----				else
--				if(parent.HasDriver and parent:HasDriver()) then 
--				-- don't go to active vehicles
--					useweapon = false;
--				else
--
--					-- check if the seat is ready.
--					-- temporary solution to prevent a inner state mismatch of PassengerId
--
--					local bIsEmptySeat = false;
--					if(parent.AI and parent.GetSeatWithWeapon) then 
--						mySeat = parent:GetSeatWithWeapon(weapon);	
--						if ( mySeat ~= nil ) then
--							local seat_ = parent:GetSeatByIndex(mySeat);
--							if (seat_ ~= nil and seat_:IsFree()) then
--								local PassengerId = seat_:GetPassengerId();
--								if (PassengerId ~=nil) then
--									local passengerEntity = System.GetEntity(PassengerId);
--									if ( PassengerEntity ~=nil ) then
--										if ( PassengerEntity.AI.theVehicle == nil ) then
--											-- for more strict checks are below.
--											-- PassengerEntity.AI.theVehicle.id ~= parent.id 
--											-- PassengerEntity.actor and PassengerEntity.actor:GetLinkedVehicleId()==nil
--											AI.LogEvent(PassengerEntity:GetName().."is not in the vehicle.");
--											bIsEmptySeat = true;
--										end
--									else
--										bIsEmptySeat = true;
--									end
--								else
--									bIsEmptySeat = true;
--								end								
--							end
--						end
--					end
--					
--					if ( bIsEmptySeat == false) then 
----						AI.LogEvent("Free gunner seat not found. Abort");
--						useweapon = false;
--					end
--				end
--			end
--			if(not entity.AI.SkipTargetCheck) then 
--				local target = AI.GetAttentionTargetEntity(entity.id);
--				if(target and useweapon) then
--					if(AI.Hostile(entity.id,g_localActor.id)) then
--						if(weapon:GetDistance(g_localActor.id)<5) then 
--							useweapon = false;
--						end
--					end
--					if(useweapon and not entity:IsTargetAimable( weapon )) then 
--						useweapon = false;
--					end
--				else
--					useweapon = false;
--				end
--			end
--		else
--			useweapon = false;
--		end
--
--		if(useweapon) then 
--			weapon.reserved = entity;
--			entity.AI.current_mounted_weapon = weapon;
--			local parent = weapon:GetParent();
--			if(parent and parent.vehicle) then 
--				-- the weapon is mounted on a vehicle
--				g_SignalData.fValue = mySeat;
--				g_SignalData.id = parent.id;
--				g_SignalData.iValue2 = 0; -- no "fast entering"
--				g_SignalData.iValue = -148; -- this is just a random number used as goal pipe id
--				AI.Signal(SIGNALFILTER_SENDER, 1, "ACT_ENTERVEHICLE", entity.id, g_SignalData);
--			else
--				AI.Signal(SIGNALFILTER_SENDER, 0, "USE_MOUNTED_WEAPON", entity.id);
--			end
--			AI.ModifySmartObjectStates(entity.id,"Busy");				
--		else
--			if(weapon) then 
--				AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
--			end
--			AI.ModifySmartObjectStates(entity.id,"-Busy");			
--		end
--
--	end,

	ORDER_HIDE = function( self, entity, sender, data )
		AI.SetRefPointPosition(entity.id, data.point);
	end,

	ORDER_SEARCH = function( self, entity, sender, data )
		AI.SetRefPointPosition(entity.id, data.point);
	end,




	HIDE_FROM_BEACON = function ( self, entity, sender)
		entity:InsertSubpipe(0,"hide_from_beacon");
	end,

	DESTROY_THE_BEACON = function ( self, entity, sender)
		if (entity.cnt.numofgrenades>0) then 
			local rnd=random(1,4);
			if (rnd>2) then 
				entity:InsertSubpipe(0,"shoot_the_beacon");
			else
				entity:InsertSubpipe(0,"bomb_the_beacon");
			end
		else
			entity:InsertSubpipe(0,"shoot_the_beacon");
		end
	end,

	OnFriendInWay = function ( self, entity, sender)
--		local rnd=random(1,4);
--		entity:InsertSubpipe(0,"friend_circle");
	end,

	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		-- called as default handling by some behaviors
	end,

	
	MAKE_ME_IGNORANT = function ( self, entity, sender)
		AI.SetIgnorant(entity.id,1);
	end,
	
	MAKE_ME_UNIGNORANT = function ( self, entity, sender)
		AI.SetIgnorant(entity.id,0);
	end,

	-- cool retreat tactic
	RETREAT_NOW = function ( self, entity, sender)

		local retreat_spot = AI.FindObjectOfType(entity.id,100,AIAnchorTable.COMBAT_RETREAT_HERE);
		if (retreat_spot) then 
			entity:SelectPipe(0,"retreat_to_spot",retreat_spot);
		else
			entity:SelectPipe(0,"retreat_back");
		end
		entity:Readibility("RETREATING_NOW",1);
	end,

	RETREAT_NOW_PHASE2 = function ( self, entity, sender)

		local retreat_spot = AI.FindObjectOfType(entity.id,100,AIAnchorTable.COMBAT_RETREAT_HERE);
		if (retreat_spot) then 
			entity:SelectPipe(0,"retreat_to_spot_phase2",retreat_spot);
		else
			entity:SelectPipe(0,"retreat_back_phase2");
		end
	
		entity:Readibility("RETREATING_NOW",1);
	end,

	PROVIDE_COVERING_FIRE = function ( self, entity, sender)
		entity:SelectPipe(0,"dumb_shoot");
		entity:Readibility("PROVIDING_COVER",1);
	end,

	-- cool rush tactic
	RUSH_TARGET = function ( self, entity, sender)
		entity:SelectPipe(0,"rush_player");
		entity:Readibility("AI_AGGRESSIVE",1);

	end,

	STOP_RUSH = function ( self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	

	START_SWIMMING = function ( self, entity, sender)
		AI.SetIgnorant(entity.id,1);
		entity:SelectPipe(0,"swim_inplace");

		if (entity.MUTANT) then
			entity:InsertAnimationPipe("drown00",2,"NOW_DIE",0.15,0.8);
		else
			local dh = AI.FindObjectOfType(entity:GetPos(),30,AIAnchorTable.SWIM_HERE);
	
			if (dh) then
				entity:InsertSubpipe(0,"swim_to",dh);
			end
		end
	end,

	GO_INTO_WAIT_STATE = function ( self, entity, sender)
		entity:SelectPipe(0,"wait_state");
	end,

	SPECIAL_FOLLOW = function (self, entity, sender)
		entity.AI.SpecialBehaviour = "SPECIAL_FOLLOW";
		entity:SelectPipe(0,"val_follow");
		entity:Readibility("FOLLOWING_PLAYER",1);
		AI.SetIgnorant(entity.id,0);
	end,

	SPECIAL_GODUMB = function (self, entity, sender)
		entity.AI.SpecialBehaviour = "SPECIAL_GODUMB";
--		entity:DoSomethingInteresting();
		AI.SetIgnorant(entity.id,1);
	end,

	SPECIAL_STOPALL = function (self, entity, sender)
		entity.AI.SpecialBehaviour = nil;
		--entity.EventToCall = "OnSpawn";
		entity:SelectPipe(0,"standingthere");
		AI.SetIgnorant(entity.id,0);
	end,

	SPECIAL_LEAD = function (self, entity, sender)
		entity.AI.SpecialBehaviour = "SPECIAL_LEAD";
		entity:SelectPipe(0,"standingthere");
		entity.LEADING = nil;
		entity.EventToCall = "OnCloseContact";
		entity:Readibility("LETS_CONTINUE",1);
		AI.SetIgnorant(entity.id,0);
	end,

	SPECIAL_HOLD = function (self, entity, sender)
		entity.AI.SpecialBehaviour = "SPECIAL_HOLD";
		local spot = AI.FindObjectOfType(entity:GetPos(),50,AIAnchorTable.SPECIAL_HOLD_SPOT);
		if (spot == nil) then 
			Hud:AddMessage("========================== UNACCEPTABLE ERROR ====================");
			Hud:AddMessage("No SPECIAL_HOLD_SPOT anchor for entity "..entity:GetName());
			Hud:AddMessage("========================== UNACCEPTABLE ERROR ====================");
		end
		entity:SelectPipe(0,"hold_spot",spot);
		AI.SetIgnorant(entity.id,0);
	end,


	CANNOT_RESUME_SPECIAL_BEHAVIOUR = function(self,entity,sender)
		if (entity.AI.SpecialBehaviour) then
			entity:Readibility("THERE_IS_STILL_SOMEONE",1);
		end
	end,

	RESUME_SPECIAL_BEHAVIOUR = function(self,entity,sender)
		if (entity.AI.SpecialBehaviour) then
			entity:TriggerEvent(AIEVENT_CLEARSOUNDEVENTS);
			AI.Signal(0,1,entity.AI.SpecialBehaviour,entity.id);
		end
	end,

	--- Everyone is now able to respond to reinforcements
	---------------------------------------------
	AISF_CallForHelp = function ( self, entity, sender)
		local guy_should_reinforce = AI.FindObjectOfType(entity.id,5,AIAnchorTable.COMBAT_RESPOND_TO_REINFORCEMENT);		
		if (guy_should_reinforce) then 
			--AI.Signal(0,1,"SWITCH_TO_RUN_TO_FRIEND",entity.id);
			entity:MakeAlerted();
			entity:SelectPipe(0,"cover_beacon_pindown");
			entity:InsertSubpipe(0,"offer_join_team_to",sender.id);
			if (not entity.inventory:GetCurrentItemId()) then
				--entity:InsertSubpipe(0,"DRAW_GUN");	
				entity:DrawWeaponNow();
			end
		end
	end,
	---------------------------------------------


	APPLY_IMPULSE_TO_ENVIRONMENT = function(self,entity,sender)
		entity:InsertAnimationPipe("kick_barrel");
		entity.ImpulseParameters.pos = entity:GetPos();
		entity.ImpulseParameters.pos.z = entity.ImpulseParameters.pos.z-1;
		entity:ApplyImpulseToEnvironment(entity.ImpulseParameters);
	end,


	OnRestoreVehicleDanger = function(self, entity)
		entity.AI.avoidingVehicleTime = nil;
	end,
	
--	OnVehicleDanger = function(self, entity, sender, signalData)
--		local driverId = sender:GetDriverId();
--		if (driverId == nil or entity.Properties.species > 0 and
--			System.GetEntity(driverId).Properties.species == entity.Properties.species) then
--			-- ignore vehicles driven by entities of the same species 
--			return;
--		end
--		
--		local currTime = System.GetCurrTime();
--		if (entity.AI.avoidingVehicleTime and (currTime - entity.AI.avoidingVehicleTime < 0.5)) then
--			-- don't allow inserting too much subpipes! overkill for pathfinder
--			return;
--		end
--		entity.AI.avoidingVehicleTime = currTime;
--		
--		-- System.Log(entity:GetName().." received OnVehicleDanger from "..sender:GetName());
--		-- LogVec("    velocity", signalData.point);
--		-- LogVec("    xy", signalData.point2);
--		
--		local p0={};
--		local p1={};
--		local p2={};
--		local perp={};
--		
--		CopyVector(p0, entity:GetPos());
--		CopyVector(p1, signalData.point);
--		FastScaleVector(p1, p1, 5);
--
--		perp.x = signalData.point.y;
--		perp.y = - signalData.point.x;
--		perp.z = 0;
--
--		FastSumVectors(p2, p0, p1);
--		System.DrawLine(p0, p2, 0, 1, 0, 1);
--		
--		FastScaleVector(p2, p1, 0.5 - (0.5 * signalData.point2.y));
--		if (signalData.point2.x < 0) then
--			FastScaleVector(perp, perp, 4 * (signalData.point2.x - 1.0));
--		else
--			FastScaleVector(perp, perp, 4 * (1.0 - signalData.point2.x));
--		end
--
--		FastSumVectors(p2, p2, perp);
--		FastSumVectors(p2, p2, p0);
----		System.DrawLine(p0, p2, 1, 0.5, 0, 1);
--		
--		AI.SetRefPointPosition(entity.id, p2);
--
--		local oldTarget = AI.GetAttentionTargetOf(entity.id);
--		if (oldTarget) then
--			entity:InsertSubpipe(0, "acquire_lastop", oldTarget);
--		else
--			entity:InsertSubpipe(0, "clear_all");
--		end
--
--		if (signalData.point2.y > 0.5 or signalData.point2.x < -0.75 or signalData.point2.x > 0.75) then
--			-- danger is far... just make 2-3 steps away
--			entity:InsertSubpipe(0, "avoid_vehicle", sender:GetAIName());
--		else
--			-- danger is too close!!!
--			entity:InsertSubpipe(0, "avoid_vehicle_running", sender:GetAIName());
--		end
--	end,

	HIDE_END_EFFECT = function(self,entity,sender)
		entity.actor:QueueAnimationState("rollfwd");
	end,

	Smoking = function(self,entity,sender)
		entity.EventToCall = "OnSpawn";
	end,

	YOU_ARE_BEING_WATCHED = function(self,entity,sender)
		
	end,


	LEFT_LEAN_ENTER = function(self,entity,sender)
		entity:SelectPipe(0,"lean_left_attack");
	end,

	RIGHT_LEAN_ENTER = function(self,entity,sender)
		entity:SelectPipe(0,"lean_right_attack");
	end,


	SWITCH_TO_MORTARGUY = function(self,entity,sender)
--		local mounted = AI.FindObjectOfType(entity:GetPos(),200,AIAnchorTable.USE_THIS_MOUNTED_WEAPON);		
--		if (mounted) then
--			entity.AI.AtWeapon=nil;
--			entity:SelectPipe(0,"goto_mounted_weapon",mounted);
--		end

	end,


	RETURN_TO_FIRST = function( self, entity, sender )
--		entity.EventToCall = "OnSpawn";	
--		entity:Readibility("INTERESTED_TO_IDLE");
	end,

	-- Everyone has to be able to warn anyone around him that he died
	--------------------------------------------------
	OnDeath = function ( self, entity, sender)

--		AI.LogEvent( ">>>> OnDeath "..entity:GetName() );
--
----		if (AI.GetGroupCount(entity.id) == 2) then
----			-- tell nearest to you to go to reinforcement
----			AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "GoForReinforcement",entity.id);
----		end
--		-- tell your friends that you died anyway regardless of wheteher someone goes for reinforcement
--		g_SignalData.id = entity.id;
--		CopyVector(g_SignalData.point,entity:GetPos());
--		if (AI.GetGroupCount(entity.id) > 1) then
--			-- tell your nearest that someone you have died only if you were not the only one
--				AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "OnGroupMemberDiedNearest",entity.id,g_SignalData); 
--		else
--			-- tell anyone that you have been killed, even outside your group
--			AI.Signal(SIGNALFILTER_ANYONEINCOMM, 1, "OnSomebodyDied",entity.id,g_SignalData);
--		end
--		
--		if(entity.bIsLeader) then 
--			AI.Signal(SIGNALFILTER_LEADER,0,"RPT_LeaderDead",entity.id);
--		end
----		AI.Signal(0, 1, "OnDeathCreateCorpseDelay",entity.id);		
--			
	end,

	-- do melee when really close
	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"melee_close");
	end,


	-- What everyone has to do when they get a notification that someone died
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)

		AI.LogEvent( ">>>> OnGroupMemberDiedNearest "..entity:GetName() );

		if (entity.ai) then 
			entity:MakeAlerted();

			entity:Readibility("FRIEND_DEATH",1);
			entity:InsertSubpipe(0,"DropBeaconAt",sender.id);

			-- bounce the dead friend notification to the group (you are going to investigate it)
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
		else
			-- vehicle bounce the signals further
			AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "OnGroupMemberDiedNearest",entity.id,data);
		end
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
	
	
		if(entity.MakeAlerted) then
			entity:MakeAlerted();
		end	
		entity:InsertSubpipe(0,"backoff_from",sender.id);
		--entity:InsertSubpipe(0,"DRAW_GUN");
		entity:InsertSubpipe(0,"setup_combat");
	end,


	-- and everyone has to be able to respond to an invitation to join a group
	--------------------------------------------------
	JoinGroup = function (self, entity, sender)
		AI.ChangeParameter(entity.id,AIPARAM_GROUPID,AI.GetGroupOf(sender.id));
		entity:SelectPipe(0,"AIS_LookForThreat");
	end,

	UNCONDITIONAL_JOIN = function (self, entity, sender)
		AI.ChangeParameter(entity.id,AIPARAM_GROUPID,AI.GetGroupOf(sender.id));
	end,

	---------------------------------------------
	--------------------------------------------------
	CONVERSATION_REQUEST = function (self,entity, sender, data)
		AI.LogEvent(entity:GetName().." requesting conversation ");
		
		if (sender ~=nil) then	
			local distance = entity:GetDistance(sender.id);
			--data.fValue ==0 -> conversation not in place
			if ((distance < 8 or distance<20 and data.fValue==0) and entity.AI.CurrentConversation==nil) then
				--answer to the requestor that you can join the conversation 
				-- (if there are conversations with enough partecipants including me)
				--if(sender.ConvPartecipants < sender.AI.CurrentConversation.MaxPartecipants) then
					sender.ConvPartecipants =	sender.ConvPartecipants + 1;
					sender.ConvActors[sender.ConvPartecipants] = entity;
					if(entity == sender) then
						entity.AI.ConvInPlace = data.fValue;
						entity.AI.ConvType = data.iValue;
						entity:InsertSubpipe(0,"gather_conversation_partecipants");
					end	
				--end	
			end			
		end
	end,


	--------------------------------------------------
	START_CONVERSATION = function (self,entity, sender)
		AI.LogEvent(entity:GetName().. " starting conversation");
		local convType = entity.AI.ConvType;

		local conv = AI_ConvManager:GetRandomConversation(entity.ConversationName, entity.AI.ConvType, entity.AI.ConvInPlace, entity.AI.ConvPartecipants);

		if (conv ~=nil) then
			entity.AI.ConvPartecipants = conv.Participants;
			for i = 1,conv.Participants do
				conv:Join(entity.ConvActors[i]);
			end
			conv:Start();
			entity.AI.CurrentConversation = conv;
		else
			AI.LogEvent(entity:GetName().." couldn't start the conversation");
		end
	end,

	--------------------------------------------------
	OFFER_JOIN_TEAM  = function (self,entity, sender)
		if (entity~=sender) then	
			if (AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then
				AI.ChangeParameter(entity.id,AIPARAM_GROUPID,AI.GetGroupOf(sender.id));
			end
		end
	end,



	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
--System.Log(">>>> default OnOutOfAmmo " );

	-- player would not have Reload implemented
	if(entity.Reload == nil)then
--	System.Log(">>>> no reload available for "..entity:GetName() );
	do return end
	end


		entity:Reload();
	end,

	--------------------------------------------------	
	SHARED_RELOAD = function (self,entity, sender)
	
		do return end
	
		if (entity.cnt) then
			if (entity.cnt.ammo_in_clip) then
				if (entity.cnt.ammo_in_clip > 5) then
					do return end
				end
			end
		end


		AI.CreateGoalPipe("reload_timeout");
		AI.PushGoal("reload_timeout","timeout",1,entity:GetAnimationLength(0, "reload"));
		entity:InsertSubpipe(0,"reload_timeout");

		entity.actor:QueueAnimationState("reload");
--		if (AI.GetGroupCount(entity.id) > 1) then
--			AI.Signal(SIGNALID_READIBILITY, 1, "RELOADING",entity.id);
--		end
		BasicPlayer.Reload(entity);	
	end,

	--------------------------------------------------
	WPN_SHOOT= function(self, entity, sender)
--		entity.actor:SelectLastItem();
	end,

	--------------------------------------------------
	THROW_GRENADE_DONE= function(self, entity, sender)
--		entity.actor:SelectLastItem();
	end,

	--------------------------------------------------
	SMART_THROW_GRENADE = function( self, entity, sender )
		if (AI_Utils:CanThrowGrenade(entity) == 1) then
			entity:Readibility("throwing_grenade",1);
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"throw_grenade_execute");
		end
	end,
		
	--------------------------------------------------
	SHARED_PLAYLEFTROLL = function(self,entity,sender)
		entity.actor:QueueAnimationState("rollleft");
	end,

	--------------------------------------------------
	SHARED_PLAYRIGHTROLL = function(self,entity,sender)
		entity.actor:QueueAnimationState("rollright");
	end,

	--------------------------------------------------
	SHARED_TAKEOUTPIN = function(self,entity,sender)
		entity.actor:QueueAnimationState("signal_inposition");
	end,

	------------------------------ Animation -------------------------------
	death_recognition = function (self, entity, sender)
		local XRandom = random(1,3)
		if (XRandom == 1) then
			entity.actor:QueueAnimationState("death_recognition1");
		elseif (XRandom == 2) then
			entity.actor:QueueAnimationState("death_recognition2");
		elseif (XRandom == 3) then
			entity.actor:QueueAnimationState("death_recognition3");
		end
	end,
	---------------------------------------------		
	PlayRollLeftAnim = function (self, entity, sender)
		entity.actor:QueueAnimationState("rollleft");
	end,
	------------------------------------------------------------------------
	PlayRollRightAnim = function (self, entity, sender)
		entity.actor:QueueAnimationState("rollright");
	end,
	

	--------------------------------------------------
--	SHARED_ENTER_ME_VEHICLE = function( self,entity, sender )
--
--
--		if( entity.ai == nil ) then return end
----		self:SPECIAL_STOPALL(entity,sender);
--
--		local vehicle = sender;
--		if (vehicle) then
--			local seatIndex = vehicle:RequestSeat(entity.id);
--			if (seatIndex) then
--				entity.AI.mySeat = seatIndex;
--				entity.AI.theVehicle = vehicle;
----				vehicle:EnterVehicle(entity.id, seatIndex);
--				if(vehicle:IsGunner(entity.id) and vehicle:IsDriver(entity.id)==false) then
--					AI.Signal(0, 1, "entered_vehicle_gunner",entity.id);
--				else
--					AI.Signal(0, 1, "entered_vehicle",entity.id);
----					AI.Signal(0, 1, "DRIVER_IN",vehicle.id);
--				end
--			end
--		end
--	end,

	
	---------------------------------------------
	OnNoAmmo = function( self, entity, sender)
--		entity.cnt:SelectNextWeapon();
	end,

	---------------------------------------------
	OnDamage = function(self,entity,sender,data)
	end,

	------------------------------------------------------	
	-- ANIMATION CONTROL FOR GETTING DOWN AND UP BETWEEN STANCES
	DEFAULT_CURRENT_TO_CROUCH = function( self, entity, sender)
		-- this doesn't have an animation from any stance
	end,
	------------------------------------------------------
	DEFAULT_CURRENT_TO_PRONE = function( self, entity, sender)
		-- this doesn't have an animation from crouch
		if ((entity.cnt.crouching==nil) and (entity.cnt.proning==nil)) then
			-- the guy was standing, so play animation getdown
			entity.actor:QueueAnimationState("pgetdown");
		end
	end,
	------------------------------------------------------
	DEFAULT_CURRENT_TO_STAND = function( self, entity, sender)
		-- this doesn't have an animation from crouch
		if (entity.cnt.proning) then 
			entity.actor:QueueAnimationState("pgetup");
		end
	end,
	------------------------------------------------------



	------------------------------------------------------
	-- special Harry-urgent-needed-blind-behaviour-hack -- 
	------------------------------------------------------
	LIGHTS_OFF  = function(self,entity,sender)
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,0.1);	
	end,
	------------------------------------------------------
	LIGHTS_ON  = function(self,entity,sender)
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange);	
	end,


	------------------------------------------------------------------------ 
	HIDE_GUN = function (self,entity)
		entity.cnt:DrawThirdPersonWeapon(0);		
	end,
	------------------------------------------------------------------------ 
	UNHIDE_GUN = function (self,entity)
		entity.cnt:DrawThirdPersonWeapon(1);		
	end,
	------------------------------------------------------------------------ 
	------------------------------------------------------------------------ 

	DO_THREATENED_ANIMATION = function(self,entity,sender)

		--put this back when appropriate animations are available 
		do return end

		local rnd = random(1,3);		
		entity:InsertAnimationPipe("_surprise0"..rnd,3);
		local anim_dur = entity:GetAnimationLength(0, "_surprise0"..rnd);	
		entity:TriggerEvent(AIEVENT_ONBODYSENSOR,anim_dur);
		--AI.EnablePuppetMovement(entity.id,0,anim_dur);
	end,
	---------------------------------------------
	SHARED_PLAY_CURIOUS_ANIMATION = function(self,entity,sender)

		local rnd = random(1,2);		
		entity:InsertAnimationPipe("_curious"..rnd);
	end,
	---------------------------------------------

	DO_SOMETHING_IDLE = function( self,entity , sender)

		if (entity:MakeMissionConversation()) then		-- try talking to someone
			entity:CheckFlashLight();
			do return end
		end

		if (entity:MakeRandomConversation()) then		-- try talking to someone
			entity:CheckFlashLight();
			do return end
		end
--		if (entity:DoSomethingInteresting()) then		-- piss, smoke or whatever
--			entity:CheckFlashLight();
--			do return end
--		end

		-- always make at least an animation :)
		--entity:MakeRandomIdleAnimation(); 		-- make idle animation
		entity:CheckFlashLight();
	end,
	---------------------------------------------
	GOING_TO_TRIGGER = function (self, entity, sender)
		entity.RunToTrigger = 1;
 		if ( sender.id == entity.id ) then
			AI.SetIgnorant(entity.id,1);
 			entity:InsertSubpipe(0,"run_to_trigger",entity.AI.ALARMNAME);
 		end
		
	end,
	---------------------------------------------
	THROW_FLARE = function (self, entity, sender)

 		if ( sender.id == entity.id ) then
			entity:InsertSubpipe(0,"throw_flare");
 		end
	end,


	MAKE_STUNNED_ANIMATION = function (self, entity, sender)

		if (entity.BLINDED_ANIM_COUNT) then
			local rnd = random(0,entity.BLINDED_ANIM_COUNT);
			local anim_name = format("blind%02d",rnd);
			entity:InsertAnimationPipe(anim_name,4);
			local dur = entity:GetAnimationLength(0, anim_name);
			AI.EnablePuppetMovement(entity.id,0,dur+3);	-- added the timeouts in the pipe
			entity:TriggerEvent(AIEVENT_ONBODYSENSOR,dur+3);
		else
			Hud:AddMessage("==================UNACCEPTABLE ERROR====================");
			Hud:AddMessage("Entity "..entity:GetName().." tried to make blinded anim, but no blindXX anims for his character.");
			Hud:AddMessage("==================UNACCEPTABLE ERROR====================");
		end
		
	end,


	---------------------------------------------
	FLASHBANG_GRENADE_EFFECT = function (self, entity, sender)
		if (entity.ai) then
			entity:InsertSubpipe(0,"stunned");
			entity:Readibility("FLASHBANG_GRENADE_EFFECT",1);
		end
		
	end,

	---------------------------------------------
	SHARED_BLINDED = function (self, entity, sender)
	end,

	---------------------------------------------
	SHARED_UNBLINDED = function (self, entity, sender)
		entity.actor:QueueAnimationState("NULL");
	end,

	---------------------------------------------
	SHARED_PLAY_GETDOWN_ANIM = function (self, entity, sender)
		local rnd= random(1,2);
		entity:InsertAnimationPipe("duck"..rnd.."_down",3);
	end,
	---------------------------------------------
	SHARED_PLAY_GETUP_ANIM = function (self, entity, sender)
		local rnd= random(1,2);
		entity:InsertAnimationPipe("duck"..rnd.."_up",3);
	end,
	---------------------------------------------
	SHARED_PLAY_DAMAGEAREA_ANIM = function (self, entity, sender)
		local rnd= random(1,2);
		entity:InsertAnimationPipe("duck"..rnd.."_up",3);
	end,
	

	exited_vehicle = function( self,entity, sender )

--		AI.Signal(SIGNALID_READIBILITY, 2, "AI_AGGRESSIVE",entity.id);	
--		entity.EventToCall = "OnSpawn";	
		AI.Signal(0,1,"OnSpawn",entity.id);
	end,

	---------------------------------------------
	select_gunner_pipe = function ( self, entity, sender)
		entity:SelectPipe(0,"h_gunner_fire");
	end,
	

	
	JOIN_TEAM = function ( self, entity, sender)
		AI.LogEvent(entity:GetName().." JOINING TEAM");
		entity.AI.InSquad = 1;
	end,

	BREAK_TEAM = function ( self, entity, sender)
		entity.AI.InSquad = 0;
	end,

	--------------------------------------------------------
	SET_REFPOINT_BEHIND_ME = function(self,entity,sender)
		local refPos = g_Vectors.temp;
		FastDifferenceVectors(refPos, entity:GetWorldPos(),entity:GetDirectionVector());
		AI.SetRefPointPosition(entity.id,refPos);
	end,
	
	--------------------------------------------------------
	CHECK_CONVOY = function(self,entity,sender)
--		System.Log(entity:GetName().." SIGNAL convoy");
	 	entity:Event_Convoy();		
	end,

	--------------------------------------------------------
	PLAY_TALK_ANIMATION = function (self,entity,sender)
		local rnd = math.random(1,6);
		entity.actor:QueueAnimationState("relaxed_idle_talk_nw_0"..rnd);
	end,
	--------------------------------------------------------
	PLAY_LISTEN_ANIMATION = function (self,entity,sender)
		local rnd = math.random(1,3);
		entity.actor:QueueAnimationState("relaxed_idle_listening_0"..rnd);
	end,
	
	--------------------------------------------------------------
	FOLLOW_LEADER = function(self,entity,sender,data)
		entity.AI.InSquad= 1;
		if(AI.GetGroupOf(entity.id)==0) then
			entity.Properties.bSquadMate = 1;
		end
	--	g_SignalData.ObjectName = "line_follow2";--formation to be used if not in follow mode
		AI.Signal(SIGNALFILTER_LEADER,10,"OnJoinTeam",entity.id);--,g_SignalData);
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	SHARED_STOP_ANIMATION = function( self, entity, sender )
		entity:StopAnimation( 0, 4 );
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	SHARED_PICK_UP = function( self, entity, sender, data )
	  local entityName = System.GetEntity( data.id ):GetName();
	  System.Log( "Picking up entity '"..entityName.."'" );
		entity:CreateBoneAttachment( 0, "weapon_bone", "right_item_attachment" );
		entity:SetAttachmentObject( 0, "right_item_attachment", data.id, -1, 0 );
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	SHARED_DROP = function( self, entity, sender, data )
		entity:ResetAttachment(0, "right_item_attachment");
	end,
	
	---------------------------------------------------------------------------------------------------------------------------------------
	HOLSTERITEM_TRUE = function( self, entity, sender )
		entity:HolsterItem( true );
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	HOLSTERITEM_FALSE = function( self, entity, sender )
		entity:DrawWeaponNow();
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	ORDER_TIMEOUT = function( self, entity, sender,data )
		if(data.fValue and data.fValue>0) then 
			g_StringTemp1 = "order_timeout"..math.floor(data.fValue*10)/10;
			AI.CreateGoalPipe(g_StringTemp1);
			AI.PushGoal(g_StringTemp1, "timeout",1,data.fValue);
			AI.PushGoal(g_StringTemp1, "signal", 0, 10, "ORD_DONE", SIGNALFILTER_LEADER);
			entity:InsertSubpipe(0,g_StringTemp1);
		else
			entity:InsertSubpipe(0, "order_timeout");
		end
	end,
	
	---------------------------------------------
	ORDER_ACQUIRE_TARGET = function(self , entity, sender, data)
		if(data.id ~= NULL_ENTITY) then
			entity:InsertSubpipe(0,"acquire_target",data.id);
		else
			entity:InsertSubpipe(0,"acquire_target",data.ObjectName);
		end
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	ORDER_COVER_SEARCH = function(self,entity,sender)
		-- ignore this order by default
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,	
	
	---------------------------------------------------------------------------------------------------------------------------------------
	CORNER = function( self, entity, sender )
		AI.SmartObjectEvent( "CORNER", entity.id, sender.id );
	end,	

	---------------------------------------------------------------------------------------------------------------------------------------
	SetTargetDistance = function (self,entity,dist)
		if(dist==nil or dist==0) then
			AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
			AI.SetPFBlockerRadius( entity.id, PFB_BEACON, 0);
		else
			local targetDist = AI.GetAttentionTargetDistance(entity.id)
			if(targetDist) then 
				local attDist = math.min(math.max(targetDist - 0.1,2),dist);
				AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, attDist);
			else
				AI.SetPFBlockerRadius( entity.id, PFB_BEACON, dist);
			end
		end
	end,
	
	---------------------------------------------------------------------------------------------------------------------------------------
	OnUpdateItems = function( self, entity, sender )
		-- check does he have RPG and update his combat class
		if ( entity.inventory:GetItemByClass("LAW") ) then
			AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.InfantryRPG );
			AI.LogEvent( entity:GetName().." changes his combat class to InfantryRPG on signal OnUpdateItems" );
		end
	end,	

	---------------------------------------------
	UNHIDE = function( self, entity, sender )
		if ( AI.SmartObjectEvent( "Unhide", entity.id ) <= 0 ) then
			entity:InsertSubpipe( 0, "shared_unhide" );
		end
	end,
			
	---------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------
	--
	--	FlowGraph	actions 
	--
	---------------------------------------------------------------------------------------------------------------------------------------

	ACT_DUMMY = function( self, entity, sender, data )
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
	end,
	
	ACT_EXECUTE = function( self, entity, sender, data )
	--	entity:InsertSubpipe( 0, "action_execute", nil, data.iValue );
		if(data) then
			AI.ExecuteAction( data.ObjectName, entity.id, sender.id, data.fValue, data.iValue );
		else
			AI.ExecuteAction( data.ObjectName, entity.id, entity.id, sender.fValue, sender.iValue );
		end	
		--AI.ChangeParameter(entity.id,AIPARAM_AWARENESS_PLAYER,0);
	end,
	
--	OnActionDone = function( self, entity, data )
--		AI.ChangeParameter(entity.id,AIPARAM_AWARENESS_PLAYER,entity.Properties.awarenessOfPlayer or 0);
--	end,
	
	ACT_FOLLOWPATH = function( self, entity, sender, data )
		local pathfind = data.point.x;
		local reverse = data.point.y;
		local startNearest = data.point.z;
		local loops = data.fValue;

		g_StringTemp1 = "follow_path";
		if(pathfind > 0) then
			g_StringTemp1 = g_StringTemp1.."_pathfind";
		end
		if(reverse > 0) then
			g_StringTemp1 = g_StringTemp1.."_reverse";
		end
		if(startNearest > 0) then
			g_StringTemp1 = g_StringTemp1.."_nearest";
		end
		
	  AI.CreateGoalPipe(g_StringTemp1);
    AI.PushGoal(g_StringTemp1, "followpath", 1, pathfind, reverse, startNearest, loops);
		AI.PushGoal(g_StringTemp1, "signal", 1, 1, "END_ACT_FOLLOWPATH",0);
    
    entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, g_StringTemp1, nil, data.iValue );
	end,

	ACT_GOTO = function( self, entity, sender, data )
		if ( data and data.point ) then
			AI.SetRefPointPosition( entity.id, data.point );

			-- use dynamically created goal pipe to set approach distance
			g_StringTemp1 = "action_goto"..data.fValue;
			AI.CreateGoalPipe(g_StringTemp1);
			AI.PushGoal(g_StringTemp1, "locate", 0, "refpoint");
			AI.PushGoal(g_StringTemp1, "+stick", 1, data.point2.x, AILASTOPRES_USE, 1, data.fValue);	-- noncontinuous stick
			AI.PushGoal(g_StringTemp1, "+branch", 0, "NO_PATH", IF_LASTOP_FAILED );
			AI.PushGoal(g_StringTemp1, "branch", 0, "END", BRANCH_ALWAYS );
			AI.PushLabel(g_StringTemp1, "NO_PATH" );
			AI.PushGoal(g_StringTemp1, "signal", 1, 1, "CANCEL_CURRENT",0);
			AI.PushLabel(g_StringTemp1, "END" );
			AI.PushGoal(g_StringTemp1, "signal", 1, 1, "END_ACT_GOTO",0);
			
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, g_StringTemp1, nil, data.iValue );
		end
	end,
	
	CANCEL_CURRENT = function( self, entity )
		entity:CancelSubpipe();
	end,

--	ACT_GOTO_LOOKAT = function( self, entity, sender )
--		local pos = g_Vectors.temp;
--		local dir = g_Vectors.temp_v1;
--		CopyVector(pos,AI.GetRefPointPosition(entity.id));
--		CopyVector(dir,AI.GetRefPointDirection(entity.id));
--		ScaleVectorInPlace(dir,10);
--		FastSumVectors(pos,pos,dir);
--		AI.SetRefPointPosition(entity.id,pos);
--
--	end,


	ACT_LOOKATPOINT = function( self, entity, sender, data )
		if ( data and data.point and (data.point.x~=0 or data.point.y~=0 or data.point.z~=0) ) then
			AI.SetRefPointPosition( entity.id, data.point );
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_lookatpoint", nil, data.iValue );
		else
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_resetlookat", nil, data.iValue );
		end
	end,


	-- make the guy shoot at the provided point	for fValue seconds
	ACT_SHOOTAT = function( self, entity, sender, data )

		-- use dynamically created goal pipe to set shooting time
		AI.CreateGoalPipe("action_shoot_at");
		AI.PushGoal("action_shoot_at", "locate", 0, "refpoint");
--		AI.PushGoal("action_shoot_at", "+lookat",1,0,0,true);		
		AI.PushGoal("action_shoot_at", "+firecmd",0,FIREMODE_FORCED,AILASTOPRES_USE);
		AI.PushGoal("action_shoot_at", "+timeout",1,data.fValue);
		AI.PushGoal("action_shoot_at", "firecmd",0,0);
		
		AI.SetRefPointPosition( entity.id, data.point );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_shoot_at", nil, data.iValue );

		-- draw weapon
		entity:DrawWeaponNow();	-- vehicles have no holster

	end,


	-- make the guy aim at the provided point	for fValue seconds
	ACT_AIMAT = function( self, entity, sender, data )

		-- use dynamically created goal pipe to set shooting time
		AI.CreateGoalPipe("action_aim_at");
		AI.PushGoal("action_aim_at", "locate", 0, "refpoint");
		AI.PushGoal("action_aim_at", "+firecmd",0,FIREMODE_AIM,AILASTOPRES_USE);
		AI.PushGoal("action_aim_at", "+timeout",1,data.fValue);
		AI.PushGoal("action_aim_at", "firecmd",0,0);
		
		AI.SetRefPointPosition( entity.id, data.point );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_aim_at", nil, data.iValue );

		-- draw weapon
		-- vehicles have no holster
		if(entity.DrawWeaponNow) then
			entity:DrawWeaponNow();	
		end	

	end,


	-- not used!!!
	---------------------------------------------
	ACT_SPEED = function( self, entity,sender,data )
		if(data and data.iValue==2) then
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_running");
		elseif(data and data.iValue==3) then
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_sprinting");
		elseif(data and data.iValue==0) then
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_very_slow");
		elseif(data and data.iValue==-1) then
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_super_slow");
		else
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_walking");
		end
		
	end,

	-- not used!!!
	---------------------------------------------
	ACT_STANCE = function( self, entity,sender,data )
		if(data and data.iValue==0) then
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_prone");
		elseif(data and data.iValue==1) then
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_crouched");
		else
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"do_it_standing");
		end
	end,
	
	--
	---------------------------------------------
	ACT_ANIM = function( self, entity, sender, data )
		AI.CreateGoalPipe( "act_animation" );
		AI.PushGoal( "act_animation", "timeout", 1, 0.1 );
		AI.PushGoal( "act_animation", "branch", 1, -1, BRANCH_ALWAYS );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "act_animation", nil, data.iValue );
		
	end,
	
	--
	---------------------------------------------
	ACT_DIALOG = function( self, entity, sender, data )
		AI.CreateGoalPipe( "act_animation" );
		AI.PushGoal( "act_animation", "timeout", 1, 0.1 );
		AI.PushGoal( "act_animation", "branch", 1, -1, BRANCH_ALWAYS );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "act_animation", nil, data.iValue );
	end,	
	
	--
	---------------------------------------------
	ACT_FOLLOW = function( self, entity,sender,data )
		if ( data == nil ) then
			-- this should never happen - lets warn
			AI.Warning("ACT_FOLLOW "..entity:GetName()..": nil data!");
	    -- insert and cancel the goal pipe to notify the node
	    entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, sender.iValue );
	    entity:CancelSubpipe( sender.iValue );
	    return;
		end
		self:ACT_JOINFORMATION(entity,sender,data);
	end,
	
	---------------------------------------------
	END_ACT_FORM = function(self,entity,sender)
	end,

	---------------------------------------------
	ACT_JOINFORMATION = function( self, entity, sender, data )
	
		if ( data == nil ) then
			-- this should never happen - lets warn
			AI.Warning("ACT_JOINFORMATION "..entity:GetName()..": nil data!");
	    -- insert and cancel the goal pipe to notify the node
	    entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, sender.iValue );
	    entity:CancelSubpipe( sender.iValue );
	    return;
		end

		if ( sender==nil) then
			-- insert and cancel the goal pipe to notify the node
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
			entity:CancelSubpipe( data.iValue );
			return;
		elseif(sender==entity) then 
			if ( entity.AI.followGoalPipeId and entity.AI.followGoalPipeId ~=0 ) then
				entity:CancelSubpipe( entity.AI.followGoalPipeId );
			end
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
			entity.AI.followGoalPipeId = data.iValue;
			return;
		end

		entity.AI.followGoalPipeId = data.iValue;
		
		local stance = AI.GetStance(sender.id);
		
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "stay_in_formation_moving", nil, data.iValue );

		if(stance==BODYPOS_CROUCH or  stance==BODYPOS_PRONE) then
			AI.SetStance(entity.id,stance);
		end

--		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, pipeName, nil, data.iValue );
		if(stance==BODYPOS_RELAX) then
			AI.SetStance(entity.id,stance);
		else -- join the formation in combat stance if it's to be crouch or prone after
			AI.SetStance(entity.id,BODYPOS_STAND);
		end
	end,

	
	--
	---------------------------------------------
	ACT_GRAB_OBJECT = function( self, entity, sender, data )
	
		if ( data == nil ) then
			-- this should never happen - lets warn
			AI.Warning("ACT_GRAB_OBJECT "..entity:GetName()..": nil data!");
	    -- insert and cancel the goal pipe to notify the node
	    entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, sender.iValue );
	    entity:CancelSubpipe( sender.iValue );
	    return;
		end
	
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_GRABBED",sender.id);
			if ( entity:GrabObject( sender ) ~= 1 ) then
				entity:CancelSubpipe( data.iValue );
			end;
	end,
	
	--
	---------------------------------------------
	ACT_DROP_OBJECT = function( self, entity, sender, data )
		if ( entity.grabParams and entity.grabParams.entityId ) then
			local grab = System.GetEntity( entity.grabParams.entityId );
			AI.Signal(SIGNALFILTER_SENDER,0,"OnDropped",entity.grabParams.entityId);
 			entity:DropObject( true, data.point, 0 );
 			
-- 			if ( grab ) then
--				--System.Log( "ACT_DROP_OBJECT received!!! Impulse is x:"..data.point.x.." y:"..data.point.y.." z:"..data.point.z );
-- 				grab:AddImpulse( -1, nil, data.point, LengthVector( data.point ), 1 );
-- 			end
 		end
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
		--AI.Signal( SIGNALFILTER_SENDER, 10, "ACTION_DONE", entity.id );
	end,
	
	--
	---------------------------------------------
	ACT_WEAPONDRAW = function( self, entity, sender, data )
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_weapondraw", nil, data.iValue );
	end,
	
	--
	---------------------------------------------
	ACT_WEAPONHOLSTER = function( self, entity, sender, data )
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_weaponholster", nil, data.iValue );
	end,

	--
	---------------------------------------------
	ACT_USEOBJECT = function( self, entity, sender, data )
	
		if ( data == nil ) then
			-- this should never happen - lets warn
			AI.Warning("ACT_USEOBJECT "..entity:GetName()..": nil data!");
	    -- insert and cancel the goal pipe to notify the node
	    entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, sender.iValue );
	    entity:CancelSubpipe( sender.iValue );
	    return;
		end
	
		if ( sender ) then
			sender:OnUsed( entity, 2 );
			AI.SmartObjectEvent( "OnUsed", sender.id, entity.id );
		end
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
	end,

	--
	---------------------------------------------
	ACT_WEAPONSELECT = function( self, entity, sender, data )
		ItemSystem.SetActorItemByName( entity.id, data.ObjectName,false );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
	end,
	
	--
	---------------------------------------------
	ACT_ALERTED = function( self, entity, sender, data )
		entity:MakeAlerted();
	end,
	
	---------------------------------------------
	SETUP_ENTERING = function( self, entity )
		-- signal sent from action_enter goal pipe
		if ( entity.AI.theVehicle ) then
			if ( entity.AI.theVehicle:EnterVehicle( entity.id, entity.AI.mySeat, true ) ~= true ) then
				entity:CancelSubpipe();
			end
		else
			entity:CancelSubpipe();
		end
	end,

	---------------------------------------------
	SETUP_ENTERING_FAST = function( self, entity )
		-- signal sent from action_enter goal pipe
		if ( entity.AI.theVehicle ) then
			if ( entity.AI.theVehicle:EnterVehicle( entity.id, entity.AI.mySeat, false ) ~= true ) then
				entity:CancelSubpipe();
			end
		else
			entity:CancelSubpipe();
		end
	end,

	---------------------------------------------
	ACT_ENTERVEHICLE = function( self, entity, sender, data )
		if ( entity.AI.theVehicle ) then
			-- fail if already inside a vehicle
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
			entity:CancelSubpipe( data.iValue );
			return;
		end
		
		-- get the vehicle
		entity.AI.theVehicle = System.GetEntity( data.id );
	 	if ( entity.AI.theVehicle == nil ) then
	 		-- no vehicle found
			AI.LogEvent( entity:GetName().." couldn't find the vehicle to enter" );
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_enter", nil, data.iValue );
			entity:CancelSubpipe( data.iValue );
	 		return;
	 	end

		local numSeats = count( entity.AI.theVehicle.Seats );
		--local numMembers = AI.GetGroupCount( entity.id, GROUP_ENABLED, AIOBJECT_PUPPET );

		--local seatIndex = data.fValue;
		if ( data.fValue<1 or data.fValue>numSeats ) then
			entity.AI.mySeat = entity.AI.theVehicle:RequestClosestSeat( entity.id );
		else
			entity.AI.mySeat = data.fValue;
		end
		
		if ( entity.AI.mySeat==nil ) then
			AI.LogEvent(entity:GetName().." aborting enter vehicle "..entity.AI.theVehicle:GetName());
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_enter", nil, data.iValue );
			entity:CancelSubpipe( data.iValue );
			return
		end
		
		entity.AI.theVehicle:ReserveSeat( entity.id, entity.AI.mySeat );
		if ( entity.AI.theVehicle:IsDriver(entity.id) ) then
			-- I'm the driver
--			entity.AI.theVehicle.AI.driver = entity;
--			entity.AI.theVehicle.AI.countVehicleCrew = 0;
			
			--if ( numSeats<numMembers ) then
			--	entity.AI.theVehicle.AI.vehicleCrewNumber = numSeats;
			--else
			--	entity.AI.theVehicle.AI.vehicleCrewNumber = numMembers;
			--end			
		end
		
		-- check is fast entering needed
		if ( data.iValue2 == 1 ) then
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_enter_fast", nil, data.iValue );
		else
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_enter", nil, data.iValue );
		end

		entity.AI.theVehicle.AI.goalType = AIGOALTYPE_UNDEFINED;
		--entity.AI.theVehicle.AI.goalType	= data.iValue;
--		AI.LogEvent(entity:GetName().." is going to enter vehicle "..entity.AI.theVehicle:GetName().." with goal type = "..(entity.AI.theVehicle.AI.goalType or "nil"));
		AI.Signal( SIGNALFILTER_SENDER, 0, "ENTERING_VEHICLE", entity.id );
	end,	

	---------------------------------------------
	ACT_EXITVEHICLE = function( self, entity, sender, data )
		if ( entity.AI.theVehicle == nil ) then
			-- fail if not inside a vehicle
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
			entity:CancelSubpipe( data.iValue );
			return;
		end

		if ( entity.AI.theVehicle:IsDriver(entity.id) ) then
			-- I'm the driver
--			entity.AI.theVehicle.AI.driver = entity;
--			entity.AI.theVehicle.AI.countVehicleCrew = 0;
			
			--if ( numSeats<numMembers ) then
			--	entity.AI.theVehicle.AI.vehicleCrewNumber = numSeats;
			--else
			--	entity.AI.theVehicle.AI.vehicleCrewNumber = numMembers;
			--end			
		end
		
		entity.AI.theVehicle:LeaveVehicle( entity.id );
		entity.AI.theVehicle = nil;

		entity:InsertSubpipe( AIGOALPIPE_HIGHPRIORITY, "action_exit", nil, data.iValue );
	end,

	---------------------------------------------------------------------
	ACT_ANIMEX = function( self, entity, sender, data )
		if ( data ) then
			-- use dynamically created goal pipe to set parameters
			AI.CreateGoalPipe( "action_animEx" );
			AI.PushGoal( "action_animEx", "locate", 0, "refpoint" );
			AI.PushGoal( "action_animEx", "+animtarget", 0, data.iValue2, data.ObjectName, data.point.x, data.fValue, data.point2.x );
			AI.PushGoal( "action_animEx", "+locate", 0, "animtarget" );
			AI.PushGoal( "action_animEx", "+approach", 1, 0.0, AILASTOPRES_USE );
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_animEx", nil, data.iValue );
		end
	end,

	---------------------------------------------------------------------
	SPOTTED_BY_SHARK = function(self,entity,sender,data)
		-- sent by SO rule, data.id = shark entity id
		local shark = System.GetEntity(data.id);
		if(shark) then 
			shark:Chase(entity);
		end
	end,

--this is not needed - switching suit modes using BasicAI functions
	---------------------------------------------------------------------
	NANOSUIT_ARMOR = function( self, entity, sender )
		entity.actor:SetNanoSuitMode(NANOMODE_DEFENSE);
		entity.AI.suitMode = 1;
	end,
	
--	---------------------------------------------------------------------
	NANOSUIT_CLOAK = function( self, entity, sender )
		entity:SetCloakType(0);
		entity.actor:SetNanoSuitMode(NANOMODE_CLOAK);
		entity.AI.suitMode = 2;		
	end,	
	
	---------------------------------------------------------------------
	DO_NOTHING = function(self,entity,sender)
			entity:SelectPipe(0,"standingthere");
			entity:SelectPipe(0,"do_nothing");			
	end,

	---------------------------------------------
	TARGETLASER_ON = function (self, entity, sender)
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, true);
	end,	
	
	---------------------------------------------
	TARGETLASER_OFF = function (self, entity, sender)
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);
	end,	

	---------------------------------------------
	SYS_FLASHLIGHT_ON = function (self, entity, sender)
		AI.EnableWeaponAccessory(entity.id, AIWEPA_COMBAT_LIGHT, true);
	end,	
	
	---------------------------------------------
	SYS_FLASHLIGHT_OFF = function (self, entity, sender)
		AI.EnableWeaponAccessory(entity.id, AIWEPA_COMBAT_LIGHT, false);
	end,	

	---------------------------------------------
	PATROL_FLASHLIGHT_ON = function (self, entity, sender)
		AI.EnableWeaponAccessory(entity.id, AIWEPA_PATROL_LIGHT, true);
	end,	
	
	---------------------------------------------
	PATROL_FLASHLIGHT_OFF = function (self, entity, sender)
		AI.EnableWeaponAccessory(entity.id, AIWEPA_PATROL_LIGHT, false);
	end,	

	---------------------------------------------------------------------
	NEW_SPAWN = function(self,entity,sender)
	
			if(entity.AI.reinfPoint) then
				entity:SelectPipe(0,"goto_point",entity.AI.reinfPoint);
			else
				entity:SelectPipe(0,"goto_point",g_SignalData.ObjectName);
			end
	end,


	TEST_SEARCH = function( self, entity, sender,data)
		--entity.AI.lookDir = {x=0,y=1,z=0};
		entity.AI.lookDir = {};
		CopyVector(entity.AI.lookDir,System.GetEntityByName("P1"):GetDirectionVector(1));
		AI.BeginGoalPipe("tr_order_search1");
			----
			AI.PushGoal("bodypos", 1, BODYPOS_STAND);
			AI.PushGoal("firecmd", 0,0);
			AI.PushGoal("pathfind", 1, "P1");
			AI.PushGoal("branch", 1, "PATH_FOUND", NOT+IF_NO_PATH);
				AI.PushGoal("signal",0,1,"OnUnitStop",SIGNALFILTER_LEADER);		
				AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
			AI.PushLabel("PATH_FOUND");
			AI.PushGoal("signal",0,1,"OnUnitMoving",SIGNALFILTER_LEADER);		
--			AI.PushGoal("trace",1,1);
			AI.PushGoal("locate", 1, "P1");
			AI.PushGoal("stick", 1, 0, AILASTOPRES_USE, 1, STICK_BREAK);	-- noncontinuous stick

			AI.PushGoal("signal",1,1,"TEST_SEARCH_REACHED",SIGNALFILTER_SENDER);		
			AI.PushGoal("bodypos", 1, BODYPOS_STEALTH);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+lookat",1,0,0,1,AI_LOOKAT_CONTINUOUS + AI_LOOKAT_USE_BODYDIR);
			AI.PushGoal("lookaround",1,20,3,3,5,AI_BREAK_ON_LIVE_TARGET);
			AI.PushGoal("lookat",1,-500);
			AI.PushLabel("DONE");	
			AI.PushGoal("bodypos", 1, BODYPOS_STAND);
			----------------
			AI.PushGoal("locate", 1, "P");
			AI.PushGoal("stick", 1, 0, AILASTOPRES_USE, 1, STICK_BREAK);	-- noncontinuous stick
			--AI.PushGoal("signal",1,1,"TEST_SEARCH",SIGNALFILTER_SENDER);		

		AI.EndGoalPipe();
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_order_search1");
	end,

}

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  
--------------------------------------------------------------------------
--  History:
--  - 15/02/2005   : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------

AIBehaviour.InVehicleGunner = {
	Name = "InVehicleGunner",
	Base = "InVehicle",
	--NOPREVIOUS = 1,
	exclusive = 1,

	-- SYSTEM EVENTS			-----
	Constructor = function(self, entity)

		if ( entity.actor:IsPlayer() ) then
			AI.LogEvent("ERROR : InVehicleGunner is used for the player");
		else
			entity.AI.theVehicle:UserEntered(entity);

			entity.AI.exitCounter = 0;

			-- never select any pipe here...ask Dejan.
			entity:InsertSubpipe(0,"devalue_target");
			AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS,AICombatClasses.VehicleGunner );		
			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 1 );
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, -30.0 );

			entity.AI.oldAimTurnSpeed = AI.GetAIParameter(entity.id, AIPARAM_AIM_TURNSPEED);
			entity.AI.oldFireTurnSpeed = AI.GetAIParameter(entity.id, AIPARAM_FIRE_TURNSPEED);
			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 60);
			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 36);
			
		end
		
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
    AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,0.5);
    AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,0.75);

	end,

 	Destructor = function( self, entity )	
   
 		-- to make him default
 		AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Infantry);		
 		AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
 		--entity:SelectPipe(0,"do_nothing");

		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, entity.AI.oldAimTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, entity.AI.oldFireTurnSpeed);

    AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,0.2);
    AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,0.5);

 	end,

 	---------------------------------------------
 	OnQueryUseObject = function ( self, entity, sender, extraData )
 		-- ignore this signal, execute DEFAULT
 		AIBehaviour.DEFAULT:OnQueryUseObject( entity, sender, extraData );
 	end,

	OnCloseCollision = function( self, entity, data )
	end,
	OnExposedToExplosion = function(self, entity, data)
	end,

	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GunnerLostTarget",entity.id);
		
		--AI.LogEvent("\001 gunner in vehicle lost target ");
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	
		AI.Signal(SIGNALFILTER_SENDER,1,"INVEHICLEGUNNER_REQUEST_SHOOT",entity.id);

	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
		
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
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	OnGroupMemberDiedNearest = function ( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id, data );
	end,
	OnSomebodyDied = function ( self, entity, sender)
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
	--------------------------------------------------
	OnDeath = function( self,entity )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id);	
		-- if driver killed - make all the passengers unignorant, get out/stop entering
		
		if(entity.AI.theVehicle )	then
			local tbl = VC.FindUserTable( entity.AI.theVehicle, entity );
			if( tbl and tbl.type == PVS_DRIVER ) then
				AI.Signal(SIGNALFILTER_GROUPONLY, -1, "MAKE_ME_UNIGNORANT",entity.id);		
			end
		end	
	end,
		---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,

	---------------------------------------------
	---------------------------------------------	--------------------------------------------------
	-- CUSTOM
	--------------------------------------------
	
	--------------------------------------------------
	SHARED_ENTER_ME_VEHICLE = function( self,entity, sender )
	
	-- in vehicle already - don't do anything

	end,

	--------------------------------------------------

	--------------------------------------------------
	SHARED_LEAVE_ME_VEHICLE = function( self,entity, sender )

		if( entity.ai == nil ) then return end

		if (entity.AI.theVehicle == nil) then
			return;
		end

		local vUp = { x=0.0, y=0.0, z=1.0 };	
		if ( entity.AI.theVehicle:GetDirectionVector(2) ) then
			if ( dotproduct3d( entity.AI.theVehicle:GetDirectionVector(2), vUp ) < math.cos( 60.0*3.1416 / 180.0 ) ) then
				return;
			end
		end

		entity.AI.theVehicle:LeaveVehicle(entity.id);
		entity.AI.theVehicle = nil;

		-- this handler is called when needs a emergency exit.
		-- should not request any goal pipe and entity.AI.theVehicle:AIDriver(0);
		-- 20/16/2006 Tetsuji

	end,

	--------------------------------------------
	exited_vehicle = function( self,entity, sender )
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,

	
	
	---------------------------------------------
	---------------------------------------------	--------------------------------------------------
	-- old FC stuff - to be revised	
	---------------------------------------------	--------------------------------------------------
	

	exited_vehicle_investigate = function( self,entity, sender )

		AI.Signal(SIGNALID_READIBILITY, 2, "AI_AGGRESSIVE",entity.id);	
		entity:TriggerEvent(AIEVENT_CLEAR);
		if(entity.HASBEACON == nil) then
			entity.EventToCall = "OnSpawn";	
		end
		if(entity.DriverKilled ~= nil) then
			local hit =	{
				dir = g_Vectors.v001,
				damage = 1,
				target = entity,
				shooter = entity,
				landed = 1,
				impact_force_mul_final=5,
				impact_force_mul=5,
				damage_type="healthonly",
			};
			entity:OnHit( hit );
		end
	end,

	--------------------------------------------
	do_exit_vehicle = function( self,entity, sender )

--		entity:TriggerEvent(AIEVENT_ENABLE);
--		entity:SelectPipe(0,"reevaluate");
AI.LogEvent( "puppet -------------------------------- exited_vehicle " );
--		entity:SelectPipe(0,"standingthere");		
		
		AI.SetIgnorant(entity.id,0);
		entity:SelectPipe(0,"b_user_getout", entity:GetName().."_land");
		
--		Previous();
	end,


 	---------------------------------------------
	START_VEHICLE = function(self,entity,sender)
		AI.LogEvent(entity:GetName().." starting vehicle "..entity.AI.theVehicle:GetName().." with goal type "..entity.AI.theVehicle.AI.goalType);
		local signal = entity.AI.theVehicle.AI.BehaviourSignals[entity.AI.theVehicle.AI.goalType];
		if(type(signal) =="string") then
			AI.Signal(SIGNALFILTER_SENDER,0,signal, entity.AI.theVehicle.id);
		else
			AI.Warning("Wrong signal type in START_VEHICLE - aborting starting vehicle");
		end
	end,


	--------------------------------------------
	desable_me = function( self,entity, sender )
		entity:TriggerEvent(AIEVENT_DISABLE);
	end,

	-- no need to run away from cars
	OnVehicleDanger = function(self,entity,sender)
	end,

	ORDER_EXIT_VEHICLE = function(self,entity,sender)
		AI.LogEvent(entity:GetName().." EXITING VEHICLE");
		entity.AI.theVehicle:LeaveVehicle(entity.id);
		entity.AI.theVehicle = nil;
		AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
		entity:SelectPipe(0,"stand_only");
	end,

	------------------------------------------------------------------------
	ORDER_ENTER_VEHICLE = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	------------------------------------------------------------------------
	ORDER_FORM =  function(self,entity,sender)
		self:ORDER_EXIT_VEHICLE(entity,sender);
	end,
	------------------------------------------------------------------------
	ORDER_FOLLOW =  function(self,entity,sender)
		self:ORDER_EXIT_VEHICLE(entity,sender);
	end,
	------------------------------------------------------------------------
	ORDER_FOLLOW_FIRE =  function(self,entity,sender)
		self:ORDER_EXIT_VEHICLE(entity,sender);
	end,
	------------------------------------------------------------------------
	ORDER_FOLLOW_HIDE =  function(self,entity,sender)
		self:ORDER_EXIT_VEHICLE(entity,sender);
	end,
	------------------------------------------------------------------------
	-- important group signals 

	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	INCOMING_FIRE = function (self, entity, sender)
	end,
	GET_ALERTED = function( self, entity )
	end,
	DO_SOMETHING_IDLE = function( self,entity , sender)
	end,
	
	--------------------------------------------------
	-- important signals 

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
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	--------------------------------------------
	-- for the 2nd gunner of the vehicle 
	-- the second gunner is requested to shoot by the vehicle AI

	INVEHICLEGUNNER_REQUEST_SHOOT = function(self,entity,sender,data)

		if ( sender.id == entity.id ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"controll_vehicleGunner",entity.id,data);
		end

	end,
	
	--------------------------------------------
		
	EXIT_VEHICLE_STAND = function(self,entity,sender)
	  -- prevent multiple EXIT_VEHICLE_STAND
		if (entity.AI.theVehicle == nil) then
			return;
		end
		-- I'm the gunner, before I check if there are enemies around
		local targetType = AI.GetTargetType(entity.id);
		local targetfound = false;
		if(targetType ==AITARGET_ENEMY or targetType ==AITARGET_SOUND or targetType ==AITARGET_MEMORY) then
			entity:SelectPipe(0,"vehicle_gunner_cover_fire");
		else
			local groupTarget = AI.GetGroupTarget(entity.id,true);
			if(groupTarget) then
				entity:SelectPipe(0,"vehicle_gunner_cover_fire");
				if(groupTarget.id) then 
					entity:InsertSubpipe(0,"acquire_target",groupTarget.id);
				else
					entity:InsertSubpipe(0,"acquire_target",groupTarget);
				end
			else				
				self:EXIT_VEHICLE_DONE(entity,sender);
			end
		end
	end,
	
	EXIT_VEHICLE_DONE = function(self,entity,sender)
		entity.AI.theVehicle:LeaveVehicle(entity.id);
		entity.AI.theVehicle = nil;
		AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
		entity:SelectPipe(0,"stand_only");
	end,
	
	--------------------------------------------------
	-- ignore grenade when in the vehicle
	OnGrenadeDanger = function( self, entity, signalData )
	end,

	--------------------------------------------------
	INVEHICLEGUNNER_CHECKGETOFF = function( self, entity )
	
		-- if the player stays near the gunner more than 15 sec,
		-- gunner will get off.

		if ( entity.AI.bInvehicleBehaviorMode == true ) then
		else

			if ( entity.AI.theVehicle ) then
			else
 				entity.AI.exitCounter = 0;
				return;
			end

			if ( AI.GetTypeOf( entity.AI.theVehicle.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( entity.AI.theVehicle.id ) == AIOBJECT_CAR ) then
			else
 				entity.AI.exitCounter = 0;
				return;
			end

			-- when there is no driver	
			for i,seat in pairs(entity.AI.theVehicle.Seats) do
				if( seat.passengerId ) then
					local member = System.GetEntity( seat.passengerId );
					if( member ~= nil ) then
					  if (seat.isDriver) then
		  				entity.AI.exitCounter = 0;
					  	return;
						end
					end
				end
			end		
	
			-- when the target is with in 15m
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target ) then
			else
 				entity.AI.exitCounter = 0;
				return;
			end
			
			if ( DistanceVectors( entity:GetPos(), target:GetPos() ) > 5.0 ) then			
 				entity.AI.exitCounter = 0;
				return;
			end

			if ( entity.AI.exitCounter > 20 ) then
				self:EXIT_VEHICLE_STAND( entity );
				return;
			end
	
			entity.AI.exitCounter = entity.AI.exitCounter + 1;

		end
		
	end,

}

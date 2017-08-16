--------------------------------------------------
--    Created By: Luciano
--------------------------
--

AIBehaviour.InVehicle = {
	Name = "InVehicle",
	Base = "Dumb",
	exclusive = 1,
--	Base = "HBaseIdle",
--	NOPREVIOUS = 1,

	-- SYSTEM EVENTS			-----
	Constructor = function(self, entity)
		entity.AI.theVehicle:UserEntered(entity);
	--	entity:InsertSubpipe(0,"devalue_target");
		
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);

	end,
	
	Destructor = function( self, entity )	
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"clear_all");
	end,
	
 	OnQueryUseObject = function ( self, entity, sender, extraData )
 		-- ignore this signal, execute DEFAULT
 		AIBehaviour.DEFAULT:OnQueryUseObject( entity, sender, extraData );
 	end,

	OnCloseCollision = function( self, entity, data )
	end,
	OnExposedToExplosion = function(self, entity, data)
	end,

 	---------------------------------------------
 	
	START_VEHICLE = function(self,entity,sender)
		AI.LogEvent(entity:GetName().." starting vehicle "..entity.AI.theVehicle:GetName().." with goal type "..(entity.AI.theVehicle.AI.goalType or "nil"));
		local signal = entity.AI.theVehicle.AI.BehaviourSignals[entity.AI.theVehicle.AI.goalType];
		if(type(signal) =="string") then
			AI.LogEvent(">>>> signal "..signal);
			AI.Signal(SIGNALFILTER_SENDER,0,signal, entity.AI.theVehicle.id);
		else
			AI.Warning("Wrong signal type in START_VEHICLE - aborting starting vehicle");
		end
		entity:SelectPipe(0,"do_nothing");
	end,
	---------------------------------------------
--	VEHICLE_REFPOINT_REACHED = function( self,entity, sender )
--		-- called by vehicle when it reaches the reference Point 
--		--entity.AI.theVehicle:SignalCrew("exited_vehicle");
--		AI.Signal(SIGNALFILTER_SENDER,1,"STOP_AND_EXIT",entity.AI.theVehicle.id);
--	end,

	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	
		--AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GunnerLostTarget",entity.id);
		
		--AI.LogEvent("\001 gunner in vehicle lost target ");
		-- caLled when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	
		-- called when the enemy sees a living player
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
		
	end,
	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,
	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnEnemyDamage = function( self, entity )
		
	end,
	---------------------------------------------
	OnFriendlyDamage = function( self, entity )
		
	end,
	---------------------------------------------
	OnDamage = function( self, entity )
		
	end,
	---------------------------------------------
	OnNearMiss = function( self, entity )
		
	end,

	---------------------------------------------
	OnExplosionDanger = function( self, entity,sender,data )
		if(data and data.id) then 
			local exploding = System.GetEntity(data.id);
			if(exploding and exploding == entity.AI.theVehicle) then
				self:ORDER_EXIT_VEHICLE(entity,sender);
				AI.SetRefPointPosition(entity.id,exploding:GetPos());
				entity:InsertSubpipe(0,"cv_backoff_from_explosion");
			end
		end
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
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied", entity.id, data );
	end,
	OnSomebodyDied = function ( self, entity, sender)
	end,

	--------------------------------------------------
	OnBodyFallSound = function(self, entity, sender, data)
	end,
	---------------------------------------------
	OnGrenadeDanger = function( self, entity, signalData )
	end,
	---------------------------------------------
	OnChangeStance = function(self,entity,sender,data)
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
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,
	--------------------------------------------------
	OnGroupChanged = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnTargetCloaked = function(self, entity)
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
	SHARED_LEAVE_ME_VEHICLE = function( self, entity, sender )

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


	-- no need to run away from cars
	OnVehicleDanger = function(self,entity,sender)
	end,

	EXIT_VEHICLE_STAND_PRE = function(self,entity,sender,data)

		AI.CreateGoalPipe("exitvehiclestandpre");
		AI.PushGoal("exitvehiclestandpre","timeout",1,data.fValue+0.1);
		AI.PushGoal("exitvehiclestandpre","signal",1,1,"EXIT_VEHICLE_STAND",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"exitvehiclestandpre");

	end,

	EXIT_VEHICLE_STAND = function(self,entity,sender)
	  -- prevent multiple EXIT_VEHICLE_STAND
		if (entity.AI.theVehicle == nil) then
			return;
		end
		if(entity.AI.theVehicle:IsDriver(entity.id)) then
			-- disable vehicle's AI
			entity.AI.theVehicle:AIDriver(0);
		end
		entity.AI.theVehicle:LeaveVehicle(entity.id);
		entity.AI.theVehicle = nil;
		AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
		entity:SelectPipe(0,"stand_only");
	end,
	
	
	ORDER_EXIT_VEHICLE = function(self,entity,sender)
		--AI.LogEvent(entity:GetName().." EXITING VEHICLE");
		entity.AI.theVehicle:LeaveVehicle(entity.id);
		entity.AI.theVehicle = nil;
		AI.Signal(SIGNALFILTER_LEADER, 10,"ORD_DONE",entity.id);
		entity:SelectPipe(0,"stand_only");
	end,
	------------------------------------------------------------------------
	ORDER_ENTER_VEHICLE = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
 	---------------------------------------------
	-- ignore this orders when in vehicle
	ORDER_FOLLOW = function(self,entity,sender)
	end,
	ORDER_HIDE = function(self,entity,sender)
	end,
	ORDER_FIRE = function(self,entity,sender)
	end,

	ACT_FOLLOW = function(self,entity,sender)
	end,
	DO_SOMETHING_IDLE = function( self,entity , sender)
	end,

	------------------------------------------------------------------------
	-- important group signals 

	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	INCOMING_FIRE = function (self, entity, sender)
		entity.AI.needsAlerted = 1;
	end,
	GET_ALERTED = function( self, entity )
		entity.AI.needsAlerted = 1;
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
	
	--------------------------------------------------
	-- ignore grenade when in the vehicle
	OnGrenadeDanger = function( self, entity, signalData )
	end,
	
	--------------------------------------------
	-- for the driver
	-- the driver is requested to contorl vehicle

	INVEHICLE_REQUEST_CONTROL = function(self,entity,sender,data)

			AI.Signal(SIGNALFILTER_SENDER,1,"controll_vehicle",entity.id,data);

	end,

	--------------------------------------------
	-- instant changing seat
	INVEHICLE_CHANGESEAT_TODRIVER = function(self,entity,sender,data)

		entity.AI.bChangeSeat = true;

	end,

	ACT_DUMMY = function(self,entity,sender,data)
	
		if ( entity.AI.bChangeSeat ~=nil and entity.AI.bChangeSeat == true ) then





		else
			AIBehaviour.DEFAULT:ACT_DUMMY( entity, sender, data );
		end

		entity.AI.bChangeSeat = false;

	end,
	


}
--------------------------------------------------
--   Created By: petar
--   Description: the idle behaviour for the cover
--------------------------
--   modified by: sten 23-10-2002

AIBehaviour.CoverGroupIdle = {
	Name = "CoverGroupIdle",
	
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player

		entity:RequestVehicle(AIGOALTYPE_ATTACK);
		entity:MakeAlerted();		
		
		if(entity.IN_SQUAD==1) then
			entity:SelectPipe(0,"random_reacting_timeout");
			entity:InsertSubpipe(0,"notify_player_seen");
			do return end;
		end	
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player

		entity:Readibility("IDLE_TO_INTERESTED");

		entity:SelectPipe(0,"cover_look_closer");
		entity:InsertSubpipe(0,"setup_stealth"); 
		entity:InsertSubpipe(0,"DRAW_GUN"); 

		-- you are going to CoverInterested
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound

	end,

	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		entity:SelectPipe(0,"cover_scramble");
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when detect weapon fire around AI
	
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);
		
	end,

	
	---------------------------------------------
	OnVehicleSuggestion = function(self, entity)
		-- called when a vehicle would be better to reach the attention/last_op target
		-- AI Suggest me to use a vehicle, I'll search for it and I'll use it
						
	end,

	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
				
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,

	--------------------------------------------------

	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"cover_investigate_threat");		
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		if (entity ~= sender) then
			entity:MakeAlerted();
--			entity:InsertSubpipe(0,"DRAW_GUN");
		end
	end,

	---------------------------------------------	
	THREAT_TOO_CLOSE = function (self, entity, sender)
		-- the team can split
		entity:MakeAlerted();

--		entity:SelectPipe(0,"cover_investigate_threat"); 
--		entity:InsertSubpipe(0,"do_it_running");
--
--		entity:InsertSubpipe(0,"cover_threatened"); 
	end,



	-------------------------------------------------
	GO_TO_DESTINATION = function(self, entity, sender, data)
		-- data.id = vehicle id
		-- data.point = destination
		if(data==nil) then
			AI.Warning("No destination data in GO_TO_DESTINATION");
			do return end
		elseif(data.point==nil or data.id==nil) then
			AI.Warning("Wrong destination data format in GO_TO_DESTINATION");
			do return end
		end
		
	 	if(data.id >0) then
	 		-- a vehicle is passed as well
	 		local vehicle = System.GetEntity(data.id);
	 		if(vehicle==nil) then
	 			do return end
	 		end
	 		
			AI.SetRefPointPosition(vehicle.id,data.point);
			
			local goalType;
			if(data.ObjectName ~="" and data.ObjectName ~=nil) then
				goalType = AIGOALTYPE_TRANSPORT; 
			else
				goalType = AIGOALTYPE_GOTO; 
			end		
			
	 		if(BasicAI:SelectVehicle(entity, data.point, data.id, goalType)==0) then
	 			-- vehicle choice has failed, what to do?
	 			AI.Signal(0,1,"CANNOT_USE_VEHICLE",sender.id);
	 		end
 	 	else
			-- go by feet...
			AI.Warning("No vehicle chosen in GO_TO_DESTINATION");
	 	end
	end,
	
	ORDER_FOLLOW = function (self, entity, sender)
		entity:SelectPipe(0,"squad_form");
		entity:InsertSubpipe(0,"do_it_running");
	end,
	
	FORMATION_REACHED = function (self, entity, sender)
	
		entity:SelectPipe(0,"stay_in_formation_moving");
		entity:InsertSubpipe(0,"do_it_walking");
	end,
	
}
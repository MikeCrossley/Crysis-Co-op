
AIBehaviour.Car_patrol = {
	Name = "Car_patrol",
	

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnSpawn = function(self , entity )

	end,
	---------------------------------------------
	OnActivate = function(self, entity )

	end,
	---------------------------------------------
	---------------------------------------------
	OnGrenadeSeen = function(self, entity )

printf( "Vehicle -------------- OnGranateSeen" );	
	
		entity:InsertSubpipe(0,"c_grenade_run_away" );
		
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self,entity,sender )
--	OnDeath = function( self,entity,sender )

--do return end
	
printf( "Vehicle -------------- OnDeath" );	
	
		if( sender == entity.AI.driver ) then				-- stop if the driver is killed
			AI:Signal( 0, 1, "STOP_VEHICLE",entity.id);
--			entity:SelectPipe(0,"c_brake");		
--			entity:SelectPipe(0,"c_standingthere" );
		end	
	
	end,	

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
--printf( "Vehicle -------------- RejectPlayer" );	

--		entity:TriggerEvent(AIEVENT_REJECT);

	end,

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--printf( "Vehicle -------------- RejectPlayer" );	

--		AI:Signal( 0, 1, "EVERYONE_OUT",entity.id);
		entity.AI.HASBEACON = 1;					
	
		if( _localplayer.AI.theVehicle ) then
			AI:Signal( 0, 1, "GO_CHASE",entity.id);
		elseif( entity.Properties.bApproachPlayer == 1 ) then
			entity:SelectPipe(0,"c_approach_n_drop");
		else
			AI:Signal( 0, 1, "EVERYONE_OUT",entity.id);
		end	

	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------
	---------------------------------------------
	VEHICLE_ARRIVED = function( self,entity, sender )
		printf( "Vehicle is there" );
		entity:SelectPipe(0,"v_brake");
	end,
	

	--------------------------------------------
	DRIVER_IN = function( self,entity, sender )
	
		AI:Signal( 0, 1, "next_point",entity.id);					
		
--entity:SelectPipe(0,"c_standingthere");		
		
	end,	
	
	--------------------------------------------
	EVERYONE_OUT = function( self,entity, sender )

		entity:SelectPipe(0,"c_brake");
		entity:TriggerEvent(AIEVENT_DROPBEACON);

--		entity:EveryoneOut();	
		VC.DropPeople( entity );
--		AI:Signal( 0, 1, "next_point",entity.id);					
--entity:SelectPipe(0,"c_standingthere");
				
		
	end,	
	


	---------------------------------------------
	GUNNER_OUT = function( self,entity,sender )
--printf( "car patol  -------------- driver out" );	
		entity:SelectPipe(0,"c_brake" );
		entity:DropPeople();
	end,	

	--------------------------------------------
	next_point = function( self,entity, sender )	
	
		entity.AI.step = entity.AI.step + 1;
		if( entity.AI.step >= entity.Properties.pathsteps ) then
			if( entity.Properties.bPathloop == 1 ) then
				entity.AI.step = entity.Properties.pathstart;			
			else	
				AI:Signal( 0, 1, "EVERYONE_OUT",entity.id);
			end	
		end	
		
		printf( "---->>let's go!!  #%d", entity.AI.step );		
		entity:SelectPipe(0,"c_goto", entity.Properties.pathname..entity.AI.step);
--		entity:SelectPipe(0,"c_goto_path", entity.Properties.pathname..self.step);		

	end,
	
}

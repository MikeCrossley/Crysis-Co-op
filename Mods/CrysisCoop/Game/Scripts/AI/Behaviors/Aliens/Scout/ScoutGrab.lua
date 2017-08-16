--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple outdoor indoor alien behavior
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutGrab = {
	Name = "ScoutGrab",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )
		-- called when the behaviour is selected

		-- for grab attack
		entity.AI.vGrabPos = {};

		-- Default action
		AI.CreateGoalPipe("scoutGrabDefault");
		AI.PushGoal("scoutGrabDefault","timeout",1,0.3);
		AI.PushGoal("scoutGrabDefault","signal",0,1,"SC_SCOUT_START_CAPTURE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutGrabDefault");

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
		entity:DropGrab();

		entity:SelectPipe(0,"do_nothing");

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnCloseContact= function( self, entity )
		-- called when AI gets at close distance to an enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )

	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_START_CAPTURE = function( self, entity )

		local grabPattern = AIBehaviour.SCOUTDEFAULT:scoutGetGrabTarget( entity );

		if ( grabPattern == 1 ) then
	
			-- Capture attack (PhisicsEntity).

			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 5.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.LogEvent(entity:GetName().." SC_SCOUT_START_CAPTURE : out of the flight region 2 - canceled");
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

			AI.CreateGoalPipe("scoutAttackCapturePhsycis");
			AI.PushGoal("scoutAttackCapturePhsycis","firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("scoutAttackCapturePhsycis","run",0,1);	
			AI.PushGoal("scoutAttackCapturePhsycis","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackCapturePhsycis","approach",1,18.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutAttackCapturePhsycis","run",0,0);	
			AI.PushGoal("scoutAttackCapturePhsycis","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackCapturePhsycis","approach",1,12.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutAttackCapturePhsycis","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackCapturePhsycis","acqtarget",0,"");
			AI.PushGoal("scoutAttackCapturePhsycis","stick",1,5.0,AILASTOPRES_LOOKAT,1);
			AI.PushGoal("scoutAttackCapturePhsycis","firecmd",0,0);
			AI.PushGoal("scoutAttackCapturePhsycis","signal",0,1,"SC_SCOUT_CAPTURE_PHYSICS",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutAttackCapturePhsycis");

		elseif ( grabPattern == 0 ) then

			-- Capture attack (Player).

			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then

				-- if he rides on the vehicles, switch the target to the vehicle.
				if ( target.actor ) then
					local vehicleId = target.actor:GetLinkedVehicleId();
					if ( vehicleId ) then
						target = System.GetEntity( vehicleId );
						AI.LogEvent("SC_SCOUT_START_CAPTURE:Switchedthe grab target to "..target:GetName());
					end
				end

				entity.AI.captureTargetEntity = target;
							
				local targetPos = {};
				local targetDir = {};

				CopyVector( targetPos, entity.AI.captureTargetEntity:GetPos() );
				CopyVector( targetDir, entity:GetPos() );
				FastScaleVector( targetDir , targetDir , -1.0 );
				FastSumVectors( targetDir , targetDir , targetPos );
				NormalizeVector( targetDir );					
				FastScaleVector( targetDir , targetDir , -5.0 );
				FastSumVectors( targetPos , targetPos , targetDir );

				AI.SetRefPointPosition( entity.id, targetPos );
				AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 5.0 );
				if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
					AI.LogEvent(entity:GetName().." SC_SCOUT_START_CAPTURE : out of the flight region - canceled");
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
					return;
				end

				AI.CreateGoalPipe("scoutAttackCapture");
				AI.PushGoal("scoutAttackCapture","firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("scoutAttackCapture","run",0,1);	
				AI.PushGoal("scoutAttackCapture","locate",0,"refpoint");		
				AI.PushGoal("scoutAttackCapture","approach",1,18.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutAttackCapture","firecmd",0,0);
				AI.PushGoal("scoutAttackCapture","run",0,0);	
				AI.PushGoal("scoutAttackCapture","locate",0,"refpoint");		
				AI.PushGoal("scoutAttackCapture","approach",1,12.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutAttackCapture","locate",0,"refpoint");		
				AI.PushGoal("scoutAttackCapture","acqtarget",0,"");
				AI.PushGoal("scoutAttackCapture","stick",1,8.0,AILASTOPRES_LOOKAT,1);
				AI.PushGoal("scoutAttackCapture","signal",0,1,"SC_SCOUT_CAPTURE",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackCapture");

			else

				-- Stop capturing
				AI.LogEvent(entity:GetName().." SC_SCOUT_START_CAPTURE : failed to grab - no target ");
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);

			end

		else

			AI.LogEvent(entity:GetName().." SC_SCOUT_START_CAPTURE : stopped grabing - there is a friend ");
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
		
		end

	end,

	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	SC_SCOUT_CAPTURE = function( self, entity )

		local attackPos = {};
		local diff = {};
		local entPos = {};

		CopyVector( entPos, entity:GetPos() );

		local	enemyPos = {}
			
		CopyVector( enemyPos, entity.AI.captureTargetEntity:GetPos() );

		SubVectors( diff, entPos, enemyPos );
		local targetDist = LengthVector( diff );

		if( targetDist < 15.0 ) then

			if ( entity:GrabObject( entity.AI.captureTargetEntity ) ) then

				CopyVector( entity.AI.vGrabPos, entity:GetPos() );

				local targetUpDir = {};
				CopyVector( targetUpDir, entity.AI.captureTargetEntity:GetDirectionVector(2) );
				FastScaleVector( targetUpDir, targetUpDir, 20.0 );
				FastSumVectors( enemyPos, enemyPos, targetUpDir);

				AI.SetRefPointPosition( entity.id , enemyPos  );
				AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
				if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
					AI.LogEvent(entity:GetName().." SC_SCOUT_CAPTURE : out of the flight region 3 - canceled");
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
					return;
				end
				
				AI.CreateGoalPipe("scoutCapture");
				AI.PushGoal("scoutCapture","timeout",0,1.0);
				AI.PushGoal("scoutCapture","run",0,0);	
				AI.PushGoal("scoutCapture","locate",0,"refpoint");		
				AI.PushGoal("scoutCapture","approach",1,2.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutCapture","signal",0,1,"SC_SCOUT_DROP",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutCapture");

				return;

			else
				AI.LogEvent(entity:GetName().." SC_SCOUT_CAPTURE : capture() failed ");
			end

		end
		
		AI.LogEvent(entity:GetName().." SC_SCOUT_CAPTURE : failed to grab - too far away ");
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);						

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_DROP = function( self, entity )
	
		AI.SetRefPointPosition( entity.id , entity.AI.vGrabPos  );
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end

		AI.CreateGoalPipe("scoutDrop");
		AI.PushGoal("scoutDrop","timeout",0,3.0);
		AI.PushGoal("scoutDrop","run",0,0);	
		AI.PushGoal("scoutDrop","locate",0,"refpoint");		
		AI.PushGoal("scoutDrop","approach",1,3.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutDrop","signal",0,1,"SC_SCOUT_DROP_END",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutDrop");

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_DROP_END = function( self, entity )
	
		--entity:DropGrab();
		local throwVec ={};
		
		CopyVector( throwVec, entity:GetDirectionVector() );
		
		throwVec.x = throwVec.x *3.0;
		throwVec.y = throwVec.y *3.0;
		throwVec.z = throwVec.z *10.0;
		
		entity:DropObject(false,throwVec)
		entity:SelectPipe(0,"do_nothing");
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);						

	end,

	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	SC_SCOUT_CAPTURE_PHYSICS = function( self, entity )

		local attackPos = {};
		local diff = {};
		local entPos = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			CopyVector( entPos, entity:GetPos() );

			local	enemyPos = {}
			
			CopyVector( enemyPos, entity.AI.captureTargetEntity:GetPos() );

			SubVectors( diff, entPos, enemyPos );
			local targetDist = LengthVector( diff );

			if( targetDist < 25.0 ) then

				if ( entity:GrabObject( entity.AI.captureTargetEntity ) ) then

					CopyVector( entity.AI.vGrabPos, entity:GetPos() );

					local escapeDir = {};
					local upDir = {};
					AIBehaviour.SCOUTDEFAULT:scoutGetScaledDirectionVector(entity,escapeDir,target:GetPos(),entity:GetPos(),5.0);
					--AIBehaviour.SCOUTDEFAULT:scoutGetScaledUpVector(target,upDir,10.0);
					FastSumVectors( escapeDir, escapeDir, entity:GetPos() );
					--FastSumVectors( escapeDir, escapeDir, upDir );

					AI.SetRefPointPosition( entity.id , escapeDir  );
					AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
					if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
						return;
					end
				
					AI.CreateGoalPipe("scoutCapturePhysics");
					AI.PushGoal("scoutCapturePhysics","run",0,0);
					AI.PushGoal("scoutCapturePhysics","locate",0,"refpoint");		
					AI.PushGoal("scoutCapturePhysics","approach",1,1.0,AILASTOPRES_USE,-1);
					AI.PushGoal("scoutCapturePhysics","signal",0,1,"SC_SCOUT_DROP_PHYSICS_END",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"scoutCapturePhysics");
					return;

				else
					--AI.LogComment(entity:GetName().." SC_SCOUT_CAPTURE_PHYSICS : failed to grab object ");
				end

			else
				--AI.LogComment(entity:GetName().." SC_SCOUT_CAPTURE_PHYSICS : failed to grab object - too far");
			end

		else
			--AI.LogComment(entity:GetName().." SC_SCOUT_CAPTURE_PHYSICS : failed to grab object - no target");
		end

		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);						

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_DROP_PHYSICS_END = function( self, entity )
		
		local target = AI.GetAttentionTargetEntity( entity.id );

		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local throwPos = {};
			local upDir = {};

			CopyVector( throwPos, target:GetPos() );
			AIBehaviour.SCOUTDEFAULT:scoutGetScaledUpVector(target,upDir,2.0);
			FastSumVectors( throwPos, throwPos, upDir );
			entity:DropObjectAtPoint( throwPos );

		else

			local throwVec ={};

			CopyVector( throwVec, entity:GetDirectionVector() );
		
			throwVec.x = throwVec.x *5.0;
			throwVec.y = throwVec.y *5.0;
			throwVec.z = throwVec.z *10.0;
		
			entity:DropObject(false); --0.0 means throw now!

		end

		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 10.0 );
		AI.CreateGoalPipe("scoutDropPhysicsEnd");
		AI.PushGoal("scoutDropPhysicsEnd","timeout",0,2.0);
		AI.PushGoal("scoutDropPhysicsEnd","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("scoutDropPhysicsEnd","timeout",1,2.0);
		AI.PushGoal("scoutDropPhysicsEnd","firecmd",0,0);
		AI.PushGoal("scoutDropPhysicsEnd","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutDropPhysicsEnd");

	end,

}


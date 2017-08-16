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
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Add new attack patterns by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutCircling = {

	Name = "ScoutCircling",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition
		
		-- Initialize and make point infomation from the position of 2 anchors.
		-- Point infomation consists of 24 points.
		-- A rectangle is made from the line whose ends are these 2 anchors.
		-- At first, a rectangle is made , then transform this rectangle into a circle.

		-- When the scout is at the right side of the line, 
		-- the scout will go round at the right side of the line.
		-- If these is no anchor, go to the "ScoutSearch" state.

		-- 29/11/05 Tetsuji

		-- Initialize entity variables.
			
		local i=0;
		local j=0;

		local vec1 ={ x=0.0,y=0.0,z=0.0 };
		local vec2 ={ x=0.0,y=0.0,z=0.0 };
		local vec3 ={ x=0.0,y=0.0,z=0.0 };
		local vec4 ={ x=0.0,y=0.0,z=0.0 };
		local vec5 ={ x=0.0,y=0.0,z=0.0 };
		local vec6 ={ x=0.0,y=0.0,z=0.0 };
		local vec7 ={ x=0.0,y=0.0,z=0.0 };
		local vec8 ={ x=0.0,y=0.0,z=0.0 };
		local vec9 ={ x=0.0,y=0.0,z=0.0 };
		local vec10 ={ x=0.0,y=0.0,z=0.0 };
		local vec11 ={ x=0.0,y=0.0,z=0.0 };
		local vec12 ={ x=0.0,y=0.0,z=0.0 };
		local vec13 ={ x=0.0,y=0.0,z=0.0 };
		local vec14 ={ x=0.0,y=0.0,z=0.0 };
		local vec15 ={ x=0.0,y=0.0,z=0.0 };
		local vec16 ={ x=0.0,y=0.0,z=0.0 };
		local vec17 ={ x=0.0,y=0.0,z=0.0 };
		local vec18 ={ x=0.0,y=0.0,z=0.0 };
		local vec19 ={ x=0.0,y=0.0,z=0.0 };
		local vec20 ={ x=0.0,y=0.0,z=0.0 };
		local vec21 ={ x=0.0,y=0.0,z=0.0 };
		local vec22 ={ x=0.0,y=0.0,z=0.0 };
		local vec23 ={ x=0.0,y=0.0,z=0.0 };
		local vec24 ={ x=0.0,y=0.0,z=0.0 };

		entity.AI.vec1 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec2 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec3 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec4 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec5 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec6 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec7 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec8 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec9 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec10 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec11 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec12 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec13 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec14 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec15 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec16 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec17 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec18 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec19 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec20 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec21 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec22 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec23 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.vec24 ={ x=0.0,y=0.0,z=0.0 };

		entity.AI.movevec = {
			entity.AI.vec1,
			entity.AI.vec2,
			entity.AI.vec3,
			entity.AI.vec4,
			entity.AI.vec5,
			entity.AI.vec6,
			entity.AI.vec7,
			entity.AI.vec8,
			entity.AI.vec9,
			entity.AI.vec10,
			entity.AI.vec11,
			entity.AI.vec12,
			entity.AI.vec13,
			entity.AI.vec14,
			entity.AI.vec15,
			entity.AI.vec16,
			entity.AI.vec17,
			entity.AI.vec18,
			entity.AI.vec19,
			entity.AI.vec20,
			entity.AI.vec21,
			entity.AI.vec22,
			entity.AI.vec23,
			entity.AI.vec24,
		};

		movevec = {
			vec1,
			vec2,
			vec3,
			vec4,
			vec5,
			vec6,
			vec7,
			vec8,
			vec9,
			vec10,
			vec11,
			vec12,
			vec13,
			vec14,
			vec15,
			vec16,
			vec17,
			vec18,
			vec19,
			vec20,
			vec21,
			vec22,
			vec23,
			vec24,
		};

		-- wing vector of entity.anchors
		entity.AI.anchorWng = {};

		-- direction vector from anchors[1]
		entity.AI.anchorDir = {};

		-- index for accessing movement data.
		entity.AI.movementIndex = 1;

		-- current position and direction.
		entity.AI.PathPosVector ={}
		entity.AI.PathDirVector ={}


		-- calcurate dir vector and wing vector
		-- entity.AI.anchors[2] comes from ScoutIdle behavior

		FastDifferenceVectors( entity.AI.anchorDir , entity.AI.anchors[2] , entity.AI.anchors[1] );
		entity.AI.anchorWng.x = entity.AI.anchorDir.y;
		entity.AI.anchorWng.y = entity.AI.anchorDir.x;
		entity.AI.anchorWng.z = 0;
		FastScaleVector( entity.AI.anchorWng , entity.AI.anchorWng , 0.25 );
		entity.AI.anchorWng.z = entity.AI.anchorDir.z

		local distanceToLine = 0.0; -- get a distance to the line.
		local anchorDirLen = 0.0;
		local tmpVector = {};
		FastDifferenceVectors( tmpVector , entity:GetPos() , entity.AI.anchors[1] );
		distanceToLine = vecLen( vecCross( tmpVector , entity.AI.anchorDir ) );
		anchorDirLen = vecLen( entity.AI.anchorDir );
		if	(anchorDirLen>0) then
			distanceToLine = distanceToLine / anchorDirLen;
		end
		AI.LogEvent(entity:GetName().." distance to the line of anchors "..distanceToLine);
	
		local entityUnitDir = {}; -- unit direction vector from anchor[1] to entity
		FastDifferenceVectors( entityUnitDir , entity:GetPos() , entity.AI.anchors[1] );
		NormalizeVector(entityUnitDir);

		local unitWingDir = {}; -- unit wing direction vector
		CopyVector(unitWingDir , entity.AI.anchorWng );
		NormalizeVector(unitWingDir);
		
		-- align the direction of the wing vector

		local dotEntityAndWing;
		dotEntityAndWing = dotproduct3d( entityUnitDir , unitWingDir);
		if(dotEntityAndWing<0.0) then
			FastScaleVector( entity.AI.anchorWng , entity.AI.anchorWng , -1.0 );
			CopyVector(unitWingDir , entity.AI.anchorWng );
			NormalizeVector(unitWingDir);
		end
		
		-- pararell movement depending on the distance to the line.
		
		FastScaleVector( tmpVector , unitWingDir , distanceToLine );
		FastSumVectors( entity.AI.anchors[1] , entity.AI.anchors[1] , tmpVector );
		FastSumVectors( entity.AI.anchors[2] , entity.AI.anchors[2] , tmpVector );
		
		-- make defaut points for rounding movement
		
		local index = i;
		for i= 1,8 do
			index = i ;
			CopyVector( tmpVector , entity.AI.anchorDir );
			FastScaleVector( tmpVector , tmpVector , i/9.0 );
			FastSumVectors( entity.AI.movevec[index] , tmpVector , entity.AI.anchors[1]);
		end
		
		for i= 1,4 do
			index = i + 8;
			CopyVector( tmpVector , entity.AI.anchorWng );
			FastScaleVector( tmpVector , tmpVector , i/5.0 );
			FastSumVectors( entity.AI.movevec[index] , tmpVector , entity.AI.anchors[2]);
		end

		for i= 1,8 do
			index = i + 8 + 4;
			CopyVector( tmpVector , entity.AI.anchorDir );
			FastScaleVector( tmpVector , tmpVector , i/-9.0 );
			FastSumVectors( entity.AI.movevec[index] , tmpVector , entity.AI.anchorWng );
			FastSumVectors( entity.AI.movevec[index] , entity.AI.movevec[index] , entity.AI.anchors[2]);
		end
	
		for i= 1,4 do
			index = i + 8 + 4 + 8;
			CopyVector( tmpVector , entity.AI.anchorWng );
			FastScaleVector( tmpVector , tmpVector , i/-5.0 );
			FastSumVectors( entity.AI.movevec[index] , tmpVector , entity.AI.anchorWng );
			FastSumVectors( entity.AI.movevec[index] , entity.AI.movevec[index] , entity.AI.anchors[1]);
		end
	
		-- calcurate 4 dimension spline curve

		local midVector1 = {};
		local midVector2 = {};
		local midVector3 = {};
	
		for j= 1,1 do
			for i= 1,24 do
			  local index1 = i+1;
			  local index2 = i+2;
			  if( index1 > 24 ) then
			  	index1 = index1 - 24;
			  end
			  if( index2 > 24 ) then
			  	index2 = index2 - 24;
			  end
				FastSumVectors(	midVector1 , entity.AI.movevec[i] , entity.AI.movevec[index1] );
				FastSumVectors(	midVector2 , entity.AI.movevec[index1] , entity.AI.movevec[index2] );
				FastScaleVector( midVector1 , midVector1 , 0.5 );
				FastScaleVector( midVector2 , midVector2 , 0.5 );
				FastSumVectors(	midVector3 , midVector1 , midVector2 );
				FastScaleVector( midVector3 , midVector3 , 0.5 );
				CopyVector( movevec[i] , midVector3 );
			end
			for i= 1,24 do
				CopyVector( entity.AI.movevec[i] , movevec[i] );
			end
		end
	 
		-- set initial movement

		CopyVector( tmpVector , entity.AI.movevec[1] );
		FastDifferenceVectors( tmpVector , tmpVector , entity:GetPos() );
		FastScaleVector( tmpVector , tmpVector , -1.0 );
			
		for i= 1,24 do
			FastSumVectors(	entity.AI.movevec[i] , entity.AI.movevec[i] , tmpVector );
		end	

		CopyVector( entity.AI.PathPosVector , entity.AI.movevec[entity.AI.movementIndex]);
		FastDifferenceVectors( entity.AI.PathDirVector , entity.AI.movevec[entity.AI.movementIndex+1] , entity.AI.movevec[entity.AI.movementIndex]);
		NormalizeVector(entity.AI.PathDirVector);

		entity.actor:SetMovementTarget( entity.AI.PathPosVector , entity.AI.PathDirVector , {x=0,y=0,z=1}, 0.0 );
		AI.SetRefPointPosition( entity.id , entity.PathPosVector  );

		AI.CreateGoalPipe("scoutMovementInit");
		AI.PushGoal("scoutMovementInit","continuous",0,1);
		AI.PushGoal("scoutMovementInit","locate",0,"refpoint");		
		AI.PushGoal("scoutMovementInit","run",0,1);		
		AI.PushGoal("scoutMovementInit","approach",1,2.0,AILASTOPRES_USE,-1);	
		AI.PushGoal("scoutMovementInit","signal",0,1,"SC_SCOUT_STRAFING_MOVE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutMovementInit");

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

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
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		AI.Signal(SIGNALFILTER_SPECIESONLY,1,"TO_SCOUT_ATTACK", entity.id);	

	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_STRAFING_MOVE = function( self, entity )

		-- Make a pattern movement of the circle and strafing.
		-- When we increase index one by one , we can get a circle movement.
		-- However, It is little slow to trace. So, I skipped some points currently
		-- 29/11/05 Tetsuji
		
		local index = 0;
		local bRun = false;
		
		index = entity.AI.movementIndex + 1;
		if (entity.AI.movementIndex == 2) then
			index =8;
			bRun = true;
		else
			if (entity.AI.movementIndex == 9) then
				index =22;
			end
		end

		if( index > 24 ) then
			index = index - 24;
		end

		if (bRun==false) then

			local pathLength;
			FastDifferenceVectors( entity.AI.PathDirVector , entity.AI.movevec[index] , entity.AI.movevec[entity.AI.movementIndex]);
			pathLength = vecLen( entity.AI.PathDirVector );
			NormalizeVector( entity.AI.PathDirVector);
			FastScaleVector( entity.AI.PathDirVector , entity.AI.PathDirVector , 100.0 );
			FastSumVectors( entity.AI.PathDirVector , entity.AI.PathDirVector , entity.AI.PathPosVector );
			--entity.actor:SetMovementTarget( entity.AI.PathPosVector , entity.AI.PathDirVector , {x=0,y=0,z=0}, 1.0 );
			CopyVector( entity.AI.PathPosVector , entity.AI.movevec[index]);
	
			AI.SetRefPointPosition( entity.id , entity.AI.PathPosVector  );

			AI.CreateGoalPipe("scoutMovement");
			AI.PushGoal("scoutMovement","continuous",0,1);
			AI.PushGoal("scoutMovement","locate",0,"refpoint");	
			AI.PushGoal("scoutMovement","approach",1,2.0,AILASTOPRES_USE,-1);	
			AI.PushGoal("scoutMovement","signal",0,1,"SC_SCOUT_STRAFING_MOVE",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutMovement");

			entity.AI.movementIndex = entity.AI.movementIndex + 1;
			if( entity.AI.movementIndex > 24 ) then
			 	entity.AI.movementIndex = entity.AI.movementIndex - 24;
			end

		else
		
			FastDifferenceVectors( entity.AI.PathDirVector , entity.AI.movevec[index] , entity.AI.movevec[entity.AI.movementIndex]);
			NormalizeVector( entity.AI.PathDirVector);
			FastScaleVector( entity.AI.PathDirVector , entity.AI.PathDirVector , 100.0 );
			FastSumVectors( entity.AI.PathDirVector , entity.AI.PathDirVector , entity.AI.PathPosVector );
			entity.actor:SetMovementTarget( entity.AI.PathPosVector , entity.AI.PathDirVector , {x=0,y=0,z=0}, 1.0 );
			CopyVector( entity.AI.PathPosVector , entity.AI.movevec[index]);
		
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 17.0 );
			AI.CreateGoalPipe("scoutMovementStandBy");
			AI.PushGoal("scoutMovementStandBy","timeout",1,0.5);	
			AI.PushGoal("scoutMovementStandBy","firecmd",0,FIREMODE_FORCED);		
			AI.PushGoal("scoutMovementStandBy","timeout",1,0.5);	
			AI.PushGoal("scoutMovementStandBy","signal",0,1,"SC_SCOUT_STRAFING_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutMovementStandBy");

		end

		entity.AI.movementIndex = index;

	end,

	---------------------------------------------
	SC_SCOUT_STRAFING_ATTACK = function( self, entity )

		-- During a pattern movement of the circle, If the scout shoot at the player.
		-- 29/11/05 Tetsuji

		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 17.0 );
		AI.SetRefPointPosition( entity.id , entity.AI.PathPosVector  );
		AI.CreateGoalPipe("scoutMovementRun");
		AI.PushGoal("scoutMovementRun","continuous",0,1);
		AI.PushGoal("scoutMovementRun","firecmd",0,FIREMODE_FORCED);		
		AI.PushGoal("scoutMovementRun","run",0,1);		
		AI.PushGoal("scoutMovementRun","locate",0,"refpoint");		
		AI.PushGoal("scoutMovementRun","approach",1,3.0,AILASTOPRES_USE,-1);	
		AI.PushGoal("scoutMovementRun","firecmd",0,0);		
		AI.PushGoal("scoutMovementRun","signal",0,1,"SC_SCOUT_STRAFING_MOVE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutMovementRun");

	end,

}

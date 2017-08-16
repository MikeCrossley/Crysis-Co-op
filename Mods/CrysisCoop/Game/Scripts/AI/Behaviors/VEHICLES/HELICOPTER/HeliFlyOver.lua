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
--  - 15/03/2006   : Created by Tetsuji
--------------------------------------------------------------------------

local Xaxis = 0;
local Yaxis = 1;
local Zaxis = 2;

--------------------------------------------------------------------------
AIBehaviour.HeliFlyOver = {
	Name = "HeliFlyOver",
 	Base = "HeliBase",
	alertness = 2,
	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "TO_HELI_ATTACK";
		entity.AI.heliMemorySignal = "TO_HELI_PICKATTACK";

		-- for flyover
		entity.AI.vFlyOver ={};
		entity.AI.vFlyOverPlayer ={};

		if ( entity.AI.isHeliAggressive ~= nil ) then

			AI.CreateGoalPipe("heliFlyOverDefault");
			AI.PushGoal("heliFlyOverDefault","timeout",1,0.1);
			AI.PushGoal("heliFlyOverDefault","signal",0,1,"HELI_FLYOVER_START_AGGRASSIVE",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliFlyOverDefault");

		else

			AI.CreateGoalPipe("heliFlyOverDefault");
			AI.PushGoal("heliFlyOverDefault","timeout",1,0.1);
			AI.PushGoal("heliFlyOverDefault","signal",0,1,"HELI_FLYOVER_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliFlyOverDefault");

		end

		AI.CreateGoalPipe("heliJustWait");
		AI.PushGoal("heliJustWait","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("heliJustWait","timeout",1,1.0);	
		AI.PushGoal("heliJustWait","signal",0,1,"TO_HELI_ATTACK",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("AheliJustWait");
		AI.PushGoal("AheliJustWait","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliJustWait","signal",0,1,"TO_HELI_ATTACK",SIGNALFILTER_SENDER);
	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
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
	OnBulletRain = function ( self, entity, sender, data )	
		self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
		if ( AIBehaviour.HELIDEFAULT:heliCheckDamageRatio( entity ) == true ) then
			return;
		end
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,

	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	--------------------------------------------------------------------------
	-- local signal handers
	--------------------------------------------------------------------------

	--------------------------------------------------------------------------
	HELI_REFLESH_FORMATION_SCALE = function( self, entity, sender, data )

		--CopyVector( entity.AI.vFormationScale, data.point );

	end,
	--------------------------------------------------------------------------
	HELI_REFLESH_POSITION = function( self, entity, sender, data )

		--AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity , entity.AI.vFormationScale );

	end,

	--------------------------------------------------------------------------
	HELI_FLYOVER_START = function( self, entity )

		local enemySpeed = entity:GetSpeed();
		if ( enemySpeed > 20.0 ) then
			AI.CreateGoalPipe("heliWaitSpeedZero");
			AI.PushGoal("heliWaitSpeedZero","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliWaitSpeedZero","locate",0,"atttarget");
			AI.PushGoal("heliWaitSpeedZero","lookat",0,0,0,true,1);
			AI.PushGoal("heliWaitSpeedZero","timeout",1,0.2);	
			AI.PushGoal("heliWaitSpeedZero","signal",0,1,"HELI_FLYOVER_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliWaitSpeedZero");
			return;
		end

		AIBehaviour.HELIDEFAULT:heliGetID( entity );
		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity );

		local heliAttackCenterPos = {};
		AIBehaviour.HELIDEFAULT:heliGetStayAttackPosition( entity, heliAttackCenterPos, 0 );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"heliJustWait");
			return;
		end

		local vDir = {};
		SubVectors( vDir, entity:GetPos(), target:GetPos()  );
		local distance = LengthVector( vDir );

		if ( distance > 70.0 or distance < 1.0 ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"HELI_FLYOVER", entity.id);
			return;
		end
		
		vDir.z = 0;
		NormalizeVector( vDir );
		local scale;	


		if ( entity.AI.stayPosition == 1 ) then

			scale = 100.0;
			FastScaleVector( vDir, vDir, scale );
			vDir.z = 20.0;
			FastSumVectors( vDir, vDir, target:GetPos() );

		elseif ( entity.AI.stayPosition == 2 ) then

			scale = 200.0;
			FastScaleVector( vDir, vDir, scale );
			vDir.z = 30.0;
			FastSumVectors( vDir, vDir, target:GetPos() );

		else

			entity:SelectPipe(0,"heliJustWait");
			return;

		end

		local vMid ={};
		FastSumVectors( vMid, entity:GetPos(), vDir );
		FastScaleVector( vMid, vMid, 0.5 );

		index = 1;
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
		index = index + 1;
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDir, index );
		if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity,  index, false ) == false ) then
			entity:SelectPipe(0,"heliJustWait");
			return;
		end

		local bRun = 1;
		if ( entity.AI.isVtol == true ) then
			bRun = 0;
		end

		local vTmp = {};
		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );
		SubVectors( vTmp, vDir, entity:GetPos() );
		vTmp.z = vMyPos.z;
		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, 30.0 );
		FastSumVectors( vTmp, vTmp, vDir );			
		AI.SetRefPointPosition( entity.id , vTmp ); -- look target

		AI.CreateGoalPipe("heliFlyOver");
		AI.PushGoal("heliFlyOver","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("heliFlyOver","continuous",0,1);
		AI.PushGoal("heliFlyOver","locate",0,"refpoint");
		AI.PushGoal("heliFlyOver","lookat",0,0,0,true,1);


		AI.CreateGoalPipe("heliFlyOverStart");
		AI.PushGoal("heliFlyOverStart","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("heliFlyOverStart","continuous",0,1);
			AI.PushGoal("heliFlyOverStart","locate",0,"atttarget");
			AI.PushGoal("heliFlyOverStart","lookat",0,0,0,true,1);

--		if ( DistanceVectors( entity:GetPos(), vDir ) < 30.0 ) then
--		else
--			AI.PushGoal("heliFlyOverStart","locate",0,"refpoint");
--			AI.PushGoal("heliFlyOverStart","lookat",0,0,0,true,1);
--		end
		AI.PushGoal("heliFlyOverStart","firecmd",0,0);
		AI.PushGoal("heliFlyOverStart","timeout",1,0.5);
		AI.PushGoal("heliFlyOverStart","run",0,bRun);	
		AI.PushGoal("heliFlyOverStart","followpath", 0, false, false, false, 0, 10, true );
		AI.PushGoal("heliFlyOverStart","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliFlyOverStart","timeout",1,0.2);
		AI.PushGoal("heliFlyOverStart","branch",1,-2);
		AI.PushGoal("heliFlyOverStart","signal",0,1,"HELI_FLYOVER",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliFlyOverStart");

	end,

	--------------------------------------------------------------------------
	HELI_FLYOVER = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"heliJustWait");
			return;
		end

		local vDir = {};
		SubVectors( vDir, entity:GetPos(), target:GetPos()  );
		local distance = LengthVector( vDir );
		if ( distance <60.0 ) then
			entity:SelectPipe(0,"heliJustWait");
			return;
		end


		local targetPos = {};
		local targetPos2 = {};
		local myPos = {};
		local enemyPos = {};

		local vDir = {};
		local vUp = { x=0.0, y=0.0, z= 1.0 };
		local vWng = {};
		local vUpVec ={};
		local vProjectedDir = {};

		CopyVector( myPos, entity:GetPos() );
		AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, enemyPos );

		if ( AIBehaviour.HELIDEFAULT:heliIsTargetVehicle( entity ) ~= true ) then

			SubVectors( vDir, enemyPos, entity:GetPos() );
			NormalizeVector( vDir );
			crossproduct3d( vWng, vDir, vUp );
			NormalizeVector( vWng );
			FastScaleVector( vWng, vWng, random( -2,2 ) * 15.0 );
			FastSumVectors( enemyPos, enemyPos, vWng );

		end

		if ( entity.AI.stayPosition == 1 ) then

			SubVectors( vDir, entity:GetPos(), enemyPos );
			FastScaleVector( vProjectedDir, vDir, 0.3 );
			FastSumVectors( targetPos, vProjectedDir, enemyPos );
			FastScaleVector( vUpVec, vUp, 12.0 );
			FastSumVectors( targetPos, targetPos, vUpVec );
		
			FastScaleVector( vProjectedDir, vDir, -0.6 );
			FastSumVectors( targetPos2, vProjectedDir, enemyPos );
			FastScaleVector( vUpVec, vUp, 20.0 );
			FastSumVectors( targetPos2, targetPos2, vUpVec );

		else
		
			SubVectors( vDir, entity:GetPos(), enemyPos );
			FastScaleVector( vProjectedDir, vDir, 0.3 );
			FastSumVectors( targetPos, vProjectedDir, enemyPos );
			FastScaleVector( vUpVec, vUp, 30.0 );
			FastSumVectors( targetPos, targetPos, vUpVec );
		
			FastScaleVector( vProjectedDir, vDir, -0.6 );
			FastSumVectors( targetPos2, vProjectedDir, enemyPos );
			FastScaleVector( vUpVec, vUp, 40.0 );
			FastSumVectors( targetPos2, targetPos2, vUpVec );
		
		end

		local vMid ={};
		SubVectors( vMid, targetPos, entity:GetPos() );
		NormalizeVector( vMid );
		FastScaleVector( vMid, vMid, 10.0 );
		FastSumVectors( vMid, vMid,  entity:GetPos() );

		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, 1 );
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos, 2 );
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos2, 3 );
		if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity,  3, false ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end



		local standByTime;
		standByTime = (entity.AI.stayPosition-1.0) * 1.0;

		local bRun = 2;
		if ( entity.AI.isVtol == true ) then
			bRun = 0;
		end

		entity.AI.autoFire = 0;

		SubVectors( vDir, targetPos2, entity:GetPos() );
		vDir.z = myPos.z;
		NormalizeVector( vDir );
		FastScaleVector( vDir, vDir, 30.0 );
		FastSumVectors( vDir, vDir, targetPos2 );			
		AI.SetRefPointPosition( entity.id , vDir ); -- look target

		AI.CreateGoalPipe("heliFlyOver");
		AI.PushGoal("heliFlyOver","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("heliFlyOver","continuous",0,1);
		AI.PushGoal("heliFlyOver","locate",0,"refpoint");
		AI.PushGoal("heliFlyOver","lookat",0,0,0,true,1);
		AI.PushGoal("heliFlyOver","firecmd",0,0);
		AI.PushGoal("heliFlyOver","timeout",1,1,0);
		AI.PushGoal("heliFlyOver","run",0,bRun);	
		AI.PushGoal("heliFlyOver","followpath", 0, false, false, false, 0, 40, true );
		AI.PushGoal("heliFlyOver","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliFlyOver","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliFlyOver","timeout",1,0.2);
		AI.PushGoal("heliFlyOver","branch",1,-3);
		AI.PushGoal("heliFlyOver","signal",0,1,"TO_HELI_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliFlyOver");
		return;


	end,

	--------------------------------------------------------------------------
	-- for the aggrassive helicopter
	HELI_FLYOVER_START_AGGRASSIVE = function( self, entity )

		AIBehaviour.HELIDEFAULT:heliGetID( entity );
		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity );

		local heliAttackCenterPos = {};
		AIBehaviour.HELIDEFAULT:heliGetStayAttackPosition( entity, heliAttackCenterPos, 0 );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"AheliJustWait");
			return;
		end

		local vDir = {};
		SubVectors( vDir, entity:GetPos(), target:GetPos()  );
		local distance = LengthVector( vDir );

		vDir.z = 0;
		NormalizeVector( vDir );
		local scale;	

		scale = 100.0;
		FastScaleVector( vDir, vDir, scale );
		vDir.z = 35.0;
		FastSumVectors( vDir, vDir, target:GetPos() );

		local vMid ={};
		FastSumVectors( vMid, entity:GetPos(), vDir );
		FastScaleVector( vMid, vMid, 0.5 );

		index = 1;
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
		index = index + 1;
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDir, index );
		if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 15.0 ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end

		AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  2, false );

		AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target

		AI.CreateGoalPipe("AheliFlyOverStart");
		AI.PushGoal("AheliFlyOverStart","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOverStart","continuous",0,1);
		AI.PushGoal("AheliFlyOverStart","locate",0,"refpoint");
		AI.PushGoal("AheliFlyOverStart","lookat",0,0,0,true,1);
		AI.PushGoal("AheliFlyOverStart","firecmd",0,0);
		AI.PushGoal("AheliFlyOverStart","run",0,2);	
		AI.PushGoal("AheliFlyOverStart","followpath", 0, false, false, false, 0, 80, true );
		AI.PushGoal("AheliFlyOverStart","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOverStart","timeout",1,0.2);
		AI.PushGoal("AheliFlyOverStart","branch",1,-2);
		AI.PushGoal("AheliFlyOverStart","signal",0,1,"HELI_FLYOVER_AGGRASSIVE_ADJUSTHEIGHT",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"AheliFlyOverStart");

	end,

	--------------------------------------------------------------------------
	HELI_FLYOVER_AGGRASSIVE_ADJUSTHEIGHT = function( self, entity )

		local enemySpeed = entity:GetSpeed();
		if ( enemySpeed > 10.0 ) then
			AI.CreateGoalPipe("AheliWaitSpeedZero2");
			AI.PushGoal("AheliWaitSpeedZero2","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("AheliWaitSpeedZero2","locate",0,"refpoint");
			AI.PushGoal("AheliWaitSpeedZero2","lookat",0,0,0,true,1);
			AI.PushGoal("AheliWaitSpeedZero2","timeout",1,0.2);	
			AI.PushGoal("AheliWaitSpeedZero2","signal",0,1,"HELI_FLYOVER_AGGRASSIVE_ADJUSTHEIGHT",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"AheliWaitSpeedZero2");
			return;
		end


		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"heliJustWait");
			return;
		end

		local vDir = {};
		local vSrc = {};
		SubVectors( vDir, target:GetPos(), entity:GetPos() );
		local length = LengthVector( vDir );

		length = length /2.0;

		CopyVector( vSrc, entity:GetPos() );
		vSrc.z =vSrc.z -5.0;
		NormalizeVector( vDir );
		FastScaleVector( vDir, vDir, length );

		local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain,target.id,entity.id,g_HitTable);
		if ( hits >0 ) then
			CopyVector( vDir, entity:GetPos() );
			vDir.z = vDir.z + 5.0;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDir, 1 );
			vDir.z = vDir.z + 7.0;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDir, 2 );
			if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 3.0 ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			end

			AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  2, false );

			AI.CreateGoalPipe("AheliFlyOverUp");
			AI.PushGoal("AheliFlyOverUp","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("AheliFlyOverUp","continuous",0,0);
			AI.PushGoal("AheliFlyOverUp","locate",0,"refpoint");
			AI.PushGoal("AheliFlyOverUp","lookat",0,0,0,true,1);
			AI.PushGoal("AheliFlyOverUp","firecmd",0,0);
			AI.PushGoal("AheliFlyOverUp","timeout",1,1,0);
			AI.PushGoal("AheliFlyOverUp","run",0,0);	
			AI.PushGoal("AheliFlyOverUp","followpath", 0, false, false, false, 0, -1, true );
			AI.PushGoal("AheliFlyOverUp","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("AheliFlyOverUp","timeout",1,0.2);
			AI.PushGoal("AheliFlyOverUp","branch",1,-2);
			AI.PushGoal("AheliFlyOverUp","signal",0,1,"HELI_FLYOVER_AGGRASSIVE",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"AheliFlyOverUp");
		
		else
			self:HELI_FLYOVER_AGGRASSIVE( entity );
		end


	end,

	--------------------------------------------------------------------------
	HELI_FLYOVER_AGGRASSIVE = function( self, entity )


		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"AheliJustWait");
			return;
		end

		local vDir = {};
		SubVectors( vDir, entity:GetPos(), target:GetPos()  );
		local distance = LengthVector( vDir );
		if ( distance <60.0 ) then
			entity:SelectPipe(0,"AheliJustWait");
			return;
		end


		local targetPos3 = {};
		local targetPos4 = {};
		local myPos = {};
		local enemyPos = {};

		local vDir = {};
		local vUp = { x=0.0, y=0.0, z= 1.0 };
		local vWng = {};
		local vUpVec ={};
		local vProjectedDir = {};

		CopyVector( myPos, entity:GetPos() );
		AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, enemyPos );

		SubVectors( vDir,  enemyPos, entity:GetPos() );
		vDir.z = 0;
		NormalizeVector( vDir );
		FastScaleVector( vProjectedDir, vDir, 10 );
		FastSumVectors( targetPos4, vProjectedDir, entity:GetPos() );
		targetPos4.z = myPos.z -5.0;

		SubVectors( vDir, entity:GetPos(), enemyPos );
		vDir.z = 0;
		NormalizeVector( vDir );
		FastScaleVector( vProjectedDir, vDir, 50 );
		FastSumVectors( targetPos3, vProjectedDir, enemyPos );
		targetPos3.z = myPos.z -5.0;

		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos4, 1 );
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos3, 2 );
		if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 3.0 ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end

		AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  2, false );

		local standByTime;
		standByTime = (entity.AI.stayPosition-1.0) * 1.0;
		entity.AI.autoFire = 0;

		SubVectors( vDir, targetPos3, entity:GetPos() );
		vDir.z = myPos.z;
		NormalizeVector( vDir );
		FastScaleVector( vDir, vDir, 30.0 );
		FastSumVectors( vDir, vDir, targetPos3 );			
		AI.SetRefPointPosition( entity.id , vDir ); -- look target

		AI.CreateGoalPipe("AheliFlyOver");
		AI.PushGoal("AheliFlyOver","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOver","continuous",0,1);
		AI.PushGoal("AheliFlyOver","locate",0,"refpoint");
		AI.PushGoal("AheliFlyOver","lookat",0,0,0,true,1);
		AI.PushGoal("AheliFlyOver","firecmd",0,0);
		AI.PushGoal("AheliFlyOver","timeout",1,1,0);
		AI.PushGoal("AheliFlyOver","run",0,1);	
		AI.PushGoal("AheliFlyOver","followpath", 0, false, false, false, 0, 40, true );
		AI.PushGoal("AheliFlyOver","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOver","signal",1,1,"HELI_AUTOFIRE_CHECK_AGGRASSIVE",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOver","timeout",1,0.2);
		AI.PushGoal("AheliFlyOver","branch",1,-3);
		AI.PushGoal("AheliFlyOver","signal",0,1,"HELI_FLYOVER_END",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"AheliFlyOver");
		return;


	end,

	--------------------------------------------------------------------------
	HELI_FLYOVER_END = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"AheliJustWait");
			return;
		end

		local vDir = {};
		SubVectors( vDir, entity:GetPos(), target:GetPos()  );
		if ( vDir.z > 50.0 or vDir.z < 10.0 ) then

			local vWng = {};
			local vCheckPos = {};
			local vCheckPos2 = {};
			AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 30.0 );

			FastSumVectors( vCheckPos, vWng, entity:GetPos() );

			local vMid = {};
			FastSumVectors( vMid, entity:GetPos(), vCheckPos );
			FastScaleVector( vMid, vMid, 0.5 );

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos, index );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target

			AI.CreateGoalPipe("AheliLineShoot");
			AI.PushGoal("AheliLineShoot","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("AheliLineShoot","firecmd",0,0);
			AI.PushGoal("AheliLineShoot","locate",0,"refpoint");
			AI.PushGoal("AheliLineShoot","lookat",0,0,0,true,1);
			AI.PushGoal("AheliLineShoot","run",0,1);
			AI.PushGoal("AheliLineShoot","continuous",0,0);
			AI.PushGoal("AheliLineShoot","followpath", 0, false, false, false, 0, -1, true );
			AI.PushGoal("AheliLineShoot","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("AheliLineShoot","timeout",1,0.2);
			AI.PushGoal("AheliLineShoot","branch",1,-2);
			AI.PushGoal("AheliLineShoot","firecmd",0,0);
			AI.PushGoal("AheliLineShoot","signal",0,1,"TO_HELI_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"AheliLineShoot");
			return;

		end


		local targetPos = {};
		local targetPos2 = {};
		local myPos = {};
		local enemyPos = {};

		local vUp = { x=0.0, y=0.0, z= 1.0 };
		local vWng = {};
		local vUpVec ={};
		local vProjectedDir = {};

		CopyVector( myPos, entity:GetPos() );
		AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, enemyPos );

		SubVectors( vDir, entity:GetPos(), enemyPos );
		vDir.z = 0;
		NormalizeVector( vDir );
		FastScaleVector( vProjectedDir, vDir, 30 );
		FastSumVectors( targetPos, vProjectedDir, enemyPos );
		FastScaleVector( vUpVec, vUp, 8.0 );
		FastSumVectors( targetPos, targetPos, vUpVec );
		
		SubVectors( vDir, entity:GetPos(), enemyPos );
		vDir.z = 0;
		NormalizeVector( vDir );
		FastScaleVector( vProjectedDir, vDir, 0 );
		FastSumVectors( targetPos2, vProjectedDir, enemyPos );
		FastScaleVector( vUpVec, vUp, 10.0 );
		FastSumVectors( targetPos2, targetPos2, vUpVec );

		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos, 1 );
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos2, 2 );
		if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 1.0 ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end

		AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  2, false );


		local standByTime;
		standByTime = (entity.AI.stayPosition-1.0) * 1.0;

		local bRun = 2;
		entity.AI.autoFire = 0;

		SubVectors( vDir, targetPos2, entity:GetPos() );
		vDir.z = myPos.z;
		NormalizeVector( vDir );
		FastScaleVector( vDir, vDir, 20.0 );
		FastSumVectors( vDir, vDir, targetPos2 );			
		AI.SetRefPointPosition( entity.id , vDir ); -- look target

		AI.CreateGoalPipe("AheliFlyOverEnd");
		AI.PushGoal("AheliFlyOverEnd","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOverEnd","continuous",0,1);
		AI.PushGoal("AheliFlyOverEnd","locate",0,"refpoint");
		AI.PushGoal("AheliFlyOverEnd","lookat",0,0,0,true,1);
		AI.PushGoal("AheliFlyOverEnd","firecmd",0,0);
		AI.PushGoal("AheliFlyOverEnd","timeout",1,1,0);
		AI.PushGoal("AheliFlyOverEnd","run",0,bRun);	
		AI.PushGoal("AheliFlyOverEnd","followpath", 0, false, false, false, 0, 80, true );
		AI.PushGoal("AheliFlyOverEnd","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
--		AI.PushGoal("AheliFlyOverEnd","signal",1,1,"HELI_AUTOFIRE_CHECK_AGGRASSIVE",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOverEnd","timeout",1,0.2);
		AI.PushGoal("AheliFlyOverEnd","branch",1,-2);
		AI.PushGoal("AheliFlyOverEnd","signal",0,1,"HELI_FLYOVER_END2",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"AheliFlyOverEnd");
		return;

	end,


	--------------------------------------------------------------------------
	HELI_FLYOVER_END2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			entity:SelectPipe(0,"AheliJustWait");
			return;
		end

		local vPos = {};
		CopyVector( vPos, entity:GetPos() );
		vPos.z = vPos.z + 3;

		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, 1 );

		vPos.z = vPos.z + 12;

		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, 2 );
		if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 1.0 ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end

		AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  2, false );

		AI.CreateGoalPipe("AheliFlyOverEnd2");
		AI.PushGoal("AheliFlyOverEnd2","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOverEnd2","continuous",0,0);
		AI.PushGoal("AheliFlyOverEnd2","locate",0,"refpoint");
		AI.PushGoal("AheliFlyOverEnd2","lookat",0,0,0,true,1);
		AI.PushGoal("AheliFlyOverEnd2","firecmd",0,0);
		AI.PushGoal("AheliFlyOverEnd2","run",0,1);	
		AI.PushGoal("AheliFlyOverEnd2","followpath", 0, false, false, false, 0, 80, true );
		AI.PushGoal("AheliFlyOverEnd2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("AheliFlyOverEnd2","timeout",1,0.2);
		AI.PushGoal("AheliFlyOverEnd2","branch",1,-2);
		AI.PushGoal("AheliFlyOverEnd2","timeout",1,0.5);
		AI.PushGoal("AheliFlyOverEnd2","signal",0,1,"TO_HELI_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"AheliFlyOverEnd2");
		return;

	end,


}


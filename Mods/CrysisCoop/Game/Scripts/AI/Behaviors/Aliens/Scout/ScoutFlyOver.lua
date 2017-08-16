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
AIBehaviour.ScoutFlyOver = {
	Name = "ScoutFlyOver",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected

		-- for flyover
		entity.AI.flyoverCounter = 0;
		entity.AI.vFlyOver ={};
		entity.AI.vFlyOverPlayer ={};

		AI.CreateGoalPipe("scoutFlyOverDefault");
		AI.PushGoal("scoutFlyOverDefault","timeout",1,0.1);
		AI.PushGoal("scoutFlyOverDefault","signal",0,1,"SC_SCOUT_FLYOVER_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutFlyOverDefault");

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
	SC_SCOUT_REFLESH_POSITION = function( self, entity, sender, data )
		-- don't reflesh during flyover
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_FLYOVER_START = function( self, entity )

		AIBehaviour.SCOUTDEFAULT:scoutGetID( entity );
		AIBehaviour.SCOUTDEFAULT:scoutRefreshStayAttackPosition( entity );

		local scoutAttackCenterPos = {};
		AIBehaviour.SCOUTDEFAULT:scoutGetStayAttackPosition( entity, scoutAttackCenterPos, 0 );

		local distance = AIBehaviour.SCOUTDEFAULT:scoutGetDistanceOfPoints( scoutAttackCenterPos, entity:GetPos() );
		if ( distance < 200.0 ) then

			AI.SetRefPointPosition( entity.id , scoutAttackCenterPos );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 0.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

			AI.CreateGoalPipe("scoutFlyOverStart");
			AI.PushGoal("scoutFlyOverStart","run",0,0);	
			AI.PushGoal("scoutFlyOverStart","continuous",0,1);
			AI.PushGoal("scoutFlyOverStart","locate",0,"refpoint");		
			AI.PushGoal("scoutFlyOverStart","approach",0,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutFlyOverStart","timeout",1,1.0);	
			AI.PushGoal("scoutFlyOverStart","signal",0,1,"SC_SCOUT_FLYOVER_START_B",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutFlyOverStart");

		else
		
			-- just wait
			AI.CreateGoalPipe("scoutJustWait");
			AI.PushGoal("scoutJustWait","timeout",1,1.0);	
			AI.PushGoal("scoutJustWait","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutJustWait");
		
		end

	end,

	SC_SCOUT_FLYOVER_START_B = function( self, entity )

			AI.CreateGoalPipe("scoutFlyOverStart_b");
			AI.PushGoal("scoutFlyOverStart_b","continuous",0,1);
			AI.PushGoal("scoutFlyOverStart_b","run",0,1);	
			AI.PushGoal("scoutFlyOverStart_b","locate",0,"refpoint");		
			AI.PushGoal("scoutFlyOverStart_b","approach",1,17.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutFlyOverStart_b","run",0,0);	
			AI.PushGoal("scoutFlyOverStart_b","locate",0,"refpoint");		
			AI.PushGoal("scoutFlyOverStart_b","approach",1,8.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutFlyOverStart_b","signal",0,1,"SC_SCOUT_FLYOVER",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutFlyOverStart_b");

	end,
	--------------------------------------------------------------------------
	SC_SCOUT_FLYOVER = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};
			local targetPos2 = {};
			local myPos = {};

			local vDir = {};
			local vUpVec ={};
			local vProjectedDir = {};

			CopyVector( vUpVec, target:GetDirectionVector(2));
			FastScaleVector( vUpVec, vUpVec, 8.0 );

			SubVectors( vDir, entity:GetPos(), target:GetPos() );
			ProjectVector( vProjectedDir, vDir, target:GetDirectionVector(2))
			FastScaleVector( vProjectedDir, vProjectedDir, 0.3 );
			FastSumVectors( targetPos, vProjectedDir, target:GetPos() );
			FastSumVectors( targetPos, targetPos, vUpVec );
			
			FastScaleVector( vProjectedDir, vProjectedDir, -1.0 );
			FastSumVectors( targetPos2, vProjectedDir, target:GetPos() );
			FastSumVectors( targetPos2, targetPos2, vUpVec );
			FastSumVectors( targetPos2, targetPos2, vUpVec );
			
			entity.AI.vFlyOver = {};
			CopyVector( entity.AI.vFlyOver, targetPos2 );

			entity.AI.vFlyOverPlayer = {};
			CopyVector( entity.AI.vFlyOverPlayer, target:GetPos() );

			AI.SetRefPointPosition( entity.id , targetPos  );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 12.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 23.0 );

			entity.AI.flyoverCounter = 0;
			if ( entity.AI.stayPosition >0 and entity.AI.stayPosition <4 ) then
				local standByTime;
				standByTime = (entity.AI.stayPosition-1.0) * 1.0;
				AI.CreateGoalPipe("scoutFlyOver");
				AI.PushGoal("scoutFlyOver","continuous",0,1);
				AI.PushGoal("scoutFlyOver","firecmd",0,0);
				AI.PushGoal("scoutFlyOver","timeout",1,standByTime);
				AI.PushGoal("scoutFlyOver","run",0,0);	
				AI.PushGoal("scoutFlyOver","locate",0,"refpoint");		
				AI.PushGoal("scoutFlyOver","approach",0,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutFlyOver","timeout",1,1);
				AI.PushGoal("scoutFlyOver","signal",0,1,"SC_SCOUT_FLYOVER_B",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutFlyOver");
				return;
			end

		end

		-- just wait
		AI.CreateGoalPipe("scoutJustWait");
		AI.PushGoal("scoutJustWait","timeout",1,1.0);	
		AI.PushGoal("scoutJustWait","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutJustWait");

	end,

	SC_SCOUT_FLYOVER_B = function( self, entity )

		AI.CreateGoalPipe("scoutFlyOver_b");
		AI.PushGoal("scoutFlyOver_b","continuous",0,1);
		AI.PushGoal("scoutFlyOver_b","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("scoutFlyOver_b","run",0,1);	
		AI.PushGoal("scoutFlyOver_b","locate",0,"refpoint");		
		AI.PushGoal("scoutFlyOver_b","approach",1,15.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutFlyOver_b","locate",0,"refpoint");		
		AI.PushGoal("scoutFlyOver_b","approach",1,7.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutFlyOver_b","firecmd",0,0);
		AI.PushGoal("scoutFlyOver_b","run",0,0);	
		AI.PushGoal("scoutFlyOver_b","signal",0,1,"SC_SCOUT_FLYOVER2",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutFlyOver_b");

	end,

	SC_SCOUT_FLYOVER_CHECK = function( self, entity )

		if ( entity.AI.flyoverCounter == 0 ) then
			local height = AIBehaviour.SCOUTDEFAULT:scoutGetDistanceFromTheGround( entity );
			if ( height < 0.5 ) then
				entity:InsertSubpipe(0,"stop_fire");
			end
		end

		entity.AI.flyoverCounter = entity.AI.flyoverCounter + 1;

		if ( entity.AI.flyoverCounter == 5 ) then
			entity.AI.flyoverCounter = 0;
		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_FLYOVER2 = function( self, entity )

			local height = AIBehaviour.SCOUTDEFAULT:scoutGetDistanceFromTheGround( entity );

			self:SC_SCOUT_FLYOVER3( entity );
--[[
			if (height>0.5) then

				local target = AI.GetAttentionTargetEntity( entity.id );
				if ( target and AI.Hostile( entity.id, target.id ) ) then

					AI.SetRefPointPosition( entity.id , entity.AI.vFlyOverPlayer  );
					AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 12.0 );
					if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
						return;
					end

					AI.CreateGoalPipe("scoutKamikazeAttack");
					AI.PushGoal("scoutKamikazeAttack","continuous",0,1);	
					AI.PushGoal("scoutKamikazeAttack","run",0,1);	
					AI.PushGoal("scoutKamikazeAttack","locate",0,"refpoint");		
					AI.PushGoal("scoutKamikazeAttack","approach",1,18.0,AILASTOPRES_USE,-1);
					AI.PushGoal("scoutKamikazeAttack","run",0,0);	
					AI.PushGoal("scoutKamikazeAttack","locate",0,"refpoint");		
					AI.PushGoal("scoutKamikazeAttack","approach",1,7.0,AILASTOPRES_USE,-1);
					AI.PushGoal("scoutKamikazeAttack","signal",0,1,"SC_SCOUT_FLYOVER3",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"scoutKamikazeAttack");

				else
					self:SC_SCOUT_FLYOVER3( entity );
				end

			else
				self:SC_SCOUT_FLYOVER3( entity );
			end
--]]
	end,
	--------------------------------------------------------------------------
	SC_SCOUT_FLYOVER3 = function( self, entity )

		AI.SetRefPointPosition( entity.id , entity.AI.vFlyOver  );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 12.0 );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end

		AI.CreateGoalPipe("scoutFlyOver3");
		AI.PushGoal("scoutFlyOver3","continuous",0,1);	
		AI.PushGoal("scoutFlyOver3","run",0,1);	
		AI.PushGoal("scoutFlyOver3","locate",0,"refpoint");		
		AI.PushGoal("scoutFlyOver3","approach",1,4.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutFlyOver3","signal",0,1,"SC_SCOUT_FLYOVER4",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutFlyOver3");

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_FLYOVER4 = function( self, entity )


		local newRefPoint = {};

		AIBehaviour.SCOUTDEFAULT:scoutRefreshStayAttackPosition( entity );
		AIBehaviour.SCOUTDEFAULT:scoutGetStayAttackPosition( entity, newRefPoint, 3 );
		AI.SetRefPointPosition( entity.id , newRefPoint  );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 12.0 );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end

		AI.CreateGoalPipe("scoutFlyOver4");
		AI.PushGoal("scoutFlyOver4","continuous",0,1);	
		AI.PushGoal("scoutFlyOver4","run",0,0);	
		AI.PushGoal("scoutFlyOver4","locate",0,"refpoint");		
		AI.PushGoal("scoutFlyOver4","approach",0,3.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutFlyOver4","timeout",1,1.0);
		AI.PushGoal("scoutFlyOver4","signal",0,1,"SC_SCOUT_FLYOVER4_B",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutFlyOver4");

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_FLYOVER4_B = function( self, entity )

		AI.CreateGoalPipe("scoutFlyOver4_b");
		AI.PushGoal("scoutFlyOver4_b","continuous",0,1);	
		AI.PushGoal("scoutFlyOver4_b","run",0,1);	
		AI.PushGoal("scoutFlyOver4_b","locate",0,"refpoint");		
		AI.PushGoal("scoutFlyOver4_b","approach",1,18.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutFlyOver4_b","run",0,0);	
		AI.PushGoal("scoutFlyOver4_b","locate",0,"refpoint");		
		AI.PushGoal("scoutFlyOver4_b","approach",1,7.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutFlyOver4_b","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutFlyOver4_b");

	end,


}


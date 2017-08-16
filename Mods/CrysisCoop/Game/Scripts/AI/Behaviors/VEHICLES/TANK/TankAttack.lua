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
--  - 06/02/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------


AIBehaviour.TankAttack = {
	Name = "TankAttack",
	alertness = 2,


	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )

		AI.LogComment(entity:GetName().." TankAttack:Constructor() selected the action for the frist encount ");

		-- currently never come back to tankAttak

		AI.CreateGoalPipe("tank_attack_start");
		AI.PushGoal("tank_attack_start","signal",0,1,"TO_TANK_ALERT",SIGNALFILTER_ANYONEINCOMM);
		AI.PushGoal("tank_attack_start","timeout",1,0.5);
		AI.PushGoal("tank_attack_start","signal",0,1,"TO_TANK_MOVE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tank_attack_start");

	end,
	---------------------------------------------
	---------------------------------------------
	---------------------------------------------
	OnGroupMemberDied = function( self,entity,sender )
	end,	

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
--		AI.GetAttentionTargetPosition(entity.id,g_Vectors.temp);
--		if(math.abs(entity:GetWorldPos().z - g_Vectors.temp.z) <5) then
--		-	AI.Signal(0, 1, "ADVANCE",entity.id);			
--		else
--			entity:SelectPipe(0,"start_fire");
--		end
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

	end,

	--------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	--------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
		-- try to move at right distance along last target's direction
--		local fDesiredDist = entity.AI.DesiredFireDistance[entity.AI.weaponIdx];
		AI.GetAttentionTargetPosition(entity.id,g_Vectors.temp);
--		if(math.abs(entity:GetWorldPos().z - g_Vectors.temp.z) <5) then
--	TO DO: use this when it'll move correctly
--			if(entity:SetRefPointAtDistanceFromTarget(fMinDist*1.1,fMinDist*1.3)) then 
--				entity:SelectPipe(0,"t_approach_target_at_distance");
--				entity:InsertSubpipe(0,"stop_fire");
--			else -- fire at the enemy memory target
--				entity:SelectPipe(0,"do_nothing");
--				entity:InsertSubpipe(0,"start_fire");
--			end
--		end
	end,
	
	---------------------------------------------
	OnTargetTooClose = function( self, entity, sender,data )
	  -- Under construction 02/11/05 Tetsuji
		-- data.iValue = current weapon index
		-- AI.LogEvent("TANK tooo close to target");
		-- AI.Signal(0, 1, "TRY_TO_MOVE_AT_DISTANCE",entity.id);			
	end,
	---------------------------------------------
	-- CUSTOM
	---------------------------------------------
	---------------------------------------------
	--------------------------------------------
	DRIVER_IN = function( self,entity, sender )
	end,	
	
	--------------------------------------------
	---------------------------------------------
--	DRIVER_OUT = function( self,entity,sender )
--	end,	

	---------------------------------------------
	on_spot = function( self,entity,sender )
	
--		entity:SelectPipe( 0, "t_stan_shoot" );		
		entity:SelectPipe( 0, "t_stand_shoot" );		
		entity.AI.MoveToSpot = false;
	end,	


	---------------------------------------------
	ADVANCE = function( self,entity,sender )

			local anchorName = AI.GetAnchor(entity.id,AIAnchorTable.TANK_SPOT,20,AIANCHOR_NEAREST_IN_FRONT);	
			local moveTo;
			if( anchorName ) then
				moveTo = true;
				local targetName = AI.GetAttentionTargetOf(entity.id);
				if (targetName and AI.Hostile(entity.id,targetName)) then
					local target = System.GetEntityByName(targetName);
					local targetPos = g_Vectors.temp;
					local targetDir = g_Vectors.temp_v1;
					AI.GetAttentionTargetPosition(entity.id,targetPos);
					local spot = System.GetEntityByName(anchorName);
					local spotPos = spot:GetWorldPos();
					local spotDir = spot:GetDirectionVector();
					FastDifferenceVectors(targetDir, targetPos,spotPos);
					NormalizeVector(targetDir);
					local side = dotproduct3d(targetDir,spotDir);
					if(side<0) then -- target is on opposite side from tank spot direction
						moveTo = false;
					end
				end
			end
			
--	TO DO: use this when it'll move correctly
--			if(moveTo) then
--				entity:SelectPipe(0,"t_moveto",anchorName);
--				entity:InsertSubipe(0,"stop_fire");
--				entity.AI.MoveToSpot = true;
--			else
--				AI.Signal(0, 1, "TRY_TO_MOVE_AT_DISTANCE",entity.id);			
--			end
	end,	

	---------------------------------------------
	REFPOINT_REACHED = function(self,entity,sender)
		if(AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then 
			entity:SelectPipe(0,"start_fire");			
		end
	end,

	--------------------------------------------------------------------------
	TANK_PROTECT_ME = function( self, entity, sender )

		if ( AI.GetSpeciesOf(entity.id) == AI.GetSpeciesOf(sender.id) ) then

			entity.AI.protect = sender.id;

			if ( entity.id == sender.id ) then
				if (entity.AI.mindType == 3 ) then
					entity.AI.mindType = 2;
				end
			else
				if (entity.AI.mindType == 2 ) then
					entity.AI.mindType = 3;
				end
			end

		end

	end,

}

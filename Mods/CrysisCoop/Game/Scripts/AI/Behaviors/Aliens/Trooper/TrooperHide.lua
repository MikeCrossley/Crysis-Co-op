--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Hide behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 14/4/2007     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperHide = {
	Name = "TrooperHide",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function(self,entity)
		entity:SelectPipe(0,"tr_stay_retreated");
	end,
	
	---------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,


	---------------------------------------------		
	OnPlayerSeen = function( self, entity, distance )
		entity:InsertSubpipe(0,"start_fire");
		if(distance < 15) then 
			if(Trooper_DoubleJumpMelee(entity)) then 
				return;
			elseif(Trooper_JumpMelee(entity)) then 
				return;
			else
				-- jump to next position (by requesting a longer distance)
				g_SignalData.iValue=AI_MOVE_BACKWARD; 
				g_SignalData.fValue = 25; -- preferred distance to next position
				g_SignalData.iValue2 = 0;
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
			end
		end
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )

	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
		-- try melee
			if(Trooper_DoubleJumpMelee(entity)) then 
				return;
			elseif(Trooper_JumpMelee(entity)) then 
				return;
			else
				-- jump to next position (by requesting a longer distance)
				g_SignalData.iValue=AI_MOVE_BACKWARD; 
				g_SignalData.fValue = 25; -- preferred distance to next position
				g_SignalData.iValue2 = 0;
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
			end
		else
			entity:InsertSubpipe(0,"acquire_target",data.id);
		end		
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data)
		-- called when the enemy detects bullet trails around him
	end,

	--------------------------------------------------
	OnNearMiss = function ( self, entity, sender, data)
		-- called when the enemy detects bullet trails around him
	end,

	
	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
		local refPos = g_Vectors.temp;
		local targetDir = g_Vectors.temp_v1;
		if(AI.GetBeaconPosition(entity.id,targetDir)) then
			FastDifferenceVectors(targetDir, targetDir,entity:GetWorldPos());
		else			
			CopyVector(targetDir,entity:GetDirectionVector());
		end
		
		targetDir.z = 0;

		local dot = dotproduct3d(targetDir,	entity:GetDirectionVector());
		if(dot <0) then
			VecRotate90_Z(targetDir);
		else
			VecRotateMinus90_Z(targetDir);
		end					
		FastSumVectors(refPos, entity:GetWorldPos(),targetDir);
		AI.SetRefPointPosition(entity.id,refPos);
	end,

	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
		entity:SelectPipe(0,"do_nothing");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_RETREAT",entity.id);
	end,
	
	--------------------------------------------------
	END_HIDE = function(self,entity,sender)
		-- Calculate strafe point and set it to ref point.
		
--		if( entity:SetRefPointToStrafeObstacle() ) then
			AIBehaviour.TROOPERDEFAULT:StrafeObstacle(entity);
			entity:InsertSubpipe(0,"start_fire");
--		end
	end,

	--------------------------------------------------
	OnPlayerFrozen = function (self,entity,sender)
	end,
	
	--------------------------------------------------
	OnPlayerUnFrozen = function (self,entity,sender)
		entity.AI.bGoingToShatterPlayer = false;
		g_localActor.AI.bFrozenNotified = false;
	end,
	
	--------------------------------------------------
	MELEE_OK = function (self,entity,sender)
		if(Trooper_CheckMeleeFinal(entity)) then 
			return;
		end
		AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_RETREAT",entity.id);
	end,

	--------------------------------------------------
	MELEE_FAILED = function (self,entity,sender)
		AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_RETREAT",entity.id);
	end,
	
	--------------------------------------------------
	END_MELEE = function (self,entity,sender)
		AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_RETREAT",entity.id);
	end,
	
	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,

	--------------------------------------------------
	JUMP_ON_ROCK = function(self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	
	end,

	--------------------------------------------------
	OnCloseContact = function(self,entity,target)
		if(Trooper_CheckMelee(entity,target,4)) then 
			return;
		end
		AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_RETREAT",entity.id);
	
	end,
}
-------------------------------------------------------------------------- 
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Attack behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------


AIBehaviour.TrooperAttackSwitchPosition = {
	Name = "TrooperAttackSwitchPosition",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	hasConversation = true,

	---------------------------------------------
	Constructor = function (self, entity)
--		AI.Signal(SIGNALFILTER_SUPERSPECIES, 0,"IS_PLAYER_ENGAGED",entity.id);
		entity:SelectPipe(0,"do_nothing");
		if(entity.AI.usingMoar == nil) then 
			-- TO DO: use AI.fireMode to check
			local weapon = entity.inventory:GetCurrentItem();
			if(weapon~=nil and (weapon.class=="MOAR" or weapon.class == "FastLightMOAR")) then
				entity.AI.usingMoar = true;
				
			else
				entity.AI.usingMoar = false;
			end
		end
		if(entity.AI.usingMoar) then 
			g_SignalData.iValue = UNIT_CLASS_LEADER; -- "I need cover"
			AI.Signal(SIGNALFILTER_LEADER,10,"OnSetUnitProperties",entity.id,g_SignalData);
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_MOAR",entity.id);
		else
			if(not Trooper_CheckJumpToFormationPoint(entity)) then 
				entity:SelectPipe(AIGOALPIPE_SAMEPRIORITY,"tr_attack_switch_position");
			end
		end
		entity:Cloak(0);
		if(entity.AI.bFormationReached) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
		end
		Trooper_SetAccuracy(entity,2);
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then 
			AI.ModifySmartObjectStates(entity.id,"SearchShootSpots,-ShootSpotFound");
		end
		Trooper_SetConversation(entity);
	end,

	Destructor = function(self,entity)
--		AI.ModifySmartObjectStates(entity.id,"-SearchShootSpots");				
	end,
	
	
	OnPlayerSeen = function(self,entity,sender)
		if(Trooper_CheckJumpToFormationPoint(entity)) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK_JUMP",entity.id);
		else
			if(entity.AI.bFormationReached) then 
				AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			end
			entity:SelectPipe(0,"tr_attack_switch_position");
		end
	end,
	
	OnPlayerLooking = function(self,entity,sender)
		if(entity:GetDistance(g_localActor.id) > entity.melee.damageRadius+1) then 
			if( Trooper_Dodge(entity)) then 
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
				return;
			end
		end
		g_SignalData.iValue = 0;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	
	end,
	
	OnEnemyMemory = function(self,entity,sender)
--		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
--		entity:SelectPipe(0,"tr_check_other_shoot_spots");
	end,

	OnNoTargetVisible = function(self,entity,sender)
		entity:Readibility("target_lost",1,0);
		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
		entity:SelectPipe(0,"tr_check_other_shoot_spots");
	end,

			
	OnLeaderActionFailed = function(self,entity,sender,data)
--		AIBehaviour.TrooperAttackSwitchPosition.OnLeaderActionCompleted(entity,sender);
		Trooper_ChooseNextTactic(entity,data,true);
	end,

	OnLeaderActionCompleted = function(self,entity,sender,data)
--		local targetType = AI.GetTargetType(entity.id);
--		if(targetType~=AITARGET_NONE and targetType~=AITARGET_FRIENDLY) then 
--			AIBehaviour.TROOPERDEFAULT:ChooseAttack(entity);
--		else
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SEARCH",entity.id);
--		end

		Trooper_ChooseNextTactic(entity,data,false);
	end,

	OnFormationPointReached = function( self, entity, sender )
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");				
		entity.AI.bFormationReached = true;
	end,
	
	OnThreateningSoundHeard = function( self, entity, sender )

	end,

	OnInterestingSoundHeard = function( self, entity, sender )

	end,

	OnSomethingSeen = function( self, entity, distance )
	end,

	OnBulletRain = function( self, entity, sender,data )
		if(AI.Hostile(entity.id,data.id)) then 
			AIBehaviour.TrooperAttackSwitchPosition:OnEnemyDamage( entity, sender,data );
		end
	end,
	
	OnBulletHit = function( self, entity, sender,data )
	end,
	
	OnNearMiss = function( self, entity, sender,data )
	end,
	
	OnEnemyDamage = function( self, entity, sender,data )
--		local dir = g_Vectors.temp;
--		CopyVector(dir,data.point2);
--		local dist = data.fValue/100;
--		if(dist>2) then 
--			dist = 2;
--		elseif(dist<1) then 
--			dist = 1;
--		end
--		ScaleVectorInPlace(dir,dist);
--		FastSumVectors(dir,dir,entity:GetWorldPos());
--		if(AI.CanMoveStraightToPoint(entity.id,dir)) then
--			if(Trooper_Jump(entity,dir,false,false,0)) then 
--				entity.AI.JumpType = TROOPER_JUMP_HITBACK; 
--				entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"tr_short_jump_timeout");
--			end
--		end
		local shooter = System.GetEntity(data.id);
		if(Trooper_ReevaluateShooterTarget(entity,shooter)) then 
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"acquire_target",shooter.id);
		end
		entity.AI.shooterId = data.id;
		self:END_HIT_BACK(entity,sender,data);
	end,

	END_HIT_BACK = function( self, entity, sender,data )
		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		local dist = AI.GetAttentionTargetDistance(entity.id);
--		if( target == nil or target.id ~= data.id or dist>5) then
		if( target == nil or target.id ~= entity.AI.shooterId or dist>5) then
			if( Trooper_Dodge(entity)) then 
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
				return;
			elseif(random(1,100)<50)then -- and Trooper_DoubleJumpMelee(entity)) then
				AI.Signal(SIGNALFILTER_SENDER,AISIGNAL_PROCESS_NEXT_UPDATE,"CHECK_DOUBLE_JUMP_MELEE",entity.id);
--				if( Trooper_DoubleJumpMelee(entity)) then
				return;
--				end
			end
		elseif(dist<=5) then
--			if(not Trooper_CheckJumpToFormationPoint(entity)) then 
--				entity:SelectPipe(0,"do_nothing");
--				entity:SelectPipe(0,"tr_attack_switch_position");
--			end
			if(Trooper_CheckJumpToFormationPoint(entity)) then 
				return;
			end
		end
					
		g_SignalData.iValue = 0;
		g_SignalData.iValue2 = 14;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
	end,

	--------------------------------------------------
	CHECK_DOUBLE_JUMP_MELEE = function(self,entity,sender)
		if(not Trooper_DoubleJumpMelee(entity)) then
			g_SignalData.iValue = 0;
			g_SignalData.iValue2 = 14;
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
		end
	end,

	--------------------------------------------------
	CHECK_DODGE = function(self,entity,sender,data)
		if(not Trooper_Dodge(entity,nil,data.iValue)) then 
			AI.Signal(SIGNALFILTER_SENDER,AISIGNAL_PROCESS_NEXT_UPDATE,"CHECK_DOUBLE_JUMP_MELEE",entity.id);
		end	
		g_SignalData.iValue = 0;
		g_SignalData.iValue2 = 14;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
	end,

	--------------------------------------------------
	OnAttackSwitchPosition = function( self, entity, sender )
--		if(entity:IsUsingPipe("tr_attack_switch_position")) then 
--			entity.AI.bReposition = true;	
--		else
			if(not Trooper_CheckJumpToFormationPoint(entity)) then 
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"tr_attack_switch_position");
			end
--		end			
	end,
	
	CHECK_REPOSITION = function( self, entity, sender )
		if(entity.AI.bReposition) then 
			if(not Trooper_CheckJumpToFormationPoint(entity)) then 
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"tr_attack_switch_position");
			end
		end
		entity.AI.bReposition = false;
	end,
	
	OnFriendlyDamage = function( self, entity, sender,data )
	end,
	
	StickPlayerAndShoot= function(self,entity,sender)
	
	end,
	
	GO_THREATEN = function(self,entity,sender)
	
	end,

	RETREAT_OK = function(self,entity,sender)
		
	end,


	OnCloseContact= function(self,entity,target)
		-- check target moving direction
		if(Trooper_CloseContactChoice(entity,target,4)) then 
			return;
		end
		local targetDir = g_Vectors.temp;
		target:GetVelocity(targetDir);
		if(IsNotNullVector(targetDir)) then
			NormalizeVector(targetDir);
		else
			CopyVector(targetDir,target:GetDirectionVector(1));
		end
		--if(random(1,2)==1) then 
		if(dotproduct2d(targetDir,entity:GetDirectionVector(0)) >0) then
			-- target is moving towards trooper's right, move left(=right w.r.to the target )
			g_SignalData.iValue = AI_MOVE_BACKWARD+AI_MOVE_RIGHT;
		else
			g_SignalData.iValue = AI_MOVE_BACKWARD+AI_MOVE_LEFT;
		end
		g_SignalData.fValue = -1;
		AI.ModifySmartObjectStates(entity.id,"StayOnGround");
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestNewPoint",entity.id,g_SignalData);
	end,

	
	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		if(entity:IsUsingPipe("tr_attack_switch_position")) then 
			entity:PlayAccelerationSound();
		end
	end,

	--------------------------------------------------
	OnNoPathFound = function(self,entity,sender)
		g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
		g_SignalData.fValue = 8;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdateAlternative",entity.id,g_SignalData);
	end,
	
	--------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
		if(entity ~= sender and not AI.GetLeader(entity.id)) then 
			AI.SetLeader(entity.id);
		end
	end,
	
	--------------------------------------------------
	OnGroupMemberDiedNearest= function(self,entity,sender,data)
		local leader = AI.GetLeader(entity.id);
		if(sender == leader) then 
			AI.SetLeader(entity.id);
		end

	end,
	
	--------------------------------------------------
	OnAvoidDanger = function(self,entity,sender,data)
		if(AI.GetNavigationType(entity.id) == NAV_TRIANGULAR) then 
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"tr_avoid_danger");
--		AI.SetRefPointPosition(entity.id,data.point);
--		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 8);
		end
	end,

	--------------------------------------------------
	OnNavTypeChanged= function(self,entity,sender,data)

	end,

	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
		local targetNavType = data.iValue2;
		if(targetNavType ==	NAV_WAYPOINT_HUMAN or targetNavType== NAW_WAYPOINT_TRIANGULAR) then 
			entity.AI.navType = data.iValue;
			entity.AI.targetNavType = targetNavType;
			if(targetNavType == NAV_WAYPOINT_HUMAN and entity.Properties.bForceOutdoor~=0) then
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
			end
		end
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		if(entity.AI.JumpType == TROOPER_JUMP_SWITCH_POSITION) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");

			entity:SelectPipe(0,"tr_attack_switch_position");
		elseif(entity.AI.JumpType == TROOPER_JUMP_MELEE) then
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
		 	if( AI.GetAttentionTargetEntity(entity.id,true)) then 
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_MELEE",entity.id);
				entity:SelectPipe(0,"tr_try_melee_inplace");
			else
				entity:SelectPipe(0,"tr_attack_switch_position");
			end
		elseif(entity.AI.JumpType == TROOPER_JUMP_FIRE) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			entity:SelectPipe(0,"tr_attack_switch_position");
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"stop_fire");
			g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
			g_SignalData.fValue = 6;
			if(random(1,50) >50) then 
				-- jump to next position (by requesting a longer distance)
				g_SignalData.iValue2 = 14; -- preferred distance to next position
			else
				g_SignalData.iValue2 = 8; -- preferred distance to next position
			end
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
		elseif(entity.AI.JumpType == TROOPER_JUMP_HITBACK) then 
			AIBehaviour.TrooperAttackSwitchPosition:END_HIT_BACK(entity,sender);
		else
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_lower_target");
		end
		entity.AI.JumpType = nil;
	end,
	
	--------------------------------------------------
	END_JUMP_ON_SPOT = function(self,entity,sender)
		AI.ModifySmartObjectStates(entity.id,"-ShootSpotFound");
		AI.ModifySmartObjectStates(entity.id,"StayOnGround");
		if(not Trooper_CheckJumpToFormationPoint(entity)) then 
			entity:SelectPipe(0,"tr_attack_switch_position");
			g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
			g_SignalData.fValue = 6;
			if(random(1,50) >50) then 
				-- jump to next position (by requesting a longer distance)
				g_SignalData.iValue2 = 14; -- preferred distance to next position
			else
				g_SignalData.iValue2 = 8; -- preferred distance to next position
			end
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
		end
	end,

	--------------------------------------------------
	END_SWITCH_POSITION = function(self,entity,sender)
		local dist = AI.GetAttentionTargetDistance(entity.id);
		
		local randomVal = random(1,100);
--		if(randomVal <50) then 
--		-- try melee
--			if( randomVal<35 or entity.AI.bBehind) then 
--				if(Trooper_DoubleJumpMelee(entity)) then 
--					return;
--				end
--			else	
--				if(Trooper_JumpMelee(entity)) then 
--					return;
--				end
--			end
--			randomVal = randomVal + 50;
--		end
		if(randomVal >25 and Trooper_JumpFire(entity,dist)) then 
		-- try jump+fire crossing the target's fov from side to side
--			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK_JUMP",entity.id);
			return;
			
		else
--			g_SignalData.iValue=0; -- no preferred direction
			g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
			g_SignalData.fValue = 6;
			if(randomVal >15) then 
				-- jump to next position (by requesting a longer distance)
				g_SignalData.iValue2 = 14; -- preferred distance to next position
			else
				g_SignalData.iValue2 = 8; -- preferred distance to next position
			end
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
			if(random(1,2)==1) then 
				entity:Readibility("taunt");
			end
		end
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	end,	

	--------------------------------------------------
	JUMP_FIRE = function(self,entity,sender)
		if(Trooper_Jump(entity,entity.AI.targetPos,true,true,20)) then 
			entity.AI.JumpType = TROOPER_JUMP_FIRE;
			entity:SelectPipe(0,entity.AI.jumpPipe);
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK_JUMP",entity.id);
		else
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			entity:SelectPipe(0,"tr_attack_switch_position");
		end
	end,
	
	--------------------------------------------------
	JUMP_FIRE_NO_PATH= function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	
	end,
	
	--------------------------------------------------
	OnBehind = function(self,entity,sender,data)
		entity.AI.bBehind = true;
--		if(random(1,100)<50 or not Trooper_DoubleJumpMelee(entity)) then 
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--		end
	end,

	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,
	

	--------------------------------------------------
	STAY_AWAY_FROM= function(self,entity,sender,data)
		Trooper_MoveAway(entity,data);		
	end,

	--------------------------------------------------
	LOOK_CLOSER= function(self,entity,sender,data)
	end,
	
	--------------------------------------------------
	END_MELEE = function(self,entity,sender)
		if(Trooper_CheckJumpToFormationPoint(entity)) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK_JUMP",entity.id);
		else
			if(entity.AI.bFormationReached) then 
				AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			end
			entity:SelectPipe(0,"tr_attack_switch_position");
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
		end
	end,
	
	--------------------------------------------------
	JUMP_ON_WALL_FAILED = function(self,entity,sender)
		if(Trooper_CheckJumpToFormationPoint(entity)) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK_JUMP",entity.id);
		else
			if(entity.AI.bFormationReached) then 
				AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			end
			entity:SelectPipe(0,"tr_attack_switch_position");
		end
	end,
}

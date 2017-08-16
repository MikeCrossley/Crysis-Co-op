-------------------------------------------------------------------------- 
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Special action Attack behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------


AIBehaviour.TrooperAttackSpecialAction = {
	Name = "TrooperAttackSpecialAction",
	Base = "TROOPERDEFAULT",
	alertness = 2,
	
	hasConversation = true,

	---------------------------------------------
	Constructor = function (self, entity)
		
		if(	entity.AI.bjumpingAtTargetDirection) then 
			return;
		end
		
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		if(not target) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"BackToSwitchPosition",entity.id);
			return;
		end
		
		-- any enemy target (unless it's a vehicle) can't have more than one trooper doing
		-- a special action against him, in the whole level 
		if(AIBlackBoard.Trooper_SpecialActionTarget and not AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE) then 
			for name,tg in pairs(AIBlackBoard.Trooper_SpecialActionTarget) do
				if(tg==target) then 
					AI.Signal(SIGNALFILTER_SENDER,1,"BackToSwitchPosition",entity.id);
					return;
				end
			end
		end
				
		if(not AIBlackBoard.Trooper_SpecialActionTarget) then 
			AIBlackBoard.Trooper_SpecialActionTarget = {};
		end
		
		AIBlackBoard.Trooper_SpecialActionTarget[entity:GetName()] = target;
		AI.ModifySmartObjectStates(entity.id,"SpecialAction");

--		local dist = AI.GetAttentionTargetDistance(entity.id);
		AI.Signal(SIGNALFILTER_LEADER,10,"OnExecutingSpecialAction",entity.id);
		
		entity.AI.meleeTarget = target;

		if(AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET) > 1) then 
			entity:Readibility("threaten",1,100,1,1.5);
		end

		self:DoSpecialAction(entity);		

		Trooper_SetConversation(entity);
		
	end,

	--------------------------------------------------
	Destructor = function(self,entity)
--		AI.ModifySmartObjectStates(entity.id,"-SearchShootSpots");				
		--entity.AI.lastHealthDamaged = nil;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnSpecialActionDone",entity.id);
		
		if(AIBlackBoard.Trooper_SpecialActionTarget) then -- might be nil because of old pre-patch3 savefiles
			AIBlackBoard.Trooper_SpecialActionTarget[entity:GetName()] = nil;
		else
			AIBlackBoard.Trooper_SpecialActionTarget = {};
		end
		
		AI.ModifySmartObjectStates(entity.id,"-SpecialAction");
		entity.AI.bMovingAtTargetDirection = false;

	end,

	--------------------------------------------------
	OnSpecialAction = function(self,entity)
		AIBehaviour.TrooperAttackSpecialAction:Constructor(entity);
	end,
	

	--------------------------------------------------
	DoSpecialAction = function(self,entity)
		local randomVal = random(1,100);
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(randomVal <80 or (target and AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE) or Trooper_LowHealth(entity)) then 
		-- try melee

			if( randomVal<60 or entity.AI.bBehind) then 
				if(Trooper_DoubleJumpMelee(entity)) then 
					return;
				elseif(Trooper_JumpMelee(entity)) then 
					return;
				end
			else	
				if(Trooper_JumpMelee(entity)) then 
					return;
				elseif(Trooper_DoubleJumpMelee(entity)) then 
					return;
				end
			end
		end
		self:TryMelee(entity,target);
	end,
	
	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		if(entity:IsUsingPipe("tr_try_melee_special") or entity:IsUsingPipe("tr_try_melee_vehicle")) then 
			local dist = AI.GetAttentionTargetDistance(entity.id);
			if(dist and dist>5) then
				entity:PlayAccelerationSound();
			end
		end
	end,
	
	--------------------------------------------------
	OnEnemyDamage = function(self,entity,sender,data) 
		if(entity:IsUsingPipe("tr_try_melee_special") or entity:IsUsingPipe("tr_try_melee_vehicle")) then -- :(
			if (data.ObjectName ~= "melee") then 
				if(Trooper_Dodge(entity,2,nil,TROOPER_DODGE_FORWARD,true)) then
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
				end
			end
		elseif(entity:IsUsingPipe("tr_jump_melee")) then -- :(
			local params =
			{
				SpawnPeriod			= 0,
				Scale						= 1,
				CountScale			= 1,
				bCountPerUnit		= 0,
				bSizePerUnit		= 0,
				AttachType			= "none",
				AttachForm			= "none",
				bPrime					= 0,
			}
			entity:LoadParticleEffect( -1, "alien_special.Trooper.heavy_damage", params );
		end
					
	end,
	
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self,entity,sender,data) 
		-- data.fValue = player's distance
		if(data.fValue>4 and data.fValue<6) then 
			if(not entity:IsUsingPipe("tr_melee_special_timeout")) then -- :(
				if(Trooper_Dodge(entity,2,nil,TROOPER_DODGE_FORWARD,true)) then
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
				end
			end
		end
	end,
	
	--------------------------------------------------
	OnPlayerSeen = function(self,entity,distance)
		entity.AI.meleeTarget = AI.GetAttentionTargetEntity(entity.id);
		entity:SelectPipe(0,"do_nothing");
		self:TryMelee(entity);
	end,
	

	--------------------------------------------------
	OnBulletRain	= function(self,entity,target,data)
	
	end,

	--------------------------------------------------
	OnNearMiss	= function(self,entity,target)
	
	end,
	
	--------------------------------------------------
	OnCloseContact= function(self,entity,target)
	end,

	--------------------------------------------------
	OnNoTargetVisible = function(self,entity,target)
		self:EndBehaviour(entity);
	end,
	
	--------------------------------------------------
	OnNoTarget = function(self,entity,target)
		if(AI.GetGroupTarget(entity.id)) then 
			self:EndBehaviour(entity);
		else
			Trooper_Search(entity);
		end
	end,
		
	--------------------------------------------------
	OnNoTargetAwareness = function(self,entity,target)
		self:EndBehaviour(entity);
	end,
	
	--------------------------------------------------
	OnEnemyMemory = function(self,entity,target)
		--AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,
	
	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
		if(Trooper_CheckMeleeFinal(entity,true)) then 
			return;
		else
			entity:SelectPipe(0,"do_nothing");
			self:END_MELEE(entity,sender);
		end
		--AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,

	--------------------------------------------------
	MELEE_TARGET_CLOSE = function( self, entity, sender)
		if(Trooper_CheckMeleeFinal(entity,true)) then 
			return;
		else
			entity:SelectPipe(0,"do_nothing");
			self:END_MELEE(entity,sender);
		end
	end,
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
		
--		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
--			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
--			entity:SelectPipe(0,"tr_attack_switch_position");
--		end
	end,
		
	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
	  AIBlackBoard.lastTrooperMeleeTime = _time;
--		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
--			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
--			entity:SelectPipe(0,"tr_attack_switch_position");
--		end
		--self:TryMelee(entity);
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			self:DoSpecialAction(entity);
		elseif(AI.GetGroupTarget(entity.id)) then 
			self:EndBehaviour(entity);
		else
			Trooper_Search(entity);
		end
	end,
	
	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	OnBehind = function(self,entity,sender,data)
		entity.AI.bBehind = true;
	end,
	
	--------------------------------------------------
	OnTargetNavTypeChanged = function(self,entity,sender,data)
		local targetNavType = data.iValue2;
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		if(entity.AI.bjumpingAtTargetDirection) then
			entity.AI.bjumpingAtTargetDirection = false;
			self:DoSpecialAction(entity);
			return;
		end
		if(AI.GetAttentionTargetEntity(entity.id,true)) then 
			self:TryMelee(entity);
		else
			self:EndBehaviour(entity);
		end
		entity.AI.JumpType = nil;
			
	end,
	
	--------------------------------------------------
	DODGE_FINISHED= function(self,entity,sender)
		if(AI.GetAttentionTargetEntity(entity.id,true)) then 
			self:TryMelee(entity);
		else
			self:EndBehaviour(entity);
		end
	end,
	
	--------------------------------------------------
	JUMP_ON_ROCK = function (self,entity,sender,data)
		AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function (self,entity,sender,data)
		AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,
		
	--------------------------------------------------

	SET_END_MELEE_TIMER = function (self,entity,sender)
		entity:SetTimer(TROOPER_MELEE_SPECIAL_TIMER,3000);
	end,
	
	--------------------------------------------------
	MELEE_SPECIAL_START_TIMEOUT = function (self,entity,sender)
		entity:SelectPipe(0,"tr_melee_special_timeout");

	end,

	--------------------------------------------------
	MELEE_SPECIAL_TIMEOUT = function (self,entity,sender)
		if(not Trooper_DoubleJumpMelee(entity)) then 
			AI.Signal(SIGNALFILTER_SENDER,AISIGNAL_PROCESS_NEXT_UPDATE,"MELEE_SPECIAL_TIMEOUT2",entity.id);
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_wait_timeout2");
		end
	end,
	
	--------------------------------------------------
	MELEE_SPECIAL_TIMEOUT2 = function (self,entity,sender)
		if(not Trooper_JumpMelee(entity)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY,1,"REQUEST_MOVE_TARGET_DIRECTION",entity.id);
			AI.Signal(SIGNALFILTER_LEADER,10,"OnSpecialActionDone",entity.id);
			entity.AI.bMovingAtTargetDirection = true;
		end
	end,
	
	--------------------------------------------------
	OnAttackSwitchPosition = function (self,entity,sender) 
		if(entity.AI.bMovingAtTargetDirection and not entity.AI.bjumpingAtTargetDirection) then 
			-- trooper has just requested to move to where the player is going
			entity.AI.bMovingAtTargetDirection = false;
			local pos = g_Vectors.temp;
			if(AI.GetFormationPointPosition(entity.id,pos)) then
				local target = AI.GetAttentionTargetEntity(entity.id);
				if(target) then 
					local movedir = g_Vectors.temp_v1;
					target:GetVelocity(movedir);
					local targetdir = g_Vectors.temp_v2;
					FastDifferenceVectors(targetdir,target:GetPos(),entity:GetPos());
					if(dotproduct2d(movedir,targetdir)>0.7) then 
						if(Trooper_Jump(entity,pos,true,true,10)) then
							entity.AI.bjumpingAtTargetDirection = true;
							return;
						end
					end
				end
			end
		end
		self:EndBehaviour(entity);
	end,
	
	--------------------------------------------------
	EndBehaviour = function (self,entity) 
		if(AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET)>1) then
			AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
		else
			self:DoSpecialAction(entity);
		end
	end,
	
	--------------------------------------------------
	MELEE_SPECIAL_TIMEOUT_FAIL = function (self,entity,sender)
		self:DoSpecialAction(entity);		
	end,
	
	--------------------------------------------------
	LOOK_CLOSER= function(self,entity,sender,data)
	end,
	
	TryMelee = function(self,entity,target)
		if(not target) then 
			target = AI.GetAttentionTargetEntity(entity.id);
		end
		if(target) then 
			if(AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE) then 
				entity:SelectPipe(0,"tr_try_melee_vehicle");
			else
				entity:SelectPipe(0,"tr_try_melee_special");
			end
		end
	end,

}

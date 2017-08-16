-------------------------------------------------------------------------- 
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Chase/Combat behavior for Alien Trooper. 
--  Following fast targets
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------


AIBehaviour.TrooperChase = {
	Name = "TrooperChase",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
		AI.ChangeMovementAbility(entity.id,AIMOVEABILITY_USEPREDICTIVEFOLLOWING,0);
		entity:SelectPipe(0,"tr_chase_fire");
		--entity:Cloak(0);
	end,

	Destructor = function(self,entity)
--		AI.ModifySmartObjectStates(entity.id,"-SearchShootSpots");				
		AI.ChangeMovementAbility(entity.id,AIMOVEABILITY_USEPREDICTIVEFOLLOWING,1);
		entity:SelectPipe(0,"do_nothing");
		AI.SetStance(entity.id,BODYPOS_STAND);
	end,
	
	
	OnPlayerSeen = function(self,entity,sender)
		if(not entity.AI.liveTarget) then 
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"tr_chase_fire");
		end
		entity.AI.liveTarget = true;
	end,
	
	OnPlayerLooking = function(self,entity,sender)
		
	end,
	
	OnEnemyMemory = function(self,entity,sender)
		entity.AI.liveTarget = false;
	end,
		
	OnLeaderActionFailed = function(self,entity,sender,data)
		Trooper_ChooseNextTactic(entity,data,true);
	end,

	OnLeaderActionCompleted = function(self,entity,sender,data)
		Trooper_ChooseNextTactic(entity,data,false);
	end,

	TRY_MELEE = function( self, entity, sender )
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");				
		if(random(1,100)<50) then 
			-- jump melee
			if(self:FirstJumpMelee(entity)) then 
				return;
			end
		end
		--entity:SelectPipe(0,"tr_shoot_moving_target");
	end,
	
	ON_END_SHOOT_MOVING_TARGET = function(self,entity,sender)
			entity:SelectPipe(0,"tr_chase_fire");
	end,
	
	OnThreateningSoundHeard = function( self, entity, sender )
		entity.AI.liveTarget = false;

	end,

	OnInterestingSoundHeard = function( self, entity, sender )
		entity.AI.liveTarget = false;

	end,

	OnSomethingSeen = function( self, entity, distance )
		if(not entity.AI.liveTarget) then 
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"tr_chase_fire");
		end
		entity.AI.liveTarget = true;
	end,

	OnBulletRain = function( self, entity, sender,data )
	end,
	
	OnNearMiss = function( self, entity, sender,data )
	end,

	OnEnemyDamage = function( self, entity, sender,data )
	end,


	OnFriendlyDamage = function( self, entity, sender,data )
	end,
	
	StickPlayerAndShoot= function(self,entity,sender)
	
	end,
	
	GO_THREATEN = function(self,entity,sender)
	
	end,

	OnCloseContact= function(self,entity,target)
	end,

	
	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		--entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_prone");
	end,
	
	--------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
		if(entity ~= sender and not AI.GetLeader(entity.id)) then 
			AI.SetLeader(entity.id);
		end
	end,
	
--	--------------------------------------------------
--	OnGroupMemberDiedNearest= function(self,entity,sender,data)
--		local leader = AI.GetLeader(entity.id);
--		if(sender == leader) then 
--			AI.SetLeader(entity.id);
--		end
--
--	end,
	
	--------------------------------------------------
	OnAvoidDanger = function(self,entity,sender,data)
--		entity:SelectPipe(0,"do_nothing");
--		entity:SelectPipe(0,"tr_avoid_danger");
--		AI.SetRefPointPosition(entity.id,data.point);
--		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 8);
	end,

	--------------------------------------------------
	OnNavTypeChanged= function(self,entity,sender,data)

	end,

	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		if(	entity.AI.JumpType == TROOPER_JUMP_SWITCH_POSITION) then 
			entity:SelectPipe(0,"tr_chase_fire");
		end
	end,
	
	--------------------------------------------------
	OnNoPathFound = function(self,entity,sender)
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_chase_fire");
	end,
	--------------------------------------------------
	JUMP_FIRE = function(self,entity,sender)
--		if(Trooper_Jump(entity,entity.AI.targetPos,false,true,20)) then 
--			entity.AI.JumpType = TROOPER_JUMP_FIRE;
--			entity:SelectPipe(0,entity.AI.jumpPipe);
--		else
--			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--		end
	end,
	
	OnVehicleDanger = function (self,entity,sender,data)
		-- called when a vehicle is going towards the AI
		-- data.point = vehicle movement direction
		-- data.point2 = suggested point to go
--		if(IsNotNullVector(data.point2)) then 
--			AI.SetRefPointPosition(entity.id,data.point2);
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_dodge_vehicle");
--		elseif(not self:FirstJumpMelee(entity)) then 
--			if( Trooper_Dodge(entity)) then 
--				--AI.Signal(SIGNALFILTER_LEADER,10,"GO_TO_DODGE",entity.id);
--				return;
--			end
--		end
		
	end,



	FirstJumpMelee = function(self,entity)
		local curTime = _time;
		if(AIBlackBoard.lastJumpMeleeTime==nil) then 
			AIBlackBoard.lastJumpMeleeTime = curTime - 6;
		end
		if( curTime - AIBlackBoard.lastJumpMeleeTime > 2) then 
			local target = AI.GetAttentionTargetEntity(entity.id,true);
			if(target) then 
--				local parent = target:GetParent();
--				if(not parent) then 
--					parent = target;
--				end
				local velocity = g_Vectors.temp;
				local pos = g_Vectors.temp_v1;
				local targetPos = g_Vectors.temp_v2;
				local dir = g_Vectors.temp_v3;
				CopyVector(pos, entity:GetPos());
				CopyVector(targetPos, target:GetPos());
--				FastDifferenceVectors(dir,parent:GetVelocity(),entity:GetVelocity());
			
				FastDifferenceVectors(dir,targetPos,pos);
				local hDist = math.sqrt(dir.x*dir.x + dir.y*dir.y) ;
				local vDist = dir.z;
				local	minHdist = 7;
				local	maxHdist = 40;
				if(hDist < minHdist  or hDist > maxHdist) then 
					return false;
				end
				-- first vertical jump
				-- compute height
				-- higher jump if the trooper is farther
				local height = (hDist-minHdist)/(maxHdist - minHdist)*1.5 + vDist + 2;
				
				targetPos.x = pos.x;
				targetPos.y = pos.y; 
				targetPos.z = pos.z + height;

				local t = AI.CanJumpToPoint(entity.id,targetPos,90,20,AI_JUMP_CHECK_COLLISION+AI_JUMP_RELATIVE,velocity);
				if(t) then 
					-- second horizontal jump
					entity:SetTimer(TROOPER_JUMP_CHASE_TIMER,t*1000);
						-- vertical jump first
					entity.actor:SetParams({jumpTo = targetPos, jumpVelocity = velocity, jumpTime = t, relative = true});
					return true;
				end
			end			
		end
		return false;
	end,

	END_MELEE = function(self,entity,sender)
		entity:SelectPipe(0,"tr_chase_fire");
	end,
	
	TRY_JUMP_CHASE = function(self,entity,sender)
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then 
			local parent = target:GetParent();
			if(parent) then 
				target = parent;
			end
			local dir = g_Vectors.temp_v1;
			FastDifferenceVectors(dir,target:GetPos(),entity:GetPos());
			local dot = dotproduct3d(dir,target:GetVelocity());
			local formPos = g_Vectors.temp;
			if(AI.GetFormationPointPosition(entity.id,formPos)) then 
				if(dot>0) then
					if(Trooper_Jump(entity,formPos,false,false,-5,false,20)) then
						entity.AI.JumpType = TROOPER_JUMP_SWITCH_POSITION;
						Trooper_SetJumpTimeout(entity);
						entity:InsertSubpipe(0,"start_fire");
					end
				elseif(self:FirstJumpMelee(entity)) then 
					Trooper_SetJumpTimeout(entity);
				end
			end
		end
	end,
}

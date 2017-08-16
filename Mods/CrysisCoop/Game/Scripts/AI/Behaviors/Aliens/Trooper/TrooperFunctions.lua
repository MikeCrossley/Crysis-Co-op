--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper AI general functions
--  
--------------------------------------------------------------------------
--  History:
--  - 28/4/2007     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------

TROOPER_JUMP_SWITCH_POSITION = 1;
TROOPER_JUMP_FIRE = 2;
TROOPER_JUMP_HITBACK = 3;
TROOPER_JUMP_MELEE = 4;

TROOPER_SAFE_DISTANCE = 15;

TROOPER_DODGE_SIDE_LONG = 0;
TROOPER_DODGE_SIDE_SHORT = 1;
TROOPER_DODGE_FORWARD = 2;

-- use own static vectors here, to not mess up with g_Vectors.* used in signals calling these functions
TrVector_v0 = {x=0,y=0,z=0};
TrVector_v1 = {x=0,y=0,z=0};
TrVector_v2 = {x=0,y=0,z=0};
TrVector_v3 = {x=0,y=0,z=0};
TrVector_v4 = {x=0,y=0,z=0};
TrVector_v5 = {x=0,y=0,z=0};
Trooper_bbmin_cache = {x=0,y=0,z=0};
Trooper_bbmax_cache = {x=0,y=0,z=0};
---------------------------------------------------------
function Trooper_SetJumpTimeout(entity,keepfire)
	entity:SelectPipe(0,"tr_jump_timeout");
	local t = entity.AI.jumpTime;
	if(t) then 
		t = math.floor(t-3)+1;
		while t >= 3 do
			entity:InsertSubpipe(0,"tr_jump_timeout_3sec");
			t = t-3;
		end
		while t >= 1 do
			entity:InsertSubpipe(0,"tr_jump_timeout_1sec");
			t = t-1;
		end
	end
	entity:InsertSubpipe(0,"do_it_standing");
	entity:InsertSubpipe(0,"tr_strafe");
	if(not keepfire) then 
--		entity:InsertSubpipe(0,"stop_fire");
		entity:InsertSubpipe(0,"tr_aim");
	end	

end

---------------------------------------------------------
function Trooper_GetJumpAngleDist(trooper,targetPos,addAngle,maxAngle,filter)
	local dir = TrVector_v3;
	FastDifferenceVectors(dir,targetPos,trooper:GetPos());
	local module = dir.x*dir.x + dir.y*dir.y ;
	local hDist = math.sqrt(module);

	if(hDist>25) then 
		return;
	end

	local vDist = dir.z;

	local dist = math.sqrt(module + vDist*vDist);

	if(dist<5 and hDist > dist*0.6) then 
		return;
	end
	
	local tang = vDist/hDist;
	local angle = math.atan(tang)*57.29577;
	if(angle <-10) then 
		angle = 10;
	elseif(angle > 10 and angle <75) then 
		angle = angle+10;
	elseif(angle >= 75 and angle <85) then 
		angle = angle+5;
	elseif( angle < 10 ) then 
		angle = angle+25+hDist/2;
	end

	if(addAngle and angle+addAngle<85) then 
		angle = angle+addAngle;
	end
	
	if(maxAngle and angle > maxAngle) then 
		angle = maxAngle;
	end
	return angle,dist;
end


function Trooper_Jump(trooper,targetPos,startAnim,useEvent,addAngle,bUseSpecialAnim,maxAngle)
	local velocity = TrVector_v2;
	
	local angle,dist = Trooper_GetJumpAngleDist(trooper,targetPos,addAngle,maxAngle);
	if(angle ==nil) then 
		return false;
	end
	
	local flags;

	if(angle<88) then 
		flags = AI_JUMP_ON_GROUND + AI_JUMP_CHECK_COLLISION;
	else
		flags = AI_JUMP_CHECK_COLLISION;
	end

	local t = AI.CanJumpToPoint(trooper.id,targetPos,angle,20, flags,velocity);
	--AI.SetRefPointPosition(trooper.id,targetPos);
	if(t and t>0.7) then 
	
		if(startAnim) then 
			trooper.actor:SetParams({jumpTo = targetPos, jumpVelocity = velocity, jumpTime = t, jumpStart = startAnim,jumpLand = true, useAnimEvent = useEvent, useSpecialAnim = bUseSpecialAnim});
		else
			trooper.actor:SetParams({jumpTo = targetPos, jumpVelocity = velocity, jumpTime = t, jumpLand = true,useAnimEvent = useEvent, useSpecialAnim = bUseSpecialAnim});
		end
		AI.LogEvent(trooper:GetName().." Jump Time to reach: "..tostring(t));
		
		trooper.AI.jumpTime = t;
		trooper.AI.lastJumpTime = _time;
		
		return true;
	end
	AI.LogEvent(trooper:GetName().." cannot jump to target");

	return false;
end

---------------------------------------------------------

SET_DODGE = function(entity,posTo,direction,dodgeType,keepmoving)
	AI.SetRefPointPosition(entity.id,posTo);
	entity.AI.lastDodgeDirection = direction;
	if(direction == AI_MOVE_RIGHT) then
		if(dodgeType==TROOPER_DODGE_SIDE_SHORT) then 
			if(keepmoving) then 
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_dodge_right_short_moving");
			else
				entity:SelectPipe(0,"tr_dodge_right_short");
			end			
		elseif(dodgeType==TROOPER_DODGE_FORWARD) then 
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_dodge_right_forward");
		else
			entity:SelectPipe(0,"tr_dodge_right");
		end
	else
		if(dodgeType==TROOPER_DODGE_SIDE_SHORT) then 
			if(keepmoving) then 
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_dodge_left_short_moving");
			else
				entity:SelectPipe(0,"tr_dodge_left_short");
			end
		elseif(dodgeType==TROOPER_DODGE_FORWARD) then 
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_dodge_left_forward");
		else
			entity:SelectPipe(0,"tr_dodge_left");
		end
	end
end

---------------------------------------------------------
Trooper_DodgeOld = function(entity, minTime, dirParam,short,keepmoving)
	local curTime = _time;
	--AI.LogEvent("CLOSE CONTACT time = ".._time);
	if(minTime==nil) then 
		minTime = 4;
	end
	
	local length;
	if(short) then 
		length = 3;
	else
		length = 6;
	end

	local direction = dirParam;
	
	if(entity.AI.lastDodgeTime==nil) then 
		entity.AI.lastDodgeTime = curTime - 10;
	end
	if(AIBlackBoard.lastDodgeTime==nil) then 
		AIBlackBoard.lastDodgeTime = curTime - 10;
	end
	
	local timePassed = curTime - entity.AI.lastDodgeTime;
	local timePassedGlobal = curTime - AIBlackBoard.lastDodgeTime;
	if( timePassed > minTime and timePassedGlobal > 0.4) then
		local dir = TrVector_v3;
		CopyVector(dir, entity:GetDirectionVector(0));
		ScaleVectorInPlace(dir,length);
		if(direction == nil) then 
			local prob = random(1,100);
			if(entity.AI.lastDodgeDirection==AI_MOVE_RIGHT) then 
				prob= prob + 30;
			elseif(entity.AI.lastDodgeDirection==AI_MOVE_LEFT) then 
				prob= prob - 20;
			end
						
			if(prob>50) then 
				direction = AI_MOVE_LEFT;
			else
				direction = AI_MOVE_RIGHT;
			end			
		end		
		if(direction == AI_MOVE_LEFT) then
			NegVector(dir);
		end
		
		local pos = TrVector_v1;
		CopyVector(pos,entity:GetPos());
		local posTo = TrVector_v2;
		FastSumVectors(posTo,pos,dir);
		pos.z = pos.z+1;
--			local	hits = Physics.RayWorldIntersection(pos,dir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
--			if( hits == 0 ) then
		if(AI.CanMoveStraightToPoint(entity.id,posTo)) then
			SET_DODGE(entity,posTo,direction,short,keepmoving);
			return true;
		elseif(dirParam == nil) then -- only if a direction hasn't been explicitly requested
			NegVector(dir);
			direction = AI_MOVE_LEFT + AI_MOVE_RIGHT - direction;
			FastSumVectors(posTo,pos,dir);
--				hits = Physics.RayWorldIntersection(pos,dir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
--				if( hits == 0 ) then
			if(AI.CanMoveStraightToPoint(entity.id,posTo)) then
				SET_DODGE(entity,posTo,direction,short,keepmoving);
				return true;
			end
		end
	end	
	return false;
end


---------------------------------------------------------
Trooper_Dodge = function(entity, minTime, dirParam,dodgeType,keepmoving)
	if(entity.actor:IsFlying()) then 
		return false;
	end
	local curTime = _time;
	if(minTime==nil) then 
		minTime = 4;
	end
	
	local length = 3;

	if(dodgeType == nil) then 
		dodgeType=TROOPER_DODGE_SIDE_SHORT;
	end

	local direction = dirParam;
	local doubleLength = false;
	
	local entityAI = entity.AI;
	
	if(entityAI.lastDodgeTime==nil) then 
		entityAI.lastDodgeTime = curTime - 10;
	end
	if(AIBlackBoard.lastDodgeTime==nil) then 
		AIBlackBoard.lastDodgeTime = curTime - 10;
	end
	
	local timePassed = curTime - entityAI.lastDodgeTime;
	local timePassedGlobal = curTime - AIBlackBoard.lastDodgeTime;
	if( timePassed > minTime and timePassedGlobal > 0.4) then
		local dir = TrVector_v3;
		CopyVector(dir, entity:GetDirectionVector(0));
		if(dodgeType==TROOPER_DODGE_FORWARD) then 
			FastSumVectors(dir, dir,entity:GetDirectionVector(1));
		end
		ScaleVectorInPlace(dir,length);
		if(direction == nil) then 
			local prob = random(1,100);
			if(entityAI.lastDodgeDirection==AI_MOVE_RIGHT) then 
				prob= prob + 30;
			elseif(entityAI.lastDodgeDirection==AI_MOVE_LEFT) then 
				prob= prob - 20;
			end
						
			if(prob>50) then 
				direction = AI_MOVE_LEFT;
			else
				direction = AI_MOVE_RIGHT;
			end			
		end		
		if(direction == AI_MOVE_LEFT) then
			NegVector(dir);
		end
		
		local pos = TrVector_v1;
		CopyVector(pos,entity:GetPos());
		local posTo = TrVector_v2;
		FastSumVectors(posTo,pos,dir);
		pos.z = pos.z+1;

		if(AI.CanMoveStraightToPoint(entity.id,posTo)) then
			if(dodgeType==TROOPER_DODGE_SIDE_SHORT and random(1,100)<60) then 
				local posTo2 = TrVector_v3;
				-- you can do the short, try the long one
				FastSumVectors(posTo2,posTo,dir);
				if(AI.CanMoveStraightToPoint(entity.id,posTo2)) then
					posTo = posTo2;
					dodgeType = TROOPER_DODGE_SIDE_LONG;
				end
			end			
			SET_DODGE(entity,posTo,direction,dodgeType,keepmoving);
			return true;
		elseif(dirParam == nil) then -- only if a direction hasn't been explicitly requested
--			NegVector(dir);
--			direction = AI_MOVE_LEFT + AI_MOVE_RIGHT - direction;
--			FastSumVectors(posTo,pos,dir);
--			if(AI.CanMoveStraightToPoint(entity.id,posTo)) then
--				SET_DODGE(entity,posTo,direction,dodgeType,keepmoving);
--				return true;
--			end
			g_SignalData.iValue = AI_MOVE_LEFT + AI_MOVE_RIGHT - direction;
			AI.Signal(SIGNALFILTER_SENDER,AISIGNAL_PROCESS_NEXT_UPDATE,"CHECK_DODGE",entity.id,g_SignalData);
			return true;
		end
	end	
	return false;
end


---------------------------------------------------------
Trooper_CheckAttackChase = function(entity,target)
	local parent = target:GetParent();
	if(parent) then 
		target = parent;
	end
	
	local speed = target:GetSpeed();
	if(target.HasDriver and target:HasDriver() and speed>2 ) then 
		-- fast target (in vehicle maybe)
		g_SignalData.iValue = LAS_ATTACK_CHASE;
		g_SignalData.iValue2 = UPR_COMBAT_GROUND;
		g_SignalData.ObjectName = "attack_surround_chase";
		g_SignalData.fValue = 3; -- predicted position time span
		g_SignalData.point.z = 6; -- min distance of beacon to target
		g_SignalData.point.y = 12; -- update formation threshold (m)
		g_SignalData.point.x = 7; -- min target speed to keep the chase tactic
		AI.Signal(SIGNALFILTER_LEADER,10,"OnKeepEnabled",entity.id);
		AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
		--AI.Signal(SIGNALFILTER_GROUPONLY,1,"GO_TO_CHASE",entity.id);
		return true;
	end
	return false;
end


---------------------------------------------------------
Trooper_ChooseAttack = function(entity)

--	local targetNavType;
--	local navType = AI.GetNavigationType(entity.id);
--	local target = AI.GetAttentionTargetEntity(entity.id)
--	if(target) then 
--		targetNavType = AI.GetNavigationType(target.id);
--	else
--		targetNavType = navType;
--	end
	if(not AI.GetLeader(entity.id)) then 
		-- not important who the leader is associated to here
		AI.SetLeader(entity.id); 
	end
	
--	if(target) then 
--		if(Trooper_CheckAttackChase(entity,target)) then
--			return;
--		end		
--	end
	
	AI.Signal(SIGNALFILTER_LEADER,10,"OnKeepEnabled",entity.id);
	
--	if(entity.Properties.bCorridor ~= 1 and (entity.Properties.bForceOutdoor ~= 0 or not (targetNavType == NAV_WAYPOINT_HUMAN or targetNavType == NAV_WAYPOINT_3DSURFACE) )) then 
		-- use outdoor combat
		-- warning: the following code is relying on the fact that signals are processed in LIFO sequence
		-- (reverse order)
		
		g_SignalData.iValue = 0;
--		if( Trooper_LowHealth(entity)) then 
--			g_SignalData.fValue = TROOPER_SAFE_DISTANCE;
--		else
			g_SignalData.fValue = 6;
--		end
		AI.Signal(SIGNALFILTER_LEADER, 10, "SetDistanceToTarget", entity.id,g_SignalData);

		g_SignalData.fValue = 5;
		AI.Signal(SIGNALFILTER_LEADER, 10, "SetMinDistanceToTarget", entity.id,g_SignalData);
		
		g_SignalData.iValue = LAS_ATTACK_SWITCH_POSITIONS;
		g_SignalData.iValue2 = UPR_COMBAT_GROUND;
		g_SignalData.fValue = 9;
		g_SignalData.ObjectName = "attack_surround1";-- to do, create other surround formations

		AI.Signal(SIGNALFILTER_LEADER, 10, "ORD_ATTACK", entity.id,g_SignalData);

--	else	
--		-- indoor combat
--		local targetType = AI.GetTargetType(entity.id);
--		if(targetType==AITARGET_ENEMY) then 
--			Trooper_StickPlayerAndShoot(entity);
--		else
--			entity:SelectPipe(0,"tr_stick_close");
--			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
--				entity:InsertSubpipe(0,"acquire_target","beacon");
--			end
--		end
--	end
	
end

---------------------------------------------
Trooper_StickPlayerAndShoot = function(entity,defend)
	if(defend) then 
		g_StringTemp1 = "_defend";
	else
		g_StringTemp1 = "";
	end
	AI.GetAttentionTargetPosition( entity.id, g_Vectors.temp );
	local roomSize = AI.GetEnclosingSpace(entity.id,g_Vectors.temp,20,CHECKTYPE_MIN_ROOMSIZE);
	if(roomSize<10) then 
		entity:SelectPipe(0,"tr_stick_close_shooting"..entity.AI.FireMode..g_StringTemp1);
	else
		entity:SelectPipe(0,"tr_stick_shooting"..entity.AI.FireMode..g_StringTemp1);
	end
end

--------------------------------------------------
Trooper_CanRetreat = function(entity)
	g_SignalData.fValue = 20;
	AI.Signal(SIGNALFILTER_LEADER, 10, "SetDistanceToTarget", entity.id,g_SignalData);
	local count = 0;
	local n = AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET);
	for i=1,n do
		local member = AI.GetGroupMember(entity.id,i,GROUP_ENABLED,AIOBJECT_PUPPET);
		if (member.actor:GetHealth()>=200) then
			count = count +1;
		end
	end
	if(count>1) then 
		AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_RETREAT",entity.id);
		return true;
	end
	if(count==0) then
		AI.Signal(SIGNALFILTER_SUPERGROUP,1,"REGROUP",entity.id);
	end
	return false;
end

--------------------------------------------------
Trooper_CanFireMoar = function(entity)
	local currtime = _time;
	if(not AIBlackBoard.lastTimeTrooperFiringMoar) then 
		AIBlackBoard.lastTimeTrooperFiringMoar = currtime - 20;
	end
	if(AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET) <= 2 or
		currtime - AIBlackBoard.lastTimeTrooperFiringMoar > 10) then 
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target and not (target.actorStats and target.actorStats.isFrozen)) then 
			return true;
		end
	end
	return false;
end

---------------------------------------------------------

Trooper_CheckMelee = function(entity,target,timeCheck)
	if(timeCheck == nil) then
		timeCheck = 3;
	end
	local diffz = entity:GetPos().z - target:GetPos().z;
	if(diffz>-1.5 and diffz<1.5) then 
		local curTime = _time;
		--AI.LogEvent("CLOSE CONTACT time = ".._time);
		if(AIBlackBoard.lastTrooperMeleeTime==nil) then 
			AIBlackBoard.lastTrooperMeleeTime = curTime - 4;
		end
		if(curTime - AIBlackBoard.lastTrooperMeleeTime > timeCheck ) then
			if(target.actorStats and target.actorStats.isFrozen) then 
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_MELEE",entity.id);
		  	entity:SelectPipe(0,"tr_try_melee_inplace");
				return true;
			end
			local dir = TrVector_v3;
			FastDifferenceVectors(dir,target:GetPos(),entity:GetPos());
			NormalizeVector(dir);
			if(dotproduct2d(dir,target:GetDirectionVector(1)) < 0 or target ~= g_localActor) then 
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_MELEE",entity.id);
		  	entity:SelectPipe(0,"tr_try_melee_inplace");
				return true;
			else
				-- warning sound for the player "I'm behind you"
				entity:Readibility("taunt",1,100);
--				local sndFlags = bor(SOUND_DEFAULT_3D,SOUND_LOOP);
--				entity:PlaySoundEvent("sounds/alien:trooper:taunt",g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_AI_READABILITY);
			end
		end
	end
	return false;
end

---------------------------------------------------------

Trooper_CloseContactChoice = function(entity,target,timeCheck)
	local randy = random(1,100);
--	if(Trooper_LowHealth(entity)) then 
--		randy = randy+20;
--	end
	if(randy<50) then 
		if(Trooper_CheckMelee(entity,target,timeCheck)) then 
			return true;
		elseif(Trooper_CheckJumpToFormationPoint(entity,8)) then 
			return;
		end
	else
		if(Trooper_CheckJumpToFormationPoint(entity,8)) then 
			return;
		elseif(Trooper_CheckMelee(entity,target,timeCheck)) then 
			return;
		end
	end
	
end


--------------------------------------------------
Trooper_CheckMeleeFinal = function(entity,skipTimeout)
	local target = AI.GetAttentionTargetEntity(entity.id,true);
	if(target) then 
		local diffz = entity:GetPos().z - target:GetPos().z;
		if(diffz>-1.5 and diffz<1.5) then 
			local targetSpeed = target:GetSpeed();
			if(targetSpeed< 1) then 
				if(not skipTimeout) then 
				  AIBlackBoard.lastTrooperMeleeTime = _time;
				  entity:SelectPipe(0,"tr_melee_timeout");
				else
				  entity:SelectPipe(0,"tr_melee");
				end
			  entity:MeleeAttack(target);
			  return true;
			end
			local targetVel = TrVector_v3;
			target:GetVelocity(targetVel);
			ScaleVectorInPlace(targetVel, 1/targetSpeed);--normalize
			local dot = dotproduct3d(targetVel,entity:GetDirectionVector(1));
			if(dot < -0.5) then 
				if(not skipTimeout) then 
				  AIBlackBoard.lastTrooperMeleeTime = _time;
				  entity:SelectPipe(0,"tr_melee_timeout");
				else
				  entity:SelectPipe(0,"tr_melee");
				end
			  entity:MeleeAttack(target);
			  return true;
			end
		end
	end
	return false;
end

--------------------------------------------------
Trooper_CheckJumpToFormationPoint = function(entity,mindist)
--	if(Trooper_IsJumping(entity)) then 
	if(entity.actor:IsFlying()) then 
		return false;
	end
	local dist2;
	if(mindist == nil) then 
		dist2 = 64;
	else
		dist2 = mindist*mindist;
	end
	local formPos = TrVector_v3;
	local dir = TrVector_v1;
	if(AI.GetFormationPointPosition(entity.id,formPos)) then 
		--FastDifferenceVectors(dir,formPos,entity:GetPos());
		if(DistanceSqVectors2d(formPos,entity:GetPos()) >dist2) then 
			if(Trooper_Jump(entity,formPos,true,true)) then
				entity.AI.JumpType = TROOPER_JUMP_SWITCH_POSITION;
				Trooper_SetJumpTimeout(entity);
--					if(entity.AI.JumpFire) then 
--						entity:InsertSubPipe(0,"start_fire");
--					end
				return true;
			end
		end
	end
	return false;
end

--------------------------------------------------
Trooper_CheckJumpMeleeFromHighSpot = function (entity,distance)
	if(distance==nil) then 
		distance = AI.GetAttentionTargetDistance(entity.id);
	end
	if(distance and distance > 7 and distance <16) then 
		if(Trooper_DoubleJumpMelee(entity)) then 
			return true;
		elseif(Trooper_JumpMelee(entity)) then 
			return true;
		end
	end	
	return false;
end

--------------------------------------------------
Trooper_UpdateMoarStats = function( entity)
	if(entity.AI.firingMoar) then 
		AIBlackBoard.lastTimeTrooperFiringMoar = _time;
	end
end

-----------------------------------------------------

Trooper_IsJumping = function(entity)
	local lastJumpTime = entity.AI.lastJumpTime;
	local jumpTime = entity.AI.jumpTime;
	if(lastJumpTime and jumpTime and (_time - lastJumpTime  <jumpTime+1)) then 
		-- he's still jumping
		return true;
	end
	return false;	
end

-----------------------------------------------------
Trooper_DoubleJumpMelee2 = function(entity)
--	if(Trooper_IsJumping(entity)) then 
	if(entity.actor:IsFlying()) then 
		return false;
	end
	local curTime = _time;
	if(AIBlackBoard.lastJumpMeleeTime==nil) then 
		AIBlackBoard.lastJumpMeleeTime = curTime - 6;
	end
	if( curTime - AIBlackBoard.lastJumpMeleeTime > 5) then 
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		if(target) then 
			local velocity = TrVector_v0;
			local pos = TrVector_v1;
			local targetPos = TrVector_v2;
			local dir = TrVector_v3;
			CopyVector(pos, entity:GetPos());
			CopyVector(targetPos, target:GetPos());
			FastDifferenceVectors(dir,targetPos,pos);
			local hDist = math.sqrt(dir.x*dir.x + dir.y*dir.y) ;
			if(hDist<3) then 
				-- too close, no matter where the target is going
				return false;
			end
			-- add some rough target position prediction
			target:GetVelocity(velocity);
			--ScaleVectorInPlace(velocity,1); 
			FastSumVectors(targetPos,targetPos,velocity);
			FastDifferenceVectors(dir,targetPos,pos);
			hDist = math.sqrt(dir.x*dir.x + dir.y*dir.y) ;
			local vDist = dir.z;
			local	minHdist = 5;
			local	maxHdist = 15;
			if(hDist < minHdist or hDist > maxHdist) then
				return false;
			end
			NormalizeVector(dir);			
			if(target == g_localActor) then 
				g_localActor.actor:GetHeadDir(TrVector_v4);
				if(dotproduct3d(dir, TrVector_v4) > -0.5) then 
					-- player is not facing the trooper, jump melee is not worth - trooper wants attention!
					return;
				end
			end 
			-- first vertical jump
			-- compute height
			-- higher jump if the trooper is farther
--			local height = (hDist-minHdist)/(maxHdist - minHdist)*1.5 + vDist + 3;
			local height = hDist/2.5 + vDist;
			--System.Log("JUMP hdist="..hDist.." HEIGHT="..height.. "dir.z="..dir.z);
			if(height < 1.3) then
				return;
			end
			
			targetPos.x = pos.x;
			targetPos.y = pos.y; 
			targetPos.z = pos.z + height;

			local t = AI.CanJumpToPoint(entity.id,targetPos,90,20,AI_JUMP_CHECK_COLLISION,velocity);
			if(t and t>0.1) then 
				-- second horizontal jump
				local entityAI = entity.AI;
				if(not entityAI.jumpVel) then 
					entityAI.jumpVel = {x=0,y=0,z=0};
					entityAI.jumpPos = {};
				end
				local jumpPos = entityAI.jumpPos;
				CopyVector(jumpPos,target:GetPos());
				--target:GetVelocity(jumpPos); -- predict the target position after t seconds
				--ScaleVectorInPlace(jumpPos,t);
				--FastSumVectors(jumpPos,jumpPos,target:GetPos());
				jumpPos.z = jumpPos.z - 0.5;

				local t1 = AI.CanJumpToPoint(entity.id,jumpPos,1,20,AI_JUMP_ON_GROUND + AI_JUMP_CHECK_COLLISION,entityAI.jumpVel,nil, targetPos);
				if(t1 and t1>0.8 and t1<2.1) then 
					entity:SetTimer(TROOPER_JUMP_TIMER,t*1000);
					entityAI.jumpTime = t1;
					entityAI.lastJumpTime = curTime;
					-- vertical jump first
					CopyVector(g_SignalData.point,jumpPos);
					CopyVector(g_SignalData.point2,entity:GetPos());
					g_SignalData.id = target.id;
				 	AI.FreeSignal(1, "STAY_AWAY_FROM", jumpPos, 7, entity.id,g_SignalData);
					entity.actor:SetParams({jumpTo = targetPos, jumpVelocity = velocity, jumpTime = t, jumpStart = true, useAnimEvent = true});
					AIBlackBoard.lastJumpMeleeTime = curTime;
					Trooper_SetJumpTimeout(entity);
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"stop_fire");
					return true;
				end
			end
		end			
	end
	return false;
end

-----------------------------------------------------
Trooper_DoubleJumpMelee = function(entity)
--	if(Trooper_IsJumping(entity)) then 
	if(entity.actor:IsFlying()) then 
		return false;
	end
	local curTime = _time;
	if(AIBlackBoard.lastJumpMeleeTime==nil) then 
		AIBlackBoard.lastJumpMeleeTime = curTime - 6;
	end
	if( curTime - AIBlackBoard.lastJumpMeleeTime > 0) then 
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		if(target) then 
			local velocity = TrVector_v0;
			local pos = TrVector_v1;
			local startPos = TrVector_v2;
			local dir = TrVector_v3;
			local dirN = TrVector_v5;
			
			CopyVector(pos, entity:GetPos());
			CopyVector(startPos, target:GetPos());
			local targetZ = startPos.z;
			
			FastDifferenceVectors(dir,startPos,pos);
			local hDist = math.sqrt(dir.x*dir.x + dir.y*dir.y) ;
--			if(hDist>25) then 
--				-- too far
--				return false;
--			end
			local	minHdist = 5;
			local	maxHdist = 15;
			if(hDist < minHdist or hDist > maxHdist) then
				return false;
			end
			-- add some rough target position prediction
			target:GetVelocity(velocity);
			ScaleVectorInPlace(velocity,0.5); 
			FastSumVectors(startPos,startPos,velocity);
			FastDifferenceVectors(dir,startPos,pos);
			hDist = math.sqrt(dir.x*dir.x + dir.y*dir.y) ;
			local vDist = dir.z;
--			local	minHdist = 5;
--			local	maxHdist = 15;
--			if(hDist < minHdist or hDist > maxHdist) then
--				return false;
--			end
			dir.z = 0;
			NormalizeVector(dir);			
			if(target == g_localActor) then 
				g_localActor.actor:GetHeadDir(TrVector_v4);
				if(dotproduct2d(dir, TrVector_v4) > -0.5) then 
					-- player is not facing the trooper, jump melee is not worth - trooper wants attention!
					return;
				end
			end 
			-- first vertical jump
			-- compute height
			-- higher jump if the trooper is farther
--			local height = (hDist-minHdist)/(maxHdist - minHdist)*1.5 + vDist + 3;
			local	minHdist = 9;
			local	maxHdist = 14;
			if(hDist< minHdist) then
				hDist = minHdist;
			elseif(hDist> maxHdist) then
				hDist = maxHdist;
			end
			
			local height = hDist/2.5;
			if(height < 1.3) then
				return;
			end
			
			CopyVector(dirN,dir);
			
			ScaleVectorInPlace(dir,hDist);
			
			startPos.x = startPos.x - dir.x;
			startPos.y = startPos.y - dir.y; 
			startPos.z = startPos.z + height;
			if (startPos.z > targetZ+4) then
				startPos.z = targetZ+4;
			end
			-- compute angle
			
			FastDifferenceVectors(dir,startPos,pos);
			local module = dir.x*dir.x + dir.y*dir.y ;
			local hMyDist = math.sqrt(module);
		
			if(hMyDist>25) then 
				return false;
			end
		
			local vMyDist = dir.z;
		
			local dist = math.sqrt(module + vMyDist*vMyDist);
		
--			if(dist<5 and hMyDist > dist*0.6) then 
--				return false;
--			end

			local angle;
			if(hMyDist <1) then
				angle = 90;
			else			
				local tang = vDist/hMyDist;
				angle = math.atan(tang)*57.29577;
--				if(angle <-10) then 
--					angle = 10;
--				elseif(angle > 10 and angle <70) then 
--					angle = angle+25;
--				elseif(angle < 10 ) then 
--					angle = angle+20+hDist/2;
				if(angle>60) then 
					angle = angle + 5;
				else
					return false; -- weird first jump angle
				end
			end			
			local angle2 = 1; -- default angle for second jump
			local fromGround = false;
			-- jump at least a little bit vertically to give some warning to the player
			local t = AI.CanJumpToPoint(entity.id,startPos,angle,20,AI_JUMP_CHECK_COLLISION,velocity);
		
			local entityAI = entity.AI;
			if(not entityAI.jumpVel) then 
				entityAI.jumpVel = {x=0,y=0,z=0};
				entityAI.jumpPos = {};
			end
			local jumpPos = entityAI.jumpPos;
			CopyVector(jumpPos,target:GetPos());

			if(not (t and (target==g_localActor and t>0.6 or t>0.2))) then 
				-- if can't jump vertically, try jump from ground
				CopyVector(startPos,entity:GetPos()); -- consider jumping from entity position
				fromGround = true;
				local dist;
				angle2,dist = Trooper_GetJumpAngleDist(entity,jumpPos,0,60);
				if(dist==nil or dist<6 or dist>12) then 
					return false;
				end
				t = 1; -- approximate time to do the start animation
--				t = AI.CanJumpToPoint(entity.id,jumpPos,angle2,20,AI_JUMP_CHECK_COLLISION+AI_JUMP_ON_GROUND,velocity);
			end
	
--			if(t and (target==g_localActor and t>0.6 or t>0.2)) then 
				-- second horizontal jump
				--AI.SetRefPointPosition(entity.id,targetPos);--debug

				--CopyVector(jumpPos,target:GetPos());
				target:GetVelocity(jumpPos); -- predict the target position after t seconds
				ScaleVectorInPlace(jumpPos,t);
				FastSumVectors(jumpPos,jumpPos,target:GetPos());
				
				-- check if target is a vehicle
				--if(AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE) then 
				if(target.vehicle) then 
--					local	hits = Physics.RayWorldIntersection(startPos,dir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
--					if( hits and (hits > 0 )) then
--						CopyVector( jumpPos, g_HitTable[1].pos );
--					end					
					CopyVector(jumpPos,AI.GetRefPointPosition(entity.id));
				else
					target:GetVelocity(jumpPos); -- predict the target position after t seconds
					ScaleVectorInPlace(jumpPos,t);
					FastSumVectors(jumpPos,jumpPos,target:GetPos());
					--FastDifferenceVectors(jumpPos,jumpPos,dirN);
				end
				-- debug
--				AI.SetRefPointPosition(entity.id,jumpPos);
		
				local t1 = AI.CanJumpToPoint(entity.id,jumpPos,angle2,20,AI_JUMP_ON_GROUND + AI_JUMP_CHECK_COLLISION,entityAI.jumpVel,target.id, startPos);
				if(t1 and t1>0.5 and t1<2.1) then 
					entityAI.firstJumpTime = t;
					entityAI.doubleJump = not fromGround;
					entityAI.meleeJumpFromGround = fromGround;
					entityAI.jumpTime = t1;
					entityAI.lastJumpTime = curTime;
					-- vertical jump first
					CopyVector(g_SignalData.point,jumpPos);
					CopyVector(entity.AI.jumpPos,jumpPos);
					CopyVector(g_SignalData.point2,entity:GetPos());
					g_SignalData.id = target.id;
				 	AI.FreeSignal(1, "STAY_AWAY_FROM", jumpPos, 7, entity.id,g_SignalData);
				 	if(fromGround) then 
						--entity.actor:SetParams({jumpTo = startPos, jumpVelocity = velocity, jumpTime = t, jumpStart = true, useAnimEvent = true});
						g_SignalData.iValue = 1; -- avoid dodge in melee behavior
						AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_MELEE",entity.id,g_SignalData);
						entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_jump_melee_ground");
					else
						entity:SetTimer(TROOPER_JUMP_TIMER,t*1000);
						entity.actor:SetParams({jumpTo = startPos, jumpVelocity = velocity, jumpTime = t, jumpStart = true, useAnimEvent = true});
						Trooper_SetJumpTimeout(entity);
						AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK_JUMP",entity.id,g_SignalData);
					end
					AIBlackBoard.lastJumpMeleeTime = curTime;
					entity.AI.JumpType = TROOPER_JUMP_MELEE;

					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"stop_fire");
					return true;
				end
		--	end
		end			
	end
	return false;
end

--------------------------------------
Trooper_JumpMelee = function ( entity)
	local curTime = _time;
	if(AIBlackBoard.lastJumpMeleeTime==nil) then 
		AIBlackBoard.lastJumpMeleeTime = curTime - 6;
	end
	if( curTime - AIBlackBoard.lastJumpMeleeTime > 4) then 
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		if(target) then 
--			local velocity = g_Vectors.temp;
--			local pos = TrVector_v1;
--			local targetPos = TrVector_v2;
--			local dir = TrVector_v3;
--			CopyVector(pos, entity:GetPos());
--			CopyVector(targetPos, target:GetPos());
--			FastDifferenceVectors(dir,targetPos,pos);
--			local hDist = math.sqrt(dir.x*dir.x + dir.y*dir.y);
--			local vDist = dir.z;
--			if(hDist<6 or hDist>11) then 
--				return false;
--			end
--			local tang = vDist/hDist;
--			local angle = math.atan(tang)*57.29577;
--			if(angle <-10) then 
--				angle = 10;
--			elseif(angle <40) then 
--				angle = angle+15;
--			else
--				return false;
--			end
--			local t = AI.CanJumpToPoint(entity.id,targetPos,angle,20,AI_JUMP_ON_GROUND + AI_JUMP_CHECK_COLLISION,velocity);
--			if(t) then 
--				entity.actor:SetParams({jumpTo = targetPos, jumpVelocity = velocity, jumpTime = t});
--				entity:SelectPipe(0,"tr_jump_timeout");
--				--entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_jump_melee");
--				AIBlackBoard.lastJumpMeleeTime = curTime;
--				return true;
--			end
			if(target ==g_localActor and target:GetSpeed() < 1) then 
				-- jump in front of the player and then try the melee after looks silly if player is not moving
				return false;
			end

			local pos = TrVector_v1;
			local targetPos = TrVector_v2;
			local dir = TrVector_v3;
			local velocity = TrVector_v4;
			CopyVector(pos, entity:GetPos());
			CopyVector(targetPos, target:GetPos());
			CopyVector(dir,target:GetDirectionVector(1));
			ScaleVectorInPlace(dir,2);
			FastSumVectors(targetPos,targetPos,dir);
			
			if(Trooper_Jump(entity,targetPos,true,true)) then
				CopyVector(g_SignalData.point,targetPos);
				CopyVector(g_SignalData.point2,pos);
				g_SignalData.id = target.id;
			 	AI.FreeSignal(1, "STAY_AWAY_FROM", targetPos, 7, entity.id,g_SignalData);
				entity.AI.JumpType = TROOPER_JUMP_MELEE;
				Trooper_SetJumpTimeout(entity);
				return true;
			end

		end
	end
	return false;
end


function Trooper_PerformSecondMeleeJump(entity)
	local target = AI.GetAttentionTargetEntity(entity.id);
	if (not entity.actor:IsFlying() or entity.actor:GetHealth()<=0) then
		return
	end
	
	local targetVel = TrVector_v0;
	local targetPos = TrVector_v1;
	local vel = TrVector_v2;
	local t;
	local pos = TrVector_v3;
	local dir = TrVector_v4;
	
	CopyVector(pos,entity:GetPos());
	if(target) then 
		target:GetVelocity(targetVel); 
		CopyVector(targetPos, target:GetPos());
		-- approximate prediction of 1 second
		FastSumVectors(targetPos,targetPos,targetVel);
		FastDifferenceVectors(dir,targetPos,pos);
		dir.z=0;
		NormalizeVector(dir);
		FastSumVectors(targetPos,targetPos,dir);
		
		t = AI.CanJumpToPoint(entity.id,targetPos,1,20,AI_JUMP_ON_GROUND + AI_JUMP_CHECK_COLLISION,vel,target);
	end				
	
	if(t) then 
		CopyVector(dir,entity:GetDirectionVector(1));
		FastDifferenceVectors(pos,pos,dir);
		pos.z = pos.z + 2;
		Particle.SpawnEffect("alien_special.Trooper.doubleJumpAttack", pos, dir, 0.5);
    --self:PlaySoundEvent("Sounds/alien:trooper:jump_burst",g_Vectors.v000, dir, SOUND_DEFAULT_3D, SOUND_SEMANTIC_LIVING_ENTITY);
		entity.actor:SetParams({jumpTo = targetPos, jumpVelocity = vel, jumpTime = t});
		AI.SetRefPointPosition(entity.id,targetPos);
	else
		local entityAI = entity.AI;
		entity.actor:SetParams({jumpTo = entityAI.jumpPos, jumpVelocity = entityAI.jumpVel, jumpTime = entityAI.jumpTime});
	end			
	
	if(target) then 
		--self:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_jump_melee");
		entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_jump_melee");
	end

end

---------------------------------------------

Trooper_JumpFire = function(entity,dist)
--	if(Trooper_IsJumping(entity)) then 
	if(entity.actor:IsFlying()) then 
		return false;
	end
	
	local target = AI.GetAttentionTargetEntity(entity.id,true);
	if(target) then 
		if(dist >7 and dist <20) then 
			local targetXdir = TrVector_v0;
			local dir = TrVector_v1;
			local targetPos = TrVector_v2;
			local targetYdir = TrVector_v3;
			CopyVector(targetPos, target:GetPos());
			CopyVector(targetXdir, target:GetDirectionVector(0));
			CopyVector(targetYdir, target:GetDirectionVector(1));
			FastDifferenceVectors(dir,targetPos,entity:GetPos());
			--NormalizeVector(dir);
			ScaleVectorInPlace(dir,1/dist); -- normalize
			local entityAI = entity.AI;

			local dot = dotproduct3d(dir,targetXdir);
			if(dot < -0.2) then 
				NegVector(targetXdir);
				entity.AI.jumpPipe = "tr_jump_fire_right";
			elseif(dot > 0.2) then 
				entity.AI.jumpPipe = "tr_jump_fire_left";
			else
				return false;
			end
			ScaleVectorInPlace(targetXdir,3+random(1,4)/2);
			ScaleVectorInPlace(targetYdir,4+random(1,2)/2);
			FastSumVectors(targetPos,targetPos,targetXdir);
			FastSumVectors(targetPos,targetPos,targetYdir);
			--FastDifferenceVector(dir,targetPos,entity:GetPos());
			AI.SetRefPointPosition(entity.id,targetPos);
			if(not entityAI.targetPos ) then 
				entityAI.targetPos = {x=0,y=0,z=0};
			end
			CopyVector(entityAI.targetPos, targetPos);
			entity:SelectPipe(0,"tr_try_jump_fire");
			return true;
		end				
	end
	return false;
end

Trooper_Search = function(entity,pos)
	if(pos) then 
		CopyVector(g_SignalData.point,pos);
	else
		g_SignalData.point.x = 0;
		g_SignalData.point.y = 0;
		g_SignalData.point.z = 0;
	end
	g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
	g_SignalData.iValue2 = AIAnchorTable.SEARCH_SPOT;
	g_SignalData.fValue = 20; --search distance
	AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
end

--------------------------------------------------
Trooper_ChooseNextTactic = function(entity,data, bFailed)
	-- data.iValue = Leader action type
	-- data.iValue2 = Leader action subtype
	-- data.id = group's live attention target 
	-- data.ObjectName = group's attention target name
	-- data.fValue = target distance
	-- data.point = average enemy position
	local actionSubType = data.iValue2 ;
	--System.Log("CHOOSING NEXT TACTIC - old tactic="..actionSubType.." failed = "..tostring(bFailed));
	local currentTime =  System.GetCurrTime();
	local targetDistance = data.fValue;
	local target = System.GetEntity(data.id);
	local bFrozenTarget = false;
	if(target and target.actor) then
		bFrozenTarget = target.actorStats ~= nil and target.actorStats.isFrozen;
	end
	
	if(data.iValue == LA_ATTACK and actionSubType==LAS_ATTACK_USE_SPOTS) then
		AI.Signal(SIGNALFILTER_SUPERGROUP,0,"GO_TO_IDLE",entity.id);
		return;
	end
	if(data.id ==NULL_ENTITY) then
		if(data.iValue == LA_SEARCH) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_IDLE",entity.id);
			--System.Log("NEXT TACTIC SEARCH->IDLE");
		elseif(data.iValue == LA_ATTACK) then
			Trooper_Search(entity);
		else
			--System.Log("NO ATTACK NO SEARCH "..data.iValue);
				
		end
	else
		Trooper_ChooseAttack(entity);
--			local enemyPos = data.point;
--			local enemyMovement = g_Vectors.temp;
--			CopyVector(entity.AI.EnemyAvgPos,enemyPos);
--			FastDifferenceVectors(enemyMovement,entity.AI.EnemyAvgPos,enemyPos);
--			local enemyDisp = LengthVector(enemyMovement);
--			--System.Log("Enemy movement = "..Vec2Str(enemyMovement).." = "..enemyDisp.." meters");
--			if(actionSubType == LAS_ATTACK_ROW) then 
--				if(bFailed) then 
--					local navType = AI.GetNavigationType(AI.GetGroupOf(entity.id),UPR_COMBAT_GROUND);
--					if(navType == NAV_WAYPOINT_HUMAN) then 
--						g_SignalData.iValue = LAS_ATTACK_CHAIN;
--						AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--						--System.Log("NEXT TACTIC = ROW (failed)->CHAIN");
--						return;
--					else
--						-- TO DO: new tactic for outdoor?
--						AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_LEAPFROG,20);
--						--System.Log("NEXT TACTIC = ROW (failed)->LEAP FROG");
--						return;
--					end					
--				end
--				if(enemyDisp<5) then 
--					local prob = math.random(100);
--					--System.Log("PROBABILITY = "..prob);
--					if(false) then --prob > 30 and currentTime - entity.AI.StartTime>15) then --TEMP remove "false"
--						if(true) then-- not bFrozenTarget and prob > 60) then --TEMP remove "true"
--							g_SignalData.iValue = LAS_ATTACK_COORDINATED_FIRE1;
--							g_SignalData.id = data.id;
--							g_SignalData.iValue2 = UPR_COMBAT_GROUND;
--							AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--							entity.AI.StartTime = currentTime;--TEMP - remove
--							--System.Log("NEXT TACTIC = ROW->COORDINATED FIRE 1");
--						else
--							g_SignalData.iValue = LAS_ATTACK_COORDINATED_FIRE2;
--							g_SignalData.id = data.id;
--							g_SignalData.iValue2 = UPR_COMBAT_GROUND;
--							AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--						--	entity.AI.StartTime = currentTime;
--							--System.Log("NEXT TACTIC = ROW->COORDINATED FIRE 2");
--						end						
--					else
--						if(IsNotNullVector(entity.AI.DefensePoint))  then 
--							-- repeat attack row if there's a point to defend
--							AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,5,entity.AI.DefensePoint);
--							
--							--System.Log("NEXT TACTIC = ROW->ROW (defense)");
--						else
--							g_SignalData.iValue = LAS_ATTACK_FLANK;
--							g_SignalData.fValue = targetDistance;
--							g_SignalData.iValue2 = UPR_COMBAT_GROUND;
--							AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--						--System.Log("NEXT TACTIC = ROW->FLANK");
--						end
--					end
--				else
--					local duration;
----					if(not IsNullVector(entity.AI.DefensePoint)) then
----						duration = random(2,3);
----					else
--						duration = random(5,6);
----					end
--					AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,duration,entity.AI.DefensePoint);
--					--System.Log("NEXT TACTIC = ROW->ROW");
--				end
--			elseif(actionSubType == LAS_ATTACK_FLANK) then
--				local prob = math.random(100);
--				--System.Log("PROBABILITY = "..prob);
--				if(false) then -- prob > 30 and currentTime - entity.AI.StartTime>15) then --TEMP remove "false"
--					if(true ) then -- not bFrozenTarget and prob > 60) then --TEMP remove "true"
--						g_SignalData.iValue = LAS_ATTACK_COORDINATED_FIRE1;
--						g_SignalData.id = data.id;
--						g_SignalData.iValue2 = UPR_COMBAT_GROUND;
--						AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--						entity.AI.StartTime = currentTime;--TEMP remove it
--						--System.Log("NEXT TACTIC = FLANK(failed)->COORDINATED FIRE 1");
--					else
--						g_SignalData.iValue = LAS_ATTACK_COORDINATED_FIRE2;
--						g_SignalData.id = data.id;
--						g_SignalData.iValue2 = UPR_COMBAT_GROUND;
--						AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--					--	entity.AI.StartTime = currentTime;
--						--System.Log("NEXT TACTIC = FLANK(failed)->COORDINATED FIRE 2");
--					end						
--				else
--					if(bFailed) then 
--						duration = random(5,6);
--						AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,duration,entity.AI.DefensePoint);
--						--System.Log("NEXT TACTIC = FLANK(failed)->ROW");
--					else
--						if(targetDistance <30) then 
--							local duration;
--		--					if(not IsNullVector(entity.AI.DefensePoint)) then
--		--						duration = random(2,3);
--		--					else
--								duration = random(5,6);
--		--					end
--							AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,duration,entity.AI.DefensePoint);
--							--System.Log("NEXT TACTIC = FLANK->ROW");
--						else
--							AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_LEAPFROG,20);
--							--System.Log("NEXT TACTIC = FLANK->LEAP FROG");
--						end
--					end
--				end
--			elseif(actionSubType == LAS_ATTACK_COORDINATED_FIRE1 or actionSubType == LAS_ATTACK_COORDINATED_FIRE2) then 
--				if(bFailed) then 
--						g_SignalData.iValue = LAS_ATTACK_FLANK;
--						g_SignalData.fValue = targetDistance;
--						g_SignalData.iValue2 = UPR_COMBAT_GROUND;
--						AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
--						--System.Log("NEXT TACTIC = COORDINATED_FIRE1 (failed)->FLANK");
--				else
--					duration = random(5,6);
--					AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,duration,entity.AI.DefensePoint);
--				end
--			elseif(actionSubType == LAS_ATTACK_LEAPFROG) then
--				local duration;
----				if(not IsNullVector(entity.AI.DefensePoint)) then
----					duration = random(2,3);
----				else
--					duration = random(5,6);
----				end
--				AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,duration,entity.AI.DefensePoint);
--				--System.Log("NEXT TACTIC = LEAP FROG->ROW");
--			else
--				--System.Log("NEXT TACTIC ="..actionSubType.." -> ?");
--			end
	end
end

function Trooper_SetAccuracy(entity,acc)
	-- TO DO: use the proper parameter (aggression?)
	if(acc) then 
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange * acc);
	else
		-- restore value
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange );
	end
end

function Trooper_LowHealth(entity)
--	if(entity.actor:GetHealth()<200) then 
--		return true;
--	end
	return false;
end

---------------------------------------------	
function Trooper_ReevaluateShooterTarget(entity,shooter)
	-- evaluate if trooper should acquire the shooter as target
--		AI.LogEvent(entity:GetName().." REEVALUATING TARGET ");
	local	target = AI.GetAttentionTargetEntity(entity.id,true);
	if(shooter and target and target ~= shooter ) then 
		local distance = entity:GetDistance(shooter.id);
		local probability;
		if(distance<25) then 
			if(AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then 
				probability = 100;
			elseif(shooter == entity.AI.LastEnemyDamaging) then 
				probability = 100;
			else	
				probability = 50-distance*2;
				if(shooter == g_localActor) then 
					probability = probability+70;
				else
					probability = probability+40;
				end
			end			
			--AI.LogEvent(entity:GetName().." probability = "..probability);
			if(random(1,100) <= probability ) then 
--					AI.LogEvent(entity:GetName().." ACQUIRING TARGET "..shooter:GetName());
				return true;
			end
		end
		entity.AI.LastEnemyDamaging = shooter;
--		elseif(shooter==nil) then 
--			AI.LogEvent(entity:GetName().." NULL SHOOTER ");
	end
	return false;
end

---------------------------------------------	
function Trooper_SetConversation(entity,reset,delay)
	if(entity.cloaked~= 1 and AIBlackBoard.trooper_ConversationState ~= TROOPER_CONV_REQUESTING) then
		local numMembers = AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET);
		if(numMembers==1 ) then
			if(not delay) then 
				delay = random(5000,7000);
			end
			AIBlackBoard.trooper_ConversationState = TROOPER_CONV_REQUESTING;
			entity:SetTimer(TROOPER_CONVERSATION_REQUEST_TIMER,delay);
			--entity:SetTimer(TROOPER_CONVERSATION_CHECK_TIMER,delay+1500);
		else
			local dist = entity:GetDistance(g_localActor.id);
			if(dist and (dist >5  and dist<25)) then 
				if(not delay) then 
					delay = random(2000,3500);
				end
				AIBlackBoard.trooper_ConversationState = TROOPER_CONV_REQUESTING;
				entity:SetTimer(TROOPER_CONVERSATION_REQUEST_TIMER,delay);
				entity:SetTimer(TROOPER_CONVERSATION_CHECK_TIMER,delay+1500);
			end
		end
	end
end


--------------------------------------------------
Trooper_Death = function ( entity, autoDestructing)

	AI.LogEvent( ">>>> OnDeath "..entity:GetName() );

	-- tell your friends that you died anyway regardless of wheteher someone goes for reinforcement
	g_SignalData.id = entity.id;
	if (AI.GetGroupCount(entity.id) > 1) then
		-- tell your nearest that someone you have died only if you were not the only one
		AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "OnGroupMemberDiedNearest",entity.id,g_SignalData); 
	else
		-- tell anyone that you have been killed, even outside your group
		AI.Signal(SIGNALFILTER_ANYONEINCOMM, 1, "OnSomebodyDied",entity.id, g_SignalData);
	end
	
--	if(autoDestructing) then 
--		CopyVector(g_SignalData.point,entity:GetWorldPos());
--		g_SignalData.iValue = entity.AutoDestructionTime+1000;
--		g_SignalData.fValue = entity.Properties.Explosion.Radius+2;
--		AI.Signal(SIGNALFILTER_LEADER,10,"AddDangerPoint",entity.id,g_SignalData);
--	end
	
	if(entity:GetName() and AIBlackBoard.Trooper_SpecialActionTarget) then 
		AIBlackBoard.Trooper_SpecialActionTarget[entity:GetName()] = nil;
	end
		
end

--------------------------------------------------
Trooper_MoveAway = function ( entity,data)
	local target = AI.GetAttentionTargetEntity(entity.id,true);
	local velocity = TrVector_v3;
	entity:GetVelocity(velocity);
	local dir = TrVector_v1;
	FastDifferenceVectors(dir,data.point,entity:GetPos());
	if(dotproduct2d(dir,velocity)>0) then
		local dirJump = TrVector_v2;
		NormalizeVector(dir);
		FastDifferenceVectors(dirJump,data.point,data.point2);
		NormalizeVector(dirJump);
		local crossProductZ = dirJump.x * dir.y - dirJump.y * dir.x;
		if(crossProductZ <0) then 
			-- left
			if(Trooper_Dodge(entity,0,AI_MOVE_LEFT)) then 
				return;
			end
		else
			-- right
			if(Trooper_Dodge(entity,0,AI_MOVE_RIGHT)) then 
				return;
			end
		end
		ScaleVectorInPlace(dirJump,-3);
		FastSumVectors(dir,dirJump,entity:GetPos());
		if(not Trooper_Jump(entity,dir,true,true,30)) then 
			ScaleVectorInPlace(dirJump,2);
			FastSumVectors(dir,dirJump,entity:GetPos());
			Trooper_Jump(entity,dir,true,true,0);
		end
	end
end

--------------------------------------------------
Trooper_GoToThreatened = function ( entity,point,shooterId)
	if(entity.Properties.Perception.sightrange > 0) then
		local target  = AI.GetAttentionTargetEntity(entity.id,true);
		if(target and shooterId == target.id) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
			CopyVector(g_SignalData.point, point);
			g_SignalData.id = shooterId;
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,0,"GO_TO_THREATENED",entity.id,g_SignalData);
		else--if(AI.GetLeader(entity.id)) then
			local shooter;
			if(shooterId) then 
				shooter = System.GetEntity(shooterId);
			end
			if(shooter) then 
				--if shooterId is passed, it means that it's been damaged
				local pos = g_SignalData.point;
		
				FastSumVectors(pos,entity:GetPos(),shooter:GetWorldPos());
				ScaleVectorInPlace(pos,0.5);
				g_SignalData.id = shooterId;
			else
				CopyVector(g_SignalData.point, point);
				g_SignalData.id = NULL_ENTITY;
			end
	
			AI.Signal(SIGNALFILTER_GROUPONLY,0,"GO_TO_THREATENED",entity.id,g_SignalData);
		end
	end		

end


--------------------------------------------------
Trooper_IsThreateningBullet = function ( entity,point)
	local pos = entity:GetPos();
	if(point.z - pos.z <0.3  ) then 
		return false;
	end
	TrVector_v0, TrVector_v1 = entity:GetLocalBBox();
	FastSumVectors(TrVector_v0,TrVector_v0,TrVector_v1);
	ScaleVectorInPlace(TrVector_v0,0.5);
	FastSumVectors(TrVector_v0,TrVector_v0,pos);
	local dist2 = DistanceSqVectors(TrVector_v0,point);
	if(dist2<0.4) then
		return true;
	end
	return false;
end

--------------------------------------------------
Trooper_CheckTargetOnVehicle = function ( entity,target)
	if(target==nil) then 
		target = AI.GetAttentionTargetEntity(entity.id);
		if(target==nil) then 
			return false;
		end
	end

	local parent = target:GetParent();
	while (parent) do
		target = parent;
		parent = parent:GetParent();
	end
	
	if(AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
				
	end
end


---------------------------------------------------------
-- test function
---------------------------------------------------------

function TrJump(angle,inAir)
	local trooper = System.GetEntityByName("T");
	local target = System.GetEntityByName("P");
	local velocity = TrVector_v0;
	local targetPos = TrVector_v1;
	if(trooper and target) then 
		CopyVector(targetPos,target:GetPos());
		local filter = AI_JUMP_CHECK_COLLISION;
		if(not inAir) then 
			filter = filter + AI_JUMP_ON_GROUND;
		end
		local t = AI.CanJumpToPoint(trooper.id,targetPos,angle,88, filter,velocity);
		if(t) then 
			trooper.actor:SetParams({jumpTo = targetPos, jumpVelocity = velocity, jumpTime = t, jumpStart = true, jumpLand = true});
		end
--		trooper:Jump(targetPos,true,true,0);
		AI.LogEvent(trooper:GetName().." Jump Time to reach: "..tostring(t));
	else
		AI.LogEvent("JUMP: Wrong entity names");
	end
end

function TrJump2()
	local trooper = System.GetEntityByName("T");
	local target = System.GetEntityByName("P");
	local velocity = TrVector_v0;
	local targetPos = TrVector_v1;
	if(trooper and target) then 
		CopyVector(targetPos,target:GetPos());
		Trooper_Jump(trooper,targetPos,true,true);
	else
		AI.LogEvent("JUMP: Wrong entity names");
	end
end


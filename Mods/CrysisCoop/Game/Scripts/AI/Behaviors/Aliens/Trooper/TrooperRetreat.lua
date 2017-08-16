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
AIBehaviour.TrooperRetreat = {
	Name = "TrooperRetreat",
	Base = "Dumb",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		AI.ModifySmartObjectStates(entity.id,"StayOnGround");
		local targetPos = g_Vectors.temp;
		local dir = g_Vectors.temp_v1;
		local length = 0;
		if(AI.GetAttentionTargetPosition(entity.id,targetPos)) then
			FastDifferenceVectors(dir,entity:GetPos(),targetPos);
			dir.z = 0;
			length = LengthVector(dir);
		end
		if(length<0.2) then
			if(length == 0) then 
				CopyVector(targetPos,entity:GetPos());
			end
			CopyVector(dir,entity:GetDirectionVector(1));
			NegVector(dir);
			length=1;
		end
		ScaleVectorInPlace(dir,10/length);
		FastSumVectors(targetPos,targetPos,dir);
		AI.SetRefPointPosition(entity.id,targetPos);
		if(Trooper_Jump(entity,targetPos,true,true,-10)) then 
			Trooper_SetJumpTimeout(entity);
		else
			entity:SelectPipe(0,"tr_retreat");
		end
	end,
	
	--------------------------------------------------
	OnEnemyDamage = function(self,entity,sender,data)
	end,
	--------------------------------------------------
	OnBulletRain = function(self,entity,sender,data)
	end,
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,

	--------------------------------------------------
	OnNearMiss = function(self,entity,sender,data)
	end,
	
	--------------------------------------------------
	OnPlayerLooking = function(self,entity,sender)
	end,
	--------------------------------------------------
	OnPlayerSeen = function(self,entity,sender)
	end,
	--------------------------------------------------
	OnEnemyMemory = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnPlayerFrozen = function (self,entity,sender)
	end,
	
	--------------------------------------------------
	OnCloseContact = function(self,entity,target)
		
		if(Trooper_CheckMelee(entity,target,3)) then 
			return;
		end
		
	end,

	--------------------------------------------------
	JUMP_ON_ROCK = function(self,entity,sender,data)
		AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,
	
	--------------------------------------------------
	JUMP_ON_WALL = function(self,entity,sender,data)
		AI.ModifySmartObjectStates(data.id,"-Busy");				
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
		entity:SelectPipe(0,"tr_retreat");
	end,

	--------------------------------------------------
	MELEE_FAILED = function (self,entity,sender)
		entity:SelectPipe(0,"tr_retreat");
	end,
	
	--------------------------------------------------
	END_MELEE = function (self,entity,sender)
		entity:SelectPipe(0,"tr_retreat");
	end,
	
	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_retreat");
--		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_RETREAT",entity.id);
	end,

	OnLand	 = function( self, entity, sender)
		entity:SelectPipe(0,"tr_hide_nearby");
	end,
	
	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,

	---------------------------------------------
	REQUEST_CONVERSATION = function(self,entity,sender)
	end,

}

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Defend behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAttackMelee = {
	Name = "TrooperAttackMelee",
	Base = "TrooperAttack",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
		entity:SelectPipe(0,"tr_prepare_melee");
	end,

--	END_STICK_VERY_CLOSE = function(self,entity,sender)
--		local dist = AI.GetAttentionTargetDistance(entity.id);
--		if(dist>3) then 
--			entity:SelectPipe(0,"tr_just_shoot");
--		else
--			entity.AI.lastMeleeTime = curTime;
--			entity:MeleeAttack(AI.GetAttentionTargetEntity(entity.id));
--			entity:SelectPipe(0,"tr_melee_timeout");
--		end
--	end,
	
	END_MELEE = function(self,entity,sender)
		if(random(1,100) <50) then 
			entity:SelectPipe(0,"tr_melee_backoff");
		end
	end,



--	END_STICK_VERY_CLOSE = function(self,entity,sender)
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then
--			if(AI.GetAttentionTargetDistance(entity.id)<2) then
--				local vel = g_Vectors.temp;
--				target:GetVelocity(vel);
--				local speed = target:GetSpeed();
--				System.Log("----------------------------------------SPEED:"..speed);
--				if(speed > 2) then
--					local y = dotproduct2d( entity:GetDirectionVector(1), vel);
--					--System.Log("----------------------------------------DOT:"..y);
--					--do nothing if the target is moving away
--					if(y>0) then 
--						return;
--					end
--				end
--				local y = dotproduct2d( entity:GetDirectionVector(1), target:GetDirectionVector(1));
--					--System.Log("----------------------------------------DOT:"..y);
--				if(y>0) then 
--					return;
--				end
--					
--				entity.AI.lastMeleeTime = curTime;
--				entity:MeleeAttack(target);
--				entity:SelectPipe(0,"do_nothing");
--				entity:SelectPipe(0,"tr_melee_timeout");
--			else
--				entity:SelectPipe(0,"tr_prepare_melee");
--			end
--		end
--	end,
		
	OnCloseContact = function(self,entity,sender)
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then
			entity.AI.meleeTarget = target;
			local vel = g_Vectors.temp;
			target:GetVelocity(vel);
			local speed = target:GetSpeed();
			if(speed > 1) then
				local y = dotproduct2d( entity:GetDirectionVector(1), vel);
				if(y>=0) then 
					return;
				end
			end
			entity.AI.lastMeleeTime = curTime;
--			entity:MeleeAttack(target);
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"tr_melee_timeout");
			--entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_do_melee");
			AI.Animation(entity.id,AIANIM_SIGNAL,"meleeAttack");
			-- Crysis Co-op
			entity.actor:PlayNetworkedAnimation(entity.id, AIANIM_SIGNAL, "meleeAttack");
			-- ~Crysis Co-op
		end
	end,
	
	OnBulletRain = function(self,entity,sender)
	
	end,
	
	OnPlayerSeen = function(self,entity,sender)
		entity:SelectPipe(0,"tr_prepare_melee");
	end,
	
	END_MELEE_BACKOFF = function(self,entity,sender)
		entity:SelectPipe(0,"tr_prepare_melee");
	end,
	
	TR_NORMALATTACK = function(self,entity,sender)
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
			entity:SelectPipe(0,"tr_prepare_melee");
		else
			entity:SelectPipe(0,"tr_seek_target");
		end
	end,
}
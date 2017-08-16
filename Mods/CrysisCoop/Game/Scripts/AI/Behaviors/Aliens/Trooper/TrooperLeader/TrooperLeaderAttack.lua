--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Attack behavior for Alien Trooper Leader
--  
--------------------------------------------------------------------------
--  History:
--	- Feb 2006		: Created by Luciano Morpurgo
--------------------------------------------------------------------------
AIBehaviour.TrooperLeaderAttack = {
	Name = "TrooperLeaderAttack",
	Base = "TrooperGroupCombat",
	alertness = 2,
	---------------------------------------------
	Constructor = function(self , entity,data )
		-- data.iValue = attack sub action type
		--CopyVector(entity.AI.EnemyAvgPos,data.point);
--		--System.Log("Initial avg enemy pos = "..Vec2Str(entity.AI.EnemyAvgPos));
		--entity:SelectPipe(0,"coord_hide_from","beacon");
		AI.GetBeaconPosition(entity.id,entity.AI.EnemyAvgPos);
		AIBehaviour.TrooperGroupCombat:Constructor(entity,data);
		
	end,
	
	OnEnemySeenByUnit = function(self,entity,sender,data)
		-- sent by a team member
		-- data.fValue = distance to seen enemy
		-- data.id = enemy's entity id
		----System.Log(");
	end,
	
	OnAttackRowTimeOut = function(self,entity,sender,data)
		-- sent by leader
		-- data.point = average enemy pos
		-- data.fValue = group's distance from average enemy pos
		-- data.iValue = group ground units count
		-- data.id = enemy's entity id (if there is)
		-- data.ObjectName = enemy name (if there is)
		--System.Log("-------------Attack Row timeout");
--		if(data.id ~= NULL_ENTITY) then 
--			AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_LEAPFROG,20);
--		end
			
	--		self:ChooseNextTactic(entity,data);
	end,

	OnAttackFlankTimeOut = function(self,entity,sender,data)
		-- sent by leader
		-- data.point = average enemy pos
		-- data.fValue = group's distance from average enemy pos
		-- data.iValue = group ground units count
		-- data.id = enemy's entity id (if there is)
		-- data.ObjectName = enemy name (if there is)
--		self:ChooseNextTactic(entity,data);
		
	end,
	
	ORDER_ATTACK_FORMATION = function(self,entity,sender)
		-- ignore this order
		AI.Signal(SIGNALFILTER_LEADER, 10, "ORD_DONE", entity.id);
		
	end,
	

	-----------------------------------------------------------
	OnUnitDamaged = function(self,entity,sender,data)
	
	end,


	-----------------------------------------------------------
}
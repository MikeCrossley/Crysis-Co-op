--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: scout stays there and fires/melee at anyone
--  derived from a cxp hack, it's probably not going to be final
--------------------------------------------------------------------------
--  History:
--  - 23/09/2005   : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.ScoutDumbAttack = {
	Name = "ScoutDumbAttack",

	---------------------------------------------
	Constructor = function(self , entity )

		-- Create attack reference counters.	

--		self:SC_CHOOSE_ATTACK_ACTION( entity );
	end,

	---------------------------------------------
	Destructor = function(self , entity )
	
		-- Make sure the automatic movement gets reset when leaving this behavior.
		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
		-- Make sure the moac stops when leaving the behavior.
		entity:StopEvent("all");
		entity:PushEvent("shield_up");

		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);

		-- Handle leaving entity, decrease references.
	end,


	---------------------------------------------
	SC_MELEE = function( self, entity )
--		local attackPos = g_Vectors.temp_v2;
--		local diff = g_Vectors.temp_v3;
--		local entPos = entity:GetPos();
--
--		local enemy = System.GetEntityByName(entity.AI.targetName);
--		if( not enemy ) then
--			-- Fail the melee.
--			self:SC_MELEE_DONE( entity );
--			return;
--		end
--		
--		local	enemyPos = enemy:GetPos();
--
--		SubVectors( diff, entPos, enemyPos );
--		local targetDist = LengthVector( diff );
--
--		if( targetDist < 20 ) then
--			-- Make sure we are near enough to do the melee.
--			local mult = 11 / targetDist;
--			attackPos.x = enemyPos.x + diff.x * mult;
--			attackPos.y = enemyPos.y + diff.y * mult;
--			attackPos.z = enemyPos.z + 7.8;
--
--			enemyPos.z = enemyPos.z + 7;
--
--			entity.actor:SetMovementTarget(attackPos,enemyPos,{x=0,y=0,z=0},1);
--
--			entity:MeleeAttack();
--
--			entity:SelectPipe(0,"sc_attack_melee_delay");
--		else
--			-- Fail the melee.
--			self:SC_MELEE_DONE( entity );
--		end
	end,

	---------------------------------------------
	SC_MELEE_DONE = function( self, entity )

		-- Remove references.
	end,

	---------------------------------------------
	SC_FIRE = function( self, entity )
		entity:BlendAnimation(50);
		entity:DoShootWeapon();
	end,
	
	---------------------------------------------
	SC_FIRE_DONE = function( self, entity )
--		self:Relocate( entity );

		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);

		-- Remove references.
--		self.AI_aggressorCount = self.AI_aggressorCount - 1;
--		entity.AI.attackMode = -1;
--
		-- Forget the enemy (use OnEnemySeen to acquire it again).
		entity.AI.targetName = nil;
	end,


	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
		
--		entity.AI.lastSeenName = entity:GetName();
		entity.AI.lastSeenName = AI.GetAttentionTargetOf(entity.id);
--		self:SC_CHOOSE_ATTACK_ACTION( entity );
		entity:SelectPipe(0,"sc_attack_rapid_fire");
	end,

	---------------------------------------------
	OnCloseContact = function( self, entity, fDistance )
		AI.SetRefPointPosition( entity.id, entity:GetPos() );
		AI.SetRefPointDirection( entity.id, {x=0,y=0,z=0} );
	
		-- Melee attack the enemy (attentionTarget).
		entity:SelectPipe(0,"sc_attack_melee", entity.AI.targetName);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
		entity.AI.lastSeenName = nil;
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged

--		if( entity.AI.attackDamageAcc > 400 ) then
--			AI.Signal( SIGNALFILTER_SENDER, 1, "GO_RECOIL", entity.id);
--			entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
--		end
	end,
	
	---------------------------------------------
}

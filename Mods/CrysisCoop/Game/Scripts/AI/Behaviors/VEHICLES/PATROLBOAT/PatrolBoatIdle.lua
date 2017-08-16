--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: boat Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 11/07/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------

AIBehaviour.PatrolBoatIdle = {
	Name = "PatrolBoatIdle",
	Base = "VehicleIdle",

	---------------------------------------------
	Constructor = function(self , entity )

		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.BOAT);		

		entity.AI.vDefultPos = {};
		CopyVector ( entity.AI.vDefultPos, entity:GetPos() );

		entity.AI.bGotShoot = false;
		entity.AI.GetShootId = nil;

		entity.AI.vZero = { x=0.0, y=0.0, z=0.0 };
		entity.AI.vUp   = { x=0.0, y=0.0, z=1.0 };
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );

		AIBehaviour.VehicleIdle:Constructor( entity );

	end,

	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	

		self:OnEnemyDamage( entity, sender, data );
		
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		local targetEntity
		if ( data and data.id ) then
			targetEntity = System.GetEntity( data.id );
			entity.AI.bGotShoot = true;
			entity.AI.GotShootId = targetEntity.id;
		end
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_PATROLBOAT_ATTACK", entity.id);

	end,

	---------------------------------------------
	-- to give a pathname for the pathfollow
	PATROLBOAT_PATHNAME_MAIN = function( self, entity, sender, data )

		if ( data and  data.ObjectName ) then
			entity.AI.patrollBoatPathNameMain =  data.ObjectName;
			entity.AI.patrollBoatPathName = entity.AI.patrollBoatPathNameMain;
		end

	end,

	---------------------------------------------
	-- to give a pathname for the pathfollow
	PATROLBOAT_PATHNAME_SUB = function( self, entity, sender, data )

		if ( data and  data.ObjectName ) then
			entity.AI.patrollBoatPathNameSub =  data.ObjectName;
		end

	end,

}
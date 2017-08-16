--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: simple behaviour for testing 3d navigation
--  
--------------------------------------------------------------------------
--  History:
--  - 09/05/2005   : Created by Mikko Mononen
--
--------------------------------------------------------------------------


AIBehaviour.HunterPatrol = {
	Name = "HunterPatrol",

	---------------------------------------------
	Constructor = function(self,entity )
		AI.ModifySmartObjectStates( entity.id, "Idle" );
		entity.AI.PathStep = 0;
		AI.Signal( SIGNALFILTER_SENDER, 1, "HT_NEXT_POINT",entity.id);
	end,

	Destructor = function( self, entity )
		AI.ModifySmartObjectStates( entity.id, "-Idle" );
	end,
	
	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

--		entity:DoPlayerSeen();
--		entity:SelectPipe(0,"ht_player_seen_delay_attack");
		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if( entity.isFlying == true ) then
			entity:SelectPipe(0,"ht_patrol_land");
		else
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
		end
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		self:OnPlayerSeen(entity, fDistance);
	end,
	
	--------------------------------------------
	HT_NEXT_POINT = function( self,entity, sender )	
	
		local name = entity:GetName();
		local tpname = name.."_P0";	

		local TagPoint = System.GetEntityByName(name.."_P"..entity.AI.PathStep);
		if (TagPoint) then 		
			tpname = name.."_P"..entity.AI.PathStep;
		else
			if (entity.AI.PathStep == 0) then 
				AI.Warning(" Entity "..name.." has a path job but no specified path points.");
				do return end
			end
			entity.AI.PathStep = 0;
		end

		entity:SelectPipe(0,"ht_patrol",tpname);

		entity.AI.PathStep = entity.AI.PathStep + 1;
	end,	

--	--------------------------------------------
--	HT_TAKEOFF = function( self,entity, sender )
--		entity:DoTakeoff();
--		local entPos = entity:GetPos();
--		entPos.z = entPos.z + 22;
--		entity.actor:SetMovementTarget(entPos,{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--	end,	

--	--------------------------------------------
--	HT_TAKEOFF_DONE = function( self,entity, sender )
--		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--	end,	

--	--------------------------------------------
--	HT_LAND = function( self,entity, sender )	
--		entity:DoLand();
--		local entPos = entity:GetPos();
--		entPos.z = entPos.z - 22;
--		entity.actor:SetMovementTarget(entPos,{x=0,y=0,z=0},{x=0,y=0,z=0},2);
--	end,	
--
--	--------------------------------------------
--	HT_LAND_DONE = function( self,entity, sender )	
--		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--	end,	

	------------------------------------------------------------------------	
}

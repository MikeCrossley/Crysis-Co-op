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
--  - 2/12/2004    : Created by Kirill Bulatsev
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--
--------------------------------------------------------------------------


AIBehaviour.ScoutPatrol = {
	Name = "ScoutPatrol",

	---------------------------------------------
	Constructor = function(self,entity )
		entity.AI.PathStep = 0;
		AI.Signal( SIGNALFILTER_SENDER, 1, "SC_NEXT_POINT",entity.id);
	end,
	
	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		entity:DoPlayerSeen();
		entity:SelectPipe(0,"sc_player_seen_delay_attack");
		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		self:OnPlayerSeen(entity, fDistance);
	end,
	
	--------------------------------------------
	SC_NEXT_POINT = function( self,entity, sender )	
	
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
			
			local TagPoint = System.GetEntityByName(name.."_PSearch");
			if (TagPoint) then 		
				entity:Event_GoSearch( );
				do return end
			end
			
			entity.AI.PathStep = 0;
		end

		entity:SelectPipe(0,"sc_patrol",tpname);

		entity.AI.PathStep = entity.AI.PathStep + 1;
	end,	
	------------------------------------------------------------------------	
}

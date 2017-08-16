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


AIBehaviour.ScoutAlert = {
	Name = "ScoutAlert",

	
	-- SYSTEM EVENTS			-----
	---------------------------------------------

	Constructor = function(self,entity )
		if( AI.GetBeaconPosition( entity.id,g_Vectors.temp ) ) then
			-- If a beacon has been dropped, go to there.
			entity:SelectPipe(0,"sc_alert");
		else
			-- No beacon, start searching.
			AI.Signal(SIGNALFILTER_SENDER, 1, "GO_SEARCH",entity.id);
		end

	end,
	
	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:DoPlayerSeen();
		entity:SelectPipe(0,"sc_player_seen_delay_attack");

		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		self:OnPlayerSeen(entity, fDistance);
	end,
}

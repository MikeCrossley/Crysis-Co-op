--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple outdoor indoor alien behavior
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.ScoutRecoil = {
	Name = "ScoutRecoil",

	---------------------------------------------
	Constructor = function(self , entity )
		self:Relocate( entity );
	end,

	---------------------------------------------
	Relocate = function( self, entity )
		-- Approach the target.
		local targetName = AI.GetAttentionTargetOf(entity.id);
		if( targetName ) then
			local attackPos = g_Vectors.temp_v1;
			local attackDir = g_Vectors.temp_v2;
			local targetPos = g_Vectors.temp_v3;
			local targetDir = g_Vectors.temp_v4;
			local validPos = 0;

			AI.GetAttentionTargetPosition( entity.id, targetPos );
			AI.GetAttentionTargetDirection( entity.id, targetDir );

			validPos = AI.GetAlienApproachParams( entity.id, 1, targetPos, targetDir, attackPos, attackDir );	-- 0 = attack pos, 1 = recoil pos

			if( validPos > 0 ) then
				-- found valid target position
				AI.SetRefPointPosition( entity.id, attackPos );
				AI.SetRefPointDirection( entity.id, attackDir );
				entity:SelectPipe(0,"sc_recoil");
			end
		end
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
	end,

}

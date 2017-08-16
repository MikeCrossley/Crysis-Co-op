--------------------------------------------------
--   Created By: petar
--   Description: this is used to run to help a mate who called for help
--------------------------

AIBehaviour.HoldPosition = {
	Name = "HoldPosition",
	NOPREVIOUS = 1,
	alertness = 1,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )


		local dist = AI.FindObjectOfType(entity:GetPos(),fDistance,AIAnchorTable.HOLD_THIS_POSITION);
		if (dist==nil) then
			AI.Signal(0,1,"THREAT_TOO_CLOSE",entity.id);				
		end
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity, fDistance )


		local dist = AI.FindObjectOfType(entity:GetPos(),fDistance,AIAnchorTable.HOLD_THIS_POSITION);
		if (dist==nil) then
			AI.Signal(0,1,"THREAT_TOO_CLOSE",entity.id);				
		end
	end,
	
	
}
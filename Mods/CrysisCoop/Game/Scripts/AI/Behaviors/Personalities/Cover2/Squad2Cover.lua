--------------------------------------------------
--   Created By: Luciano
--   Description: Squadmate becomes player's enemy because of a teamkill


AIBehaviour.Squad2Cover = {
	Name = "Squad2Cover",
	Base = "Cover2Attack",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)

		--AI.LogEvent("Squadmate "..entity:GetName().." revolting against player");
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 15);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 15);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 7);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 7);

		if(not entity.AI.target) then
			entity.AI.target = {x=0, y=0, z=0};
		end

		entity.AI.fleeLastTime = _time;
		entity.AI.peekCount = 0;

		entity.AI.changeCoverLastTime = _time;
		entity.AI.changeCoverInterval = random(7,10);

		entity.AI.friendInWay = 0;
		entity.AI.lastPeek = 0;
		
		entity:SelectPipe(0,"cv_scramble");
		entity:InsertSubpipe(0,"squad_revolt");
	end,


	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,



	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
	end,


	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,



	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
	end,
	
	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
	end,
	
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)

	end,


}

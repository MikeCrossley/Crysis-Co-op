--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Helocipter Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 12/06/2006   : the first implementation by Tetsuji
--
--------------------------------------------------------------------------
local Xaxis =0;
local Yaxis =1;
local Zaxis =2;

AIBehaviour.HeliSmoothGoto = {
	Name = "HeliSmoothGoto",
	Base = "HeliBase",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity, sender, data )

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "TO_HELI_IDLE";
		entity.AI.heliMemorySignal = "TO_HELI_IDLE";

	end,
	
	ACT_DUMMY = function( self, entity, sender, data )
		self:HELI_SMOOTH_GOTO( entity, data );
	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnCloseContact= function( self, entity )
		-- called when AI gets at close distance to an enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity );
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			--entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	---------------------------------------------
	HELI_SMOOTH_GOTO = function( self, entity, data )
	
		local targetEntity = System.GetEntity( entity.AI.smoothGotoId );
		if ( targetEntity ) then

			local name = targetEntity:GetName();
			local nameLength = string.len(name);
			if ( nameLength < 2 ) then
				return;
			end

			local shortname = string.sub(name,1,nameLength-1);
			local index = 1;

			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );
			
			for i = 1,8 do
				name = shortname..tostring(i);
				local tagEntity = System.GetEntityByName( name );
				if ( tagEntity ) then
					index = index + 1;
					AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, tagEntity:GetPos(), index );
				else
					break;
				end
			end
			if ( index > 1 ) then
				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity, index, true ) == true ) then
					AI.CreateGoalPipe("heliSmoothGoto");
					AI.PushGoal("heliSmoothGoto","followpath", 1, false, false, false, 0, 10, true );
					AI.PushGoal("heliSmoothGoto","signal",1,1,"TO_HELI_IDLE",SIGNALFILTER_SENDER);
					entity:InsertSubpipe(0,"heliSmoothGoto",nil,data.iValue);
					return;
				end
			end
		end

		AI.CreateGoalPipe("heliSmoothGotoFailed");
		AI.PushGoal("heliSmoothGotoFailed","signal",1,1,"TO_HELI_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"heliSmoothGotoFailed",nil,data.iValue);

	end,

	---------------------------------------------
}

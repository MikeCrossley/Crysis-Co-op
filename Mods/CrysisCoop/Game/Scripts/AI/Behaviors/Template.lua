--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Template behavior with all the system signal callbacks
--  and most common callback from lua
--  Modify it only to add new empty system/most common callbacks
--  
--------------------------------------------------------------------------
--  History:
--  - 10/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TemplateBehavior = {
	Name = "TemplateBehavior",-- must be the same as the behavior name
--	[[Base = "BaseBehavior",]]-- Optional - the behavior from which it's derived from
												-- if a callback is not found here when receiving a signal,
												-- it will be searched in the BAse behavior
--	[[alertness = 1,]]				-- Optional - indicates the alert status (0 = idle, 1 = alert, 2=engaged in combat)
												-- read by AI system to get the alert status and display it i.e. on the radar
--	[[ TASK=1, ]]					-- Optional: if this is marked as a task, when switching to a new
												-- behavior which is not a task, this behaviour will be restored
												-- when "ON_PREVIOUS" signal will be sent while in the new behavior
		---------------------------------------------
	Constructor = function (self, entity,data)
		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition
	end,
	---------------------------------------------
	Destructor = function (self, entity,data)
		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
	end,


	---------------------------------------------
	OnActionDone = function( self, entity, data )
		-- called after finishing any AI action for which this agent was "the user"
		--
		-- data.ObjectName is the action name
		-- data.iValue is 0 if action was canceled or 1 if it was finished normally
		-- data.id is the entity id of "the object" of AI action
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
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
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		-- if (data.iValue == AIOBJECT_GRENADE) then -- grenade
		-- if (data.iValue == AIOBJECT_RPG) then -- rockets
		--	 ...
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the AI goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnReloadDone = function( self, entity )
		-- called after reloading is done
	end,
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender )
		-- called when the AI reaches his hidespot and he's actually well hidden
	end,	
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
		-- called when no hiding place can be found with the specified parameters
		-- data.fValue = distance at which the hidespot has been searched
	end,	
	---------------------------------------------
	OnBadHideSpot = function( self, entity, sender )
		-- called when the AI reaches a hidespot which proves to not hide correctly
	end,	
	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender )
		-- called when the AI reaches a hidespot which is too low to fit when standing up
	end,	
	---------------------------------------------
	OnLeftLean = function( self, entity, sender )
		-- called when a bad hidespot is reached, and AI can lean on the left
	end,
	---------------------------------------------
	OnRightLean = function( self, entity, sender )
		-- called when a bad hidespot is reached, and AI can lean on the right
	end,
	---------------------------------------------
	OnNoPathFound = function( self, entity, sender )
		-- called when the AI has requested a path which is not possible
	end,	
	---------------------------------------------
	OnEndPathOffset = function( self, entity, sender )
		-- called when the AI has requested a path and the end of path
		-- is far from the desired destination
	end,	
	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	---------------------------------------------
	OnBackOffFailed = function( self, entity, sender )
		-- called when the AI tried to execute a "backoff" goal which failed
	end,	


	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the AI couldn't find a formation point
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when AI is damaged by another friendly/unknown AI
		-- data.id = damaging AI's entity id
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
	end,

	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)	
		-- called when there are bullet impacts nearby
	end,

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
		-- called when a member of same species dies nearby
	end,
	--------------------------------------------------
	OnLeaderDied = function( self, entity, sender)
		-- called when the AI's group leader dies
	end,

	---------------------------------------------
	OnFriendInWay = function ( self, entity, sender)
		-- called when AI is trying to fire and another friendly AI is on his line of fire
	end,
	

	---------------------------------------------
	OnTargetTooClose = function (self,entity,sender,data)
		-- called when the attention target is too close for the current weapon range
		-- TO DO: it works only if AI is a vehicle
	end,
	---------------------------------------------
	OnTargetTooFar = function (self,entity,sender,data)
		-- called when the attention target is too close for the current weapon range
		-- TO DO: it works only if AI is a vehicle
	end,
	---------------------------------------------
	OnVehicleDanger = function (self,entity,sender,data)
		-- called when a vehicle is going towards the AI
		-- data.point = vehicle movement direction
		-- data.point2 = AI direction with respect to vehicle
	end,
	---------------------------------------------
	OnFireIncoming = function (self,entity,sender,data)
		-- called when an AI(*) of same species is going to shoot an explosive bullet nearby
		-- data.point = predicted point of impact
		-- data.fValue = damage radius
		-- (*) TO do: it works only if shooter AI is a vehicle
		
	end,	
	---------------------------------------------
	OnTaskSuspend = function ( self, entity, sender)
		-- if this behavior is marked as task, this callback will be executed when 
		-- switching to a behavior which is not a task
	end,
	---------------------------------------------
	OnTaskResume = function ( self, entity, sender)
		-- if this behavior is marked as task, this callback will be executed when 
		-- coming back to this from the previous behavior (which was not a task)
	end,
	
	---------------------------------------------
	OnSeenByEnemy = function ( self, entity, sender)
		-- called when AI is sought by the enemy
	end,
	
	---------------------------------------------
	OnThreateningSoundHeardByEnemy = function ( self, entity, sender)
		-- called when AI produces a threatening sound that is heard by enemy
	end,
	
	---------------------------------------------
	OnSwitchWeaponAccessory = function ( self, entity, sender,data)
		-- called for squadmates when the player changes/remove a weapon accessory
	end,
	
		---------------------------------------------
	OnPlayerLooking = function(self,entity,sender,data)
		-- player is looking at the ai since <entity.Properties.awarenessOfPlayer> seconds
		-- data.fValue = player distance
	end,

	---------------------------------------------
	OnPlayerLookingAway = function(self,entity,sender)
		-- player has just stopped looking at the AI
	end,

	---------------------------------------------
	OnPlayerSticking = function(self,entity,sender)
		-- player is staying close to the ai since <entity.Properties.awarenessOfPlayer> seconds
	end,

	----------------------------------
	OnPlayerGoingAway = function(self,entity,sender)
		-- player has just stopped staying close to the AI
	end,

}
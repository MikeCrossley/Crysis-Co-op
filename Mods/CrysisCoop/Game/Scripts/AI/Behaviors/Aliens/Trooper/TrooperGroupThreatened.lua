--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Group Idle behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/1/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperGroupThreatened = {
	Name = "TrooperGroupThreatened",
	Base = "TROOPERDEFAULT",
	
	-------------------------------------------------
	OnPlayerSeen = function(self,entity,distance)
	end,
	
	-------------------------------------------------
	OnSomethingSeen = function(self,entity,sender)
	end,
	
	-------------------------------------------------
	OnInterestingSoundHeard = function(self,entity,sender)
	end,
	
	-------------------------------------------------
	OnThreateningSoundHeard = function(self,entity,sender)
	end,

	-------------------------------------------------
	OnEnemyMemory = function(self,entity,sender)
	end,
	
	-------------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,
	
	-------------------------------------------------
	OnCloseContact = function(self,entity,sender)
	end,
	
	-------------------------------------------------
	GO_THREATEN = function(self,entity,sender)
	end,
	
}
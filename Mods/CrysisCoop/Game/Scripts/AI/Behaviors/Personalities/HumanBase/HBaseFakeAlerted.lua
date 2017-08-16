--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--   Description: idle but ignoring some minor things (dead bodies, interesting sounds, etc)
--  
--------------------------------------------------------------------------
--  History:
--  - 01/oct/2006   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------



AIBehaviour.HBaseFakeAlerted = {
	Name = "HBaseFakeAlerted",
	Base = "HBaseIdle",


	--------------------------------------------------
	
	--------------------------------------------------
	OnGroupMemberDiedNearest = function(self, entity, sender, data)
		--ignore dead body
	end,
	

}

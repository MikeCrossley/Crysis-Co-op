----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: the idle (default) behaviour for the Sniper
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 30:nov:2005   : Created by Kirill Bulatsev
--
----------------------------------------------------------------------------------------------------´

AIBehaviour.SniperIdle = {
	Name = "SniperIdle",
	Base = "HBaseIdle",		

	Constructor = function (self, entity)

		entity.primaryWeapon = "DSG1";
	
		entity.AI.snipe_spot_pos = nil;
		if(AIBehaviour.SniperMove.FindSnipeSpot(self, entity, 1) == nil) then
			entity:SelectPipe(0,"sniper_singlespot");
--			AI.Signal(SIGNALFILTER_SENDER,0,"on_spot",entity.id);	
		else
			AI.SetRefPointPosition( entity.id, entity.AI.snipe_spot_pos );
			entity:SelectPipe(0,"sniper_move_idle");
		end
		
		-- this needed to properly hanlde switching behaviors
		entity:InsertSubpipe(0,"devalue_target");		

		entity:CheckWeaponAttachments();
		
	end,

	HEADS_UP_GUYS = function (self, entity, sender)

			entity:MakeAlerted();
			entity:SelectPipe(0,"hide_from_beacon");
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		AI.LogEvent(entity:GetName().." OnInterestingSound heard");
--		entity:Readibility("IDLE_TO_INTERESTED");

		entity:SelectPipe(0,"look_around_quick");
--		entity:InsertSubpipe(0,"setup_stealth"); 
		entity:DrawWeaponDelay(0.6);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		-- first send him OnSeenByEnemy signal
----		local target = AI.GetAttentionTargetEntity(entity.id);
----		if(target) then 
----			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
----		end
--		entity:Readibility("IDLE_TO_THREATENED",1);
--		entity:DrawWeaponDelay(0.5);
--		entity:GettingAlerted();		
--		entity:SelectPipe(0, "not_so_random_hide_from" );
	end,

	---------------------------------------------
	-- Sniper never does search
	LOOK_FOR_TARGET	 = function( self, entity )

	end,

	---------------------------------------------
	GET_ALERTED = function( self, entity )

--		entity:Readibility("IDLE_TO_THREATENED");

		entity:SelectPipe(0,"look_around_quick");
--		entity:SelectPipe(0,"cover_pindown");
--		entity:SelectPipe(0,"cover_look_closer");
--		entity:InsertSubpipe(0,"setup_stealth"); 
		entity:DrawWeaponDelay(0.6);

	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--		local rnd=random(1,10);
--		if (rnd < 5) then 
--			entity:Readibility("THREATEN",1);			
--		end

		-- tell everybody else
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if (AI.GetGroupCount(entity.id) > 1) then
			-- only send this signal if you are not alone
--			if (entity:NotifyGroup()==nil) then
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "wakeup",entity.id);
--			end
		end
	
--		local stc=entity:SelectStance();
--		if (stc == 1 ) then 
--			entity:InsertSubpipe(0,"do_it_prone");
--		else	
--				entity:InsertSubpipe(0,"do_it_crouched");
--		end	
--		do return end		
	end,

	---------------------------------------------
	-- sniper gets pistol and switches to camper character
	SniperCloseContact = function( self, entity)
		AI.Signal(SIGNALFILTER_SENDER,0,"Switch2Camper",entity.id);	
	end,
	---------------------------------------------
	-- snaper gets pistol and switches to camper character
	Switch2Camper = function( self, entity, fDistance )
		AI.SetCharacter( entity.id, "Camper" );	
--		AI.Signal(SIGNALFILTER_SENDER,0,"OnPlayerSeen",entity.id);		
	end,	
	
	---------------------------------------------
	ChecktargetProximity = function( self, entity, fDistance )
	
		if(fDistance == nil) then
AI.LogEvent("sniper:ChecktargetProximity >>>>> NO TARGET");		
		return end
	
AI.LogEvent("sniper:ChecktargetProximity >>>>> "..fDistance);
	
		if(fDistance < 20)then
			AI.Signal(SIGNALFILTER_SENDER,0,"SniperCloseContact",entity.id);
			entity:SelectPipe(0,"cv_scramble");
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE, "cv_short_cover_fire");
			return 1
		end	
		return nil
	end,

	---------------------------------------------
	OnTargetApproaching = function( self, entity, fDistance )
		AIBehaviour.SniperIdle:ChecktargetProximity(entity, AI.GetAttentionTargetDistance(entity.id));
	end,
	
	---------------------------------------------
	on_spot = function( self, entity, fDistance )
	
		local refPos = g_Vectors.temp;
		-- if there is snipeSpot around
		if(entity.AI.snipe_spot_dir) then
			FastScaleVector(refPos, entity.AI.snipe_spot_dir, 15);
			FastSumVectors(refPos, entity:GetWorldPos(), refPos);
			AI.SetRefPointPosition(entity.id,refPos);
		end	
		entity:MakeAlerted();	
		entity:SelectPipe(0,"sniper_snipe");		
		
	end,
	
	--------------------------------------------------
	OnCollision = function(self,entity,sender,data)
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then 
			if(AI.Hostile(entity.id,data.id)) then 
			--entity:ReadibilityContact();
				entity:SelectPipe(0,"short_look_at_lastop",data.id);
			end
		end
	end,	
}

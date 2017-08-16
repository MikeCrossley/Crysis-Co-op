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
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--------------------------------------------------------------------------


--------------------------------------------------------------------------
AIBehaviour.ScoutIdle = {
	Name = "ScoutIdle",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition

		entity.AI.vFormationScale = {};
		entity.AI.vFormationScale.x =1.0;
		entity.AI.vFormationScale.y =1.0;
		entity.AI.vFormationScale.z =1.0;
		
		-- Detect weapons.
		entity:HolsterItem(true);
		entity:HolsterItem(false);
		entity.AI.bUseFreezeGun = false;
		entity.AI.bBlockHide = false;

		local weapon = entity.inventory:GetCurrentItem();
		if(weapon~=nil) then
			--AI.LogComment(entity:GetName().." ScoutIdle:Constructor weapon = "..weapon.class);
			if(weapon~=nil and weapon.class=="MOAR") then
				--AI.LogComment(entity:GetName().." ScoutIdle:Constructor MOAR behavior is selected for "..weapon.class);
				entity.AI.bUseFreezeGun = true;
			else
				--AI.LogComment(entity:GetName().." ScoutIdle:Constructor MOAC behavior is selected for "..weapon.class);
			end
		end

		-- Initialize entity variables.

		entity.AI.avec1 ={ x=0.0,y=0.0,z=0.0 };
		entity.AI.avec2 ={ x=0.0,y=0.0,z=0.0 };

		entity.AI.anchors = {
			entity.AI.avec1,
			entity.AI.avec2,
		};

		-- Search anchors for a pattern movement
		local anchorIndex = 1;
		local anchorName;
		local anchorEntity;
		for i= 0,400,20 do
			AI.SetRefPointPosition( entity.id , entity:GetPos() );
			anchorName = AI.GetAnchor(entity.id,AIAnchorTable.ALIEN_SCOUT_ATTACKSPOT,{min=i,max=i+10},AIANCHOR_NEAREST_TO_REFPOINT);	
			if( anchorName ) then
				local anchorEntity = System.GetEntityByName(anchorName);
				if( anchorEntity ) then
					--AI.LogEvent(entity:GetName().."found anchor in distance"..i);
					CopyVector( entity.AI.anchors[anchorIndex] , anchorEntity:GetPos() );
					anchorIndex = anchorIndex +1;
					if( anchorIndex == 3) then
						break;
					end
				end
			end
		end

		-- If there are anchors for pattern movement, select a circling behavior.
		if ( anchorIndex == 3) then
			entity.AI.bUseAnchors = true;
			for i= 1,2 do
				--AI.LogComment(entity:GetName()..i.." x= "..entity.AI.anchors[i].x);
				--AI.LogComment(entity:GetName()..i.." y= "..entity.AI.anchors[i].y);
				--AI.LogComment(entity:GetName()..i.." z= "..entity.AI.anchors[i].z);
			end
			AI.Signal(SIGNALFILTER_SENDER, -100, "TO_SCOUT_CIRCLING", entity.id);

		-- If there is no anchor, select a hovering behavior as idle.
		else
			entity.AI.bUseAnchors = false;
			entity.AI.hoveringCounter = 1;
			entity.AI.vec1 ={ x=5.0,y=0.0,z=0.0 };
			entity.AI.vec2 ={ x=0.0,y=5.0,z=0.0 };
			entity.AI.vec3 ={ x=0.0,y=0.0,z=5.0 };
			FastSumVectors( entity.AI.vec1 , entity.AI.vec1 , entity:GetPos() );
			FastSumVectors( entity.AI.vec2 , entity.AI.vec2 , entity:GetPos() );
			FastSumVectors( entity.AI.vec3 , entity.AI.vec3 , entity:GetPos() );
			entity.AI.movevec = {
				entity.AI.vec1,
				entity.AI.vec2,
				entity.AI.vec3,
			};
			AI.Signal(SIGNALFILTER_SENDER, -100, "SC_SCOUT_IDLE", entity.id);
		end

		-- recover game paramaters.

		if ( entity.AI.rsvForceView ~=nil ) then
			entity.gameParams.forceView = entity.AI.rsvForceView;
		end
		if ( entity.AI.normalSpeedRsv ~=nil ) then
			-- AI.LogEvent("set set set"..entity.AI.normalSpeedRsv..","..entity.AI.maxSpeedRsv );
			entity.gameParams.stance[1].normalSpeed = entity.AI.normalSpeedRsv;
			entity.gameParams.stance[1].maxSpeed = entity.AI.maxSpeedRsv;
		end
		entity.actor:SetParams(entity.gameParams);

		-- for temporary

		if ( scoutSelected ~= nil ) then
			if ( scoutSelected == entity.id ) then
				scoutSelected = nil;
			end
		end

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		entity:SelectPipe(0,"do_nothing");

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
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_PATROL", entity.id);

		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);

		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then 
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", target.id);
		end

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
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		local hitter = System.GetEntity(data.id);
		
		AI.SetRefPointPosition( entity.id , hitter:GetPos() );
		AI.CreateGoalPipe("scoutHovering2");
		AI.PushGoal("scoutHovering2","locate",0,"refpoint");
		AI.PushGoal("scoutHovering2","approach",1,20.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutHovering2","signal",0,1,"SC_SCOUT_IDLE",SIGNALFILTER_SENDER,-1);
		entity:SelectPipe(0,"scoutHovering2");


	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )

	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_IDLE = function( self, entity )
		entity:TriggerEvent(AIEVENT_CLEAR);
		AI.SetRefPointPosition( entity.id , entity.AI.movevec[entity.AI.hoveringCounter] );
		if ( entity.AI.hoveringCounter < 4 ) then
			AI.CreateGoalPipe("scoutHovering");
			AI.PushGoal("scoutHovering","locate",1,"hoge");
			AI.PushGoal("scoutHovering","continues",0,1);
			AI.PushGoal("scoutHovering","locate",0,"refpoint");
			AI.PushGoal("scoutHovering","approach",1,1.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHovering","signal",0,1,"SC_SCOUT_IDLE",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHovering");
			entity.AI.hoveringCounter = entity.AI.hoveringCounter +1;
		else
			entity.AI.hoveringCounter = 1;
		end		

	end,

	------------------------------------------------------------------------
	CLOAK = function(self,entity,sender)
		entity:Event_Cloak();
	end,

	------------------------------------------------------------------------
	UNCLOAK = function(self,entity,sender)
		entity:Event_UnCloak();
	end,

}


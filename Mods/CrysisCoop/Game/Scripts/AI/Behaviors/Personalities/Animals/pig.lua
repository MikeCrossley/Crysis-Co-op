-------------------------------------------------
--   	Created By: 	Sten Huebler
--   	Description: 	pecari behaviour
--------------------------
--	last modified:	24-10-2002 

AIBehaviour.Pig = {
	Name = "Pig",
	
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnSpawn = function( self, entity )
		-- called when enemy spawned or reset

		AI:CreateGoalPipe("pig_wander");
		AI:PushGoal("pig_wander","signal",0,1,"DO_COOL_ANIMATION",0);
		AI:PushGoal("pig_wander","locate",0,"hidepoint");
		AI:PushGoal("pig_wander","acqtarget",0,"");
		AI:PushGoal("pig_wander","timeout",1,1,2);
		AI:PushGoal("pig_wander","approach",1,0.5);
		AI:PushGoal("pig_wander","timeout",1,0,1);
		AI:PushGoal("pig_wander","approach",1,0.5);
		AI:PushGoal("pig_wander","timeout",1,0,1);
		AI:PushGoal("pig_wander","signal",0,1,"DO_SOMETHING_INTERESTING",0);
		AI:PushGoal("pig_wander","timeout",1,1,2);

		AI:CreateGoalPipe("pig_scared_hide");
		AI:PushGoal("pig_scared_hide","run",0,1);
		AI:PushGoal("pig_scared_hide","hide",1,20,HM_FARTHEST_FROM_TARGET,1);
		AI:PushGoal("pig_scared_hide","run",0,0);
		AI:PushGoal("pig_scared_hide","timeout",1,0,1);
		AI:PushGoal("pig_scared_hide","signal",0,1,"APPROACH_TARGET",0);
	
		AI:CreateGoalPipe("pig_cautious_sniff");
		AI:PushGoal("pig_cautious_sniff","timeout",1,1,2);
		AI:PushGoal("pig_cautious_sniff","signal",0,1,"WONDER_ABOUT_SOMETHING",0);
		AI:PushGoal("pig_cautious_sniff","hide",1,20,HM_FARTHEST_FROM_TARGET,1);
		AI:PushGoal("pig_cautious_sniff","signal",0,1,"WONDER_ABOUT_SOMETHING",0);

		AI:CreateGoalPipe("pig_cautious_approach");
		AI:PushGoal("pig_cautious_approach","timeout",1,0,1);
		AI:PushGoal("pig_cautious_approach","approach",1,1);
		AI:PushGoal("pig_cautious_approach","timeout",1,0,1);
		AI:PushGoal("pig_cautious_approach","signal",0,1,"WONDER_ABOUT_SOMETHING",0);
		AI:PushGoal("pig_cautious_approach","timeout",1,0,1);
		AI:PushGoal("pig_cautious_approach","signal",0,1,"WANDER_AROUND",0);

		self:WANDER_AROUND(entity);
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
		self:WANDER_AROUND(entity);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
		entity:SelectPipe(0,"pig_scared_hide");
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:SelectPipe(0,"pig_cautious_approach");
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:SelectPipe(0,"pig_scared_hide");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		entity:SelectPipe(0,"pig_scared_hide");
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:SelectPipe(0,"pig_scared_hide");
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:SelectPipe(0,"pig_scared_hide");
	end,


	WONDER_ABOUT_SOMETHING = function ( self, entity, sender)
		-- play some animation that is not related to anything
		entity:InsertAnimationPipe("pecari_sniff");
	end,
	---------------------------------------------------
	WANDER_AROUND = function ( self, entity, sender)
		entity:SelectPipe(0,"pig_wander");		
	end,
	---------------------------------------------------
	DO_COOL_ANIMATION = function ( self, entity, sender)
		-- play some animation that is not related to anything
	end,
	---------------------------------------------------
	DO_SOMETHING_INTERESTING = function ( self, entity, sender)
		-- play sniffing animation, or peeing animation or whatever
		entity:InsertAnimationPipe("pecari_sniff");
	end,

	APPROACH_TARGET = function( self, entity, sender )
		-- called when the enemy hears an interesting sound
		entity:SelectPipe(0,"pig_cautious_approach");
	end,

}
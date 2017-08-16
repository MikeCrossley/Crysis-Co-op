-- Created By Luciano Morpurgo
-- Reused by Dejan Pavlovski
-- Generic Play Sequence behavior - modified Generic Idle behavior; see the AI_IdleTable.lua
-- Actor moves to an anchor, performs animations, plays sounds,
-- ignoring signals which could cancel the sequence...
--------------------------

AIBehaviour.GenericPlaySequence = {
	Name = "GenericPlaySequence",
	alertness = 1,

	HEADS_UP_GUYS = function( self, entity, sender )
		if (not entity.ignorant) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "HEADS_UP_GUYS2", entity.id);
		end
	end,
	
	CONVERSATION_REQUEST = function(self, entity)
		-- disallow doing conversation during generic play
	end,

	---------------------------------------------
	Constructor = function(self,entity )
		entity:TriggerEvent(AIEVENT_ONBODYSENSOR, 100);
		entity.SeqLoopStart = 0;
		entity.SeqLoopCount = 0;
		entity.bEndSeqLoop = false;

		entity.currentIdleStep = 0;
		entity.idleAnimLoopStep = 0;
		entity.IdleAnchor = nil;
		entity.stopAnimations = nil;

		entity.ignorant = true;

		AI.Signal(SIGNALFILTER_SENDER,0,"OnJobContinue",entity.id);
	end,

	Destructor = function(self,entity )
		entity:TriggerEvent(AIEVENT_ONBODYSENSOR, 0);
		entity:TriggerEvent(AIEVENT_ONBODYSENSOR, 1.5);
		AI.LogEvent(entity:GetName()..": GENERIC PLAY DESTRUCTOR");
		entity.ignorant = nil;
		if (entity.stopAnimations) then
			entity.stopAnimations = nil;
			entity:StartAnimation(0,"stand_idle",6,0.5,1,0);
		end;
	end,
	
	OnJobContinue = function(self,entity,sender )	
--		local currentStep = entity.idleSequence[entity.currentIdleStep];
--		if(currentStep.SeqLoop) then
			
		entity.currentIdleStep = entity.currentIdleStep + 1;
		AI.LogEvent(entity:GetName()..": Generic Play continue: step "..entity.currentIdleStep);
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if(currentStep ~=nil) then

			if(currentStep.SeqLoop) then
			 	if(entity.SeqLoopCount ==0) then
					-- set the number of loops (if it's not been set already)
					entity.SeqLoopCount = currentStep.SeqLoop;
				end
				entity.bEndSeqLoop = true;
			end

			if(currentStep.SeqLoopStart~=nil) then
				entity.SeqLoopStart = entity.currentIdleStep-1;
			end

			if(currentStep.AnchorType~=nil) then
				local anchor;
				if (entity.useExactlyThisAnchor and AIAnchorTable[entity.useExactlyThisAnchor.Properties.aianchor_AnchorType] == currentStep.AnchorType) then
					anchor = entity.useExactlyThisAnchor;
					CopyVector(g_Vectors.temp, anchor:GetWorldPos());
					CopyVector(g_Vectors.temp_v2, anchor:GetDirectionVector());
					entity.useExactlyThisAnchor = nil;
					anchor = anchor:GetName();
				else
					anchor = AI.FindObjectOfType(entity.id,120,currentStep.AnchorType,0,g_Vectors.temp,g_Vectors.temp_v2);
				end
				if(anchor and anchor~="") then
AI.LogEvent("Using play anchor type "..currentStep.AnchorType.." by entity "..entity:GetName().." in idle step "..entity.currentIdleStep);
					if(anchor==entity.IdleAnchor) then
						-- same anchor as previous, avoid approaching it
						AI.Signal(SIGNALFILTER_SENDER,1,"TARGET_REACHED",entity.id);
						do return end
					end
					entity.IdleAnchor = anchor;
					g_Vectors.temp.x = g_Vectors.temp.x - 2*g_Vectors.temp_v2.x;
					g_Vectors.temp.y = g_Vectors.temp.y - 2*g_Vectors.temp_v2.y;
					g_Vectors.temp.z = g_Vectors.temp.z - 2*g_Vectors.temp_v2.z+1.3;
					AI.SetRefPointPosition(entity.id,g_Vectors.temp);
					entity:SelectPipe(0,"do_nothing");
					entity:SelectPipe(0,"approach_lastop_ignoring",anchor);
					entity:InsertSubpipe(0,"do_it_walking");
					entity:InsertSubpipe(0,"approach_refpoint_ignoring");
					if(currentStep.Run==1) then
						entity:InsertSubpipe(0,"do_it_running");
					else
						entity:InsertSubpipe(0,"do_it_walking");
					end
				else
					AI.Warning("[AI] Play anchor type "..currentStep.AnchorType.." not found by entity "..entity:GetName().." in play step "..entity.currentIdleStep);
					entity.IdleAnchor = nil;
				end
				do return end
			else
				entity.IdleAnchor = nil;
			end

			AI.Signal(SIGNALFILTER_SENDER,1,"TARGET_REACHED",entity.id);

		else
			AI.LogEvent(entity:GetName()..": END PLAY SEQUENCE");
			entity.IdleAnchor = nil;
		end
	end,

	REFPOINT_REACHED = function(self,entity,sender)
	--	if (entity.currentIdleStep == 1) then
	--		entity.stopAnimations = true;
	--		entity:StartAnimation(0,"stand_idle",6,0.5,1,0);
	--	end
	end,

	TARGET_REACHED = function(self,entity,sender)

		local soundStartLength = 0;
		local animStartLength = 0;

		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"clear_devalued");
		
		entity.bEndSequence = false;
		-- play animation
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		
		if(currentStep ==nil) then
			AI.LogEvent(entity:GetName()..": Step "..entity.currentIdleStep.." not existing in play sequence "..entity.Properties.IdleSequence);
			do return end
		end

		
		if(currentStep.SoundSynch==false) then
			entity.SoundSynch = false;
		else
			entity.SoundSynch = true;
		end

		if(currentStep.SoundStart ~=nil) then
			local soundStart = Sound.Load3DSound(currentStep.SoundStart, SOUND_UNSCALABLE, 128, 3, 43);
			if(soundStart) then
				Sound.SetSoundPosition(soundStart, entity:GetWorldPos());
				Sound.PlaySound(soundStart);
				soundStartLength =  Sound.GetSoundLength(soundStart)*1000;
			end
		end
	
		if(currentStep.AnimStart ~=nil) then

			entity.stopAnimations = true;
			entity:StartAnimation(0,currentStep.AnimStart,6,0.5,1,0);

			animStartLength = entity:GetAnimationLength(0, currentStep.AnimStart)*1000;
			
			entity:InsertSubpipe(0,"ignore_all");
		end
		
		entity.iAnimTimer  = Script.SetTimerForFunction(animStartLength, "AIBehaviour.GenericPlaySequence.OnAnimStartEnd", entity);

	end,



	OnAnimStartEnd = function( entity, timerid)
--		Script.KillTimer(timerid);
		AI.LogEvent(entity:GetName()..": ANIM START END");
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		local animLoopDuration = 0;
			
		if(currentStep and currentStep.AnimLoop ~=nil) then
		
			entity.stopAnimations = true;
			entity:StartAnimation(0,currentStep.AnimLoop,6,0.5,1,true);
			
			local loop = currentStep.Loop;
			if(loop==nil or loop==0) then
				loop =1;
			end

			if(loop>0) then
				animLoopDuration = entity:GetAnimationLength(0, currentStep.AnimLoop)*1000;
				entity.EndLoopSignal = currentStep.EndLoopSignal;
				entity.iAnimTimer  = Script.SetTimerForFunction(animLoopDuration*loop, "AIBehaviour.GenericPlaySequence.OnAnimLoopEnd", entity);
			
				entity:InsertSubpipe(0,"ignore_all");
			end
		
		elseif(currentStep and currentStep.AnimEnd ~=nil) then
		
			entity.stopAnimations = true;
			entity:StartAnimation(0,currentStep.AnimEnd,6,0.5,1,false);
			local duration = entity:GetAnimationLength(0, currentStep.AnimEnd)*1000;
			entity.bEndSequence = true;
			entity.iAnimTimer  = Script.SetTimerForFunction(duration*loop , "AIBehaviour.GenericPlaySequence.OnEndAnimationSequence", entity);
			
		end
		
		entity.SoundLoopLength = 0;
		if(currentStep and currentStep.SoundLoop) then

			entity.SoundLoop = Sound.Load3DSound(currentStep.SoundLoop, SOUND_UNSCALABLE, 128, 3, 43);

			if(entity.SoundLoop) then

				Sound.SetSoundPosition(entity.SoundLoop, entity:GetWorldPos());
				Sound.PlaySound(entity.SoundLoop);

				if(entity.SoundSynch and animLoopDuration>0) then
					entity.SoundLoopLength =  animLoopDuration;
				else
					entity.SoundLoopLength =  Sound.GetSoundLength(entity.SoundLoop)*1000;
				end

			end

			entity.iSoundTimer  = Script.SetTimerForFunction(entity.SoundLoopLength, "AIBehaviour.GenericPlaySequence.OnSoundLoopEnd", entity);

		end
		
	end,
	
	OnAnimLoopEnd = function( entity, timerid)
		
--		Script.KillTimer(timerid);
		AI.LogEvent(entity:GetName()..": ANIM LOOP END");

		if (entity.IdleAnchor) then
			local anchor = System.GetEntityByName(entity.IdleAnchor);
			if (anchor) then
				AI.LogEvent(entity:GetName()..": Triggering event Use on anchor "..entity.IdleAnchor);
				if (anchor.Event_Use) then
					anchor:Event_Use( nil ); -- nil indicates it's an output event
				end
			end
		end
		
		if (entity.EndLoopSignal) then
			AI.Signal(SIGNALFILTER_SENDER, 10, entity.EndLoopSignal, entity.id);
			entity.EndLoopSignal = nil;
		end

		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if (not currentStep) then
			if (entity.stopAnimations) then
				entity.stopAnimations = nil;
				entity:StartAnimation(0,"stand_idle",6,0.5,1,0);
			end;
			return;
		end

		if(currentStep.AnimEnd ~=nil) then

			entity.stopAnimations = true;
			entity:StartAnimation(0,currentStep.AnimEnd,6,0.5,1,false);
			local duration = entity:GetAnimationLength(0, currentStep.AnimEnd)*1000;
			entity.bEndSequence = true;
			entity.iTimer  = Script.SetTimerForFunction(duration, "AIBehaviour.GenericPlaySequence.OnEndAnimationSequence", entity);

			if(currentStep.SoundEnd ) then
				local soundEnd = Sound.Load3DSound(currentStep.SoundEnd, SOUND_UNSCALABLE, 128, 3, 43);
				if(soundEnd) then
					Sound.SetSoundPosition(soundEnd, entity:GetWorldPos());
					Sound.PlaySound(soundEnd);
				end
			end
			
		else
			if (entity.stopAnimations) then
				entity.stopAnimations = nil;
				entity:StartAnimation(0,"stand_idle",6,0.5,1,0);
			end
			AIBehaviour.GenericPlaySequence.OnEndAnimationSequence(entity);
		end				
	end,	


	OnSoundStartEnd = function( entity, timerid)
--		Script.KillTimer(timerid);
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if(currentStep) then
			if( currentStep.SoundLoop ~=nil) then
				entity.SoundLoop = Sound.Load3DSound(currentStep.SoundLoop, SOUND_UNSCALABLE, 128, 3, 43);
				if(entity.SoundLoop) then
					Sound.SetSoundPosition(entity.SoundLoop, entity:GetWorldPos());
					Sound.PlaySound(entity.SoundLoop);
					entity.SoundLoopLength =  Sound.GetSoundLength(entity.SoundLoop)*1000;
					entity.iSoundTimer  = Script.SetTimerForFunction(entity.SoundLoopLength, "AIBehaviour.GenericPlaySequence.OnSoundLoopEnd", entity);
				end

			elseif(currentStep.SoundEnd ~=nil) then
				local soundEnd = Sound.Load3DSound(currentStep.soundEnd, SOUND_UNSCALABLE, 128, 3, 43);
				if(soundEnd) then
					Sound.SetSoundPosition(soundEnd, entity:GetWorldPos());
					Sound.PlaySound(soundEnd);
					local soundEndLength =  Sound.GetSoundLength(soundEnd)*1000;
					entity.iSoundTimer  = Script.SetTimerForFunction(soundEndLength, "AIBehaviour.GenericPlaySequence.OnSoundEndEnd", entity);
				end
			end
		end				
	end,



	OnSoundLoopEnd = function( entity, timerid)
--		Script.KillTimer(timerid);
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if(currentStep) then
		  if(not entity.bEndSequence) then
	  		if(entity.SoundLoop) then
					Sound.SetSoundPosition(entity.SoundLoop, entity:GetWorldPos());
					Sound.PlaySound(entity.SoundLoop);
					entity.iSoundTimer  = Script.SetTimerForFunction(entity.SoundLoopLength, "AIBehaviour.GenericPlaySequence.OnSoundLoopEnd", entity);
				end

			end
		end				
	end,

	
	OnEndAnimationSequence = function( entity, timerid)
--		Script.KillTimer(timerid);
		AI.LogEvent(entity:GetName()..": END STEP "..entity.currentIdleStep.." loop count = "..entity.SeqLoopCount);
		entity.bEndSequence = true;
		entity.SoundLoop = nil;
		if(entity.bEndSeqLoop and entity.SeqLoopCount ~=0) then
			entity.SeqLoopCount  = entity.SeqLoopCount -1;
			if(	entity.SeqLoopCount ~=0) then
				entity.currentIdleStep = entity.SeqLoopStart ;
			else
				entity.SeqLoopStart = 0;
			end

			entity.bEndSeqLoop = false;

		end
		AI.Signal(SIGNALFILTER_SENDER,1,"OnJobContinue",entity.id);
	end,

-- Ignore all default processing of signals
	---------------------------------------------
	OnStartPanicking = function( self, entity, sender)
	end,
	---------------------------------------------
	OnStopPanicking = function( self, entity, sender)
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees an enemy
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when detect weapon fire around AI
	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
	end,
	---------------------------------------------
	OnVehicleSuggestion = function(self, entity)
		-- called when a vehicle would be better to reach the attention/last_op target
		-- AI Suggest me to use a vehicle, I'll search for it and I'll use it
	end,
	-- CUSTOM SIGNALS
	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		-- call the default to do stuff that everyone should do
	end,
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
	end,
	--------------------------------------------------
	COVER_RELAX = function (self, entity, sender)
	end,
	--------------------------------------------------
	AISF_GoOn = function (self, entity, sender)
	end,
	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	KEEP_FORMATION = function (self, entity, sender)
	end,
	---------------------------------------------	
	MOVE_IN_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to move in formation
	end,
	---------------------------------------------	
	THREAT_TOO_CLOSE = function (self, entity, sender)
		-- the team can split
	end,
	---------------------------------------------	
	BREAK_FORMATION = function (self, entity, sender)
		-- the team can split
	end,
	---------------------------------------------	
	SINGLE_GO = function (self, entity, sender)
		-- the team leader has instructed this group member to approach the enemy
	end,
	---------------------------------------------	
	GROUP_COVER = function (self, entity, sender)
		-- the team leader has instructed this group member to cover his friends
	end,
	---------------------------------------------	
	IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
	end,
	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
	end,
	---------------------------------------------	
	PHASE_BLACK_ATTACK = function (self, entity, sender)
		-- team leader instructs black team to attack
	end,
	---------------------------------------------	
	GROUP_MERGE = function (self, entity, sender)
		-- team leader instructs groups to merge into a team again
	end,
	---------------------------------------------	
	CLOSE_IN_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	ASSAULT_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	GROUP_NEUTRALISED = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	-------------------------------------------------
	GO_TO_DESTINATION = function(self, entity, sender, data)
	end,
	-----------------------------------------------------------------------------	
	ORDER_FOLLOW = function (self, entity, sender)
	end,
	-----------------------------------------------------------------------------	
	FORMATION_REACHED = function (self, entity, sender)
	end,
	-----------------------------------------------------------------------------	
	SEARCH_AROUND = function(self,entity,sender)
	end,
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	------------------------------------------------------------------------

	
}

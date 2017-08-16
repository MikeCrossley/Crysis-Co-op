-- Created By Luciano Morpurgo
-- Generic Idle behavior implementation; see the AI_IdleTable.lua
-- Actor moves to an anchor, performs animations, plays sounds
--------------------------

AIBehaviour.Job_GenericIdle = {
	Name = "Job_GenericIdle",				
	JOB = 1,	

	CONVERSATION_REQUEST = function(self, entity)
		-- disallow doing conversation during generic idle
	end,

	---------------------------------------------
	Constructor = function(self,entity )
		entity.SeqLoopStart = 0;
		entity.SeqLoopCount = 0;
		entity.bEndSeqLoop = false;

		entity.currentIdleStep = 0;
		entity.idleAnimLoopStep = 0;
		entity.IdleAnchor = nil;
		entity.stopAnimations = nil;

		if(entity.Properties.IdleSequence == "None") then
			return
		end

		entity.idleSequence = AI_IdleTable[entity.Properties.IdleSequence];

		if(entity.idleSequence==nil) then
			AI.Warning("[AI] Entity "..entity:GetName().." has undefined IdleSequence in its properties");
			return
		end
		
		if (entity.idleSequence.Ignorant) then
			AI.Signal(SIGNALFILTER_SENDER, 0, "DO_GENERIC_PLAY", entity.id);
		elseif (entity.Properties.bIdleStartOnSpawn) then
			AI.Signal(SIGNALFILTER_SENDER, 0, "OnJobContinue", entity.id);
		end
		
		if (entity.idleSequence.WithWeapon and entity.idleSequence.WithWeapon == 1) then
			if (entity.inventory:GetCurrentItemId()) then
				AI.Signal(SIGNALFILTER_SENDER,1,"DRAW_WEAPON",entity.id);
			end
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"HOLSTER_WEAPON",entity.id);
		end

	end,

	----------------------------------------------------------------
	Destructor = function(self,entity )
		AI.LogEvent(entity:GetName()..": GENERIC IDLE DESTRUCTOR");
		if (entity.stopAnimations) then
			entity.stopAnimations = nil;
			entity:StartAnimation(0,"stand_idle",6,0.5,1,0);
		end
		if(entity.iAnimTimer) then
			Script.KillTimer(entity.iAnimTimer); 
			entity.iAnimTimer = nil;
		end
		if(entity.iSoundTimer) then
			Script.KillTimer(entity.iSoundTimer); 
			entity.iSoundTimer = nil;
		end
		entity.EndLoopSignal = nil;

		if (entity.idleSequence) then
			if (not entity.idleSequence.WithWeapon or entity.idleSequence.WithWeapon ~= 1 and entity.inventory:GetCurrentItemId()) then

				entity:HolsterItem(false); -- assuming that entity always switches to a alert/combat behaviour after job_genericIdle
			end
		end
	end,
	

	----------------------------------------------------------------
	OnJobContinue = function(self,entity,sender )	
--		local currentStep = entity.idleSequence[entity.currentIdleStep];
--		if(currentStep.SeqLoop) then
			
		entity.currentIdleStep = entity.currentIdleStep + 1;
--		AI.LogEvent(entity:GetName()..": Generic Idle continue: step "..entity.currentIdleStep);
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if(currentStep ~=nil) then

			if (currentStep.Ignorant) then
				entity.ignorant = 1;
			else
				entity.ignorant = nil;
			end
			
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
					anchor = AI.FindObjectOfType(entity.id,120,currentStep.AnchorType,4,g_Vectors.temp,g_Vectors.temp_v2);
				end
				
				if(anchor and anchor~="") then
--AI.LogEvent("Using idle anchor type "..currentStep.AnchorType.." by entity "..entity:GetName().." in idle step "..entity.currentIdleStep);
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
					entity:SelectPipe(0,"approach_lastop",anchor);
					entity:InsertSubpipe(0,"do_it_walking");
					entity:InsertSubpipe(0,"approach_refpoint");
					if(currentStep.Run==1) then
						entity:InsertSubpipe(0,"do_it_running");
					else
						entity:InsertSubpipe(0,"do_it_walking");
					end
				else
					AI.Warning("[AI] Idle anchor type "..currentStep.AnchorType.." not found by entity "..entity:GetName().." in idle step "..entity.currentIdleStep);
					entity.IdleAnchor = nil;
				end
				do return end
			else
				entity.IdleAnchor = nil;
			end

			AI.Signal(SIGNALFILTER_SENDER,1,"TARGET_REACHED",entity.id);

		else
--			AI.LogEvent(entity:GetName()..": END IDLE SEQUENCE");
			entity.IdleAnchor = nil;
		end
	end,

	----------------------------------------------------------------
	REFPOINT_REACHED = function(self,entity,sender)
	--	if (entity.currentIdleStep == 1) then
	--		entity.stopAnimations = true;
	--		entity:StartAnimation(0,"stand_idle",6,0.5,1,0);
	--	end
	end,
	----------------------------------------------------------------
	TARGET_REACHED = function(self,entity,sender)

		local soundStartLength = 0;
		local animStartLength = 0;

		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"clear_devalued");
		
		entity.bEndSequence = false;
		-- play animation
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		
		if(currentStep ==nil) then
			AI.LogEvent(entity:GetName()..": Step "..entity.currentIdleStep.." not existing in idle sequence "..entity.Properties.IdleSequence);
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
		self:PlayAnimation(entity,"currentStep.AnimStart,AIBehaviour.Job_GenericIdle.OnAnimStartEnd");
	end,

	----------------------------------------------------------------
	HOLSTER_WEAPON = function(self,entity,sender)
		entity:HolsterItem(true);
	end,

	----------------------------------------------------------------
	DRAW_WEAPON = function(self,entity,sender)
		entity:HolsterItem(false);
	end,

	----------------------------------------------------------------

	OnAnimStartEnd = function( entity, timerid)
--		Script.KillTimer(timerid);
--		AI.LogEvent(entity:GetName()..": ANIM START END");
		entity.iAnimTimer = nil;
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		local animLoopDuration = 0;
			
		if (currentStep) then
		
			local loop = 1;
			if (currentStep.Loop) then
				loop = currentStep.Loop;
			end
			entity.numLoops = loop;

			entity.EndLoopSignal = currentStep.EndLoopSignal;
			AIBehaviour.Job_GenericIdle:PlayAnimation(entity,"currentStep.AnimLoop,AIBehaviour.Job_GenericIdle.OnAnimLoopEnd");

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

			entity.iSoundTimer  = Script.SetTimerForFunction(entity.SoundLoopLength, "AIBehaviour.Job_GenericIdle.OnSoundLoopEnd", entity);

		end
		
	end,

	---------------------------------------------------------------------
	
	OnAnimLoopEnd = function( entity, timerid)
		entity.numLoops = entity.numLoops -1;
		entity.iAnimTimer = nil;
		if( entity.numLoops~=0) then
			local currentStep = entity.idleSequence[entity.currentIdleStep];
			
			AIBehaviour.Job_GenericIdle:PlayAnimation(entity,"currentStep.AnimLoop,AIBehaviour.Job_GenericIdle.OnAnimLoopEnd");
			return;
		end			
		
--		Script.KillTimer(timerid);
--		AI.LogEvent(entity:GetName()..": ANIM LOOP END");

		if (entity.IdleAnchor) then
			local anchor = System.GetEntityByName(entity.IdleAnchor);
			if (anchor) then
				--AI.LogEvent(entity:GetName()..": Triggering event Use on anchor "..entity.IdleAnchor);
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
			end
			return;
		end

		if(currentStep.AnimEnd ~=nil) then

			entity.bEndSequence = true;
			AIBehaviour.Job_GenericIdle:PlayAnimation(entity,"currentStep.AnimEnd,AIBehaviour.Job_GenericIdle.OnEndAnimationSequence");

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
			AIBehaviour.Job_GenericIdle.OnEndAnimationSequence(entity);
		end				
	end,	

	---------------------------------------------------------------------

	OnSoundStartEnd = function( entity, timerid)
--		Script.KillTimer(timerid);
		entity.iSoundTimer = nil;
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if(currentStep) then
			if( currentStep.SoundLoop ~=nil) then
				entity.SoundLoop = Sound.Load3DSound(currentStep.SoundLoop, SOUND_UNSCALABLE, 128, 3, 43);
				if(entity.SoundLoop) then
					Sound.SetSoundPosition(entity.SoundLoop, entity:GetWorldPos());
					Sound.PlaySound(entity.SoundLoop);
					entity.SoundLoopLength =  Sound.GetSoundLength(entity.SoundLoop)*1000;
					entity.iSoundTimer  = Script.SetTimerForFunction(entity.SoundLoopLength, "AIBehaviour.Job_GenericIdle.OnSoundLoopEnd", entity);
				end

			elseif(currentStep.SoundEnd ~=nil) then
				local soundEnd = Sound.Load3DSound(currentStep.soundEnd, SOUND_UNSCALABLE, 128, 3, 43);
				if(soundEnd) then
					Sound.SetSoundPosition(soundEnd, entity:GetWorldPos());
					Sound.PlaySound(soundEnd);
					local soundEndLength =  Sound.GetSoundLength(soundEnd)*1000;
					entity.iSoundTimer  = Script.SetTimerForFunction(soundEndLength, "AIBehaviour.Job_GenericIdle.OnSoundEndEnd", entity);
				end
			end
		end				
	end,

	---------------------------------------------------------------------

	OnSoundLoopEnd = function( entity, timerid)
--		Script.KillTimer(timerid);
		entity.iSoundTimer = nil;
		local currentStep = entity.idleSequence[entity.currentIdleStep];
		if(currentStep) then
		  if(not entity.bEndSequence) then
	  		if(entity.SoundLoop) then
					Sound.SetSoundPosition(entity.SoundLoop, entity:GetWorldPos());
					Sound.PlaySound(entity.SoundLoop);
					entity.iSoundTimer  = Script.SetTimerForFunction(entity.SoundLoopLength, "AIBehaviour.Job_GenericIdle.OnSoundLoopEnd", entity);
				end

			end
		end				
	end,

	---------------------------------------------------------------------

	OnEndAnimationSequence = function( entity, timerid)
--		Script.KillTimer(timerid);
--		AI.LogEvent(entity:GetName()..": END STEP "..entity.currentIdleStep.." loop count = "..entity.SeqLoopCount);
		entity.iAnimTimer = nil;
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

	---------------------------------------------------------------------

	PlayAnimation = function(self,entity, animation, callback_str_name)
			-- play idle animation
		if(type(animation)=="string") then
			g_StringTemp1 = animation;
		elseif(type(animation)=="table") then
			local c = count(animation);
			local rnd = math.random(1,100);
			local p = 0;
			local i = 0;
			while(i<c and p<rnd) do
				i=i+2;
				p = p+animation[i];
			end
			i = i-1;
			if(type(animation[i])=="string") then				
				g_StringTemp1 = animation[i];
			else
				g_StringTemp1 = "";
				AI.Warning(entity:GetName()..": Wrong animation data in animation table (AI_IdleTable.lua)");
				entity.iAnimTimer = Script.SetTimerForFunction(0,callback_str_name,entity);
				return;
			end
		elseif (animation == nil) then
			g_StringTemp1 = "";
-- not used anymore			
--			callback(entity);
			return;
		else
			g_StringTemp1 = "";
			AI.Warning(entity:GetName()..": Wrong animation data type in AI_IdleTable.lua");
			entity.iAnimTimer = Script.SetTimerForFunction(0,callback_str_name,entity);
			return;
		end

		entity.stopAnimations = true;
		entity:StartAnimation(0,g_StringTemp1,6,0.5,1,false);
		local duration = entity:GetAnimationLength(0, g_StringTemp1)*1000;
		entity.iAnimTimer = Script.SetTimerForFunction(duration,callback_str_name,entity);
	end,	
}



--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--
--	Description: BasicAI should contain all shared AI functionality for 
--	actors 
--  
--------------------------------------------------------------------------
--  History:
--	Created by Petar
--  - 13/06/2005   15:36 : Kirill - cleanup
--
--------------------------------------------------------------------------

Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAITable.lua");
Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAIEvent.lua");
Script.ReloadScript("Scripts/AI/anchor.lua");


BasicAI = {
	ai=1,
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

	primaryWeapon = "FY71",
	secondaryWeapon = "SOCOM",

	supressed=0,
	supressedTrh=8,	

	Behaviour = {
	},

	onAnimationStart = {},
	onAnimationEnd = {},
	onAnimationKey = {},
	
	Server = {},
	Client = {},
	lastSplash = 0,
	
	Editor={
		Icon="User.bmp",
		IconOnTop=1,
	},
	
	SuitMode ={
		SUIT_OFF=0,
		SUIT_ARMOR=1,		
		SUIT_CLOAK=2,
		SUIT_POWER=3,
		SUIT_SPEED=4,				
	}
}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function BasicAI:OnPropertyChange()
	--do not rephysicalize at each property change

	self:RegisterAI();
	self:OnReset();
	
end


----------------------------------------------------------------------------------------------------
function BasicAI:OnLoadAI(saved)


--	AI.RegisterWithAI(self.id, AIOBJECT_PUPPET, self.Properties, self.PropertiesInstance, self.AIMovementAbility);
--	AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);

	self.AI = {};
	if(saved.AI) then 
		self.AI = saved.AI;
	end

	if(saved.Events) then 
--		self.Events = saved.Events;
		self.Events = {};
		local evts = self.Events;
		for name, data in pairs(saved.Events) do
			local eventTargets = saved.Events[name];
			if not evts[name] then evts[name] = {} end			
			for i, target in pairs(eventTargets) do
				local TargetId = target[1];
				local TargetEvent = target[2];			
				table.insert(evts[name], {TargetId, TargetEvent})
			end	
		end
	else
		self.Events = nil;
	end

	if(saved.spawnedEntity) then
		self.spawnedEntity = saved.spawnedEntity;
	else
		self.spawnedEntity = nil;
	end
			
	if(self.Properties and self.Properties.aicharacter_character) then 
		local characterTable = AICharacter[self.Properties.aicharacter_character];
		if(characterTable and characterTable.OnLoad) then 
			characterTable.OnLoad(self,saved);
		end
	end	

end


----------------------------------------------------------------------------------------------------
function BasicAI:OnSaveAI(save)
	if(self.AI) then 
		save.AI = self.AI;
	end
	
	if(self.Events) then 
--		self.Events = sav.Events;
		save.Events = {};
		local evtsSaved = save.Events
		for name, data in pairs(self.Events) do
			if not evtsSaved[name] then evtsSaved[name] = {} end
			for i, target in pairs(data) do
					local TargetId = target[1];
					local TargetEvent = target[2];
					table.insert(evtsSaved[name], {TargetId, TargetEvent})
				end
--			evtsSaved[name] = data[1];
		end
	end

	if(self.spawnedEntity) then
		save.spawnedEntity = self.spawnedEntity;
	end	

	if(self.Properties and self.Properties.aicharacter_character) then 
		local characterTable = AICharacter[self.Properties.aicharacter_character];
		if(characterTable and characterTable.OnSave) then 
			characterTable.OnSave(self,save);
		end
	end
end


-----------------------------------------------------------------------------------------------------
function BasicAI:RegisterAI()

	if (self ~= g_localActor) then
		if ( self.AIType == nil ) then
			AI.RegisterWithAI(self.id, AIOBJECT_PUPPET, self.Properties, self.PropertiesInstance, self.AIMovementAbility,self.melee);
		else
			AI.RegisterWithAI(self.id, self.AIType, self.Properties, self.PropertiesInstance, self.AIMovementAbility,self.melee);
		end
		AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_TARGET,self.forgetTimeTarget);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_SEEK,self.forgetTimeSeek);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_MEMORY,self.forgetTimeMemory);
	
		-- If the entity is hidden during 
		if (self:IsHidden()) then
			AI.LogEvent(self:GetName()..": The entity is hidden during init -> disable AI.");
			self:TriggerEvent(AIEVENT_DISABLE);
		end
	end
end

-----------------------------------------------------------------------------------------------------
function BasicAI:UnregisterAI()
    AI.RegisterWithAI(self.id, 0, self.Properties, self.PropertiesInstance, self.AIMovementAbility,self.melee);
end

-----------------------------------------------------------------------------------------------------
function BasicAI:OnReset()
	if (self.ResetOnUsed) then
		self:ResetOnUsed();
	end
	
	System.LogAlways("BasicAI:OnReset");

	self.ignorant = nil;
	self.isFallen = nil;

	local Properties = self.Properties;
	
--	AI.ChangeParameter(self.id,AIPARAM_COMMRANGE,Properties.commrange);	-- communications range gets overriden when AI is killed
--	AI.ChangeParameter(self.id,AIPARAM_GROUPID,Properties.commrange);	-- communications range gets overriden when AI is killed

	-- Reset all properties to editor set values.
	AI.ResetParameters(self.id, Properties, self.PropertiesInstance, nil,self.melee);
	AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);
	AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_TARGET,self.forgetTimeTarget);
	AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_SEEK,self.forgetTimeSeek);
	AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_MEMORY,self.forgetTimeMemory);

	-- free mounted weapon
	if (self.AI.current_mounted_weapon) then
		self.AI.current_mounted_weapon.reserved = nil;
		self.AI.current_mounted_weapon.listPotentialUsers = nil;
		self.AI.current_mounted_weapon = nil;
	end	

	if( self.OnInitCustom ) then
	 self:OnInitCustom();
	end 

	self:SetActorModel();
	
	if (self.AI.bIsLeader) then
		AI.SetLeader(self.id);
--	if(Properties.aicharacter_character =="TLDefense") then
		AI.Signal(SIGNALFILTER_SENDER, 0, "REQUEST_JOIN_TEAM",self.id);
--	AI.Commander:AddLeader(self);
--	end
	end

	self.Enemy_Hidden = 0;
	self.UpdateTime = 0.05;

	self:NetPresent(1);
	self.PLAYER_ALREADY_SEEN = nil;
	self.DODGING_ALREADY  = nil;
	self.POTSHOTS = 0;
	self.EXPRESSIONS_ALLOWED = 1;
	self:SetScriptUpdateRate(self.UpdateTime);

	self.AI.PlayerEngaged = nil;
	self.AI.ALARMNAME = nil;
	self.RunToTrigger = nil;
	self.SpecialTarget = nil;
	self.useAction = AIUSEOP_NONE;

	self:StopConversation();

	if (Properties.ImpulseParameters) then 
		for name,value in pairs(Properties.ImpulseParameters) do
			self.ImpulseParameters[name] = value;
		end
	end

--	BasicPlayer.OnReset(self);
	
	if(Properties.bNanoSuit==1) then 
		--self.actor:ActivateNanoSuit(1);
	else
		self.actor:ActivateNanoSuit(0);
	end

	self.AI.CurrentConversation = nil;
	
	--randomize only if the AI is using a voicepack.
	if (Properties.SoundPack and Properties.SoundPack~="") then
		Properties.SoundPack = SPRandomizer:GetHumanPack(self.PropertiesInstance.groupid,Properties.SoundPack);
-- 	 AI.LogEvent("SOUNDPACK "..self:GetName().." using"..Properties.SoundPack);
	else
--		AI.LogEvent("SOUNDPACK not found for "..self:GetName());
	end

	self.groupid = self.PropertiesInstance.groupid;

	Properties.LEADING_COUNT = -1;
	self.LEADING = nil;

	-- now the same for special fire animations

	if (self.isAlien) then
		BasicAlien.Reset(self);
	else
		BasicActor.Reset(self);
	end
	
	if( self.OnResetCustom ) then
		self:OnResetCustom();
	end 

	self.AI.theVehicle = nil;
	
--	if (self.currentItemId) then
--		local item = System.GetEntity(self.currentItemId);
--	end

	if (self.instructionId) then
		HUD:SetInstructionObsolete(self.instructionId);
	end
	self.instructionId = nil;
	
	self:HideAttachment(0,"Animated LAW",true,true);

	if(self.bSquadMate) then 
		AICharacter.Player:InitItems(self);
	end
	self.AI.NextWeaponAccessory = nil;
	self.AI.WeaponAccessoryMountType = nil;
	self.AI.MountingAccessory = nil;

	self:AssignPrimaryWeapon();
	--self:CheckWeaponAttachments();
--	self:EnableLAM("Laser",true);
	
	if(not self.bGunReady) then
		ItemSystem.SetActorItem(self.id,NULL_ENTITY,false);
    --self:HolsterItem(true);
	end
		
	if (self.isAlien) then
	  self:DrawWeaponNow();
	end
	
	self:CheckWeaponAttachments();
	AI.EnableWeaponAccessory(self.id, AIWEPA_LASER, true);
	
	self:SetColliderMode(Properties.eiColliderMode);

end



--------------------------------------------------------------------------------------------------------
function BasicAI.Server:OnInit()
	--Log("$8%s.Server:OnInit()", self:GetName());
	
	self:RegisterAI();
	self:OnReset();
end


--------------------------------------------------------------------------------------------------------
function BasicAI.Client:OnInit()
	if( self.OnResetClient ) then
		self:OnResetClient();
	end 
end


--------------------------------------------------------------------------------------------------------
function BasicAI.Client:OnShutDown()

	if (self.isAlien) then
		BasicAlien.ShutDown(self);
	else
		BasicActor.ShutDown(self);
	end
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:CheckFlashLight()

	if (self.Properties.special == 1) then 
		do return end
	end

	local name = AI.FindObjectOfType(self.id,2,AIAnchorTable.AIANCHOR_FLASHLIGHT);
	
	if (name) then 
		self:InsertSubpipe(0,"flashlight_investigate",name);
	end
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:MakeMissionConversation(name)

	-- Conversation in place: the two guys are already close and don't have to move
	-- to each other's place (also valid when they're walking together)
	-- TO DO Conversation not in place: the guys requested for conversation must go to 
	-- the requestor

	if(name == nil or name=="") then
		name = AI.FindObjectOfType(self.id,25,AIAnchorTable.IDLE_MISSION_TALK_INPLACE);
	end

	if (name and name~="") then
		if (self.AI.CurrentConversation == nil) then
			self.AI.ConvPartecipants = 0;
			self.ConvActors = {nil,nil,nil,nil,nil,nil,nil};
			self.ConversationName = name;
			g_SignalData.iValue = 1; -- for mission conversation 
			g_SignalData.fValue = 1; -- for conversation in place

			AI.Signal(SIGNALFILTER_GROUPONLY,0,"CONVERSATION_REQUEST",self.id, g_SignalData);
			return 1
		end
	end


	name = AI.FindObjectOfType(self.id,25,AIAnchorTable.IDLE_MISSION_TALK);

	if (name) then
		if (self.AI.CurrentConversation == nil) then
			self.AI.ConvPartecipants = 0;
			self.ConvActors = {nil,nil,nil,nil,nil,nil,nil};
			self.ConversationName = name;
			g_SignalData.iValue = 1; -- for mission conversation 
			g_SignalData.fValue = 0; -- for conversation not in place
			AI.Signal(SIGNALFILTER_NEARESTGROUP,0,"CONVERSATION_REQUEST",self.id, g_SignalData);
			return 1
		end
	end
	
	return nil

end



--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:MakeRandomConversation(name)

	-- Conversation in place: the two guys are already close and don't have to move
	-- to each other's place (also valid when they're walking together)
	-- TO DO Conversation not in place: the guys requested for conversation must go to 
	-- the requestor
	if(name == nil or name=="") then
		name = AI.FindObjectOfType(self.id,25,AIAnchorTable.IDLE_RANDOM_TALK_INPLACE);
	end

	if (name and name~="") then
		if (self.AI.CurrentConversation == nil) then
			self.AI.ConvPartecipants = 0;
			self.ConvActors = {nil,nil,nil,nil,nil,nil,nil};
			self.ConversationName = name;
			g_SignalData.iValue = 2; -- for idle conversation 
			g_SignalData.fValue = 1; -- for conversation in place

			AI.Signal(SIGNALFILTER_GROUPONLY,0,"CONVERSATION_REQUEST",self.id, g_SignalData);
			return 1
		end
	end

	name = AI.FindObjectOfType(self.id,25,AIAnchorTable.IDLE_RANDOM_TALK);
	
	if (name) then
		if (self.AI.CurrentConversation == nil) then
			self.AI.ConvPartecipants = 0;
			self.ConvActors = {nil,nil,nil,nil,nil,nil,nil};
			self.ConversationName = name;
			g_SignalData.iValue = 2; -- for idle conversation 
			g_SignalData.fValue = 0; -- for conversation not in place
			AI.Signal(SIGNALFILTER_NEARESTGROUP,0,"CONVERSATION_REQUEST",self.id, g_SignalData);
			return 1
		end
	end
	
	return nil

end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:StopConversation()
	
	if (self.AI.CurrentConversation) then
		self.AI.CurrentConversation:Stop(self);
--		self:StopDialog();
		self.AI.CurrentConversation = nil;
	end
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:RushTactic( probability)

	if (self.Properties.fRushPercentage) then 
		if (self.Properties.fRushPercentage>0) then
			local percent = GetHealthPercentage();   -- self.actor:GetHealth() / 100;
			if (percent<self.Properties.fRushPercentage) then
				local rnd=random(1,10);
				if (rnd>probability) then
					AI.Signal(SIGNALFILTER_SUPERGROUP,1,"RUSH_TARGET",self.id);
					AI.Signal(SIGNALID_READIBILITY, 1, "LO_RUSH_TACTIC",self.id);
				end
			end
		end
	end
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:MakeAlerted( noDrawWeapon )

	self:StopConversation();
	
	if(noDrawWeapon~=nil) then return end
	
	self:DrawWeaponNow( );

end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:MakeIdle()
	-- Make this guy idle
	AI.ChangeParameter(self.id,AIPARAM_SIGHTRANGE,self.Properties.Perception.sightrange);
	AI.ChangeParameter(self.id,AIPARAM_FOVPRIMARY,self.Properties.Perception.FOVPrimary);
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:InitAIRelaxed()
	
	self:MakeIdle();
	self:InsertSubpipe(0,"stance_relaxed");
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:InitAICombat()

	self.AI.GunOut = true;
	self:DrawWeaponNow( );
	self.RunToTrigger = nil;
	self:InsertSubpipe(0,"stance_stand");
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:InsertAnimationPipe( anim_name , layer_override, signal_at_end, fBlendTime, multiplier)

	if (fBlendTime==nil) then
		fBlendTime = 0.33;
	end

	if (multiplier==nil) then 
		multiplier = 1;
	end


	AI.CreateGoalPipe("temp_animation_delay");
	AI.PushGoal("temp_animation_delay","timeout",1,self:GetAnimationLength(0, anim_name)*multiplier);
	if (signal_at_end) then
		AI.PushGoal("temp_animation_delay","signal",1,-1,signal_at_end,0);
	end

	if (self:InsertSubpipe(0,"temp_animation_delay")) then
		if (layer_override) then
			self:StartAnimation(0,anim_name,layer_override,fBlendTime);
		else
			self:StartAnimation(0,anim_name,4,fBlendTime);
		end
	end

end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:MakeRandomIdleAnimation()
	
--do return end

	-- pick random idle animation
	local MyAnim = IdleManager:GetIdleAnimation( self );
	if (MyAnim) then
		self:InsertAnimationPipe(MyAnim.Name);
	else
		System.Warning( "[AI] [ART ERROR][DESIGN ERRoR] Model "..self.Properties.fileModel.." used, assigned a job BUT HAS NO idleXX animations.");
	end
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:NotifyGroup()
	return 1
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:GettingAlerted()

	if (self.Properties.special == 1) then 
		do return end
	end

	self:DrawWeaponNow( );
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:Blind_RunToAlarm()

	do return end
	
	if (self.Properties.special == 1) then 
		do return end
	end

	self.AI.ALARMNAME = AI.FindObjectOfType(self.id,30,AIAnchorTable.USE_BLIND_ALARM);		
	if (self.AI.ALARMNAME) then	
		AI.Signal(0, 2, "GOING_TO_TRIGGER",self.id);
	end

end



--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:RunToAlarm()

	do return end
	
	if (self.Properties.special == 1) then 
		do return end
	end

	local flare_name = AI.FindObjectOfType(self.id,10,AIAnchorTable.ACTION_THROW_FLARE);		
	if (flare_name) then

		AI.Signal(0, 2, "THROW_FLARE",self.id);
--		BasicPlayer.SelectGrenade(self,"FlareGrenade");
	end

	self.AI.ALARMNAME = AI.FindObjectOfType(self.id,30,AIAnchorTable.USE_PUSH_ALARM);		
	if (self.AI.ALARMNAME) then	
		AI.Signal(0, 2, "GOING_TO_TRIGGER",self.id);
	end

end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:Say( soundFile, soundData, listenerActor, sound3D )
	if (soundData~=nil) then
		if(listenerActor~=nil and listenerActor~=self) then
			local v = self:GetVelocity();
			local x = v.x;
			local y = v.y;
			local z = v.z;
			local d = x*x+y*y+z*z;
			if(d<0.6) then
				-- make the speaker look at the listener only if he's not moving
				self:InsertSubpipe(0,"look_at_lastop",listenerActor.id);
			end
		end
--		AI.LogEvent("Saying "..soundFile);
		self.AI.myCurrentDialog = soundData;
		if(self.AI.myCurrentDialog ~= nil) then
			if(sound3D) then 
				Sound.SetSoundPosition(self.AI.myCurrentDialog, self:GetWorldPos());
			end
			Sound.PlaySound(self.AI.myCurrentDialog);
		end
	--	self:SayDialog(phrase.soundFile, phrase.Volume, phrase.min, phrase.max, SOUND_DEFAULT_3D,AIConvTable);
	end
end



--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:ReadibilityContact()

	local targetFwd = g_Vectors.temp_v2;
	local self2target = g_Vectors.temp_v1;

	AI.GetAttentionTargetDirection(self.id, targetFwd);
	AI.GetAttentionTargetPosition(self.id, self2target);
	FastDifferenceVectors(self2target, self2target, self:GetWorldPos());	

	local dot=dotproduct3d(self2target, targetFwd);
	
	if(dot<0) then
		self:Readibility("first_contact_group");--,0,100);
	else
		self:Readibility("first_contact_group_back");--,0,100);	
	end

end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:Readibility(signal,bSkipGroupCheck,priority,delayMin,delayMax)

--	AI.LogEvent(" >>>> Readibility "..signal);

	g_SignalData.iValue = 0;
	g_SignalData.fValue = 0;

	if( priority ) then
		g_SignalData.iValue = priority;
	end
	
	if( delayMin ) then
		if( not delayMax ) then
			g_SignalData.fValue = delayMin;
		else
			local range = delayMax - delayMin;
			g_SignalData.fValue = delayMin + (random(1000)/1000.0)*range;
		end
	end

	AI.Signal(SIGNALID_READIBILITY, 1, signal,self.id,g_SignalData);	
	
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:GetReadibilityLength(signal)
	return 4000;
end

function BasicAI:GetNearestInGroup()
	local groupCount = AI.GetGroupCount( self.id, GROUP_ENABLED );
	local nearest = nil;
	local pos = self:GetWorldPos();
	local minDistance = 1000.0;
	if (groupCount > 1) then	
		local i = 1;
		while (i <= groupCount) do
			local member = AI.GetGroupMember( self.id, i, GROUP_ENABLED, AIOBJECT_PUPPET );
			if ( member.id ~= self.id ) then
				local distance = DistanceSqVectors( pos, member:GetWorldPos() );
				if ( distance < minDistance ) then
					minDistance = distance;
					nearest = member;
				end
			end
			i = i+1;
		end
	end
	return nearest;
end

--------------------------------------------------------------------------------------------------------
--
--
-- 						weapon related methods
--
--
--
--------------------------------------------------------------------------------------------------------
function BasicAI:AssignPrimaryWeapon()
  -- this is the new way of equiping actors
	local equipmentPack = self.Properties.equip_EquipmentPack;
	if (equipmentPack and equipmentPack ~= "") then
		self.primaryWeapon = ItemSystem.GetPackPrimaryItem(equipmentPack) or "";
		
    -- get secondary weapon
    if (ItemSystem.GetPackNumItems(equipmentPack)>1) then
	    self.secondaryWeapon = ItemSystem.GetPackItemByIndex(equipmentPack, 1) or "";
			-- make sure any kind of grenades are not considered as secondary weapon
	    if( self.secondaryWeapon == "AIFlashbangs" or
			    self.secondaryWeapon == "AISmokeGrenades" or
	  		  self.secondaryWeapon == "AIGrenades" ) then
		    		self.secondaryWeapon = "";
	    end		
	    --Log("%s has secondary weapon %s", self:GetName(), self.secondaryWeapon);
    end		
	end
end

--
--------------------------------------------------------------------------------------------------------
function BasicAI:DrawWeaponNow( skipCheck )
	if ( skipCheck~=1 and self.inventory:GetCurrentItem() ) then
		-- there is something in his hands - don't change weapon, just make sure it's out
		return
	end

	--	self:HolsterItem(false);
	local weapon = self.inventory:GetCurrentItem();
	-- make sure we select primary weapon
	if (weapon==nil or weapon.class~=self.primaryWeapon) then
		self.actor:SelectItemByName(self.primaryWeapon);
	end
		
	-- lets set burst fire mode - only Kuang has it currently
	weapon = self.inventory:GetCurrentItem();
	if(weapon~=nil and weapon.weapon~=nil and weapon.class==self.primaryWeapon) then
		weapon.weapon:SetCurrentFireMode("burst");
	end	
	
--	self:UseLAM("FlashLight",true);
--	self:UseLAM("Laser",true);
end

--
--------------------------------------------------------------------------------------------------------
-- check selected weapon
-- returns nil if no weapon selected, 0 if primary weapon selected, 1 if secondary
-- 
function BasicAI:CheckCurWeapon( checkDistance )

	if(checkDistance~=nil) then
		local targetDist = AI.GetAttentionTargetDistance(self.id);
		if(targetDist and targetDist>10.5) then return nil end
	end
	
	local currentWeapon = self.inventory:GetCurrentItem();
	if(currentWeapon==nil) then return nil end
	if(currentWeapon.class==self.primaryWeapon) then return 0 end	
	if(currentWeapon.class==self.secondaryWeapon) then return 1 end
	
end

--
--------------------------------------------------------------------------------------------------------
function BasicAI:HasSecondaryWeapon()
	local secondaryWeaponId=self.inventory:GetItemByClass(self.secondaryWeapon);
	-- see if secondary weapon is awailable
	if(secondaryWeaponId==nil) then		return nil	end		
	do return 1 end
end

--
--------------------------------------------------------------------------------------------------------
function BasicAI:SelectSecondaryWeapon()

	local secondaryWeaponId=self.inventory:GetItemByClass(self.secondaryWeapon);
	-- see if secondary weapon is awailable
	if(secondaryWeaponId==nil) then		return nil	end		
	-- see if it is already selected
	local currentWeapon = self.inventory:GetCurrentItem();
	--AI.LogComment(entity:GetName().." ScoutIdle:Constructor weapon = "..weapon.class);
	if(currentWeapon~=nil and currentWeapon.class==self.secondaryWeapon) then return nil end
--	if(secondaryWeaponId==self.inventory:GetCurrentItem()) then		return nil	end		
	
	self.actor:SelectItemByName( self.secondaryWeapon );
	
	do return 1 end
end

--
--------------------------------------------------------------------------------------------------------
function BasicAI:SelectPrimaryWeapon()
	self.actor:SelectItemByName(self.primaryWeapon);
end


--
--------------------------------------------------------------------------------------------------------
function BasicAI:Reload()
	local weapon = self.inventory:GetCurrentItem();
	if(weapon~=nil and weapon.weapon~=nil) then
		weapon.weapon:Reload();
	else
		AI.LogEvent(">>>>"..self:GetName().." FAILED TO RELOAD WEAPON!");
	end	
end


function BasicAI:DropItem()
	local item = self.inventory:GetCurrentItem();
	if (item) then
		item:Drop();
	end
end


function BasicAI:IsOnVehicle()
if (self.vehicleId) then
		return true;
	end
	
	return false;
end

function BasicAI:OnItemPicked(what)
	if (what.weapon) then
		ItemSystem:SetActorItem(self, what.id);
	end
end

function BasicAI:OnItemDropped(what)
end

function BasicAI:AnimationEvent(event,value)
	--Log("BasicAI:AnimationEvent "..event.." "..value);
	if ( event == "setIdleAction" ) then
		self.actor:SetAnimationInput( "Action", "idle" );
	elseif ( event == "useObject" ) then
		local navObject = AI.GetLastUsedSmartObject( self.id );
		if ( navObject and navObject.OnUsed ) then
			navObject:OnUsed( self, 2 );
			AI.SmartObjectEvent( "OnUsed", navObject.id, self.id );
		end
	elseif ( event == "grabObject" ) then
		local grabObject = AI.GetLastUsedSmartObject( self.id );
		if ( grabObject ) then
			self:GrabObject( grabObject );
			self.actor:SetAnimationInput( "Action", "carryBox" );
		end
	elseif ( event == "dropObject" ) then
		self.actor:SetAnimationInput( "Action", "idle" );
		self:DropObject( false );
	elseif ( event == "dropItem" ) then
		self:DropItem();
	elseif ( event == "kickObject" ) then
		local navObject = AI.GetLastUsedSmartObject( self.id );
		if ( navObject ) then
			if ( navObject.BreachDoor ) then
				navObject:BreachDoor();
			else
				navObject:AddImpulse( -1, nil, self:GetDirectionVector(1), self:GetMass(), 1 );
			end
		end
--	elseif ( event == "ThrowGrenade" ) then
	elseif ( BasicActor.AnimationEvent ) then
		BasicActor.AnimationEvent(self,event,value);
	end
end

-----------------------------------------------------------------------------------
function BasicAI:ScriptEvent(event,value,str)
	if (event == "splash") then
		if(_time - self.lastSplash > 1.0) then
			self.lastSplash = _time;
			PlayRandomSound(self,ActorShared.splash_sounds);
		end
	else	
		BasicActor.ScriptEvent(self,event,value,str);
	end
end


--------------------------------------------------------------------------------
function BasicAI:CreateFormation(otherLeader, bPersistent )
	local target;
	if(g_StringTemp1) then
		target = System.GetEntityByName(g_StringTemp1);
	end
	g_SignalData.point = g_SignalData_point;
	if(target~=nil) then
		CopyVector(g_SignalData.point, target:GetWorldPos());
		g_SignalData.point.z = self:GetWorldPos().z;
	else
		CopyVector(g_SignalData.point, g_Vectors.v000);
	end
	if(otherLeader and not otherLeader:IsDead()) then
		g_SignalData.id = otherLeader.id;
	else
		g_SignalData.id = self.id;
	end
	if(bPersistent) then
		g_SignalData.fValue = 1;
	else
		g_SignalData.fValue = 0;
	end
	g_SignalData.iValue = AI.GetGroupOf(self.id);
	self.AI.Follow = true;		
	AI.Signal(SIGNALFILTER_LEADER,0,"ORD_FOLLOW",self.id,g_SignalData);
 	g_StringTemp1 = ""; -- safer for further calls, since it's an optional parameter
end


--------------------------------------------------------------------------------
function BasicAI:JoinFormation(groupid)
	g_SignalData.iValue = groupid;
	self.AI.Follow = true;		
	AI.Signal(SIGNALFILTER_LEADER,0,"ORD_FOLLOW",self.id,g_SignalData);
end


-- temporary; to be tuned for a more general purpose
function BasicAI:GetAimingPoint(weaponType,target)
--	if(self.weaponId == nil) then
--		AI.LogEvent("No weapon found for aiming by "..self:GetName());
--		do return end
--	end
--	local weapon =System.GetEntity(self.weaponId);
--	if(weapon) then
		-- to do at least: get the weapon type name from the weapon itself
		if(weaponType=="LAW") then
			local vel = target:GetVelocity();
			local pos = target:GetWorldPos();
			local myPos = self:GetWorldPos();
--			local delayTime = 1;--1.5; --should be the delay between issuing the fire command and the actual shoot
--			local dx = vel.x*delayTime;
--			local dy = vel.y*delayTime;
--			local dz = vel.z*delayTime;
			local sx = (pos.x - myPos.x);
			local sy = (pos.y - myPos.y);
			local sz = (pos.z - myPos.z);
			local dist = math.sqrt(sx*sx + sy*sy + sz*sz);
			local vProj = 50;
			local t = dist/vProj;-- approximate time of flight of bullet 
			--AI.LogEvent("vel = ("..vel.x..","..vel.y..","..vel.z..") dist="..dist.." t="..t);
			g_Vectors.temp.y = pos.y + vel.y*t*1.2;
			g_Vectors.temp.x = pos.x + vel.x*t*1.2;
			g_Vectors.temp.z = pos.z +0.7;-- + dist/40+vel.z*delayTime;
			AI.SetRefPointPosition(self.id,g_Vectors.temp);
		end
--	end
end


function BasicAI:CheckWalkFollower()
	if(self.AI.bIsLeader) then
	
		g_StringTemp1 = "";--self:GetName().."_P0";
		g_SignalData.ObjectName = "row2";
		self:CreateFormation();
		return true;
	end
	return false;
end



----------------------------------------------------------------------------------------------------
function BasicAI:SetAnimationStartEndEvents(slot, animation, funcStart,funcEnd)
	if (animation and animation ~="") then
		self.onAnimationStart[animation] = funcStart;
		self.onAnimationEnd[animation] = funcEnd;
		self:SetAnimationEvent(slot, animation);
	end
end

----------------------------------------------------------------------------------------------------
function BasicAI.Client:OnStartAnimation(animation)
	local func = self.onAnimationStart[animation];
	
	if (func) then
		func(self, animation);
--		self.onAnimationStart[animation] = nil;
	end
end


----------------------------------------------------------------------------------------------------
function BasicAI.Client:OnEndAnimation(animation)
	local func = self.onAnimationEnd[animation];
	if (func) then
		func(self, animation);
--		self.onAnimationEnd[animation] = nil;
	end
end

----------------------------------------------------------------------------------------------------
--function BasicAI.Client:OnTimer(timerId)
----------------------------------------------------------------------------------------------------
function BasicAI.OnDeath( entity )
	AI.SetSmartObjectState( entity.id, "Dead" );

	-- notify spawner - so it counts down and updates
	if(entity.AI.spawnerListenerId) then
		local spawnerEnt = System.GetEntity(entity.AI.spawnerListenerId);
		if(spawnerEnt) then
			spawnerEnt:UnitDown();
		end
	end

	
--	AI.LogEvent(" >>>> BasicAI.OnDeath "..entity:GetName());
	--the guy is dead	

--	BasicAIEvent.Event_Dead(entity);

 	if(entity.AI.theVehicle and entity.AI.theVehicle:IsDriver(entity.id)) then
 			-- disable vehicle's AI
 		if (entity.AI.theVehicle.AIDriver) then
 		  entity.AI.theVehicle:AIDriver(0);
 		end
 		entity.AI.theVehicle=nil;
 	end

	if(entity.Event_Dead) then
		entity:Event_Dead(entity);	
	end	
	
	-- Notify AI system about this	
	--AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 10, "OnGroupMemberDied", entity.id);

--	entity:TriggerEvent(AIEVENT_AGENTDIED);
	-- re-register actor with Action_R
--	AI.RegisterWithAI( entity.id, AIAnchorTable.ACTION_RECOG_CORPSE );
	entity.bUseOrderEnabled = false;

	-- free mounted weapon
	if (entity.AI.current_mounted_weapon) then
		if (entity.AI.current_mounted_weapon.item:GetOwnerId() == entity.id) then
			entity.AI.current_mounted_weapon.item:Use( entity.id );--Stop using
			entity.AI.current_mounted_weapon.reserved = nil;
			AI.ModifySmartObjectStates(entity.AI.current_mounted_weapon.id,"Idle,-Busy");				
		end
		entity.AI.current_mounted_weapon.listPotentialUsers = nil;
		entity.AI.current_mounted_weapon = nil;
		AI.ModifySmartObjectStates(entity.id,"-Busy");			
	end	
	-- check ammo count modifier
	if(entity.AI.AmmoCountModifier and entity.AI.AmmoCountModifier>0) then 
		entity:ModifyAmmo();
	end
	
	AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "MAN_DOWN", entity.id);
	
end

function BasicAI:ModifyAmmo(multiplier)
	
	local item = self.inventory:GetCurrentItem();
	if(item) then 
		local currWeapon = item.weapon;
		if(currWeapon ) then 
			if(multiplier) then
				local ammoCount = currWeapon:GetClipSize();
				currWeapon:SetAmmoCount(nil, ammoCount*multiplier)
			elseif(self.AI.AmmoCountModifier) then 
				if( self.AI.AmmoCountModifier==0) then 
					self.AI.AmmoCountModifier=1;
				end
				local ammoCount = currWeapon:GetAmmoCount();
				currWeapon:SetAmmoCount(nil, ammoCount/self.AI.AmmoCountModifier);
			end
			self.AI.AmmoCountModifier = multiplier;
		end
	end
end

function BasicAI:GetAmmoLeftPercent()
	-- returns how much of the clip is still left in percent.
	local item = self.inventory:GetCurrentItem();
	if(item) then 
		local currWeapon = item.weapon;
		if(currWeapon ) then 
			local clipSize = currWeapon:GetClipSize();
			local ammoCount = currWeapon:GetAmmoCount();
			return ammoCount / clipSize;
		end
	end
	return 1;
end

function BasicAI:IsSquadMate()
	if (self.Properties.bSquadMate and (self.Properties.bSquadMate ~= 0)) then
		return true;
	else
		return false;
	end
end

function BasicAI:UpdateRadar(radarContact)
	if (not self:IsDead()) then
		
		if (radarContact) then
			if (self:IsSquadMate()) then
				radarContact.color[1] = 64;
				radarContact.color[2] = 64;
				radarContact.color[3] = 255;
				radarContact.img = "textures/gui/hud/radar/enemy_grey.dds";
				radarContact.radius = 4;
				
				if (self.hit) then
					radarContact.blinking = 1.0;
					radarContact.blinkColor[1] = 255;
					radarContact.blinkColor[2] = 0;
					radarContact.blinkColor[3] = 0;
					self.hit = nil;
				end			
			else
				
				local alertness = self.Behaviour.alertness;
				
				if (g_localActor) then
					local targetName = AI.GetAttentionTargetOf(self.id);
	              	--Log(tostring(targetName));
	                if (targetName and targetName == g_localActor:GetName()) then
	                	alertness = 2;
	                	
	                	radarContact.blinking = 1.0;
						radarContact.blinkColor[1] = 255;
						radarContact.blinkColor[2] = 255;
						radarContact.blinkColor[3] = 255;
	                end
	            end
				
				--idle
				if (not alertness or alertness == 0) then
					radarContact.color[1] = 26;
					radarContact.color[2] = 255;
					radarContact.color[3] = 26;
				--alerted
				elseif (alertness == 1) then
					radarContact.color[1] = 255;
					radarContact.color[2] = 128;
					radarContact.color[3] = 26;
				--combat
				else
					radarContact.color[1] = 255;
					radarContact.color[2] = 26;
					radarContact.color[3] = 26;
				end
				
				radarContact.img = "textures/gui/hud/radar/enemy_grey.dds";
			end
			
			if (self.speakingTime and self.speakingTime > 0) then
				AI.LogEvent(self:GetName() .."speaking for ".. self.speakingTime * 0.001 .." seconds");
				radarContact.blinking = 1.0+self.speakingTime * 0.001;
				radarContact.blinkColor[1] = 255;
				radarContact.blinkColor[2] = 255;
				radarContact.blinkColor[3] = 255;

				self.speakingTime = 0;
			end	
		end
		
		return true;
	else	
		return false;
	end
end

function BasicAI:MotionTrackable(radarContact)
	--enable the readability check for every motion tracked AI
	self.bCheckReadabilityLength = true;
	return (not self:IsDead()) and (not self:IsOnVehicle());
end

-----------------------------------------------------------
function BasicAI:RequestVehicle(goaltype,target)
	if(target==nil) then
		local targetName = AI.GetAttentionTargetOf(self.id);
		if(targetName) then
			target = System.GetEntityByName(targetName);
		else -- no target at all
			AI.LogEvent(self:GetName().." requesting vehicle with no target ");
			return;
		end
	end

	if (target and target.id) then 
		AI.LogEvent(self:GetName().." requesting vehicle for target "..target:GetName());
		g_SignalData.id = target.id;
		CopyVector(g_SignalData.point2,g_Vectors.v000);
	else -- target is there, but it's not an entity
		AI.LogEvent(self:GetName().." requesting vehicle for AI target "..targetName);
		g_SignalData.id = NULL_ENTITY;
		AI.GetAttentionTargetPosition(self.id,g_SignalData.point2);
	end
			
	CopyVector(g_SignalData.point, self:GetWorldPos());
	
	g_SignalData.iValue = goaltype;
	AI.Signal(SIGNALFILTER_LEADER,0,"OnVehicleRequest",self.id,g_SignalData);
	self.vehicleGoalType = goaltype;
end

function BasicAI:CheckReinforcements()
	AI.LogEvent(self:GetName().." >>> checking reinforcements, group count="..AI.GetGroupCount(self.id,GROUP_ENABLED,AIOBJECT_PUPPET));
	if(AI.GetGroupCount(self.id,GROUP_ENABLED,AIOBJECT_PUPPET)<3) then -- the 3rd is the one just died
		AI.LogEvent(self:GetName().." found less than 3 people");
		local anchorName = AI.FindObjectOfType(self.id,30,AIAnchorTable.USE_RADIO_ALARM,0);
		if(anchorName == nil) then
			-- achorName = other kind of anchor (call reinforcements by waving hand etc)
		end
		if(anchorName) then
			AI.LogEvent(self:GetName().." found an anchor for reinforcement");
			local anchor = System.GetEntityByName(anchorName);
			if(anchor) then
				self:InsertSubpipe(0,"do_it_standing");
				self:InsertSubpipe(0,"do_it_running");
--				anchor:Event_Use(self);
--				anchor:Event_Disable(self);
				
			end
		end
	end
end

function BasicAI:SetRefPointAroundBeaconRandom(distance)
	local targetPos = g_Vectors.temp;
--AI.LogEvent("BasicAI:SetRefPointAroundBeaconRandom>>> "); 	
	if( AI.GetBeaconPosition(self.id,targetPos) == nil ) then	return nil; end
--AI.LogEvent("BasicAI:SetRefPointAroundBeaconRandom>>> good beacon at "..Vec2Str(targetPos));
	local targetDir = g_Vectors.temp_v1;
	if(random(10)<5) then
		targetDir.x = -randomF(1,distance);
	else
		targetDir.x = randomF(1,distance);
	end
	if(random(10)<5) then
		targetDir.y = -randomF(1,distance);
	else
		targetDir.y = randomF(1,distance);
	end
	local	hits = Physics.RayWorldIntersection(targetPos,targetDir,2,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
	local actualDistance = distance;
	if(hits>0) then
		local firstHit = g_HitTable[1];
		AI.SetRefPointPosition(self.id, firstHit.pos);
		actualDistance = firstHit.dist;
--AI.LogEvent("BasicAI:SetRefPointAroundBeaconRandom>>> hit  "..Vec2Str(firstHit.pos));
	else
		targetPos.x = targetPos.x + targetDir.x;
		targetPos.y = targetPos.y + targetDir.y;
		AI.SetRefPointPosition(self.id, targetPos);
--AI.LogEvent("BasicAI:SetRefPointAroundBeaconRandom>>> free  "..Vec2Str(targetPos));
	end
--AI.LogEvent("BasicAI:SetRefPointAroundBeaconRandom>>> dist "..actualDistance);
	return actualDistance;
end

function BasicAI:SetRefPointAtDistanceFromTarget(distance)
	local targetPos = g_Vectors.temp;
	local targetDir = g_Vectors.temp_v1;

	if(AI.GetNavigationType(self.id) ~= NAV_TRIANGULAR) then 
		return false;
	end

	AI.GetAttentionTargetDirection(self.id, targetDir);
--	AI.LogEvent("TARGET DIR: "..Vec2Str(targetDir));
	if(LengthSqVector(targetDir)<0.05) then 
		-- target is still, no direction to approach
		return false; 
	end
	AI.GetAttentionTargetPosition(self.id, targetPos);
--	FastSumVectors(targetPos,targetPos,targetDir);
	ScaleVectorInPlace(targetDir, -distance);

	local	hits = Physics.RayWorldIntersection(targetPos,targetDir,2,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
	local actualDistance = distance;
	if(hits>0) then
		local firstHit = g_HitTable[1];
		AI.SetRefPointPosition(self.id, firstHit.pos);
		actualDistance = firstHit.dist;
	else
		FastSumVectors(targetPos,targetPos,targetDir);
		AI.SetRefPointPosition(self.id, targetPos);
	end
	return actualDistance;
end

----------------------------------------------------------------------------------
function BasicAI:GetWeaponDir(weapon)
	return self.fireDir;
end

----------------------------------------------------------------------------------
function BasicAI:DrawWeaponDelay(time)
	Script.SetTimerForFunction(random(100,time*1000),"BasicAI.OnDelayedDrawWeapon",self);
end

----------------------------------------------------------------------------------
function BasicAI:OnDelayedDrawWeapon(timerid)
	if(not self.inventory:GetCurrentItemId()) then
		self:HolsterItem(false);
	end
end


----------------------------------------------------------------------------------
function BasicAI:ProtectSpot()
	return AI.GetAnchor(self.id,AIAnchorTable.COMBAT_PROTECT_THIS_POINT,15);
end



----------------------------------------------------------------------------------
function BasicAI:Supress( stress )
	
	if(self.supressed == 0) then
		Script.SetTimerForFunction(500,"BasicAI.SupressUpdate",self);
	end	
	self.supressed = self.supressed + stress;
	if( self.supressed > self.supressedTrh ) then
		AI.Signal(SIGNALFILTER_SENDER, 0, "SUPRESSED",self.id);
		self.supressed = self.supressed/2;
	end	

--AI.LogEvent(">>>  "..self.supressed);
	
end


----------------------------------------------------------------------------------
function BasicAI:SupressUpdate( timerId )
	if(self.supressed > 0) then
		self.supressed = self.supressed - 1;
		if( self.supressed < 0 ) then
			self.supressed = 0;
		else
			Script.SetTimerForFunction(1000,"BasicAI.SupressUpdate",self);		
		end	
	end	
end



----------------------------------------------------------------------------------

function BasicAI:Expose()
	Net.Expose{
		Class = self,
		ClientMethods = {
		},
		ServerMethods = {
		},
		ServerProperties = {
		}
	};
end

----------------------------------------------------------------------------------
-- BasicAI:IsTargetAimable returns true if attention target is within weapon's
-- rotation limits, or there's no attention target.
-- WARNING: It assumes that weapons up vector is (0, 0, 1) !!!
--function BasicAI:IsTargetAimable( mountedWeapon )
--	--AI.LogEvent("IsTargetAimable of "..self:GetName());
--	local targetPos = g_Vectors.temp;
--	AI.GetAttentionTargetPosition( self.id, targetPos );
--	if ( targetPos.x ) then
--		--AI.LogEvent("    target found...");
--		local weaponPos = mountedWeapon:GetWorldPos();
--		local targetDir = g_Vectors.temp_v1;
--		FastDifferenceVectors( targetDir, targetPos, weaponPos );
--		
--		local targetDirXY = g_Vectors.temp_v2;
--		targetDirXY.x = targetDir.x;
--		targetDirXY.y = targetDir.y;
--		targetDirXY.z = 0;
--		
--		local lengthXY = LengthVector( targetDirXY );
--		if ( lengthXY < 7 ) then
--			--AI.LogEvent("    too close (< 7m)");
--			return false;
--		end
--		
--		FastScaleVector( targetDirXY, targetDirXY, 1.0/lengthXY );
--	
--		local mountDir = g_Vectors.temp;
--		CopyVector(mountDir,mountedWeapon.item:GetMountedDir());
--		
--		local mountAngles = g_Vectors.temp_v3;
--		CopyVector(mountAngles,mountedWeapon.item:GetMountedAngleLimits());
--		--AI.LogEvent("MountDir ="..Vec2Str(mountDir).." mount Angles="..Vec2Str(mountAngles));
--		-- if yaw is limited
--		if( mountAngles.z>0 and mountAngles.z<159 )	then
--			local yawRange = mountAngles.z * g_Deg2Rad;
--			local deltaYaw = mountDir.x*targetDirXY.x + mountDir.y*targetDirXY.y;
--			--AI.LogEvent("deltaYaw = "..deltaYaw);
--			if ( deltaYaw < math.cos(yawRange) ) then
--				--AI.LogEvent("    outside yaw limits");
--				return false;
--			end
--		end
--			
--		local minPitch = mountAngles.x * g_Deg2Rad;
--		local maxPitch = mountAngles.y * g_Deg2Rad;
--		--AI.LogEvent("minPitch = "..minPitch.." maxPitch = "..maxPitch);
--		
--		-- TO DO: remove this fix for min and max pitch when they'll be fixed in C++ code - now 0,90 means actually -45,+45
--		--maxPitch = (maxPitch - minPitch)/2;					------
--		--minPitch = -maxPitch;												------
--		--------------------------------------------------
--		
--		local pitch = math.atan( targetDir.z/lengthXY );
--		if ( (pitch < minPitch) or (pitch > maxPitch) ) then
--			--AI.LogEvent("    outside pitch limits");
--			return false;
--		end
--		
--		-- check target distance and where he's going
--		local targetVel = g_Vectors.temp_v3;
--		local target = AI.GetAttentionTargetEntity(self.id);
--		if(target) then
--			target:GetVelocity(targetVel);
--			targetVel.z=0;
--			local lengthVel = LengthVector( targetVel );
--			if(lengthVel >0) then
--				FastScaleVector( targetVel, targetVel, 1.0/lengthVel );
--			end
--			local cosine = targetDirXY.x*targetVel.x + targetDirXY.y*targetVel.y;
--			if(lengthXY<5 and cosine<=0) then
--				--AI.LogEvent("    target (getting) too close");
--				return false;
--			end	
--		end
--
--		
--	end
--	--AI.LogEvent("    returns true");
--	return true;
--end

function BasicAI:SetRefPointToStrafeObstacle(dist)
	if(dist==nil) then
		dist=3;
	end
	local moveDir = g_Vectors.temp;
	local targetDir = g_Vectors.temp_v1;
	local refPos = g_Vectors.temp_v2;
	local targetPos = g_Vectors.temp_v3;
	
	AI.GetAttentionTargetPosition(self.id,targetPos);
	

	CopyVector(moveDir, self:GetDirectionVector(0));
	local dir = random(0,1)*2*dist - dist;
	
	ScaleVectorInPlace(moveDir, dir); 
	FastSumVectors(refPos,self:GetWorldPos(),moveDir);
	FastDifferenceVectors(targetDir,	targetPos,refPos);
	
	local	hits = Physics.RayWorldIntersection(refPos,targetDir,10,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
	if(hits>0) then
		-- try opposite direction
		ScaleVectorInPlace(moveDir, -1); 
		FastSumVectors(refPos,self:GetWorldPos(),moveDir);
		FastDifferenceVectors(targetDir,	targetPos,refPos);
	
		local	hits = Physics.RayWorldIntersection(refPos,targetDir,10,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
		if(hits>0) then
			return false;
		end
	end
	
	AI.SetRefPointPosition(self.id,refPos);
	
	return true;
end

----------------------------------------------------------------------------------
function BasicAI:SetRefPointToStrafePoint(point,dist)
	if(dist==nil) then
		dist=3;
	end
	local moveDir = g_Vectors.temp;
	local targetDir = g_Vectors.temp_v1;
	local pointDir = g_Vectors.temp_v1; -- beware, same as targetDir
	local refPos = g_Vectors.temp_v2;
	local targetPos = g_Vectors.temp_v3;
	
	AI.GetAttentionTargetPosition(self.id,targetPos);

	CopyVector(moveDir, self:GetDirectionVector(0));

	FastDifferenceVectors(pointDir,	point,refPos);
	NormalizeVector(pointDir);
	
	local x = dotproduct3d( self:GetDirectionVector(1), pointDir );
	local dir;
	if(x>0) then
		dir = dist;
	else
		dir = -dist;
	end
	ScaleVectorInPlace(moveDir, dir); 
	FastSumVectors(refPos,self:GetWorldPos(),moveDir);
	FastDifferenceVectors(targetDir,	targetPos,refPos);
	
	local	hits = Physics.RayWorldIntersection(refPos,targetDir,10,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
	if(hits>0) then
		-- try opposite direction
		ScaleVectorInPlace(moveDir, -1); 
		FastSumVectors(refPos,self:GetWorldPos(),moveDir);
		FastDifferenceVectors(targetDir,	targetPos,refPos);
	
		local	hits = Physics.RayWorldIntersection(refPos,targetDir,10,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
		if(hits>0) then
			return false;
		end
	end
	
	AI.SetRefPointPosition(self.id,refPos);
	
	return true;
end
----------------------------------------------------------------------------------

function BasicAI:DropObjectAtPoint(point)
	-- TO DO: only horizontal impulse by now; so it assumes that the thrown object
	-- is at a higher place than the point.
  if ( self.grabParams and self.grabParams.entityId) then
		local grab = System.GetEntity( self.grabParams.entityId );
		self:DropObject( false );

		if ( grab ) then
			local mass = grab:GetMass();
			local dir = g_Vectors.temp;
			FastDifferenceVectors(dir, point, grab:GetPos());

			if(dir.z <0) then -- temporary: consider only target at lower height
				local z = math.abs(dir.z);
				
				local dispXY = math.sqrt(dir.x*dir.x+dir.y*dir.y);
				local gravity = 9.8;
				if (z<0.05) then 
					-- avoid degenerated situations ( z of grabbed object and target is almost the same)
					z = 0.05;
				end
				local Vxy = dispXY*math.sqrt(gravity/(z*2));
				-- consider accuracy
				if(self.Properties.accuracy) then 
					local acc = 1 - self.Properties.accuracy;
					if(acc>0) then
						acc = clamp(acc,0,1);
						local  err = dispXY/4;
						dir.x= dir.x + random(-err,err)*acc;
						dir.y= dir.y + random(-err,err)*acc;
					end
				end
				dir.z = 0;
				NormalizeVector(dir);
				local impulse = g_Vectors.temp_v1;
				FastScaleVector(impulse,dir,Vxy);
				FastDifferenceVectors(impulse,impulse,self:GetVelocity());
				local V = LengthVector(impulse);
				ScaleVectorInPlace(impulse, 1/V);
				local tempVelTable = {v={x=0,y=0,z=0}};
				grab:SetPhysicParams(PHYSICPARAM_VELOCITY, tempVelTable);
--				local spinpoint = g_Vectors.temp_v2;
--				spinpoint.x = random(-100,100)/200;
--				spinpoint.y = random(-100,100)/200;
--				spinpoint.z = 0;
--				local spinimpulse = g_Vectors.temp_v3;
--				spinimpulse.x = 0;
--				spinimpulse.y = 0;
--				spinimpulse.z = random(-100,100);
				grab:AddImpulse( -1, g_Vectors.v000, impulse, mass*V, 1 );
--				grab:AddImpulse( -1, spinpoint, spinimpulse, mass/100, 1 );
--
--				spinimpulse.z = -spinimpulse.z;
--
--				spinpoint.x = -spinpoint.x;
--				spinpoint.x = -spinpoint.y;
--				grab:AddImpulse( -1, spinpoint, spinimpulse, mass/100, 1 );
			end
		end
	end
end


----------------------------------------------------------------------------------
function BasicAI:SomeoneCloseToPosition(pos, dist)
	-- Check if someone is already close to beacon.
	local n = AI.GetGroupCount(self.id, GROUP_ENABLED);
	for i = 1, n do
		local member = AI.GetGroupMember(self.id, i);
		if(member ~= nul and member.id ~= self.id) then
			if(DistanceVectors(pos, member:GetPos()) < dist) then
				return true;
			end			
		end
	end
	return false;
end

----------------------------------------------------------------------------------
function BasicAI:AmIDead()

	if(self.actor:GetHealth() <= 0) then
		return 1
	end
	return nil	
end


----------------------------------------------------------------------------------
function BasicAI:IsEnemyClose( distance )

--	do return nil	end

	if(distance <= 20) then
		AI.Signal(SIGNALFILTER_SENDER, 1, "EnemyClose",self.id);
		return 1
	end
	return nil	
end


----------------------------------------------------------------------------------
-- chose prone/crouch/stand
-- returns:
-- nil - no att target, undefined
-- 1 - prone
-- 2 - crouch
-- 3 - stand
function BasicAI:SelectStance()

do return 2; end

	local targetPos = g_Vectors.temp;

	if(AI.GetAttentionTargetPosition(self.id,targetPos)) then
		local dist2;
		dist2 = LengthSqVector(targetPos);
		local rnd=random(1,10);
		if(dist2>20*20 and rnd<5 ) then --prone
			return 1 
		end		
		return 2
	end
	return nil	
end

----------------------------------------------------------------------------------
function BasicAI:ExecuteAttachWeaponAccessory(singleItem)
	local item = self.inventory:GetCurrentItem();
	if(item) then 
		local currWeapon = item.weapon;
		--System.Log("ATTACHING WEAPON ACCESSORY:"..self.AI.NextWeaponAccessory.." ON="..tostring(self.AI.NextWeaponAccessoryMount));
		if(currWeapon) then 
			if(self.AI.WeaponAccessoryMountType==0) then 
				currWeapon:AttachAccessory(self.AI.NextWeaponAccessory,false);
			elseif(self.AI.WeaponAccessoryMountType==1) then 
				currWeapon:AttachAccessory(self.AI.NextWeaponAccessory,true);
			elseif(self.AI.WeaponAccessoryMountType==2) then 
				currWeapon:SwitchAccessory(self.AI.NextWeaponAccessory);
			end
		end
		if(not singleItem) then
			AI.Signal(SIGNALFILTER_SENDER,0,"CheckNextWeaponAccessory",self.id);
		end
	end
	self.AI.MountingAccessory = false;
end

----------------------------------------------------------------------------------
function BasicAI:CheckWeaponAttachments()
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"Silencer",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"LAMRifle",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"AssaultScope",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"SniperScope",true);
	self:CheckSingleWeaponAttachment("SOCOM","LAM",true);
	self:CheckSingleWeaponAttachment("SOCOM","SOCOMSilencer",true);
	self:CheckSingleWeaponAttachment("SOCOM","LAMFlashLight",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"LAMRifleFlashLight",true);
end

----------------------------------------------------------------------------------
function BasicAI:CheckSingleWeaponAttachment(weaponClass,attachmentClass,attach)
  local itemId = self.inventory:GetItemByClass(weaponClass);
	if (itemId) then
  	local item = System.GetEntity(itemId);
  	local att = self.inventory:GetItemByClass(attachmentClass);
  	if(item and att) then 
  		local currWeapon = item.weapon;
  		if(currWeapon and currWeapon:SupportsAccessory(attachmentClass)) then 
  			currWeapon:AttachAccessory(attachmentClass,attach,true);	-- force attach
  		end
  	end
  end
end

----------------------------------------------------------------------------------
function BasicAI:SetStealth(stealth)
	self.AI.Stealth = stealth;
	if(stealth) then 
--		System.Log(self:GetName().." GOIN' STEALTH");
		AI.ChangeParameter(self.id,AIPARAM_CAMOSCALE,0.8);
	else
--		System.Log(self:GetName().." GOIN' UNCOVERED");
		AI.ChangeParameter(self.id,AIPARAM_CAMOSCALE,1);
	end
end

----------------------------------------------------------------------------------
function BasicAI:GetHealthPercentage( )

	local percent = 100 * self.actor:GetHealth() / self.actor:GetMaxHealth();
	return percent;
	
end

---------------------------------------------------------------------
function BasicAI:NanoSuitMode( mode )

	AI.LogEvent(self:GetName()..": Setting SUIT mode to "..mode);

	if(mode == self.AI.curSuitMode) then return end

	if(mode == BasicAI.SuitMode.SUIT_OFF) then
		self.actor:ActivateNanoSuit(0);
	elseif(mode == BasicAI.SuitMode.SUIT_ARMOR) then
		self.actor:SetNanoSuitMode(NANOMODE_DEFENSE);
	elseif(mode == BasicAI.SuitMode.SUIT_CLOAK) then
		self:SetCloakType(2);
		self.actor:SetNanoSuitMode(NANOMODE_CLOAK);
	elseif(mode == BasicAI.SuitMode.SUIT_POWER) then
		self.actor:SetNanoSuitMode(NANOMODE_STRENGTH);
	end	
	
	self.AI.curSuitMode = mode;	
end
	

--------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
function CreateAI(child)

	local newt={}
	mergef(newt,child,1);
	mergef(newt,BasicAI,1);
	mergef(newt,BasicAIEvent,1);
	mergef(newt,BasicAITable,1);

	MakeSpawnable(newt)

	return newt;
end

----------------------------------------------------------------------------------

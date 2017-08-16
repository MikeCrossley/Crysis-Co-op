-- Generic Idle behaviour - just change animations to make it something else
-- created by petar
--------------------------

Idle_Smoke = {
	Name = "Idle_Smoke",
	JOB = 2,
	
	SmokeParticles = { --smoke slow white
				focus = 2,
				speed = 0,
				start_color = {70,70,70},
				end_color = {0,0,0},
				count = 1,
				size = 0.02,
				size_speed = 0.1,
				gravity={x=0,y=0.2,z=0.1},
				rotation = {x=0,y=0,z=2},
				lifetime=3,
				tid = System.LoadTexture("textures\\cloud1.dds"),
				blend_type=1,
				frames=0,
				bouncyness = 0,
	},
	
	-- change this to whatever anchor you want the guy to approach
	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_SMOKE,

	Attachment = {

		{
			fileObject = "Objects/characters/mercenaries/accessories/cigarrette.cgf",
			strBoneName  = "Bip01 L Hand",
		},
	},
	
	-- the animation that should replace the normal idle breathing loop
	-- specify more to randomly choose between them
	BaseLoopAnimation 	= {
					{ 
						"_smoking_idle_loop",		-- name
					 	1,				-- 1 can be played back to back, 0 cannot
					  	{1.0, 1.0},			-- multiplier range for the speed
					  	0.15,				-- blend in/out time
					},
				  },

	--  the animation that needs to play intially entering this idle
	-- specify more to randomly choose between them
	StartAnimation 		= {	
					{
						"_smoking_start",
					  	0,
					 	{0.8,1.2},
					 	0.15,
					},
				  },

	--  the animation that needs to play intially when exiting this idle
	EndAnimation		= {
					{
						"_smoking_end1",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"_smoking_end2",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	-- animation breaks that play during the idle - they will play randomly.
	-- these animations will play only if NumberOfBreaks is not nil.
	BreakAnimation	 	= {

					{
						"_smoking_1",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"_smoking_2",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"_smoking_3",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

				 },

	-- how many times a break animations needs to play before ending - the number is picked in the supplied range
	-- specify nil for no breaks. (ALWAYS HAVE TO HAVE 2 NUMBERS IF NOT NIL)
	NumberOfBreaks		= {3,7},

	-- specify how many seconds to wait between breaks - the number is picked in the supplied range
	-- nil means between 0 and 1 seconds.(ALWAYS HAVE TO HAVE 2 NUMBERS IF NOT NIL)
	BreakDelay			= {2,3},
}
AIBehaviour.Idle_Smoke = CreateIdleBehaviour(Idle_Smoke);

--------------------------

Idle_FixFence = {
	Name = "Idle_FixFence",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_FENCE,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/screwdriver.cgf",
			strBoneName  = "Bip01 R Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"_fixfence_loop",
					  	1,
					 	{0.9,1.1},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"_fixfence_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"_fixfence_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"_fixfence_idle01",
					  	0,
					 	{0.8,1.4},
					 	0.35,
					},

				},

	NumberOfBreaks		= {2,4},
	BreakDelay			= {5,7},

}
AIBehaviour.Idle_FixFence = CreateIdleBehaviour(Idle_FixFence);

--------------------------

Idle_FixFence_Long = {
	Name = "Idle_FixFence_Long",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_FENCE_LONG,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/screwdriver.cgf",
			strBoneName  = "Bip01 R Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"_fixfence_loop",
					  	1,
					 	{0.9,1.1},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"_fixfence_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"_fixfence_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"_fixfence_idle01",
					  	0,
					 	{0.8,1.4},
					 	0.35,
					},

				},

	NumberOfBreaks		= {70,77},
	BreakDelay			= {5,7},

}
AIBehaviour.Idle_FixFence_Long = CreateIdleBehaviour(Idle_FixFence_Long);

--------------------------

Idle_FixWheel = {
	Name = "Idle_FixWheel",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_WHEEL,

	BaseLoopAnimation 	= {
					{
						"_fixwheel_loop",
					  	1,
					 	{0.9,1.1},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"_fixwheel_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= { 
					{
						"_fixwheel_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				   },

	BreakAnimation	 	= {
					{
						"_fixwheel_idle01",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"_fixwheel_idle02",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"_fixwheel_idle03",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

				},

	NumberOfBreaks		= {2,4},
	BreakDelay			= {3,5},
}
AIBehaviour.Idle_FixWheel = CreateIdleBehaviour(Idle_FixWheel);

--------------------------
Idle_PlantBomb = {
	Name = "Idle_PlantBomb",
	JOB = 2,

	SPECIAL_AI_ONLY 	= 1,
	AFFECT_POSITION 	= 1,
	TRIGGER_EVENT      	= 1,
	WITHOUT_WEAPON      	= 1,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.PLANT_BOMB_HERE,
	
	Attachment = {

		{
			fileObject = "Objects/characters/mercenaries/accessories/val_bomb_radio_rhand.cgf",
			strBoneName  = "Bip01 R Hand",
			USE_KEYFRAME = 1,
		},
	},

	BaseLoopAnimation 	= {
					{
						"val_keypad_breath",
					  	1,
					 	{1,1},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"val_bomb_start",
					  	0,
					 	{1,1},
					 	0.35,
					},
				  },

	EndAnimation		= nil,
	BreakAnimation	 	= {
					{
						"val_keypad1",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"val_keypad2",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"val_keypad3",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

					{
						"val_keypad4",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"val_lookaround",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

				},

	NumberOfBreaks		= {15,15},
	BreakDelay			= {1,1},
}
AIBehaviour.Idle_PlantBomb = CreateIdleBehaviour(Idle_PlantBomb);

--------------------------

Idle_Magazine = {
	Name = "Idle_Magazine",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_MAGAZINE,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/magazine.cgf",
			strBoneName  = "Bip01 L Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"sit_magazine_breath",
					  	1,
					 	{0.8,1.2},
					 	0.9,
					},
				  },

	StartAnimation 		= {
					{
						"sitdown",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"situp",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"sit_magazine_idle1",
					  	0,
					 	{0.5,1.0},
					 	0.35,
					},
					{
						"sit_magazine_idle2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"sit_magazine_pageflip",
					  	1,
					 	{0.5,1.1},
					 	0.35,
					},
					{
						"sit_magazine_reading",
					  	0,
					 	{0.5,1.0},
					 	0.35,
					},

				  },

	NumberOfBreaks		= {7,10},
	BreakDelay			= {1,2},
}
AIBehaviour.Idle_Magazine = CreateIdleBehaviour(Idle_Magazine);

--------------------------

Idle_PushButton = {
	Name = "Idle_PushButton",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_PUSHBUTTON,

	BaseLoopAnimation 	= nil,

	StartAnimation 		= {
					{
						"push_button",
					  	0,
					 	{0.9,1.1},
					 	0.35,
					},
				  },
	EndAnimation		= {
					{
						"push_frustated",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"push_hit_machine",
					  	0,
					 	{0.8,1.4},
					 	0.35,
					},
					{
						"push_button_repeated",
					  	0,
					 	{0.8,1.4},
					 	0.35,
					},

				},

	NumberOfBreaks		= {2,2},
	BreakDelay			= {1,1},

}
AIBehaviour.Idle_PushButton = CreateIdleBehaviour(Idle_PushButton);

--------------------------

Idle_Fish = {
	Name = "Idle_Fish",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.FISH_HERE,


	Attachment = {
		{
			fileObject = "Objects/Outdoor/HUMAN_CAMP/fishing_rod.cgf",
			strBoneName  = "weapon_bone",
		},
	},
	
	BaseLoopAnimation 	= {
					{
						"fish_idle",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"fish_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation 		= {
					{
						"fish_idle",
					  	0,
					 	{0.8,1.2},
					 	1.0,
					},
				  },

	BreakAnimation	 	= {
					{
						"fish_pull",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
				  },

	NumberOfBreaks		= {4,7},
	BreakDelay			= {3,5},
}
AIBehaviour.Idle_Fish = CreateIdleBehaviour(Idle_Fish);

--------------------------

Idle_Clipboard = {
	Name = "Idle_Clipboard",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_CLIPBOARD,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/clipboard.cgf",
			strBoneName  = "Bip01 L Hand",
		},
		{
			fileObject = "Objects/characters/mercenaries/accessories/pencil.cgf",
			strBoneName  = "Bip01 R Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"clipboard_writing_loop",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"clipboard_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"clipboard_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"clipboard_idle1",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"clipboard_idle2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"clipboard_breathing_loop",
					  	0,
					 	{0.8,1.2},
					 	0.5,
					},

				  },

	NumberOfBreaks		= {3,5},
	BreakDelay			= {3,5},
}
AIBehaviour.Idle_Clipboard = CreateIdleBehaviour(Idle_Clipboard);

--------------------------

Idle_Beaker = {
	Name = "Idle_Beaker",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_BEAKER,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/beaker_left.cgf",
			strBoneName  = "Bip01 L Hand",
		},
		{
			fileObject = "Objects/characters/mercenaries/accessories/beaker_right.cgf",
			strBoneName  = "Bip01 R Hand",
		},
	},

	BaseLoopAnimation 	= nil,

	StartAnimation 		= {
					{
						"pour_beaker1",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"pour_beaker2",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"pour_beaker3",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	EndAnimation 		= nil,

	BreakAnimation 		= nil,


	NumberOfBreaks		= nil,
	BreakDelay			= nil,

}
AIBehaviour.Idle_Beaker = CreateIdleBehaviour(Idle_Beaker);

--------------------------

Idle_Microscope = {
	Name = "Idle_Microscope",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_MICROSCOPE,

	BaseLoopAnimation 	= nil,

	StartAnimation 		= {
					{
						"microscope1",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"microscope2",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	EndAnimation 		= nil,

	BreakAnimation 		= nil,


	NumberOfBreaks		= nil,
	BreakDelay			= nil,

}
AIBehaviour.Idle_Microscope = CreateIdleBehaviour(Idle_Microscope);

--------------------------

Idle_Sit_Write = {
	Name = "Idle_Sit_Write",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_SIT_WRITE,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/pencil.cgf",
			strBoneName  = "Bip01 R Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"sit_writing_loop",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"sitdown_desk",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"situp_desk",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"sit_writing_idle1",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"sit_writing_idle2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"sit_writing_idle3",
					  	0,
					 	{0.7,1.3},
					 	0.5,
					},

				  },

	NumberOfBreaks		= {5,7},
	BreakDelay			= {7,10},
}
AIBehaviour.Idle_Sit_Write = CreateIdleBehaviour(Idle_Sit_Write);

--------------------------

Idle_Sit_Type = {
	Name = "Idle_Sit_Type",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_SIT_TYPE,

	BaseLoopAnimation 	= {
					{
						"sit_typing_loop",
					  	1,
					 	{1.0,1.2},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"sitdown_desk",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"situp_desk",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"sit_typing_idle1",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"sit_typing_idle2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"sit_typing_onehanded",
					  	0,
					 	{1.0,1.2},
					 	0.5,
					},
					{
						"sit_hitdesk",
					  	0,
					 	{0.8,1.2},
					 	0.5,
					},
					{
						"sit_hitmonitor",
					  	0,
					 	{0.8,1.2},
					 	0.5,
					},

				  },

	NumberOfBreaks		= {7,10},
	BreakDelay			= {7,10},
}
AIBehaviour.Idle_Sit_Type = CreateIdleBehaviour(Idle_Sit_Type);

--------------------------

Idle_Sleep = {
	Name = "Idle_Sleep",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.SLEEP,

	BaseLoopAnimation 	= nil,
	StartAnimation 		= {
					{
						"sleeping_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},

	EndAnimation 		= {
					{
						"sleeping_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	BreakAnimation		= {
					{
						"sleeping_loop",
					  	1,
					 	{0.8,1.2},
					 	0.0,
					},
				},


	NumberOfBreaks		= {35,70},
	BreakDelay			= {1,2},

}
AIBehaviour.Idle_Sleep = CreateIdleBehaviour(Idle_Sleep);

--------------------------

Idle_Seat = {
	Name = "Idle_Seat",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_SEAT,

	BaseLoopAnimation 	= {
					{
						"sitdown_breath",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	StartAnimation 		= {
					{
						"sitdown",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},

	EndAnimation 		= {
					{
						"situp",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	BreakAnimation		= {
					{
						"sitdown_breath",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},


	NumberOfBreaks		= {20,35},
	BreakDelay			= {1,2},

}
AIBehaviour.Idle_Seat = CreateIdleBehaviour(Idle_Seat);


--------------------------

Idle_Seat_Precise = {
	Name = "Idle_Seat_Precise",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.SEAT_PRECISE,
	AFFECT_POSITION = 1,

	BaseLoopAnimation 	= {
					{
						"sitdown_breath",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	StartAnimation 		= {
					{
						"sitdown",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},

	EndAnimation 		= {
					{
						"situp",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	BreakAnimation		= {
					{
						"sitdown_breath",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},


	NumberOfBreaks		= {20,35},
	BreakDelay			= {1,2},

}
AIBehaviour.Idle_Seat_Precise = CreateIdleBehaviour(Idle_Seat_Precise);

--------------------------

Idle_Exercise = {
	Name = "Idle_Exercise",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.EXERCISE_HERE,

	BaseLoopAnimation		= {
					{
						"pushup_loop",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	StartAnimation 		= {
					{
						"pushup_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},

	EndAnimation 		= {
					{
						"pushup_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	BreakAnimation		= nil,

	NumberOfBreaks		= {5,10},
	BreakDelay			= {1,2},

}
AIBehaviour.Idle_Exercise = CreateIdleBehaviour(Idle_Exercise);

--------------------------

Idle_WarmHands = {
	Name = "Idle_WarmHands",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_WARMHANDS,

	BaseLoopAnimation 		= {
					{
						"warmhands_loop",
					  	0,
					 	{0.5,1.0},
					 	0.35,
					},
				},
	StartAnimation 		= nil,
	EndAnimation 		= {
					{
						"warmhands_rub",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	BreakAnimation		= {
					{
						"warmhands_rub",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},


	NumberOfBreaks		= {2,3},
	BreakDelay			= {2,4},

}
AIBehaviour.Idle_WarmHands = CreateIdleBehaviour(Idle_WarmHands);

--------------------------

Idle_Cards = {
	Name = "Idle_Cards",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.PLAY_CARDS_HERE,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/cards.cgf",
			strBoneName  = "Bip01 L Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"card_loop",
					  	1,
					 	{0.9,1.1},
					 	0.35,
					},
				  },

	StartAnimation 		= {
					{
						"sitdown_desk",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= {
					{
						"situp_desk",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	BreakAnimation	 	= {
					{
						"card_throw1",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"card_throw2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"card_drink1",
					  	0,
					 	{0.7,1.2},
					 	0.35,
					},
					{
						"card_drink2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"card_drink3",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},

				},

	NumberOfBreaks		= {21,23},
	BreakDelay			= {4,7},

}
AIBehaviour.Idle_Cards = CreateIdleBehaviour(Idle_Cards);

--------------------------

Idle_Dinner1 = {
	Name = "Idle_Dinner1",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_DINNER1,

	BaseLoopAnimation 		= {
					{
						"eat_pick_loop",
					  	1,
					 	{0.7,1.2},
					 	0.35,
					},
				},
	StartAnimation 		= nil,
	EndAnimation 		= nil,
	BreakAnimation		= {
					{
						"eat1",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"eat2",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},


	NumberOfBreaks		= {5,10},
	BreakDelay			= {1,1},

}
AIBehaviour.Idle_Dinner1 = CreateIdleBehaviour(Idle_Dinner1);

--------------------------

Idle_Dinner2 = {
	Name = "Idle_Dinner2",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_DINNER2,

	BaseLoopAnimation = nil,
	StartAnimation 	= {
					{
						"eat_start",
					  	1,
					 	{0.9,1.1},
					 	0.35,
					},
				},
	EndAnimation 	= {
					{
						"eat_end",
					  	1,
					 	{0.9,1.1},
					 	0.35,
					},
				},
	BreakAnimation 	= {
					{
						"eat_loop01",
					  	1,
					 	{0.7,1.2},
					 	0.35,
					},
					{
						"eat_loop02",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"eat_idle_loop",
					  	1,
					 	{0.7,1.2},
					 	0.35,
					},
				},

	NumberOfBreaks		= {70,100},
	BreakDelay			= {1,1},

}
AIBehaviour.Idle_Dinner2 = CreateIdleBehaviour(Idle_Dinner2);

--------------------------



Idle_Relief = {
	Name = "Idle_Relief",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_RELIEF,

	BaseLoopAnimation 		= {
					{
						"relief",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	StartAnimation 		= nil,
	EndAnimation 		= nil,
	BreakAnimation		= {
					{
						"relief",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},


	NumberOfBreaks		= {2,5},
	BreakDelay			= {1,1},

}
AIBehaviour.Idle_Relief = CreateIdleBehaviour(Idle_Relief);

--------------------------

Idle_Stand_Type = {
	Name = "Idle_Stand_Type",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_STAND_TYPE,

	BaseLoopAnimation 	= {
					{
						"stand_typing_loop",
					  	1,
					 	{1.0,1.2},
					 	0.35,
					},
				  },

	StartAnimation 		= nil,
	EndAnimation		= nil,
	BreakAnimation	 	= {
					{
						"stand_typing_idle1",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"stand_typing_idle2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"stand_typing_onehanded",
					  	0,
					 	{1.0,1.2},
					 	0.5,
					},
					{
						"stand_hitdesk",
					  	0,
					 	{0.8,1.2},
					 	0.5,
					},

				  },

	NumberOfBreaks		= {7,10},
	BreakDelay			= {7,10},
}
AIBehaviour.Idle_Stand_Type = CreateIdleBehaviour(Idle_Stand_Type);

--------------------------

Idle_SPECIAL_Stand_Type = {
	Name = "Idle_SPECIAL_Stand_Type",
	JOB = 2,

	SPECIAL_AI_ONLY		= 1,
	WITHOUT_WEAPON      	= 1,
	ANCHOR_TO_APPROACH 	= AIAnchorTable.SPECIAL_STAND_TYPE,

	BaseLoopAnimation 	= {
					{
						"stand_typing_loop",
					  	1,
					 	{1.0,1.2},
					 	0.35,
					},
				  },

	StartAnimation 		= nil,
	EndAnimation		= nil,
	BreakAnimation	 	= {
					{
						"stand_typing_idle1",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"stand_typing_idle2",
					  	0,
					 	{0.7,1.3},
					 	0.35,
					},
					{
						"stand_typing_onehanded",
					  	0,
					 	{1.0,1.2},
					 	0.5,
					},
					{
						"stand_hitdesk",
					  	0,
					 	{0.8,1.2},
					 	0.5,
					},

				  },

	NumberOfBreaks		= {7,10},
	BreakDelay			= {7,10},
}
AIBehaviour.Idle_SPECIAL_Stand_Type = CreateIdleBehaviour(Idle_SPECIAL_Stand_Type);

--------------------------

Idle_SPECIAL_EnterCode = {
	Name = "Idle_SPECIAL_EnterCode",
	JOB = 2,
	
	SPECIAL_AI_ONLY 	= 1,
	RUN			= 1,
	WITHOUT_WEAPON 		= 1,
	ANCHOR_TO_APPROACH 	= AIAnchorTable.SPECIAL_ENTERCODE,
	AFFECT_POSITION 	= 1,

	BaseLoopAnimation 	= nil,

	StartAnimation 		= {
					{
						"entercode",
					  	0,
					 	{1,1},
					 	0.21,
					},
				  },
	EndAnimation		= nil,
	BreakAnimation	 	= nil,

	NumberOfBreaks		= nil,
	BreakDelay			= nil,

}
AIBehaviour.Idle_SPECIAL_EnterCode = CreateIdleBehaviour(Idle_SPECIAL_EnterCode);

--------------------------

Idle_Rampage = {
	Name = "Idle_Rampage",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_RAMPAGE,

	BaseLoopAnimation	 	= nil,
	StartAnimation 		= {
					{
						"crunch01",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"swipe01",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"swipe02",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"kick_barrel",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

				  },
	EndAnimation	 	= nil,
	BreakAnimation	 	= nil,

	NumberOfBreaks		= nil,
	BreakDelay			= nil,
}
AIBehaviour.Idle_Rampage = CreateIdleBehaviour(Idle_Rampage);

--------------------------

Idle_Examination = {
	Name = "Idle_Examination",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_EXAMINATION,

	Attachment = {
		{
			fileObject = "Objects/characters/mercenaries/accessories/scalpel.cgf",
			strBoneName  = "Bip01 R Hand",
		},
	},

	BaseLoopAnimation 	= {
					{
						"examination_breath_loop",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },
	StartAnimation 		= {
					{
						"examination_start",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				  },

	EndAnimation		= { 
					{
						"examination_end",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				   },

	BreakAnimation	 	= {
					{
						"examination_slice01",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"examination_slice02",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"examination_idle00",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"examination_idle01",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"examination_idle02",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
					{
						"examination_open",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},

				},

	NumberOfBreaks		= {20,30},
	BreakDelay			= {1,2},
}
AIBehaviour.Idle_Examination = CreateIdleBehaviour(Idle_Examination);

--------------------------

Idle_Mutated = {
	Name = "Idle_Mutated",
	JOB = 2,

	ANCHOR_TO_APPROACH 	= AIAnchorTable.AIANCHOR_MUTATED,

	BaseLoopAnimation		= {
					{
						"mutated_breath",
					  	1,
					 	{0.8,1.2},
					 	0.35,
					},
				},
	EndAnimation		= nil,
	BreakAnimation 		= {
					{
						"mutated_cough",
					  	0,
					 	{0.8,1.2},
					 	0.35,
					},
				},

	NumberOfBreaks		= {40,50},
	BreakDelay			= {5,7},

}
AIBehaviour.Idle_Mutated = CreateIdleBehaviour(Idle_Mutated);
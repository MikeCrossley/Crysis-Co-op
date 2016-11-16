Script.ReloadScript( "SCRIPTS/Entities/AI/Aliens/CoopScout_x.lua");

CreateAlien(CoopScout_x);
CoopScout = CreateAI(CoopScout_x)
CoopScout:Expose();

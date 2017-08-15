Script.ReloadScript( "SCRIPTS/Entities/AI/Aliens/CoopHunter_x.lua");

CreateAlien(CoopHunter_x);
CoopHunter = CreateAI(CoopHunter_x)
CoopHunter:Expose();


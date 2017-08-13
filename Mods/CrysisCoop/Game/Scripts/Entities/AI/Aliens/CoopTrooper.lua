Script.ReloadScript( "SCRIPTS/Entities/AI/Aliens/CoopTrooper_x.lua");

CreateAlien(CoopTrooper_x);
CoopTrooper = CreateAI(CoopTrooper_x)
CoopTrooper:Expose();

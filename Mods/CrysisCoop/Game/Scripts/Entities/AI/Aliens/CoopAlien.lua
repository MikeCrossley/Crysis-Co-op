Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAI.lua");
Script.ReloadScript( "SCRIPTS/Entities/AI/Aliens/CoopAlien_x.lua");

CreateAlien(CoopAlien_x);
CoopAlien=CreateAI(CoopAlien_x);
CoopAlien:Expose();

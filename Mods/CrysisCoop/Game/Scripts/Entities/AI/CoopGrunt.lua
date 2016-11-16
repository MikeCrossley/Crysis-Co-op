Script.ReloadScript( "SCRIPTS/Entities/AI/CoopGrunt_x.lua");
-----------------------------------------------------------------------------------------------------

CreateActor(CoopGrunt_x);
CoopGrunt = CreateAI(CoopGrunt_x);
CoopGrunt:Expose();
--MakeSpawnable(CoopGrunt)


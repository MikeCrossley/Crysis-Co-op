# Crysis-Co-op
===================

The efforts of forum users RaZoR-FIN and Fudsine to bring cooperative multiplayer to the popular 2007 Crytek title Crysis. This version and all future versions will be for the base game Crysis (Cryis Wars will no longer be supported)

# How it Works
===================

The primary principle behined getting AI to work in multiplayer was a bit of a workaround. In the inaccesible engine code there are numerous checks for determining wether or not the game is in multiplayer mode and then preventing the AI systems from loading and running. To bypass this we "trick" the game into believing it is running in singleplayer on the server, load the neccesary AI systems and then revert back to the multiplayer state. (Look at CCoopSystem for more information)

From here it was a matter of networking all of the AI and game logic. As of writing the only supported AI types are human and partially vehicles.

# Level Content
===================

If you want to setup your own levels grab the content from the moddb page http://www.moddb.com/mods/crysis-co-op/downloads and open up any of the levels and observe our flowgraph setups for game logic.

# Multiplayer and Gamespy
===================

As the Gamespy servers have been shutdown and Crytek has not provided a suitable replacement, you will need to find a suitable peer-to-peer VPN to play the mod. We personally use EvolveHQ, in future we would like to put something better in place.

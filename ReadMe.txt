Description

Warning: this is experimental, use it at your own risk!

These PowerShell GUIs and scripts helps to tweak a custom mod, especially groups of vehicles:
_ When you have multiple similar vehicles and don't know how to fit them in your favorite map, the ChangeMapVehicles tool can help randomize the vehicles on the existing spawnpoints of the map. Multiple characteristics can be defined in "vehicles_db.csv" (to edit e.g. with Microsoft Excel) to describe how a specific vehicle can be replaced with another one (e.g. you might want that only a US tank could be swapped with another US tank and not with a MEC plane, etc.). Most of the vehicles of Battlefield 2 Complete Collection are already described, plus some available from Mod DB and elsewhere (some download links are in "vehicles_db.csv", you would have to install them manually or disable them if they cause problems).
_ Vehicles wrecks usually stay up to 10 s in standard Battlefield 2 versions. TimeToStayAsWreck tool can help changing this value for a whole folder of vehicles.
_ AddVehicleSpawnPoint and AddVehicleSupplyObject tools can help adding a mobile spawnpoint or supplyobject for a whole folder of vehicles according to "vehicles_db.csv".
_ BasicTempUpdate tool can help convince the bots to use more the vehicles whenever possible.
_ SetBots tool can help changing the number of bots.
_ Please see the tutorial below, where Battlefield 2 Demo with a modified Gulf Of Oman map with many vehicles spawnpoints will be used to demonstrate some possiblities.


Prerequisites

_ Windows (tested with Windows 10 Pro v21H2 64 bit with English language)
_ 7-Zip (add 7z.exe to Windows PATH environment variable and reboot, tested with v22.01 from https://www.7-zip.org/)
_ PowerShell (default version (5.1) should be OK for Windows 10, for Windows XP see https://www.catalog.update.microsoft.com/Search.aspx?q=968929 to get PowerShell 2.0, scripts might need fixes)

The scripts will probably need to be run as Administrator (right-click on the script and choose "Run as administrator" if needed).

If the scripts appear to be blocked, type in PowerShell (or check the Internet for other options): 
set-executionpolicy remotesigned

For better security, you might want to reset to:
set-executionpolicy restricted
when you do not use the mod or other PowerShell scripts.

Please make a backup of any important data on the computer since failures in scripts might sometimes delete or overwrite unexpected data. Note also that some scripts might not provide a way to easily revert their changes. WinMerge might be useful to check the changes made between folders.

Battlefield 2 Demo on Windows XP SP3 (32 bit with English language) has been quickly tested but Battlefield 2 Complete Collection on a powerfull computer with Windows 10 + some vehicles from Mod DB (https://www.moddb.com/games/battlefield-2/addons) are recommended.

Some experience in maps and vehicles modding in Battlefield 2 might be necessary.


Tutorial

This tutorial proposes to use Battlefield 2 Demo, create a new mod and modify the Gulf of Oman map:
_ Note: if you are using Notepad to view some text documents, enable Format\Word Wrap in its menu if needed to see long lines more easily.
_ Edit "vehicles_db.csv" e.g. with Microsoft Excel (or any text editor) to ensure only the vehicles really fully available in Battlefield 2 Demo have their column Disabled to 0 (i.e. only apc_btr90, JEEP_FAAV, jep_mec_paratrooper, jep_vodnik, RUTNK_T90, USAPC_LAV25, USJEP_HMMWV, USTNK_M1A2, boat_rib, ahe_ah1z, ahe_havoc, air_f35b, ruair_mig29, RUAIR_SU34, usthe_uh60), while all the others have Disabled to 1.
_ Copy "C:\Program Files\EA Games\Battlefield 2 Demo\mods\bf2" as "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2". xbf2 will be the name of the new mod.
_ Replace "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Levels\Gulf_of_Oman\Info" with the provided one, extract using 7-Zip "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Levels\Gulf_of_Oman\server.zip", right-click on "server" folder and in its Properties, disable Read-only attribute for all its content. Copy "server\gamemodes\sp1\16" as "server\gamemodes\sp3\64". Compress using 7-Zip the content of "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Levels\Gulf_of_Oman\server" to "server.zip" and replace the original (make sure that the resulting "server.zip" does not contain itself a root folder "server", the directory structure needs to look like "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Levels\Gulf_of_Oman\server.zip\gamemodes\..." and not "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Levels\Gulf_of_Oman\server.zip\server\gamemodes\...").
_ Double-click "ChangeMapVehicles_GUI.bat", change the level folder in the GUI to "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Levels\Gulf_of_Oman", change gameMode to sp3, mapSize to 64, teams to MEC and US, you will need to uncheck bEnforceCompatibleTeams and/or other options to see some changes since few vehicles are available for those teams in Battlefield 2 Demo, click on Apply button and check the output in the console and especially if/which vehicle changed, click again on Apply button to get another random distribution if needed, then close both windows.
_ To increase the number of bots, double-click "SetBots_GUI.bat", change the mod folder in the GUI to "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2", click on Apply button and check the output in the console, then close both windows.
_ Extract using 7-Zip "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server.zip" to "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server". 
_ Right-click on Objects_server folder and in its Properties, disable Read-only attribute for all its content.
_ To have vehicles wrecks stay longer, double-click "TimeToStayAsWreckUpdate_GUI.bat", change the Objects folder in the GUI to "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server", change Time to 240 s, click on Apply button and check the output in the console, then close both windows.
_ To make the bots use more the vehicles, double-click "BasicTempUpdate_GUI.bat", change the Objects folder in the GUI to "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server", change BasicTemp to 100, click on Apply button and check the output in the console, then close both windows.
_ Test also "AddVehicleSpawnPoint_GUI.bat", "AddVehicleSupplyObject_GUI.bat", "AddArmorEffect_GUI.bat" in a similar way. You might want to use WinMerge to compare the original Objects_server with the modified one.
_ Compress using 7-Zip the content of "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server" to "Objects_server.zip" and replace the original (make sure that the resulting "Objects_server.zip" does not contain itself a root folder "Objects_server", the directory structure needs to look like "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server.zip\Vehicles\..." and not "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2\Objects_server.zip\Objects_server\Vehicles\...")
_ Open a terminal in "C:\Program Files\EA Games\Battlefield 2 Demo\mods\xbf2" and run something similar to:
bf2.exe +restart 1 +developer 1 +managedTextures 0 +fileMonitor 1 +menu 1 +fullscreen 0 +modPath mods/xbf2 +szx 1600 +szy 900
to test the modified map "Gulf Of Oman - 64" in the mod.
_ To get a version of the map with more vehicle spawnpoints, download https://www.moddb.com/games/battlefield-2/addons/gulf-of-oman-coop, get its server\StaticObjects.con, server\ai, server\aipathfinding (or maybe use directly all the files?), copy server\gamemodes\gpm_coop\64 as server\gamemodes\sp3\64 (be sure to delete any GamePlayObject.con.bak inside the zip and extracted folder), run "ChangeMapVehicles_GUI.bat" with bEnforceVehicleType, bEnforceVTOL, bEnforceNeedLargeAirfield disabled, bRemoveIncompatible enabled...
_ To get a version of the map with even more vehicle spawnpoints, get provided sp3\64 (be sure to delete any GamePlayObject.con.bak inside the zip and extracted folder), remove occurences of ATS_HJ8 and ATS_TOW in GamePlayObject.con (since they are not available in Battlefield 2 Demo), remove sp3\64\ai\Strategies.ai (or install https://www.moddb.com/mods/esai-enhanced-strategic-ai/ and edit Strategies.ai), run "ChangeMapVehicles_GUI.bat" with bEnforceVehicleType, bEnforceVTOL, bEnforceNeedLargeAirfield disabled, bRemoveIncompatible enabled...
_ TODO: adding a new vehicle from Mod DB (e.g. RU_T90MS), provide patches for some of them...


More information

"vehicles_db.csv" specification:

vehicleName;vehicleType (tank: 0, mobile artillery: 0.1, heavily armed APC: 1, anti-tank APC: 1.1, light-armed APC: 1.2, attack heli: 2, transport heli: 2.1, heavy armed car: 3, light armed car: 3.1, light ground vehicle: 3.2, light civilian car: 3.3, heavy civilian car: 3.4, spy car: 3.5, multi-purpose plane: 4, AA plane: 4.1, bombing plane: 4.2, spy plane: 4.3, light civilian plane: 4.4, heavy civilian plane: 4.5, AA: 5, light boat: 6, medium boat: 6.1, heavy boat: 6.2, light submarine: 6.3, heavy submarine: 6.4);preferredTeams;compatibleTeams (ALL (particular case),US,MEC,CH,SEAL,MECSF,Spetz,SAS,Chinsurgent,MEInsurgent,EU);Disabled (1 to disable, 0 to enable, intermediate values can be set to give some priority with 1 corresponding to the lowest priority and 0 corresponding to the standard priority (0.5 would be half standard priority, -1 double, -3 quadruple, etc.));sizeCategory (0: small, 1: standard, 2: big, 3: huge);bAmphibious (0 or 1);bFloating (0 or 1);bFlying (0 or 1);bVTOL (0 or 1);bNeedWater (0 or 1);bNeedAirfield (0 or 1);bNeedLargeAirfield (0 or 1);bHeavilyArmored (1 if largely able to resist to 1 tank shot, 0 otherwise);bHeavilyArmed (1 if able to destroy a tank in less than around 5 shots, 0 otherwise);bHasManyPassengers (0 for 3 or less, 1 otherwise);bCanBeAirDropped (0 or 1);bDisableSpawnPoint (0 or 1, e.g. for when the passengers do not have any weapon and are not meant to be dropped);bHasSupplies (0 or 1);comments;downloadLink;wikiLink

Do not forget to set Disabled to 1 for vehicles that you do not have or which have known issues. Check the comments column for some known issues and possible solutions. If a map references a vehicle which is not described in "vehicles_db.csv", consider running ChangeMapVehicles tool a first time to easily identify it in the warning messages, and then add it manually to "vehicles_db.csv" (set at least vehicleName, vehicleType, Disabled columns) so that next time it knows how to replace it especially if it appears multiple times.

Some custom vehicles from the Internet sometimes have problems with their wrecks, try to force ObjectTemplate.armor.timeToStayAsWreck need to be set to 0 in vehicleName.tweak if needed.

BasicTemp might vary a lot among custom vehicles from the Internet, you might need to check specific cases.


Known issues

_ PowerShell 2.0 (highest version available on Windows XP) might have compatibility issues (e.g. FolderBrowserDialog does not work, use the TextBox instead)... 
_ Decimal separator interpretation might cause problems depending on the international settings of the OS. If needed, consider setting it to '.'.


ChangeLog

0.1: First public version.

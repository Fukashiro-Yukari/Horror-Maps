local pass = function() end
CheckpointsDisabled = pass

function Horror:MapChange(s)
	for k, v in pairs(player.GetAll()) do
        v:ScreenFade(SCREENFADE.OUT,color_black,3,100)
        v:Freeze(true)
    end
    
    timer.Simple(4,function()
        game.ConsoleCommand('changelevel "'..mapname..'"\n')

        timer.Simple(1,function()
            PrintMessage(HUD_PRINTTALK,'Next map not found! "'..mapname..'"')
        end)
    end)
end

MapChange = Horror.MapChange

function Horror:AllFrozen(b)
    for k,v in pairs(player.GetAll()) do
        v:Freeze(b)
    end
end

AllFrozen = Horror.AllFrozen

function Horror:FlashlightStatus(b)
    for k,v in pairs(player.GetAll()) do
        v:AllowFlashlight(b)
    end
end

FlashlightStatus = Horror.FlashlightStatus
ForceRealismEnable = pass
StartWithNothing = pass
ForceBringDisable = pass
ForceRealisticZombies = pass
ForceRealisticHeadcrabs = pass
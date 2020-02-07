util.PrecacheSound('horror/mission_failed.wav')

local pass = function() end
CheckpointsDisabled = pass

function Horror.MapChange(s)
	for k, v in pairs(player.GetAll()) do
        v:ScreenFade(SCREENFADE.OUT,color_black,3,100)
        v:Freeze(true)
    end

    timer.Simple(4,function()
        game.ConsoleCommand('changelevel "'..s..'"\n')

        timer.Simple(1,function()
            PrintMessage(HUD_PRINTTALK,'Next map not found! "'..s..'"')
        end)
    end)
end

MapChange = Horror.MapChange

function Horror.AllFrozen(b)
    for k,v in pairs(player.GetAll()) do
        v:Freeze(b)
    end
end

AllFrozen = Horror.AllFrozen

function Horror.FlashlightStatus(b)
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
StartWithNothing = pass
ActivateCheckpoint = pass

local reloadtime = 8
local fadeTime = 5

local rs = {
    'What the hell are you doing !?',
    'You should not do this'
}

function Horror.MissionFailed(s)
    if !s then
        s = table.Random(rs)
    end

    if Horror.__restarting then return end

    Horror.__restarting = true

	for k,v in pairs(player.GetAll()) do
        v:ScreenFade(SCREENFADE.OUT,color_black,fadeTime,reloadtime)
        v:Freeze(true)
        v:SendLua('surface.PlaySound(\'horror/mission_failed.wav\')')
        v:StripAmmo()
        v:StripWeapons()
        v:SetNW2String('qtg_hr_missionfailed',s)
    end

    timer.Simple(reloadtime,function()
        game.CleanUpMap()

        timer.Simple(0,function()
            for k,v in pairs(player.GetAll()) do
                v:Spawn()
                v:Freeze(false)
                v:SetNW2String('qtg_hr_missionfailed','')
            end
    
            Horror.__restarting = false
        end)
    end)
end

MissionFailed = Horror.MissionFailed

function Horror.GiveMission(s,e)
    Horror.__currentmission = s

    for k,v in pairs(player.GetAll()) do
        v:SetNW2String('qtg_hr_currentmission',s)
    end
end

function Horror.NoHeadcrabs(b)
    Horror.__noheadcrabs = b
end

NoHeadcrabs = Horror.NoHeadcrabs
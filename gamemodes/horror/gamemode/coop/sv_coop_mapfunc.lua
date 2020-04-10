util.PrecacheSound('horror/mission_failed.wav')

local pass = function() end
CheckpointsDisabled = pass

function Horror.MapChange(s)
    if !file.Exists('maps/'..s..'.bsp','GAME') then
        PrintMessage(HUD_PRINTTALK,'Next map not found! "'..s..'"')

        return
    end

	for k, v in pairs(player.GetAll()) do
        v:ScreenFade(SCREENFADE.OUT,color_black,3,100)
        v:Freeze(true)
    end

    timer.Simple(4,function()
        game.ConsoleCommand('changelevel "'..s..'"\n')
    end)
end

MapChange = Horror.MapChange

function Horror.AllFrozen(b)
    for k,v in pairs(player.GetAll()) do
        v:Freeze(b)
    end
end

AllFrozen = Horror.AllFrozen

function Horror.AllowFlashlight(b)
    for k,v in pairs(player.GetAll()) do
        v:AllowFlashlight(b)
    end
end

FlashlightStatus = Horror.AllowFlashlight
ForceRealismEnable = pass
ForceBringDisable = pass
ForceRealisticZombies = pass
ForceRealisticHeadcrabs = pass
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

    if !IsValid(Horror.__missionfailedsound) then
        local f = RecipientFilter()
        f:AddAllPlayers()

        Horror.__missionfailedsound = CreateSound(game.GetWorld(),'horror/mission_failed.wav',f)
    end

    Horror.__missionfailedsound:SetSoundLevel(0)
    Horror.__missionfailedsound:Play()

	for k,v in pairs(player.GetAll()) do
        v:ScreenFade(SCREENFADE.OUT,color_black,fadeTime,reloadtime)
        v:Freeze(true)
        v:StripAmmo()
        v:StripWeapons()
        v:SetNW2String('qtg_hr_missionfailed',s)

        if IsValid(v.__deathsound) then
            v.__deathsound:Stop()
        end
    end

    timer.Simple(reloadtime,function()
        game.CleanUpMap()

        timer.Simple(0,function()
            for k,v in pairs(player.GetAll()) do
                v:Spawn()
                v:Freeze(false)
                v:SetNW2String('qtg_hr_missionfailed','')
            end

            if IsValid(Horror.__missionfailedsound) then
                Horror.__missionfailedsound:Stop()
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

    if IsValid(e) then
        Horror.__currentmissionent = e
    end
end

function Horror.NoHeadcrabs(b)
    Horror.__noheadcrabs = b
end

NoHeadcrabs = Horror.NoHeadcrabs

function Horror.StartWithNothing(b)
    Horror.__nospawnwep = b
end

StartWithNothing = Horror.StartWithNothing
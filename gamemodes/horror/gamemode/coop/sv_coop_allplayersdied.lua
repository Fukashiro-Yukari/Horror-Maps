util.PrecacheSound('horror/mission_failed.wav')

Horror.__restarting = false

function Horror:MissionFailed()
    if !self then
        self = Horror
    end

    if !self.__restarting then return end

    self.__restarting = true

	for k,v in pairs(player.GetAll()) do
        v:ScreenFade(SCREENFADE.OUT,color_black,6,2)
        v:Freeze(true)
        v:ConCommand('play horror/mission_failed.wav')
        v:StripAmmo()
        v:StripWeapons()
        v:SetNW2Bool('qtg_hr_missionfailed',true)
    end

    timer.Simple(7.3,function()
        game.CleanUpMap()
    end)

    timer.Simple(7.4,function()
        for k,v in pairs(player.GetAll()) do
            v:Spawn()
            v:Freeze(false)
            v:SetNW2Bool('qtg_hr_missionfailed',false)
        end

        self.__restarting = false
    end)
end

MissionFailed = Horror.MissionFailed
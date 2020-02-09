local function shit()
    if CLIENT then return end

    local ENT = scripted_ents.Get('lua_run')
    local old = ENT.RunCode

    if !old then return end
    
    function ENT:RunCode(ac,ca,co)
        local r = hook.Run('OnMapRunLua',ac,ca,co)

        if r then
            if r == true then
                return
            else
                co = r
            end
        end

        return old(self,ac,ca,co)
    end

    scripted_ents.Register(ENT,'lua_run')
end

timer.Simple(0,shit)

local hookr = {
	['CanPlayerSuicide'] = true,
	['PlayerCanPickupWeapon'] = true,
	['PlayerDeath'] = true,
	['KeyPress'] = true,
	['DrawDeathNotice'] = true,
	['PlayerDeathThink'] = true
}

function GM:OnMapRunLua(ac,ca,co)
    for k,v in pairs(hookr) do
        if isstring(co) and string.find(co,k) then
            return true
        end
    end
end

function GM:AcceptInput(e,i,a,c,v)
    if !IsValid(a) or !IsValid(e) then return end

    if a:IsPlayer() then
        if IsValid(e) and e:GetClass() == 'game_player_equip' then
            a:SetNW2Bool('qtg_hr_forcegivewep',true)
        end

        if IsValid(e) and e:GetClass() == 'player_weaponstrip' and IsValid(a:GetActiveWeapon()) and Horror.__crewept[a:GetActiveWeapon():GetClass()] then
            return true
        end
    end
end
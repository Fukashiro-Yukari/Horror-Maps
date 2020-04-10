GM.Name = 'Horror Maps'
GM.Author = 'Neptune QTG'

function GM:Initialize()
	if GetConVar('sv_defaultdeployspeed'):GetInt() != 1 then
		game.ConsoleCommand('sv_defaultdeployspeed 1\n')
	end
end

function GM:Think()
	hook.Call('RemoveHook',GAMEMODE)
	
	for k,p in pairs(player.GetAll()) do
		hook.Call('PlayerThink',GAMEMODE,p)
	end
end

function GM:Tick()
end

local rclasst = {
	['npc_poisonzombie'] = true,
	['npc_headcrab'] = true,
	['npc_headcrab_fast'] = true,
	['npc_headcrab_black'] = true,
	['npc_headcrab_poison'] = true,
}

local bclasst = {
	['npc_zombie_torso'] = true,
	['npc_zombie'] = true,
	['npc_fastzombie'] = true,
	['npc_zombine'] = true
}

function GM:PlayerTick(p,m)
	local dist = p:GetVelocity():LengthSqr()

	if p:KeyDown(IN_SPEED) and dist > p:GetWalkSpeed()^2 then
		p:SetNW2Bool('QTG_Running',true)
	elseif p:GetNW2Bool('QTG_Running') then
		p:SetNW2Bool('QTG_Running',false)
	end
	
	if !Horror or !Horror.GetConvar then return end
	
	local sprint = Horror.GetConvar('sprint_durable')
	
	if SERVER then
		local alive = 0

		for k,v in pairs(player.GetAll()) do
			if v:Alive() then
				alive = alive+1
			end
		end

		if #player.GetAll() > 1 and alive <= 0 and Horror.GetConvar('all_playerdeathfailed'):GetBool() then
			Horror.MissionFailed('All players are dead')
		end
		
		if Horror.__noheadcrabs then
			for k,v in pairs(ents.GetAll()) do
				if rclasst[v:GetClass()] then
					SafeRemoveEntity(v)
				end
		
				if bclasst[v:GetClass()] then
					v:SetBodygroup(1,0)
				end
			end
		end

		if istable(Horror.__agivewept) then
			for k,v in pairs(Horror.__agivewept) do
				if !p:HasWeapon(v) and p:Alive() then
					p:Give(v)
				end
			end
		end

		if p:Alive() and (p:IsOnGround() or p:WaterLevel() > 0) then
			if !p:Crouching() and m:KeyDown(IN_SPEED) and p:GetVelocity():LengthSqr() > p:GetWalkSpeed()^2 then
				if p:GetNW2Float('QTG_hr_sprint_durable') > 0 then
					p:SetNW2Float('QTG_hr_sprint_durable',p:GetNW2Float('QTG_hr_sprint_durable')-0.3)
				else
					p.tbspeedkey = CurTime()+1.5
				end
			elseif !m:KeyDown(IN_SPEED) and p:GetNW2Float('QTG_hr_sprint_durable') < sprint:GetFloat() then
				if p.tbspeedkey and p.tbspeedkey > CurTime() then
				else
					p:SetNW2Float('QTG_hr_sprint_durable',p:GetNW2Float('QTG_hr_sprint_durable')+0.065)
				end
			end
		end

		local n = 1

		if p:GetNW2Float('qtg_hr_jump') < 0.3 then
			p:SetNW2Float('qtg_hr_jump',0.3)
		end

		if p:GetNW2Float('qtg_hr_jumptime')-CurTime() < 1 and p:GetNW2Float('qtg_hr_jumptime')-CurTime() > 0 then
			p:SetNW2Float('qtg_hr_jump',1)
		end

		if p:Alive() then
			n = p:GetNW2Float('qtg_hr_jump')
		end

		hook.Call('PlayerSpeed',GAMEMODE,p,n)
	end
end

if SERVER then
    util.AddNetworkString('Horror_NetHook')
end

local nett = {}

function Horror.StartNet(a,t,v,...)
    net.Start('Horror_NetHook')
	net.WriteString(a)

	local args = {...}
	
	if CLIENT then
		if v then
			table.insert(args,1,v)
		end

		table.insert(args,1,t)
		table.insert(args,1,LocalPlayer())
	end

    net.WriteTable(args)

    if SERVER then
        t = t or 'Broadcast'

        if net[t] then
            net[t](v)

            return true
        else
            return false
        end
    else
        net.SendToServer()

        return true
    end

    return false
end

net.Receive('Horror_NetHook',function(_,p)
    local id = net.ReadString()
	local t = net.ReadTable()
	
	if CLIENT then
		table.insert(t,1,LocalPlayer())
	end

    if nett[id] then
        nett[id](unpack(t))
    end
end)

function Horror.ReadNet(a,b)
    if !isfunction(b) then return end

    nett[a] = b
end
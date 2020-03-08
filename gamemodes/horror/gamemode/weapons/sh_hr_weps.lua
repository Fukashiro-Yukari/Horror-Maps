Horror.__crewept = {}
Horror.__agivewept = {}

function Horror.AddCantRemoveWep(s,b)
    Horror.__crewept[s] = s
end

function Horror.AddAutoGiveWep(s,b)
    local wt = weapons.Get(s)

    if istable(wt) then
        Horror.__agivewept[s] = s
    end

    if b then return end

    Horror.__crewept[s] = s
end

timer.Simple(0,function()
    local name = 'qtg_hr_item_'

    Horror.AddAutoGiveWep(name..'lighter')
end)

local function addwep(t,c)
    t.Base = 'qtg_hr_item_base'
    t.Category = 'Horror Maps'
    t.UseHands = true

    weapons.Register(t,'qtg_hr_item_'..c)
end

game.AddParticles('particles/lighter.pcf')
PrecacheParticleSystem('lighter_flame')

local SWEP = {Primary = {},Secondary = {}}

SWEP.PrintName			        = 'Lighter'

SWEP.Spawnable			        = true

SWEP.ViewModelFOV 		        = 70

SWEP.WeaponInfoType			    = 2

SWEP.DeploySound                = {'lighter/lighter_draw.wav',100,100}
SWEP.HolsterSound               = {'lighter/lighter_holster.wav',100,100}

function SWEP:ChangePickUp()
    ParticleEffectAttach('lighter_flame',PATTACH_POINT_FOLLOW,self:GetOwner():GetViewModel(),1)
end

function SWEP:PreChangeHolster()
    self.Owner:GetViewModel():StopParticles()
end

function SWEP:ThinkPickUp()
    if SERVER then return end

    local l = DynamicLight(self:EntIndex()..'_lighter')
				
	if l then
		l.Pos = self.Owner:EyePos()
		l.r = 212
		l.g = 131
		l.b = 43
		l.Brightness = 2
		l.Size = 150
		l.DieTime = CurTime()+0.01
		l.Style = 1
	end
end

addwep(SWEP,'lighter')
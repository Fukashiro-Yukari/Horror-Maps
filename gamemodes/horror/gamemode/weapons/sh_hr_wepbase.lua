local function addwep(t,c)
    weapons.Register(t,'qtg_hr_item_'..c)
end

local SWEP = {Primary = {},Secondary = {}}

SWEP.HoldType			        = 'pistol'
SWEP.HoldTypeOff                = 'normal'

SWEP.PrintName			        = 'Horror Maps Weapon Base'

SWEP.Slot		                = 5
SWEP.SlotPos			        = 0

SWEP.DrawAmmo			        = true
SWEP.BounceWeaponIcon	        = true
SWEP.DrawCrosshair		        = false

SWEP.ViewModel			        = 'models/weapons/c_lighter.mdl'
SWEP.WorldModel			        = 'models/weapons/w_lighter_fix.mdl'

SWEP.DeployAnim					= ACT_VM_DRAW
SWEP.DeploySound                = ''

SWEP.HolsterAnim                = ACT_VM_HOLSTER
SWEP.HolsterSound               = ''

SWEP.IdleAnim					= ACT_VM_IDLE

SWEP.ViewModelFOV 		        = 54

SWEP.Weight				        = 2
SWEP.AutoSwitchTo		        = true
SWEP.Spawnable			        = false

SWEP.WeaponInfoType			    = 0
SWEP.WeaponInfoModelCustom	    = ''
SWEP.WeaponInfoModelSize	    = 45
SWEP.WeaponInfoFontCustom	    = 'QTG_hr_SelectIcons'
SWEP.WeaponInfoFontIcon		    = 'd'
SWEP.WeaponInfoFontColor	    = Color(255,210,0)
SWEP.WeaponInfoPNGCustom	    = ''

SWEP.Delay                      = 1

SWEP.Primary.ClipSize           = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic          = false
SWEP.Primary.Ammo               = 'none'

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = false
SWEP.Secondary.Ammo             = 'none'

SWEP.CanIdle                    = true
SWEP.CanHolster                 = true

function SWEP:AddNWVar(a,b,...)
	if !istable(self.__nwvarn) then
		self.__nwvarn = {
			['String'] = 0,
			['Bool'] = 0,
			['Float'] = 0,
			['Int'] = 0,
			['Vector'] = 0,
			['Angle'] = 0,
			['Entity'] = 0
		}
	end

	if self.__nwvarn[a] then
		self:NetworkVar(a,self.__nwvarn[a],b,...)
		self.__nwvarn[a] = self.__nwvarn[a]+1
	end
end

function SWEP:SetupDataTables()
	self:AddNWVar('Bool','Empty')
	self:AddNWVar('Bool','IsChange')
    self:AddNWVar('Float','NextIdle')

	self:AltSetupDataTables()
end

function SWEP:AltSetupDataTables() end

function SWEP:SendAnim(o)
    if !o then return end
    if !IsValid(self:GetOwner()) then return end

    if istable(o) then
		o = table.Random(o)
    end
    
    local vm = self:GetOwner():GetViewModel()
    if !IsValid(vm) then return end

	if isstring(o) then
		if o != '' then
			vm:SendViewModelMatchingSequence(vm:LookupSequence(o))
		end
	else
		self:SendWeaponAnim(o)
	end
end

function SWEP:ChangeHoldType()
    self:SetHoldType(self:GetEmpty() and self.HoldTypeOff or self.HoldType)
end

function SWEP:Initialize()
	self:ChangeHoldType()
end

function SWEP:Deploy()
    if !IsFirstTimePredicted() then return end

    self:ChangeHoldType()

    if !self:GetEmpty() then
        self:SendAnim(self.DeployAnim)
		self:EmitSound(istable(self.DeploySound) and unpack(self.DeploySound) or self.DeploySound)
	end

	self:SetNextSecondaryFire(CurTime()+self.Delay)
	self:SetIsChange(true)
	self:PreChangePickUp()

    return true
end

function SWEP:Holster()
	self:SetEmpty(false)

	return true
end

function SWEP:CustomHolster()
	self:SendAnim(self.HolsterAnim)
	self:EmitSound(istable(self.HolsterSound) and unpack(self.HolsterSound) or self.HolsterSound)
	self:SetNextSecondaryFire(CurTime()+self.Delay)
	self:SetIsChange(true)
	self:PreChangeHolster()
end

function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:PrimaryAttack() end

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:SecondaryAttack()
    if !self:CanSecondaryAttack() then return end
    if !IsValid(self:GetOwner()) then return end
    if !self.CanHolster then return end

    local vm = self:GetOwner():GetViewModel()
	
    if !IsValid(vm) then return end

    self:SetEmpty(!self:GetEmpty())
    self:ChangeHoldType()

    if self:GetEmpty() then
        self:CustomHolster()
    else
        self:ChangeHoldType()
        self:Deploy()
	end
end

function SWEP:Think()
    if !IsValid(self:GetOwner()) then return end
    if self:GetOwner():IsNPC() then return end
    
    local ct = CurTime()

    if self:GetEmpty() then
        if self:GetIsChange() and self:GetNextSecondaryFire() < ct then
            self:ChangeHoldType()
			self:ChangeHolster()
			self:SetIsChange(false)
        end

        self:ThinkHolster()
    else
        if self:GetIsChange() and self:GetNextSecondaryFire() < ct then
			self:ChangePickUp()
			self:SetIsChange(false)
        end

		if self:GetNextSecondaryFire() < ct then
			self:ThinkPickUp()
		end
    end
    
    local vm = self:GetOwner():GetViewModel()
	
	if !IsValid(vm) then return end

	if self:GetNextIdle() < ct and self.CanIdle and vm:SequenceDuration() < ct and self:GetNextSecondaryFire() < ct and !self:GetEmpty() then
		self:SendAnim(self.IdleAnim)
		self:SetNextIdle(ct+vm:SequenceDuration())
	end
end

SWEP.MaterialErrer = false
local function CheckMaterial(self,a)
	if self.MaterialErrer then
		return 'icon16/gun.png'
	end
	
	if Material(a):IsError() and !self.MaterialErrer then
		self.MaterialErrer = true
		Msg('Warning: WeaponIcon not found "'..a..'"\n')
		return 'icon16/gun.png'
	end
	
	return a
end

local wepinfot = {
    function(self,x,y,wide,tall,alpha,fsin)
    end,
    function(self,x,y,wide,tall,alpha,fsin)
        local color = self.WeaponInfoFontColor
		local color2 = Color(color.r,color.g,color.b,math.Rand(10,120))

		draw.SimpleText(self.WeaponInfoFontIcon,self.WeaponInfoFontCustom,x+wide/2,y+tall*0.10,color,TEXT_ALIGN_CENTER)
		
		if self.BounceWeaponIcon then
			draw.SimpleText(self.WeaponInfoFontIcon,self.WeaponInfoFontCustom,x+wide/2+math.Rand(-4,4),y+tall*0.10+math.Rand(-14,14),color2,TEXT_ALIGN_CENTER)
			draw.SimpleText(self.WeaponInfoFontIcon,self.WeaponInfoFontCustom,x+wide/2+math.Rand(-4,4),y+tall*0.10+math.Rand(-9,9),color2,TEXT_ALIGN_CENTER)
		end
    end,
    function(self,x,y,wide,tall,alpha,fsin)
        local mat = CheckMaterial(self,self.WeaponInfoPNGCustom != '' and self.WeaponInfoPNGCustom or 'entities/'..self.ClassName..'.png')

		if !self.__oldweppngicon or self.__oldweppngicon != mat then
			self.__oldweppngicon = mat

			self.__weppngiconmat = Material(mat)
		end

		surface.SetDrawColor(255,255,255,alpha)
		surface.SetMaterial(self.__weppngiconmat)

		if self.OldBounceWeaponIcon then
			surface.DrawTexturedRect(x+wide/4+0.5+fsin,y-fsin,wide/2-fsin*2,(wide/2)+fsin)
		else
			surface.DrawTexturedRect(x+wide/4+0.5,y-fsin,wide/2,wide/2)
		end
    end
}

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	y = y + 10
	x = x + 10
	wide = wide - 20
    tall = tall - 20

    local fsin = self.BounceWeaponIcon and math.sin(CurTime()*10)*5 or 0
		
	if wepinfot[self.WeaponInfoType] then
		wepinfot[self.WeaponInfoType](self,x,y,wide,tall,alpha,fsin)
	else
		if !isnumber(self.WepSelectIcon) then
			self.WepSelectIcon = surface.GetTextureID(self.WepSelectIcon)
		end

		surface.SetDrawColor(255,255,255,alpha)
		surface.SetTexture(self.WepSelectIcon)
		
		if self.OldBounceWeaponIcon then
			surface.DrawTexturedRect(x+fsin,y-fsin,wide-fsin*2,(wide/2)+fsin)
		else
			surface.DrawTexturedRect(x,y-fsin,wide,wide/2)
		end
	end
end

function SWEP:ThinkPickUp() end
function SWEP:ThinkHolster() end
function SWEP:PreChangePickUp() end
function SWEP:PreChangeHolster() end
function SWEP:ChangePickUp() end
function SWEP:ChangeHolster() end

addwep(SWEP,'base')
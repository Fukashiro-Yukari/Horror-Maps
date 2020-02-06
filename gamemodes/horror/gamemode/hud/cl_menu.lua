local HrMenu = {}

local w,h = ScrW(),ScrH()
local x,y = 0,0
local menubg = Color(0,0,255,120)
local menupr = Color(80,20,100,120)

local function RespawnMenu()
	local menuIsvisible = false

	if IsValid(hrmenu) then
		menuIsvisible = hrmenu:IsVisible()
		hrmenu:SetVisible(false)
	end

	hrmenu = vgui.Create('HorrorMapsMenu')
	hrmenu:SetVisible(true)

	if menuIsvisible then
		hrmenu:Show()
	else
		hrmenu:Hide()
	end
end

function HrMenu:SetColor()
	local color = Color(Horror.GetConvar('menu_r'):GetInt(),Horror.GetConvar('menu_g'):GetInt(),Horror.GetConvar('menu_b'):GetInt())
	menubg = Color(color.r,color.g,color.b,120)
end

function HrMenu:Init()
	self:SetColor()

	local p = LocalPlayer()

	self:SetSize(w,h)
	self:Center()
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)

	local frame = self:Add('DForm')
	frame:SetSize(w,h)
	frame:Center()
	frame:SetName('')
	frame.Paint = function(self,w,h)
		surface.SetDrawColor(menubg)
		surface.DrawRect(0,0,w,h)
	end

	w,h = ScrW()-20,ScrH()-20

	local frame2 = frame:Add('EditablePanel')
	frame2:SetSize(w,h)
	frame2:Center()
	frame2:SetName('')
	frame2.Paint = function(self,w,h)
		surface.SetDrawColor(menubg)
		surface.DrawRect(0,0,w,h)
	end

	local Scroll = frame2:Add('DScrollPanel')
	Scroll:Dock(FILL)

	local sbar = Scroll:GetVBar()

	function sbar:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h,menubg)
	end

	function sbar.btnUp:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h-5,menubg)
	end

	function sbar.btnDown:Paint(w,h)
		draw.RoundedBox(3,5,5,w-5,h-5,menubg)
	end

	function sbar.btnGrip:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h,menupr)
		if self.Hovered then
			draw.RoundedBox(3,5,0,w-5,h,menupr)
		end
		if self.Depressed then
			draw.RoundedBox(3,5,0,w-5,h,Color(60,0,100))
		end
	end

	local Sheet = Scroll:Add('DPropertySheet')
	Sheet:SetPos(0,0)
	Sheet:Dock(FILL)
	Sheet:SetSize(w,h)
	Sheet.Paint = function(self,w,h)
		surface.SetDrawColor(Color(0,0,0,0))
		surface.DrawRect(0,0,w,h)
	end

	self:SpawnMenu(Sheet)
	self:PlayerEditorMenu(Sheet)
	self:ContextMenu(Sheet)

	hook.Run('QTG_HorrorMapsAddMenu',Sheet)

	self:SettingMenu(Sheet)
end

local oldrplymodel =  Horror.GetConvar('randomplayerModel'):GetBool()
local oldshoww = Horror.GetConvar('show_all_weapon'):GetBool()

function HrMenu:Think()
	local newrplymodel =  Horror.GetConvar('randomplayerModel'):GetBool()
	local newshoww = Horror.GetConvar('show_all_weapon'):GetBool()

	if oldrplymodel != newrplymodel or oldshoww != newshoww then
		RespawnMenu()
		oldrplymodel = newrplymodel
		oldshoww = newshoww
	end
end

function Horror.AddMenuTabs(a,b,c,d)
	if c == nil then c = 'icon16/plugin.png' end
	local panel = a:Add('EditablePanel')

	panel.Paint = function(self,w,h) 
		draw.RoundedBox(4,0,0,w,h,Color(255,255,255,0))
	end

	a:AddSheet(b,panel,c)

	if d == nil then d = function(panel) end end
	d(panel)

	return panel
end

function HrMenu:ContextMenu(pl)
	Horror.AddMenuTabs(pl,'Context','icon16/plugin.png',function(panel)
		local frame = panel:Add('EditablePanel')
		frame:SetPos(0,0)
		frame:Dock(FILL)
		frame.Paint = function(self,w,h)
			surface.SetDrawColor(Color(0,0,0,0))
			surface.DrawRect(0,0,w,h)
		end

		local IconLayout = frame:Add('DIconLayout')
		IconLayout:Dock(LEFT)
		IconLayout:SetBorder(8)
		IconLayout:SetSpaceX(8)
		IconLayout:SetSpaceY(8)
		IconLayout:SetWide(200)
		IconLayout:SetLayoutDir(LEFT)

		for k, v in pairs(list.Get('DesktopWindows')) do
			local icon = IconLayout:Add('DButton')
			icon:SetText('')
			icon:SetSize(80,82)
			icon.Paint = function() end

			local label = icon:Add('DLabel')
			label:Dock(BOTTOM)
			label:SetText(v.title)
			label:SetContentAlignment(5)
			label:SetTextColor(Color(255,255,255,255))
			label:SetExpensiveShadow(1,Color(0,0,0,200))

			local image = icon:Add('DImage')
			image:SetImage(v.icon)
			image:SetSize(64,64)
			image:Dock(TOP)
			image:DockMargin(8,0,8,0)
			icon.DoClick = function()
				local newv = list.Get('DesktopWindows')[k]

				if v.onewindow then
					if IsValid(icon.Window) then icon.Window:Center() return end
				end

				icon.Window = self:Add('DFrame')
				icon.Window:SetSize(newv.width,newv.height)
				icon.Window:SetTitle(newv.title)
				icon.Window:Center()

				newv.init(icon,icon.Window)
			end
		end
	end)
end

function HrMenu:SpawnMenu(pl)
	local p = LocalPlayer()
	if !p:IsAdmin() then return end

	Horror.AddMenuTabs(pl,'Weapons','icon16/gun.png',function(panel)
		local Scroll = panel:Add('DScrollPanel')
		Scroll:Dock(FILL)
		local sbar = Scroll:GetVBar()

		function sbar:Paint(w,h)
			draw.RoundedBox(3,5,0,w-5,h,menubg)
		end

		function sbar.btnUp:Paint(w,h)
			draw.RoundedBox(3,5,0,w-5,h-5,menubg)
		end

		function sbar.btnDown:Paint(w,h)
			draw.RoundedBox(3,5,5,w-5,h-5,menubg)
		end

		function sbar.btnGrip:Paint(w,h)
			draw.RoundedBox(3,5,0,w-5,h,menupr)
			if self.Hovered then
				draw.RoundedBox(3,5,0,w-5,h,menupr)
			end
			if self.Depressed then
				draw.RoundedBox(3,5,0,w-5,h,Color(60,0,100))
			end
		end

		local frame = panel:Add('EditablePanel')
		frame:SetSize(ScrW()/8,h-40)
		frame:SetPos(0,0)
		frame.Paint = function(self,w,h)
			surface.SetDrawColor(menubg)
			surface.DrawRect(0,0,w,h)
		end

		local frame2 = Scroll:Add('EditablePanel')
		frame2:SetSize(w-ScrW()/8,1e9)
		frame2:SetPos(255,0)
		frame2.Paint = function(self,w,h)
			surface.SetDrawColor(menubg)
			surface.DrawRect(0,0,w,h)
		end

		local dtree = frame:Add('DTree')
		dtree:Dock(FILL)
		frame2.HorizontalDivider = frame2:Add('DHorizontalDivider')
		frame2.HorizontalDivider:Dock(FILL)
		frame2.HorizontalDivider:SetLeftWidth(50)
		frame2.HorizontalDivider:SetLeftMin(20)
		frame2.HorizontalDivider:SetRightMin(20)
		frame2.HorizontalDivider:SetDividerWidth(6)

		function frame2:SwitchPanel(pl)
			if IsValid(self.SelectedPanel) then
				self.SelectedPanel:SetVisible(false)
				self.SelectedPanel = nil
			end
			self.SelectedPanel = pl
			self.HorizontalDivider:SetRight(self.SelectedPanel)
			self.HorizontalDivider:InvalidateLayout(true)
			self.SelectedPanel:SetVisible(true)
			self:InvalidateParent()
		end

		local Weapons = list.Get('Weapon')
		local Categorised = {}
		local showw = Horror.GetConvar('show_all_weapon')
		for k,w in pairs(Weapons) do
			if !w.Spawnable and !showw:GetBool() then continue end
			Categorised[w.Category] = Categorised[w.Category] or {}
			table.insert(Categorised[w.Category],w)
		end

		Weapons = nil

		for CategoryName,v in SortedPairs(Categorised) do
			local node = dtree:AddNode(CategoryName,'icon16/gun.png')

			node.DoPopulate = function(self)
				if self.PropPanel then return end
				self.PropPanel = frame2:Add('DIconLayout')
				self.PropPanel:Dock(FILL)
				self.PropPanel:SetBorder(8)
				self.PropPanel:SetSpaceX(0)
				self.PropPanel:SetSpaceY(0)
				self.PropPanel:SetWide(200)
				self.PropPanel:SetLayoutDir(TOP)
				self.PropPanel:SetVisible(true)
				for k, ent in SortedPairsByMemberValue(v,'PrintName') do
					local cicon = self.PropPanel:Add('ContentIcon')
					cicon:SetMaterial('entities/'..ent.ClassName..'.png')
					cicon:SetName(ent.PrintName or ent.ClassName)
					cicon.DoClick = function()
						for i=1,2 do
							Horror.StartNet('GiveWeapon',ent.ClassName)
						end
					end
					cicon.OpenMenu = function()
						local menu = DermaMenu()
						menu:AddOption('Copy to clipboard',function() SetClipboardText(ent.ClassName) end):SetIcon('icon16/cut.png')
						menu:Open()
					end
				end
			end

			node.DoClick = function(self)
				self:DoPopulate()
				frame2:SwitchPanel(self.PropPanel)
			end

			node.Paint = function(self,w,h) 
				draw.RoundedBox(4,0,0,w,h,Color(255,255,255,0))
			end
		end
	end)
end

local default_animations = {'idle_all_01','menu_walk','pose_standing_02','pose_standing_03','idle_fist'}

function HrMenu:PlayerEditorMenu(pl)
	Horror.AddMenuTabs(pl,'Player Editor','icon16/user_edit.png',function(panel)
		local mdl = panel:Add('DModelPanel')
		mdl:Dock(FILL)
		mdl:SetFOV(50)
		mdl:SetCamPos(Vector(0,0,0))
		mdl:SetDirectionalLight(BOX_RIGHT,Color(255,160,80,255))
		mdl:SetDirectionalLight(BOX_LEFT,Color(80,160,255,255))
		mdl:SetAmbientLight(Vector(-64,-64,-64))
		mdl:SetAnimated(true)
		mdl.Angles = Angle(0,0,0)
		mdl:SetLookAt(Vector(-100,0,-22))

		local sheet = panel:Add('DPropertySheet')
		sheet:Dock(RIGHT)
		sheet:SetSize(ScrW()/2,0)
		sheet.Paint = function(self,w,h)
			surface.SetDrawColor(menubg)
			surface.DrawRect(0,20,w,h-20)
		end
		
		local PanelSelect
		if !Horror.GetConvar('randomplayerModel'):GetBool() then
			PanelSelect = sheet:Add('DPanelSelect')

			for name, model in SortedPairs(player_manager.AllValidModels()) do
				local icon = vgui.Create('SpawnIcon')
				icon:SetModel(model)
				icon:SetSize(64,64)
				icon:SetTooltip(name)
				icon.playermodel = name
				PanelSelect:AddPanel(icon,{cl_playermodel=name})
			end

			sheet:AddSheet('Model',PanelSelect,'icon16/user.png')
		end

		local controls = panel:Add('EditablePanel')
		controls:DockPadding(8,8,8,8)
		controls.Paint = function(self,w,h)
			surface.SetDrawColor(Color(234,234,234))
			surface.DrawRect(0,0,w,h)
		end

		local lbl = controls:Add('DLabel')
		lbl:SetText('Player color')
		lbl:SetTextColor(Color(0,0,0))
		lbl:Dock(TOP)

		local plycol = controls:Add('DColorMixer')
		plycol:SetAlphaBar(false)
		plycol:SetPalette(false)
		plycol:Dock(TOP)
		plycol:SetSize(200,260)

		local lbl = controls:Add('DLabel')
		lbl:SetText('Physgun color')
		lbl:SetTextColor(Color(0,0,0))
		lbl:DockMargin(0,20,0,0)
		lbl:Dock(TOP)

		local wepcol = controls:Add('DColorMixer')
		wepcol:SetAlphaBar(false)
		wepcol:SetPalette(false)
		wepcol:Dock(TOP)
		wepcol:SetSize(200,260)
		wepcol:SetVector(Vector(GetConVar('cl_weaponcolor'):GetString()))
		
		local DermaButton = controls:Add('DButton')
		DermaButton:SetText('Reset to default values')
		DermaButton:SetTextColor(Color(0,0,0))
		DermaButton:Dock(TOP)
		DermaButton:DockMargin(0,20,0,0)
		DermaButton:SetSize(200,40)
		DermaButton.DoClick = function()
			plycol:SetVector(Vector(0.24,0.34,0.41))
			wepcol:SetVector(Vector(0.30,1.80,2.10))
			RunConsoleCommand('cl_playercolor','0.24 0.34 0.41')
			RunConsoleCommand('cl_weaponcolor','0.30 1.80 2.10')
		end

		DermaButton.Paint = function(_,w,h)
			local menubg2 = menubg
			if DermaButton:IsHovered() then
				surface.SetDrawColor(menupr)
			else
				surface.SetDrawColor(menubg)
			end
			surface.DrawRect(0,0,w,h)
		end

		sheet:AddSheet('Colors',controls,'icon16/color_wheel.png')
		
		local bdcontrols
		local bdcontrolspanel
		local bgtab
		if !Horror.GetConvar('randomplayerModel'):GetBool() then
			bdcontrols = panel:Add('EditablePanel')
			bdcontrols:DockPadding(8,8,8,8)
			bdcontrols.Paint = function(self,w,h)
				surface.SetDrawColor(Color(234,234,234))
				surface.DrawRect(0,0,w,h)
			end

			bdcontrolspanel = bdcontrols:Add('DPanelList')
			bdcontrolspanel:EnableVerticalScrollbar(true)
			bdcontrolspanel:Dock(FILL)

			bgtab = sheet:AddSheet('Bodygroups',bdcontrols,'icon16/cog.png')
		end
		
		-- Helper functions

		local function MakeNiceName( str )
			local newname = {}

			for _, s in pairs( string.Explode( '_', str ) ) do
				if ( string.len( s ) == 1 ) then table.insert( newname, string.upper( s ) ) continue end
				table.insert( newname, string.upper( string.Left( s, 1 ) ) .. string.Right( s, string.len( s ) - 1 ) ) -- Ugly way to capitalize first letters.
			end

			return string.Implode( ' ', newname )
		end

		local function PlayPreviewAnimation( panel, playermodel )

			if ( !panel or !IsValid( panel.Entity ) ) then return end

			local anims = list.Get( 'PlayerOptionsAnimations' )

			local anim = default_animations[ math.random( 1, #default_animations ) ]
			if ( anims[ playermodel ] ) then
				anims = anims[ playermodel ]
				anim = anims[ math.random( 1, #anims ) ]
			end

			local iSeq = panel.Entity:LookupSequence( anim )
			if ( iSeq > 0 ) then panel.Entity:ResetSequence( iSeq ) end

		end

		-- Updating
		local function UpdateBodyGroups( pnl, val )
			if ( pnl.type == 'bgroup' ) then

				mdl.Entity:SetBodygroup( pnl.typenum, math.Round( val ) )

				local str = string.Explode( ' ',GetConVar('cl_playerbodygroups'):GetString())
				if ( #str < pnl.typenum + 1 ) then for i = 1, pnl.typenum + 1 do str[ i ] = str[ i ] or 0 end end
				str[ pnl.typenum + 1 ] = math.Round( val )
				RunConsoleCommand( 'cl_playerbodygroups', table.concat( str, ' ' ) )

			elseif ( pnl.type == 'skin' ) then

				mdl.Entity:SetSkin( math.Round( val ) )
				RunConsoleCommand( 'cl_playerskin', math.Round( val ) )

			end

			Horror.StartNet('SetModel')
		end

		local function RebuildBodygroupTab()
			bdcontrolspanel:Clear()

			bgtab.Tab:SetVisible( false )

			local nskins = mdl.Entity:SkinCount() - 1
			if ( nskins > 0 ) then
				local skins = vgui.Create( 'DNumSlider' )
				skins:Dock( TOP )
				skins:SetText( 'Skin' )
				skins:SetDark( true )
				skins:SetTall( 50 )
				skins:SetDecimals( 0 )
				skins:SetMax( nskins )
				skins:SetValue(GetConVar('cl_playerskin'):GetFloat())
				skins.type = 'skin'
				skins.OnValueChanged = UpdateBodyGroups

				bdcontrolspanel:AddItem( skins )

				mdl.Entity:SetSkin(GetConVar('cl_playerskin'):GetFloat())

				bgtab.Tab:SetVisible( true )
			end

			local groups = string.Explode( ' ',GetConVar('cl_playerbodygroups'):GetString())
			for k = 0, mdl.Entity:GetNumBodyGroups() - 1 do
				if ( mdl.Entity:GetBodygroupCount( k ) <= 1 ) then continue end

				local bgroup = vgui.Create( 'DNumSlider' )
				bgroup:Dock( TOP )
				bgroup:SetText( MakeNiceName( mdl.Entity:GetBodygroupName( k ) ) )
				bgroup:SetDark( true )
				bgroup:SetTall( 50 )
				bgroup:SetDecimals( 0 )
				bgroup.type = 'bgroup'
				bgroup.typenum = k
				bgroup:SetMax( mdl.Entity:GetBodygroupCount( k ) - 1 )
				bgroup:SetValue( groups[ k + 1 ] or 0 )
				bgroup.OnValueChanged = UpdateBodyGroups

				bdcontrolspanel:AddItem( bgroup )

				mdl.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )

				bgtab.Tab:SetVisible( true )
			end
		end

		local function UpdateFromConvars()
			local model = LocalPlayer():GetInfo('cl_playermodel')
			local modelname = player_manager.TranslatePlayerModel(model)
			if Horror.GetConvar('randomplayerModel'):GetBool() then
				modelname = LocalPlayer():GetModel()
			end
			util.PrecacheModel(modelname)
			mdl:SetModel(modelname)
			mdl.Entity.GetPlayerColor = function() return Vector(GetConVar('cl_playercolor'):GetString()) end
			mdl.Entity:SetPos(Vector(-100,0,-61))

			plycol:SetVector(Vector(GetConVar('cl_playercolor'):GetString()))
			wepcol:SetVector(Vector(GetConVar('cl_weaponcolor'):GetString()))

			PlayPreviewAnimation(mdl,model)
			if !Horror.GetConvar('randomplayerModel'):GetBool() then
				RebuildBodygroupTab()
			end
		end

		local function UpdateFromControls()
			RunConsoleCommand('cl_playercolor',tostring(plycol:GetVector()))
			RunConsoleCommand('cl_weaponcolor',tostring(wepcol:GetVector()))

			Horror.StartNet('SetModel')
		end

		plycol.ValueChanged = UpdateFromControls
		wepcol.ValueChanged = UpdateFromControls

		UpdateFromConvars()
		
		if !Horror.GetConvar('randomplayerModel'):GetBool() then
			function PanelSelect:OnActivePanelChanged(old,new)
				if old != new then -- Only reset if we changed the model
					RunConsoleCommand('cl_playerbodygroups','0')
					RunConsoleCommand('cl_playerskin','0')
				end
				timer.Simple( 0.1, function() UpdateFromConvars() end)
				
				Horror.StartNet('SetModel')
			end
		end

		-- Hold to rotate

		function mdl:DragMousePress()
			self.PressX, self.PressY = gui.MousePos()
			self.Pressed = true
		end

		function mdl:DragMouseRelease() self.Pressed = false end

		function mdl:LayoutEntity( ent )
			if ( self.bAnimated ) then self:RunAnimation() end

			if ( self.Pressed ) then
				local mx, my = gui.MousePos()
				self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )

				self.PressX, self.PressY = gui.MousePos()
			end

			ent:SetAngles( self.Angles )
		end
		local oldmodel = LocalPlayer():GetModel()
		function panel:Think()
			local newmodel = LocalPlayer():GetModel()
			if Horror.GetConvar('randomplayerModel'):GetBool() and oldmodel != newmodel then
				UpdateFromConvars()
				oldmodel = newmodel
			end
		end
	end)
end

function Horror.AddSettingMenu(a,b,c)
	if c == nil then c = 'icon16/cog.png' end

	local panel = a:Add('EditablePanel')
	panel:DockPadding(8,8,8,8)
	panel.Paint = function(self,w,h)
		surface.SetDrawColor(Color(234,234,234))
		surface.DrawRect(0,0,w,h)
	end

	a:AddSheet(b,panel,c)

	local dtree = panel:Add('DTree')
	dtree:Dock(FILL)
	panel.PropPanel = panel:Add('EditablePanel')
	panel.PropPanel.Paint = function(self,w,h)
		surface.SetDrawColor(Color(234,234,234))
		surface.DrawRect(0,0,w,h)
	end

	panel.PropPanel:Dock(RIGHT)
	panel.PropPanel:SetSize(ScrW()/2+ScrW()/3,500)
	panel.HorizontalDivider = panel:Add('DHorizontalDivider')
	panel.HorizontalDivider:Dock(FILL)
	panel.HorizontalDivider:SetLeftWidth(250)
	panel.HorizontalDivider:SetLeftMin(250)
	panel.HorizontalDivider:SetRightMin(250)
	panel.HorizontalDivider:SetDividerWidth(6)
	panel.HorizontalDivider:SetLeft(dtree)
	panel.HorizontalDivider:SetRight(panel.PropPanel)

	function panel:SwitchPanel(pl)
		if IsValid(self.SelectedPanel) then
			self.SelectedPanel:SetVisible(false)
			self.SelectedPanel = nil
		end

		self.SelectedPanel = pl
		self.HorizontalDivider:SetRight(self.SelectedPanel)
		self.HorizontalDivider:InvalidateLayout(true)
		self.SelectedPanel:SetVisible(true)
		self:InvalidateParent()
	end

	return {dtree,panel}
end

function Horror.AddSettingMenuTab(a,b,c,d)
	if c == nil then c = 'icon16/cog.png' end
	if a == nil then return end
	local dtree = a[1]
	local panel = a[2]
	local node = dtree:AddNode(b,c)

	node.DoPopulate = function(self)
		if self.PropPanel then return end
		self.PropPanel = panel:Add('EditablePanel')
		self.PropPanel:Dock(RIGHT)
		self.PropPanel:SetSize(ScrW()/2+ScrW()/3,0)
		self.PropPanel:SetVisible(true)
		self.PropPanel.Paint = function(self,w,h)
			surface.SetDrawColor(Color(234,234,234))
			surface.DrawRect(0,0,w,h)
		end
		panel.PropPanel:SetVisible(false)
		d(self.PropPanel)
	end

	node.DoClick = function(self)
		self:DoPopulate()
		panel:SwitchPanel(self.PropPanel)
	end

	node.Paint = function(self,w,h)
		draw.RoundedBox(4,0,0,w,h,Color(255,255,255,0))
	end

	return node.PropPanel
end

function HrMenu:SettingMenu(pl)
	Horror.AddMenuTabs(pl,'Setting','icon16/cog.png',function(panel)
		local Sheet = panel:Add('DPropertySheet')
		Sheet:SetPos(0,0)
		Sheet:Dock(FILL)
		Sheet:SetSize(w,h)
		Sheet.Paint = function(self,w,h)
			surface.SetDrawColor(menubg)
			surface.DrawRect(0,20,w,h-20)
		end

		local panels = Horror.AddSettingMenu(Sheet,'Horror Maps Setting','icon16/cog.png')
		Horror.AddSettingMenuTab(panels,'Admin / Server','icon16/cog.png',function(pl)
			local pos = {x=15,y=0}
			local Checkbox = pl:Add('DCheckBoxLabel')
			Checkbox:SetPos(pos.x,pos.y)
			Checkbox:SetText('Random player model')
			Checkbox:SetTextColor(Color(0,0,0))
			Checkbox:SetConVar('horror_randomplayermodel')	
			Checkbox:SizeToContents()
			
			pos.y = pos.y+20

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,50,255))
			Label:SetText('If enabled, Player spawn will become a random model')
			Label:SizeToContents()

			pos.y = pos.y+20

			local Checkbox = pl:Add('DCheckBoxLabel')
			Checkbox:SetPos(pos.x,pos.y)
			Checkbox:SetText('Player teammate damage')
			Checkbox:SetTextColor(Color(0,0,0))
			Checkbox:SetConVar('horror_player_ff')	
			Checkbox:SizeToContents()

			pos.y = pos.y+20

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,50,255))
			Label:SetText('If enabled, Teammate attack will receive damage')
			Label:SizeToContents()

			pos.y = pos.y+20

			local NumSlider = pl:Add('DNumSlider')
			NumSlider:SetPos(pos.x,pos.y)
			NumSlider:SetSize(495,20)
			NumSlider:SetText('Players re-spawn time')
			NumSlider:SetMin(0)
			NumSlider:SetMax(100)
			NumSlider:SetDecimals(0)
			NumSlider:SetConVar('horror_respawntime')

			pos.y = pos.y+3

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,0,0))
			Label:SetText('Players re-spawn time')
			Label:SizeToContents()

			pos.y = pos.y+23

			local Checkbox = pl:Add('DCheckBoxLabel')
			Checkbox:SetPos(pos.x,pos.y)
			Checkbox:SetText('Player drop weapons after death')
			Checkbox:SetTextColor(Color(0,0,0))
			Checkbox:SetConVar('horror_ondeathdropweapon')
			Checkbox:SizeToContents()

			pos.y = pos.y+20

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,50,255))
			Label:SetText('If enabled, Player will drop all weapons on his body after death')
			Label:SizeToContents()

			pos.y = pos.y+20

			local NumSlider = pl:Add('DNumSlider')
			NumSlider:SetPos(pos.x,pos.y)
			NumSlider:SetSize(495,20)
			NumSlider:SetText('Players sprint durable')
			NumSlider:SetMin(0)
			NumSlider:SetMax(200)
			NumSlider:SetDecimals(0)
			NumSlider:SetConVar('horror_sprint_durable')

			pos.y = pos.y+3

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,0,0))
			Label:SetText('Players sprint durable')
			Label:SizeToContents()
		end)

		Horror.AddSettingMenuTab(panels,'Client','icon16/cog.png',function(pl)
			local pos = {x=15,y=0}

			local Checkbox = pl:Add('DCheckBoxLabel')
			Checkbox:SetPos(pos.x,pos.y)
			Checkbox:SetText('Show player halo')
			Checkbox:SetTextColor(Color(0,0,0))
			Checkbox:SetConVar('horror_show_playerhalo')	
			Checkbox:SizeToContents()
			
			pos.y = pos.y+20

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,50,255))
			Label:SetText('Switch show player halo')
			Label:SizeToContents()
		end)

		local panels = Horror.AddSettingMenu(Sheet,'Menu Setting','icon16/cog.png')
		Horror.AddSettingMenuTab(panels,'Client','icon16/cog.png',function(pl)
			local pos = {x=15,y=0}
			local color = Color(Horror.GetConvar('menu_r'):GetInt(),Horror.GetConvar('menu_g'):GetInt(),Horror.GetConvar('menu_b'):GetInt())

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,0,0))
			Label:SetText('Menu Color')
			Label:SizeToContents()

			local Mixer = pl:Add('DColorMixer')
			Mixer:Dock(TOP)
			Mixer:DockPadding(15,15,ScrW()/2,5)
			Mixer:SetColor(color)
			Mixer:SetAlphaBar(false)
			Mixer.ValueChanged = function(self)
				RunConsoleCommand('horror_menu_r',self:GetColor().r)
				RunConsoleCommand('horror_menu_g',self:GetColor().g)
				RunConsoleCommand('horror_menu_b',self:GetColor().b)
			end

			local DermaButton = pl:Add('DButton')
			DermaButton:SetText('Reset menu')
			DermaButton:SetTextColor(Color(0,0,0))
			DermaButton:Dock(TOP)
			DermaButton:DockMargin(15,15,ScrW()/2,5)
			DermaButton:SetSize(200,40)

			DermaButton.DoClick = function()
				RespawnMenu()
			end

			DermaButton.Paint = function(_,w,h)
				local menubg2 = menubg
				if DermaButton:IsHovered() then
					surface.SetDrawColor(menupr)
				else
					surface.SetDrawColor(menubg)
				end
				surface.DrawRect(0,0,w,h)
			end

			pos.y = pos.y+300

			local Checkbox = pl:Add('DCheckBoxLabel')
			Checkbox:SetPos(pos.x,pos.y)
			Checkbox:SetText('Show All Weapon')
			Checkbox:SetTextColor(Color(0,0,0))
			Checkbox:SetConVar('horror_show_all_weapon')	
			Checkbox:SizeToContents()

			pos.y = pos.y+20

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(0,50,255))
			Label:SetText('If enabled, Will display all weapons (including hidden weapons, does not include SWEP)')
			Label:SizeToContents()

			pos.y = pos.y+20

			local Label = pl:Add('DLabel')
			Label:SetPos(pos.x,pos.y)
			Label:SetTextColor(Color(255,0,0))
			Label:SetText('Warning: This option is very dangerous. Hidden weapons are usually the basis of weapons and can easily lead to game errors.')
			Label:SizeToContents()
		end)
		
		hook.Run('QTG_HorrorMapsAddSettingMenu',Sheet)
	end)
end

function HrMenu:Close() --outfitter fix
	self:Hide()
end

list.Set('PlayerOptionsAnimations','gman',{'menu_gman'})

list.Set('PlayerOptionsAnimations','hostage01',{'idle_all_scared'})
list.Set('PlayerOptionsAnimations','hostage02',{'idle_all_scared'})
list.Set('PlayerOptionsAnimations','hostage03',{'idle_all_scared'})
list.Set('PlayerOptionsAnimations','hostage04',{'idle_all_scared'})

list.Set('PlayerOptionsAnimations','zombine',{'menu_zombie_01'})
list.Set('PlayerOptionsAnimations','corpse',{'menu_zombie_01'})
list.Set('PlayerOptionsAnimations','zombiefast',{'menu_zombie_01'})
list.Set('PlayerOptionsAnimations','zombie',{'menu_zombie_01'})
list.Set('PlayerOptionsAnimations','skeleton',{'menu_zombie_01'})

list.Set('PlayerOptionsAnimations','combine',{'menu_combine'})
list.Set('PlayerOptionsAnimations','combineprison',{'menu_combine'})
list.Set('PlayerOptionsAnimations','combineelite',{'menu_combine'})
list.Set('PlayerOptionsAnimations','police',{'menu_combine'})
list.Set('PlayerOptionsAnimations','policefem',{'menu_combine'})

list.Set('PlayerOptionsAnimations','css_arctic',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_gasmask',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_guerilla',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_leet',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_phoenix',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_riot',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_swat',{'pose_standing_02','idle_fist'})
list.Set('PlayerOptionsAnimations','css_urban',{'pose_standing_02','idle_fist'})

vgui.Register('HorrorMapsMenu',HrMenu)

function GM:OnHorrorSpawnMenuOpen()
	if IsValid(hrmenu) then
		if !hrmenu:IsVisible() then
			hrmenu:Show()
		end
	else
		hrmenu = vgui.Create('HorrorMapsMenu')
	end
end

function GM:OnHorrorSpawnMenuClose()
	if IsValid(hrmenu) then
		hrmenu:Hide()
	end
end

concommand.Add('+menu',function()
	hook.Call('OnHorrorSpawnMenuOpen',GAMEMODE)
end,nil,'Opens the horror spawnmenu',{FCVAR_DONTRECORD})

concommand.Add('-menu',function()
	if (input.IsKeyTrapping()) then return end
	hook.Call('OnHorrorSpawnMenuClose',GAMEMODE)
end,nil,'Closes the horror spawnmenu',{FCVAR_DONTRECORD})

concommand.Add('horror_menu_reload',function()
	RespawnMenu()
end,nil,nil,FCVAR_DONTRECORD)
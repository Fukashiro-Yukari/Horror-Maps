function GM:PostGamemodeLoaded()
	if !ConVarExists('cl_playercolor') then CreateConVar('cl_playercolor','0.24 0.34 0.41',{FCVAR_ARCHIVE,FCVAR_USERINFO,FCVAR_DONTRECORD},'The value is a Vector - so between 0-1 - not between 0-255') end
	if !ConVarExists('cl_weaponcolor') then CreateConVar('cl_weaponcolor','0.30 1.80 2.10',{FCVAR_ARCHIVE,FCVAR_USERINFO,FCVAR_DONTRECORD},'The value is a Vector - so between 0-1 - not between 0-255') end
	if !ConVarExists('cl_playerskin') then CreateConVar('cl_playerskin','0',{FCVAR_ARCHIVE,FCVAR_USERINFO,FCVAR_DONTRECORD},'The skin to use, if the model has any') end
	if !ConVarExists('cl_playerbodygroups') then CreateConVar('cl_playerbodygroups','0',{FCVAR_ARCHIVE,FCVAR_USERINFO,FCVAR_DONTRECORD},'The bodygroups to use, if the model has any') end
	if !ConVarExists('cl_playerflexes') then CreateConVar('cl_playerflexes','0',{FCVAR_ARCHIVE,FCVAR_USERINFO,FCVAR_DONTRECORD},'The flexes to use, if the model has any') end
end

function Horror.AddConvar(a,b,c)
	if c then
		if !ConVarExists('horror_'..a) then CreateClientConVar('horror_'..a,b,FCVAR_ARCHIVE) end
	else
		if !ConVarExists('horror_'..a) then CreateConVar('horror_'..a,b,CLIENT and {FCVAR_REPLICATED} or {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}) end
	end
end

function Horror.AddInfo(a,b)
	if !ConVarExists('horror_'..a) then if CLIENT then CreateConVar('horror_'..a,b,{FCVAR_ARCHIVE,FCVAR_USERINFO}) end end
end

function Horror.GetConvar(a)
	if ConVarExists('horror_'..a) then
		return GetConVar('horror_'..a)
	end
	
	error('"'..a..'" Horror Convar Not Found!')
end

function Horror.GetInfo(p,a,b)
	return p:GetInfo('horror_'..a,b)
end

Horror.AddConvar('randomplayermodel',0)
Horror.AddConvar('player_ff',0)
Horror.AddConvar('respawntime',30)
Horror.AddConvar('ondeathdropweapon',1)
Horror.AddConvar('sprint_durable',200)

Horror.AddConvar('menu_r',0,true)
Horror.AddConvar('menu_g',0,true)
Horror.AddConvar('menu_b',255,true)
Horror.AddConvar('show_all_weapon',0,true)
Horror.AddConvar('show_playerhalo',1,true)
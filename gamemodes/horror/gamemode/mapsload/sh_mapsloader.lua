Horror.__loadmap = {}
Horror.MapObj = {}

local path = GM.FolderName..'/maps/'

function Horror.MapObj:Create()
    local t = {}

    setmetatable(t,self)
    self.__index = self

    t.PlayerLoadout = {}
    t.NoHeadcrabs = false
    t.ColorModify = {}

    return t
end

function Horror.MapObj:Init() end

function Horror.GetMapInfo()
    return Horror.__loadmap
end

function Horror.LoadMapInfo()
    path = path..game.GetMap()..'.lua'

    if !file.Exists(path,'LUA') then return end

    HorrorMaps = Horror.MapObj:Create()

    Horror:includefile(path)

    Horror.__loadmap = HorrorMaps
    HorrorMaps = nil
    Horror.MapObj = nil
end

if game.GetMap() then
    Horror.LoadMapInfo()
end
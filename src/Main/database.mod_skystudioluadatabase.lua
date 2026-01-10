local global = _G
local api = global.api
local table = global.table
local require = global.require
local pairs = global.pairs

local DayNightCycleManager = require('SkyStudioDayNightCycleManager')
local RenderParametersComponentManager = require('SkyStudioRenderParametersComponentManager')

local Mod_SkyStudioLuaDatabase = {}

function Mod_SkyStudioLuaDatabase.AddContentToCall(_tContentToCall)
    table.insert(_tContentToCall, require("Database.Mod_SkyStudioLuaDatabase"))
    table.insert(_tContentToCall, DayNightCycleManager)
    table.insert(_tContentToCall, RenderParametersComponentManager)
end

function Mod_SkyStudioLuaDatabase.Init()
    api.ui2.MapResources("SkyStudio")
end

function Mod_SkyStudioLuaDatabase.Shutdown()
    api.ui2.UnmapResources("SkyStudio")
end

Mod_SkyStudioLuaDatabase.tManagers = {
    ["Environments.CPTEnvironment"] = {
        ["Managers.Mod_SkyStudio.UIManager"] = {}
    }
}

Mod_SkyStudioLuaDatabase.AddLuaManagers = function(_fnAdd)
    for sManagerName, tParams in pairs(Mod_SkyStudioLuaDatabase.tManagers) do
        _fnAdd(sManagerName, tParams)
    end
end

return Mod_SkyStudioLuaDatabase

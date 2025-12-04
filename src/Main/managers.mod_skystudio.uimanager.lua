local global = _G
local api = global.api
local debug = api.debug
local pairs = global.pairs
local require = global.require
local module = global.module
local Object = require("Common.object")
local Mutators = require("Environment.ModuleMutators")
local type = global.type
local tostring = global.tostring
local tonumber = global.tonumber
local math = global.math
local trace = require("SkyStudioTrace")

local SkyStudioDataStore = require("SkyStudioDataStore")

---@class SkyStudioUIManager
local SkyStudioUIManager = module(..., Mutators.Manager())

local SkyStudioUI = require("UI.Mod_SkyStudio")

function SkyStudioUIManager:Init()
  trace("SkyStudioUIManager:Init()")

  self.ui = SkyStudioUI:new(function()
    trace("SkyStudioUIManager:SkyStudioUI is ready")
  
    self.ui:SkyStudioChangedValue_bUseVanillaLighting(function(_, value)
      trace("SkyStudioChangedValue_bUseVanillaLighting: " .. tostring(value))
      SkyStudioDataStore.bUseVanillaLighting = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunAzimuth(function(_, value)
      trace("SkyStudioChangedValue_nUserSunAzimuth: " .. tostring(value))
      SkyStudioDataStore.nUserSunAzimuth = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunLatitudeOffset(function(_, value)
      trace("SkyStudioChangedValue_nUserSunLatitudeOffset: " .. tostring(value))
      SkyStudioDataStore.nUserSunLatitudeOffset = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunTimeOfDay(function(_, value)
      trace("SkyStudioChangedValue_nUserSunTimeOfDay: " .. tostring(value))
      SkyStudioDataStore.nUserSunTimeOfDay = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunColorR(function(_, value)
      trace("SkyStudioChangedValue_nUserSunColorR: " .. tostring(value))
      SkyStudioDataStore.nUserSunColorR = value
    end, self) 

    self.ui:SkyStudioChangedValue_nUserSunColorG(function(_, value)
      trace("SkyStudioChangedValue_nUserSunColorG: " .. tostring(value))
      SkyStudioDataStore.nUserSunColorG = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunColorB(function(_, value)
      trace("SkyStudioChangedValue_nUserSunColorB: " .. tostring(value))
      SkyStudioDataStore.nUserSunColorB = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSunIntensity: " .. tostring(value))
      SkyStudioDataStore.nUserSunIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserSunUseLinearColors(function(_, value)
      trace("SkyStudioChangedValue_bUserSunUseLinearColors: " .. tostring(value))
      SkyStudioDataStore.bUserSunUseLinearColors = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonAzimuth(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonAzimuth: " .. tostring(value))
      SkyStudioDataStore.nUserMoonAzimuth = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonLatitudeOffset(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonLatitudeOffset: " .. tostring(value))
      SkyStudioDataStore.nUserMoonLatitudeOffset = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonTimeOfDay(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonTimeOfDay: " .. tostring(value))
      SkyStudioDataStore.nUserMoonTimeOfDay = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonColorR(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonColorR: " .. tostring(value))
      SkyStudioDataStore.nUserMoonColorR = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonColorG(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonColorG: " .. tostring(value))
      SkyStudioDataStore.nUserMoonColorG = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonColorB(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonColorB: " .. tostring(value))
      SkyStudioDataStore.nUserMoonColorB = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonIntensity: " .. tostring(value))
      SkyStudioDataStore.nUserMoonIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserMoonUseLinearColors(function(_, value)
      trace("SkyStudioChangedValue_bUserMoonUseLinearColors: " .. tostring(value))
      SkyStudioDataStore.bUserMoonUseLinearColors = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserDayNightTransition(function(_, value)
      trace("SkyStudioChangedValue_nUserDayNightTransition: " .. tostring(value))
      SkyStudioDataStore.nUserDayNightTransition = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunFade(function(_, value)
      trace("SkyStudioChangedValue_nUserSunFade: " .. tostring(value))
      SkyStudioDataStore.nUserSunFade = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonFade(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonFade: " .. tostring(value))
      SkyStudioDataStore.nUserMoonFade = value
    end, self)

    -- New override bindings

    self.ui:SkyStudioChangedValue_bUserOverrideSunTimeOfDay(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideSunTimeOfDay: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunTimeOfDay = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunOrientation(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideSunOrientation: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunOrientation = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunColorAndIntensity(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideSunColorAndIntensity: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunColorAndIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonOrientation(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonOrientation: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonOrientation = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonTimeOfDay(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonTimeOfDay: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonTimeOfDay = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonColorAndIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideDayNightTransition(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideDayNightTransition: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideDayNightTransition = value
    end, self)
    
    -- Show UI with current parameters (loaded from config file)
    self.ui:Show({
      bUseVanillaLighting = SkyStudioDataStore.bUseVanillaLighting,
      nUserSunAzimuth = SkyStudioDataStore.nUserSunAzimuth,
      nUserSunLatitudeOffset = SkyStudioDataStore.nUserSunLatitudeOffset,
      nUserSunTimeOfDay = SkyStudioDataStore.nUserSunTimeOfDay,
      nUserSunColorR = SkyStudioDataStore.nUserSunColorR,
      nUserSunColorG = SkyStudioDataStore.nUserSunColorG,
      nUserSunColorB = SkyStudioDataStore.nUserSunColorB,
      nUserSunIntensity = SkyStudioDataStore.nUserSunIntensity,
      bUserSunUseLinearColors = SkyStudioDataStore.bUserSunUseLinearColors,
      nUserMoonAzimuth = SkyStudioDataStore.nUserMoonAzimuth,
      nUserMoonLatitudeOffset = SkyStudioDataStore.nUserMoonLatitudeOffset,
      nUserMoonTimeOfDay = SkyStudioDataStore.nUserMoonTimeOfDay,
      nUserMoonColorR = SkyStudioDataStore.nUserMoonColorR,
      nUserMoonColorG = SkyStudioDataStore.nUserMoonColorG,
      nUserMoonColorB = SkyStudioDataStore.nUserMoonColorB,
      nUserMoonIntensity = SkyStudioDataStore.nUserMoonIntensity,
      bUserMoonUseLinearColors = SkyStudioDataStore.bUserMoonUseLinearColors,
      nUserDayNightTransition = SkyStudioDataStore.nUserDayNightTransition,
      nUserSunFade = SkyStudioDataStore.nUserSunFade,
      nUserMoonFade = SkyStudioDataStore.nUserMoonFade,
      bUserOverrideSunTimeOfDay = SkyStudioDataStore.bUserOverrideSunTimeOfDay,
      bUserOverrideSunOrientation = SkyStudioDataStore.bUserOverrideSunOrientation,
      bUserOverrideSunColorAndIntensity = SkyStudioDataStore.bUserOverrideSunColorAndIntensity,
      bUserOverrideMoonOrientation = SkyStudioDataStore.bUserOverrideMoonOrientation,
      bUserOverrideMoonTimeOfDay = SkyStudioDataStore.bUserOverrideMoonTimeOfDay,
      bUserOverrideMoonColorAndIntensity = SkyStudioDataStore.bUserOverrideMoonColorAndIntensity,
      bUserOverrideDayNightTransition = SkyStudioDataStore.bUserOverrideDayNightTransition
    })
  end)
end

-- / Validate class methods and interfaces, the game needs
-- / to validate the Manager conform to the module requirements.
Mutators.VerifyManagerModule(SkyStudioUIManager)

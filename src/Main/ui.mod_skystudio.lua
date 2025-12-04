local global = _G
local api = global.api
local require = global.require
local module = global.module

local Object = require("Common.object")
local GamefaceUIWrapper = require("UI.GamefaceUIWrapper")
local trace = require("SkyStudioTrace")

--- @class SkyStudioUI
local SkyStudioUI = module(..., Object.subclass(GamefaceUIWrapper))
local ObjectNew = SkyStudioUI.new

SkyStudioUI.new = function(self, _fnOnReadyCallback)
  trace("SkyStudioUI.new()")
  
  local oNewSkyStudioUI = ObjectNew(SkyStudioUI)
  local tInitSettings = {
    sViewName = "SkyStudio",
    sViewAddress = "coui://UIGameface/skystudio.html",
    bStartEnabled = true,
    fnOnReadyCallback = _fnOnReadyCallback,
    nViewDepth = 0,
    nViewWidth = 1920,
    nViewHeight = 1080,
    bRegisterWrapper = true
  }
  oNewSkyStudioUI:Init(tInitSettings)
  return oNewSkyStudioUI
end

SkyStudioUI.Show = function(self, params)
  trace("SkyStudioUI.Show()")
  self:TriggerEventAtNextAdvance("Show", params)
end

SkyStudioUI.Hide = function(self)
  trace("SkyStudioUI.Hide()")
  self:TriggerEventAtNextAdvance("Hide")
end

-- Data store key names to map listeners for:
--
-- SkyStudioDataStore.bUseVanillaLighting,
-- SkyStudioDataStore.nUserSunAzimuth,
-- SkyStudioDataStore.nUserSunLatitudeOffset,
-- SkyStudioDataStore.nUserSunTimeOfDay,
-- SkyStudioDataStore.nUserSunColorR,
-- SkyStudioDataStore.nUserSunColorG,
-- SkyStudioDataStore.nUserSunColorB,
-- SkyStudioDataStore.nUserSunIntensity,
-- SkyStudioDataStore.bUserSunUseLinearColors,
-- SkyStudioDataStore.nUserMoonAzimuth,
-- SkyStudioDataStore.nUserMoonLatitudeOffset,
-- SkyStudioDataStore.nUserMoonPhase,
-- SkyStudioDataStore.nUserMoonColorR,
-- SkyStudioDataStore.nUserMoonColorG,
-- SkyStudioDataStore.nUserMoonColorB,
-- SkyStudioDataStore.nUserMoonIntensity,
-- SkyStudioDataStore.bUserMoonUseLinearColors,
-- SkyStudioDataStore.nUserDayNightTransition,
-- SkyStudioDataStore.nUserSunFade,
-- SkyStudioDataStore.nUserMoonFade,
-- SkyStudioDataStore.bUserOverrideSunTimeOfDay,
-- SkyStudioDataStore.bUserOverrideSunOrientation,
-- SkyStudioDataStore.bUserOverrideSunColorAndIntensity,
-- SkyStudioDataStore.bUserOverrideMoonOrientation,
-- SkyStudioDataStore.bUserOverrideMoonPhase,
-- SkyStudioDataStore.bUserOverrideMoonColorAndIntensity,
-- SkyStudioDataStore.bUserOverrideDayNightTransition

SkyStudioUI.SkyStudioChangedValue_bUseVanillaLighting = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUseVanillaLighting")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUseVanillaLighting", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunAzimuth = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunAzimuth")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunAzimuth", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunLatitudeOffset = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunLatitudeOffset")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunLatitudeOffset", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunTimeOfDay = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunTimeOfDay")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunTimeOfDay", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunColorR = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColorR")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColorR", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunColorG = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColorG")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColorG", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunColorB = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColorB")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColorB", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunIntensity = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserSunUseLinearColors = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserSunUseLinearColors")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserSunUseLinearColors", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonAzimuth = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonAzimuth")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonAzimuth", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonLatitudeOffset = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonLatitudeOffset")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonLatitudeOffset", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonPhase = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonPhase")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonPhase", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColorR = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColorR")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColorR", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColorG = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColorG")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColorG", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColorB = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColorB")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColorB", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonIntensity = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserMoonUseLinearColors = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserMoonUseLinearColors")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserMoonUseLinearColors", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserDayNightTransition = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserDayNightTransition")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserDayNightTransition", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunFade = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunFade", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonFade = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonFade", 1, _callback, _self)
end

-- New override bindings

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunTimeOfDay = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunTimeOfDay")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunTimeOfDay", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunOrientation = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunOrientation")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunOrientation", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunColorAndIntensity = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunColorAndIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunColorAndIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonOrientation = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonOrientation")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonOrientation", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonPhase = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonPhase")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonPhase", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideDayNightTransition = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideDayNightTransition")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideDayNightTransition", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunFade = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunFade", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonFade = function(self, _callback, _self)
  trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonFade", 1, _callback, _self)
end


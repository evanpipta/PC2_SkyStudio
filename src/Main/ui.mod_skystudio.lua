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
  -- trace("SkyStudioUI.new()")
  
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
  -- trace("SkyStudioUI.Show()")
  self:TriggerEventAtNextAdvance("Show", params)
end

SkyStudioUI.Hide = function(self)
  -- trace("SkyStudioUI.Hide()")
  self:TriggerEventAtNextAdvance("Hide")
end

SkyStudioUI.UpdatePresetList = function(self, presetList)
  -- trace("SkyStudioUI.Hide()")
  self:TriggerEventAtNextAdvance("UpdatePresetList", presetList)
end

SkyStudioUI.UpdateSettings = function(self, settings)
  self:TriggerEventAtNextAdvance("UpdateSettings", settings)
end

SkyStudioUI.SkyStudioChangedValue_bUseVanillaLighting = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUseVanillaLighting")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUseVanillaLighting", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunAzimuth = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunAzimuth")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunAzimuth", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunLatitudeOffset = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunLatitudeOffset")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunLatitudeOffset", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunTimeOfDay = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunTimeOfDay")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunTimeOfDay", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunColorR = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColorR")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColorR", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunColorG = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColorG")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColorG", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunColorB = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColorB")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColorB", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserSunUseLinearColors = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserSunUseLinearColors")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserSunUseLinearColors", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonAzimuth = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonAzimuth")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonAzimuth", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonLatitudeOffset = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonLatitudeOffset")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonLatitudeOffset", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonPhase = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonPhase")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonPhase", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColorR = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColorR")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColorR", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColorG = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColorG")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColorG", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColorB = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColorB")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColorB", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserMoonUseLinearColors = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserMoonUseLinearColors")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserMoonUseLinearColors", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserDayNightTransition = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserDayNightTransition")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserDayNightTransition", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunFade = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunFade", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonFade = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonFade", 1, _callback, _self)
end

-- New override bindings

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunTimeOfDay = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunTimeOfDay")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunTimeOfDay", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunOrientation = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunOrientation")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunOrientation", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunColorAndIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunColorAndIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunColorAndIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonOrientation = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonOrientation")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonOrientation", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonPhase = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonPhase")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonPhase", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideDayNightTransition = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideDayNightTransition")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideDayNightTransition", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunFade = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunFade", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonFade = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonFade")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonFade", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunGroundMultiplier = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunGroundMultiplier")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunGroundMultiplier", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonGroundMultiplier = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonGroundMultiplier")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonGroundMultiplier", 1, _callback, _self)
end

-- Atmosphere override bindings

SkyStudioUI.SkyStudioChangedValue_bUserOverrideAtmosphere = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideAtmosphere")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideAtmosphere", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunDisk = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideSunDisk")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideSunDisk", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonDisk = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideMoonDisk")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideMoonDisk", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserFogDensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserFogDensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserFogDensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserFogScaleHeight = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserFogScaleHeight")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserFogScaleHeight", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserHazeDensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserHazeDensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserHazeDensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserHazeScaleHeight = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserHazeScaleHeight")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserHazeScaleHeight", 1, _callback, _self)
end

-- Sun disk and scatter bindings

SkyStudioUI.SkyStudioChangedValue_nUserSunDiskSize = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunDiskSize")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunDiskSize", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunDiskIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunDiskIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunDiskIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSunScatterIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunScatterIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunScatterIntensity", 1, _callback, _self)
end

-- Moon disk and scatter bindings

SkyStudioUI.SkyStudioChangedValue_nUserMoonDiskSize = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonDiskSize")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonDiskSize", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonDiskIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonDiskIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonDiskIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonScatterIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonScatterIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonScatterIntensity", 1, _callback, _self)
end

-- Additional atmosphere bindings

SkyStudioUI.SkyStudioChangedValue_nUserIrradianceScatterIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserIrradianceScatterIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserIrradianceScatterIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSkyLightIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSkyLightIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSkyLightIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSkyScatterIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSkyScatterIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSkyScatterIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserSkyDensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSkyDensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSkyDensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserVolumetricScatterWeight = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserVolumetricScatterWeight")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserVolumetricScatterWeight", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserVolumetricDistanceStart = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserVolumetricDistanceStart")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserVolumetricDistanceStart", 1, _callback, _self)
end

-- Fog and Haze color bindings (receives 3 args: r, g, b as floats 0-1)
SkyStudioUI.SkyStudioChangedValue_nUserFogColor = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserFogColor")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserFogColor", 3, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserHazeColor = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserHazeColor")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserHazeColor", 3, _callback, _self)
end

-- Sun and Moon color bindings (receives 3 args: r, g, b as floats 0-1)
SkyStudioUI.SkyStudioChangedValue_nUserSunColor = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserSunColor")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserSunColor", 3, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserMoonColor = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserMoonColor")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserMoonColor", 3, _callback, _self)
end

-- Rendering tab: GI and HDR toggles
SkyStudioUI.SkyStudioChangedValue_bUserOverrideGI = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideGI")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideGI", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_bUserOverrideHDR = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideHDR")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideHDR", 1, _callback, _self)
end

-- Rendering tab: GI parameters
SkyStudioUI.SkyStudioChangedValue_nUserGISkyIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserGISkyIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserGISkyIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserGISunIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserGISunIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserGISunIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserGIBounceBoost = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserGIBounceBoost")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserGIBounceBoost", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserGIMultiBounceIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserGIMultiBounceIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserGIMultiBounceIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserGIEmissiveIntensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserGIEmissiveIntensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserGIEmissiveIntensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserGIAmbientOcclusionWeight = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserGIAmbientOcclusionWeight")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserGIAmbientOcclusionWeight", 1, _callback, _self)
end

-- Rendering tab: HDR parameters
SkyStudioUI.SkyStudioChangedValue_nUserHDRAdaptionTime = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserHDRAdaptionTime")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserHDRAdaptionTime", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserHDRAdaptionDarknessScale = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserHDRAdaptionDarknessScale")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserHDRAdaptionDarknessScale", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_ResetRendering = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_ResetRendering")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_ResetRendering", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_ResetSun = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_ResetSun")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_ResetSun", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_ResetMoon = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_ResetMoon")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_ResetMoon", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_ResetAll = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_ResetAll")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_ResetAll", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_ResetAtmosphere = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_ResetAtmosphere")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_ResetAtmosphere", 1, _callback, _self)
end

-- Clouds tab bindings

SkyStudioUI.SkyStudioChangedValue_bUserOverrideClouds = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_bUserOverrideClouds")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideClouds", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsDensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsDensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsDensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsScale = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsScale")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsScale", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsSpeed = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsSpeed")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsSpeed", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsAltitudeMin = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsAltitudeMin")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsAltitudeMin", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsAltitudeMax = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsAltitudeMax")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsAltitudeMax", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsCoverageMin = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsCoverageMin")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsCoverageMin", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsCoverageMax = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsCoverageMax")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsCoverageMax", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsHorizonDensity = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsHorizonDensity")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsHorizonDensity", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsHorizonCoverageMin = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsHorizonCoverageMin")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsHorizonCoverageMin", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserCloudsHorizonCoverageMax = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserCloudsHorizonCoverageMax")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserCloudsHorizonCoverageMax", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_ResetClouds = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_ResetClouds")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_ResetClouds", 1, _callback, _self)
end

-- Shadow bindings

SkyStudioUI.SkyStudioChangedValue_bUserOverrideShadows = function(self, _callback, _self)
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_bUserOverrideShadows", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_nUserShadowFilterSoftness = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_nUserShadowFilterSoftness")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_nUserShadowFilterSoftness", 1, _callback, _self)
end

SkyStudioUI.SkyStudioChangedValue_sCurrentPresetName = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudioChangedValue_sCurrentPresetName")
  return self:AddGlobalEnvironmentEventListener("SkyStudioChangedValue_sCurrentPresetName", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_Preset_Save = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_Preset_Save")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_Preset_Save", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_Preset_SaveAs = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_Preset_SaveAs")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_Preset_SaveAs", 1, _callback, _self)
end

-- SkyStudioUI.SkyStudio_Preset_Delete = function(self, _callback, _self)
--   -- trace("Adding Listener SkyStudioUI.SkyStudio_Preset_Delete")
--   return self:AddGlobalEnvironmentEventListener("SkyStudio_Preset_Delete", 1, _callback, _self)
-- end

SkyStudioUI.SkyStudio_Preset_Load = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_Preset_Load")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_Preset_Load", 1, _callback, _self)
end

SkyStudioUI.SkyStudio_Preset_RefreshList = function(self, _callback, _self)
  -- trace("Adding Listener SkyStudioUI.SkyStudio_Preset_RefreshList")
  return self:AddGlobalEnvironmentEventListener("SkyStudio_Preset_RefreshList", 0, _callback, _self)
end


local global = _G
local api = global.api
local debug = api.debug
local pairs = global.pairs
local require = global.require
local module = global.module
local coroutine = global.coroutine
local Object = require("Common.object")
local Mutators = require("Environment.ModuleMutators")
local type = global.type
local tostring = global.tostring
local tonumber = global.tonumber
local math = global.math
local trace = require("SkyStudioTrace")

local Vector3 = require("Vector3")

local SkyStudioDataStore = require("SkyStudioDataStore")

-- Helper function to convert RGB floats (0-1) to integer color (0xRRGGBB)
local function rgbFloatsToInt(r, g, b)
  local ri = math.floor(r * 255 + 0.5)
  local gi = math.floor(g * 255 + 0.5)
  local bi = math.floor(b * 255 + 0.5)
  return ri * 65536 + gi * 256 + bi
end

---@class SkyStudioUIManager
local SkyStudioUIManager = module(..., Mutators.Manager())

local SkyStudioUI = require("UI.Mod_SkyStudio")

function SkyStudioUIManager:Init(_tProperties, _tEnvironment)
  trace("SkyStudioUIManager:Init()")
  -- Store environment reference for later use
  self.tEnvironment = _tEnvironment
end

-- Activate is called after all managers are initialized, safe to access world APIs here
function SkyStudioUIManager:Activate()
  trace("SkyStudioUIManager:Activate()")
  
  -- Cache world APIs during Activate - this is safe and will be used by UI callbacks
  self.tWorldAPIs = api.world.GetWorldAPIs()
  if self.tWorldAPIs then
    trace("Cached tWorldAPIs successfully")
  else
    trace("WARNING: Could not cache tWorldAPIs")
  end

  SkyStudioDataStore:LoadBlueprints()
  
  -- Set callback to update UI when save completes
  SkyStudioDataStore.fnOnSaveComplete = function()
    trace("CALLBACK: fnOnSaveComplete called")
    trace("CALLBACK: About to call UpdatePresetListUI...")
    self:UpdatePresetListUI()
    trace("CALLBACK: UpdatePresetListUI completed")
  end

  SkyStudioDataStore.fnOnDeleteComplete = function()
    trace("CALLBACK: fnOnDeleteComplete called")
    trace("CALLBACK: About to call UpdatePresetListUI...")
    self:UpdatePresetListUI()
    trace("CALLBACK: UpdatePresetListUI completed")
  end

  self.ui = SkyStudioUI:new(function()
    trace("SkyStudioUIManager:SkyStudioUI is ready")
  
    self.ui:SkyStudioChangedValue_bUseVanillaLighting(function(_, value)
      -- trace("SkyStudioChangedValue_bUseVanillaLighting: " .. tostring(value))
      SkyStudioDataStore.bUseVanillaLighting = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunAzimuth(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunAzimuth: " .. tostring(value))
      SkyStudioDataStore.nUserSunAzimuth = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunLatitudeOffset(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunLatitudeOffset: " .. tostring(value))
      SkyStudioDataStore.nUserSunLatitudeOffset = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunTimeOfDay(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunTimeOfDay: " .. tostring(value))
      SkyStudioDataStore.nUserSunTimeOfDay = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunColorR(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunColorR: " .. tostring(value))
      SkyStudioDataStore.nUserSunColorR = value
    end, self) 

    self.ui:SkyStudioChangedValue_nUserSunColorG(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunColorG: " .. tostring(value))
      SkyStudioDataStore.nUserSunColorG = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunColorB(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunColorB: " .. tostring(value))
      SkyStudioDataStore.nUserSunColorB = value
    end, self)

    -- Combined sun color handler (receives r, g, b as floats 0-1)
    self.ui:SkyStudioChangedValue_nUserSunColor(function(_, r, g, b)
      -- trace("SkyStudioChangedValue_nUserSunColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.nUserSunColorR = r
      SkyStudioDataStore.nUserSunColorG = g
      SkyStudioDataStore.nUserSunColorB = b
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunIntensity: " .. tostring(value))
      SkyStudioDataStore.nUserSunIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunGroundMultiplier(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunGroundMultiplier: " .. tostring(value))
      SkyStudioDataStore.nUserSunGroundMultiplier = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserSunUseLinearColors(function(_, value)
      -- trace("SkyStudioChangedValue_bUserSunUseLinearColors: " .. tostring(value))
      SkyStudioDataStore.bUserSunUseLinearColors = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonAzimuth(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonAzimuth: " .. tostring(value))
      SkyStudioDataStore.nUserMoonAzimuth = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonLatitudeOffset(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonLatitudeOffset: " .. tostring(value))
      SkyStudioDataStore.nUserMoonLatitudeOffset = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonPhase(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonPhase: " .. tostring(value))
      SkyStudioDataStore.nUserMoonPhase = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonColorR(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonColorR: " .. tostring(value))
      SkyStudioDataStore.nUserMoonColorR = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonColorG(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonColorG: " .. tostring(value))
      SkyStudioDataStore.nUserMoonColorG = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonColorB(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonColorB: " .. tostring(value))
      SkyStudioDataStore.nUserMoonColorB = value
    end, self)

    -- Combined moon color handler (receives r, g, b as floats 0-1)
    self.ui:SkyStudioChangedValue_nUserMoonColor(function(_, r, g, b)
      -- trace("SkyStudioChangedValue_nUserMoonColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.nUserMoonColorR = r
      SkyStudioDataStore.nUserMoonColorG = g
      SkyStudioDataStore.nUserMoonColorB = b
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonIntensity: " .. tostring(value))
      SkyStudioDataStore.nUserMoonIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonGroundMultiplier(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonGroundMultiplier: " .. tostring(value))
      SkyStudioDataStore.nUserMoonGroundMultiplier = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserMoonUseLinearColors(function(_, value)
      -- trace("SkyStudioChangedValue_bUserMoonUseLinearColors: " .. tostring(value))
      SkyStudioDataStore.bUserMoonUseLinearColors = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserDayNightTransition(function(_, value)
      -- trace("SkyStudioChangedValue_nUserDayNightTransition: " .. tostring(value))
      SkyStudioDataStore.nUserDayNightTransition = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunFade(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunFade: " .. tostring(value))
      SkyStudioDataStore.nUserSunFade = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonFade(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonFade: " .. tostring(value))
      SkyStudioDataStore.nUserMoonFade = value
    end, self)

    -- New override bindings

    self.ui:SkyStudioChangedValue_bUserOverrideSunTimeOfDay(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideSunTimeOfDay: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunTimeOfDay = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunOrientation(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideSunOrientation: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunOrientation = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunColorAndIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideSunColorAndIntensity: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunColorAndIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonOrientation(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideMoonOrientation: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonOrientation = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonPhase(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideMoonPhase: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonPhase = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonColorAndIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideDayNightTransition(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideDayNightTransition: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideDayNightTransition = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunFade(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideSunFade: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunFade = value
    end, self)
    
    self.ui:SkyStudioChangedValue_bUserOverrideMoonFade(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideMoonFade: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonFade = value
    end, self)

    -- Atmosphere override bindings
    self.ui:SkyStudioChangedValue_bUserOverrideAtmosphere(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideAtmosphere: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideAtmosphere = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunDisk(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideSunDisk: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunDisk = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonDisk(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideMoonDisk: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonDisk = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserFogDensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserFogDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserFogScaleHeight(function(_, value)
      -- trace("SkyStudioChangedValue_nUserFogScaleHeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.ScaleHeight = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserHazeDensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserHazeDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserHazeScaleHeight(function(_, value)
      -- trace("SkyStudioChangedValue_nUserHazeScaleHeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.ScaleHeight = value
    end, self)

    -- Sun disk and scatter bindings
    self.ui:SkyStudioChangedValue_nUserSunDiskSize(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunDiskSize: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Size = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunDiskIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunDiskIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunScatterIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSunScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Scatter.Intensity = value
    end, self)

    -- Moon disk and scatter bindings
    self.ui:SkyStudioChangedValue_nUserMoonDiskSize(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonDiskSize: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Size = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonDiskIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonDiskIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonScatterIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserMoonScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Scatter.Intensity = value
    end, self)

    -- Additional atmosphere bindings
    self.ui:SkyStudioChangedValue_nUserIrradianceScatterIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserIrradianceScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.IrradianceScatterIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSkyLightIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSkyLightIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSkyScatterIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSkyScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Scatter.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSkyDensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserSkyDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Sky.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserVolumetricScatterWeight(function(_, value)
      -- trace("SkyStudioChangedValue_nUserVolumetricScatterWeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Scatter.Weight = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserVolumetricDistanceStart(function(_, value)
      -- trace("SkyStudioChangedValue_nUserVolumetricDistanceStart: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Distance.Start = value
    end, self)

    -- Fog and Haze color bindings (receive r, g, b as floats 0-1)
    self.ui:SkyStudioChangedValue_nUserFogColor(function(_, r, g, b)
      -- trace("SkyStudioChangedValue_nUserFogColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Albedo.value = {r, g, b}
    end, self)

    self.ui:SkyStudioChangedValue_nUserHazeColor(function(_, r, g, b)
      -- trace("SkyStudioChangedValue_nUserHazeColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Albedo.value = {r, g, b}
    end, self)

    -- Rendering tab: GI and HDR toggles
    self.ui:SkyStudioChangedValue_bUserOverrideGI(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideGI: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideGI = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideHDR(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideHDR: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideHDR = value
    end, self)

    -- Rendering tab: GI parameters
    self.ui:SkyStudioChangedValue_nUserGISkyIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserGISkyIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SkyIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGISunIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserGISunIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SunIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIBounceBoost(function(_, value)
      -- trace("SkyStudioChangedValue_nUserGIBounceBoost: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.BounceBoost = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIMultiBounceIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserGIMultiBounceIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.MultiBounceIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIEmissiveIntensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserGIEmissiveIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.EmissiveIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIAmbientOcclusionWeight(function(_, value)
      -- trace("SkyStudioChangedValue_nUserGIAmbientOcclusionWeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.AmbientOcclusionWeight = value
    end, self)

    -- Rendering tab: HDR parameters
    self.ui:SkyStudioChangedValue_nUserHDRAdaptionTime(function(_, value)
      -- trace("SkyStudioChangedValue_nUserHDRAdaptionTime: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionTime = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserHDRAdaptionDarknessScale(function(_, value)
      -- trace("SkyStudioChangedValue_nUserHDRAdaptionDarknessScale: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionDarknessScale = value
    end, self)

    self.ui:SkyStudio_ResetRendering(function()
      trace("SkyStudioUIManager:SkyStudio_ResetRendering()")
      SkyStudioDataStore:ResetRenderingToDefaults()
    end, self)

    self.ui:SkyStudio_ResetSun(function()
      trace("SkyStudioUIManager:SkyStudio_ResetSun()")
      SkyStudioDataStore:ResetSunToDefaults()
    end, self)

    self.ui:SkyStudio_ResetMoon(function()
      trace("SkyStudioUIManager:SkyStudio_ResetMoon()")
      SkyStudioDataStore:ResetMoonToDefaults()
    end, self)

    self.ui:SkyStudio_ResetAll(function()
      trace("SkyStudioUIManager:SkyStudio_ResetAll()")
      SkyStudioDataStore:ResetAllToDefaults()
    end, self)

    self.ui:SkyStudio_ResetAtmosphere(function()
      trace("SkyStudioUIManager:SkyStudio_ResetAtmosphere()")
      SkyStudioDataStore:ResetAtmosphereToDefaults()
    end, self)

    -- Clouds tab: override toggle
    self.ui:SkyStudioChangedValue_bUserOverrideClouds(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideClouds: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideClouds = value
    end, self)

    -- Clouds tab: parameters
    self.ui:SkyStudioChangedValue_nUserCloudsDensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsScale(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsScale: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Scale = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsSpeed(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsSpeed: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Speed = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsAltitudeMin(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsAltitudeMin: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMin = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsAltitudeMax(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsAltitudeMax: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMax = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsCoverageMin(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsCoverageMin: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMin = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsCoverageMax(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsCoverageMax: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMax = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsHorizonDensity(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsHorizonDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsHorizonCoverageMin(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsHorizonCoverageMin: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMin = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsHorizonCoverageMax(function(_, value)
      -- trace("SkyStudioChangedValue_nUserCloudsHorizonCoverageMax: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMax = value
    end, self)

    self.ui:SkyStudio_ResetClouds(function()
      trace("SkyStudioUIManager:SkyStudio_ResetClouds()")
      SkyStudioDataStore:ResetCloudsToDefaults()
    end, self)

    -- Shadow parameters
    self.ui:SkyStudioChangedValue_bUserOverrideShadows(function(_, value)
      -- trace("SkyStudioChangedValue_bUserOverrideShadows: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideShadows = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserShadowFilterSoftness(function(_, value)
      -- trace("SkyStudioChangedValue_nUserShadowFilterSoftness: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Shadows.Collect.FilterSoftness = value
    end, self)

    self.ui:SkyStudioChangedValue_sCurrentPresetName(function(_, value)
      -- trace("SkyStudioChangedValue_sCurrentPresetName: " .. tostring(value))
      SkyStudioDataStore.sCurrentPresetName = value
    end, self)

    self.ui:SkyStudio_Preset_Save(function()
      trace('SkyStudio_Preset_Save called')
      
      -- Use cached tWorldAPIs from Activate() - calling GetWorldAPIs() in UI callbacks crashes
      local tWorldAPIs = self.tWorldAPIs
      if not tWorldAPIs then
        trace("Cannot save: tWorldAPIs not cached (manager not activated?)")
        return false
      end
      trace('Step 1: Using cached tWorldAPIs')
      
      -- Get UniqueNameComponent
      local UniqueNameComponent = tWorldAPIs.UniqueNameComponent
      if not UniqueNameComponent then
        trace("Cannot save: UniqueNameComponent not available")
        return false
      end
      trace('Step 2: UniqueNameComponent exists')
      
      -- Get editor entity ID
      local editorEntityID = UniqueNameComponent:GetEntityID("EditorModesHelper")
      if not editorEntityID then
        trace("Cannot save: Not in editor mode (no EditorModesHelper entity)")
        return false
      end
      trace('Step 3: editorEntityID = ' .. tostring(editorEntityID))
      
      -- Get GameModeHelperComponent
      local gameModeHelperComponent = tWorldAPIs.GameModeHelperComponent
      if not gameModeHelperComponent then
        trace("Cannot save: GameModeHelperComponent not available")
        return false
      end
      trace('Step 4: gameModeHelperComponent exists')
      
      -- Get current edit mode
      local editMode = gameModeHelperComponent:GetCurrentMode(editorEntityID)
      if not editMode then
        trace("Cannot save: No edit mode active")
        return false
      end
      trace('Step 5: editMode obtained')
      
      local selection = nil
      
      -- Get sceneryAPI and placementAPI for creating BuildingPartSet
      local sceneryAPI = tWorldAPIs.scenery
      local placementAPI = tWorldAPIs.placement
      
      -- APPROACH 1: Try selectAndEditComponent (single selection mode)
      local selectAndEditComponent = editMode.selectAndEditComponent
      if selectAndEditComponent and selectAndEditComponent.tSelectedEntity then
        trace('Step 6a: selectAndEditComponent available (single select mode)')
        local tSelectedEntity = selectAndEditComponent.tSelectedEntity
        
        -- Debug: show tSelectedEntity keys
        trace('Step 6b: tSelectedEntity keys:')
        for k, v in pairs(tSelectedEntity) do
          trace('  - ' .. tostring(k) .. ' = ' .. tostring(v))
        end
        
        -- Try to create a BuildingPartSet from the selected entity
        if sceneryAPI and sceneryAPI.CreateBuildingPartSet then
          selection = sceneryAPI:CreateBuildingPartSet()
          trace('Step 6c: Created BuildingPartSet via sceneryAPI')
          
          -- Try adding by partID first (preferred)
          if tSelectedEntity.partID then
            selection:Add(tSelectedEntity.partID)
            trace('Step 6d: Added partID ' .. tostring(tSelectedEntity.partID))
          -- Try adding by buildingGroupID
          elseif tSelectedEntity.buildingGroupID then
            selection:Add(tSelectedEntity.buildingGroupID)
            trace('Step 6d: Added buildingGroupID ' .. tostring(tSelectedEntity.buildingGroupID))
          -- Try converting entityID to placementID
          elseif tSelectedEntity.entityID and placementAPI and placementAPI.EntityIDToPlacementID then
            local partID = placementAPI:EntityIDToPlacementID(tSelectedEntity.entityID)
            if partID then
              selection:Add(partID)
              trace('Step 6d: Converted entityID to partID ' .. tostring(partID) .. ' and added')
            else
              trace('Step 6d: Could not convert entityID to partID')
            end
          else
            trace('Step 6d: No valid ID found to add to BuildingPartSet')
          end
        else
          trace('Step 6c: sceneryAPI.CreateBuildingPartSet not available')
        end
      end
      
      -- APPROACH 2: Try multiSelectHelper (multi-select mode)
      if (not selection or selection:CountParts() == 0) and editMode.multiSelectHelper then
        trace('Step 6a: multiSelectHelper available (multi-select mode)')
        local multiSelectHelper = editMode.multiSelectHelper
        
        -- Debug: show multiSelectHelper keys
        trace('Step 6b: multiSelectHelper keys:')
        for k, v in pairs(multiSelectHelper) do
          trace('  - ' .. tostring(k) .. ' (' .. type(v) .. ')')
        end
        
        -- Try to get selection from multiSelectHelper
        if multiSelectHelper.GetSelectionSet then
          selection = multiSelectHelper:GetSelectionSet()
          trace('Step 6c: Got selection from multiSelectHelper:GetSelectionSet()')
        elseif multiSelectHelper.selection then
          selection = multiSelectHelper.selection
          trace('Step 6c: Got selection from multiSelectHelper.selection')
        elseif multiSelectHelper.partSet then
          selection = multiSelectHelper.partSet
          trace('Step 6c: Got selection from multiSelectHelper.partSet')
        elseif multiSelectHelper.tSelectedParts then
          -- If it's a list of parts, create a BuildingPartSet
          trace('Step 6c: Found tSelectedParts, creating BuildingPartSet')
          if sceneryAPI and sceneryAPI.CreateBuildingPartSet then
            selection = sceneryAPI:CreateBuildingPartSet()
            for _, partID in pairs(multiSelectHelper.tSelectedParts) do
              selection:Add(partID)
            end
          end
        end
      end
      
      -- APPROACH 3: Try GetEditorContext
      if (not selection or (selection.CountParts and selection:CountParts() == 0)) and editMode.GetEditorContext then
        trace('Step 6a: Trying GetEditorContext')
        local editorContext = editMode:GetEditorContext()
        if editorContext and editorContext.GetSelectionSet then
          selection = editorContext:GetSelectionSet()
          trace('Step 6b: Got selection from editorContext:GetSelectionSet()')
        end
      end
      
      -- If still no selection, show debug info
      if not selection then
        trace('Step 6: Could not find selection. editMode keys:')
        for k, v in pairs(editMode) do
          trace('  - ' .. tostring(k) .. ' (' .. type(v) .. ')')
        end
        trace("Cannot save: Could not get selection from any source")
        return false
      end
      
      trace('Step 7: selection obtained, type: ' .. type(selection))
      
      -- Check selection has parts
      if not selection.CountParts then
        trace("Cannot save: selection doesn't have CountParts method")
        return false
      end
      
      local nPartCount = selection:CountParts()
      trace('Step 8: nPartCount = ' .. tostring(nPartCount))
      
      if nPartCount == 0 then
        trace("No selection found, using auto-place save flow")
        self:StartAutoPlaceSave()
        return
      end
      
      -- TODO: Re-enable once oncomplete reliability is fixed
      -- Check if already saving
      -- if SkyStudioDataStore.bIsSavingPreset then
      --   trace('Already saving a preset, please wait...')
      --   return false
      -- end
      
      -- All checks passed, safe to save
      trace('All checks passed, calling SaveSettingsAsBlueprintWithSaveToken')
      SkyStudioDataStore:SaveSettingsAsBlueprintWithSaveToken(selection, tWorldAPIs)
    end, self)



    self.ui:SkyStudio_Preset_Load(function(_, nBlueprintIndex)
      trace("SkyStudioUIManager:SkyStudio_Preset_Load(" .. tostring(nBlueprintIndex) .. ")")

      -- Load settings from the blueprint at the given index
      if SkyStudioDataStore:LoadSettingsFromBlueprintByIndex(nBlueprintIndex) then
        trace("Loaded preset successfully, updating UI")
        -- Send updated settings to UI
        self:SendCurrentSettingsToUI()
      else
        trace("Failed to load preset from index: " .. tostring(nBlueprintIndex))
      end
    end, self)

    -- Manual refresh list handler
    self.ui:SkyStudio_Preset_RefreshList(function()
      trace("SkyStudioUIManager:SkyStudio_Preset_RefreshList called")
      
      -- Reload blueprints from disk
      SkyStudioDataStore:LoadBlueprints()
      trace("Blueprints reloaded, count: " .. tostring(#SkyStudioDataStore.tSkyStudioBlueprintSaves))
      
      -- Update the UI
      self:UpdatePresetListUI()
      trace("Preset list UI updated")
    end, self)

    -- Save As handler - IDENTICAL to Save handler, just clears the token first
    self.ui:SkyStudio_Preset_SaveAs(function()
      trace('SkyStudio_Preset_SaveAs called')
      
      -- Use cached tWorldAPIs from Activate() - calling GetWorldAPIs() in UI callbacks crashes
      local tWorldAPIs = self.tWorldAPIs
      if not tWorldAPIs then
        trace("Cannot save: tWorldAPIs not cached (manager not activated?)")
        return false
      end
      
      -- Clear the loaded blueprint token so SaveAs creates a NEW blueprint instead of overwriting
      SkyStudioDataStore.cLoadedBlueprintSaveToken = nil
      trace("Cleared cLoadedBlueprintSaveToken for Save As (will create new blueprint)")
      
      -- Get UniqueNameComponent
      local UniqueNameComponent = tWorldAPIs.UniqueNameComponent
      if not UniqueNameComponent then
        trace("Cannot save: UniqueNameComponent not available")
        return false
      end
      
      -- Get editor entity ID
      local editorEntityID = UniqueNameComponent:GetEntityID("EditorModesHelper")
      if not editorEntityID then
        trace("Cannot save: Not in editor mode (no EditorModesHelper entity)")
        return false
      end
      
      -- Get GameModeHelperComponent
      local gameModeHelperComponent = tWorldAPIs.GameModeHelperComponent
      if not gameModeHelperComponent then
        trace("Cannot save: GameModeHelperComponent not available")
        return false
      end
      
      -- Get current edit mode
      local editMode = gameModeHelperComponent:GetCurrentMode(editorEntityID)
      if not editMode then
        trace("Cannot save: No edit mode active")
        return false
      end
      
      local selection = nil
      
      -- Get sceneryAPI and placementAPI for creating BuildingPartSet
      local sceneryAPI = tWorldAPIs.scenery
      local placementAPI = tWorldAPIs.placement
      
      -- APPROACH 1: Try selectAndEditComponent (single selection mode)
      local selectAndEditComponent = editMode.selectAndEditComponent
      if selectAndEditComponent and selectAndEditComponent.tSelectedEntity then
        local tSelectedEntity = selectAndEditComponent.tSelectedEntity
        
        -- Try to create a BuildingPartSet from the selected entity
        if sceneryAPI and sceneryAPI.CreateBuildingPartSet then
          selection = sceneryAPI:CreateBuildingPartSet()
          
          -- Try adding by partID first (preferred)
          if tSelectedEntity.partID then
            selection:Add(tSelectedEntity.partID)
          -- Try adding by buildingGroupID
          elseif tSelectedEntity.buildingGroupID then
            selection:Add(tSelectedEntity.buildingGroupID)
          -- Try converting entityID to placementID
          elseif tSelectedEntity.entityID and placementAPI and placementAPI.EntityIDToPlacementID then
            local partID = placementAPI:EntityIDToPlacementID(tSelectedEntity.entityID)
            if partID then
              selection:Add(partID)
            end
          end
        end
      end
      
      -- APPROACH 2: Try multiSelectHelper (multi-select mode)
      if (not selection or selection:CountParts() == 0) and editMode.multiSelectHelper then
        local multiSelectHelper = editMode.multiSelectHelper
        
        -- Try to get selection from multiSelectHelper
        if multiSelectHelper.GetSelectionSet then
          selection = multiSelectHelper:GetSelectionSet()
        elseif multiSelectHelper.selection then
          selection = multiSelectHelper.selection
        elseif multiSelectHelper.partSet then
          selection = multiSelectHelper.partSet
        elseif multiSelectHelper.tSelectedParts then
          -- If it's a list of parts, create a BuildingPartSet
          if sceneryAPI and sceneryAPI.CreateBuildingPartSet then
            selection = sceneryAPI:CreateBuildingPartSet()
            for _, partID in pairs(multiSelectHelper.tSelectedParts) do
              selection:Add(partID)
            end
          end
        end
      end
      
      -- APPROACH 3: Try GetEditorContext
      if (not selection or (selection.CountParts and selection:CountParts() == 0)) and editMode.GetEditorContext then
        local editorContext = editMode:GetEditorContext()
        if editorContext and editorContext.GetSelectionSet then
          selection = editorContext:GetSelectionSet()
        end
      end
      
      -- If still no selection, show debug info
      if not selection then
        trace('Could not find selection. editMode keys:')
        for k, v in pairs(editMode) do
          trace('  - ' .. tostring(k) .. ' (' .. type(v) .. ')')
        end
        trace("Cannot save: Could not get selection from any source")
        return false
      end
      
      -- Check selection has parts
      if not selection.CountParts then
        trace("Cannot save: selection doesn't have CountParts method")
        return false
      end
      
      local nPartCount = selection:CountParts()
      if nPartCount == 0 then
        trace("No selection found, using auto-place save flow")
        self:StartAutoPlaceSave()
        return
      end
      
      -- All checks passed, safe to save with existing selection
      trace('All checks passed (SaveAs), calling SaveSettingsAsBlueprintWithSaveToken')
      SkyStudioDataStore:SaveSettingsAsBlueprintWithSaveToken(selection, tWorldAPIs)
    end, self)

    self.ui:SkyStudio_Preset_Delete(function(_, nBlueprintIndex)
      trace("SkyStudioUIManager:SkyStudio_Preset_Delete(" .. tostring(nBlueprintIndex) .. ")")
      SkyStudioDataStore:DeleteSettingsBlueprintByIndex(nBlueprintIndex)
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
      nUserSunColor = rgbFloatsToInt(
        SkyStudioDataStore.nUserSunColorR,
        SkyStudioDataStore.nUserSunColorG,
        SkyStudioDataStore.nUserSunColorB
      ),
      nUserSunIntensity = SkyStudioDataStore.nUserSunIntensity,
      bUserSunUseLinearColors = SkyStudioDataStore.bUserSunUseLinearColors,
      nUserMoonAzimuth = SkyStudioDataStore.nUserMoonAzimuth,
      nUserMoonLatitudeOffset = SkyStudioDataStore.nUserMoonLatitudeOffset,
      nUserMoonPhase = SkyStudioDataStore.nUserMoonPhase,
      nUserMoonColorR = SkyStudioDataStore.nUserMoonColorR,
      nUserMoonColorG = SkyStudioDataStore.nUserMoonColorG,
      nUserMoonColorB = SkyStudioDataStore.nUserMoonColorB,
      nUserMoonColor = rgbFloatsToInt(
        SkyStudioDataStore.nUserMoonColorR,
        SkyStudioDataStore.nUserMoonColorG,
        SkyStudioDataStore.nUserMoonColorB
      ),
      nUserMoonIntensity = SkyStudioDataStore.nUserMoonIntensity,
      bUserMoonUseLinearColors = SkyStudioDataStore.bUserMoonUseLinearColors,
      nUserDayNightTransition = SkyStudioDataStore.nUserDayNightTransition,
      nUserSunFade = SkyStudioDataStore.nUserSunFade,
      nUserMoonFade = SkyStudioDataStore.nUserMoonFade,
      bUserOverrideSunTimeOfDay = SkyStudioDataStore.bUserOverrideSunTimeOfDay,
      bUserOverrideSunOrientation = SkyStudioDataStore.bUserOverrideSunOrientation,
      bUserOverrideSunColorAndIntensity = SkyStudioDataStore.bUserOverrideSunColorAndIntensity,
      bUserOverrideMoonOrientation = SkyStudioDataStore.bUserOverrideMoonOrientation,
      bUserOverrideMoonPhase = SkyStudioDataStore.bUserOverrideMoonPhase,
      bUserOverrideMoonColorAndIntensity = SkyStudioDataStore.bUserOverrideMoonColorAndIntensity,
      bUserOverrideDayNightTransition = SkyStudioDataStore.bUserOverrideDayNightTransition,
      -- Atmosphere parameters
      bUserOverrideAtmosphere = SkyStudioDataStore.bUserOverrideAtmosphere,
      bUserOverrideSunDisk = SkyStudioDataStore.bUserOverrideSunDisk,
      bUserOverrideMoonDisk = SkyStudioDataStore.bUserOverrideMoonDisk,
      nUserFogDensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Density,
      nUserFogScaleHeight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.ScaleHeight,
      nUserHazeDensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Density,
      nUserHazeScaleHeight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.ScaleHeight,
      -- Sun/Moon disk and scatter parameters
      nUserSunDiskSize = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Size,
      nUserSunDiskIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Intensity,
      nUserSunScatterIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Scatter.Intensity,
      nUserMoonDiskSize = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Size,
      nUserMoonDiskIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Intensity,
      nUserMoonScatterIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Scatter.Intensity,
      -- Additional atmosphere parameters
      nUserIrradianceScatterIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.IrradianceScatterIntensity,
      nUserSkyLightIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Intensity,
      nUserSkyScatterIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Scatter.Intensity,
      nUserSkyDensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Sky.Density,
      nUserVolumetricScatterWeight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Scatter.Weight,
      nUserVolumetricDistanceStart = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Distance.Start,
      -- Fog and Haze colors (as integer for color picker)
      nUserFogColor = rgbFloatsToInt(
        SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Albedo.value[1],
        SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Albedo.value[2],
        SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Albedo.value[3]
      ),
      nUserHazeColor = rgbFloatsToInt(
        SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Albedo.value[1],
        SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Albedo.value[2],
        SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Albedo.value[3]
      ),
      -- Rendering tab: toggles
      bUserOverrideGI = SkyStudioDataStore.bUserOverrideGI,
      bUserOverrideHDR = SkyStudioDataStore.bUserOverrideHDR,
      -- Rendering tab: GI parameters
      nUserGISkyIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SkyIntensity,
      nUserGISunIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SunIntensity,
      nUserGIBounceBoost = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.BounceBoost,
      nUserGIMultiBounceIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.MultiBounceIntensity,
      nUserGIEmissiveIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.EmissiveIntensity,
      nUserGIAmbientOcclusionWeight = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.AmbientOcclusionWeight,
      -- Rendering tab: HDR parameters
      nUserHDRAdaptionTime = SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionTime,
      nUserHDRAdaptionDarknessScale = SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionDarknessScale,
      -- Shadow parameters
      bUserOverrideShadows = SkyStudioDataStore.bUserOverrideShadows,
      nUserShadowFilterSoftness = SkyStudioDataStore.tUserRenderParameters.Shadows.Collect.FilterSoftness,
      -- Clouds tab: toggle
      bUserOverrideClouds = SkyStudioDataStore.bUserOverrideClouds,
      -- Clouds tab: parameters
      nUserCloudsDensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Density,
      nUserCloudsScale = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Scale,
      nUserCloudsSpeed = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Speed,
      nUserCloudsAltitudeMin = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMin,
      nUserCloudsAltitudeMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMax,
      nUserCloudsCoverageMin = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMin,
      nUserCloudsCoverageMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMax,
      nUserCloudsHorizonDensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.Density,
      nUserCloudsHorizonCoverageMin = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMin,
      nUserCloudsHorizonCoverageMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMax,

      sCurrentPresetName = SkyStudioDataStore.sCurrentPresetName
    })

    -- Send the preset list to the UI (key = blueprint index, value = preset name)
    self:UpdatePresetListUI()
  end)
end

-- Helper to build and send the preset list to UI
function SkyStudioUIManager:UpdatePresetListUI()
  trace("UpdatePresetListUI: START")
  local tPresetTable = {}
  trace("UpdatePresetListUI: Building preset table...")
  for i, v in pairs(SkyStudioDataStore.tSkyStudioBlueprintSaves) do
    tPresetTable[i] = v.sPresetName
  end
  trace("UpdatePresetListUI: Built table with " .. tostring(#SkyStudioDataStore.tSkyStudioBlueprintSaves) .. " presets")
  trace("UpdatePresetListUI: About to call self.ui:UpdatePresetList()...")
  self.ui:UpdatePresetList(tPresetTable)
  trace("UpdatePresetListUI: About to call self.ui:UpdateCurrentPreset()...")
  self.ui:UpdateCurrentPreset({ sCurrentPresetName = SkyStudioDataStore.sCurrentPresetName })
  trace("UpdatePresetListUI: DONE")
end

-- Helper to send current settings to UI (after loading a preset)
function SkyStudioUIManager:SendCurrentSettingsToUI()
  trace("SendCurrentSettingsToUI called")
  
  -- Get render params with safe access
  local rp = SkyStudioDataStore.tUserRenderParameters or {}
  local atm = rp.Atmospherics or {}
  local fog = atm.Fog or {}
  local haze = atm.Haze or {}
  local sun = atm.Sun or {}
  local moon = atm.Moon or {}
  local irr = atm.Irradiance or {}
  local sky = atm.Sky or {}
  local vol = atm.Volumetric or {}
  local clouds = atm.Clouds or {}
  local horizon = clouds.Horizon or {}
  local gi = rp.GI or {}
  local hdr = rp.HDR or {}
  local shadows = rp.Shadows or {}
  
  local tSettings = {
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
    nUserMoonPhase = SkyStudioDataStore.nUserMoonPhase,
    nUserMoonColorR = SkyStudioDataStore.nUserMoonColorR,
    nUserMoonColorG = SkyStudioDataStore.nUserMoonColorG,
    nUserMoonColorB = SkyStudioDataStore.nUserMoonColorB,
    nUserMoonIntensity = SkyStudioDataStore.nUserMoonIntensity,
    bUserMoonUseLinearColors = SkyStudioDataStore.bUserMoonUseLinearColors,
    nUserSunGroundMultiplier = SkyStudioDataStore.nUserSunGroundMultiplier,
    nUserMoonGroundMultiplier = SkyStudioDataStore.nUserMoonGroundMultiplier,
    nUserDayNightTransition = SkyStudioDataStore.nUserDayNightTransition,
    nUserSunFade = SkyStudioDataStore.nUserSunFade,
    nUserMoonFade = SkyStudioDataStore.nUserMoonFade,
    bUserOverrideSunTimeOfDay = SkyStudioDataStore.bUserOverrideSunTimeOfDay,
    bUserOverrideSunOrientation = SkyStudioDataStore.bUserOverrideSunOrientation,
    bUserOverrideSunColorAndIntensity = SkyStudioDataStore.bUserOverrideSunColorAndIntensity,
    bUserOverrideMoonOrientation = SkyStudioDataStore.bUserOverrideMoonOrientation,
    bUserOverrideMoonPhase = SkyStudioDataStore.bUserOverrideMoonPhase,
    bUserOverrideMoonColorAndIntensity = SkyStudioDataStore.bUserOverrideMoonColorAndIntensity,
    bUserOverrideSunFade = SkyStudioDataStore.bUserOverrideSunFade,
    bUserOverrideMoonFade = SkyStudioDataStore.bUserOverrideMoonFade,
    bUserOverrideDayNightTransition = SkyStudioDataStore.bUserOverrideDayNightTransition,
    bUserOverrideAtmosphere = SkyStudioDataStore.bUserOverrideAtmosphere,
    bUserOverrideSunDisk = SkyStudioDataStore.bUserOverrideSunDisk,
    bUserOverrideMoonDisk = SkyStudioDataStore.bUserOverrideMoonDisk,
    bUserOverrideGI = SkyStudioDataStore.bUserOverrideGI,
    bUserOverrideHDR = SkyStudioDataStore.bUserOverrideHDR,
    bUserOverrideShadows = SkyStudioDataStore.bUserOverrideShadows,
    bUserOverrideClouds = SkyStudioDataStore.bUserOverrideClouds,
    nUserFogDensity = fog.Density,
    nUserFogScaleHeight = fog.ScaleHeight,
    nUserHazeDensity = haze.Density,
    nUserHazeScaleHeight = haze.ScaleHeight,
    nUserSunDiskSize = sun.DiskSize,
    nUserSunDiskIntensity = sun.DiskIntensity,
    nUserSunScatterIntensity = sun.ScatterIntensity,
    nUserMoonDiskSize = moon.DiskSize,
    nUserMoonDiskIntensity = moon.DiskIntensity,
    nUserMoonScatterIntensity = moon.ScatterIntensity,
    nUserIrradianceScatterIntensity = irr.ScatterIntensity,
    nUserSkyLightIntensity = sky.LightIntensity,
    nUserSkyScatterIntensity = sky.ScatterIntensity,
    nUserSkyDensity = sky.Density,
    nUserVolumetricScatterWeight = vol.ScatterWeight,
    nUserVolumetricDistanceStart = vol.DistanceStart,
    nUserGISkyIntensity = gi.SkyIntensity,
    nUserGISunIntensity = gi.SunIntensity,
    nUserGIBounceBoost = gi.BounceBoost,
    nUserGIMultiBounceIntensity = gi.MultiBounceIntensity,
    nUserGIEmissiveIntensity = gi.EmissiveIntensity,
    nUserGIAmbientOcclusionWeight = gi.AmbientOcclusionWeight,
    nUserHDRAdaptionTime = hdr.AdaptionTime,
    nUserHDRAdaptionDarknessScale = hdr.AdaptionDarknessScale,
    nUserShadowFilterSoftness = shadows.FilterSoftness,
    nUserCloudsDensity = clouds.Density,
    nUserCloudsScale = clouds.Scale,
    nUserCloudsSpeed = clouds.Speed,
    nUserCloudsAltitudeMin = clouds.AltitudeMin,
    nUserCloudsAltitudeMax = clouds.AltitudeMax,
    nUserCloudsCoverageMin = clouds.CoverageMin,
    nUserCloudsCoverageMax = clouds.CoverageMax,
    nUserCloudsHorizonDensity = horizon.Density,
    nUserCloudsHorizonCoverageMin = horizon.CoverageMin,
    nUserCloudsHorizonCoverageMax = horizon.CoverageMax,
    sCurrentPresetName = SkyStudioDataStore.sCurrentPresetName
  }
  
  -- Add color values if the color tables exist
  if fog.Color then
    tSettings.nUserFogColor = rgbFloatsToInt(fog.Color.R or 0, fog.Color.G or 0, fog.Color.B or 0)
  end
  if haze.Color then
    tSettings.nUserHazeColor = rgbFloatsToInt(haze.Color.R or 0, haze.Color.G or 0, haze.Color.B or 0)
  end
  if sun.Color then
    tSettings.nUserSunColor = rgbFloatsToInt(sun.Color.R or 0, sun.Color.G or 0, sun.Color.B or 0)
  end
  if moon.Color then
    tSettings.nUserMoonColor = rgbFloatsToInt(moon.Color.R or 0, moon.Color.G or 0, moon.Color.B or 0)
  end
  
  trace("Calling UpdateSettings with settings table")
  self.ui:UpdateSettings(tSettings)
  trace("UpdateSettings completed")
end

-- Auto-placement state
SkyStudioUIManager.fnAutoPlaceCoroutine = nil
SkyStudioUIManager.bAutoPlaceInProgress = false
SkyStudioUIManager.nAutoPlacedPartID = nil

-- Auto-place a primitive sphere at world origin, run save, then undo
-- This allows saving without requiring user selection
function SkyStudioUIManager:StartAutoPlaceSave()
  trace("StartAutoPlaceSave: Beginning auto-place save flow")
  
  if self.bAutoPlaceInProgress then
    trace("StartAutoPlaceSave: Already in progress, ignoring")
    return false
  end
  
  local tWorldAPIs = self.tWorldAPIs
  if not tWorldAPIs then
    trace("StartAutoPlaceSave: tWorldAPIs not available")
    return false
  end
  
  local editorsAPI = tWorldAPIs.editors
  local sceneryAPI = tWorldAPIs.scenery
  
  if not editorsAPI then
    trace("StartAutoPlaceSave: editorsAPI not available")
    return false
  end
  
  if not sceneryAPI then
    trace("StartAutoPlaceSave: sceneryAPI not available")
    return false
  end
  
  self.bAutoPlaceInProgress = true
  self.nAutoPlacedPartID = nil
  
  -- Create the coroutine for the auto-placement flow
  self.fnAutoPlaceCoroutine = coroutine.create(function()
    trace("AutoPlace coroutine: Starting")
    
    -- Step 1: Create undo operations hierarchy
    trace("AutoPlace: Creating UndoOperationsHierarchy")
    local clh = editorsAPI:CreateUndoOperationsHierarchy()
    if not clh then
      trace("AutoPlace: Failed to create UndoOperationsHierarchy")
      self.bAutoPlaceInProgress = false
      return
    end
    
    -- Step 2: Create a primitive sphere part
    trace("AutoPlace: Creating primitive sphere part")
    local completionToken = api.entity.CreateRequestCompletionToken()
    local createObject = clh:CreateNewPart("PC_Primitive_Sphere", completionToken)
    
    if not createObject then
      trace("AutoPlace: Failed to create part object")
      self.bAutoPlaceInProgress = false
      return
    end
    
    -- Step 3: Wait for entity creation to complete
    trace("AutoPlace: Waiting for entity creation")
    while not api.entity.HaveRequestsCompleted(completionToken) do
      coroutine.yield()
    end
    trace("AutoPlace: Entity creation completed")
    
    -- Step 4: Start editing the part
    trace("AutoPlace: Starting to edit part")
    local moveObject = clh:StartEditingPart_Scenery(createObject)
    if not moveObject then
      trace("AutoPlace: Failed to start editing part")
      self.bAutoPlaceInProgress = false
      return
    end
    
    -- Step 5: Position at world origin (0,0,0)
    trace("AutoPlace: Positioning at origin")
    moveObject:SetPosition(Vector3:new(0, 0, 0))
    
    -- Step 6: Start preview
    trace("AutoPlace: Starting preview")
    local changelist = clh:GetFullUndoChangeList()
    local previewBusyToken, previewToken = api.undo.PreviewChangeList(changelist)
    
    -- Wait for preview to be ready
    trace("AutoPlace: Waiting for preview to be ready")
    while not api.undo.IsOperationComplete(previewBusyToken) do
      coroutine.yield()
    end
    trace("AutoPlace: Preview ready")
    
    -- Step 7: Check if we can commit
    trace("AutoPlace: Checking if can commit")
    local bCanCommit = api.undo.CanCommitPreview(previewToken)
    while bCanCommit == nil do
      coroutine.yield()
      bCanCommit = api.undo.CanCommitPreview(previewToken)
    end
    
    if not bCanCommit then
      trace("AutoPlace: Cannot commit preview, canceling")
      api.undo.CancelPreview(previewToken)
      self.bAutoPlaceInProgress = false
      return
    end
    
    -- Step 8: Commit the preview
    trace("AutoPlace: Committing preview")
    local commitToken = api.undo.CommitPreview(previewToken)
    while not api.undo.IsOperationComplete(commitToken) do
      coroutine.yield()
    end
    trace("AutoPlace: Commit completed")
    
    -- Step 9: Checkpoint
    api.undo.Checkpoint({})
    trace("AutoPlace: Checkpoint created")
    
    -- Step 10: Find a scenery part via raycast at origin
    -- We placed a sphere at (0,0,0), so raycast from above to find it (or any nearby scenery)
    trace("AutoPlace: Using raycast to find scenery at origin")
    local selection = sceneryAPI:CreateBuildingPartSet()
    local placementAPI = tWorldAPIs.placement
    local partID = nil
    
    -- Raycast from above origin downward to find the placed sphere (or any scenery there)
    local vRayStart = Vector3:new(0, 2, 0)
    local vRayDir = Vector3:new(0, -1, 0)
    
    if api.spatial and api.spatial.RayQuery and api.spatial.Flag_Scenery then
      trace("AutoPlace: Performing spatial raycast from (0,10,0) downward")
      local tHits = api.spatial.RayQuery(vRayStart, vRayDir, api.spatial.Flag_Scenery)
      if tHits then
        for _, nEntityID in pairs(tHits) do
          trace("AutoPlace: Raycast hit entityID: " .. tostring(nEntityID))
          if placementAPI and placementAPI.EntityIDToPlacementID then
            partID = placementAPI:EntityIDToPlacementID(nEntityID)
            if partID then
              trace("AutoPlace: Converted to partID: " .. tostring(partID))
              selection:Add(partID)
              self.nAutoPlacedPartID = partID
              break
            end
          end
        end
      else
        trace("AutoPlace: Raycast returned no hits (tHits is nil)")
      end
      
      -- If no hits going down, try from different angles
      if selection:CountParts() == 0 then
        trace("AutoPlace: No hits from above, trying horizontal raycast")
        vRayStart = Vector3:new(10, 0.5, 0)
        vRayDir = Vector3:new(-1, 0, 0)
        tHits = api.spatial.RayQuery(vRayStart, vRayDir, api.spatial.Flag_Scenery)
        if tHits then
          for _, nEntityID in pairs(tHits) do
            trace("AutoPlace: Horizontal raycast hit entityID: " .. tostring(nEntityID))
            if placementAPI and placementAPI.EntityIDToPlacementID then
              partID = placementAPI:EntityIDToPlacementID(nEntityID)
              if partID then
                trace("AutoPlace: Converted to partID: " .. tostring(partID))
                selection:Add(partID)
                self.nAutoPlacedPartID = partID
                break
              end
            end
          end
        end
      end
    else
      trace("AutoPlace: api.spatial.RayQuery not available, trying api.physics")
      -- Fallback: try physics raycast if spatial isn't available
      if api.physics and api.physics.Raycast then
        trace("AutoPlace: Trying api.physics.Raycast")
        -- Physics raycast may have different signature
      end
    end
    
    if selection:CountParts() == 0 then
      trace("AutoPlace: WARNING - Raycast found no scenery, selection is empty")
    end
    
    local nPartCount = selection:CountParts()
    trace("AutoPlace: Selection has " .. tostring(nPartCount) .. " parts")
    
    if nPartCount == 0 then
      trace("AutoPlace: Selection is empty, undoing and aborting")
      api.undo.Undo()
      self.bAutoPlaceInProgress = false
      return
    end
    
    -- Step 11: Clear the loaded blueprint token so we create a NEW blueprint
    SkyStudioDataStore.cLoadedBlueprintSaveToken = nil
    trace("AutoPlace: Cleared cLoadedBlueprintSaveToken for new blueprint")
    
    -- Step 12: Start the blueprint save with our selection
    trace("AutoPlace: Starting blueprint save")
    SkyStudioDataStore:SaveSettingsAsBlueprintWithSaveToken(selection, tWorldAPIs)
    
    -- Step 13: Wait for save to complete
    trace("AutoPlace: Waiting for save to complete")
    while SkyStudioDataStore.bIsSavingPreset or SkyStudioDataStore.fnSavePresetCoroutine do
      -- Advance the save coroutine
      SkyStudioDataStore:AdvanceSaveCoroutine()
      coroutine.yield()
    end
    trace("AutoPlace: Save completed")
    
    -- Step 14: Undo the placed sphere to clean up
    trace("AutoPlace: Undoing the auto-placed sphere")
    api.undo.Undo()
    
    -- Wait for undo to complete
    while api.undo.IsBusy() do
      coroutine.yield()
    end
    trace("AutoPlace: Undo completed")
    
    -- Done!
    self.bAutoPlaceInProgress = false
    self.nAutoPlacedPartID = nil
    trace("AutoPlace: Auto-place save flow completed successfully!")
  end)
  
  return true
end

-- Advance the auto-place coroutine
function SkyStudioUIManager:AdvanceAutoPlaceCoroutine()
  if not self.fnAutoPlaceCoroutine then
    return
  end
  
  local status = coroutine.status(self.fnAutoPlaceCoroutine)
  if status == "dead" then
    trace("AdvanceAutoPlaceCoroutine: Coroutine finished")
    self.fnAutoPlaceCoroutine = nil
    self.bAutoPlaceInProgress = false
    return
  end
  
  local success, errorMsg = coroutine.resume(self.fnAutoPlaceCoroutine)
  if not success then
    trace("AdvanceAutoPlaceCoroutine: Coroutine error: " .. tostring(errorMsg))
    self.fnAutoPlaceCoroutine = nil
    self.bAutoPlaceInProgress = false
  end
end

-- Advance is called every frame - use it to run the save coroutine
function SkyStudioUIManager:Advance(_dt)
  -- Advance the auto-place coroutine if running
  if self.bAutoPlaceInProgress or self.fnAutoPlaceCoroutine then
    self:AdvanceAutoPlaceCoroutine()
  end
  
  -- Advance the save coroutine if it's running (and not inside auto-place)
  if not self.bAutoPlaceInProgress then
    if SkyStudioDataStore.bIsSavingPreset or SkyStudioDataStore.fnSavePresetCoroutine then
      SkyStudioDataStore:AdvanceSaveCoroutine()
    end
  end
end

-- / Validate class methods and interfaces, the game needs
-- / to validate the Manager conform to the module requirements.
Mutators.VerifyManagerModule(SkyStudioUIManager)

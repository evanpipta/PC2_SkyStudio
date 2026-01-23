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

function SkyStudioUIManager:Init()
  trace("SkyStudioUIManager:Init()")

  SkyStudioDataStore:LoadBlueprints()

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

    -- Combined sun color handler (receives r, g, b as floats 0-1)
    self.ui:SkyStudioChangedValue_nUserSunColor(function(_, r, g, b)
      trace("SkyStudioChangedValue_nUserSunColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.nUserSunColorR = r
      SkyStudioDataStore.nUserSunColorG = g
      SkyStudioDataStore.nUserSunColorB = b
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSunIntensity: " .. tostring(value))
      SkyStudioDataStore.nUserSunIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunGroundMultiplier(function(_, value)
      trace("SkyStudioChangedValue_nUserSunGroundMultiplier: " .. tostring(value))
      SkyStudioDataStore.nUserSunGroundMultiplier = value
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

    self.ui:SkyStudioChangedValue_nUserMoonPhase(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonPhase: " .. tostring(value))
      SkyStudioDataStore.nUserMoonPhase = value
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

    -- Combined moon color handler (receives r, g, b as floats 0-1)
    self.ui:SkyStudioChangedValue_nUserMoonColor(function(_, r, g, b)
      trace("SkyStudioChangedValue_nUserMoonColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.nUserMoonColorR = r
      SkyStudioDataStore.nUserMoonColorG = g
      SkyStudioDataStore.nUserMoonColorB = b
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonIntensity: " .. tostring(value))
      SkyStudioDataStore.nUserMoonIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonGroundMultiplier(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonGroundMultiplier: " .. tostring(value))
      SkyStudioDataStore.nUserMoonGroundMultiplier = value
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

    self.ui:SkyStudioChangedValue_bUserOverrideMoonPhase(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonPhase: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonPhase = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonColorAndIntensity: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonColorAndIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideDayNightTransition(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideDayNightTransition: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideDayNightTransition = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunFade(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideSunFade: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunFade = value
    end, self)
    
    self.ui:SkyStudioChangedValue_bUserOverrideMoonFade(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonFade: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonFade = value
    end, self)

    -- Atmosphere override bindings
    self.ui:SkyStudioChangedValue_bUserOverrideAtmosphere(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideAtmosphere: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideAtmosphere = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideSunDisk(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideSunDisk: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideSunDisk = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideMoonDisk(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideMoonDisk: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideMoonDisk = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserFogDensity(function(_, value)
      trace("SkyStudioChangedValue_nUserFogDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserFogScaleHeight(function(_, value)
      trace("SkyStudioChangedValue_nUserFogScaleHeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.ScaleHeight = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserHazeDensity(function(_, value)
      trace("SkyStudioChangedValue_nUserHazeDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserHazeScaleHeight(function(_, value)
      trace("SkyStudioChangedValue_nUserHazeScaleHeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.ScaleHeight = value
    end, self)

    -- Sun disk and scatter bindings
    self.ui:SkyStudioChangedValue_nUserSunDiskSize(function(_, value)
      trace("SkyStudioChangedValue_nUserSunDiskSize: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Size = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunDiskIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSunDiskIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSunScatterIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSunScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Scatter.Intensity = value
    end, self)

    -- Moon disk and scatter bindings
    self.ui:SkyStudioChangedValue_nUserMoonDiskSize(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonDiskSize: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Size = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonDiskIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonDiskIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserMoonScatterIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserMoonScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Scatter.Intensity = value
    end, self)

    -- Additional atmosphere bindings
    self.ui:SkyStudioChangedValue_nUserIrradianceScatterIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserIrradianceScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.IrradianceScatterIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSkyLightIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSkyLightIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSkyScatterIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSkyScatterIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Scatter.Intensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserSkyDensity(function(_, value)
      trace("SkyStudioChangedValue_nUserSkyDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Sky.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserVolumetricScatterWeight(function(_, value)
      trace("SkyStudioChangedValue_nUserVolumetricScatterWeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Scatter.Weight = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserVolumetricDistanceStart(function(_, value)
      trace("SkyStudioChangedValue_nUserVolumetricDistanceStart: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Distance.Start = value
    end, self)

    -- Fog and Haze color bindings (receive r, g, b as floats 0-1)
    self.ui:SkyStudioChangedValue_nUserFogColor(function(_, r, g, b)
      trace("SkyStudioChangedValue_nUserFogColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Albedo.value = {r, g, b}
    end, self)

    self.ui:SkyStudioChangedValue_nUserHazeColor(function(_, r, g, b)
      trace("SkyStudioChangedValue_nUserHazeColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Albedo.value = {r, g, b}
    end, self)

    -- Rendering tab: GI and HDR toggles
    self.ui:SkyStudioChangedValue_bUserOverrideGI(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideGI: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideGI = value
    end, self)

    self.ui:SkyStudioChangedValue_bUserOverrideHDR(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideHDR: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideHDR = value
    end, self)

    -- Rendering tab: GI parameters
    self.ui:SkyStudioChangedValue_nUserGISkyIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserGISkyIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SkyIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGISunIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserGISunIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SunIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIBounceBoost(function(_, value)
      trace("SkyStudioChangedValue_nUserGIBounceBoost: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.BounceBoost = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIMultiBounceIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserGIMultiBounceIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.MultiBounceIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIEmissiveIntensity(function(_, value)
      trace("SkyStudioChangedValue_nUserGIEmissiveIntensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.EmissiveIntensity = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserGIAmbientOcclusionWeight(function(_, value)
      trace("SkyStudioChangedValue_nUserGIAmbientOcclusionWeight: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.AmbientOcclusionWeight = value
    end, self)

    -- Rendering tab: HDR parameters
    self.ui:SkyStudioChangedValue_nUserHDRAdaptionTime(function(_, value)
      trace("SkyStudioChangedValue_nUserHDRAdaptionTime: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionTime = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserHDRAdaptionDarknessScale(function(_, value)
      trace("SkyStudioChangedValue_nUserHDRAdaptionDarknessScale: " .. tostring(value))
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
      trace("SkyStudioChangedValue_bUserOverrideClouds: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideClouds = value
    end, self)

    -- Clouds tab: parameters
    self.ui:SkyStudioChangedValue_nUserCloudsDensity(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsScale(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsScale: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Scale = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsSpeed(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsSpeed: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Speed = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsAltitudeMin(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsAltitudeMin: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMin = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsAltitudeMax(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsAltitudeMax: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMax = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsCoverageMin(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsCoverageMin: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMin = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsCoverageMax(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsCoverageMax: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMax = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsHorizonDensity(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsHorizonDensity: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.Density = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsHorizonCoverageMin(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsHorizonCoverageMin: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMin = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserCloudsHorizonCoverageMax(function(_, value)
      trace("SkyStudioChangedValue_nUserCloudsHorizonCoverageMax: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMax = value
    end, self)

    self.ui:SkyStudio_ResetClouds(function()
      trace("SkyStudioUIManager:SkyStudio_ResetClouds()")
      SkyStudioDataStore:ResetCloudsToDefaults()
    end, self)

    -- Shadow parameters
    self.ui:SkyStudioChangedValue_bUserOverrideShadows(function(_, value)
      trace("SkyStudioChangedValue_bUserOverrideShadows: " .. tostring(value))
      SkyStudioDataStore.bUserOverrideShadows = value
    end, self)

    self.ui:SkyStudioChangedValue_nUserShadowFilterSoftness(function(_, value)
      trace("SkyStudioChangedValue_nUserShadowFilterSoftness: " .. tostring(value))
      SkyStudioDataStore.tUserRenderParameters.Shadows.Collect.FilterSoftness = value
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
      nUserCloudsHorizonCoverageMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMax
    })
  end)
end

-- / Validate class methods and interfaces, the game needs
-- / to validate the Manager conform to the module requirements.
Mutators.VerifyManagerModule(SkyStudioUIManager)

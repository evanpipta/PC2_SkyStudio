local global = _G
local api = global.api
local coroutine = global.coroutine
local math = global.math
local pairs = global.pairs
local tostring = global.tostring
local ipairs = global.ipairs
local type = global.type
local ParkLoadSaveManager = require("managers.parkloadsavemanager")

local trace = require('SkyStudioTrace')

----------------------------------------------------------------
-- Park Save Hook: Inject SkyStudio config into park metadata
-- This hooks GenerateCurrentParkMetaData so that whenever a park
-- is saved (manual or autosave), the SkyStudio config is included.
----------------------------------------------------------------

-- Store reference to original function before we replace it
local originalGenerateCurrentParkMetaData = ParkLoadSaveManager.GenerateCurrentParkMetaData

-- Forward declaration - will be set after SkyStudioDataStore is created
local fnGetSkyStudioConfigSnapshot = nil

-- Replace with hooked version that injects SkyStudio config
ParkLoadSaveManager.GenerateCurrentParkMetaData = function(self)
  trace('HOOK: GenerateCurrentParkMetaData called - injecting SkyStudio config')
  
  -- Call original function to get base metadata
  local tMetadata = originalGenerateCurrentParkMetaData(self)
  
  -- Inject SkyStudio config if we have the snapshot function
  if tMetadata and fnGetSkyStudioConfigSnapshot then
    local tSkyStudioConfig = fnGetSkyStudioConfigSnapshot()
    if tSkyStudioConfig then
      tMetadata.tSkyStudioConfig = tSkyStudioConfig
      trace('HOOK: Injected tSkyStudioConfig into park metadata')
    end
  end
  
  return tMetadata
end

trace('Park save hook installed on ParkLoadSaveManager.GenerateCurrentParkMetaData')

local BaseEditMode = require("Editors.Shared.BaseEditMode")

local SkyStudioDataStore = {}

-- Flag to prevent multiple concurrent saves
SkyStudioDataStore.bIsSavingPreset = false
-- Coroutine for async save operation
SkyStudioDataStore.fnSavePresetCoroutine = nil
-- Callback function to be called when save completes successfully (updates UI)
SkyStudioDataStore.fnOnSaveComplete = nil
SkyStudioDataStore.fnOnDeleteComplete = nil

-- Deep copy helper function for tables
local function deepCopy(original)
  if type(original) ~= "table" then
    return original
  end
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = deepCopy(value)
  end
  return copy
end

-- Helper to normalize color array keys from strings to numbers (fixes serialization issue)
local function normalizeColorArray(colorTable)
  if not colorTable or not colorTable.value then return end
  local v = colorTable.value
  -- Check if keys are strings and convert to numeric
  if v["1"] ~= nil or v["2"] ~= nil or v["3"] ~= nil then
    local normalized = {
      v["1"] or v[1],
      v["2"] or v[2],
      v["3"] or v[3]
    }
    colorTable.value = normalized
    trace('Normalized color array from string keys to numeric keys')
  end
end

SkyStudioDataStore.bUseVanillaLighting = false

SkyStudioDataStore.nParkTodCycleMoonColorR = 0.50                 -- vanilla default: 0.341
SkyStudioDataStore.nParkTodCycleMoonColorG = 0.69                 -- vanilla default: 0.588
SkyStudioDataStore.nParkTodCycleMoonColorB = 1                     -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleMoonIntensity = 0.65               -- vanilla default: 0.65
SkyStudioDataStore.nParkTodCycleMoonGroundMultiplier = 1

SkyStudioDataStore.nParkTodCycleSunColorR = 1                      -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleSunColorG = 1                      -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleSunColorB = 1                      -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleSunIntensity = 128                 -- vanilla default: 128
SkyStudioDataStore.nParkTodCycleSunGroundMultiplier = 2            -- vanilla default: 1

SkyStudioDataStore.nParkTodCycleDayNightTransitionMidnight = 40   -- midnight value
SkyStudioDataStore.nParkTodCycleDayNightTransitionDawn = 45       -- dawn value
SkyStudioDataStore.nParkTodCycleDayNightTransitionNoon = 100       -- noon value
SkyStudioDataStore.nParkTodCycleDayNightTransitionDusk = 45       -- dusk value

SkyStudioDataStore.nParkTodCycleDayNightTransitionCurve = 2

SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnEnd = 80
SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskStart = 100
SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskEnd = 190
SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnStart = 350

SkyStudioDataStore.nParkTodCycleTwilightLength = 30

SkyStudioDataStore.nParkTodCycleMoonPhase = 200

SkyStudioDataStore.nParkTodCycleSunDawnFadeStart = -0.5
SkyStudioDataStore.nParkTodCycleSunDawnFadeEnd = 2
SkyStudioDataStore.nParkTodCycleSunDuskFadeStart = 178
SkyStudioDataStore.nParkTodCycleSunDuskFadeEnd = 180.5

-- Same for the moon
-- The moon's "dusk" and "dawn" refer to moonrise and moonset here, not sunrise and sunset
SkyStudioDataStore.nParkTodCycleMoonDawnFadeStart = -0.5
SkyStudioDataStore.nParkTodCycleMoonDawnFadeEnd = 1
SkyStudioDataStore.nParkTodCycleMoonDuskFadeStart = 179
SkyStudioDataStore.nParkTodCycleMoonDuskFadeEnd = 180.5

-- Sun time of day
SkyStudioDataStore.bUserOverrideSunTimeOfDay = false     -- Override time of day, effectively the same as "fixed time of day" in vanilla
SkyStudioDataStore.nUserSunTimeOfDay = 9                 -- Time of day in hours (24 hour clock)

-- Sun orientation in the sky
SkyStudioDataStore.bUserOverrideSunOrientation = false
SkyStudioDataStore.nUserSunAzimuth = 0                   -- Sun "rotation" in degrees
SkyStudioDataStore.nUserSunLatitudeOffset = 17            -- Sun "tilt" in degrees

-- Sun color and intensity:
SkyStudioDataStore.bUserOverrideSunColorAndIntensity = false
SkyStudioDataStore.nUserSunColorR = 1                    -- vanilla defualt: 1
SkyStudioDataStore.nUserSunColorG = 1                    -- vanilla defualt: 1
SkyStudioDataStore.nUserSunColorB = 1                    -- vanilla defualt: 1
SkyStudioDataStore.nUserSunIntensity = 128               -- vanilla default: 128
SkyStudioDataStore.nUserSunGroundMultiplier = 1

-- Moon orientation in the sky:
SkyStudioDataStore.bUserOverrideMoonOrientation = false
SkyStudioDataStore.nUserMoonAzimuth = 0                  -- Moon "rotation" in degrees
SkyStudioDataStore.nUserMoonLatitudeOffset = 0           -- Moon "tilt" in degrees

-- Moon "time of day"
SkyStudioDataStore.bUserOverrideMoonPhase = false
SkyStudioDataStore.nUserMoonPhase = 200                  -- 200 = moon rise ~2hrs before sunset

-- Moon color and intensity:
SkyStudioDataStore.bUserOverrideMoonColorAndIntensity = false
SkyStudioDataStore.nUserMoonColorR = 0.341       -- vanilla default: 0.341
SkyStudioDataStore.nUserMoonColorG = 0.588       -- vanilla default: 0.588
SkyStudioDataStore.nUserMoonColorB = 1           -- vanilla defualt: 1
SkyStudioDataStore.nUserMoonIntensity = 0.65     -- vanilla default: 0.65
SkyStudioDataStore.nUserMoonGroundMultiplier = 2 -- vanilla default: 1

SkyStudioDataStore.bUserOverrideSunFade = false
SkyStudioDataStore.bUserOverrideMoonFade = false

SkyStudioDataStore.bUserOverrideDayNightTransition = false

SkyStudioDataStore.bUserOverrideAtmosphere = false
SkyStudioDataStore.bUserOverrideSunDisk = false
SkyStudioDataStore.bUserOverrideMoonDisk = false

-- Rendering tab overrides
SkyStudioDataStore.bUserOverrideGI = false
SkyStudioDataStore.bUserOverrideHDR = false

-- Clouds tab override
SkyStudioDataStore.bUserOverrideClouds = false

-- Shadows override
SkyStudioDataStore.bUserOverrideShadows = false

SkyStudioDataStore.nUserDayNightTransition = 90
SkyStudioDataStore.nUserSunFade = 1
SkyStudioDataStore.nUserMoonFade = 0
 
-- Override switches for:

-- Volumetric/Fog/Haze/Sky (atmosphere)
-- Clouds
-- Lights (sun/moon, maybe these are always enabled? Or connected to override sun and moon color)
-- Stars
-- Probe + RadiativeTransfer
-- Shadows
-- View-GlobalIllumination
-- View-Luminance
-- (Other view stuff separate)

SkyStudioDataStore.tUserRenderParameters = {
  -- DayNight = {
  --   DayFactor = 1.0
  -- },
  Atmospherics = {
    Volumetric = {
      Scatter = {
        Weight = 0.4
      },
      Distance = {
        Start = 0
      }
    },
    Fog = {
      Albedo = {
        type = "colour",
        value = {0.36470588235, 0.49411764706, 0.60392156863}
      },
      Density = 0.5,
      Altitude = 0,
      ScaleHeight = 500.0 
    },
    Haze = {
      Albedo = {
        type = "colour",
        value = {0.49019607843, 0.81960784314, 0.97647058824}
      },
      Density = 5,
      Altitude = 0,
      ScaleHeight = 1200.0
    },
    Sky = {
      -- Albedo = {
      --   type = "colour",
      --   value = {255, 0, 0, 255}
      -- },
      Density = 1,
      Altitude = 0,
      ScaleHeight = 7994.0
    },
    Clouds = {
      Density = 150.0,
      Scale = 1.24,
      Speed = 70.0,
      AltitudeMin = 1500.0,
      AltitudeMax = 2700.0,
      CoverageMin = 0.73,
      CoverageMax = 1.0,
      Horizon = {
        Density = 0.0,
        CoverageMin = 0.1,
        CoverageMax = 1.0
      }
    },
    Lights = {
      IrradianceScatterIntensity = 1.0,
      Sun  = {
        Disk = {
          Size = 1.5,
          Intensity = 1
        },
        Scatter = {
          Intensity = 2.2
        }
      },
      Moon = {
        Disk = {
          Size = 3,
          Intensity = 50,
        },
        Scatter = {
          Intensity = 1
        }
      },
      Sky = {
        Intensity = 1.0,
        Scatter = {
          Intensity = 1.0
        }
      }
    },
    -- Stars = {
    --   Strength = 1,
    --   Enabled = true,
    -- },
    RadiativeTransfer = {
      Curve = {
        Power = 1.0
      }
    },
    Probe = {
      RadianceScale = 1.0,
      RadianceSaturation = 1.0,
      RadianceOcclusionFactor = 0
    }
  },
  Shadows = {
    Collect = {
      FilterSoftness = 2.5
    }
  },
  View = {
    GlobalIllumination = {
      AmbientOcclusionWeight = 0.0,
      BounceBoost = 0.39,
      EmissiveIntensity = 1.0,
      MultiBounceIntensity = 1.0,
      SkyIntensity = 1.0,
      SunIntensity = 1.0,
    },
    LookAdjust = {
      Luminance = {
        AdaptionTime = 1.35,
        AdaptionDarknessScale = 0.9
      }
    }
  }
}

SkyStudioDataStore.defaultValues = {
  bUseVanillaLighting = SkyStudioDataStore.bUseVanillaLighting,
  nParkTodCycleMoonColorR = SkyStudioDataStore.nParkTodCycleMoonColorR,
  nParkTodCycleMoonColorG = SkyStudioDataStore.nParkTodCycleMoonColorG,
  nParkTodCycleMoonColorB = SkyStudioDataStore.nParkTodCycleMoonColorB,
  nParkTodCycleMoonIntensity = SkyStudioDataStore.nParkTodCycleMoonIntensity,
  nParkTodCycleMoonGroundMultiplier = SkyStudioDataStore.nParkTodCycleMoonGroundMultiplier,
  nParkTodCycleSunColorR = SkyStudioDataStore.nParkTodCycleSunColorR,
  nParkTodCycleSunColorG = SkyStudioDataStore.nParkTodCycleSunColorG,
  nParkTodCycleSunColorB = SkyStudioDataStore.nParkTodCycleSunColorB,
  nParkTodCycleSunIntensity = SkyStudioDataStore.nParkTodCycleSunIntensity,
  nParkTodCycleSunGroundMultiplier = SkyStudioDataStore.nParkTodCycleSunGroundMultiplier,
  nParkTodCycleDayNightTransitionMidnight = SkyStudioDataStore.nParkTodCycleDayNightTransitionMidnight,
  nParkTodCycleDayNightTransitionDawn = SkyStudioDataStore.nParkTodCycleDayNightTransitionDawn,
  nParkTodCycleDayNightTransitionNoon = SkyStudioDataStore.nParkTodCycleDayNightTransitionNoon,
  nParkTodCycleDayNightTransitionDusk = SkyStudioDataStore.nParkTodCycleDayNightTransitionDusk,
  nParkTodCycleDayNightTransitionCurve = SkyStudioDataStore.nParkTodCycleDayNightTransitionCurve,
  nParkTodCycleDayNightTransitionDawnEnd = SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnEnd,
  nParkTodCycleDayNightTransitionDuskStart = SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskStart,
  nParkTodCycleDayNightTransitionDuskEnd = SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskEnd,
  nParkTodCycleDayNightTransitionDawnStart = SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnStart,
  nParkTodCycleTwilightLength = SkyStudioDataStore.nParkTodCycleTwilightLength,
  nParkTodCycleMoonPhase = SkyStudioDataStore.nParkTodCycleMoonPhase,
  nParkTodCycleSunDawnFadeStart = SkyStudioDataStore.nParkTodCycleSunDawnFadeStart,
  nParkTodCycleSunDawnFadeEnd = SkyStudioDataStore.nParkTodCycleSunDawnFadeEnd,
  nParkTodCycleSunDuskFadeStart = SkyStudioDataStore.nParkTodCycleSunDuskFadeStart,
  nParkTodCycleSunDuskFadeEnd = SkyStudioDataStore.nParkTodCycleSunDuskFadeEnd,
  nParkTodCycleMoonDawnFadeStart = SkyStudioDataStore.nParkTodCycleMoonDawnFadeStart,
  nParkTodCycleMoonDawnFadeEnd = SkyStudioDataStore.nParkTodCycleMoonDawnFadeEnd,
  nParkTodCycleMoonDuskFadeStart = SkyStudioDataStore.nParkTodCycleMoonDuskFadeStart,
  nParkTodCycleMoonDuskFadeEnd = SkyStudioDataStore.nParkTodCycleMoonDuskFadeEnd,
  bUserOverrideSunTimeOfDay = SkyStudioDataStore.bUserOverrideSunTimeOfDay,
  nUserSunTimeOfDay = SkyStudioDataStore.nUserSunTimeOfDay,
  bUserOverrideSunOrientation = SkyStudioDataStore.bUserOverrideSunOrientation,
  nUserSunAzimuth = SkyStudioDataStore.nUserSunAzimuth,
  nUserSunLatitudeOffset = SkyStudioDataStore.nUserSunLatitudeOffset,
  bUserOverrideSunColorAndIntensity = SkyStudioDataStore.bUserOverrideSunColorAndIntensity,
  nUserSunColorR = SkyStudioDataStore.nUserSunColorR,
  nUserSunColorG = SkyStudioDataStore.nUserSunColorG,
  nUserSunColorB = SkyStudioDataStore.nUserSunColorB,
  nUserSunIntensity = SkyStudioDataStore.nUserSunIntensity,
  nUserSunGroundMultiplier = SkyStudioDataStore.nUserSunGroundMultiplier,
  bUserOverrideMoonOrientation = SkyStudioDataStore.bUserOverrideMoonOrientation,
  nUserMoonAzimuth = SkyStudioDataStore.nUserMoonAzimuth,
  nUserMoonLatitudeOffset = SkyStudioDataStore.nUserMoonLatitudeOffset,
  bUserOverrideMoonPhase = SkyStudioDataStore.bUserOverrideMoonPhase,
  nUserMoonPhase = SkyStudioDataStore.nUserMoonPhase,
  bUserOverrideMoonColorAndIntensity = SkyStudioDataStore.bUserOverrideMoonColorAndIntensity,
  nUserMoonColorR = SkyStudioDataStore.nUserMoonColorR,
  nUserMoonColorG = SkyStudioDataStore.nUserMoonColorG,
  nUserMoonColorB = SkyStudioDataStore.nUserMoonColorB,
  nUserMoonIntensity = SkyStudioDataStore.nUserMoonIntensity,
  nUserMoonGroundMultiplier = SkyStudioDataStore.nUserMoonGroundMultiplier,
  bUserOverrideSunFade = SkyStudioDataStore.bUserOverrideSunFade,
  bUserOverrideMoonFade = SkyStudioDataStore.bUserOverrideMoonFade,
  bUserOverrideDayNightTransition = SkyStudioDataStore.bUserOverrideDayNightTransition,
  nUserDayNightTransition = SkyStudioDataStore.nUserDayNightTransition,
  nUserSunFade = SkyStudioDataStore.nUserSunFade,
  nUserMoonFade = SkyStudioDataStore.nUserMoonFade,
  -- Deep copy to preserve original defaults when user modifies values
  tUserRenderParameters = deepCopy(SkyStudioDataStore.tUserRenderParameters),
}

function SkyStudioDataStore:SetDefaultValuesFromCurrentValues()
  SkyStudioDataStore.defaultValues.bUseVanillaLighting = SkyStudioDataStore.bUseVanillaLighting
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonColorR = SkyStudioDataStore.nParkTodCycleMoonColorR
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonColorG = SkyStudioDataStore.nParkTodCycleMoonColorG
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonColorB = SkyStudioDataStore.nParkTodCycleMoonColorB
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonIntensity = SkyStudioDataStore.nParkTodCycleMoonIntensity
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonGroundMultiplier = SkyStudioDataStore.nParkTodCycleMoonGroundMultiplier
  SkyStudioDataStore.defaultValues.nParkTodCycleSunColorR = SkyStudioDataStore.nParkTodCycleSunColorR
  SkyStudioDataStore.defaultValues.nParkTodCycleSunColorG = SkyStudioDataStore.nParkTodCycleSunColorG
  SkyStudioDataStore.defaultValues.nParkTodCycleSunColorB = SkyStudioDataStore.nParkTodCycleSunColorB
  SkyStudioDataStore.defaultValues.nParkTodCycleSunIntensity = SkyStudioDataStore.nParkTodCycleSunIntensity
  SkyStudioDataStore.defaultValues.nParkTodCycleSunGroundMultiplier = SkyStudioDataStore.nParkTodCycleSunGroundMultiplier
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionMidnight = SkyStudioDataStore.nParkTodCycleDayNightTransitionMidnight
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionDawn = SkyStudioDataStore.nParkTodCycleDayNightTransitionDawn
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionNoon = SkyStudioDataStore.nParkTodCycleDayNightTransitionNoon
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionDusk = SkyStudioDataStore.nParkTodCycleDayNightTransitionDusk
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionCurve = SkyStudioDataStore.nParkTodCycleDayNightTransitionCurve
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionDawnEnd = SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnEnd
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionDuskStart = SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskStart
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionDuskEnd = SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskEnd
  SkyStudioDataStore.defaultValues.nParkTodCycleDayNightTransitionDawnStart = SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnStart
  SkyStudioDataStore.defaultValues.nParkTodCycleTwilightLength = SkyStudioDataStore.nParkTodCycleTwilightLength
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonPhase = SkyStudioDataStore.nParkTodCycleMoonPhase
  SkyStudioDataStore.defaultValues.nParkTodCycleSunDawnFadeStart = SkyStudioDataStore.nParkTodCycleSunDawnFadeStart
  SkyStudioDataStore.defaultValues.nParkTodCycleSunDawnFadeEnd = SkyStudioDataStore.nParkTodCycleSunDawnFadeEnd
  SkyStudioDataStore.defaultValues.nParkTodCycleSunDuskFadeStart = SkyStudioDataStore.nParkTodCycleSunDuskFadeStart
  SkyStudioDataStore.defaultValues.nParkTodCycleSunDuskFadeEnd = SkyStudioDataStore.nParkTodCycleSunDuskFadeEnd
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonDawnFadeStart = SkyStudioDataStore.nParkTodCycleMoonDawnFadeStart
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonDawnFadeEnd = SkyStudioDataStore.nParkTodCycleMoonDawnFadeEnd
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonDuskFadeStart = SkyStudioDataStore.nParkTodCycleMoonDuskFadeStart
  SkyStudioDataStore.defaultValues.nParkTodCycleMoonDuskFadeEnd = SkyStudioDataStore.nParkTodCycleMoonDuskFadeEnd
  SkyStudioDataStore.defaultValues.bUserOverrideSunTimeOfDay = SkyStudioDataStore.bUserOverrideSunTimeOfDay
  SkyStudioDataStore.defaultValues.nUserSunTimeOfDay = SkyStudioDataStore.nUserSunTimeOfDay
  SkyStudioDataStore.defaultValues.bUserOverrideSunOrientation = SkyStudioDataStore.bUserOverrideSunOrientation
  SkyStudioDataStore.defaultValues.nUserSunAzimuth = SkyStudioDataStore.nUserSunAzimuth
  SkyStudioDataStore.defaultValues.nUserSunLatitudeOffset = SkyStudioDataStore.nUserSunLatitudeOffset
  SkyStudioDataStore.defaultValues.bUserOverrideSunColorAndIntensity = SkyStudioDataStore.bUserOverrideSunColorAndIntensity
  SkyStudioDataStore.defaultValues.nUserSunColorR = SkyStudioDataStore.nUserSunColorR
  SkyStudioDataStore.defaultValues.nUserSunColorG = SkyStudioDataStore.nUserSunColorG
  SkyStudioDataStore.defaultValues.nUserSunColorB = SkyStudioDataStore.nUserSunColorB
  SkyStudioDataStore.defaultValues.nUserSunIntensity = SkyStudioDataStore.nUserSunIntensity
  SkyStudioDataStore.defaultValues.nUserSunGroundMultiplier = SkyStudioDataStore.nUserSunGroundMultiplier
  SkyStudioDataStore.defaultValues.bUserOverrideMoonOrientation = SkyStudioDataStore.bUserOverrideMoonOrientation
  SkyStudioDataStore.defaultValues.nUserMoonAzimuth = SkyStudioDataStore.nUserMoonAzimuth
  SkyStudioDataStore.defaultValues.nUserMoonLatitudeOffset = SkyStudioDataStore.nUserMoonLatitudeOffset
  SkyStudioDataStore.defaultValues.bUserOverrideMoonPhase = SkyStudioDataStore.bUserOverrideMoonPhase
  SkyStudioDataStore.defaultValues.nUserMoonPhase = SkyStudioDataStore.nUserMoonPhase
  SkyStudioDataStore.defaultValues.bUserOverrideMoonColorAndIntensity = SkyStudioDataStore.bUserOverrideMoonColorAndIntensity
  SkyStudioDataStore.defaultValues.nUserMoonColorR = SkyStudioDataStore.nUserMoonColorR
  SkyStudioDataStore.defaultValues.nUserMoonColorG = SkyStudioDataStore.nUserMoonColorG
  SkyStudioDataStore.defaultValues.nUserMoonColorB = SkyStudioDataStore.nUserMoonColorB
  SkyStudioDataStore.defaultValues.nUserMoonIntensity = SkyStudioDataStore.nUserMoonIntensity
  SkyStudioDataStore.defaultValues.nUserMoonGroundMultiplier = SkyStudioDataStore.nUserMoonGroundMultiplier
  SkyStudioDataStore.defaultValues.bUserOverrideSunFade = SkyStudioDataStore.bUserOverrideSunFade
  SkyStudioDataStore.defaultValues.bUserOverrideMoonFade = SkyStudioDataStore.bUserOverrideMoonFade
  SkyStudioDataStore.defaultValues.bUserOverrideDayNightTransition = SkyStudioDataStore.bUserOverrideDayNightTransition
  SkyStudioDataStore.defaultValues.nUserDayNightTransition = SkyStudioDataStore.nUserDayNightTransition
  SkyStudioDataStore.defaultValues.nUserSunFade = SkyStudioDataStore.nUserSunFade
  SkyStudioDataStore.defaultValues.nUserMoonFade = SkyStudioDataStore.nUserMoonFade
end

-- Reset all user values from the sun color tab (including disk settings)
function SkyStudioDataStore:ResetSunToDefaults()
  SkyStudioDataStore.nUserSunColorR = SkyStudioDataStore.defaultValues.nUserSunColorR
  SkyStudioDataStore.nUserSunColorG = SkyStudioDataStore.defaultValues.nUserSunColorG
  SkyStudioDataStore.nUserSunColorB = SkyStudioDataStore.defaultValues.nUserSunColorB
  SkyStudioDataStore.nUserSunIntensity = SkyStudioDataStore.defaultValues.nUserSunIntensity
  SkyStudioDataStore.nUserSunGroundMultiplier = SkyStudioDataStore.defaultValues.nUserSunGroundMultiplier
  SkyStudioDataStore.nUserSunFade = SkyStudioDataStore.defaultValues.nUserSunFade
  -- Sun disk settings
  SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Size = SkyStudioDataStore.defaultValues.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Size
  SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Intensity = SkyStudioDataStore.defaultValues.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Intensity
end

-- Reset all user values from the moon color tab (including disk settings)
function SkyStudioDataStore:ResetMoonToDefaults()
  SkyStudioDataStore.nUserMoonColorR = SkyStudioDataStore.defaultValues.nUserMoonColorR
  SkyStudioDataStore.nUserMoonColorG = SkyStudioDataStore.defaultValues.nUserMoonColorG
  SkyStudioDataStore.nUserMoonColorB = SkyStudioDataStore.defaultValues.nUserMoonColorB
  SkyStudioDataStore.nUserMoonIntensity = SkyStudioDataStore.defaultValues.nUserMoonIntensity
  SkyStudioDataStore.nUserMoonGroundMultiplier = SkyStudioDataStore.defaultValues.nUserMoonGroundMultiplier
  SkyStudioDataStore.nUserMoonFade = SkyStudioDataStore.defaultValues.nUserMoonFade
  -- Moon disk settings
  SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Size = SkyStudioDataStore.defaultValues.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Size
  SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Intensity = SkyStudioDataStore.defaultValues.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Intensity
end

-- Reset all atmosphere render parameter values
function SkyStudioDataStore:ResetAtmosphereToDefaults()
  local defaults = SkyStudioDataStore.defaultValues.tUserRenderParameters.Atmospherics
  local current = SkyStudioDataStore.tUserRenderParameters.Atmospherics
  
  -- Fog
  current.Fog.Density = defaults.Fog.Density
  current.Fog.Altitude = defaults.Fog.Altitude
  current.Fog.ScaleHeight = defaults.Fog.ScaleHeight
  current.Fog.Albedo.value = {
    defaults.Fog.Albedo.value[1],
    defaults.Fog.Albedo.value[2],
    defaults.Fog.Albedo.value[3]
  }
  
  -- Haze
  current.Haze.Density = defaults.Haze.Density
  current.Haze.Altitude = defaults.Haze.Altitude
  current.Haze.ScaleHeight = defaults.Haze.ScaleHeight
  current.Haze.Albedo.value = {
    defaults.Haze.Albedo.value[1],
    defaults.Haze.Albedo.value[2],
    defaults.Haze.Albedo.value[3]
  }
  
  -- Sky
  current.Sky.Density = defaults.Sky.Density
  current.Sky.Altitude = defaults.Sky.Altitude
  current.Sky.ScaleHeight = defaults.Sky.ScaleHeight
  
  -- Volumetric
  current.Volumetric.Scatter.Weight = defaults.Volumetric.Scatter.Weight
  current.Volumetric.Distance.Start = defaults.Volumetric.Distance.Start
  
  -- Lights (scatter intensities)
  current.Lights.IrradianceScatterIntensity = defaults.Lights.IrradianceScatterIntensity
  current.Lights.Sun.Scatter.Intensity = defaults.Lights.Sun.Scatter.Intensity
  current.Lights.Moon.Scatter.Intensity = defaults.Lights.Moon.Scatter.Intensity
  current.Lights.Sky.Intensity = defaults.Lights.Sky.Intensity
  current.Lights.Sky.Scatter.Intensity = defaults.Lights.Sky.Scatter.Intensity
end

-- Reset all rendering (GI + HDR) values
function SkyStudioDataStore:ResetRenderingToDefaults()
  local defaults = SkyStudioDataStore.defaultValues.tUserRenderParameters.View
  local current = SkyStudioDataStore.tUserRenderParameters.View
  
  -- Global Illumination
  current.GlobalIllumination.SkyIntensity = defaults.GlobalIllumination.SkyIntensity
  current.GlobalIllumination.SunIntensity = defaults.GlobalIllumination.SunIntensity
  current.GlobalIllumination.BounceBoost = defaults.GlobalIllumination.BounceBoost
  current.GlobalIllumination.MultiBounceIntensity = defaults.GlobalIllumination.MultiBounceIntensity
  current.GlobalIllumination.EmissiveIntensity = defaults.GlobalIllumination.EmissiveIntensity
  current.GlobalIllumination.AmbientOcclusionWeight = defaults.GlobalIllumination.AmbientOcclusionWeight
  
  -- HDR / Luminance
  current.LookAdjust.Luminance.AdaptionTime = defaults.LookAdjust.Luminance.AdaptionTime
  current.LookAdjust.Luminance.AdaptionDarknessScale = defaults.LookAdjust.Luminance.AdaptionDarknessScale
end

-- Reset all cloud values
function SkyStudioDataStore:ResetCloudsToDefaults()
  local defaults = SkyStudioDataStore.defaultValues.tUserRenderParameters.Atmospherics.Clouds
  local current = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds
  
  current.Density = defaults.Density
  current.Scale = defaults.Scale
  current.Speed = defaults.Speed
  current.AltitudeMin = defaults.AltitudeMin
  current.AltitudeMax = defaults.AltitudeMax
  current.CoverageMin = defaults.CoverageMin
  current.CoverageMax = defaults.CoverageMax
  current.Horizon.Density = defaults.Horizon.Density
  current.Horizon.CoverageMin = defaults.Horizon.CoverageMin
  current.Horizon.CoverageMax = defaults.Horizon.CoverageMax
end

-- Reset all user settings (including turning off all overrides)
function SkyStudioDataStore:ResetAllToDefaults()
  -- Reset simple nUser* values
  for key, value in pairs(SkyStudioDataStore.defaultValues) do
    if string.sub(key, 1, 5) == "nUser" then
      SkyStudioDataStore[key] = value
    end
  end
  
  -- Turn off all bUserOverride* flags
  SkyStudioDataStore.bUserOverrideSunTimeOfDay = false
  SkyStudioDataStore.bUserOverrideSunOrientation = false
  SkyStudioDataStore.bUserOverrideSunColorAndIntensity = false
  SkyStudioDataStore.bUserOverrideMoonOrientation = false
  SkyStudioDataStore.bUserOverrideMoonPhase = false
  SkyStudioDataStore.bUserOverrideMoonColorAndIntensity = false
  SkyStudioDataStore.bUserOverrideSunFade = false
  SkyStudioDataStore.bUserOverrideMoonFade = false
  SkyStudioDataStore.bUserOverrideDayNightTransition = false
  SkyStudioDataStore.bUserOverrideAtmosphere = false
  SkyStudioDataStore.bUserOverrideSunDisk = false
  SkyStudioDataStore.bUserOverrideMoonDisk = false
  SkyStudioDataStore.bUserOverrideGI = false
  SkyStudioDataStore.bUserOverrideHDR = false
  SkyStudioDataStore.bUserOverrideClouds = false
  SkyStudioDataStore.bUserOverrideShadows = false
  
  -- Also reset the master switch to use vanilla lighting
  SkyStudioDataStore.bUseVanillaLighting = false
  
  -- Reset all render parameter sections
  SkyStudioDataStore:ResetSunToDefaults()
  SkyStudioDataStore:ResetMoonToDefaults()
  SkyStudioDataStore:ResetAtmosphereToDefaults()
  SkyStudioDataStore:ResetRenderingToDefaults()
  SkyStudioDataStore:ResetCloudsToDefaults()
end

-- Build a render parameters table containing only values for enabled overrides
-- This is called by the RenderParametersComponentManager before CreateParameterFromTable
function SkyStudioDataStore:GetActiveRenderParameters()
  local tActive = {}

  -- Atmosphere overrides (Fog, Haze, Sky, Volumetric, Lights)
  if SkyStudioDataStore.bUserOverrideAtmosphere then
    tActive.Atmospherics = tActive.Atmospherics or {}
    
    -- Fog
    tActive.Atmospherics.Fog = {
      Albedo = {
        type = "colour",
        value = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Albedo.value
      },
      Density = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Density,
      Altitude = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.Altitude,
      ScaleHeight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Fog.ScaleHeight
    }
    
    -- Haze
    tActive.Atmospherics.Haze = {
      Albedo = {
        type = "colour",
        value = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Albedo.value
      },
      Density = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Density,
      Altitude = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.Altitude,
      ScaleHeight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Haze.ScaleHeight
    }
    
    -- Sky
    tActive.Atmospherics.Sky = {
      Density = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Sky.Density,
      Altitude = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Sky.Altitude,
      ScaleHeight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Sky.ScaleHeight
    }
    
    -- Volumetric
    tActive.Atmospherics.Volumetric = {
      Scatter = {
        Weight = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Scatter.Weight
      },
      Distance = {
        Start = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Volumetric.Distance.Start
      }
    }
    
    -- Lights (scatter intensities and irradiance)
    tActive.Atmospherics.Lights = tActive.Atmospherics.Lights or {}
    tActive.Atmospherics.Lights.IrradianceScatterIntensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.IrradianceScatterIntensity
    
    tActive.Atmospherics.Lights.Sun = tActive.Atmospherics.Lights.Sun or {}
    tActive.Atmospherics.Lights.Sun.Scatter = {
      Intensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Scatter.Intensity
    }
    
    tActive.Atmospherics.Lights.Moon = tActive.Atmospherics.Lights.Moon or {}
    tActive.Atmospherics.Lights.Moon.Scatter = {
      Intensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Scatter.Intensity
    }
    
    tActive.Atmospherics.Lights.Sky = {
      Intensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Intensity,
      Scatter = {
        Intensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sky.Scatter.Intensity
      }
    }
  end

  -- Sun Disk overrides - ALWAYS include to reset to defaults when toggle is off
  local defaults = SkyStudioDataStore.defaultValues.tUserRenderParameters
  
  tActive.Atmospherics = tActive.Atmospherics or {}
  tActive.Atmospherics.Lights = tActive.Atmospherics.Lights or {}
  tActive.Atmospherics.Lights.Sun = tActive.Atmospherics.Lights.Sun or {}
  
  if SkyStudioDataStore.bUserOverrideSunDisk then
    tActive.Atmospherics.Lights.Sun.Disk = {
      Size = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Size,
      Intensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Sun.Disk.Intensity
    }
  else
    -- Use defaults when toggle is off
    tActive.Atmospherics.Lights.Sun.Disk = {
      Size = defaults.Atmospherics.Lights.Sun.Disk.Size,
      Intensity = defaults.Atmospherics.Lights.Sun.Disk.Intensity
    }
  end

  -- Moon Disk overrides - ALWAYS include to reset to defaults when toggle is off
  tActive.Atmospherics.Lights.Moon = tActive.Atmospherics.Lights.Moon or {}
  
  if SkyStudioDataStore.bUserOverrideMoonDisk then
    tActive.Atmospherics.Lights.Moon.Disk = {
      Size = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Size,
      Intensity = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Lights.Moon.Disk.Intensity
    }
  else
    -- Use defaults when toggle is off
    tActive.Atmospherics.Lights.Moon.Disk = {
      Size = defaults.Atmospherics.Lights.Moon.Disk.Size,
      Intensity = defaults.Atmospherics.Lights.Moon.Disk.Intensity
    }
  end

  -- Global Illumination overrides - ALWAYS include to reset to defaults when toggle is off
  tActive.View = tActive.View or {}
  
  if SkyStudioDataStore.bUserOverrideGI then
    tActive.View.GlobalIllumination = {
      SkyIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SkyIntensity,
      SunIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.SunIntensity,
      BounceBoost = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.BounceBoost,
      MultiBounceIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.MultiBounceIntensity,
      EmissiveIntensity = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.EmissiveIntensity,
      AmbientOcclusionWeight = SkyStudioDataStore.tUserRenderParameters.View.GlobalIllumination.AmbientOcclusionWeight
    }
  else
    -- Use defaults when toggle is off
    tActive.View.GlobalIllumination = {
      SkyIntensity = defaults.View.GlobalIllumination.SkyIntensity,
      SunIntensity = defaults.View.GlobalIllumination.SunIntensity,
      BounceBoost = defaults.View.GlobalIllumination.BounceBoost,
      MultiBounceIntensity = defaults.View.GlobalIllumination.MultiBounceIntensity,
      EmissiveIntensity = defaults.View.GlobalIllumination.EmissiveIntensity,
      AmbientOcclusionWeight = defaults.View.GlobalIllumination.AmbientOcclusionWeight
    }
  end

  -- HDR / Luminance overrides - ALWAYS include to reset to defaults when toggle is off
  tActive.View.LookAdjust = tActive.View.LookAdjust or {}
  
  if SkyStudioDataStore.bUserOverrideHDR then
    tActive.View.LookAdjust.Luminance = {
      AdaptionTime = SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionTime,
      AdaptionDarknessScale = SkyStudioDataStore.tUserRenderParameters.View.LookAdjust.Luminance.AdaptionDarknessScale
    }
  else
    -- Use defaults when toggle is off
    tActive.View.LookAdjust.Luminance = {
      AdaptionTime = defaults.View.LookAdjust.Luminance.AdaptionTime,
      AdaptionDarknessScale = defaults.View.LookAdjust.Luminance.AdaptionDarknessScale
    }
  end

  -- Shadows - only include when toggle is on
  if SkyStudioDataStore.bUserOverrideShadows then
    tActive.Shadows = {
      Collect = {
        FilterSoftness = SkyStudioDataStore.tUserRenderParameters.Shadows.Collect.FilterSoftness
      }
    }
  end

  -- Clouds overrides - ALWAYS include to reset to defaults when toggle is off
  tActive.Atmospherics = tActive.Atmospherics or {}
  
  if SkyStudioDataStore.bUserOverrideClouds then
    tActive.Atmospherics.Clouds = {
      Density = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Density,
      Scale = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Scale,
      Speed = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Speed,
      AltitudeMin = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMin,
      AltitudeMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.AltitudeMax,
      CoverageMin = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMin,
      CoverageMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.CoverageMax,
      Horizon = {
        Density = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.Density,
        CoverageMin = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMin,
        CoverageMax = SkyStudioDataStore.tUserRenderParameters.Atmospherics.Clouds.Horizon.CoverageMax
      }
    }
  end

  return tActive
end

----------------------------------------------------------------
-- SkyStudio Blueprint Presets (saved as blueprint metadata)
----------------------------------------------------------------

-- New datastore fields (put these near the top with the other SkyStudioDataStore.* fields)
SkyStudioDataStore.tSkyStudioBlueprintSaves = SkyStudioDataStore.tSkyStudioBlueprintSaves or {}  -- [{sPresetName=string, cSaveToken=cSaveToken}, ...]
SkyStudioDataStore.sCurrentPresetName = SkyStudioDataStore.sCurrentPresetName or ""
SkyStudioDataStore.cLoadedBlueprintSaveToken = SkyStudioDataStore.cLoadedBlueprintSaveToken or nil

-- Build a serializable config table from the datastore.
-- Per your requirement: “entirety of configurable values (minus default values table)”.
-- Also excludes runtime bookkeeping fields we add for blueprint browsing.
local function buildSkyStudioConfigSnapshot(self)
  local t = {}

  -- Fields to exclude from serialization:
  -- - defaultValues: reference data, not user config
  -- - tSkyStudioBlueprintSaves: runtime blueprint cache
  -- - cLoadedBlueprintSaveToken: runtime state (userdata)
  -- - tGlobalMessageReceivers: contains function callbacks (breaks serialization!)
  -- - cCurrentParkSaveToken: runtime state (userdata)
  -- - bParkHasSkyStudioConfig: runtime state
  -- - bIsSavingPreset: runtime state
  local tExcludedKeys = {
    defaultValues = true,
    tSkyStudioBlueprintSaves = true,
    cLoadedBlueprintSaveToken = true,
    tGlobalMessageReceivers = true,
    cCurrentParkSaveToken = true,
    bParkHasSkyStudioConfig = true,
    bIsSavingPreset = true,
  }

  for k, v in pairs(self) do
    if not tExcludedKeys[k] then
      local tv = type(v)
      if tv ~= "function" and tv ~= "userdata" and tv ~= "thread" then
        t[k] = deepCopy(v)
      end
    end
  end

  return t
end

-- Connect the park save hook to the config snapshot function
-- This allows the hook (defined at module load time) to access the snapshot function
fnGetSkyStudioConfigSnapshot = function()
  return buildSkyStudioConfigSnapshot(SkyStudioDataStore)
end
trace('Park save hook connected to SkyStudioDataStore config snapshot')

-- Apply a loaded config snapshot onto the datastore (overwrite keys).
local function applySkyStudioConfigSnapshot(self, tConfig)
  if type(tConfig) ~= "table" then
    return
  end

  for k, v in pairs(tConfig) do
    if k ~= "defaultValues" then
      local tv = type(v)
      if tv ~= "function" and tv ~= "userdata" and tv ~= "thread" then
        self[k] = deepCopy(v)
      end
    end
  end
end

-- local SelectAndEditComponent = api.world.GetWorldAPIs().SelectAndEditComponent
-- SelectAndEditComponent.

-- Getting selection set:
-- local selection = (self.editorContext):GetSelectionSet()

-- Getting editor context:
-- self.gameModeHelperComponent = (self.tWorldAPIs).GameModeHelperComponent
-- local editMode = (self.gameModeHelperComponent):GetCurrentMode(editorEntityID)
-- if editMode.GetEditorContext then
--   local editorContext = editMode:GetEditorContext()
-- end

-- Internal function to capture a screenshot (called from within coroutine)
local function _PerformCameraCapture()
  trace('_PerformCameraCapture: Starting...')
  
  -- Wait for capture system to be ready
  while not api.render.IsCaptureSystemReady() do
    trace('_PerformCameraCapture: Waiting for capture system...')
    coroutine.yield()
  end
  trace('_PerformCameraCapture: Capture system ready')
  
  local vBackBufferDimensions = api.render.GetBackBufferDimensions()
  local nX = vBackBufferDimensions:GetX()
  local nY = vBackBufferDimensions:GetY()
  trace('_PerformCameraCapture: Screen dimensions: ' .. tostring(nX) .. 'x' .. tostring(nY))
  
  local nMaxDimension = 1280
  local nPictureAspectRatio = 1.777778  -- 16:9
  local nScreenAspectRatio = nX / nY
  
  -- Adjust for aspect ratio
  if nPictureAspectRatio < nScreenAspectRatio then
    nX = nY * nPictureAspectRatio
  elseif nScreenAspectRatio < nPictureAspectRatio then
    nY = nX / nPictureAspectRatio
  end
  
  -- Scale down if needed
  local nScaleFactor = 1
  if nMaxDimension < nX then
    nScaleFactor = nMaxDimension / nX
  end
  nX = math.floor(nX * nScaleFactor)
  nY = math.floor(nY * nScaleFactor)
  
  trace('_PerformCameraCapture: Adjusted dimensions: ' .. tostring(nX) .. 'x' .. tostring(nY))
  
  -- Capture full screen (minU=0, minV=0, maxU=1, maxV=1)
  -- Two captures: thumbnail (416x232) and big image
  trace('_PerformCameraCapture: Starting capture...')
  api.render.StartCaptureFromSourceArea(
    {minU = 0, minV = 0, maxU = 1, maxV = 1, width = 416, height = 232, quality = 75},  -- thumbnail
    {minU = 0, minV = 0, maxU = 1, maxV = 1, width = nX, height = nY, maxFileSize = 1048576, quality = 90}  -- big
  )
  
  -- Wait for capture to complete
  while not api.render.IsCaptureSystemReady() do
    trace('_PerformCameraCapture: Waiting for capture to complete...')
    coroutine.yield()
  end
  
  local cToken = api.render.GetCaptureToken()
  trace('_PerformCameraCapture: Got capture token: ' .. tostring(cToken))
  
  return cToken
end
 
-- Start the async save process (creates a coroutine)
function SkyStudioDataStore:StartSaveSettingsAsBlueprint(selection, tWorldAPIs)
  trace('StartSaveSettingsAsBlueprint called')
  
  -- TODO: Re-enable this check once we figure out why oncomplete doesn't always fire
  -- Check if already saving
  -- if self.bIsSavingPreset then
  --   trace('Already saving a preset, ignoring request')
  --   return false
  -- end
  
  -- Validate selection parameter
  if not selection then
    trace('selection is nil')
    return false
  end
  
  trace('selection CountParts: ' .. tostring(selection:CountParts()))
  
  if selection:CountParts() == 0 then
    trace('selection countParts == 0')
    return false
  end
  
  -- Set flag (still set it so Advance knows to run the coroutine)
  self.bIsSavingPreset = true
  trace('bIsSavingPreset = true')
  
  -- Create the coroutine that will do the actual save
  self.fnSavePresetCoroutine = coroutine.create(function()
    trace('Save coroutine started')
    
    -- Get APIs needed for creating SaveSelection
    local worldSerialisationAPI = tWorldAPIs and tWorldAPIs.worldserialisation
    local sceneryAPI = tWorldAPIs and tWorldAPIs.scenery
    
    -- Convert BuildingPartSet to SaveSelection (required by api.save.RequestSave)
    local saveSelection = nil
    if worldSerialisationAPI and worldSerialisationAPI.CreateSaveSelection then
      saveSelection = worldSerialisationAPI:CreateSaveSelection()
      trace('Created SaveSelection via worldSerialisationAPI')
      
      -- Add parts from our BuildingPartSet to the SaveSelection
      if sceneryAPI and sceneryAPI.AddSceneryToBlueprintSelection then
        local tPartIDs = selection:GetPartIDCollection()
        if tPartIDs then
          for i = 1, #tPartIDs do
            sceneryAPI:AddSceneryToBlueprintSelection(tPartIDs[i], saveSelection)
            trace('Added partID ' .. tostring(tPartIDs[i]) .. ' to SaveSelection')
          end
        else
          trace('ERROR: GetPartIDCollection returned nil')
          self.bIsSavingPreset = false
          return
        end
      else
        trace('ERROR: AddSceneryToBlueprintSelection not available')
        self.bIsSavingPreset = false
        return
      end
    else
      trace('ERROR: worldSerialisationAPI.CreateSaveSelection not available')
      self.bIsSavingPreset = false
      return
    end
    
    -- Capture screenshot
    trace('Starting screenshot capture...')
    local imgToken = _PerformCameraCapture()
    
    -- Build screenshot info
    local tScreenshotInfo = nil
    if imgToken then
      tScreenshotInfo = {nIndex = 0, cToken = imgToken, nBigIndex = 1}
      trace('Built tScreenshotInfo with token')
    else
      trace('WARNING: No screenshot token, tScreenshotInfo will be nil')
    end
    
    -- Build config and metadata
    local tConfig = buildSkyStudioConfigSnapshot(self)
    local sName = (self.sCurrentPresetName and self.sCurrentPresetName ~= "") and self.sCurrentPresetName or "SkyStudio Preset"
    
    -- Debug: trace Fog and Haze Albedo values being saved
    if tConfig.tUserRenderParameters and tConfig.tUserRenderParameters.Atmospherics then
      local atm = tConfig.tUserRenderParameters.Atmospherics
      if atm.Fog and atm.Fog.Albedo and atm.Fog.Albedo.value then
        local v = atm.Fog.Albedo.value
        trace('SAVE Fog.Albedo.value: {' .. tostring(v[1]) .. ', ' .. tostring(v[2]) .. ', ' .. tostring(v[3]) .. '}')
      else
        trace('SAVE Fog.Albedo: NOT FOUND in config')
      end
      if atm.Haze and atm.Haze.Albedo and atm.Haze.Albedo.value then
        local v = atm.Haze.Albedo.value
        trace('SAVE Haze.Albedo.value: {' .. tostring(v[1]) .. ', ' .. tostring(v[2]) .. ', ' .. tostring(v[3]) .. '}')
      else
        trace('SAVE Haze.Albedo: NOT FOUND in config')
      end
    else
      trace('SAVE: tUserRenderParameters.Atmospherics NOT FOUND in config')
    end
    
    -- Metadata must include all standard fields the game expects, plus our custom data
    -- See SaveMetadataBuilder for the expected structure
    local tMetadata = {
      nVersion = 23,  -- Current metadata version (SaveMetadataBuilder.cCurrentMetadataVersion)
      sGameVersion = "1.0",  -- SaveMetadataBuilder.cCurrentGameVersion
      nType = 1,  -- Type_Blueprint (SaveMetadataBuilder.Type_Blueprint)
      bComplexityLimitDisabledWhenSaved = false,
      sName = sName,
      sDescription = "SkyStudio Lighting Preset",
      tTags = {},  -- Empty array
      nRequiredDLC = 0,
      nLoadCriticalDLC = 0,
      bIsModded = true,
      tBlueprint = {
        nBuildingCount = 0,
        nSceneryCount = 1,
        nFlatRideCount = 0,
        nTrackedRideCount = 0,
        nPlacementCost = 0,
        nRunningCost = 0,
        tResearchPacks = nil,
        tEFN = nil,
        sRideID = nil,
        -- Custom SkyStudio data stored within tBlueprint
        tSkyStudioConfig = tConfig,
        sSkyStudioConfigName = sName,
      },
      tSave = {
        sParkName = nil,
        sWorldName = nil,
        sGeome = nil,
        sGameMode = nil,
        sScenarioCode = nil,
        sChallengeName = nil,
        tMedals = nil,
        tObjectives = nil,
        bContainsUGC = nil,
        bIsUGCPark = nil,
        nComplexity = nil,
        nGuestCap = nil,
        nGuestCount = nil,
      },
      tResource = {
        nRunningCost = 0,
        nPlacementCost = 0,
      },
    }
    
    -- Use api.save.RequestSave with proper SaveSelection
    local tSaveInfo = {
      type = "blpr2",
      location = "local",
      customname = sName,
      metadata = tMetadata,
      selection = saveSelection,  -- Must be a SaveSelection, not BuildingPartSet
      screenshotInfo = tScreenshotInfo,
      oncomplete = function(_tSaveInfo)
        trace('RequestSave oncomplete called!')
        if _tSaveInfo and _tSaveInfo.exception == nil and _tSaveInfo.save ~= nil then
          local newToken = _tSaveInfo.save
          trace("Saved SkyStudio preset, token: " .. tostring(newToken))
          
          -- Update current preset name
          self.sCurrentPresetName = sName
          
          -- Directly add/update the preset in our list (avoids EnumerateBlueprintSaves crash)
          -- Check if we're overwriting an existing preset or adding a new one
          -- Compare by preset NAME since userdata tokens may not compare equal by reference
          -- If we're saving a preset with the same name as an existing one, update that entry
          local bFoundExisting = false
          local oldTokenToDelete = nil
          for i, entry in ipairs(self.tSkyStudioBlueprintSaves) do
            if entry.sPresetName == sName then
              -- Overwriting existing - save the old token for deletion, then update to new token
              oldTokenToDelete = entry.cSaveToken
              entry.cSaveToken = newToken
              bFoundExisting = true
              trace('Updated existing preset at index ' .. tostring(i) .. ' with name: ' .. sName .. ' and new token')
              break
            end
          end
          
          if not bFoundExisting then
            -- New preset - add to list
            table.insert(self.tSkyStudioBlueprintSaves, {
              sPresetName = sName,
              cSaveToken = newToken
            })
            trace('Added new preset to list: ' .. sName .. ' (total: ' .. tostring(#self.tSkyStudioBlueprintSaves) .. ')')
          end
          
          -- If we overwrote an existing preset, delete the old save file to prevent duplicates
          if oldTokenToDelete and oldTokenToDelete ~= newToken then
            trace('Deleting old save file to prevent duplicates...')
            api.save.RequestDelete(oldTokenToDelete, {
              oncomplete = function()
                trace('Old save file deleted successfully')
              end
            })
          end
          
          -- Update loaded token to point to this save
          self.cLoadedBlueprintSaveToken = newToken
          
          -- Call completion callback to update UI (if set by manager)
          if self.fnOnSaveComplete then
            trace('Calling fnOnSaveComplete to update UI...')
            self.fnOnSaveComplete()
          end
        else
          trace("Save failed or had exception: " .. tostring(_tSaveInfo and _tSaveInfo.exception))
        end
        
        -- Clear flag regardless of success/failure
        self.bIsSavingPreset = false
        trace('bIsSavingPreset = false, save complete!')
      end
    }
    
    -- For new saves, pass player owner. For overwriting existing, pass the existing token.
    local saveToken = self.cLoadedBlueprintSaveToken or api.player.GetGameOwner()
    
    trace('Calling api.save.RequestSave...')
    trace('  saveToken: ' .. tostring(saveToken))
    trace('  saveSelection type: ' .. tostring(type(saveSelection)))
    trace('  screenshotInfo: ' .. tostring(tScreenshotInfo ~= nil))
    
    api.save.RequestSave(saveToken, tSaveInfo)
    
    trace('api.save.RequestSave called, waiting for oncomplete...')
  end)
  
  trace('Save coroutine created')
  return true
end

-- Advance function to be called each frame to run the save coroutine
function SkyStudioDataStore:AdvanceSaveCoroutine()
  -- First, handle the coroutine if it exists
  if self.fnSavePresetCoroutine then
    local status = coroutine.status(self.fnSavePresetCoroutine)
    if status == "suspended" then
      local bOk, sErr = coroutine.resume(self.fnSavePresetCoroutine)
      if not bOk then
        trace('Save coroutine error: ' .. tostring(sErr))
        self.fnSavePresetCoroutine = nil
        self.bIsSavingPreset = false
      end
    elseif status == "dead" then
      trace('Coroutine dead, clearing reference')
      self.fnSavePresetCoroutine = nil
      trace('Coroutine reference cleared')
    end
  end
  
end

-- Legacy function for compatibility (now starts the async save)
function SkyStudioDataStore:SaveSettingsAsBlueprintWithSaveToken(selection, tWorldAPIs)
  return self:StartSaveSettingsAsBlueprint(selection, tWorldAPIs)
end

function SkyStudioDataStore:LoadSettingsFromBlueprintWithSaveToken(cSaveToken)
  if cSaveToken == nil then
    return false
  end

  local tMetadata = api.save.GetSaveMetadata(cSaveToken)
  if type(tMetadata) ~= "table" then
    return false
  end

  local tBlueprint = tMetadata.tBlueprint
  if type(tBlueprint) ~= "table" then
    return false
  end

  local tConfig = tBlueprint.tSkyStudioConfig
  if type(tConfig) ~= "table" then
    -- This blueprint doesn’t contain SkyStudio config
    return false
  end

  -- trace('full config')
  -- trace(tConfig)
  -- trace('full renderparameters')
  -- trace(tConfig.tUserRenderParameters)

  -- Helper to get color value handling both numeric and string keys (serialization can convert 1 to "1")
  local function getColorValue(v, index)
    return v[index] or v[tostring(index)]
  end
  
  -- Normalize Fog and Haze Albedo arrays in the loaded config (fix string key issue from serialization)
  if tConfig.tUserRenderParameters and tConfig.tUserRenderParameters.Atmospherics then
    local atm = tConfig.tUserRenderParameters.Atmospherics
    if atm.Fog and atm.Fog.Albedo then
      normalizeColorArray(atm.Fog.Albedo)
    end
    if atm.Haze and atm.Haze.Albedo then
      normalizeColorArray(atm.Haze.Albedo)
    end
  end

  -- Debug: trace Fog and Haze Albedo values FROM the loaded config (after normalization)
  if tConfig.tUserRenderParameters and tConfig.tUserRenderParameters.Atmospherics then
    local atm = tConfig.tUserRenderParameters.Atmospherics
    if atm.Fog and atm.Fog.Albedo and atm.Fog.Albedo.value then
      local v = atm.Fog.Albedo.value
      trace('LOAD (from file) Fog.Albedo.value: {' .. tostring(v[1]) .. ', ' .. tostring(v[2]) .. ', ' .. tostring(v[3]) .. '}')
    else
      trace('LOAD (from file) Fog.Albedo: NOT FOUND in config')
    end
    if atm.Haze and atm.Haze.Albedo and atm.Haze.Albedo.value then
      local v = atm.Haze.Albedo.value
      trace('LOAD (from file) Haze.Albedo.value: {' .. tostring(v[1]) .. ', ' .. tostring(v[2]) .. ', ' .. tostring(v[3]) .. '}')
    else
      trace('LOAD (from file) Haze.Albedo: NOT FOUND in config')
    end
  else
    trace('LOAD (from file): tUserRenderParameters.Atmospherics NOT FOUND in config')
  end

  -- trace('Applying config snapshot: ')
  -- trace(tConfig);

  -- Apply loaded config to datastore
  applySkyStudioConfigSnapshot(self, tConfig)

  -- Debug: trace Fog and Haze Albedo values AFTER applying to datastore
  if self.tUserRenderParameters and self.tUserRenderParameters.Atmospherics then
    local atm = self.tUserRenderParameters.Atmospherics
    if atm.Fog and atm.Fog.Albedo and atm.Fog.Albedo.value then
      local v = atm.Fog.Albedo.value
      trace('LOAD (after apply) Fog.Albedo.value: {' .. tostring(v[1]) .. ', ' .. tostring(v[2]) .. ', ' .. tostring(v[3]) .. '}')
    else
      trace('LOAD (after apply) Fog.Albedo: NOT FOUND in datastore')
    end
    if atm.Haze and atm.Haze.Albedo and atm.Haze.Albedo.value then
      local v = atm.Haze.Albedo.value
      trace('LOAD (after apply) Haze.Albedo.value: {' .. tostring(v[1]) .. ', ' .. tostring(v[2]) .. ', ' .. tostring(v[3]) .. '}')
    else
      trace('LOAD (after apply) Haze.Albedo: NOT FOUND in datastore')
    end
  else
    trace('LOAD (after apply): tUserRenderParameters.Atmospherics NOT FOUND in datastore')
  end

  -- Track which blueprint token is currently loaded so "Save" can overwrite it
  self.cLoadedBlueprintSaveToken = cSaveToken

  -- Prefer explicit stored config name; fall back to save custom name
  local sName = tBlueprint.sCurrentPresetName
  if not sName or sName == "" then
    sName = api.save.GetSaveCustomName(cSaveToken)
  end
  if sName and sName ~= "" then
    self.sCurrentPresetName = sName
  end

  return true
end

-- function SkyStudioDataStore:OnDeleteComplete(result)
--   trace('deleted preset')
--   trace(result)
-- end

function SkyStudioDataStore:DeleteSettingsBlueprint(cSaveToken)
  local function onDeleteComplete()
    trace('deleted preset, removing from presets list')

    for i, entry in ipairs(self.tSkyStudioBlueprintSaves) do
      if entry.cSaveToken == cSaveToken then
        table.remove(self.tSkyStudioBlueprintSaves, i)
        trace('Removed preset from list at index ' .. tostring(i))
        break
      end
    end

    -- If we deleted the currently loaded preset, clear the current preset state
    if self.cLoadedBlueprintSaveToken == cSaveToken then
      trace('Deleted preset was the currently loaded preset, clearing current preset state')
      self.cLoadedBlueprintSaveToken = nil
      self.sCurrentPresetName = ""
    end

    if self.fnOnDeleteComplete then
      self.fnOnDeleteComplete()
    end
  end

  api.save.RequestDelete(cSaveToken, { oncomplete = onDeleteComplete })
end

-- Load settings from a blueprint by its index in tSkyStudioBlueprintSaves
function SkyStudioDataStore:LoadSettingsFromBlueprintByIndex(nIndex)
  trace("LoadSettingsFromBlueprintByIndex: " .. tostring(nIndex))
  
  local tBlueprintEntry = self.tSkyStudioBlueprintSaves[nIndex]
  if not tBlueprintEntry then
    trace("No blueprint found at index: " .. tostring(nIndex))
    return false
  end
  
  local cSaveToken = tBlueprintEntry.cSaveToken
  if not cSaveToken then
    trace("Blueprint entry at index " .. tostring(nIndex) .. " has no save token")
    return false
  end
  
  trace("Loading blueprint: " .. tostring(tBlueprintEntry.sPresetName))
  return self:LoadSettingsFromBlueprintWithSaveToken(cSaveToken)
end

function SkyStudioDataStore:DeleteSettingsBlueprintByIndex(nIndex)
  trace("DeleteSettingsBlueprintByIndex: " .. tostring(nIndex))

  local tBlueprintEntry = self.tSkyStudioBlueprintSaves[nIndex]
  if not tBlueprintEntry then
    trace("No blueprint found at index: " .. tostring(nIndex))
    return false
  end

  local cSaveToken = tBlueprintEntry.cSaveToken
  if not cSaveToken then
    trace("Blueprint entry at index " .. tostring(nIndex) .. " has no save token")
    return false
  end

  return self:DeleteSettingsBlueprint(cSaveToken)
end

function SkyStudioDataStore:LoadBlueprints()
  trace('LoadBlueprints: START')
  self.tSkyStudioBlueprintSaves = {}
  trace('LoadBlueprints: Cleared tSkyStudioBlueprintSaves')
 
  -- 1) Local blueprint saves (blpr2)
  trace('LoadBlueprints: Calling EnumerateBlueprintSaves...')
  local bLocalSuccess, tLocalTokens = ParkLoadSaveManager:EnumerateBlueprintSaves()
  trace('LoadBlueprints: EnumerateBlueprintSaves returned, bLocalSuccess=' .. tostring(bLocalSuccess))
  
  if bLocalSuccess and type(tLocalTokens) == "table" then
    trace('LoadBlueprints: Got ' .. tostring(#tLocalTokens) .. ' tokens')
    for i, cSaveToken in ipairs(tLocalTokens) do
      trace('LoadBlueprints: Processing token ' .. tostring(i) .. '...')
      local tMetadata = api.save.GetSaveMetadata(cSaveToken)
      trace('LoadBlueprints: Got metadata for token ' .. tostring(i))
      if type(tMetadata) == "table" and tMetadata.tBlueprint and type(tMetadata.tBlueprint.tSkyStudioConfig) == "table" then
        trace('LoadBlueprints: Token ' .. tostring(i) .. ' is a SkyStudio preset')
        local sName = tMetadata.tBlueprint.tSkyStudioConfig.sCurrentPresetName
        if not sName or sName == "" then
          sName = api.save.GetSaveCustomName(cSaveToken)
        end

        table.insert(self.tSkyStudioBlueprintSaves, {
          sPresetName = sName or "SkyStudio Preset",
          cSaveToken = cSaveToken
        })
        trace('LoadBlueprints: Added preset "' .. tostring(sName) .. '"')
      end
    end
  else
    trace("LoadBlueprints: Failed to enumerate local blueprint saves")
  end
  
  -- 2) Installed workshop blueprints
  -- We can enumerate them, but in this decompiled manager there isn’t a guaranteed “get metadata” path
  -- for installed items here (unlike save tokens via api.save.GetSaveMetadata).
  -- So: best-effort only—if an item already contains metadata in its returned table, we’ll use it.
  -- local bWorkshopSuccess, tWorkshopItems = ParkLoadSaveManager:EnumerateInstalledBlueprints()
  -- trace('tWorkshopItems')
  -- trace(tWorkshopItems)
  -- if bWorkshopSuccess and type(tWorkshopItems) == "table" then
  --   for _, item in ipairs(tWorkshopItems) do
  --     -- Best-effort: some builds include metadata directly on the item record.
  --     local tMetadata = item.metadata
  --     if type(tMetadata) == "table" and type(tMetadata.tBlueprint.tSkyStudioConfig) == "table" then
  --       local sName = tMetadata.tBlueprint.tSkyStudioConfig.sCurrentPresetName

  --       if not sName or sName == "" then
  --         sName = api.save.GetSaveCustomName(item.cSaveToken)
  --       end

  --       local token = item.token or item.cSaveToken or item.cItemToken -- unknown shape; kept for debugging/extension
  --       if token ~= nil then
  --         table.insert(self.tSkyStudioBlueprintSaves, { sPresetName = sName, cSaveToken = token })
  --       end
  --     end
  --   end
  -- end

  trace('tSkyStudioBlueprintSaves')
  trace(self.tSkyStudioBlueprintSaves)

  return self.tSkyStudioBlueprintSaves
end

----------------------------------------------------------------
-- Park Save/Load Integration
-- Automatically save/load SkyStudio config with park saves
----------------------------------------------------------------

-- Track the currently active park save token
SkyStudioDataStore.cCurrentParkSaveToken = nil
SkyStudioDataStore.bParkHasSkyStudioConfig = false

-- Global message receiver for park save/load events
SkyStudioDataStore.tGlobalMessageReceivers = {}

-- Initialize park save/load hooks
function SkyStudioDataStore:InitParkSaveLoadHooks()
  trace('InitParkSaveLoadHooks: Registering global message receivers...')
  
  -- Listen for park saved/deleted messages
  if api.messaging and api.messaging.MsgType_PlayerParkSavedDeletedMessage then
    self.tGlobalMessageReceivers[api.messaging.MsgType_PlayerParkSavedDeletedMessage] = function(tMessages)
      trace('Park save/delete message received')
      self:OnParkSavedOrDeleted(tMessages)
    end
    api.messaging.RegisterGlobalReceiver(
      api.messaging.MsgType_PlayerParkSavedDeletedMessage,
      self.tGlobalMessageReceivers[api.messaging.MsgType_PlayerParkSavedDeletedMessage]
    )
    trace('InitParkSaveLoadHooks: Registered MsgType_PlayerParkSavedDeletedMessage receiver')
  else
    trace('InitParkSaveLoadHooks: WARNING - api.messaging or MsgType_PlayerParkSavedDeletedMessage not available')
  end
end

-- Cleanup park save/load hooks
function SkyStudioDataStore:CleanupParkSaveLoadHooks()
  trace('CleanupParkSaveLoadHooks: Unregistering global message receivers...')
  
  for nMessageType, fnReceiver in pairs(self.tGlobalMessageReceivers) do
    if api.messaging and api.messaging.UnregisterGlobalReceiver then
      api.messaging.UnregisterGlobalReceiver(nMessageType, fnReceiver)
    end
  end
  self.tGlobalMessageReceivers = {}
end

-- Called when a park is saved or deleted
function SkyStudioDataStore:OnParkSavedOrDeleted(tMessages)
  trace('OnParkSavedOrDeleted called')
  -- The message contains the save token
  -- We can use this to track the current park
  if tMessages and #tMessages > 0 then
    for _, msg in ipairs(tMessages) do
      if msg.save then
        trace('Park save token detected: ' .. tostring(msg.save))
        self.cCurrentParkSaveToken = msg.save
      end
    end
  end
end

-- Try to load SkyStudio config from the currently loaded park's metadata
function SkyStudioDataStore:TryLoadConfigFromPark()
  trace('TryLoadConfigFromPark called')
  
  -- Get the ParkLoadSaveManager to find the active park save token
  local parkManager = nil
  if api.game and api.game.GetEnvironment then
    local env = api.game.GetEnvironment()
    if env and env.RequireInterface then
      parkManager = env:RequireInterface("Interfaces.IParkLoadSaveManager")
    end
  end
  
  if not parkManager then
    trace('TryLoadConfigFromPark: Could not get ParkLoadSaveManager')
    return false
  end
  
  -- Get the last active park save token
  local cSaveToken = parkManager.cLastActiveParkSaveToken
  if not cSaveToken then
    trace('TryLoadConfigFromPark: No active park save token')
    return false
  end
  
  trace('TryLoadConfigFromPark: Found active park save token')
  self.cCurrentParkSaveToken = cSaveToken
  
  -- Get the park's metadata
  local tMetadata = api.save.GetSaveMetadata(cSaveToken)
  if not tMetadata then
    trace('TryLoadConfigFromPark: Could not get park metadata')
    return false
  end
  
  -- Check if the metadata contains SkyStudio config
  if tMetadata.tSkyStudioConfig then
    trace('TryLoadConfigFromPark: Found tSkyStudioConfig in park metadata!')
    
    local tConfig = tMetadata.tSkyStudioConfig
    
    -- Normalize color arrays if needed (same as blueprint loading)
    if tConfig.tUserRenderParameters then
      local atm = tConfig.tUserRenderParameters.Atmospherics
      if atm then
        if atm.Fog and atm.Fog.Albedo then
          normalizeColorArray(atm.Fog.Albedo)
        end
        if atm.Haze and atm.Haze.Albedo then
          normalizeColorArray(atm.Haze.Albedo)
        end
      end
    end
    
    -- Apply the config
    applySkyStudioConfigSnapshot(self, tConfig)
    self.bParkHasSkyStudioConfig = true
    
    trace('TryLoadConfigFromPark: Successfully applied SkyStudio config from park')
    return true
  else
    trace('TryLoadConfigFromPark: No tSkyStudioConfig in park metadata - resetting to defaults')
    self.bParkHasSkyStudioConfig = false
    -- Reset all settings to defaults when loading a park without SkyStudio config
    self:ResetAllToDefaults()
    return false
  end
end

return SkyStudioDataStore

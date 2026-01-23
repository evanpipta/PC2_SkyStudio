local global = _G
local api = api
local ParkLoadSaveManager = require("managers.parkloadsavemanager")

local trace = require('SkyStudioTrace')

local SkyStudioDataStore = {}

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

-- Reset all user settings
function SkyStudioDataStore:ResetAllToDefaults()
  -- Reset simple nUser* values
  for key, value in pairs(SkyStudioDataStore.defaultValues) do
    if string.sub(key, 1, 5) == "nUser" then -- or string.sub(key, 1, 5) == "bUser" then
      SkyStudioDataStore[key] = value
    end
  end
  
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



-- If saving over an existing save, pass in the save token
-- Otherwise leave it nil to generate a new one
function SkyStudioDataStore:SaveSettingsAsBlueprintWithSaveToken()
  local tMetadata = {}
  tMetadata.tUserRenderParameters = deepCopy(self.tUserRenderParameters)

  -- Convert the current sky studio data store to a table, skipping only defaultValues
  -- Then write it to the metadata using the key tSkyStudioConfig
  -- Then save that as a blueprint to a save token
  -- If we have a save token already loaded, use that
  -- Otherwise, make sure we have a string name to generate a new one from

  -- ParkLoadSaveManager.SaveBlueprintToSaveToken(nil, nil, nil, tMetadata, nil)

end

function SkyStudioDataStore:LoadSettingsFromBlueprintWithSaveToken(cSaveToken) 
  local tMetadata = api.save.GetSaveMetadata(cSaveToken)
  trace("Metadata")
  trace(tMetadata)

  if tMetadata.tBlueprint.tSkyStudioConfig ~= nil then
    -- Overwrite data store config with config saved in blueprint metadata

    -- Also store the save token in a new value in the data store so we can use it to overwrite the save later if we save over the existing config

  end
  
end

function SkyStudioDataStore:LoadBlueprints()
  trace("EnumerateInstalledBlueprints")

  local bWorkshopSuccess, tWorkshopItems = ParkLoadSaveManager:EnumerateInstalledBlueprints()

  if (bWorkshopSuccess) then
    trace(tWorkshopItems)
  else 
    trace('Failed to load blueprionts from workshop')
  end

  trace('EnumerateBlueprintSaves')

  local bLocalSuccess, tLocalItems = ParkLoadSaveManager:EnumerateBlueprintSaves()

  if (bLocalSuccess) then
    trace(tLocalItems)
  else 
    trace('Failed to load blueprionts from local')
  end

  -- TODO - iterate both sets of blueprints and filter down ones that include a tSkyStudioConfig key, then store the tokens of those blueprints somewhere
  -- Store a list that ust has the name and the save token
  -- We don't need to store the whole config because that will happen when we call LoadSettingsFromBlueprintWithSaveToken
  
end

return SkyStudioDataStore

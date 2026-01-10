local SkyStudioDataStore = {}

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

SkyStudioDataStore.nUserDayNightTransition = 90
SkyStudioDataStore.nUserSunFade = 1
SkyStudioDataStore.nUserMoonFade = 0

SkyStudioDataStore.tUserRenderParameters = {
  Atmospherics = {
    Fog = {
      Density = 1
    },
    Haze = {
      Density = 1
    },
    Lights = {
      Sun  = {
        Disk = {
          Size = 0.5,
          Intensity = 10
        }
      },
      Moon = {
        Disk = {
          Size = 0.5,
          Intensity = 15,
        }
      },
    },
    Stars = {
      Strength = 1
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
  tUserRenderParameters = {}
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

-- Reset all user values from the sun color tab
function SkyStudioDataStore:ResetSunToDefaults()
  SkyStudioDataStore.nUserSunColorR = SkyStudioDataStore.defaultValues.nUserSunColorR
  SkyStudioDataStore.nUserSunColorG = SkyStudioDataStore.defaultValues.nUserSunColorG
  SkyStudioDataStore.nUserSunColorB = SkyStudioDataStore.defaultValues.nUserSunColorB
  SkyStudioDataStore.nUserSunIntensity = SkyStudioDataStore.defaultValues.nUserSunIntensity
  SkyStudioDataStore.nUserSunGroundMultiplier = SkyStudioDataStore.defaultValues.nUserSunGroundMultiplier
  SkyStudioDataStore.nUserSunFade = SkyStudioDataStore.defaultValues.nUserSunFade
end

-- Reset all user values from the moon color tab
function SkyStudioDataStore:ResetMoonToDefaults()
  SkyStudioDataStore.nUserMoonColorR = SkyStudioDataStore.defaultValues.nUserMoonColorR
  SkyStudioDataStore.nUserMoonColorG = SkyStudioDataStore.defaultValues.nUserMoonColorG
  SkyStudioDataStore.nUserMoonColorB = SkyStudioDataStore.defaultValues.nUserMoonColorB
  SkyStudioDataStore.nUserMoonIntensity = SkyStudioDataStore.defaultValues.nUserMoonIntensity
  SkyStudioDataStore.nUserMoonGroundMultiplier = SkyStudioDataStore.defaultValues.nUserMoonGroundMultiplier
  SkyStudioDataStore.nUserMoonFade = SkyStudioDataStore.defaultValues.nUserMoonFade
end

-- Reset all user settings
function SkyStudioDataStore:ResetAllToDefaults()
  for key, value in pairs(SkyStudioDataStore.defaultValues) do
    if string.sub(key, 1, 5) == "nUser" then -- or string.sub(key, 1, 5) == "bUser" then
      SkyStudioDataStore[key] = value
    end
  end
end

return SkyStudioDataStore

local SkyStudioDataStore = {}


SkyStudioDataStore.bUseVanillaLighting = false

SkyStudioDataStore.nParkTodCycleMoonColorR = 0.341                 -- vanilla default: 0.341
SkyStudioDataStore.nParkTodCycleMoonColorG = 0.588                 -- vanilla default: 0.588
SkyStudioDataStore.nParkTodCycleMoonColorB = 1                     -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleMoonIntensity = 0.65               -- vanilla default: 0.65

SkyStudioDataStore.nParkTodCycleSunColorR = 1                      -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleSunColorG = 1                      -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleSunColorB = 1                      -- vanilla default: 1
SkyStudioDataStore.nParkTodCycleSunIntensity = 150                 -- vanilla default: 128

SkyStudioDataStore.nParkTodCycleDayNightTransitionMidnight = 40   -- midnight value
SkyStudioDataStore.nParkTodCycleDayNightTransitionDawn = 45       -- dawn value
SkyStudioDataStore.nParkTodCycleDayNightTransitionNoon = 95       -- noon value
SkyStudioDataStore.nParkTodCycleDayNightTransitionDusk = 45       -- dusk value

SkyStudioDataStore.nParkTodCycleDayNightTransitionCurve = 2
SkyStudioDataStore.nParkTodCycleTwilightLength = 30

SkyStudioDataStore.nParkTodCycleMoonDuskFadeStart = -1
SkyStudioDataStore.nParkTodCycleMoonDuskFadeEnd = 0.5

SkyStudioDataStore.nParkTodCycleMoonDawnFadeStart = 179
SkyStudioDataStore.nParkTodCycleMoonDawnFadeEnd = 180.5

SkyStudioDataStore.nParkTodCycleSunDawnFadeStart = -0.5
SkyStudioDataStore.nParkTodCycleSunDawnFadeEnd = 1

SkyStudioDataStore.nParkTodCycleSunDuskFadeStart = 179
SkyStudioDataStore.nParkTodCycleSunDuskFadeEnd = 180.5

-- Moon's phase relative to the sun (180 = full moon opposite sun, 0 = new moon in front of sun)
-- Default this to near 180 since we only have an almost full moon texture right now
-- Not even sure if that can be changed, it's something to work on later
SkyStudioDataStore.nParkTodCycleMoonPhase = 200

-- Sun orientation in the sky
SkyStudioDataStore.bUserOverrideSunOrientation = false
SkyStudioDataStore.nUserSunAzimuth = 0                   -- Sun "rotation" in degrees
SkyStudioDataStore.nUserSunLatitudeOffset = 0            -- Sun "tilt" in degrees

-- Sun time of day
SkyStudioDataStore.bUserOverrideSunTimeOfDay = false     -- Override time of day, effectively the same as "fixed time of day" in vanilla
SkyStudioDataStore.nUserSunTimeOfDay = 9                 -- Time of day in hours (24 hour clock)

-- Sun color and intensity:
SkyStudioDataStore.bUserOverrideSunColorAndIntensity = false
SkyStudioDataStore.nUserSunColorR = 1                    -- vanilla defualt: 1
SkyStudioDataStore.nUserSunColorG = 1                    -- vanilla defualt: 1
SkyStudioDataStore.nUserSunColorB = 1                    -- vanilla defualt: 1
SkyStudioDataStore.nUserSunIntensity = 150               -- vanilla default: 128

-- Moon orientation in the sky:
SkyStudioDataStore.bUserOverrideMoonOrientation = false
SkyStudioDataStore.nUserMoonAzimuth = 5                  -- Moon "rotation" in degrees
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

SkyStudioDataStore.bUserOverrideSunFade = false
SkyStudioDataStore.bUserOverrideMoonFade = false

SkyStudioDataStore.bUserOverrideDayNightTransition = false

SkyStudioDataStore.nUserDayNightTransition = 90
SkyStudioDataStore.nUserSunFade = 1
SkyStudioDataStore.nUserMoonFade = 0

return SkyStudioDataStore

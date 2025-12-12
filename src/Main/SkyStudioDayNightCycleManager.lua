local global = _G
local api = global.api
local require = require

local DayNightCycle = require("lighting.daynightcycle")

local Quaternion = require("Quaternion")
local Rotation = require("Rotation")
local TransformQ = require("TransformQ")
local Vector3 = require("Vector3")
local CommonParameterSetter = require("CommonParameterSetter")
-- local Object = require("Common.Object")

local SkyStudioDataStore = require("SkyStudioDataStore")

local loadConfig = require("SkyStudioConfigLoader")

local trace = require("SkyStudioTrace")

local SkyStudioDayNightCycleManager = {}

----------------------------------------------------------------------
--  LOCAL HELPERS
----------------------------------------------------------------------

-- dawn = 0, noon = 90, dusk = 180, midnight = 270
local function HoursToDegrees(d)
  return (d * 15 - 90) % 360
end

local function DegreesToRadians(d)
  return d * math.pi / 180
end

local function TransformFromPosF(pos, forward)
  local rot = Rotation.FromF(forward or Vector3.ZAxis)
  local rotQ = Quaternion.FromRotation(rot)
  return TransformQ.FromOrPos(rotQ, pos or Vector3.Zero)
end

local function Linearstep(value, min, max)
  local t = (value - min) / (max - min)
  if t < 0 then t = 0 end
  if t > 1 then t = 1 end
  return t
end

local function RemapDawnDuskPropToAngle(dawnDuskProp)
  local integral, fractional = math.modf((dawnDuskProp - 1.5) * 0.5)
  local weight = 1 - math.abs(math.abs(fractional) * 2 - 1)
  return weight * 180 - 90
end

local function CalculateUserSunDirection(nSunH, nSunZ, nSunV)
  local vSunDirAtNoon = (Vector3:new(1, 0, 0)):RotatedAround(Vector3.YAxis, nSunH)
  local vSunRotationAxis = ((vSunDirAtNoon).Cross)(vSunDirAtNoon, Vector3.YAxis)
  vSunRotationAxis = -(vSunRotationAxis):RotatedAround(vSunDirAtNoon, nSunZ)
  local vSunDir = (vSunDirAtNoon):RotatedAround(vSunRotationAxis, nSunV)
  return vSunDir
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end


local function RemapRange(nValue, nInMin, nInMax, nOutMin, nOutMax)
    -- avoid division by zero
    if nInMax == nInMin then 
        return nOutMin 
    end
    local nT = (nValue - nInMin) / (nInMax - nInMin)
    return Lerp(nOutMin, nOutMax, nT)
end


-- t in [0,1], steepness >= 0
local function EaseOut(t, steepness)
    if steepness <= 0 then
        return t
    end
    local p = 1.0 + steepness
    local exponent = 1.0 / p      -- concave: big change near t=0
    return t ^ exponent
end

local function EaseIn(t, steepness)
    if steepness <= 0 then
        return t
    end
    local p = 1.0 + steepness
    local exponent = p            -- convex: big change near t=1
    return t ^ exponent
end

local function LerpDayNightFadeByAngle(nDawnValue, nNoonValue, nDuskValue, nMidnightValue, nSunAngle, nEasingParameter, _nDawnFadeEndDegrees, _nDuskFadeStartDegrees, _nDuskFadeEndDegrees, _nDawnFadeStartDegrees)
  local nDawnFadeEndDegrees = _nDawnFadeEndDegrees or 90
  local nDuskFadeStartDegrees = _nDuskFadeStartDegrees or 90
  local nDuskFadeEndDegrees = _nDuskFadeEndDegrees or 270
  local nDawnFadeStartDegrees = _nDawnFadeStartDegrees or 270

    local a = nSunAngle % 360
    nEasingParameter = nEasingParameter or 0.0

    if a < nDawnFadeEndDegrees then
        -- Dawn → Noon
        local t = a / nDawnFadeEndDegrees
        t = EaseOut(t, nEasingParameter)
        return Lerp(nDawnValue, nNoonValue, t)

    elseif a < nDuskFadeStartDegrees then
        -- Noon plateau
        return nNoonValue

    elseif a < 180 then
        -- Noon → Dusk
        local t = (a - nDuskFadeStartDegrees) / (180 - nDuskFadeStartDegrees)
        t = EaseIn(t, nEasingParameter)
        return Lerp(nNoonValue, nDuskValue, t)

    elseif a < nDuskFadeEndDegrees then
        -- Dusk → Midnight
        local t = (a - 180) / (nDuskFadeEndDegrees - 180)
        t = EaseOut(t, nEasingParameter)
        return Lerp(nDuskValue, nMidnightValue, t)

    elseif a < nDawnFadeStartDegrees then
        -- Midnight plateau
        return nMidnightValue

    else
        -- Midnight → Dawn
        local t = (a - nDawnFadeStartDegrees) / (360 - nDawnFadeStartDegrees)
        t = EaseIn(t, nEasingParameter)
        return Lerp(nMidnightValue, nDawnValue, t)
    end
end

-- Remap the day/night fade value so that the day/night fade slider is less sensitive and feels more linear at the low end
local function RemapDayNightFadeValue(nSliderValue)
    -- nSliderValue expected in [0, 1]
    if nSliderValue <= 0.5 then
        -- First half maps to [0.00, 0.05]
        local t = nSliderValue / 0.5  -- normalize 0→0.5 to 0→1
        return t * 0.05
    else
        -- Second half maps to [0.05, 1.00]
        local t = (nSliderValue - 0.5) / 0.5 -- normalize 0.5→1.0 to 0→1
        return 0.05 + t * (1.0 - 0.05)
    end
end

-- Engine twilight depth (degrees below horizon)
local nSkyShaderTwilightDepthDegrees = 3.0

-- User-adjustable: how many degrees below the horizon we treat as "twilight"
-- e.g. SkyStudioDataStore.nParkTodCycleTwilightLength = 10
-- We'll read it inside the function so it can be tweakable.
local function RemapTwilightAngle(nSunAngleDegrees)
    local nA = nSunAngleDegrees % 360.0
    local nTwilightIn  = SkyStudioDataStore.nParkTodCycleTwilightLength or 10.0
    local nTwilightOut = nSkyShaderTwilightDepthDegrees

    -- If user twilight is shorter than or equal to engine twilight, don't remap.
    if nTwilightIn <= nTwilightOut then
        return nA
    end

    local nDawn     = 0.0
    local nNoon     = 90.0
    local nDusk     = 180.0
    local nMidnight = 270.0
    local nNextDawn = 360.0

    -- DUSK → MIDNIGHT HALF (180..270)
    if nA >= nDusk and nA < nMidnight then
        local nDuskTwilightEndIn   = nDusk + nTwilightIn
        local nDuskTwilightEndOut  = nDusk + nTwilightOut

        -- Segment 1: dusk twilight [180, 180 + nTwilightIn] → [180, 180 + nTwilightOut]
        if nA < nDuskTwilightEndIn then
            return RemapRange(
                nA,
                nDusk,                 -- input start
                nDuskTwilightEndIn,    -- input end
                nDusk,                 -- output start
                nDuskTwilightEndOut    -- output end
            )
        end

        -- Segment 2: post-twilight night [180 + in, 270] → [180 + out, 270]
        return RemapRange(
            nA,
            nDuskTwilightEndIn,       -- input start
            nMidnight,                -- input end
            nDuskTwilightEndOut,      -- output start
            nMidnight                 -- output end
        )
    end

    -- MIDNIGHT → DAWN HALF (270..360)
    if nA >= nMidnight then
        local nPreDawnEndIn   = nNextDawn - nTwilightIn
        local nPreDawnEndOut  = nNextDawn - nTwilightOut

        -- Segment 3: pre-dawn night [270, 360 - in] → [270, 360 - out]
        if nA < nPreDawnEndIn then
            return RemapRange(
                nA,
                nMidnight,        -- input start
                nPreDawnEndIn,    -- input end
                nMidnight,        -- output start
                nPreDawnEndOut    -- output end
            )
        end

        -- Segment 4: dawn twilight [360 - in, 360] → [360 - out, 360]
        return RemapRange(
            nA,
            nPreDawnEndIn,       -- input start
            nNextDawn,           -- input end
            nPreDawnEndOut,      -- output start
            nNextDawn            -- output end
        )
    end

    -- Everything from 0..180 (dawn → noon → dusk) is untouched.
    return nA
end


----------------------------------------------------------------------
-- DEFAULTS FROM REMOVED TWEAKABLES (BAKED IN)
----------------------------------------------------------------------
local DEFAULT_BLEND_START          = 45
local DEFAULT_BLEND_END            = -1.5
local DEFAULT_SHADOW_FADE_START    = 0.5
local DEFAULT_SHADOW_FADE_END      = -0.5

local DEFAULT_SUN_HORIZON_ROT      = -2.641593
local DEFAULT_SUN_ZENITH_ROT       = -0.64
local DEFAULT_MOON_HORIZON_ROT     = 1.8
local DEFAULT_MOON_ZENITH_ROT      = 5.5

local USE_LINEAR_COLOURS           = true

----------------------------------------------------------------------
-- THE PATCH TABLE: CLEAN REIMPLEMENTATIONS
----------------------------------------------------------------------

local Patched = {}

----------------------------------------------------------------------
--  Init
----------------------------------------------------------------------
function Patched.Init(self, useParkTimeOfDay, sunH, sunZ, moonH, moonZ, sTimeOfDay, env)
  trace("DayNightCycle: Init" .. 'useParkTimeOfDay=' .. tostring(useParkTimeOfDay) ..
    ', sunH=' .. tostring(sunH) ..
    ', sunZ=' .. tostring(sunZ) ..
    ', moonH=' .. tostring(moonH) ..
    ', moonZ=' .. tostring(moonZ) ..
    ', sTimeOfDay=' .. tostring(sTimeOfDay))

  -- User controlled parameters - to be hooked up to UI later

  -- End user controlled parameters

  local tWorldAPIs = api.world.GetWorldAPIs()
  self.ParkAPI = tWorldAPIs.park

  -- trace('parkAPI' .. self.ParkAPI)

  -- Use baked defaults if nil
  self.nSunHorizonRotation = sunH or DEFAULT_SUN_HORIZON_ROT
  self.nSunZenithRotation  = sunZ or DEFAULT_SUN_ZENITH_ROT
  self.nMoonHorizonRotation = moonH or DEFAULT_MOON_HORIZON_ROT
  self.nMoonZenithRotation  = moonZ or DEFAULT_MOON_ZENITH_ROT

  -- Create light rig entity
  self.completionToken = api.entity.CreateRequestCompletionToken()
  self.lightRigRoot = api.entity.InstantiatePrefab("TransformPrefab", "DayNightCycle", self.completionToken, TransformQ.Identity)

  -- Parameter setter
  self.tCommonParameterSetter = CommonParameterSetter:new()
  self.tCommonParameterSetter:SetDefaultParameters()

  -- Compute sun & moon axes
  self:_CalculateSunRotationAxis()
  self:_CalculateMoonDirection()

  -- Light colours & intensities
  self.vSunLightColour  = self.tCommonParameterSetter:GetSunLightColour()
  self.nSunLightIntensity = self.tCommonParameterSetter:GetSunLightIntensity()
  self.vMoonLightColour = self.tCommonParameterSetter:GetMoonLightColour()
  self.nMoonLightIntensity = self.tCommonParameterSetter:GetMoonLightIntensity()

  -- Create primary & secondary directional lights
  local function MakeDirectional(name, colour, intensity, forward, complexity)
  return api.entity.InstantiatePrefab(
    "DirectionalLight",
    name,
    self.completionToken,
    TransformFromPosF(Vector3.Zero, forward),
    self.lightRigRoot,
    true,
    {
      Colour = colour,
      IsLinear = USE_LINEAR_COLOURS,
      Intensity = intensity,
      LightingComplexity = complexity
    }
  )
  end

  self.tLights = {
    Primary   = MakeDirectional("Primary",   self.vSunLightColour,  self.nSunLightIntensity, self.vSunDirAtNoon, "Global"),
    Secondary = MakeDirectional("Secondary", self.vMoonLightColour, self.nMoonLightIntensity, self.vMoonDir,   "DirectWithoutShadows")
  }

  -- Wait for light creation
  while not api.entity.HaveRequestsCompleted(self.completionToken) do
    coroutine.yield()
  end
  self.completionToken = nil
  

  -- Set initial light usage & fades
  api.lighting.SetDirectionalFade(self.tLights.Primary,   1)
  api.lighting.SetDirectionalFade(self.tLights.Secondary, 0)
  api.lighting.SetDirectionalUsage(self.tLights.Primary,   api.lighting.Sun)
  api.lighting.SetDirectionalUsage(self.tLights.Secondary, api.lighting.Moon)

  self.currentCycleDirection = 1
end

----------------------------------------------------------------------
--  Shutdown
----------------------------------------------------------------------
function Patched.Shutdown(self)
  api.entity.DestroyEntity(self.lightRigRoot)

  if self.tCommonParameterSetter then
    self.tCommonParameterSetter:Shutdown()
    self.tCommonParameterSetter = nil
  end

  self.tLights = nil
end

----------------------------------------------------------------------
--  Advance
----------------------------------------------------------------------
function Patched.Advance(self, dt)
  self:AdvanceTimeOfDay(dt)
end

----------------------------------------------------------------------
--  AdvanceTimeOfDay
----------------------------------------------------------------------
function Patched.AdvanceTimeOfDay(self, dt)
  local nHour, nMinute, nDayProp, nDawnDuskProp, isApparentTimeofDayOverriden = self.ParkAPI:GetTimeOfDayLighting()
  self.nDawnDuskProp = nDawnDuskProp

  self:UpdateLighting(self.nDawnDuskProp)
end

----------------------------------------------------------------------
--  UpdateLighting
--  Preserved Vanilla function
----------------------------------------------------------------------
function Patched.UpdateLighting(self, prop)
  if SkyStudioDataStore.bUseVanillaLighting then
    local frac = prop % 1
    frac = frac * frac * (3 - 2 * frac)
    local smoothProp = math.floor(prop) + frac

    -- Update sun direction
    local vSun = self.vSunDirAtNoon:RotatedAround(self.vSunRotationAxis, smoothProp * math.pi):Normalised()
    self.vSunDirNow = vSun

    local angle = RemapDawnDuskPropToAngle(smoothProp)

    local transProp = 1 - Linearstep(angle, DEFAULT_BLEND_END, math.max(DEFAULT_BLEND_END, DEFAULT_BLEND_START))
    local fadeProp  = 1 - Linearstep(angle, DEFAULT_SHADOW_FADE_END, math.max(DEFAULT_SHADOW_FADE_END, DEFAULT_SHADOW_FADE_START))

    -- Apply day/night parameters
    self.tCommonParameterSetter:ApplyDayNightParameters(transProp)

    -- Shadow fade split
    local sunDown = 0.01
    local moonDown = 0.04

    local sunMin = 0
    local sunMax = 0.5 - sunDown * 0.5
    local moonMin = 0.5 + moonDown * 0.5
    local moonMax = 1

    local sunFade = 1 - Linearstep(fadeProp, sunMin, sunMax)
    local moonFade = Linearstep(fadeProp, moonMin, moonMax)

    -- Usage swapping
    if fadeProp < 0.5 and not self.primaryLightIsSun then
      api.lighting.SetDirectionalUsage(self.tLights.Primary, api.lighting.Sun)
      api.transform.SetTransform(self.tLights.Primary, TransformFromPosF(Vector3.Zero, vSun))

      api.lighting.SetDirectionalUsage(self.tLights.Secondary, api.lighting.Moon)
      api.transform.SetTransform(self.tLights.Secondary, TransformFromPosF(Vector3.Zero, self.vMoonDir))

      self.primaryLightIsSun = true
    elseif fadeProp > 0.5 and self.primaryLightIsSun then
      api.lighting.SetDirectionalUsage(self.tLights.Primary, api.lighting.Moon)
      api.transform.SetTransform(self.tLights.Primary, TransformFromPosF(Vector3.Zero, self.vMoonDir))

      api.lighting.SetDirectionalUsage(self.tLights.Secondary, api.lighting.Sun)
      api.transform.SetTransform(self.tLights.Secondary, TransformFromPosF(Vector3.Zero, vSun))

      self.primaryLightIsSun = false
    end

    -- Apply fade + colour + transform
    local sunLight, moonLight
    if self.primaryLightIsSun then
      sunLight  = self.tLights.Primary
      moonLight = self.tLights.Secondary
    else
      sunLight  = self.tLights.Secondary
      moonLight = self.tLights.Primary
    end

    api.lighting.SetDirectionalFade(sunLight, sunFade)
    api.lighting.SetColour(sunLight, self.vSunLightColour, USE_LINEAR_COLOURS, self.nSunLightIntensity)
    api.transform.SetTransform(sunLight, TransformFromPosF(Vector3.Zero, vSun))

    api.lighting.SetDirectionalFade(moonLight, moonFade)
    api.lighting.SetColour(moonLight, self.vMoonLightColour, USE_LINEAR_COLOURS, self.nMoonLightIntensity)
    api.transform.SetTransform(moonLight, TransformFromPosF(Vector3.Zero, self.vMoonDir))
  else
    self:UpdateLightingFromUserParams()
  end
end

-- Set custom lighting from user parameters
function Patched.UpdateLightingFromUserParams(self)
  local nSunTimeOfDayDegrees = HoursToDegrees(SkyStudioDataStore.nUserSunTimeOfDay)

  if not SkyStudioDataStore.bUserOverrideSunTimeOfDay then
    nSunTimeOfDayDegrees = HoursToDegrees(self.ParkAPI:GetTimeOfDayLighting())
  end

  local nMoonPhaseDegrees = SkyStudioDataStore.nParkTodCycleMoonPhase
  if SkyStudioDataStore.bUserOverrideMoonPhase then
    nMoonPhaseDegrees = SkyStudioDataStore.nUserMoonPhase
  end

  -- Moonrise/Moonset "time of day" in degrees
  -- 
  -- A full 360 rotation of the moon around a viewer on earth is about 50 minutes longer than the sun
  -- So the sun's day is about 0.966 as long as a moon "day" (24 / 24.833)
  -- In reality, this is what causes the moon to phase
  -- 
  -- We don't have dynamic moon phasing for now, so just make the moon day slightly longer than the sun's day and apply static phase
  -- 
  local nMoonTimeOfDayDegrees = (nSunTimeOfDayDegrees * 0.966 + nMoonPhaseDegrees) % 360

  -- trace('UpdateLightingFromUserParams -- nSunTimeOfDayDegrees' .. tostring(nSunTimeOfDayDegrees) .. ' nMoonPhaseDegrees ' .. tostring(nMoonPhaseDegrees))

  -- Remap sun time of day agnle after sunset
  -- Because the sky shader's "twilight" feels short, this it he only way to make it longer afaik
  -- Only use this for the light's direction, not for the rest of the values
  local nRemappedTwilightSunDegrees = RemapTwilightAngle(nSunTimeOfDayDegrees)

  -- Convert to radians for vector math
  local nSunTimeOfDayRadians = DegreesToRadians(nRemappedTwilightSunDegrees)
  local nMoonTimeOfDayRadians = DegreesToRadians(nMoonTimeOfDayDegrees)

  -- Sun orientation switching: override vs from park / vanilla
  local vSunDir = nil
  if SkyStudioDataStore.bUserOverrideSunOrientation then
    -- User sun orientation
    vSunDir = CalculateUserSunDirection(
      DegreesToRadians(SkyStudioDataStore.nUserSunAzimuth),
      DegreesToRadians(SkyStudioDataStore.nUserSunLatitudeOffset),
      nSunTimeOfDayRadians
    ) 
  else 
    -- Vanilla sun orientation
    vSunDir = self.vSunDirAtNoon:RotatedAround(self.vSunRotationAxis, nSunTimeOfDayRadians):Normalised()
  end

  local vMoonDir = nil
  if SkyStudioDataStore.bUserOverrideMoonOrientation then
    vMoonDir = CalculateUserSunDirection(
    -- lock moon azimuth to sun azimuth and treat user setting as an offset, it's less frustrating this way
      DegreesToRadians((SkyStudioDataStore.nUserSunAzimuth + SkyStudioDataStore.nUserMoonAzimuth) % 360),
      DegreesToRadians(SkyStudioDataStore.nUserMoonLatitudeOffset),
      nMoonTimeOfDayRadians
    )
  else
    -- Because we have moonrise and moonset, we can just copy the sun's path and phase the moon along the same path
    -- Todo: apply a slight offset so they're not perfectly aligned
    vMoonDir = self.vSunDirAtNoon:RotatedAround(self.vSunRotationAxis, nMoonTimeOfDayRadians):Normalised()
  end

  -- Sun color and intensity
  local vSunColor       = Vector3:new(
                            SkyStudioDataStore.nUserSunColorR,
                            SkyStudioDataStore.nUserSunColorG,
                            SkyStudioDataStore.nUserSunColorB
                        )
  local nSunIntensity   = SkyStudioDataStore.nUserSunIntensity
  local bSunIsLinear    = USE_LINEAR_COLOURS
  if not SkyStudioDataStore.bUserOverrideSunColorAndIntensity then
    vSunColor = Vector3:new(
      SkyStudioDataStore.nParkTodCycleSunColorR,
      SkyStudioDataStore.nParkTodCycleSunColorG,
      SkyStudioDataStore.nParkTodCycleSunColorB
    )
    nSunIntensity = SkyStudioDataStore.nParkTodCycleSunIntensity
  end

  -- Moon color and intensity
  local vMoonColor      = Vector3:new(
                            SkyStudioDataStore.nUserMoonColorR,
                            SkyStudioDataStore.nUserMoonColorG,
                            SkyStudioDataStore.nUserMoonColorB
                        )
  local nMoonIntensity  = SkyStudioDataStore.nUserMoonIntensity
  local bMoonIsLinear   = USE_LINEAR_COLOURS
  if not SkyStudioDataStore.bUserOverrideMoonColorAndIntensity then
    vMoonColor = Vector3:new(
      SkyStudioDataStore.nParkTodCycleMoonColorR,
      SkyStudioDataStore.nParkTodCycleMoonColorG,
      SkyStudioDataStore.nParkTodCycleMoonColorB
    )
    nMoonIntensity = SkyStudioDataStore.nParkTodCycleMoonIntensity
  end

  -- Render Parameter day/night transition
  -- Divide by 100 here to make the UI slider more granular
  local renderParameterFade   = RemapDayNightFadeValue(SkyStudioDataStore.nUserDayNightTransition / 100.0)

  if not SkyStudioDataStore.bUserOverrideDayNightTransition then
    local lerpedDayNightTransition = LerpDayNightFadeByAngle(
      SkyStudioDataStore.nParkTodCycleDayNightTransitionDawn,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionNoon,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionDusk,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionMidnight,
      nSunTimeOfDayDegrees,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionCurve,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnEnd,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionDuskStart,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionDusk,
      SkyStudioDataStore.nParkTodCycleDayNightTransitionDawnStart
    )

    renderParameterFade = RemapDayNightFadeValue(lerpedDayNightTransition / 100.0)
  end

  self.tCommonParameterSetter:ApplyDayNightParameters(1 - renderParameterFade)

  -- Set sun and moon light fade values
  -- Fades sun and moon intensity in and out at dawn/dusk
  local sunFade               = SkyStudioDataStore.nUserSunFade
  local moonFade              = SkyStudioDataStore.nUserMoonFade

  if not SkyStudioDataStore.bUserOverrideSunFade then
    sunFade = LerpDayNightFadeByAngle(
      0.5,
      1,
      0.5,
      0,
      nSunTimeOfDayDegrees,
      1,
      SkyStudioDataStore.nParkTodCycleSunDawnFadeEnd,
      SkyStudioDataStore.nParkTodCycleSunDuskFadeStart,
      SkyStudioDataStore.nParkTodCycleSunDuskFadeEnd,
      SkyStudioDataStore.nParkTodCycleSunDawnFadeStart
    )
  end
    
  if not SkyStudioDataStore.bUserOverrideMoonFade then
    moonFade = LerpDayNightFadeByAngle(
      0.5,
      1,
      0.5,
      0,
      nMoonTimeOfDayDegrees,
      1,
      SkyStudioDataStore.nParkTodCycleMoonDawnFadeEnd,
      SkyStudioDataStore.nParkTodCycleMoonDuskFadeStart,
      SkyStudioDataStore.nParkTodCycleMoonDuskFadeEnd,
      SkyStudioDataStore.nParkTodCycleMoonDawnFadeStart
    )
  end
  
  -- We can apply a ground multiplier here because these fade values only affect light cast on the ground
  -- The sky is always lit using the base sun/moon intensity
  if SkyStudioDataStore.bUserOverrideSunColorAndIntensity then
    sunFade = sunFade * SkyStudioDataStore.nUserSunGroundMultiplier
  else
    sunFade = sunFade * SkyStudioDataStore.nParkTodCycleSunGroundMultiplier
  end
  if SkyStudioDataStore.bUserOverrideMoonColorAndIntensity then
    moonFade = moonFade * SkyStudioDataStore.nUserMoonGroundMultiplier
  else
    moonFade = moonFade * SkyStudioDataStore.nParkTodCycleMoonGroundMultiplier
  end
  
  -- Cutoff times in time of day cycle where shadow casting and main GI light switches between sun and moon
  -- This is now done by the sun's angle in degrees to improve flexibility of other parameters
  -- This could be put into the config but it's probably not necessary or useful
  local nPrimaryLightSwitchDawnDegrees = -0.5
  local nPrimaryLightSwitchDuskdegrees = 180.5
  local bIsDaytime = nSunTimeOfDayDegrees % 360 < nPrimaryLightSwitchDuskdegrees or nSunTimeOfDayDegrees % 360 > 360 + nPrimaryLightSwitchDawnDegrees

  -- Swap primary lightsource based on the sun angle
  if bIsDaytime and not self.primaryLightIsSun then
    api.lighting.SetDirectionalUsage(self.tLights.Primary, api.lighting.Sun)
    api.transform.SetTransform(self.tLights.Primary, TransformFromPosF(Vector3.Zero, vSunDir))

    api.lighting.SetDirectionalUsage(self.tLights.Secondary, api.lighting.Moon)
    api.transform.SetTransform(self.tLights.Secondary, TransformFromPosF(Vector3.Zero, vMoonDir))

    self.primaryLightIsSun = true
  elseif not bIsDaytime and self.primaryLightIsSun then
    api.lighting.SetDirectionalUsage(self.tLights.Primary, api.lighting.Moon)
    api.transform.SetTransform(self.tLights.Primary, TransformFromPosF(Vector3.Zero, vMoonDir))

    api.lighting.SetDirectionalUsage(self.tLights.Secondary, api.lighting.Sun)
    api.transform.SetTransform(self.tLights.Secondary, TransformFromPosF(Vector3.Zero, vSunDir))

    self.primaryLightIsSun = false
  end

  -- Apply fade + colour + transform
  local sunLight, moonLight
  if self.primaryLightIsSun then
    sunLight  = self.tLights.Primary
    moonLight = self.tLights.Secondary
  else
    sunLight  = self.tLights.Secondary
    moonLight = self.tLights.Primary
  end

  api.lighting.SetDirectionalFade(sunLight, sunFade)  
  api.lighting.SetColour(sunLight, vSunColor, bSunIsLinear, nSunIntensity)
  api.transform.SetTransform(sunLight, TransformFromPosF(Vector3.Zero, vSunDir))

  api.lighting.SetDirectionalFade(moonLight, moonFade)
  api.lighting.SetColour(moonLight, vMoonColor, bMoonIsLinear, nMoonIntensity)
  api.transform.SetTransform(moonLight, TransformFromPosF(Vector3.Zero, vMoonDir))
end

----------------------------------------------------------------------
--  INSTALL PATCHES
----------------------------------------------------------------------

function SkyStudioDayNightCycleManager:Setup()
  trace("Patching DayNightCycle")

  DayNightCycle.Init = Patched.Init
  DayNightCycle.Shutdown = Patched.Shutdown
  DayNightCycle.Advance = Patched.Advance
  DayNightCycle.AdvanceTimeOfDay = Patched.AdvanceTimeOfDay
  DayNightCycle.UpdateLighting = Patched.UpdateLighting
  DayNightCycle.UpdateLightingFromUserParams = Patched.UpdateLightingFromUserParams
end

function SkyStudioDayNightCycleManager:Init()
  trace("Init")

  -- Load config into data store
  local config = loadConfig()
  for k, v in pairs(config) do
    SkyStudioDataStore[k] = v
    SkyStudioDataStore.defaultValues[k] = v
  end
end

return SkyStudioDayNightCycleManager

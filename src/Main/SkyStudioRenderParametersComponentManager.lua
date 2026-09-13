local global = _G
local api = global.api
local debug = api.debug
local require = require

local RenderParametersComponent = require("components.render.renderparameterscomponent")

local SkyStudioDataStore = require("SkyStudioDataStore")

local trace = require("SkyStudioTrace")

local RenderParametersComponentManager = {}

local Patched = {}

function Patched.Advance(self, _nDeltaTime)
  -- trace("Patched RenderParametersComponent.Advance")

  local tMotionBlurParameters = nil
  if self.MotionBlurManager ~= nil then
    tMotionBlurParameters = (self.MotionBlurManager):GetRenderParameterCollection()
  end

  local bHasOverrideParameters = self.tEditorOverrideRenderParametersCollection ~= nil or tMotionBlurParameters ~= nil

  local sDebugLifecycle =
    tostring(self.tGlobalParameters ~= nil) .. ":" ..
    tostring(self.tCommittedParameters ~= nil) .. ":" ..
    tostring(self.tTransitionEntity ~= nil) .. ":" ..
    tostring(self.tOverrideParameters ~= nil)
  if self.sSkyStudioDebugLifecycle ~= sDebugLifecycle then
    self.sSkyStudioDebugLifecycle = sDebugLifecycle
    -- #region agent log
    debug.Trace(
      "[SkyStudio][DBG:e61100][H1_H3_H4_H5] Render.Advance.Lifecycle" ..
      " global=" .. tostring(self.tGlobalParameters ~= nil) ..
      " committed=" .. tostring(self.tCommittedParameters ~= nil) ..
      " transition=" .. tostring(self.tTransitionEntity ~= nil) ..
      " transitionId=" .. tostring(self.tTransitionEntity and self.tTransitionEntity.nEntityID) ..
      " transitionTimeLeft=" .. tostring(self.tTransitionEntity and self.tTransitionEntity.nTimeLeft) ..
      " overrideCollection=" .. tostring(self.tOverrideParameters ~= nil) ..
      " motionBlur=" .. tostring(tMotionBlurParameters ~= nil)
    )
    -- #endregion
  end

  local bHasDebugApply = false
  if not bHasDebugApply and self.tTransitionEntity ~= nil then
    (self.tTransitionEntity).nTimeLeft = (self.tTransitionEntity).nTimeLeft - _nDeltaTime
    if (self.tTransitionEntity).nTimeLeft <= 0 then
      self:CommitParameters((self.tTransitionEntity).nEntityID)
      self.tTransitionEntity = nil
    end
  end

  do
    if self.tGlobalParameters ~= nil then

      -- Get and apply weather parameters to global parameters
      local tWeatherRenderParameters = self.WeatherAPI:GetRenderParametersCollection()
      if tWeatherRenderParameters ~= nil then
        self.RenderParametersAPI:ApplyParametersTo(tWeatherRenderParameters, self.tGlobalParameters)
      end

      -- Get and apply committed parameters
      if self.tCommittedParameters ~= nil then
        self.RenderParametersAPI:ApplyParametersTo(self.tCommittedParameters, self.tGlobalParameters)
      end


      -- Get only the active render parameters based on enabled overrides
      local tActiveRenderParameters = SkyStudioDataStore:GetActiveRenderParameters()
      local tUserParameters = self.RenderParametersAPI:CreateParameterFromTable("SkyStudioUserParameters", tActiveRenderParameters)
      local tSunDisk = tActiveRenderParameters.Atmospherics.Lights.Sun.Disk
      local tMoonDisk = tActiveRenderParameters.Atmospherics.Lights.Moon.Disk
      local sDebugActive =
        tostring(SkyStudioDataStore.bUserOverrideAtmosphere) .. ":" ..
        tostring(SkyStudioDataStore.bUserOverrideSunDisk) .. ":" ..
        tostring(SkyStudioDataStore.bUserOverrideMoonDisk) .. ":" ..
        tostring(tSunDisk and tSunDisk.Size) .. ":" ..
        tostring(tSunDisk and tSunDisk.Intensity) .. ":" ..
        tostring(tMoonDisk and tMoonDisk.Size) .. ":" ..
        tostring(tMoonDisk and tMoonDisk.Intensity)
      if self.sSkyStudioDebugActive ~= sDebugActive then
        self.sSkyStudioDebugActive = sDebugActive
        -- #region agent log
        debug.Trace(
          "[SkyStudio][DBG:e61100][H2_H3_H4] Render.ActiveCollection" ..
          " created=" .. tostring(tUserParameters ~= nil) ..
          " atmosphereOverride=" .. tostring(SkyStudioDataStore.bUserOverrideAtmosphere) ..
          " sunDiskOverride=" .. tostring(SkyStudioDataStore.bUserOverrideSunDisk) ..
          " moonDiskOverride=" .. tostring(SkyStudioDataStore.bUserOverrideMoonDisk) ..
          " sunDiskSize=" .. tostring(tSunDisk and tSunDisk.Size) ..
          " sunDiskIntensity=" .. tostring(tSunDisk and tSunDisk.Intensity) ..
          " moonDiskSize=" .. tostring(tMoonDisk and tMoonDisk.Size) ..
          " moonDiskIntensity=" .. tostring(tMoonDisk and tMoonDisk.Intensity)
        )
        -- #endregion
      end
      if tUserParameters ~= nil then
        self.RenderParametersAPI:ApplyParametersTo(tUserParameters, self.tGlobalParameters)
      end

      if bHasOverrideParameters then
        if tMotionBlurParameters ~= nil then
          (self.RenderParametersAPI):ApplyParametersTo(tMotionBlurParameters, self.tOverrideParameters)
        end
        if self.tEditorOverrideRenderParametersCollection ~= nil then
          -- With editor override parameters
          (self.RenderParametersAPI):ApplyParametersTo(self.tEditorOverrideRenderParametersCollection, self.tOverrideParameters)
        end
        -- non-editor override parameters ... ???
        (self.RenderParametersAPI):ApplyParameters(self.tOverrideParameters)
      end

      if self.tTransitionEntity ~= nil and not bHasDebugApply then
        local nBlendFactor = 1 - (self.tTransitionEntity).nTimeLeft / (self.tEntityTransitionTimes)[(self.tTransitionEntity).nEntityID]

        if bHasOverrideParameters then
          self.RenderParametersAPI:BlendParametersTo(self.tGlobalParameters, (self.tTransitionEntity).tParameters, self.tOverrideParameters, nBlendFactor)
        else
          self.RenderParametersAPI:BlendParameters(self.tGlobalParameters, (self.tTransitionEntity).tParameters, nBlendFactor)
        end

      elseif bHasOverrideParameters then
        self.RenderParametersAPI:ApplyParametersTo(self.tGlobalParameters, self.tOverrideParameters)
      else
        self.RenderParametersAPI:ApplyParameters(self.tGlobalParameters)
      end
      
    end

    self.DebugApplyGlobals()
  end
end

function Patched.SetEditorOverrideRenderParametersCollection(self, _parameterCollection)
  self.tEditorOverrideRenderParametersCollection = _parameterCollection
end


function RenderParametersComponentManager:Setup()
  trace("Patching RenderParametersComponent")

  -- #region agent log
  debug.Trace(
    "[SkyStudio][DBG:e61100][H1_H5] RenderManager.Setup" ..
    " originalAdvance=" .. tostring(RenderParametersComponent.Advance)
  )
  -- #endregion

  RenderParametersComponent.Advance = Patched.Advance
  RenderParametersComponent.SetEditorOverrideRenderParametersCollection = Patched.SetEditorOverrideRenderParametersCollection
end

function RenderParametersComponentManager:Init()
  -- trace("Init")
end

return RenderParametersComponentManager

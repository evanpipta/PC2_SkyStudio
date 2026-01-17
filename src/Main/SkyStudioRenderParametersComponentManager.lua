local global = _G
local api = global.api
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

  RenderParametersComponent.Advance = Patched.Advance
  RenderParametersComponent.SetEditorOverrideRenderParametersCollection = Patched.SetEditorOverrideRenderParametersCollection
end

function RenderParametersComponentManager:Init()
  -- trace("Init")
end

return RenderParametersComponentManager

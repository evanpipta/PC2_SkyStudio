local trace = require('SkyStudioTrace')

local function loadConfig(path)
  path = path or "Win64\\ovldata\\Mod_SkyStudio\\Config.lua"

  -- sandbox: treat config as data-only assignments into env
  local env = {}
  setmetatable(env, {
    __index = function() return nil end,
    __newindex = rawset,
  })

  local chunk, err = loadfile(path, "t", env)
  if not chunk then
    trace("Failed to load config: " .. tostring(err))
    return {}
  end
  
  local ok, runErr = pcall(chunk)
  if not ok then
    trace("Error executing config: " .. tostring(runErr))
    return {}
  end

  return env
end

return loadConfig

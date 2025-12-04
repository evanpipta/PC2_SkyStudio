local global = _G
local api = global.api
local debug = api.debug

local function logTable(t, indent, visited, depth, maxDepth)
    indent   = indent or 2
    depth    = depth or 0
    maxDepth = maxDepth or 4          -- keep this modest
    visited  = visited or {}

    if visited[t] then
        -- debug.Trace(("[SkyStudio]%s<cycle> %s"):format(
        --     string.rep("  ", indent),
        --     tostring(t)
        -- ))
        return
    end
    visited[t] = true

    local prefix = string.rep("  ", indent)

    if depth > maxDepth then
        debug.Trace(("[SkyStudio]%s<max depth reached> %s"):format(
            prefix,
            tostring(t)
        ))
        return
    end

    for k, v in pairs(t) do
        if type(v) == "table" then
            debug.Trace("[SkyStudio]" .. prefix .. tostring(k) .. " = {")
            logTable(v, indent + 1, visited, depth + 1, maxDepth)
            debug.Trace("[SkyStudio]" .. prefix .. "}")
        else
            debug.Trace("[SkyStudio]" .. prefix .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

-- Msg can be a string or a table
local trace = function (msg)
    if type(msg) == "string" then
        debug.Trace("[SkyStudio] " .. msg)
    elseif type(msg) == "table" then
        debug.Trace("[SkyStudio] {")
        logTable(msg)
        debug.Trace("[SkyStudio] }")
    else
        debug.Trace("[SkyStudio] attempted to debug.Trace invalid type: " .. tostring(type(msg)))
    end
end


return trace

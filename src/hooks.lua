local config = require(script.Parent.GlobalConfig).get()
local deepEqual = require(script.Parent.deepEqual)

local currentComponent = nil
local hookIndex = 1
local hookData = {}

local function setupHooks(component)
    currentComponent = component
end

local function teardownHooks(component)
    currentComponent = nil
    hookIndex = 1
end

local function useState(initialValue)
    assert(currentComponent)
    local current = currentComponent
    local state
    if hookData[hookIndex] ~= nil then
        state = hookData[hookIndex]
    else
        state = initialValue
    end

    local myHookIndex = hookIndex
    local function setState(newState)
        local current2 = current
        print(current2)
        hookData[myHookIndex] = newState
    end

    hookIndex = hookIndex + 1

    return state, setState
end

--[[
    Runs after the render has completed, optionally if dependencies have changed.
]]
local function useEffect(callback, deps)
    assert(currentComponent)
	if config.typeChecks then
        assert(typeof(callback) == "function", "useEffect callback must be a function")

        -- TODO: Check it's array like
        assert(typeof(deps) == "table" or deps == nil, "useEffect dependencies must be a table or nil")
	end

    local oldDeps = hookData[hookIndex]

    if deps == nil or oldDeps == nil or not deepEqual(oldDeps, deps) then
        callback() -- TODO: Call this after the render
    end

    hookIndex = hookIndex + 1
end

local function useMemo(callback, deps)
    assert(currentComponent)
	if config.typeChecks then
        assert(typeof(callback) == "function", "useMemo callback must be a function")

        -- TODO: Check it's array like
        assert(typeof(deps) == "table" or deps == nil, "useMemo dependencies must be a table or nil")
    end

    hookData[hookIndex] = hookData[hookIndex] or {}

    local myHookData = hookData[hookIndex]

    local oldDeps = myHookData.deps

    local result

    if deps == nil or oldDeps == nil or not deepEqual(oldDeps, deps) then
        result = callback()
        myHookData.deps = deps
        myHookData.memo = result
    else
        result = myHookData.memo
    end

    hookIndex = hookIndex + 1

    return result
end

--[[
    Returns a memoized callback that only changes if the deps change
]]
local function useCallback(callback, deps)
    return useMemo(function()
        return callback
    end, deps)
end

local function useRef(initialValue)
    assert(currentComponent)
    if hookData[hookIndex] == nil then
        local myHookIndex = hookIndex
        hookData[hookIndex] = {
            current = initialValue,
            -- Purely to match the newer Roact API.
            getValue = function()
                return hookData[myHookIndex].current
            end
        }
    end

    hookIndex = hookIndex + 1

    return hookData[hookIndex]
end

return {
    -- Internal API
    setupHooks = setupHooks,
    teardownHooks = teardownHooks,
    getInternalState = getInternalState

    -- Public API
    useCallback = useCallback,
    useEffect = useEffect,
    useMemo = useMemo,
    useState = useState,
    useRef = useRef,
}
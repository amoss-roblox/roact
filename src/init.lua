--[[
	Packages up the internals of Roact and exposes a public API for it.
]]

local GlobalConfig = require(script.GlobalConfig)
local createReconciler = require(script.createReconciler)
local createReconcilerCompat = require(script.createReconcilerCompat)
local RobloxRenderer = require(script.RobloxRenderer)
local hooks = require(script.hooks)
local strict = require(script.strict)
local Binding = require(script.Binding)

local robloxReconciler = createReconciler(RobloxRenderer)
local reconcilerCompat = createReconcilerCompat(robloxReconciler)

local Roact = strict {
	Component = require(script.Component),
	createElement = require(script.createElement),
	createFragment = require(script.createFragment),
	oneChild = require(script.oneChild),
	PureComponent = require(script.PureComponent),
	None = require(script.None),
	Portal = require(script.Portal),
	createRef = require(script.createRef),
	createBinding = Binding.create,
	joinBindings = Binding.join,
	createContext = require(script.createContext),

	Change = require(script.PropMarkers.Change),
	Children = require(script.PropMarkers.Children),
	Event = require(script.PropMarkers.Event),
	Ref = require(script.PropMarkers.Ref),

	mount = robloxReconciler.mountVirtualTree,
	unmount = robloxReconciler.unmountVirtualTree,
	update = robloxReconciler.updateVirtualTree,

	reify = reconcilerCompat.reify,
	teardown = reconcilerCompat.teardown,
	reconcile = reconcilerCompat.reconcile,

	setGlobalConfig = GlobalConfig.set,

	Hooks = {
		useState = hooks.useState,
		useCallback = hooks.useCallback,
		useMemo = hooks.useMemo,
		useEffect = hooks.useEffect,
		useRef = hooks.useRef,
	},

	-- APIs that may change in the future without warning
	UNSTABLE = {
	},
}

return Roact
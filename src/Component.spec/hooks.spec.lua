return function()

    FOCUS()

    local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
    local Type = require(script.Parent.Parent.Type)
    local Component = require(script.Parent.Parent.Component)


    local Hooks = require(script.Parent.Parent).Hooks
    local useState = Hooks.useState
    local useEffect = Hooks.useEffect
    local useMemo = Hooks.useMemo
    local useCallback = Hooks.useCallback
    local useRef = Hooks.useRef

	local noopReconciler = createReconciler(NoopRenderer)

    describe("throws if calling from a non-functional component", function()

        local function assertThrowsInClassComponentRender(render)

            local Foo = Component:extend("Foo")

            Foo.render = render

            local element = createElement(Foo)
            local hostParent = nil
            local key = "Foo Test"

            expect(function()
                noopReconciler.mountVirtualNode(element, hostParent, key)
            end).to.throw()
        end

        it("useState", function()
            assertThrowsInClassComponentRender(function()
                useState(1)
            end)
        end)

        it("useRef", function()
            assertThrowsInClassComponentRender(function()
                useRef(1)
            end)
        end)

        it("useEffect", function()
            assertThrowsInClassComponentRender(function()
                useEffect(function() end)
            end)
        end)

        it("useMemo", function()
            assertThrowsInClassComponentRender(function()
                useMemo(function()
                    return 1
                end)
            end)
        end)
    end)

    describe("useState", function()
        -- TODO Mirror test cases from setState.spec.lua

        local hostParent = nil
        local key = "Test"

        itFOCUS("updates state with value", function()
            local setter

            local spy = createSpy()

            local MyComponent = function()
                local count, setCount = useState(1)

                setter = setCount

                spy.value(count)

                return createElement("TextLabel", {
                    Text = "Count is " .. tostring(count)
                })
            end

            local tree = noopReconciler.mountVirtualTree(createElement(MyComponent), hostParent, key)

            setter(2)

            noopReconciler.updateVirtualTree(tree, createElement(MyComponent))

            spy:assertCalledWith(1, 2)
        end)

        it("with multiple usages in children of same component type, values are not aliased", function()
            local childSpies = {}

            local MyChild = function(props)
                local count, setCount = useState(props.initial)

                if childSpies[props.id] == nil then
                    childSpies[props.id] = {
                        spy = createSpy(),
                        setCount = setCount,
                    }
                end

                childSpies[props.id].spy.value(count)

                return nil
            end

            local MyComponent = function()
                local count, setCount = useState(1)

                return createElement("Frame", {}, {
                    Child1 = MyChild({
                        id = 1,
                        initial = 1,
                    }),
                    Child2 = MyChild({
                        id = 2,
                        initial = 10,
                    }),
                })
            end

            local tree = noopReconciler.mountVirtualTree(createElement(MyComponent), hostParent, key)

            assert(#childSpies == 2)

            childSpies[1].spy:assertCalledWith(1)
            childSpies[2].spy:assertCalledWith(10)

            childSpies[1].setCount(2)

            noopReconciler.updateVirtualTree(tree, createElement(MyComponent))

            childSpies[1].spy:assertCalledWith(1, 2)
            childSpies[2].spy:assertCalledWith(10)
        end)

        -- TODO: Disallow changing order of hooks

        -- TODO: Reset hooks between tests

        -- TODO unmount/mount
    end)

end
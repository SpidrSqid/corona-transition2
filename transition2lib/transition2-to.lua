--[[

TODO: doc

Markus Ranner 2017

--]]

--[[
x1, y1, x2, y2, x3, y3, x4, y4 (optional)
Numbers. Applies only if the target is a RectPath, applicable to a ShapeObject. These properties control the quadrilateral distortion of the target.
[filterParameter] (optional)
Number. Applicable only if the target is a fill.effect applied to a ShapeObject. In this case, [filterParameter] indicates an effect property associated with the specific filter effect, for example ShapeObject.fill.effect.intensity. See the Filters, Generators, Composites guide for which filter parameters apply to each filter.
--]]

local utils = require("utils")

local SIMPLE_PROPS = { "x", "y", "rotation", "alpha", "xScale", "yScale", "width", "height", "size" }

return {
    getStartValue = function(displayObject, params)
        local startValue = {}
        
        for i = 1, #SIMPLE_PROPS do
            local propName = SIMPLE_PROPS[i]
            if (params[propName] ~= nil) then
                startValue[propName] = displayObject[propName] or 0
            end
        end
        
        -- For rect paths, the (x1,y1)...(x4,y4) are also possible to change
        if (utils.isRectPath(displayObject)) then
            for i = 1, 4 do
                local xi = "x" .. i
                if (params[xi]) then
                    startValue[xi] = displayObject.path[xi]
                end
                local yi = "y" .. i
                if (params[yi]) then
                    startValue[yi] = displayObject.path[yi]
                end
            end
        end
        
        return startValue
    end,

    getEndValue = function(displayObject, params)
        local endValue = {}
        
        for i = 1, #SIMPLE_PROPS do
            local propName = SIMPLE_PROPS[i]
            if (params[propName] ~= nil) then
                endValue[propName] = (params.delta and ((displayObject[propName] or 0) + params[propName]) or params[propName])
            end
        end
        
        -- For rect paths, the (x1,y1)...(x4,y4) are also possible to change
        if (utils.isRectPath(displayObject)) then
            for i = 1, 4 do
                local xi = "x" .. i
                if (params[xi]) then
                    endValue[xi] = (params.delta and (displayObject.path[xi] + params[xi]) or params[xi])
                end
                local yi = "y" .. i
                if (params[yi]) then
                    endValue[yi] = (params.delta and (displayObject.path[yi] + params[yi]) or params[yi])
                end
            end
        end
        
        return endValue        
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        -- First, apply simple props to display object
        for i = 1, #SIMPLE_PROPS do
            local propName = SIMPLE_PROPS[i]
            if (value[propName] ~= nil) then
                displayObject[propName] = value[propName]
            end
        end
        
        -- Then handle the path nodes
        for i = 1, 4 do
            local xi = "x" .. i
            if (value[xi] ~= nil) then
                displayObject.path[xi] = value[xi]
            end
            local yi = "y" .. i
            if (value[yi] ~= nil) then
                displayObject.path[yi] = value[yi]
            end
        end
    end,
 
    getParams = function(displayObject, params)                
        params.time = params.time or 500
        params.transition = params.transition or easing.linear
        params.delta = (params.delta == true)            
    
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        -- This will cancel the transition if the display object appears to no longer exist
        return displayObject.x == nil
    end
}
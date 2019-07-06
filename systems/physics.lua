--  Copyright 2019 sayaks

--  This file is part of SimplePlatformer.

--  SimplePlatformer is free software: you can redistribute it and/or modify
--  it under the terms of the GNU Affero General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

--  SimplePlatformer is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Affero General Public License for more details.

--  You should have received a copy of the GNU Affero General Public License
--  along with SimplePlatformer.  If not, see <https://www.gnu.org/licenses/>.

System = require "system"

local Module = {}

Module.constants = {
    scale = 1,
    gravity = 10
}

local function bump(pos1, pos2, len1, len2)
    local mid = pos1 + len1 / 2
    local otherMid = pos2 + len2 / 2

    if mid < otherMid then
        return pos2 - len1
    else
        return pos2 + len2
    end
end

Module.Move = System.new(
    "move",
    {"colliders", "x", "y", "velX", "velY", "width", "height"},
    function (obj, dt)
        local newX = obj.x + obj.velX * dt * Module.constants.scale
        local newY = obj.y + obj.velY * dt * Module.constants.scale

        local coll = obj.colliders:check(obj, newX, newY)

        if coll then
            local xColl = obj.colliders:check(obj, newX, obj.y)
            local yColl = obj.colliders:check(obj, obj.x, newY)

            if xColl == nil and yColl == nil then
                xColl = coll
                yColl = coll
            end

            if xColl then
                if obj.state ~= nil then
                    if xColl.x < obj.x then
                        obj.state:tryTransition("collide wall left")
                        obj.velX = -1
                    else
                        obj.state:tryTransition("collide wall right")
                        obj.velX = 1
                    end
                else 
                    obj.velX = 0
                end


                newX = bump(obj.x, xColl.x, obj.width, xColl.width)
            end

            if yColl then
                if newY > obj.y and obj.state ~= nil then
                    obj.state:tryTransition("collide ground")
                end

                if newY < obj.y then
                    obj.velY = 0
                end

                newY = bump(obj.y, yColl.y, obj.height, yColl.height)
            end
        end

        if newY > obj.y and obj.state ~= nil then
            obj.state:tryTransition("leave ground")
        end

        if obj.state ~= nil then
            local state = obj.state:getState()

            if state == "wallslideleft" and newX < obj.x then
                obj.state:tryTransition("leave wall")
            elseif state == "wallslideright" and newX > obj.x then
                obj.state:tryTransition("leave wall")                
            end
        end

        obj.x = newX
        obj.y = newY
    end
)

Module.Gravity = System.new(
    "gravity",
    {"velY"},
    function (obj, dt)
        if obj.state ~= nil then
            local state = obj.state:getState()
            if state == "float" then
                assert(obj.floatModifier ~= nil)

                obj.velY = obj.velY + Module.constants.gravity * dt * Module.constants.scale * obj.floatModifier            
            elseif state == "fall" then
                obj.velY = obj.velY + Module.constants.gravity * dt * Module.constants.scale
            elseif state == "ground" then
                obj.velY = 1
            elseif state == "wallslideleft" or state == "wallslideright" then
                assert(obj.wallFriction ~= nil)

                obj.velY = obj.velY + Module.constants.gravity * dt * Module.constants.scale
                obj.velY = obj.velY * math.pow(1 - obj.wallFriction, dt)
            end
        else
            obj.velY = obj.velY + Module.constants.gravity * dt * Module.constants.scale
        end
    end
)

return Module
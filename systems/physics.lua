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
                newX = bump(obj.x, xColl.x, obj.width, xColl.width)
            end

            if yColl then
                newY = bump(obj.y, yColl.y, obj.height, yColl.height)
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
        local realGravity = Module.constants.gravity
        if obj.state ~= nil and obj.state:getState() == "float" then
            assert(obj.floatModifier ~= nil)
            realGravity = realGravity * obj.floatModifier
        end

        obj.velY = obj.velY + realGravity * dt * Module.constants.scale
    end
)

return Module
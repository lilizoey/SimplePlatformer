--- A very basic Collision Detection library that only supports square colliders.

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

local World = {}
World.__index = World

--- Create a new World to contain the colliders.
-- @return a World object
function World.init()
    local self = setmetatable({}, World)
    self.objects = {}
    return self
end

--- Register a new object to be collidable in the world.
-- The object must have an x, y, width, and height field.
-- @param object A collidable object.
function World.register(self, object)
    table.insert(self.objects, object)
end

--- Check if two objects collide
function collide(object, other)
    return 
        object.x < other.x + other.width and
        object.x + object.width > other.x and
        object.y + object.height > other.y and
        object.y < other.y + other.height
end

--- Check if the object would collide with something at a new position.
-- @param object A collidable object
-- @param x The x-position to check collision at
-- @param y The y-position to check collision at
-- @return the object it collides with, nil if no collision
function World.check(self, object, x, y)
    local inner = {["x"] = x, ["y"] = y, ["width"] = object.width, ["height"] = object.height}
    for i, other in ipairs(self.objects) do
        if object ~= other and collide(inner, other) then
            return other
        end
    end

    return nil
end

return World
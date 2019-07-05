--- A very basic system library, as in a system from ecs. 

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

System = {}
System.__index = System

function System.new(name, components, func, ...)
    local self = setmetatable({}, System)
    self.name = name
    self.components = components
    self.func = func
    self.extra = {...}
    return self
end

function System.register(self, obj)
    for i, val in ipairs(self.components) do
        if obj[val] == nil then
            error("cannot register a " .. self.name .. " entity without " .. val)
        end
    end

    for i, val in ipairs(self.extra) do
        val(obj)
    end

    table.insert(self, obj)
end

function System.deregister(self, obj)
    error("not implemented properly")
    table.remove(self, obj)
end

function System.run(self, ...)
    for i, val in ipairs(self) do
        self.func(val, ...)
    end
end

return System
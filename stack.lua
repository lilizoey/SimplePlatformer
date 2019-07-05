--- A very basic Stack library 

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

Stack = {}
Stack.__index = Stack

function Stack.new()
    local self = setmetatable({}, Stack)
    return self
end

function Stack.isEmpty(self)
    return #self == 0
end

function Stack.push(self, val)
    table.insert(self, val)
end

function Stack.peek(self)
    return self[#self]
end

function Stack.pop(self)
    if self:isEmpty() then
        return nil
    else
        local val = self:peek()
        self[#self] = nil
        return val
    end
end

return Stack
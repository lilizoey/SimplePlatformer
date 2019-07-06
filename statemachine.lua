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
Stack = require "stack"

StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new()
    local self = setmetatable({}, StateMachine)
    self.currentState = 0
    self.states = {}
    self.transitions = {}
    return self
end

function StateMachine.setState(self, stateIndex)
    if stateIndex < 1 or stateIndex > #self.states then
        error("invalid state")
    end

    self.currentState = stateIndex
end

function StateMachine.addState(self, state)
    table.insert(self.states, state)
    table.insert(self.transitions, {})
end

function StateMachine.addTransition(self, fromStateID, toStateID, symbol)
    self.transitions[fromStateID][symbol] = toStateID
end

function StateMachine.tryTransition(self, symbol)
    local transition = self.transitions[self.currentState][symbol]

    if transition == nil then
        return false
    end

    self.currentState = transition

    return true
end

function StateMachine.indexOf(self, state)
    for i,v in ipairs(self.states) do
        if v == state then
            return i
        end
    end

    return nil
end

function StateMachine.getState(self)
    return self.states[self.currentState]
end

return StateMachine
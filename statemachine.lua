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
    self.stack = Stack.new()
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

function StateMachine.addTransition(self, fromStateID, toStateID, symbol, pop, push)
    local transition = {
        to = toStateID,
        pop = pop,
        push = push
    }
    self.transitions[fromStateID][symbol] = transition
end

function StateMachine.tryTransition(self, symbol)
    local transition = self.transitions[self.currentState][symbol]
    if transition = nil then
        return false
    end

    if transition.pop ~= nil and self.stack:peek() ~= transition.pop then
        return false
    elseif transition.pop ~= nil then
        self.stack:pop()
    end

    if transition.push ~= nil then
        self.stack:push(transition.push)
    end

    self.currentState = transition.to

    return true
end

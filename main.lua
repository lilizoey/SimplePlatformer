--  Copyright 2019 sayaks

--  This file is part of SimplePlatformer.

--  SimplePlatformer is free software: you can redistribute it and/or modify
--  it under the terms of the GNU Affero General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any    later version.

--  SimplePlatformer is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Affero General Public License for more details.

--  You should have received a copy of the GNU Affero General Public License
--  along with SimplePlatformer.  If not, see <https://www.gnu.org/licenses/>.

-- imports

World = require "collision"
GameState = require "gamestate"
System = require "system"

Player = require "player"

Physics = require "systems.physics"
Control = require "systems.control"

-- testing

testState = GameState.new()
GameState.stateStack:push(testState)

-- constants

WORLD = World.init()
PHYSICS_SCALE = 5
GRAVITY = 9.81
GROUND_LEVEL = 500

-- helpers

function verifyHeldKey(obj)
    if type(obj.heldKey) ~= "table" then
        error("heldkey must be a table")
    end
end

--- Finds first occurence of val
function linearFind(t, val)
    for i, v in ipairs(t) do
        if v == val then
            return i
        end
    end
    return nil
end

-- main

myObj = Player.new(20, 20, 20, 40, 40, 2)
myObj.x = 100

myObj.colliders = WORLD

wall = {}

wall.width = 200
wall.height = 20
wall.x = 50
wall.y = 450

Physics.constants.scale = 5

Physics.Gravity:register(myObj)
Physics.Move:register(myObj)

Control.JumpHandler:register(myObj)
Control.InputHandler:register(myObj)
Control.Movement:register(myObj)

WORLD:register(wall)

function testState.update(dt)
    Physics.Move:run(dt)
    Physics.Gravity:run(dt)
    Control.JumpHandler:run()
    Control.Movement:run(dt)
end

function testState.draw()
    love.graphics.rectangle("fill", myObj.x, myObj.y, myObj.width, myObj.height)
    love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
end

function testState.keypressed(key, scancode, isrepeat)
    Control.InputHandler:run(key, true)
end

function testState.keyreleased(key, scancode)
    Control.InputHandler:run(key, false)
end
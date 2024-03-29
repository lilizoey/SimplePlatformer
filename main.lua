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

Walls = {}

local function createWall(x1, y1, x2, y2)
    wall = {}

    wall.width = x2 - x1
    wall.height = y2 - y1
    wall.x = x1
    wall.y = y1

    table.insert(Walls, wall)
    WORLD:register(wall)
end

myObj = Player.new(20, 20, 20, 40, 40, 2)
myObj.x = 100

myObj.colliders = WORLD

Physics.constants.scale = 5

Physics.Gravity:register(myObj)
Physics.Move:register(myObj)

Control.JumpHandler:register(myObj)
Control.InputHandler:register(myObj)
Control.Movement:register(myObj)

function testState.load()

    createWall(0, love.graphics.getHeight(), love.graphics.getWidth(), love.graphics.getHeight() + 10)
    createWall(100, love.graphics.getHeight() - 100, 120, love.graphics.getHeight())


end

function testState.update(dt)
    Player.DataHandler:run()
    Control.Movement:run(dt)
    Control.JumpHandler:run()
    Physics.Gravity:run(dt)
    Physics.Move:run(dt)
end

function testState.draw()
    love.graphics.rectangle("fill", myObj.x, myObj.y, myObj.width, myObj.height)
    for i, wall in ipairs(Walls) do
        love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
    end
    love.graphics.print(myObj.state:getState(), 50, 20)
end

function testState.keypressed(key, scancode, isrepeat)
    Control.InputHandler:run(key, true)
end

function testState.keyreleased(key, scancode)
    Control.InputHandler:run(key, false)
end
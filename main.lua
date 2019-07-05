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

-- imports

World = require "collision"
GameState = require "gamestate"
System = require "system"

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

-- gravity

Gravity = System.new(
    "gravity",
    {"velY"},
    function (obj, dt)
        obj.velY = obj.velY + GRAVITY * dt * PHYSICS_SCALE
    end
)

-- move

MovableCollection = {}

function MovableCollection.register(obj)
--    if obj.keymap
end

-- ground

Ground = System.new(
    "ground",
    {"x", "y", "velY", "height", "jumpCount", "hasCollided", "floorCollider"},
    function (obj)
        local groundLevel = love.graphics.getHeight() 

        if obj.y + obj.height >= groundLevel then
            obj.y = groundLevel - obj.height
            obj.jumpCount = 0
        elseif obj.hasCollided and WORLD:check(floorCollider, obj.x, obj.y + 1) then
            obj.velY = 0
            obj.jumpCount = 0
        end
    end
)

-- move controllerS

MoveController = System.new(
    "move controller",
    {"heldKey", "velX", "movementSpeed"},
    function (obj, dt)
        if not obj.heldKey.left == nil then 
            print("left: " .. obj.heldKey.left)
        end
        if obj.heldKey.left and obj.velX > -obj.movementSpeed then
            obj.velX = obj.velX - obj.movementSpeed * dt * PHYSICS_SCALE
        elseif obj.heldKey.right and obj.velX < obj.movementSpeed then
            obj.velX = obj.velX + obj.movementSpeed * dt * PHYSICS_SCALE
        end
    end,
    verifyHeldKey
)

JumpController = System.new(
    "jump controller",
    {"velY", "jumpCount", "maxJumps", "jumpHeight"},
    function (obj, key)
        if key ~= "up" then return end

        if obj.jumpCount >= obj.maxJumps then return end

        obj.velY = -obj.jumpHeight
        obj.jumpCount = obj.jumpCount + 1
        obj.hasJumped = true
    end
)

function walljump(obj, sign)
    obj.velY = -obj.jumpHeight
    obj.velX = obj.jumpHeight * sign
end

WallJumpController = System.new(
    "walljump controller",
    {"hasCollided", "x", "velX", "velY"},
    function (obj, key)
        if not obj.hasCollided then return end

        if key ~= "up" then return end

        local right = WORLD:check(obj, obj.x + 1, obj.y)
        local left = WORLD:check(obj, obj.x - 1, obj.y)

        if right then 
            walljump(obj, -1)
        end

        if left then
            walljump(obj, 1)
        end
    end
)


-- mover

Mover = System.new(
    "mover",
    {"x", "y", "velX", "velY", "hasCollided"},
    function (obj, dt)

        if not obj.hasCollided then
            obj.x = obj.x + obj.velX * dt * PHYSICS_SCALE
            obj.y = obj.y + obj.velY * dt * PHYSICS_SCALE
        else
            if WORLD:check(obj, obj.x + obj.velX * dt * PHYSICS_SCALE, obj.y) then
                obj.velX = 0
            else
                obj.x = obj.x + obj.velX * dt * PHYSICS_SCALE
            end

            if WORLD:check(obj, obj.x, obj.y + obj.velY * dt * PHYSICS_SCALE) then
                obj.velY = 0
            else
                obj.y = obj.y + obj.velY * dt * PHYSICS_SCALE
            end
        end
    end
)

AirFriction = System.new(
    "air friction",
    {"velX", "velY", "airResistance"},
    function (obj, dt)
        obj.velX = obj.velX * (1 - obj.airResistance * dt)
        obj.velY = obj.velY * (1 - obj.airResistance * dt)
    end
)

-- collision handling

CollisionHandler = System.new(
    "collision handler",
    {"x", "y", "height", "width", "velX", "velY", "hasCollided"},
    function (obj, dt)
        local collision = WORLD:check(obj, obj.x + obj.velX * dt * PHYSICS_SCALE, obj.y + obj.velY * dt * PHYSICS_SCALE)
        if not collision then 
            obj.hasCollided = false
        else
            obj.hasCollided = true
        end
    end
)

-- key handling

HeldKeyHandler = System.new(
    "held key handler",
    {"heldKey"},
    function (obj, key, press)
        obj.heldKey[key] = press
    end,
    verifyHeldKey
)

-- main

myObj = {}

myObj.velX = 0
myObj.velY = 0
myObj.x = 100
myObj.y = 0
myObj.height = 20
myObj.width = 20
myObj.jumpCount = 0
myObj.maxJumps = 2
myObj.jumpHeight = 40
myObj.movementSpeed = 40
myObj.hasJumped = false
myObj.hasCollided = false
myObj.airResistance = 0.90
myObj.heldKey = {}

floorCollider = {
    width = 10,
    height = 20
}

myObj.floorCollider = floorCollider


wall = {}

wall.width = 20
wall.height = 150
wall.x = 200
wall.y = 450

Gravity:register(myObj)
Ground:register(myObj)
Mover:register(myObj)
MoveController:register(myObj)
JumpController:register(myObj)
WallJumpController:register(myObj)
CollisionHandler:register(myObj)
AirFriction:register(myObj)
HeldKeyHandler:register(myObj)

WORLD:register(wall)

function testState.update(dt)
    Mover:run(dt)
    Gravity:run(dt)
    Ground:run()
    CollisionHandler:run(dt)
    AirFriction:run(dt)
    MoveController:run(dt)
end

function testState.draw()
    love.graphics.rectangle("fill", myObj.x, myObj.y, myObj.width, myObj.height)
    love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
end

function testState.keypressed(key, scancode, isrepeat)
    HeldKeyHandler:run(key, true)
    WallJumpController:run(key)
    JumpController:run(key)
end

function testState.keyreleased(key, scancode)
    HeldKeyHandler:run(key, false)
end
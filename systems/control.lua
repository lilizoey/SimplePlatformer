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

local System = require "system"
local Verifiers = require "systems.verifiers"
local Physics = require "systems.physics"

local Module = {}

local verifyHeldKeys = Verifiers.isType("heldKeys", "table")
local verifyState = Verifiers.isType("state", "table")

Module.JumpHandler = System.new(
    "jump handler",
    {"jumpSpeed", "velY", "heldKeys", "jumpCount", "state"},
    function (obj)
        if not obj.heldKeys.up then return end

        local state = obj.state:getState()

        if state == "jump" then
            obj.jumpCount = obj.jumpCount + 1
            obj.velY = -obj.jumpSpeed
            assert(obj.state:tryTransition("complete jump"))
        end
    end,
    verifyHeldKeys,
    verifyState
)

Module.InputHandler = System.new(
    "input handler",
    {"state", "heldKeys", "jumpCount", "maxJumps"},
    function (obj, key, press)
        obj.heldKeys[key] = press

        local event
        if press then
            event = "press "
        else
            event = "release "
        end
        if key == "up" then
            print(obj.jumpCount)
        end
        if key == "up" and obj.jumpCount < obj.maxJumps then
            obj.state:tryTransition(event .. "jump")
        end
    end,
    verifyHeldKeys,
    verifyState
)

local function doMove(obj, dt, sign)
    local newV = obj.velX + obj.jerk * dt * Physics.constants.scale * sign

    if math.abs(newV) > obj.movementSpeed then
        obj.velX = obj.movementSpeed * sign
    else
        obj.velX = newV
    end
end

Module.Movement = System.new(
    "movement",
    {"state", "heldKeys", "velX", "movementSpeed", "jerk"},
    function (obj, dt)

        if obj.state:getState() == "wallslideleft" or obj.state:getState() == "wallslideright" then
            if obj.heldKeys.up then
                if obj.jumpCount ~= nil then obj.jumpCount = obj.jumpCount - 1 end
                obj.state:tryTransition("press jump")
            end

            if obj.heldKeys.left and not obj.heldKeys.right and obj.state:getState() == "wallslideright" then
                obj.state:tryTransition("leave wall")
            end

            if obj.heldKeys.right and not obj.heldKeys.left and obj.state:getState() == "wallslideleft" then
                obj.state:tryTransition("leave wall")
            end
        end

        if obj.heldKeys.right then
            doMove(obj, dt, 1)
        end

        if obj.heldKeys.left then
            doMove(obj, dt, -1)
        end

        if not (obj.heldKeys.left or obj.heldKeys.right) then
            if math.abs(obj.velX) < 5 then
                obj.velX = 0
            else
                obj.velX = obj.velX * math.pow(0.1, dt)
            end
        end
    end,
    verifyHeldKeys,
    verifyState
)

return Module
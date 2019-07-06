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

local StateMachine = require "statemachine"
local System = require "system"

local Player = {}
Player.__index = Player

-- Systems

Player.DataHandler = System.new(
    "data handler",
    {"state", "jumpCount"},
    function (obj)
        local state = obj.state:getState()

        if state == "ground" then
            obj.jumpCount = 0
        end
    end
)

-- Data


function Player.new(width, height, jerk, movementSpeed, jumpSpeed, maxJumps)
    local self = setmetatable({}, Player)

    -- physical values

    self.x = 0
    self.y = 0
    self.velX = 0
    self.velY = 0
    self.width = width
    self.height = height

    self.floatModifier = 0.8
    self.wallFriction = 1

    -- gameplay values

    self.jerk = jerk
    self.movementSpeed = movementSpeed
    self.jumpCount = 0
    self.jumpSpeed = jumpSpeed
    self.maxJumps = maxJumps

    -- storage

    self.heldKeys = {}

    -- state machine

    self.state = StateMachine.new()

    self.state:addState("ground")
    self.state:addState("jump")
    self.state:addState("float")
    self.state:addState("fall")
    self.state:addState("wallslideleft")
    self.state:addState("wallslideright")

    local groundID = self.state:indexOf("ground")
    local jumpID = self.state:indexOf("jump")
    local floatID = self.state:indexOf("float")
    local fallID = self.state:indexOf("fall")
    local wallSlideLeftID = self.state:indexOf("wallslideleft")
    local wallSlideRightID = self.state:indexOf("wallslideright")

    self.state:addTransition(groundID, jumpID, "press jump")
    self.state:addTransition(fallID, jumpID, "press jump")
    self.state:addTransition(wallSlideLeftID, jumpID, "press jump")
    self.state:addTransition(wallSlideRightID, jumpID, "press jump")

    self.state:addTransition(jumpID, floatID, "complete jump")
    self.state:addTransition(floatID, fallID, "release jump")

    self.state:addTransition(floatID, groundID, "collide ground")
    self.state:addTransition(fallID, groundID, "collide ground")
    self.state:addTransition(wallSlideLeftID, groundID, "collide ground")
    self.state:addTransition(wallSlideRightID, groundID, "collide ground")

    self.state:addTransition(groundID, fallID, "leave ground")
    self.state:addTransition(wallSlideLeftID, fallID, "leave wall")
    self.state:addTransition(wallSlideRightID, fallID, "leave wall")

    self.state:addTransition(floatID, wallSlideLeftID, "collide wall left")
    self.state:addTransition(floatID, wallSlideRightID, "collide wall right")
    self.state:addTransition(fallID, wallSlideLeftID, "collide wall left")
    self.state:addTransition(fallID, wallSlideRightID, "collide wall right")

    self.state:setState(self.state:indexOf("fall"))

    self.DataHandler:register(self)

    return self
end

return Player
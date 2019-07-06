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

StateMachine = require "statemachine"
System = require "system"

-- Systems



-- Data


local Player = {}
Player.__index = Player

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
    self.state:addState("wallslide")

    local groundID = self.state:indexOf("ground")
    local jumpID = self.state:indexOf("jump")
    local floatID = self.state:indexOf("float")
    local fallID = self.state:indexOf("fall")
    local wallSlideID = self.state:indexOf("wallslide")

    self.state:addTransition(groundID, jumpID, "press jump")
    self.state:addTransition(fallID, jumpID, "press jump")
    self.state:addTransition(wallSlideID, jumpID, "press jump")

    self.state:addTransition(jumpID, floatID, "complete jump")
    self.state:addTransition(floatID, fallID, "release jump")

    self.state:addTransition(floatID, groundID, "collide ground")
    self.state:addTransition(fallID, groundID, "collide ground")
    self.state:addTransition(wallSlideID, groundID, "collide ground")

    self.state:addTransition(groundID, fallID, "leave ground")
    self.state:addTransition(wallSlideID, fallID, "leave wall")

    self.state:addTransition(floatID, wallSlideID, "collide wall")
    self.state:addTransition(fallID, wallSlideID, "collide wall")

    self.state:setState(self.state:indexOf("ground"))

    return self
end

return Player
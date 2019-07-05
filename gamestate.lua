--- A very basic GameState library to handle changing game states

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

GameState = {}
GameState.__index = GameState

GameState.stateStack = Stack.new()

function GameState.new()
    local self = setmetatable({}, GameState)
    return self
end

function GameState.push(state)
    GameState.stateStack:push(state)
    if GameState.stateStack:peek().run ~= nil then
        GameState.stateStack:peek().run()
    end
end

function GameState.pop()
    if GameState.stateStack:peek() ~= nil and GameState.stateStack:peek().quit ~= nil then
        GameState.stateStack:peek().quit()
    end    
    return GameState.stateStack:pop()
end

function GameState.swap(state)
    GameState.pop()
    GameState.push(state)
end

function callbackHook(which, fallback)
    return function (...)
        local func = nil
        if not GameState.stateStack:isEmpty() then
            func = GameState.stateStack:peek()[which]
        end

        if func == nil then
            func = fallback
        end

        if func == nil then
            return
        end

        return func(...)
    end
end

-- general
love.draw = callbackHook("draw")
-- love.errhand = callbackHook("errhand", love.errhand)
-- love.errorhandler = callbackHook("errorhandler", love.errorhandler)
love.load = callbackHook("load", love.load)
love.lowmemory = callbackHook("lowmemory", love.lowmemory)
function love.quit()
    while not GameState.stateStack:isEmpty() do 
        GameState.stateStack:pop()
    end
end

love.run = callbackHook("run", love.run) 
-- love.threaderror = callbackHook("threaderror", love.threaderror)
love.update = callbackHook("update", love.update)

-- window
love.directorydropped = callbackHook("directorydropped", love.directorydropped)
love.filedropped = callbackHook("filedropped", love.filedropped)
love.focus = callbackHook("focus", love.focus)
love.mousefocus = callbackHook("mousefocus", love.mousefocus)
love.resize = callbackHook("resize", love.resize)
love.visible = callbackHook("visible", love.visible)

-- keyboard
love.keypressed = callbackHook("keypressed", love.keypressed)
love.keyreleased = callbackHook("keyreleased", love.keyreleased)
love.textedited = callbackHook("textedited", love.textedited)
love.textinput = callbackHook("textinput", love.textinput)

-- mouse
love.mousemoved = callbackHook("mousemoved", love.mousemoved)
love.mousepressed = callbackHook("mousepressed", love.mousepressed)
love.mousereleased = callbackHook("mousereleased", love.mousereleased)
love.wheelmoved = callbackHook("wheelmoved", love.wheelmoved)

-- joystick
love.gamepadaxis = callbackHook("gamepadaxis", love.gamepadaxis)
love.gamepadpressed = callbackHook("gamepadpressed", love.gamepadpressed)
love.gamepadreleased = callbackHook("gamepadreleased", love.gamepadreleased)
love.joystickadded = callbackHook("joystickadded", love.joystickadded)
love.joystickaxis = callbackHook("joystickaxis", love.joystickaxis)
love.joystickhat = callbackHook("joystickhat", love.joystickhat)
love.joystickpressed = callbackHook("joystickpressed", love.joystickpressed)
love.joystickreleased = callbackHook("joystickreleased", love.joystickreleased)
love.joystickremoved = callbackHook("joystickremoved", love.joystickremoved)

-- touch
love.touchmoved = callbackHook("touchmoved", love.touchmoved)
love.touchpressed = callbackHook("touchpressed", love.touchpressed)
love.touchreleased = callbackHook("touchreleased", love.touchreleased)

return GameState
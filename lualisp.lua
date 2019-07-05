--  Copyright 2019 sayaks

--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU Affero General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Affero General Public License for more details.

--  You should have received a copy of the GNU Affero General Public License
--  along with this program.  If not, see <https://www.gnu.org/licenses/>.

function def(name, ...)
    _ENV[name] = ...
end

_ENV["+"] = function (...)
    local sum = 0
    local args = table.pack(...)
    for i=1, args.n do
        if type(args[i]) == "string" then
            sum = sum + _ENV[args[i]]
        else
            sum = sum + args[i]
        end
    end
    return sum
end

function car(ls)
    return ls[1]
end

function cdr(ls)
    newLs = {}
    for i=2, #ls do
        table.insert(newLs, ls[i])
    end

    return newLs
end

function eval(ls)
    if type(ls[1]) == "table" then
        ls[1] = eval(ls[1])
    end

    if type(car(ls)) == "function" then
        return car(ls)(unpack(cdr(ls)))
    else
        return _ENV[car(ls)](unpack(cdr(ls)))
    end
end

function lambda(...)
    local args = {...}
    local lambdaArgs = car(args)
    local funcBody = cdr(args)
    print("-1")
    return function(...)
        print("0")
        args = {...}
        print("1")
        for i=1, #lambdaArgs do
            _ENV[lambdaArgs[i]] = args[i]
        end
        print("2")
        for i=1, #funcBody - 1 do
            eval(funcBody[i])
        end
        print("3")

        return eval(funcBody[#funcBody])
    end
end
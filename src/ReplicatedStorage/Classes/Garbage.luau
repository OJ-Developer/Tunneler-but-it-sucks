local Garbage = {}
local mt = {}
mt.__index = mt

function Garbage.new()
    local self = setmetatable({}, mt)

    self._garbage = {}

    return self
end

function mt:Add(v: any)
    table.insert(self._garbage, v)
end

function mt:Cleanup()
    for _, v in self._garbage do
        if not v then continue end

        local t = typeof(v)
        if t == "RBXScriptConnection" then
            v:Disconnect()
        elseif t == "thread" then
            pcall(function()
                task.cancel(v)
            end)
        elseif t == "Instance" then
            v:Destory()
        end
    end
end

return Garbage
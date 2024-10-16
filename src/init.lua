local Module = {}
Module.__index = Module

function Module.new()
    local self = setmetatable({}, Module)
    self.cache = {}
    return self
end

function Module:add(objectId, object)
    self.cache[objectId] = object
end

function Module:get(objectId)
    return self.cache[objectId]
end

function Module:remove(objectId)
    self.cache[objectId] = nil
end

return Module
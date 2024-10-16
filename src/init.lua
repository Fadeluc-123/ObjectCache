--[[
    Allows users to cache both 2D and 3D instance
    which can be easily retrieved and removed.
--]]

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Promise = require(Packages.Promise)

local Module = {}
Module.__index = Module

function Module.new()
    local self = setmetatable({}, Module)
    self.cache = {
        inUse = {} -- Stores the objects being used
    } :: {string: {}}

    return self
end

--[[
    Create a cache category to store cached items into, an example
    of this would be a `Sound` or `Weapons` cache

    @category: The name of the category you want to create, you use this - 
    to retrieve an item from a specific category
--]]

function Module:create(category: string)
    if not self.cache[category] then
        self.cache[category] = {
            items = {} :: {[string]: Model | Instance},
        }
    else
        warn(`{category} Category already exists!`)
    end
end

--[[
    Add an object to the cache which can be retrieved using `get`
    
    @object: The model or basepart you want to cache
    @count: The number of times the object should be cached
    @parent: The parent of the cached items (Workspace only)
--]]

function Module:add(
    object: (Model | BasePart) | nil,
    count: number,
    parent: Folder?,
    category: string?
)

    assert(object ~= nil, `{object} passed through object parameter is nil!`)
    assert(object:IsDescendantOf(game), `{object} passed through object parameter is not a descendant of game!`)
    assert(parent ~= nil, `{parent} passed through parent parameter is nil!`)
    assert(self.cache[category] ~= nil, `Category does not exist!`)

    -- Clone objects and add them to their categories cache
    local cacheCategory: {} = self.cache[category]
    Promise.new(function()
        for _ = 0, count or 1, 1 do
            local clone: Model | BasePart = object:Clone()
            clone.Parent = parent
            table.insert(cacheCategory.items, clone)
        end
    end)
end

--[[
    Attempts to "get" (return) a cached item that was added to a
    specific category
    
    @category: The category to attempt to find a cached item
    @item: The name of the cached item that you want to retrieve
    @count: The amount of items you want to get, defaults to 1, returns
    an array of objects if count is greater than 1
--]]

function Module:get(category: string, item: string, count: number?) : (Model | BasePart | {Instance}) | nil
    assert(self.cache[category] ~= nil, `"{category}" Category does not exist`)
    assert(item ~= nil and item ~= "", `{item} Item parameter is invalid, make sure it isn't nil!`)

    local cacheCategory: {} = self.cache[category]
    local items: {} = cacheCategory.items

    if next(items) ~= nil then
        if count then
            local itemsToReturn: {Instance} = {}
            local newCount: number = if #items >= count then count else #items

            for index = 0, newCount, 1 do
                table.insert(itemsToReturn, items[index])
            end
        else
            local object: Instance = items[1]
            self.inUse[object] = {
                instance = object,
                category = category,
            }

            items[1] = nil -- We've taken the object out of the cache, since it's being used (needs to be returned)
            return object
        end
    end
end

--[[
    Removes an item from the categories cache

    @category: The category of the cached item to remove
    @item: The name of the cached item to remove
    @count: The amount of cached items to remove, defaults to 1
--]]

function Module:remove(category: string, item: string, count: number?)
    assert(self.cache[category] ~= nil, `"{category}" Category does not exist`)
    assert(item ~= nil and item ~= "", `{item} Item parameter is invalid, make sure it isn't nil!`)

    local cacheCategory: {} = self.cache[category]
    local items: {} = cacheCategory.items

    if next(items) ~= nil then
        if count then
            for _ = 0, count, 1 do
                if
                    items[1]
                then
                    items[1] = nil -- Remove first item of the category
                end
            end
        else
            if items[1] then
                items[1] = nil
            else
                warn(`Failed to find items within the category!`)
            end
        end
    end
end

--[[
    Returns the cached part back into the cache, and positions
    very far away to move out out of render. Would've been called
    "return" but that's a syntax statement.
--]]

function Module:rebound(object: (Model | BasePart) | nil)
    if not self.inUse[object] then
        warn(`Failed to find cached object data for {object}!`)
        return
    end

    local category: string = self.inUse[object].category

    if not self.cache[category] then
        warn(`Failed to find category {category}!`)
        return
    end

    local cacheCategory: {} = self.cache[category]
    local items: {} = cacheCategory.items

    self.inUse[object] = nil
    table.insert(items, object)
end

return Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

local ObjectCache = ReplicatedStorage.Packages.ObjectCache

TestEZ.TestBootstrap:run({
    ObjectCache["init.spec"],
})
local json = require 'json'

local DATA_NOT_IN_MEMORY = nil
local modData = DATA_NOT_IN_MEMORY

local function LoadDataFromDisk()
    local serialized = Isaac.LoadModData(MOD)
    if serialized == "" then
        modData = {}
    else
        modData = json.decode(serialized)
    end
end

function Clear()
    Isaac.RemoveModData(MOD)
    modData = DATA_NOT_IN_MEMORY
end

function SetItem(key, value)
    if modData == DATA_NOT_IN_MEMORY then
        LoadDataFromDisk()
    end

    modData[key] = value
    Isaac.SaveModData(MOD, json.encode(modData))
end

function GetItem(key)
    if modData == DATA_NOT_IN_MEMORY then
        LoadDataFromDisk()
    end

    return modData[key]
end

function GetItemOrDefault(key, default)
    local value = GetItem(key)
    if value == nil then
        return default
    end
    return value
end

local Storage = {
    GetItem = GetItem,
    GetItemOrDefault = GetItemOrDefault,
    SetItem = SetItem,
    Clear = Clear
}

return Storage

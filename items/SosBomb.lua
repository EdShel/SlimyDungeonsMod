require 'Util'
local Storage = require 'Storage'
local game = Game()
local ITEM_ID = Isaac.GetItemIdByName("Bomb 'SOS'")

local SECONDS_UNTIL_DEATH = 505
local STORAGE_KEY = "SOS"
local MOVE_SPEED_INCREASE = 0.2
local ITEMS_TO_GIVE = 3
local DEATH_EXPLOSION_DAMAGE = 400

local playersItemCount = {}


function EvaluateCache(_, player, cacheFlag)
    local bombsNumber = player:GetCollectibleNum(ITEM_ID)
    if bombsNumber == 0 then
        return
    end

    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + MOVE_SPEED_INCREASE * bombsNumber
    end
end
MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

function OnGameStarted(_, fromSave)
    if fromSave then
        for i = 0, game:GetNumPlayers() - 1 do
            local player = game:GetPlayer(i)
            playersItemCount[i] = player:GetCollectibleNum(ITEM_ID)
        end
    else
        Storage.SetItem(STORAGE_KEY, {})
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OnGameStarted)

function OnBombPickedUp(player, playerIndex, currentCount)
    for i = 1, ITEMS_TO_GIVE do
        SpawnItemFromPool(player.Position, player:GetCollectibleRNG(ITEM_ID), 3)
    end
    if currentCount == 1 then
        local bombInfo = Storage.GetItem(STORAGE_KEY)
        if bombInfo == nil then
            bombInfo = {}
        end
        bombInfo[tostring(playerIndex)] = { ExplodeIn = GetTimeSeconds() + SECONDS_UNTIL_DEATH }
        Storage.SetItem(STORAGE_KEY, bombInfo)
    end
end

function OnBombRemoved(player, playerIndex, currentCount)
    if currentCount == 0 then
        local bombInfo = Storage.GetItem(STORAGE_KEY)
        bombInfo[tostring(playerIndex)] = {}
        Storage.SetItem(STORAGE_KEY, bombInfo)
    end
end

function CheckForTimerRanOut(player, playerIndex)
    local bombInfo = Storage.GetItemOrDefault(STORAGE_KEY, {})
    local playerInfo = bombInfo[tostring(playerIndex)]
    if playerInfo ~= nil then
        local isTimeout = playerInfo.ExplodeIn < GetTimeSeconds()
        if isTimeout then
            for i = 1, player:GetCollectibleNum(ITEM_ID) do
                player:RemoveCollectible(ITEM_ID)
            end
            if not IsPlayerHasExplosionImmunity(player) then
                player:Kill()
            end
            Isaac.Explode(player.Position, nil, DEATH_EXPLOSION_DAMAGE)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, 127, 0, player.Position, Vector(0, 0), nil)
        end
    end
end

function OnUpdate()
    for i = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(i)
        local hasNow = player:GetCollectibleNum(ITEM_ID)
        local hadBefore = playersItemCount[i]
        playersItemCount[i] = hasNow

        if hadBefore == nil then
            hadBefore = hasNow
        end
        if hasNow > hadBefore then
            OnBombPickedUp(player, i, hasNow)
        elseif hasNow < hadBefore then
            OnBombRemoved(player, i, hasNow)
        end

        if hasNow > 0 then
            CheckForTimerRanOut(player, i)
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)

function DrawDeathTimer(secondsLeft, pos)
    local text = tostring(secondsLeft)
    local w = Isaac.GetTextWidth(text)

    local color = nil
    local shakeSpeed = nil
    if secondsLeft / SECONDS_UNTIL_DEATH < 0.1 then
        color = {R = 250, G = 15, B = 15, A = 1}
        shakeSpeed = 2
    elseif secondsLeft / SECONDS_UNTIL_DEATH < 0.5 then
        color = {R = 250, G = 179, B = 15, A = 1}
        shakeSpeed = 3
    else
        color = {R = 255, G = 255, B = 255, A = 1}
        shakeSpeed = 5
    end

    local yOffset = math.sin(game.TimeCounter / shakeSpeed) * 2

    Isaac.RenderText(text, pos.X - w / 2, pos.Y + yOffset, color.R / 255, color.G / 255, color.B / 255, color.A)
end

function OnRendered()
    for i = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(i)
        if player:HasCollectible(ITEM_ID) then
            local pos = Isaac.WorldToScreen(player.Position)
            local bombInfo = Storage.GetItemOrDefault(STORAGE_KEY, {})
            local playerInfo = bombInfo[tostring(i)]
            if playerInfo == nil then
                return
            end
            local deathTime = playerInfo.ExplodeIn
            DrawDeathTimer(deathTime - GetTimeSeconds(), pos)
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_RENDER, OnRendered)

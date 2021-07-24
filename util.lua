local game = Game()

function IsAnyPlayerHasItem(collectibleType)
    local playersCount = game:GetNumPlayers()
    for i = 0, playersCount do
        local player = game:GetPlayer(i)
        if player:HasCollectible(collectibleType) then
            return true
        end
    end
    return false
end

function IsQuestItem(collectibleId)
    return collectibleId == 327 -- The Polaroid
        or collectibleId == 328 -- The Negative
        or collectibleId == 238 -- Key piece #1
        or collectibleId == 239 -- Key piece #2
        or collectibleId == 550 -- Broken shovel (basement)
        or collectibleId == 551 -- Broken shovel (boss rush)
        or collectibleId == 626 -- Knife piece 1
        or collectibleId == 627 -- Knife piece 2
        or collectibleId == 668 -- Dad's note
end

function GetRoomItems()
    local entities = game:GetRoom():GetEntities()
    local i = 0
    local len = #entities
    return function ()
        while i < len do
            local entity = entities:Get(i)
            i = i + 1

            if entity.Type == EntityType.ENTITY_PICKUP
                and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE
            then
                return entity:ToPickup()
            end
        end
    end
end

function ToArray(iterator)
    local array = {}
    local i = 1
    for item in iterator do
        array[i] = item
        i = i + 1
    end
    return array
end

function GetTimeSeconds()
    return math.floor(game.TimeCounter / 30)
end

function SpawnItemFromPool(position, rng, distance)
    local room = game:GetRoom()
    local roomType = room:GetType()
    local itemPool = game:GetItemPool()
    local poolType = itemPool:GetPoolForRoom(roomType, rng:RandomInt(1000))
    local collectibleId = itemPool:GetCollectible(poolType, true, rng:RandomInt(1000))
    
    local positionForItem = room:FindFreePickupSpawnPosition(position, 1, distance)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectibleId,
        positionForItem, Vector(0, 0), nil)
end

function IsPlayerHasExplosionImmunity(player)
    return player:HasCollectible(223) -- Pyromaniac
        or player:HasCollectible(375) -- Host hat
end

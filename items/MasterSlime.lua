require 'Util'
local game = Game()

local ITEM_ID = Isaac.GetItemIdByName("Slime of a Master")
local ITEM_TO_REPLACE_REWARD = 36 -- The poop
local ITEM_ID_NO_HIT_REWARD = 25 -- Breakfast

local tookDamage = false
local isBossRoom = false
local waitingToReplaceReward = false
local rewardReplaced = false

function OnRoomEntered()
    tookDamage = false

    if not IsAnyPlayerHasItem(ITEM_ID) then
        return
    end

    local room = game:GetRoom()
    isBossRoom = room:GetType() == RoomType.ROOM_BOSS
end
MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnRoomEntered)

function OnTakeDamage()
    tookDamage = true
end
MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnTakeDamage, EntityType.ENTITY_PLAYER)

function OnUpdate()
    -- Do not replace further spawned items
    if waitingToReplaceReward and rewardReplaced then
        waitingToReplaceReward = false
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)

function SpawnNoHitReward()
    local room = game:GetRoom()
    local positionForItem = room:FindFreePickupSpawnPosition(Isaac.GetPlayer(0).Position, 1, true)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID_NO_HIT_REWARD,
        positionForItem, Vector(0, 0), nil)
end

function OnSpawnReward()
    if not IsAnyPlayerHasItem(ITEM_ID)
        or not isBossRoom
    then
        return
    end

    if tookDamage then
        waitingToReplaceReward = true
        rewardReplaced = false
    else
        SpawnNoHitReward()
    end
end
MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnSpawnReward)

function OnEntitySpawn(_, entityType, variant, subtype, pos, vel, spawner, seed)
    if not IsAnyPlayerHasItem(ITEM_ID)
        or not isBossRoom
        or not waitingToReplaceReward
    then
        return
    end

    if entityType == EntityType.ENTITY_PICKUP
        and variant == PickupVariant.PICKUP_COLLECTIBLE
    then
        rewardReplaced = true
        if not IsQuestItem(subtype) then
            return {  entityType, variant, ITEM_TO_REPLACE_REWARD, seed }
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, OnEntitySpawn)

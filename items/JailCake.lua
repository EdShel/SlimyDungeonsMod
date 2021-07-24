local game = Game()

local JailCake = {
    ITEM_ID = Isaac.GetItemIdByName("Jail Cake"),
    ANY_KEY = 0
}

function JailCake:OnItemUse(collectibleType, rng)
    for i = 1, game:GetNumPlayers() do
        local player = game:GetPlayer(i)
        if player:GetActiveItem() == JailCake.ITEM_ID then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, JailCake.ANY_KEY, player.Position, player.Velocity, player)
            return
        end
    end
end

MOD:AddCallback(ModCallbacks.MC_USE_ITEM, JailCake.OnItemUse, JailCake.ITEM_ID)
print('fdsfsd')
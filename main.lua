local Mod = RegisterMod("SlimyDungeons", 1)
local JailCake = require('jailCake')

JailCake(Mod);

-- function Mod:OnGameStarted(fromSave) 
--     if not fromSave then
--         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, JailCake.ITEM_ID, Vector(300, 300), Vector(0, 0), nil)
--     end
-- end
-- Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.OnGameStarted)




-- local function UpdateItems(player)
--     HasItem.JailCake = player:HasCollectible(ItemId.JAIL_CAKE)
-- end

-- function Mod:OnPlayerInit(player)
--     UpdateItems(player)
-- end
-- Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.OnPlayerInit)

-- function Mod:OnUpdated(player)
--     if game:GetFrameCount() == 1 then
--         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.JAIL_CAKE, Vector(300, 300), Vector(0, 0), nil)
--         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.JAIL_CAKE, Vector(330, 300), Vector(0, 0), nil)

--         -- if player:GetName() == "Isaac" then
--         --     player:AddCollectible(ItemId.JAIL_CAKE, 0, true)
--         -- end
--     end


--     UpdateItems(player)
-- end
-- Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.OnUpdated)

-- function Mod:OnCache(player, cacheFlag)
--     if cacheFlag == CacheFlag.CACHE_DAMAGE then
--         if player:HasCollectible(ItemId.JAIL_CAKE) then
--             player.Damage = player.Damage + 3
--         end
--     end
-- end
-- Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.OnCache)
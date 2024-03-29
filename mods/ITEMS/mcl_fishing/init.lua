local S = minetest.get_translator("mcl_fishing")

local go_fishing = function(itemstack, user, pointed_thing)
	if pointed_thing and pointed_thing.under then
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		if string.find(node.name, "mcl_core:water") then
			local itemname
			local itemcount = 1
			local itemwear = 0
			-- FIXME: Maybe use a better seeding
			local pr = PseudoRandom(os.time() * math.random(1, 100))
			local r = pr:next(1, 100)
			if r <= 85 then
				-- Fish
				items = mcl_loot.get_loot({
					items = {
						{ itemstring = "mcl_fishing:fish_raw", weight = 60 },
						{ itemstring = "mcl_fishing:salmon_raw", weight = 25 },
						{ itemstring = "mcl_fishing:clownfish_raw", weight = 2 },
						{ itemstring = "mcl_fishing:pufferfish_raw", weight = 13 },
					}
				}, pr)
			elseif r <= 95 then
				-- Junk
				items = mcl_loot.get_loot({
					items = {
						{ itemstring = "mcl_core:bowl", weight = 10 },
						{ itemstring = "mcl_fishing:fishing_rod", weight = 2, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
						{ itemstring = "mcl_mobitems:leather", weight = 10 },
						{ itemstring = "3d_armor:boots_leather", weight = 10, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
						{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
						{ itemstring = "mcl_core:stick", weight = 5 },
						{ itemstring = "mcl_mobitems:string", weight = 5 },
						{ itemstring = "mcl_potions:potion_water", weight = 10 },
						{ itemstring = "mcl_mobitems:bone", weight = 10 },
						{ itemstring = "mcl_dye:black", weight = 1, amount_min = 10, amount_max = 10 },
						{ itemstring = "mcl_mobitems:string", weight = 10 }, -- TODO: Tripwire Hook
					}
				}, pr)
			else
				-- Treasure
				items = mcl_loot.get_loot({
					items = {
						-- TODO: Enchanted Bow
						{ itemstring = "mcl_bows:bow", wear_min = 49144, wear_max = 65535 }, -- 75%-100% damage
						-- TODO: Enchanted Book
						{ itemstring = "mcl_books:book" },
						-- TODO: Enchanted Fishing Rod
						{ itemstring = "mcl_fishing:fishing_rod", wear_min = 49144, wear_max = 65535 }, -- 75%-100% damage
						{ itemstring = "mcl_mobs:nametag", },
						{ itemstring = "mcl_mobitems:saddle", },
						{ itemstring = "mcl_flowers:waterlily", },
					}
				}, pr)
			end
			local item
			if #items >= 1 then
				item = ItemStack(items[1])
			else
				item = ItemStack()
			end
			local inv = user:get_inventory()
			if inv:room_for_item("main", item) then
				inv:add_item("main", item)
			end
			if not minetest.settings:get_bool("creative_mode") then
				local idef = itemstack:get_definition()
				itemstack:add_wear(65535/65) -- 65 uses
				if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
					minetest.sound_play(idef.sound.breaks, {pos=pointed_thing.above, gain=0.5})
				end
			end
			return itemstack
		end
	end
	return nil
end

-- Fishing Rod
minetest.register_tool("mcl_fishing:fishing_rod", {
	description = S("Fishing Rod"),
	_doc_items_longdesc = S("Fishing rods can be used to catch fish."),
	_doc_items_usagehelp = S("Rightclick a water source to try to go fishing. Who knows what you're going to catch?"),
	-- This item is incomplete, hide it from creative inventory
	groups = { tool=1, not_in_creative_inventory=1 },
	inventory_image = "mcl_fishing_fishing_rod.png",
	stack_max = 1,
	liquids_pointable = true,
	on_place = go_fishing,
	sound = { breaks = "default_tool_breaks" },
})

--[[

Temporarily removed from crafting as the fishing rod is massively overpowered atm.

TODO: Re-enable crafting when fishing rod has been improved.

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'','','mcl_core:stick'},
		{'','mcl_core:stick','mcl_mobitems:string'},
		{'mcl_core:stick','','mcl_mobitems:string'},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'mcl_core:stick', '', ''},
		{'mcl_mobitems:string', 'mcl_core:stick', ''},
		{'mcl_mobitems:string','','mcl_core:stick'},
	}
})
]]

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_fishing:fishing_rod",
	burntime = 15,
})


-- Fish
minetest.register_craftitem("mcl_fishing:fish_raw", {
	description = S("Raw Fish"),
	_doc_items_longdesc = S("Raw fish is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_fish_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	stack_max = 64,
	groups = { food=2, eatable = 2 },
	_mcl_saturation = 0.4,
})

minetest.register_craftitem("mcl_fishing:fish_cooked", {
	description = S("Cooked Fish"),
	_doc_items_longdesc = S("Mmh, fish! This is a healthy food item."),
	inventory_image = "mcl_fishing_fish_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	stack_max = 64,
	groups = { food=2, eatable=5 },
	_mcl_saturation = 6,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_fishing:fish_cooked",
	recipe = "mcl_fishing:fish_raw",
	cooktime = 10,
})

-- Salmon
minetest.register_craftitem("mcl_fishing:salmon_raw", {
	description = S("Raw Salmon"),
	_doc_items_longdesc = S("Raw salmon is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_salmon_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	stack_max = 64,
	groups = { food=2, eatable = 2 },
	_mcl_saturation = 0.4,
})

minetest.register_craftitem("mcl_fishing:salmon_cooked", {
	description = S("Cooked Salmon"),
	_doc_items_longdesc = S("This is a healthy food item which can be eaten."),
	inventory_image = "mcl_fishing_salmon_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	stack_max = 64,
	groups = { food=2, eatable=6 },
	_mcl_saturation = 9.6,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_fishing:salmon_cooked",
	recipe = "mcl_fishing:salmon_raw",
	cooktime = 10,
})

-- Clownfish
minetest.register_craftitem("mcl_fishing:clownfish_raw", {
	description = S("Clownfish"),
	_doc_items_longdesc = S("Clownfish may be obtained by fishing (and luck) and is a food item which can be eaten safely."),
	inventory_image = "mcl_fishing_clownfish_raw.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	stack_max = 64,
	groups = { food=2, eatable = 1 },
	_mcl_saturation = 0.2,
})

-- Pufferfish
-- TODO: Add real status effect
minetest.register_craftitem("mcl_fishing:pufferfish_raw", {
	description = S("Pufferfish"),
	_doc_items_longdesc = S("Pufferfish are a common species of fish and can be obtained by fishing. They can technically be eaten, but they are very bad for humans. Eating a pufferfish only restores 1 hunger point and will poison you very badly (which drains your health non-fatally) and causes serious food poisoning (which increases your hunger)."),
	inventory_image = "mcl_fishing_pufferfish_raw.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	stack_max = 64,
	groups = { food=2, eatable=1 },
	_mcl_saturation = 0.2,
})


minetest.register_craftitem("mcl_throwing:arrow", {
	description = "Arrow",
	inventory_image = "mcl_throwing_arrow_inv.png",
	groups = { ammo=1, ammo_bow=1 },
})

minetest.register_node("mcl_throwing:arrow_box", {
	drawtype = "nodebox",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},
			
			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"mcl_throwing_arrow.png", "mcl_throwing_arrow.png", "mcl_throwing_arrow_back.png", "mcl_throwing_arrow_front.png", "mcl_throwing_arrow_2.png", "mcl_throwing_arrow.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	visual = "wielditem",
	visual_size = {x=0.4, y=0.4},
	textures = {"mcl_throwing:arrow_box"},
	collisionbox = {0,0,0,0,0,0},

	_timer=0,
	_lastpos={},
	_startpos=nil,
	_damage=1,	-- Damage on impact
	_shooter=nil,	-- ObjectRef of player or mob who shot it
}

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self._timer=self._timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	if self._timer>0.2 then
		local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				local entity_name = obj:get_luaentity().name
				if obj ~= self._shooter and entity_name ~= "mcl_throwing:arrow_entity" and entity_name ~= "__builtin:item" then
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=self._damage},
					}, nil)

					-- Achievement for hitting skeleton, wither skeleton or stray (TODO) with an arrow at least 50 meters away
					-- TODO: This achievement should be given for the kill, not just a hit
					if self._shooter and self._shooter:is_player() and vector.distance(pos, self._startpos) >= 50 then
						if (entity_name == "mobs_mc:skeleton" or entity_name == "mobs_mc:skeleton2") then
							awards.unlock(self._shooter:get_player_name(), "mcl:snipeSkeleton")
						end
					end
					self.object:remove()
				end
			elseif obj ~= self._shooter then
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=self._damage},
				}, nil)
				self.object:remove()
			end
		end
	end

	if self._lastpos.x~=nil then
		local def = minetest.registered_nodes[node.name]
		if (def and def.walkable) or not def then
			minetest.add_item(self._lastpos, 'mcl_throwing:arrow')
			self.object:remove()
		end
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("mcl_throwing:arrow_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = 'mcl_throwing:arrow 4',
	recipe = {
		{'mcl_core:flint'},
		{'mcl_core:stick'},
		{'mcl_mobitems:feather'}
	}
})

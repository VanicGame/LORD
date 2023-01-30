clothing = {
	formspec = armor.formspec,
	textures = {},
}

clothing.set_player_clothing = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local player_inv = player:get_inventory()
	if not name or not player_inv then
		return
	end
	local clothing_texture = "lottarmor_trans.png"
	local elements = {}
	local textures = {}
	local preview = multiskin:get_skin_name(name) or "clothing_preview"
	preview = preview..".png"
	for i=1, 5 do
		local stack = player_inv:get_stack("clothing", i)
		local item = stack:get_name()
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			if def.groups["clothes"] == 1 then
				local texture = item:gsub("%:", "_")
				table.insert(textures, texture..".png")
				if not def.groups["no_preview"] then
					preview = preview.."^"..texture.."_preview.png"
				end
			end
		end
	end
	if #textures > 0 then
		clothing_texture = table.concat(textures, "^")
	end
	self.textures[name].clothing = clothing_texture
	self.textures[name].preview = preview
	multiskin[name].clothing = clothing_texture
	multiskin:update_player_visuals(player)
end

clothing.update_inventory = function(self, player)
	local name = player:get_player_name()
	local formspec = armor.get_armor_formspec(self, name)
	local page = player:get_inventory_formspec()
	if page:find("detached:"..name.."_clothing") then
		minetest.show_formspec(player:get_player_name(), "custom", formspec)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if fields.clothing then
		local formspec = clothing:get_clothing_formspec(name)
		minetest.show_formspec(player:get_player_name(), "custom", formspec)
		return
	end
end)

races.register_init_callback(function(name, race, gender, skin, texture, face)
	local player = minetest.get_player_by_name(name)
    multiskin:init(player, texture)
	local player_inv = player:get_inventory()
	local clothing_inv = minetest.create_detached_inventory(name.."_clothing",{
		on_put = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, stack)
			clothing:set_player_clothing(player)
			clothing:update_inventory(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
			clothing:set_player_clothing(player)
			clothing:update_inventory(player)
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local plaver_inv = player:get_inventory()
			local stack = inv:get_stack(to_list, to_index)
			player_inv:set_stack(to_list, to_index, stack)
			player_inv:set_stack(from_list, from_index, nil)
			clothing:set_player_clothing(player)
			clothing:update_inventory(player)
		end,
		allow_put = function(inv, listname, index, stack, player)
			if index == 1 then
				if stack:get_definition().groups.clothes_head == nil then
					return 0
				else
					return 1
				end
			elseif index == 2 then
				if stack:get_definition().groups.clothes_torso == nil then
					return 0
				else
					return 1
				end
			elseif index == 3 then
				if stack:get_definition().groups.clothes_legs == nil then
					return 0
				else
					return 1
				end
			elseif index == 4 then
				if stack:get_definition().groups.clothes_feet == nil then
					return 0
				else
					return 1
				end
			elseif index == 5 then
				if stack:get_definition().groups.clothes_cloak == nil then
					return 0
				else
					return 1
				end
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
	}, name)
	clothing_inv:set_size("clothing", 5)
	player_inv:set_size("clothing", 5)
	for i=1, 5 do
		local stack = player_inv:get_stack("clothing", i)
		clothing_inv:set_stack("clothing", i, stack)
	end
	clothing.textures[name] = {
		clthing = "clothing_trans.png",
		preview = "clothing_preview.png",
	}
	minetest.after(ARMOR_INIT_DELAY, function(player)
		clothing:set_player_clothing(player)
		clothing:update_inventory(player)
	end, player)
end)

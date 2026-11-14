--!nonstrict
--[[
	THE HORIZON — Items, recipes and craft times (shared)
	ModuleScript named "HorizonItems" in ReplicatedStorage.

	Both the UI (client) and the inventory server read this, so recipes only
	live in one place. The SERVER is the one that enforces them: changing this
	file on the client does nothing.
]]

local HorizonItems = {}

-- Images from the old crafting script
HorizonItems.ITEMS = {
	planks = { Name = "Planks", Image = "rbxassetid://78387750873126" },
	stone = { Name = "Stone", Image = "rbxassetid://127351259030040" },
	leaves = { Name = "Leaves", Image = "rbxassetid://94252892154991" },
	rope = { Name = "Rope", Image = "rbxassetid://94728420315409", Desc = "A simple binding material made from leaves." },
	fiber = { Name = "Fiber", Image = "rbxassetid://85899584797851" },
	scrap = { Name = "Scrap", Image = "rbxassetid://123247338574784" },
	plastic = { Name = "Plastic", Image = "rbxassetid://126538877519520" },
	nails = { Name = "Nails", Image = "rbxassetid://100720163739756", Desc = "Basic metal fasteners used in construction." },
	hide = { Name = "Hide", Image = "rbxassetid://137106848150031" },
	cup_clean = { Name = "Clean Water Cup", Image = "rbxassetid://75855735142648", Desc = "Safe drinking water." },
	cup_sea = { Name = "Seawater Cup", Image = "rbxassetid://94755334875949" },
	stone_axe = { Name = "Stone Axe", Image = "rbxassetid://73396827796121", Desc = "A basic chopping tool for cutting trees and gathering planks." },
	stone_pickaxe = { Name = "Stone Pickaxe", Image = "rbxassetid://103209016597189", Desc = "A basic mining tool for breaking stone and gathering ore." },
	stone_spear = { Name = "Stone Spear", Image = "rbxassetid://131953404883594", Desc = "A simple spear for hunting and defending yourself." },
	wooden_club = { Name = "Wooden Club", Image = "rbxassetid://77142435102160", Desc = "A rough wooden club for close combat." },
	stone_sword = { Name = "Stone Sword", Image = "rbxassetid://99964958308218", Desc = "A sharper stone weapon for stronger melee attacks." },
	torch = { Name = "Torch", Image = "rbxassetid://128672619441958", Desc = "A handheld light for exploring dark areas." },
	bow = { Name = "Bow", Image = "rbxassetid://103839860687597", Desc = "A wooden bow for firing arrows." },
	stone_arrows = { Name = "Stone Arrows", Image = "rbxassetid://87510233891000", Desc = "Stone-tipped arrows for a bow." },
	wooden_shield = { Name = "Wooden Shield", Image = "rbxassetid://104624286311499", Desc = "A wooden shield for blocking attacks." },
	building_hammer = { Name = "Building Hammer", Image = "rbxassetid://85234448517206", Desc = "A tool for planning and placing structures." },
	map = { Name = "Map", Image = "", Desc = "A hide map for finding your way." },
	compass = { Name = "Compass", Image = "", Desc = "A compass for finding your direction." },
}

-- mats = nil means "Recipe not set yet" (can't be crafted)
HorizonItems.RECIPES = {
	Tools = {
		{ id = "stone_pickaxe", mats = { { "planks", 4 }, { "stone", 4 }, { "rope", 2 } } },
		{ id = "stone_axe", mats = { { "planks", 3 }, { "stone", 4 }, { "rope", 2 } } },
		{ id = "stone_spear", mats = { { "planks", 3 }, { "stone", 1 }, { "rope", 1 } } },
		{ id = "wooden_club", mats = { { "planks", 3 }, { "rope", 1 } } },
		{ id = "stone_sword", mats = { { "planks", 3 }, { "stone", 5 }, { "rope", 2 } } },
		{ id = "torch", mats = { { "planks", 1 }, { "leaves", 4 }, { "rope", 1 } } },
		{ id = "bow", mats = nil },
		{ id = "stone_arrows", mats = nil },
		{ id = "wooden_shield", mats = { { "planks", 6 }, { "rope", 2 }, { "hide", 1 } } },
		{ id = "building_hammer", mats = nil },
		{ id = "map", mats = { { "hide", 2 }, { "fiber", 2 } } },
		{ id = "compass", mats = { { "scrap", 3 }, { "plastic", 1 } } },
	},
	Resources = {
		{ id = "rope", mats = { { "leaves", 3 } } },
		{ id = "nails", mats = { { "scrap", 1 } } },
	},
	Consumables = {
		{ id = "cup_clean", mats = nil },
	},
}
HorizonItems.CATEGORY_ORDER = { "Tools", "Resources", "Consumables" }

-- Seconds per item. PLACEHOLDERS — set your real times here.
HorizonItems.CRAFT_TIME = {
	stone_pickaxe = 4, stone_axe = 4, stone_spear = 3, wooden_club = 2.5, stone_sword = 5,
	torch = 2, wooden_shield = 4, map = 3, compass = 3, rope = 1.5, nails = 1,
}
HorizonItems.DEFAULT_CRAFT_TIME = 3

HorizonItems.QUEUE_MAX = 8 -- different entries in the craft queue
HorizonItems.HOTBAR_SLOTS = 8

-- lookups
local recipeById, categoryById = {}, {}
for category, list in pairs(HorizonItems.RECIPES) do
	for _, recipe in ipairs(list) do
		recipeById[recipe.id] = recipe
		categoryById[recipe.id] = category
	end
end

function HorizonItems.findRecipe(id)
	return recipeById[id]
end

function HorizonItems.categoryOf(id)
	return categoryById[id]
end

function HorizonItems.craftTime(id)
	return HorizonItems.CRAFT_TIME[id] or HorizonItems.DEFAULT_CRAFT_TIME
end

return HorizonItems

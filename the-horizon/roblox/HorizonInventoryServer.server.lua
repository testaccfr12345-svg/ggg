--[[
	THE HORIZON — starts the inventory & crafting server
	Script named "HorizonInventoryServer" in ServerScriptService,
	next to the ModuleScript "HorizonInventoryService".
]]
require(script.Parent:WaitForChild("HorizonInventoryService")).Start()

Config = {}
Config.Debug = false

Config.oxInv = true -- set this to ox if you have ox_inventory

--  DISABLE OX LIB IN FXMANIFEST IF THIS IS FALSE:
Config.oxLib = true -- set this to ox if you have ox_lib !!! MAKE SURE OX LIB IS ADDED TO SHARED_SCRIPTS IN FXMANIFEST!!

Config.UseLocalImages = false -- set this to true if you want to use local images rather than automatic. Put the images for the recipes and ingredients in the 'images' folder next to the blueprint.png

Config.UseCWRepForCraftingSkill = false -- Set to true if you want to use cw-rep for skill instead of qbs metadata (highly recommended)
Config.CraftingSkillName = 'crafting' -- Make sure this matches the crafting skill name in your cw-rep config

local minimumSkillRep = 1 -- the least amount of skill you can gain per craft

-- You can tweak this function to return different amount of points per skill
-- The default one will give you 1 skill for a crafted item and the +1 for each 100 in skill requirement the item has. 
Config.CraftingRepGainFunction = function(skillReq)
	if not skillReq then return minimumSkillRep end
	
    local skillGain = 1 + math.floor((skillReq - 1) / 100)
	if skillGain < minimumSkillRep then return minimumSkillRep end
	if Config.Debug then print('Skill gain:', skillGain) end
	return skillGain
end


Config.Blueprints = { -- rarity is 1-5, chance is 0.0-1.0 with lower numbers lowering chance of getting the item
	['aluminumoxide_pro'] = { rarity = 3, chance = 30, type='legal' },
	['repairkit'] = { rarity = 2, chance = 40,  type='legal' },
	['screwdriverset'] = { rarity = 2, chance = 50,  type='legal' },
	['electronickit'] = { rarity = 2, chance = 30,  type='legal' },
	['radioscanner'] = { rarity = 3, chance = 5, type='illegal' },
	['gatecrack'] = { rarity = 4, chance = 20,  type='illegal' },
	['armor'] = { rarity = 5, chance = 5, type='illegal'},
	['Ap Pistol'] = { rarity = 5, chance = 1, type='illegal' },
}

Config.DefaultFailChance = 80

Config.DefaultCraftingTime = 1000 -- in milliseconds

Config.Recipes = {
	['lockpick'] = {
		category = "Tools",
		toItems = {
			lockpick = 2,
		},
		materials = { metalscrap = 12, plastic = 12 },
		craftingTime= 3000,
		craftingSkill= 10,
	},
	['breakdown_phone'] = {
		label = 'Breakdown phone',
		type = "breakdown",
		materials = {
			phone = 1
		},
		toItems = {
			aluminum = 14,
			glass = 21,
			plastic = 10
		},
		maxCraft = 10,
		category = 'Breakdown',
		craftingTime= 4000,
	},
	["weapon_appistol"] = {
		label = "AP Pistol",
		toItems = {
			WEAPON_APPISTOL = 1,
		},
		materials = {
			["metalscrap"] = 360,
		},
		category = 'Weapons',
		tables = {'guns'},
		blueprint = 'Ap Pistol',
		metadata = {registered= false} -- If set, will write info/metadata on item
	},
}


-- Search for more tables here, for example: https://gta-objects.xyz/objects
-- For icons see https://pictogrammers.com/library/mdi/
Config.CraftingTables = {
	['basic'] = {
		title = "Crafting",
		objects = { 'ex_prop_ex_toolchest_01', 'prop_toolchest_04', 'prop_toolchest_05'}, 
		locations = {  vector3(939.4, -1554.36, 30.58), }
	},
	['mechanic'] = {
		title = "Mechanic Crafting",
		objects = { 'prop_toolchest_05' },
		icon = "car-wrench", -- optional. Defaults to 'wrench'
		jobType = { ['mechanic'] = 1 }, -- NOTE: This checks TYPES not name. A new qb thing. It's good. Use it.
		locations = { vector3(948.81, -1552.64, 30.59), }, -- BOXZONE: If you add one of these objects (locations = ...) it will spawn boxzones
		spawnTable = { { coords = vector4(794.49, -2613.63, 87.97, 2.4), prop = 'ex_prop_ex_toolchest_01' } } -- SPAWNS TABLE: the spawnTable field holds a list of several tables with prop and location. If these are added it will SPAWN a table that's interactable
	},
	['guns'] = {
		title = "Weapon Crafting",
		icon = "pistol",
		objects = { 'gr_prop_gr_bench_01a' }
	},
	['ballasguns'] = {
		title = "Weapon Crafting For Ballas",
		icon = "pistol",
		gang = "ballas",
		spawnTable = { { coords = vector4(100.52, -1968.95, 20.91, 352.84), prop='gr_prop_gr_bench_02a' }}
	},
}

Config.UseSundownUtils = false

Config.BlueprintDudes = { -- SET THIS TO Config.BlueprintDudes = nil TO DISABLE
	{
		model = 'cs_nigel',
		type = 'legal',
		coords = vector4(-1647.53, 248.17, 61.97, 118.29),
		animation = 'WORLD_HUMAN_SEAT_LEDGE_EATING',
	},
	{
		model = 'u_m_m_blane',
		type = 'illegal',
		coords = vector4(1641.73, 3731.21, 35.07, 6.15),
		animation = 'WORLD_HUMAN_DRINKING',
	}
}
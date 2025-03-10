Config = {}
Config.Debug = false

Config.oxInv = false -- set this to ox if you have ox_inventory

--  DISABLE OX LIB IN FXMANIFEST IF THIS IS FALSE:
Config.oxLib = true -- set this to ox if you have ox_lib !!! MAKE SURE OX LIB IS ADDED TO SHARED_SCRIPTS IN FXMANIFEST!!
Config.useOxTarget = true -- Set to true if you use ox-target. If this is false the script uses qb target

Config.UseLocalImages = false -- set this to true if you want to use local images rather than automatic. Put the images for the recipes and ingredients in the 'images' folder next to the blueprint.png
Config.ReopenCraftingWhenFinished = false -- if true the script will re-open the crafting when it's done

Config.ItemName = "blueprint" -- Name of the item in your items.lua
Config.PlayersTableName = 'players' -- 'players' for qb/qbox, 'characters' for ox. Something else for esx probably
Config.PlayerDbIdentifier = 'citizenId' -- 'citizenId' for qb/qbox, 'stateId' for ox, Something else for ex probably
Config.UseCWRepForCraftingSkill = true -- Set to true if you want to use cw-rep for skill instead of qbs metadata
-- The following all require cw-rep to be enabled:
Config.CraftingSkillName = 'crafting' -- Make sure this matches the crafting skill name in your cw-rep config
Config.CraftingSkillLabel = '"Crafting Skill"' -- Default name for the crafting skill
Config.UseLevelsInsteadOfSkill = false -- If true then cw-rep will use level instead of pure xp 
Config.DefaultMaxCraft = 10 -- Default max amount a player can craft at a time

Config.PrimaryUiColor = '#52d996' -- Primary color in UI, default is blue

local minimumSkillRep = 1 -- the least amount of skill you can gain per craft

-- You can tweak this function to return different amount of points per skill
-- The default one will give you 1 skill for a crafted item and the +1 for each 100 in skill requirement the item has. 
Config.CraftingRepGainFunction = function(skillReq, recipe)
	if recipe and recipe.customSkillGain then return recipe.customSkillGain end
	if not skillReq then return minimumSkillRep end
	
    local skillGain = 1 + math.floor((skillReq - 1) / 100)
	if skillGain < minimumSkillRep then return minimumSkillRep end
	if Config.Debug then print('Skill gain:', skillGain) end
	return skillGain
end


Config.Blueprints = { -- rarity is 1-5, chance is 0.0-1.0 with lower numbers lowering chance of getting the item
	['NavyRevolverBlueprint'] = { rarity = 5, type='illegal'},
}

Config.DefaultFailChance = 80

Config.DefaultCraftingTime = 1000 -- in milliseconds
Config.LearningTime = 2500 -- time it takes to learn BP in milliseconds

Config.Recipes = {
	['lockpick'] = {
		category = "basic",
		toItems = {
			lockpick = 2,
		},
		materials = { iron_bar = 2, copper_bar = 1 },
		craftingTime= 3000,
		craftingSkill= 10,
		customSkillGain = 5,
		skillName='crafting',
		tables ={"basic"},
		keepMaterials = { plastic = true }
	},
	['weapon_revolver_navy'] = {
		category = "weapon",
		toItems = {
			weapon_revolver_navy = 1,
		},
		materials = { iron_bar = 1, copper_bar = 1,silver_bar = 1,gold_bar = 1 },
		craftingTime= 10000,
		craftingSkill= 10,
		tables ={"basic"},
		maxCraft = 1,
		customSkillGain = 5,
		blueprint = 'NavyRevolverBlueprint',
	},
	['gold_bar'] = {
		category = "blacksmith",
		toItems = {
			gold_bar = 1,
		},
		materials = { gold_ore = 5, water = 1 },
		craftingTime= 3000,
		skillName='blacksmith',
		customSkillGain = 5,
		tables ={"blacksmith"},
		keepMaterials = { water = true }
	},
	
	['iron_bar'] = {
		category = "blacksmith",
		toItems = {
			iron_bar = 1,
		},
		materials = { iron_ore = 5, water = 1 },
		craftingTime= 3000,
		skillName='blacksmith',
		customSkillGain = 5,
		tables ={"blacksmith"},
		keepMaterials = { water = true }
	},
	['silver_bar'] = {
		category = "blacksmith",
		toItems = {
			silver_bar = 1,
		},
		materials = { silver_ore = 5, water = 1 },
		craftingTime= 3000,
		skillName='blacksmith',
		customSkillGain = 5,
		tables ={"blacksmith"},
		keepMaterials = { water = true }
	},
	['copper_bar'] = {
		category = "blacksmith",
		toItems = {
			copper_bar = 1,
		},
		materials = { copper_ore = 5, water = 1 },
		craftingTime= 3000,
		skillName='blacksmith',
		customSkillGain = 5,
		tables ={"blacksmith"},
		keepMaterials = { water = true }
	},
	
}


-- Search for more tables here, for example: https://gta-objects.xyz/objects
-- For icons see https://pictogrammers.com/library/mdi/
Config.CraftingTables = {
	['basic'] = {
		title = "Crafting",
		animation = { dict = 'anim@amb@business@coc@coc_unpack_cut@', anim = 'fullcut_cycle_v7_cokecutter'},
		objects = { 'mp005_s_posse_ammotable03x'}, 
		-- locations = {  vector3(2941.11, 1267.26, 44.59), },
		spawnTable = { { coords = vector4(2008.08, 706.73, 172.73, 345.22), prop = 'mp005_s_posse_ammotable03x' } },
		skipPlaceObjectOnGroundProperly = true -- Defaults to false, if set to true then object wont be placed onto ground. Useful for placing items on tables etc
	},

	['blacksmith'] = {
		title = "BlackSmith Crafting",
		animation = { dict = 'anim@amb@business@coc@coc_unpack_cut@', anim = 'fullcut_cycle_v7_cokecutter'},
		objects = { 'p_baseburner01x'}, 
		-- locations = {  vector3(2941.11, 1267.26, 44.59), },
		spawnTable = { { coords = vector4(2004.85, 704.65, 172.66, 355.34), prop = 'p_baseburner01x' } },
		skipPlaceObjectOnGroundProperly = true -- Defaults to false, if set to true then object wont be placed onto ground. Useful for placing items on tables etc
	},
	['medic'] = {
		title = "Medical Crafting",
		objects = { 'p_chestmedice01x','p_boxmedmedical01x','s_lootablemedicinecrate' },
		icon = "medical-bag", -- optional. Defaults to 'wrench'
		jobType = { ['mechanic'] = 1 }, -- NOTE: This checks TYPES not name. A new qb thing. It's good. Use it.
		locations = { vector3(948.81, -1552.64, 30.59), }, -- BOXZONE: If you add one of these objects (locations = ...) it will spawn boxzones
		spawnTable = { { coords = vector4(794.49, -2613.63, 87.97, 2.4), prop = 'ex_prop_ex_toolchest_01' } } -- SPAWNS TABLE: the spawnTable field holds a list of several tables with prop and location. If these are added it will SPAWN a table that's interactable
	},
	['food'] = {
		title = "Food Crafting",
		objects = {'p_campfirecombined01x','p_campfirecombined02x','p_campfirecombined03x','s_campfirecombined01x','s_campfireset01x','s_cul_cookfire01x','s_hobo_cookfire01x'},
		icon = "food-fork-drink",
	},
}

Config.UseSundownUtils = false

Config.BlueprintDudes = nil
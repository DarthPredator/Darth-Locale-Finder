local AddOnName, Engine = ...
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0")
local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")

_G[AddOnName] = Engine;

local upper, match = upper, match
local type, pairs = type, pairs

local missingLocCounters = {
	["enUS"] = 0,
	["deDE"] = 0,
	["esMX"] = 0,
	["frFR"] = 0,
	["itIT"] = 0,
	["koKR"] = 0,
	["ptBR"] = 0,
	["ruRU"] = 0,
	["zhTW"] = 0,
	["zhCN"] = 0,
}

local ABC = {
	"!", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}

local function CreateTabs()
	for i = 1, #ABC do
		E.Options.args.DarthLocaleFinder.args.localesTab.args["Tab_"..ABC[i]] = {
			type = 'group',
			name = ABC[i],
			args = {},
		}
	end
	for loc, _ in pairs(missingLocCounters) do
		E.Options.args.DarthLocaleFinder.args.missingTab.args["Tab_"..loc] = {
			type = 'group',
			name = loc,
			args = {},
		}
	end
end

local function CreateMissingLocales(parsedLocale, line)
	local translation = type(E.Libs.ACL.apps["ElvUI"][parsedLocale][line]) == "table" and "|cffD3CF00This is a table of translations. See the file in question to compare|r" or E.Libs.ACL.apps["ElvUI"][parsedLocale][line]
	E.Options.args.DarthLocaleFinder.args.missingTab.args["Tab_"..parsedLocale].args[line] ={
		type = "group",
		order = 10,
		name = line,
		-- guiInline = true,
		args = {
			original = {
				type = "input",
				order = 1,
				name = "Original",
				width = "full",
				get = function() return line end,
				set = function() end,
			},
			translation = {
				type = "input",
				order = 2,
				name = "Translation",
				width = "full",
				get = function() return translation end,
				set = function() end,
			},
		},
		
	}
end

local function ClearMissingCounters()
	for loc, missing in pairs(missingLocCounters) do
		missingLocCounters[loc] = 0
	end
end

local function IsLineMissing(parsedLocale, line)
	if parsedLocale ~= "enUS" and E.Libs.ACL.apps["ElvUI"][parsedLocale][line] == line then
		return true
	elseif ((L == EngLocale or parsedLocale == "enUS") and E.Libs.ACL.elvUIMissingLines[line]) then
		return true
	else
		return false
	end
end

local function BuildTableList()
	local EngLocale = E.Libs.ACL:GetLocale("ElvUI", "enUS")
	ClearMissingCounters()
	E.Options.args.DarthLocaleFinder.args.missingInfoLine.name = "Missing lines in..."
	-- print(ActualLocale["Condensed (Spaced)"])
	-- for line, translation in pairs(EngLocale) do
	-- print(L == E.Libs.ACL.apps["ElvUI"]["enUS"])
	-- print(GetLocale())
	for line, translation in pairs(L) do
		local first = line:match("^.?[\128-\191]*"):upper()
		local tabName = E.Options.args.DarthLocaleFinder.args.localesTab.args["Tab_"..first] and "Tab_"..first or "Tab_!"
		local forcedWarning = false
		E.Options.args.DarthLocaleFinder.args.localesTab.args[tabName].args[line] = {
			type = 'group',
			name = line,
			args = {},
		}
		if type(translation) == "table" then
			forcedWarning = true;
			translation = "|cffD3CF00This is a table of translations. See the file in question to compare|r"
		end
		E.Options.args.DarthLocaleFinder.args.localesTab.args[tabName].args[line].args.supposedToBe = {
			type = "input",
			order = 1,
			name = 'As seen in code',
			width = "full",
			get = function() return translation end,
			set = function() end,
		}
		for parsedLocale, missing in pairs(missingLocCounters) do
			E.Options.args.DarthLocaleFinder.args.localesTab.args[tabName].args[line].args[parsedLocale] = {
				type = "input",
				order = 10,
				name = parsedLocale,
				width = "full",
				get = function() return E.Libs.ACL.apps["ElvUI"][parsedLocale][line] end,
				set = function() end,
			}
			-- if L == EngLocale then
				-- if L[line] == true then print(line) end
			-- end
			-- if (loc ~= "enUS" and E.Libs.ACL.apps["ElvUI"][loc][line] == line) or (L ~= EngLocale and EngLocale[line] == L[line]) or forcedWarning then
			
			if forcedWarning or IsLineMissing(parsedLocale, line) then
				missingLocCounters[parsedLocale] = missing + 1
				CreateMissingLocales(parsedLocale, line)
			end
		end
	end
	
	for loc, missing in pairs(missingLocCounters) do
		local color = missing > 100 and "E30000" or missing > 5 and "D3CF00" or "00FF00"
		E.Options.args.DarthLocaleFinder.args.missingInfoLine.name = E.Options.args.DarthLocaleFinder.args.missingInfoLine.name.." "..loc..": |cff"..color..missing.."|r;"
	end
end

function AddOn:ConfigTable()
	E.Options.args.DarthLocaleFinder = {
		order = 500,
		type = 'group',
		name = "|cff9482c9Darth's|r Locale Finder",
		childGroups = 'tab',
		args = {
			header = {
				order = 1,
				type = "header",
				name = "|cff9482c9Darth's|r Locale Finder",
			},
			parseLocales = {
				order = 2,
				type = 'execute',
				name = "Get Locales",
				desc = "Parse locale tables",
				func = function() BuildTableList() end,
			},
			missingInfoLine = {
				type = "description",
				order = 3,
				name = "Missing lines in..."
			},
			missingTab = {
				type = 'group',
				name = "Missing",
				childGroups = 'tab',
				order = 10,
				args = {
					empty = {
						type = "group",
						order = 1,
						name = "!",
						args = {
							emptyString = {
								type = "description",
								order = 1,
								name = "This is the starting tab in case of too many lines in deDE locale.\nWhen locales are parsed, you can find any untranslated ones for locale you want in the corresponding tab of this section.",
							}
						},
					}
				},
			},
			localesTab = {
				type = 'group',
				name = "Locales",
				order = 11,
				args = {},
				childGroups = 'tab',
			},
		}
	}
	CreateTabs()
end


function AddOn:OnInitialize()
	EP:RegisterPlugin(AddOnName, AddOn.ConfigTable)
end
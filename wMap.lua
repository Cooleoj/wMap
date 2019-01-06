local wMap = LibStub("AceAddon-3.0"):NewAddon("wMap", "AceConsole-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local _G = _G
local pairs = pairs
local tostring = tostring
local PlaySound = PlaySound
local LoadAddOn = LoadAddOn
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local ToggleCalendar = ToggleCalendar
local ToggleTimeManager = ToggleTimeManager
local TimeManager_TurnOffAlarm = TimeManager_TurnOffAlarm
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
-- GLOBALS: LibStub, Minimap, UIParent, TimeManagerClockButton, TimeManagerFrame
-- GLOBALS: GameTimeFrame, MinimapCluster, GameTimeCalendarInvitesTexture

local defaults = {
	profile = {
		PosX = 0,
		PosY = 0,
		Scale = 1,
		Position = "TOPRIGHT",
		border = {
			size = 1,
			color = { r = 1, g = 1, b = 1, a = 1 }
		},
		clock = {
			font = {
				-- name = nil,
				type = "OUTLINE",
				size = 18,
				color = { r = 1, g = 1, b = 1, a = 1 },
			},
		},
	},
}

local positionOptions = {
	["TOP"] = "TOP",
	["RIGHT"] = "RIGHT",
	["BOTTOM"] = "BOTTOM",
	["LEFT"] = "LEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["TOPLEFT"] = "TOPLEFT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["CENTER"] = "CENTER",
}

local fontTypes = {
	[""] = "None",
	["OUTLINE"] = "Outline",
	["THICKOUTLINE"] = "Thick outline",
	["MONOCHROME"] = "Monochrome",
}

local options = {
	name = "wMap",
	handler = wMap,
	type = 'group',
	args = {
		Position = {
			name = "Position",
			desc = "The position of the minimap.",
			type = 'select',
			order = 0,
			values = function()
				return positionOptions
			end,
			get = function()
				return wMap:GetPosition()
			end,
			set = function(info, newValue)
				wMap:SetPosition(info, newValue)
			end,
		},
		PosX = {
			type = "input",
			name = "XPosition",
			order = 1,
			desc = "The X position of minimap relative to Position",
			usage = "<PosX>",
			get = function()
				local posX = wMap:GetPosX()
				return tostring(posX)
			end,
			set = function(info, newValue)
				wMap:SetPosX(info, newValue)
			end,
		},
		PosY = {
			type = "input",
			name = "YPosition",
			order = 2,
			desc = "The Y position of minimap relative to Position",
			usage = "<PosY>",
			get = function()
				local posY = wMap:GetPosY()
				return tostring(posY)
			end,
			set = function(info, newValue)
				wMap:SetPosY(info, newValue)
			end,
		},
		Scale = {
			type = "input",
			name = "Scale",
			order = 3,
			desc = "The scale of the minimap.",
			usage = "<Scale>",
			get = function()
				local scale = wMap:GetScale()
				return tostring(scale)
			end,
			set = function(info, newValue)
				wMap:SetScale(info, newValue)
			end,
		},
		border = {
			order = 4,
			type = "group",
			guiInline = true,
			name = "Border",
			args = {
				size = {
					type = "input",
					name = "Border size",
					order = 0,
					desc = "The size of the border.",
					usage = "<Size>",
					get = function()
						local size = wMap:GetBorderSize()
						return tostring(size)
					end,
					set = function(info, newValue)
						wMap:SetBorderSize(info, newValue)
					end,
				},
				color = {
					name = "Border color",
					desc = "The color of the border.",
					type = "color",
					order = 1,
					hasAlpha = true,
					get = function()
						local color = wMap.db.profile.border.color
						return color.r, color.g, color.b, color.a
					end,
					set = function(info, r, g, b, a)
						wMap:SetBorderColor(info, r, g, b, a)
					end,
				},
			},
		},
		clock = {
			order = 4,
			type = "group",
			guiInline = true,
			name = "Clock",
			args ={
				font = {
					order = 0,
					type = "group",
					guiInline = true,
					name = "Fonts",
					args = {
						name = {
							order = 1,
							type = "select",
							name ="Font name",
							dialogControl = "LSM30_Font",
							values = _G.AceGUIWidgetLSMlists.font,
							get = function()
								return wMap:GetClockFontName()
							end,
							set = function(info, newValue)
								wMap:SetClockFontName(info, newValue)
							end,
						},
						type = {
							name = "Font type",
							desc = "The fonts type.",
							type = 'select',
							order = 2,
							values = function()
								return fontTypes
							end,
							get = function()
								return wMap:GetClockFontType()
							end,
							set = function(info, newValue)
								wMap:SetClockFontType(info, newValue)
							end,
						},
						size = {
							order = 3,
							type = "range",
							name = "Font size",
							min = 1, max = 100, step = 1,
							get = function()
								return wMap:GetClockFontSize()
							end,
							set = function(info, newValue)
								wMap:SetClockFontSize(info, newValue)
							end,
						},
						color = {
							name = "Text color",
							desc = "The color of the text.",
							type = "color",
							order = 4,
							hasAlpha = true,
							get = function()
								local color = wMap.db.profile.clock.font.color
								return color.r, color.g, color.b, color.a
							end,
							set = function(info, r, g, b, a)
								wMap:SetClockFontColor(info, r, g, b, a)
							end,
						},
					},
				},
			},
		}
	}
}

function wMap:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("wMapDB", defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "Init_wMap")
	self.db.RegisterCallback(self, "OnProfileCopied", "Init_wMap")
	self.db.RegisterCallback(self, "OnProfileReset", "Init_wMap")

	LSM.RegisterCallback( wMap, "LibSharedMedia_Registered", "MediaUpdate" )
	LSM.RegisterCallback( wMap, "LibSharedMedia_SetGlobal", "MediaUpdate" )

	local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("wMap", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Profiles", profileOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("wMap", "wMap")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Profiles", "Profiles", "wMap")
	self:RegisterChatCommand("wMap", "ChatCommand")

	LibStub("AceConfigRegistry-3.0"):NotifyChange("wMap");
	self:Init_wMap()
end

function wMap:OnEnable()
	-- Called when the addon is enabled
end

function wMap:OnDisable()
	-- Called when the addon is disabled
end

function wMap:MediaUpdate()
	self:SetUpClock()
end

function wMap:GetPosX()
	return self.db.profile.PosX
end

function wMap:SetPosX(_, newValue)
	self.db.profile.PosX = newValue
	Minimap:SetPoint(self.db.profile.Position, UIParent, self.db.profile.Position, self.db.profile.PosX, self.db.profile.PosY)
end

function wMap:GetPosY()
	return self.db.profile.PosY
end

function wMap:SetPosY(_, newValue)
	self.db.profile.PosY = newValue
	Minimap:SetPoint(self.db.profile.Position, UIParent, self.db.profile.Position, self.db.profile.PosX, self.db.profile.PosY)
end

function wMap:GetPosition()
	return self.db.profile.Position
end

function wMap:SetPosition(_, newValue)
	self.db.profile.Position = newValue
	Minimap:ClearAllPoints()
	Minimap:SetPoint(self.db.profile.Position, UIParent, self.db.profile.Position, self.db.profile.PosX, self.db.profile.PosY)
end

function wMap:GetScale()
	return self.db.profile.Scale
end

function wMap:SetClockFontName(_, newValue)
	self.db.profile.clock.font.name = newValue

	self:UpdateClockFont()
end

function wMap:GetClockFontName()
	return LibStub("LibSharedMedia-3.0"):IsValid("font", self.db.profile.clock.font.name) and self.db.profile.clock.font.name or LibStub("LibSharedMedia-3.0"):GetDefault("font")
end

function wMap:SetClockFontSize(_, newValue)
	self.db.profile.clock.font.size = newValue

	self:UpdateClockFont()
end

function wMap:GetClockFontSize()
	return self.db.profile.clock.font.size
end

function wMap:SetClockFontType(_, newValue)
	self.db.profile.clock.font.type = newValue

		self:UpdateClockFont()
end

function wMap:GetClockFontType()
	return self.db.profile.clock.font.type
end

function wMap:SetClockFontColor(_, r, g, b, a)
	self.db.profile.clock.font.color.r = r
	self.db.profile.clock.font.color.g = g
	self.db.profile.clock.font.color.b = b
	self.db.profile.clock.font.color.a = a

	self.ClockTime:SetTextColor(color.r, color.g, color.b, color.a)
end

function wMap:SetScale(_, newValue)
	self.db.profile.Scale = newValue

	Minimap:SetSize(180*self:GetScale(), 180*self:GetScale())
	Minimap:SetHitRectInsets(0, 0, 24*self:GetScale(), 24*self:GetScale())
	Minimap:SetPoint(self:GetPosition(), UIParent, self:GetPosition(), self:GetPosX(), self:GetPosY())
	Minimap:SetScale(self:GetScale())
	self.BorderFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -(22*self:GetScale()))
	self.BorderFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 1, (22*self:GetScale()))
end

function wMap:SetBorderSize(_, newValue)
	self.db.profile.border.size = newValue

	local texture = "Interface\\Buttons\\WHITE8x8"
	local backdrop = {
		edgeFile = texture,
		edgeSize = self:GetBorderSize()
	}

	self.BorderFrame:SetBackdrop(backdrop)
end

function wMap:GetBorderSize()
	return self.db.profile.border.size
end

function wMap:SetBorderColor(_, r, g, b, a)
	local color = self.db.profile.border.color
	color[1], color[2], color[3], color[4] = r, g, b, a

	self.BorderFrame:SetBackdropBorderColor(self:GetBorderColor())
end

function wMap:GetBorderColor()
	local color = self.db.profile.border.color
	return color[1], color[2], color[3], color[4]
end

function wMap:ChatCommand(input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	else
		LibStub("AceConfigCmd-3.0"):HandleCommand("wMap", input)
	end
end

function wMap:UpdateClockFont()
	local font = self.db.profile.clock.font
	self.ClockTime:SetFont(LSM:Fetch("font", font.name), font.size, font.type)


end

function wMap:Init_wMap()
	local mediaFolder = "Interface\\AddOns\\wMap\\media\\"   -- don't touch this ...
	local size_x = 180
	local size_y = 180

	MinimapCluster:EnableMouse(false)

	Minimap:SetSize(size_x*self:GetScale(), size_y*self:GetScale())
	Minimap:SetMaskTexture(mediaFolder.."rectangle.tga")
	Minimap:SetHitRectInsets(0, 0, 24*self:GetScale(), 24*self:GetScale())
	Minimap:SetFrameLevel(4)
	Minimap:ClearAllPoints()
	Minimap:SetPoint(self:GetPosition(), UIParent, self:GetPosition(), self:GetPosX(), self:GetPosY())
	Minimap:SetScale(self:GetScale())

	Minimap:SetArchBlobRingScalar(0);
	Minimap:SetQuestBlobRingScalar(0);

	local border = {
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = self:GetBorderSize()
	}

	self.BorderFrame = CreateFrame("Frame", nil, Minimap)
	self.BorderFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -(22*self:GetScale()))
	self.BorderFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 1, (22*self:GetScale()))
	self.BorderFrame:SetBackdrop(border)
	self.BorderFrame:SetBackdropBorderColor(self:GetBorderColor())
	self.BorderFrame:SetFrameLevel(6)

	self:SetUpClock()
	self:HideUgly()
end


--[[ Clock ]]
function wMap:SetUpClock()
	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn("Blizzard_TimeManager")
	end

	self.ClockFrame, self.ClockTime = TimeManagerClockButton:GetRegions()
	self.ClockFrame:Hide()
	self.ClockTime:SetFont(LSM:Fetch("font", self:GetClockFontName()), self:GetClockFontSize(), self:GetClockFontType())
	self.ClockTime:SetShadowOffset(0,0)
	local color = self.db.profile.clock.font.color
	self.ClockTime:SetTextColor(color.r, color.g, color.b, color.a)
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 20)
	TimeManagerClockButton:SetScript('OnShow', nil)
	TimeManagerClockButton:Show()
	TimeManagerClockButton:SetScript('OnClick', function(clockButton, button)
		if(button=="RightButton") then
			if(clockButton.alarmFiring) then
				PlaySound('igMainMenuQuit')
				TimeManager_TurnOffAlarm()
			else
				ToggleTimeManager()
			end
		else
			ToggleCalendar()
		end
	end)
	TimeManagerFrame:ClearAllPoints()
	TimeManagerFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
	TimeManagerFrame:SetClampedToScreen(true)
	TimeManagerFrame:SetToplevel(true)
end
--[[ Hiding ugly things	]]
function wMap:HideUgly()
	--[[ Hiding ugly things ]]
	local dummy = function() end
	local frames = {
		-- "MiniMapVoiceChatFrame",
		"MiniMapWorldMapButton",
		"MinimapZoneTextButton",
		"MiniMapMailBorder",
		"MiniMapInstanceDifficulty",
		"MinimapNorthTag",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MinimapBackdrop",
		"GameTimeFrame",
		"GuildInstanceDifficulty",
		"MiniMapChallengeMode",
		"MinimapBorderTop",
	}
	GameTimeFrame:SetAlpha(0)
	GameTimeFrame:EnableMouse(false)
	GameTimeCalendarInvitesTexture:SetParent("Minimap")
	for i in pairs(frames) do
		_G[frames[i]]:Hide()
		_G[frames[i]].Show = dummy
	end
end

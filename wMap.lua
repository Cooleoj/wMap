local wMap = LibStub("AceAddon-3.0"):NewAddon("wMap", "AceConsole-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local defaults = {
    profile = {
        PosX = 0,
        PosY = 0,
        Scale = 1,
        Position = "TOPRIGHT",
        font = {
          -- name = nil,
          size = 18,
        },
    },
}

local options = {
    name = "wMap",
    handler = wMap,
    type = 'group',
    args = {
      PosX = {
            type = "input",
            name = "XPosition",
            order = 1,
            desc = "The X position of minimap relative to Position",
            usage = "<PosX>",
            get = "GetPosX",
            set = "SetPosX",
        },
      PosY = {
            type = "input",
            name = "YPosition",
            order = 2,
            desc = "The Y position of minimap relative to Position",
            usage = "<PosY>",
            get = "GetPosY",
            set = "SetPosY",
        },
      Position = {
          	name = "Position",
          	desc = "The position of the minimap.",
          	type = 'select',
          	order = 0,
          	values = function()
          		positions = {
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
          		return positions
          	end,
            get = "GetPosition",
            set = "SetPosition",
        },
      Scale = {
            type = "input",
            name = "Scale",
            order = 3,
            desc = "The scale of the minimap.",
            usage = "<Scale>",
            get = "GetScale",
            set = "SetScale",
        },
      font = {
          order = 21,
          type = "group",
          guiInline = true,
          name = "Fonts",
          args = {
            name = {
              order = 1,
              type = "select",
              name ="Font name",
              dialogControl = "LSM30_Font",
              values = AceGUIWidgetLSMlists.font,
              get = "GetFontName",
              set = "SetFontName",
            },
            size = {
              order = 2,
              type = "range",
              name = "Font size",
              min = 10, max = 20, step = 1,
              get = function()
                return wMap.db.profile.font.size
              end,
              set = "SetFontSize",
            },
          },
    },
  }
}

function wMap:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("wMapDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("wMap", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("wMap", "wMap")
    self:RegisterChatCommand("wMap", "ChatCommand")

    self:Init_wMap()
end

function wMap:OnEnable()
    -- Called when the addon is enabled
end

function wMap:OnDisable()
    -- Called when the addon is disabled
end

function wMap:GetPosX(info)
    return self.db.profile.PosX
end

function wMap:SetPosX(info, newValue)
    self.db.profile.PosX = newValue
    Minimap:SetPoint(self.db.profile.Position, UIParent, self.db.profile.Position, self.db.profile.PosX, self.db.profile.PosY)
end

function wMap:GetPosY(info)
    return self.db.profile.PosY
end

function wMap:SetPosY(info, newValue)
    self.db.profile.PosY = newValue
    Minimap:SetPoint(self.db.profile.Position, UIParent, self.db.profile.Position, self.db.profile.PosX, self.db.profile.PosY)
end

function wMap:GetPosition(info)
    return self.db.profile.Position
end

function wMap:SetPosition(info, newValue)
    self.db.profile.Position = newValue
    Minimap:ClearAllPoints()
    Minimap:SetPoint(self.db.profile.Position, UIParent, self.db.profile.Position, self.db.profile.PosX, self.db.profile.PosY)
end

function wMap:GetScale(info)
    return self.db.profile.Scale
end

function wMap:SetFontName(info, newValue)
  self.db.profile.font.name = newValue

  local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
  clockTime:SetFont(LSM:Fetch("font", self.db.profile.font.name), self.db.profile.font.size, "OUTLINE")

  TimeManagerClockButton:ClearAllPoints()
  TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", -1, 14)
  TimeManagerClockButton:Show()
end

function wMap:GetFontName(info)
  return LibStub("LibSharedMedia-3.0"):IsValid("font", self.db.profile.font.name) and self.db.profile.font.name or LibStub("LibSharedMedia-3.0"):GetDefault("font")
end

function wMap:SetFontSize(info, newValue)
  self.db.profile.font.size = newValue

  local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
  clockTime:SetFont(LSM:Fetch("font", self.db.profile.font.name), self.db.profile.font.size, "OUTLINE")

  TimeManagerClockButton:ClearAllPoints()
  TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", -1, 14)
  TimeManagerClockButton:Show()
end

function wMap:SetScale(info, newValue)
    self:SetScale(newValue)
    Minimap:SetSize(180*self:GetScale(), 180*self:GetScale())
    Minimap:SetHitRectInsets(0, 0, 24*self:GetScale(), 24*self:GetScale())
    Minimap:SetPoint(self:GetPosition(), UIParent, self:GetPosition(), self:GetPosX(), self:GetPosY())
    Minimap:SetScale(self:GetScale())
    BorderFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -(22*self:GetScale()))
    BorderFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 1, (22*self:GetScale()))
end

function wMap:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("wMap", input)
    end
end

function wMap:Init_wMap()
  local mediaFolder = "Interface\\AddOns\\wMap\\media\\"   -- don't touch this ...
  local size_x = 180
  local size_y = 180
  local classcolors = true -- class color text
  local color = {r=255/255, g=255/255, b=255/255 }
  local texture = "Interface\\Buttons\\WHITE8x8"
  local backdrop = {edgeFile = texture, edgeSize = 1}
  local backdropcolor = {0/255, 0/255, 0/255}     -- backdrop color
  local brdcolor = {0/255, 0/255, 0/255}              -- backdrop border color
  local wMap = CreateFrame("Frame", "wMap", UIParent)

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

  BorderFrame = CreateFrame("Frame", nil, Minimap)
  BorderFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -(22*self:GetScale()))
  BorderFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 1, (22*self:GetScale()))
  BorderFrame:SetBackdrop(backdrop)
  BorderFrame:SetBackdropBorderColor(unpack(brdcolor))
  BorderFrame:SetBackdropColor(unpack(backdropcolor))
  BorderFrame:SetFrameLevel(6)

  self:SetUpClock()
  self:HideUgly()
end


--[[ Clock ]]
function wMap:SetUpClock()
  local mediaFolder = "Interface\\AddOns\\wMap\\media\\"   -- don't touch this ...
  local font = mediaFolder.."big_noodle_titling.ttf"
  local fontsize = 20
  local fontflag = "OUTLINE"
  local size_x = 180
  local size_y = 180
  local classcolors = true -- class color text
  local color = {r=255/255, g=255/255, b=255/255 }
  local texture = "Interface\\Buttons\\WHITE8x8"
  local backdrop = {edgeFile = texture, edgeSize = 1}
  local backdropcolor = {0/255, 0/255, 0/255}     -- backdrop color
  local brdcolor = {0/255, 0/255, 0/255}              -- backdrop border color

  if not IsAddOnLoaded("Blizzard_TimeManager") then
  	LoadAddOn("Blizzard_TimeManager")
  end
  local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
  clockFrame:Hide()
  clockTime:SetFont(font, fontsize, fontflag)
  clockTime:SetShadowOffset(0,0)
  clockTime:SetTextColor(color.r, color.g, color.b)
  TimeManagerClockButton:ClearAllPoints()
  TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", -1, 14)
  TimeManagerClockButton:SetScript('OnShow', nil)
  TimeManagerClockButton:Show()
  TimeManagerClockButton:SetScript('OnClick', function(self, button)
  	if(button=="RightButton") then
  		if(self.alarmFiring) then
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

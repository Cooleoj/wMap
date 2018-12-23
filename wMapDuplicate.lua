local mediaFolder = "Interface\\AddOns\\QuseMap\\media\\"   -- don't touch this ...

-- Config
-- Fonts
local font = mediaFolder.."big_noodle_titling.ttf"
local fontsize = 20
local fontflag = "OUTLINE"

-- Position, size & scale
local PosX
local PosY
local Position
local Scale

local size_x = 180
local size_y = 180

-- Color & theme
local classcolors = true -- class color text
local color = {r=255/255, g=255/255, b=255/255 }

local mediaFolder = "Interface\\AddOns\\QuseMap\\media\\"   -- don't touch this ...

local texture = "Interface\\Buttons\\WHITE8x8"
local backdrop = {edgeFile = texture, edgeSize = 1}

local backdropcolor = {0/255, 0/255, 0/255}     -- backdrop color
local brdcolor = {0/255, 0/255, 0/255}              -- backdrop border color

local wMap = CreateFrame("Frame", "QuseMap", UIParent)
wMap:RegisterEvent("ADDON_LOADED")
wMap:RegisterEvent("PLAYER_LOGOUT");

function wMap:OnEvent(event, arg1)
  if event == "ADDON_LOADED" then
    if SavedScale == nil then
      SavedScale = 1
    end

    if SavedPosX == nil then
      SavedPosX = 0
    end

    if SavedPosY == nil then
      SavedPosY = 0
    end

    if SavedPosition == nil then
      SavedPosition = "TOPRIGHT"
    end

    Scale = SavedScale
    PosX = SavedPosX
    PosY = SavedPosY
    Position = SavedPosition

    InitWmap()
  elseif event == "PLAYER_LOGOUT" then
    SavedScale = Scale
    SavedPosX = PosX
    SavedPosY = PosY
    SavedPosition = Position
  end
end


  SLASH_WMAP1 = "/wmap"
  SlashCmdList["WMAP"] = function(msg)

    if msg == "config" then
      CreateFrame("Frame","ConfigFrame",UIParent,"BasicFrameTemplate")

      ConfigFrame:SetSize(600,400)
      ConfigFrame:SetPoint("CENTER")

      ConfigFrame:Show()

      ConfigFrame.PosXEdit = CreateFrame("EditBox", "PosXEdit", ConfigFrame, "InputBoxTemplate" );
      ConfigFrame.PosXEdit:SetPoint("LEFT",0,-50)
      ConfigFrame.PosXEdit:SetSize(300,30)

      ConfigFrame.PosXOKButton = CreateFrame("Button","PosXOKButton",ConfigFrame,"UIPanelButtonTemplate")
      ConfigFrame.PosXOKButton:SetSize(150,22)
      ConfigFrame.PosXOKButton:SetPoint("LEFT",305,-50)
      ConfigFrame.PosXOKButton:SetText("OK")
      ConfigFrame.PosXOKButton:SetScript("OnClick",
      function(self, arg1)
        SetXPos(ConfigFrame.PosXEdit:GetText())
      end)
    end

    parameters = { }
    index = 1

    for value in string.gmatch(msg, "%w+") do
      parameters[index] = value
      index = index + 1
    end
    if parameters[1] == "scale" then
      arg = string.sub (msg, 7, -1)
      -- Should perform check here
      Scale = arg
      Minimap:SetSize(size_x*Scale, size_y*Scale)
      Minimap:SetHitRectInsets(0, 0, 24*Scale, 24*Scale)
      Minimap:SetScale(Scale)

    elseif parameters[1] == "x" then
      arg = string.sub (msg, 2, -1)
      -- Should perform check here
      SetXPos(arg)

    elseif parameters[1] == "y" then
      arg = string.sub (msg, 2, -1)
      -- Should perform check here
      SetYPos(arg)

    elseif parameters[1] == "pos" then
      arg = string.sub (msg, 5, -1)
      -- Should perform check here
      Position = arg
      print(arg)
      Minimap:ClearAllPoints()
      Minimap:SetPoint(Position, UIParent, Position, PosX, PosY)

    end
  end

wMap:SetScript("OnEvent", wMap.OnEvent);

function SetXPos(arg)
  -- Should perform check on arg here
  PosX = arg
  Minimap:SetPoint(Position, UIParent, Position, PosX, PosY)
end

function SetYPos(arg)
  -- Should perform check on arg here
  PosY = arg
  Minimap:SetPoint(Position, UIParent, Position, PosX, PosY)
end

function InitWmap()
-- Style
  MinimapCluster:EnableMouse(false)

  Minimap:SetSize(size_x*Scale, size_y*Scale)
  Minimap:SetMaskTexture(mediaFolder.."rectangle")
  Minimap:SetHitRectInsets(0, 0, 24*Scale, 24*Scale)
  Minimap:SetFrameLevel(4)
  Minimap:ClearAllPoints()
  print(PosX..", "..PosY)
  Minimap:SetPoint(Position, UIParent, Position, PosX, PosY)
  Minimap:SetScale(Scale)

  Minimap:SetArchBlobRingScalar(0);
  Minimap:SetQuestBlobRingScalar(0);

  BorderFrame = CreateFrame("Frame", nil, Minimap)
  BorderFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -(22*Scale))
  BorderFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 1, (22*Scale))
  BorderFrame:SetBackdrop(backdrop)
  BorderFrame:SetBackdropBorderColor(unpack(brdcolor))
  BorderFrame:SetBackdropColor(unpack(backdropcolor))
  BorderFrame:SetFrameLevel(6)

  SetUpClock()
  HideUgly()
end


--[[ Clock ]]
function SetUpClock()
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
function HideUgly()
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

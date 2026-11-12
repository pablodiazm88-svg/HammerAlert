-- HammerAlert v2.7
-- Creado por EKO

local HAMMER_ID = 24275
local SOUND_ID = 50111
local HAMMER_TEXTURE = 132326

local controller = CreateFrame("Frame")
DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00HammerAlert v2.7 iniciado!|r")

HammerAlertDB = HammerAlertDB or {}
if HammerAlertDB.x == nil then
    HammerAlertDB.x = 0
end
if HammerAlertDB.y == nil then
    HammerAlertDB.y = 100
end
if HammerAlertDB.size == nil then
    HammerAlertDB.size = 80
end
if HammerAlertDB.sound == nil then
    HammerAlertDB.sound = true
end

local icon = CreateFrame("Frame", "HammerAlertIcon", UIParent)
local texture = icon:CreateTexture(nil, "ARTWORK")
texture:SetAllPoints(icon)
texture:SetTexture(HAMMER_TEXTURE)

local glow = icon:CreateTexture(nil, "OVERLAY")
glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
glow:SetBlendMode("ADD")
glow:SetVertexColor(1, 0.88, 0.48)
glow:SetPoint("CENTER", icon, "CENTER", 0, 0)

local sparks = {}
for index = 1, 8 do
    local spark = icon:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    spark:SetBlendMode("ADD")
    sparks[index] = spark
end

local animationTime = 0

local function AnimateGlow(self, elapsed)
    animationTime = (animationTime + elapsed) % 1.4
    local phase = animationTime / 1.4
    glow:SetAlpha(0.72 + 0.28 * (0.5 + 0.5 * math.cos(phase * 2 * math.pi)))

    local size = HammerAlertDB.size
    local halfSide = size * 0.53

    for index, spark in ipairs(sparks) do
        local tailIndex = (index - 1) % 4
        local opposite = math.floor((index - 1) / 4) * 0.5
        local perimeter = ((phase + opposite - tailIndex * 0.018) % 1) * 4
        local side = math.floor(perimeter)
        local offset = (perimeter - side) * 2 * halfSide
        local x, y

        if side == 0 then
            x, y = -halfSide + offset, halfSide
        elseif side == 1 then
            x, y = halfSide, halfSide - offset
        elseif side == 2 then
            x, y = halfSide - offset, -halfSide
        else
            x, y = -halfSide, -halfSide + offset
        end

        local sparkSize = math.max(2, size * (0.075 - tailIndex * 0.009))
        spark:SetWidth(sparkSize)
        spark:SetHeight(sparkSize)
        spark:SetVertexColor(1, 1 - tailIndex * 0.09, 0.9 - tailIndex * 0.20, 1 - tailIndex * 0.16)
        spark:ClearAllPoints()
        spark:SetPoint("CENTER", self, "CENTER", x, y)
    end
end

icon:SetScript("OnShow", function(self)
    animationTime = 0
    AnimateGlow(self, 0)
    self:SetScript("OnUpdate", AnimateGlow)
end)

icon:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil)
end)

local function ApplySettings()
    local glowSize = HammerAlertDB.size * 1.8
    glow:SetWidth(glowSize)
    glow:SetHeight(glowSize)
    icon:SetWidth(HammerAlertDB.size)
    icon:SetHeight(HammerAlertDB.size)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", UIParent, "CENTER", HammerAlertDB.x, HammerAlertDB.y)
end

ApplySettings()
icon:SetMovable(true)
icon:SetClampedToScreen(true)
icon:EnableMouse(false)
icon:RegisterForDrag("LeftButton")
icon:Hide()

local testMode = false
local dragging = false
local wasAvailable = false

local positionLoader = CreateFrame("Frame")
positionLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
positionLoader:SetScript("OnEvent", function()
    ApplySettings()
end)

local function PlayHammerSound()
    if HammerAlertDB.sound and type(PlaySound) == "function" then
        PlaySound(SOUND_ID)
    end
end

icon:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        dragging = true
        self:StartMoving()
    end
end)

icon:SetScript("OnDragStop", function(self)
    if not dragging then
        return
    end

    self:StopMovingOrSizing()
    dragging = false

    local x, y = self:GetCenter()
    local parentX, parentY = UIParent:GetCenter()

    if x and y and parentX and parentY then
        HammerAlertDB.x = x - parentX
        HammerAlertDB.y = y - parentY
        ApplySettings()
        DEFAULT_CHAT_FRAME:AddMessage("HammerAlert: Posicion guardada.")
    end
end)

local function FindHammer()
    for slot = 1, 120 do
        local actionType, actionID = GetActionInfo(slot)

        if actionType == "spell" and actionID == HAMMER_ID then
            return slot
        end
    end

    return nil
end

local function UpdateHammerTexture(slot)
    if slot then
        local actionTexture = GetActionTexture(slot)
        texture:SetTexture(actionTexture or HAMMER_TEXTURE)
    end
end

local settings = CreateFrame("Frame", "HammerAlertSettings", UIParent)
settings:SetWidth(300)
settings:SetHeight(205)
settings:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
settings:SetFrameStrata("DIALOG")
settings:EnableMouse(true)
settings:Hide()

local background = settings:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(settings)
background:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")

local title = settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", settings, "TOPLEFT", 16, -16)
title:SetText("HammerAlert")

local close = CreateFrame("Button", nil, settings, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", settings, "TOPRIGHT", -4, -4)
close:SetScript("OnClick", function()
    settings:Hide()
end)

local sizeLabel = settings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
sizeLabel:SetPoint("TOPLEFT", settings, "TOPLEFT", 16, -58)

local sound = CreateFrame("CheckButton", "HammerAlertSoundCheck", settings, "UICheckButtonTemplate")
sound:SetPoint("TOPLEFT", settings, "TOPLEFT", 10, -82)
local soundLabel = settings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
soundLabel:SetPoint("LEFT", sound, "RIGHT", 0, 0)
soundLabel:SetText("Activar sonido")

local preview = CreateFrame("CheckButton", "HammerAlertPreviewCheck", settings, "UICheckButtonTemplate")
preview:SetPoint("TOPLEFT", settings, "TOPLEFT", 10, -118)
local previewLabel = settings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
previewLabel:SetPoint("LEFT", preview, "RIGHT", 0, 0)
previewLabel:SetText("Mostrar icono para moverlo con Shift")

local function RefreshSettings()
    sizeLabel:SetText("Tamano del icono: " .. HammerAlertDB.size)
    sound:SetChecked(HammerAlertDB.sound)
    preview:SetChecked(testMode)
end

settings:SetScript("OnShow", RefreshSettings)

local function AddSettingsButton(label, width, x, y, callback)
    local button = CreateFrame("Button", nil, settings, "UIPanelButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(24)
    button:SetPoint("TOPLEFT", settings, "TOPLEFT", x, y)
    button:SetText(label)
    button:SetScript("OnClick", callback)
end

local function RunHammerCommand(command)
    SlashCmdList["HAMMERALERT"](command)
end

AddSettingsButton("-", 28, 219, -51, function()
    RunHammerCommand("size " .. math.max(30, HammerAlertDB.size - 5))
end)

AddSettingsButton("+", 28, 252, -51, function()
    RunHammerCommand("size " .. math.min(200, HammerAlertDB.size + 5))
end)

AddSettingsButton("Probar sonido", 120, 16, -164, function()
    RunHammerCommand("sound test")
end)

sound:SetScript("OnClick", function(self)
    RunHammerCommand(self:GetChecked() and "sound on" or "sound off")
end)

preview:SetScript("OnClick", function()
    RunHammerCommand("test")
end)

local function ToggleSettings()
    if settings:IsShown() then
        settings:Hide()
    else
        settings:Show()
    end
end

if Minimap then
    local minimapButton = CreateFrame("Button", "HammerAlertMinimapButton", Minimap)
    minimapButton:SetWidth(31)
    minimapButton:SetHeight(31)
    minimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    minimapButton:RegisterForDrag("LeftButton")

    local buttonBackground = minimapButton:CreateTexture(nil, "BACKGROUND")
    buttonBackground:SetWidth(20)
    buttonBackground:SetHeight(20)
    buttonBackground:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
    buttonBackground:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    local buttonTexture = minimapButton:CreateTexture(nil, "ARTWORK")
    buttonTexture:SetWidth(16)
    buttonTexture:SetHeight(16)
    buttonTexture:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
    buttonTexture:SetTexture(HAMMER_TEXTURE)
    buttonTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = minimapButton:CreateTexture(nil, "OVERLAY")
    border:SetWidth(53)
    border:SetHeight(53)
    border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local directionX = HammerAlertDB.minimapX or -0.87
    local directionY = HammerAlertDB.minimapY or -0.50

    local function PositionMinimapButton()
        local radius = math.min(Minimap:GetWidth(), Minimap:GetHeight()) / 2
        minimapButton:ClearAllPoints()
        minimapButton:SetPoint(
            "CENTER", Minimap, "CENTER", radius * directionX, radius * directionY
        )
    end

    local function FollowCursor()
        local centerX, centerY = Minimap:GetCenter()
        if not centerX or not centerY then
            return
        end

        local cursorX, cursorY = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        local x = cursorX / scale - centerX
        local y = cursorY / scale - centerY
        local distance = math.sqrt(x * x + y * y)

        if distance > 1 then
            directionX = x / distance
            directionY = y / distance
            PositionMinimapButton()
        end
    end

    minimapButton:SetScript("OnShow", PositionMinimapButton)
    minimapButton:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", FollowCursor)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        HammerAlertDB.minimapX = directionX
        HammerAlertDB.minimapY = directionY
    end)

    minimapButton:SetScript("OnClick", ToggleSettings)
    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("HammerAlert")
        GameTooltip:AddLine("Clic para abrir los ajustes", 1, 1, 1)
        GameTooltip:AddLine("Arrastra para mover el boton por el borde", 1, 1, 1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    PositionMinimapButton()
end

SLASH_HAMMERALERT1 = "/hammer"

SlashCmdList["HAMMERALERT"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "config" then
        ToggleSettings()
        return
    end

    local newSize = tonumber(string.match(msg, "^size%s+(%d+)$"))

    if newSize then
        if newSize >= 30 and newSize <= 200 then
            HammerAlertDB.size = newSize
            ApplySettings()
            RefreshSettings()
            DEFAULT_CHAT_FRAME:AddMessage(
                "HammerAlert: Tamano cambiado a " .. tostring(newSize)
            )
        else
            DEFAULT_CHAT_FRAME:AddMessage(
                "HammerAlert: Usa un tamano entre 30 y 200."
            )
        end

        return
    end

    if msg == "test" then
        testMode = not testMode
        RefreshSettings()

        if testMode then
            UpdateHammerTexture(FindHammer())
            icon:EnableMouse(true)
            icon:Show()
            DEFAULT_CHAT_FRAME:AddMessage("HammerAlert: Modo prueba ACTIVADO.")
            DEFAULT_CHAT_FRAME:AddMessage("Manten Shift y arrastra el icono.")
        else
            icon:EnableMouse(false)
            icon:Hide()
            wasAvailable = true
            DEFAULT_CHAT_FRAME:AddMessage("HammerAlert: Modo prueba DESACTIVADO.")
        end

        return
    end

    if msg == "sound on" then
        HammerAlertDB.sound = true
        RefreshSettings()
        DEFAULT_CHAT_FRAME:AddMessage("HammerAlert: Sonido ACTIVADO.")
        return
    end

    if msg == "sound off" then
        HammerAlertDB.sound = false
        RefreshSettings()
        DEFAULT_CHAT_FRAME:AddMessage("HammerAlert: Sonido DESACTIVADO.")
        return
    end

    if msg == "sound test" then
        PlayHammerSound()
        DEFAULT_CHAT_FRAME:AddMessage("HammerAlert: Prueba de sonido.")
        return
    end

    if msg == "info" then
        DEFAULT_CHAT_FRAME:AddMessage("HammerAlert - Configuracion:")
        DEFAULT_CHAT_FRAME:AddMessage("Tamano: " .. tostring(HammerAlertDB.size))
        DEFAULT_CHAT_FRAME:AddMessage("Posicion X: " .. tostring(HammerAlertDB.x))
        DEFAULT_CHAT_FRAME:AddMessage("Posicion Y: " .. tostring(HammerAlertDB.y))
        DEFAULT_CHAT_FRAME:AddMessage("Sonido: " .. tostring(HammerAlertDB.sound))
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00HammerAlert - Comandos:|r")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer config - Abrir ajustes")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer test - Mostrar u ocultar icono")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer size 80 - Cambiar tamano")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer sound on - Activar sonido")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer sound off - Desactivar sonido")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer sound test - Probar sonido")
    DEFAULT_CHAT_FRAME:AddMessage("/hammer info - Ver configuracion")
end

local timer = 0

controller:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed

    if timer < 0.2 then
        return
    end

    timer = 0

    if testMode then
        icon:Show()
        return
    end

    local slot = FindHammer()

    if not slot then
        icon:Hide()
        wasAvailable = false
        return
    end

    UpdateHammerTexture(slot)

    -- Avisar solo para el objetivo seleccionado durante el combate.
    local available = false

    if UnitAffectingCombat("player")
        and UnitExists("target")
        and UnitCanAttack("player", "target")
        and not UnitIsDead("target") then

        local usable = IsUsableAction(slot)
        available = usable == true or usable == 1
    end

    if available then
        icon:Show()

        if not wasAvailable then
            PlayHammerSound()
        end
    else
        icon:Hide()
    end

    wasAvailable = available
end)

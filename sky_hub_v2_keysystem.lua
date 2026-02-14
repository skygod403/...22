--[[ =======================================================================
	NEON MOVEMENT HUB + PIN
	Versão Final Estável
	Senha: Script 01

	Funcionalidades:
	- Tela de senha obrigatória
	- GUI neon animada PREMIUM
	- Velocidade fixa (não diminui)
	- Pulo infinito
	- Fly com WASD
	- NoClip
	- Respawn safe
	- Toggle com Z
	- ESP Players (vermelho, atravessa parede + linha de rastreio)

	LocalScript | Roblox
======================================================================= ]]

---------------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------------

local Players         = game:GetService("Players")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local CoreGui         = game:GetService("CoreGui")

---------------------------------------------------------------------------
-- PLAYER
---------------------------------------------------------------------------

local player = Players.LocalPlayer

---------------------------------------------------------------------------
-- CORES GLOBAIS (tema cyberpunk)
---------------------------------------------------------------------------

local C = {
	bg        = Color3.fromRGB(8,  8,  12),   -- fundo quase preto azulado
	panel     = Color3.fromRGB(14, 14, 22),   -- painel interno
	card      = Color3.fromRGB(20, 20, 32),   -- card dos botões
	border    = Color3.fromRGB(80, 60, 200),  -- roxo neon
	accent1   = Color3.fromRGB(120, 80, 255), -- roxo claro
	accent2   = Color3.fromRGB(0,  200, 255), -- ciano neon
	accent3   = Color3.fromRGB(255, 60, 120), -- rosa neon
	green     = Color3.fromRGB(0,  255, 160), -- verde neon
	white     = Color3.fromRGB(230, 230, 255),-- branco frio
	dim       = Color3.fromRGB(100, 100, 140),-- texto apagado
	btnOff    = Color3.fromRGB(22, 22, 36),   -- botão desativado
	btnOn     = Color3.fromRGB(30, 15, 60),   -- botão ativado (roxo escuro)
}

---------------------------------------------------------------------------
-- HELPERS DE TWEEN
---------------------------------------------------------------------------

local function tween(obj, t, props)
	TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props):Play()
end

---------------------------------------------------------------------------
-- HELPER: UIGradient diagonal no frame
---------------------------------------------------------------------------

local function addGradient(parent, c0, c1, rot)
	local g = Instance.new("UIGradient", parent)
	g.Color = ColorSequence.new(c0, c1)
	g.Rotation = rot or 135
	return g
end

---------------------------------------------------------------------------
-- HELPER: cria separador elegante
---------------------------------------------------------------------------

local function createSep(parent, y)
	local sep = Instance.new("Frame", parent)
	sep.Size = UDim2.new(1, -24, 0, 1)
	sep.Position = UDim2.new(0, 12, 0, y)
	sep.BackgroundColor3 = C.border
	sep.BackgroundTransparency = 0.6
	sep.BorderSizePixel = 0
	return sep
end

---------------------------------------------------------------------------
-- HELPER: label de seção com bolinha colorida
---------------------------------------------------------------------------

local function createSectionLabel(parent, text, y, dotColor)
	-- bolinha
	local dot = Instance.new("Frame", parent)
	dot.Size = UDim2.new(0, 6, 0, 6)
	dot.Position = UDim2.new(0, 14, 0, y + 11)
	dot.BackgroundColor3 = dotColor or C.accent2
	dot.BorderSizePixel = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local l = Instance.new("TextLabel", parent)
	l.Size = UDim2.new(1, -30, 0, 24)
	l.Position = UDim2.new(0, 26, 0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamBold
	l.TextSize = 11
	l.TextColor3 = dotColor or C.accent2
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

---------------------------------------------------------------------------
-- HELPER: cria TextBox estilizado
---------------------------------------------------------------------------

local function createStyledBox(parent, placeholder, y)
	local wrap = Instance.new("Frame", parent)
	wrap.Size = UDim2.new(1, -24, 0, 34)
	wrap.Position = UDim2.new(0, 12, 0, y)
	wrap.BackgroundColor3 = C.card
	wrap.BorderSizePixel = 0
	Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)

	-- borda brilhante
	local stroke = Instance.new("UIStroke", wrap)
	stroke.Thickness = 1
	stroke.Color = C.border
	stroke.Transparency = 0.5

	local b = Instance.new("TextBox", wrap)
	b.Size = UDim2.new(1, -12, 1, 0)
	b.Position = UDim2.new(0, 6, 0, 0)
	b.BackgroundTransparency = 1
	b.PlaceholderText = placeholder
	b.PlaceholderColor3 = C.dim
	b.Text = ""
	b.ClearTextOnFocus = false
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = C.white

	-- ao focar, ilumina a borda
	b.Focused:Connect(function()
		tween(stroke, 0.2, {Color = C.accent2, Transparency = 0})
	end)
	b.FocusLost:Connect(function()
		tween(stroke, 0.3, {Color = C.border, Transparency = 0.5})
	end)

	return b, wrap
end

---------------------------------------------------------------------------
-- HELPER: cria botão toggle estilizado
---------------------------------------------------------------------------

local function createStyledButton(parent, textOff, y, accentColor)
	local accent = accentColor or C.accent1

	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -24, 0, 36)
	btn.Position = UDim2.new(0, 12, 0, y)
	btn.BackgroundColor3 = C.btnOff
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = 1
	stroke.Color = accent
	stroke.Transparency = 0.6

	-- ícone de status (bolinha esquerda)
	local dot = Instance.new("Frame", btn)
	dot.Size = UDim2.new(0, 7, 0, 7)
	dot.Position = UDim2.new(0, 12, 0.5, -3)
	dot.BackgroundColor3 = C.dim
	dot.BorderSizePixel = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local label = Instance.new("TextLabel", btn)
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.new(0, 26, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = textOff
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = C.dim
	label.TextXAlignment = Enum.TextXAlignment.Left

	-- estado ON/OFF
	local isOn = false

	local function setState(on)
		isOn = on
		if on then
			tween(btn,   0.2, {BackgroundColor3 = C.btnOn})
			tween(stroke, 0.2, {Color = accent, Transparency = 0})
			tween(dot,   0.2, {BackgroundColor3 = accent})
			tween(label, 0.2, {TextColor3 = accent})
		else
			tween(btn,   0.2, {BackgroundColor3 = C.btnOff})
			tween(stroke, 0.2, {Color = accent, Transparency = 0.6})
			tween(dot,   0.2, {BackgroundColor3 = C.dim})
			tween(label, 0.2, {TextColor3 = C.dim})
		end
	end

	-- hover
	btn.MouseEnter:Connect(function()
		if not isOn then
			tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(28, 28, 45)})
			tween(stroke, 0.15, {Transparency = 0.2})
		end
	end)
	btn.MouseLeave:Connect(function()
		if not isOn then
			tween(btn, 0.15, {BackgroundColor3 = C.btnOff})
			tween(stroke, 0.15, {Transparency = 0.6})
		end
	end)

	return btn, label, setState
end

---------------------------------------------------------------------------
-- ========================= SISTEMA DE SENHA ==============================
---------------------------------------------------------------------------

-- URL do arquivo de keys válidas no seu GitHub (arquivo público)
local KEYS_URL = "https://raw.githubusercontent.com/skygod403/...22/refs/heads/main/keys_validas.txt"

local unlocked = false

-- Busca as keys válidas do GitHub e verifica
local function verificarKey(keyDigitada)
	local ok, resultado = pcall(function()
		return game:HttpGet(KEYS_URL)
	end)
	if not ok then
		return false, "Erro ao verificar. Tente novamente."
	end
	for linha in resultado:gmatch("[^\n]+") do
		linha = linha:gsub("%s+", "")
		if linha == keyDigitada:gsub("%s+", "") then
			return true, "OK"
		end
	end
	return false, "Key invalida ou expirada!"
end

local pinGui = Instance.new("ScreenGui")
pinGui.Name = "PIN_GUI"
pinGui.ResetOnSpawn = false
pinGui.IgnoreGuiInset = true

local ok1 = pcall(function() pinGui.Parent = CoreGui end)
if not ok1 then pinGui.Parent = player:WaitForChild("PlayerGui") end

-- fundo desfocado escuro
local pinBg = Instance.new("Frame", pinGui)
pinBg.Size = UDim2.new(1, 0, 1, 0)
pinBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pinBg.BackgroundTransparency = 0.4
pinBg.BorderSizePixel = 0

local pinFrame = Instance.new("Frame", pinGui)
pinFrame.Size = UDim2.new(0, 320, 0, 230)
pinFrame.Position = UDim2.new(0.5, -160, 0.5, -115)
pinFrame.BackgroundColor3 = C.bg
pinFrame.BorderSizePixel = 0
Instance.new("UICorner", pinFrame).CornerRadius = UDim.new(0, 16)

-- gradiente no painel de senha
addGradient(pinFrame, Color3.fromRGB(10, 8, 20), Color3.fromRGB(6, 6, 16), 160)

-- borda animada
local pinStroke = Instance.new("UIStroke", pinFrame)
pinStroke.Thickness = 1.5
pinStroke.Color = C.accent1

-- brilho topo
local pinGlow = Instance.new("Frame", pinFrame)
pinGlow.Size = UDim2.new(0.7, 0, 0, 1)
pinGlow.Position = UDim2.new(0.15, 0, 0, 0)
pinGlow.BackgroundColor3 = C.accent1
pinGlow.BorderSizePixel = 0
pinGlow.BackgroundTransparency = 0.2

-- título SKY
local pinSky = Instance.new("TextLabel", pinFrame)
pinSky.Size = UDim2.new(1, 0, 0, 40)
pinSky.Position = UDim2.new(0, 0, 0, 14)
pinSky.BackgroundTransparency = 1
pinSky.Text = "SKY"
pinSky.Font = Enum.Font.GothamBlack
pinSky.TextSize = 28
pinSky.TextColor3 = C.accent1

-- subtítulo
local pinSub = Instance.new("TextLabel", pinFrame)
pinSub.Size = UDim2.new(1, 0, 0, 18)
pinSub.Position = UDim2.new(0, 0, 0, 52)
pinSub.BackgroundTransparency = 1
pinSub.Text = "🔒  VERIFICAÇÃO DE ACESSO"
pinSub.Font = Enum.Font.Gotham
pinSub.TextSize = 10
pinSub.TextColor3 = C.dim

-- caixa de senha
local pinBox, pinBoxWrap = createStyledBox(pinFrame, "Digite a senha...", 84)

-- botão entrar
local pinBtn = Instance.new("TextButton", pinFrame)
pinBtn.Size = UDim2.new(1, -24, 0, 40)
pinBtn.Position = UDim2.new(0, 12, 0, 132)
pinBtn.BackgroundColor3 = C.accent1
pinBtn.BorderSizePixel = 0
pinBtn.Text = "ENTRAR"
pinBtn.Font = Enum.Font.GothamBlack
pinBtn.TextSize = 13
pinBtn.TextColor3 = Color3.new(1, 1, 1)
pinBtn.AutoButtonColor = false
Instance.new("UICorner", pinBtn).CornerRadius = UDim.new(0, 9)
addGradient(pinBtn, C.accent1, C.border, 90)

-- hover botão entrar
pinBtn.MouseEnter:Connect(function()
	tween(pinBtn, 0.15, {BackgroundColor3 = C.accent2})
end)
pinBtn.MouseLeave:Connect(function()
	tween(pinBtn, 0.15, {BackgroundColor3 = C.accent1})
end)

-- rodapé
local pinFoot = Instance.new("TextLabel", pinFrame)
pinFoot.Size = UDim2.new(1, 0, 0, 18)
pinFoot.Position = UDim2.new(0, 0, 0, 200)
pinFoot.BackgroundTransparency = 1
pinFoot.Text = "SKY HUB  •  v2.0"
pinFoot.Font = Enum.Font.Gotham
pinFoot.TextSize = 9
pinFoot.TextColor3 = C.dim

-- animação cor da borda PIN
task.spawn(function()
	local cols = {C.accent1, C.accent2, C.accent3, C.green}
	while pinFrame.Parent do
		for _, c in ipairs(cols) do
			tween(pinStroke, 1.2, {Color = c})
			tween(pinSky,    1.2, {TextColor3 = c})
			tween(pinGlow,   1.2, {BackgroundColor3 = c})
			task.wait(1.2)
		end
	end
end)

pinBtn.MouseButton1Click:Connect(function()
	-- Mostra "verificando..."
	pinBtn.Text = "VERIFICANDO..."
	pinBtn.Active = false

	task.spawn(function()
		local valida, msg = verificarKey(pinBox.Text)

		if valida then
			pinBtn.Text = "ENTRAR"
			pinBtn.Active = true
			-- animação de saída
			tween(pinFrame, 0.3, {Position = UDim2.new(0.5, -160, 0.6, -115), BackgroundTransparency = 1})
			tween(pinBg, 0.3, {BackgroundTransparency = 1})
			task.wait(0.35)
			unlocked = true
			pinGui:Destroy()
		else
			pinBtn.Text = "ENTRAR"
			pinBtn.Active = true
			-- shake de erro
			tween(pinStroke, 0.1, {Color = C.accent3})
			tween(pinBoxWrap, 0.1, {Position = UDim2.new(0, 16, 0, 84)})
			task.wait(0.1)
			tween(pinBoxWrap, 0.1, {Position = UDim2.new(0, 8,  0, 84)})
			task.wait(0.1)
			tween(pinBoxWrap, 0.1, {Position = UDim2.new(0, 12, 0, 84)})
			-- mostra mensagem de erro
			pinSub.Text = "❌  " .. msg
			tween(pinSub, 0.2, {TextColor3 = C.accent3})
			task.wait(2)
			pinSub.Text = "🔒  VERIFICACAO DE ACESSO"
			tween(pinSub, 0.2, {TextColor3 = C.dim})
		end
	end)
end)

repeat task.wait() until unlocked

---------------------------------------------------------------------------
-- ========================= VARIÁVEIS DE JOGO =============================
---------------------------------------------------------------------------

local character, humanoid, rootPart
local defaultSpeed  = 16
local speedEnabled  = false
local savedSpeed    = nil
local infiniteJump  = false
local flyEnabled    = false
local bodyVelocity  = nil
local bodyGyro      = nil
local noclipEnabled = false

---------------------------------------------------------------------------
-- ========================= PERSONAGEM / RESPAWN ==========================
---------------------------------------------------------------------------

local function setupCharacter(char)
	character = char
	humanoid  = char:WaitForChild("Humanoid")
	rootPart  = char:WaitForChild("HumanoidRootPart")
	defaultSpeed = humanoid.WalkSpeed
	if speedEnabled and savedSpeed then humanoid.WalkSpeed = savedSpeed end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro     then bodyGyro:Destroy()     bodyGyro     = nil end
	flyEnabled = false
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

---------------------------------------------------------------------------
-- ========================= GUI PRINCIPAL ================================
---------------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "NEON_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local ok2 = pcall(function() gui.Parent = CoreGui end)
if not ok2 then gui.Parent = player.PlayerGui end

-- FRAME PRINCIPAL
local frame = Instance.new("Frame", gui)
frame.Size     = UDim2.new(0, 300, 0, 520)
frame.Position = UDim2.new(0.5, -150, 0.5, -260)
frame.BackgroundColor3 = C.bg
frame.BorderSizePixel  = 0
frame.Visible  = false
frame.Active   = true
frame.Draggable= true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
addGradient(frame, Color3.fromRGB(10, 8, 20), Color3.fromRGB(5, 5, 14), 160)

-- sombra (frame atrás maior e escuro)
local shadow = Instance.new("Frame", gui)
shadow.Size = UDim2.new(0, 316, 0, 536)
shadow.Position = UDim2.new(0.5, -158, 0.5, -268)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = frame.ZIndex - 1
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 18)

-- borda animada principal
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Thickness = 1.5
frameStroke.Color = C.accent1

-- brilho no topo
local topGlow = Instance.new("Frame", frame)
topGlow.Size = UDim2.new(0.6, 0, 0, 1)
topGlow.Position = UDim2.new(0.2, 0, 0, 0)
topGlow.BackgroundColor3 = C.accent1
topGlow.BorderSizePixel = 0
topGlow.BackgroundTransparency = 0.1

---------------------------------------------------------------------------
-- HEADER
---------------------------------------------------------------------------

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 54)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

-- cobre cantos inferiores do header
local headerFix = Instance.new("Frame", header)
headerFix.Size = UDim2.new(1, 0, 0.5, 0)
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = C.panel
headerFix.BorderSizePixel = 0

-- título SKY grande
local titleSky = Instance.new("TextLabel", header)
titleSky.Size = UDim2.new(0.5, 0, 1, 0)
titleSky.Position = UDim2.new(0, 16, 0, 0)
titleSky.BackgroundTransparency = 1
titleSky.Text = "SKY"
titleSky.Font = Enum.Font.GothamBlack
titleSky.TextSize = 22
titleSky.TextColor3 = C.accent1
titleSky.TextXAlignment = Enum.TextXAlignment.Left

-- badge versão
local badge = Instance.new("Frame", header)
badge.Size = UDim2.new(0, 52, 0, 20)
badge.Position = UDim2.new(1, -64, 0.5, -10)
badge.BackgroundColor3 = C.btnOn
badge.BorderSizePixel = 0
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

local badgeTxt = Instance.new("TextLabel", badge)
badgeTxt.Size = UDim2.new(1, 0, 1, 0)
badgeTxt.BackgroundTransparency = 1
badgeTxt.Text = "v2.0"
badgeTxt.Font = Enum.Font.GothamBold
badgeTxt.TextSize = 10
badgeTxt.TextColor3 = C.accent1

-- tecla Z hint
local zHint = Instance.new("TextLabel", header)
zHint.Size = UDim2.new(1, -16, 0, 12)
zHint.Position = UDim2.new(0, 16, 1, -14)
zHint.BackgroundTransparency = 1
zHint.Text = "[Z] para abrir/fechar"
zHint.Font = Enum.Font.Gotham
zHint.TextSize = 9
zHint.TextColor3 = C.dim
zHint.TextXAlignment = Enum.TextXAlignment.Left

---------------------------------------------------------------------------
-- ÁREA DE SCROLL (conteúdo)
---------------------------------------------------------------------------

local content = Instance.new("ScrollingFrame", frame)
content.Size = UDim2.new(1, 0, 1, -58)
content.Position = UDim2.new(0, 0, 0, 56)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = C.accent1
content.CanvasSize = UDim2.new(0, 0, 0, 460)
content.ScrollingDirection = Enum.ScrollingDirection.Y

---------------------------------------------------------------------------
-- ANIMAÇÃO NEON (borda + topo)
---------------------------------------------------------------------------

task.spawn(function()
	local cols = {C.accent1, C.accent2, C.accent3, C.green}
	while frame.Parent do
		for _, c in ipairs(cols) do
			tween(frameStroke, 1.4, {Color = c})
			tween(topGlow,     1.4, {BackgroundColor3 = c})
			tween(titleSky,    1.4, {TextColor3 = c})
			tween(badgeTxt,    1.4, {TextColor3 = c})
			task.wait(1.4)
		end
	end
end)

---------------------------------------------------------------------------
-- HELPERS PARA O CONTEÚDO
---------------------------------------------------------------------------

local yOff = 12 -- cursor Y dentro do content

local function sectionLabel(text, dotColor)
	createSectionLabel(content, text, yOff, dotColor)
	yOff = yOff + 28
end

local function sep()
	createSep(content, yOff)
	yOff = yOff + 14
end

local function styledBox(placeholder)
	local b, _ = createStyledBox(content, placeholder, yOff)
	yOff = yOff + 44
	return b
end

local function styledBtn(textOff, accent)
	local btn, lbl, setState = createStyledButton(content, textOff, yOff, accent)
	yOff = yOff + 46
	return btn, lbl, setState
end

---------------------------------------------------------------------------
-- ========================= ELEMENTOS ====================================
---------------------------------------------------------------------------

-- ── VELOCIDADE ──────────────────────────────────────────────
sectionLabel("VELOCIDADE DE CORRIDA", C.accent2)
local speedBox                          = styledBox("Ex: 100")
local speedBtn, speedLbl, speedSet      = styledBtn("Velocidade  OFF", C.accent2)

sep()

-- ── PULO ────────────────────────────────────────────────────
sectionLabel("PULO INFINITO", C.green)
local jumpBtn, jumpLbl, jumpSet         = styledBtn("Pulo Infinito  OFF", C.green)

sep()

-- ── FLY ─────────────────────────────────────────────────────
sectionLabel("VOAR (WASD)", C.accent1)
local flyBox                            = styledBox("Velocidade fly (Ex: 60)")
local flyBtn, flyLbl, flySet            = styledBtn("Fly  OFF", C.accent1)

sep()

-- ── NOCLIP ──────────────────────────────────────────────────
sectionLabel("NO-CLIP", C.accent3)
local noclipBtn, noclipLbl, noclipSet   = styledBtn("No-Clip  OFF", C.accent3)

sep()

-- ── ESP ─────────────────────────────────────────────────────
sectionLabel("ESP PLAYERS", Color3.fromRGB(255, 80, 80))
local espBtn, espLbl, espSet            = styledBtn("ESP  OFF", Color3.fromRGB(255, 80, 80))

sep()

-- ── IDIOMA ──────────────────────────────────────────────────
sectionLabel("IDIOMA / LANGUAGE", Color3.fromRGB(255, 200, 50))
yOff = yOff + 4

local langRow = Instance.new("Frame", content)
langRow.Size = UDim2.new(1, -24, 0, 44)
langRow.Position = UDim2.new(0, 12, 0, yOff)
langRow.BackgroundTransparency = 1
langRow.BorderSizePixel = 0
yOff = yOff + 52

local function createLangBtn(parent, flag, name, xPos, isActive)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, 82, 1, 0)
	btn.Position = UDim2.new(0, xPos, 0, 0)
	btn.BackgroundColor3 = isActive and Color3.fromRGB(30, 25, 55) or C.btnOff
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = isActive and 1.5 or 1
	stroke.Color = isActive and Color3.fromRGB(255, 200, 50) or C.border
	stroke.Transparency = isActive and 0 or 0.6

	local flagLbl = Instance.new("TextLabel", btn)
	flagLbl.Size = UDim2.new(1, 0, 0, 22)
	flagLbl.Position = UDim2.new(0, 0, 0, 4)
	flagLbl.BackgroundTransparency = 1
	flagLbl.Text = flag
	flagLbl.Font = Enum.Font.GothamBold
	flagLbl.TextSize = 18
	flagLbl.TextColor3 = C.white

	local nameLbl = Instance.new("TextLabel", btn)
	nameLbl.Size = UDim2.new(1, 0, 0, 14)
	nameLbl.Position = UDim2.new(0, 0, 0, 26)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = name
	nameLbl.Font = Enum.Font.Gotham
	nameLbl.TextSize = 9
	nameLbl.TextColor3 = isActive and Color3.fromRGB(255, 200, 50) or C.dim

	return btn, stroke, nameLbl
end

local langBR_btn, langBR_stroke, langBR_name = createLangBtn(langRow, "🇧🇷", "BRASIL",  0,   true)
local langUS_btn, langUS_stroke, langUS_name = createLangBtn(langRow, "🇺🇸", "USA",     91,  false)
local langEU_btn, langEU_stroke, langEU_name = createLangBtn(langRow, "🇪🇺", "EUROPE",  182, false)

-- ajusta canvas
content.CanvasSize = UDim2.new(0, 0, 0, yOff + 16)

---------------------------------------------------------------------------
-- ========================= BOTÃO MINIMIZADO (mobile/toggle) =============
---------------------------------------------------------------------------

local miniBtn = Instance.new("ImageButton", gui)
miniBtn.Size = UDim2.new(0, 54, 0, 54)
miniBtn.Position = UDim2.new(0, 16, 1, -72) -- canto inferior esquerdo
miniBtn.BackgroundColor3 = C.bg
miniBtn.BorderSizePixel = 0
miniBtn.Image = ""
miniBtn.ZIndex = 10
miniBtn.Active = true
miniBtn.Visible = true
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 14)

-- gradiente no mini botão
addGradient(miniBtn, Color3.fromRGB(18, 10, 40), Color3.fromRGB(8, 8, 18), 135)

-- borda neon animada
local miniStroke = Instance.new("UIStroke", miniBtn)
miniStroke.Thickness = 2
miniStroke.Color = C.accent1

-- brilho topo mini
local miniGlow = Instance.new("Frame", miniBtn)
miniGlow.Size = UDim2.new(0.7, 0, 0, 1)
miniGlow.Position = UDim2.new(0.15, 0, 0, 0)
miniGlow.BackgroundColor3 = C.accent1
miniGlow.BorderSizePixel = 0
miniGlow.BackgroundTransparency = 0.2
miniGlow.ZIndex = 11

-- letra S central
local miniS = Instance.new("TextLabel", miniBtn)
miniS.Size = UDim2.new(1, 0, 1, 0)
miniS.BackgroundTransparency = 1
miniS.Text = "S"
miniS.Font = Enum.Font.GothamBlack
miniS.TextSize = 26
miniS.TextColor3 = C.accent1
miniS.ZIndex = 12

-- pontinhos decorativos nos cantos
local function miniDot(px, py, color)
	local d = Instance.new("Frame", miniBtn)
	d.Size = UDim2.new(0, 4, 0, 4)
	d.Position = UDim2.new(0, px, 0, py)
	d.BackgroundColor3 = color
	d.BorderSizePixel = 0
	d.ZIndex = 12
	Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
end
miniDot(6,  6,  C.accent2)
miniDot(44, 6,  C.accent3)
miniDot(6,  44, C.accent3)
miniDot(44, 44, C.accent2)

-- sombra do mini botão
local miniShadow = Instance.new("Frame", gui)
miniShadow.Size = UDim2.new(0, 62, 0, 62)
miniShadow.Position = UDim2.new(0, 12, 1, -76)
miniShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniShadow.BackgroundTransparency = 0.5
miniShadow.BorderSizePixel = 0
miniShadow.ZIndex = 9
Instance.new("UICorner", miniShadow).CornerRadius = UDim.new(0, 16)

-- animação neon mini botão (sincronizada com a GUI principal)
task.spawn(function()
	local cols = {C.accent1, C.accent2, C.accent3, C.green}
	while miniBtn.Parent do
		for _, c in ipairs(cols) do
			tween(miniStroke, 1.4, {Color = c})
			tween(miniS,      1.4, {TextColor3 = c})
			tween(miniGlow,   1.4, {BackgroundColor3 = c})
			task.wait(1.4)
		end
	end
end)

-- hover / press mini botão
miniBtn.MouseEnter:Connect(function()
	tween(miniBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(22, 12, 50)})
	tween(miniStroke, 0.15, {Thickness = 2.5})
end)
miniBtn.MouseLeave:Connect(function()
	tween(miniBtn, 0.15, {BackgroundColor3 = C.bg})
	tween(miniStroke, 0.15, {Thickness = 2})
end)

---------------------------------------------------------------------------
-- ========================= TOGGLE (Z + mini botão) =======================
---------------------------------------------------------------------------

local function toggleGui()
	frame.Visible  = not frame.Visible
	shadow.Visible = frame.Visible

	if frame.Visible then
		-- animação de abertura
		frame.BackgroundTransparency = 1
		frame.Position = UDim2.new(0.5, -150, 0.52, -260)
		tween(frame, 0.25, {BackgroundTransparency = 0, Position = UDim2.new(0.5, -150, 0.5, -260)})
		-- mini botão some suavemente
		tween(miniBtn,    0.2, {BackgroundTransparency = 0.3})
		tween(miniS,      0.2, {TextTransparency = 0.5})
		tween(miniStroke, 0.2, {Transparency = 0.5})
	else
		-- mini botão volta ao normal
		tween(miniBtn,    0.2, {BackgroundTransparency = 0})
		tween(miniS,      0.2, {TextTransparency = 0})
		tween(miniStroke, 0.2, {Transparency = 0})
	end
end

-- clique no mini botão
miniBtn.MouseButton1Click:Connect(toggleGui)

-- tecla Z no teclado
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Z then
		toggleGui()
	end
end)

shadow.Visible = false

---------------------------------------------------------------------------
-- ========================= SISTEMA DE IDIOMAS ============================
---------------------------------------------------------------------------

-- Dicionário completo dos 3 idiomas
local LANG = {
	BR = {
		speed_section  = "VELOCIDADE DE CORRIDA",
		speed_off      = "Velocidade  OFF",
		speed_on       = "Velocidade  ON  |  ",
		speed_ph       = "Ex: 100",
		jump_section   = "PULO INFINITO",
		jump_off       = "Pulo Infinito  OFF",
		jump_on        = "Pulo Infinito  ON",
		fly_section    = "VOAR (WASD)",
		fly_off        = "Fly  OFF",
		fly_on         = "Fly  ON",
		fly_ph         = "Velocidade fly (Ex: 60)",
		noclip_section = "NO-CLIP",
		noclip_off     = "No-Clip  OFF",
		noclip_on      = "No-Clip  ON",
		esp_section    = "ESP PLAYERS",
		esp_off        = "ESP  OFF",
		esp_on         = "ESP  ON",
		lang_section   = "IDIOMA / LANGUAGE",
		pin_lock       = "🔒  VERIFICAÇÃO DE ACESSO",
		pin_enter      = "ENTRAR",
		pin_ph         = "Digite a senha...",
		hint           = "[Z] para abrir/fechar",
	},
	US = {
		speed_section  = "RUN SPEED",
		speed_off      = "Speed  OFF",
		speed_on       = "Speed  ON  |  ",
		speed_ph       = "Ex: 100",
		jump_section   = "INFINITE JUMP",
		jump_off       = "Infinite Jump  OFF",
		jump_on        = "Infinite Jump  ON",
		fly_section    = "FLY (WASD)",
		fly_off        = "Fly  OFF",
		fly_on         = "Fly  ON",
		fly_ph         = "Fly speed (Ex: 60)",
		noclip_section = "NO-CLIP",
		noclip_off     = "No-Clip  OFF",
		noclip_on      = "No-Clip  ON",
		esp_section    = "ESP PLAYERS",
		esp_off        = "ESP  OFF",
		esp_on         = "ESP  ON",
		lang_section   = "IDIOMA / LANGUAGE",
		pin_lock       = "🔒  ACCESS VERIFICATION",
		pin_enter      = "LOGIN",
		pin_ph         = "Enter password...",
		hint           = "[Z] to open/close",
	},
	EU = {
		speed_section  = "VITESSE DE COURSE",
		speed_off      = "Vitesse  OFF",
		speed_on       = "Vitesse  ON  |  ",
		speed_ph       = "Ex: 100",
		jump_section   = "SAUT INFINI",
		jump_off       = "Saut Infini  OFF",
		jump_on        = "Saut Infini  ON",
		fly_section    = "VOL (WASD)",
		fly_off        = "Vol  OFF",
		fly_on         = "Vol  ON",
		fly_ph         = "Vitesse vol (Ex: 60)",
		noclip_section = "NO-CLIP",
		noclip_off     = "No-Clip  OFF",
		noclip_on      = "No-Clip  ON",
		esp_section    = "ESP JOUEURS",
		esp_off        = "ESP  OFF",
		esp_on         = "ESP  ON",
		lang_section   = "IDIOMA / LANGUAGE",
		pin_lock       = "🔒  VÉRIFICATION D'ACCÈS",
		pin_enter      = "ENTRER",
		pin_ph         = "Mot de passe...",
		hint           = "[Z] ouvrir/fermer",
	},
}

local currentLang = "BR"

-- Referências dos labels de seção que precisam mudar
-- (guardadas numa tabela para facilitar update)
local sectionRefs = {}

-- Percorre o content e coleta todos os TextLabels de seção pelo texto atual
local function collectSectionLabels()
	sectionRefs = {}
	for _, child in ipairs(content:GetDescendants()) do
		if child:IsA("TextLabel") then
			local t = child.Text
			if t == "VELOCIDADE DE CORRIDA" or t == "RUN SPEED"        or t == "VITESSE DE COURSE"  then sectionRefs["speed_section"]  = child
			elseif t == "PULO INFINITO"     or t == "INFINITE JUMP"    or t == "SAUT INFINI"        then sectionRefs["jump_section"]   = child
			elseif t == "VOAR (WASD)"       or t == "FLY (WASD)"       or t == "VOL (WASD)"         then sectionRefs["fly_section"]    = child
			elseif t == "NO-CLIP"                                                                    then sectionRefs["noclip_section"] = child
			elseif t == "ESP PLAYERS"       or t == "ESP JOUEURS"                                   then sectionRefs["esp_section"]    = child
			elseif t == "IDIOMA / LANGUAGE"                                                          then sectionRefs["lang_section"]   = child
			end
		end
	end
end

collectSectionLabels()

-- Aplica idioma na GUI toda
local function applyLang(code)
	local L = LANG[code]
	if not L then return end
	currentLang = code

	-- seções
	if sectionRefs["speed_section"]  then sectionRefs["speed_section"].Text  = L.speed_section  end
	if sectionRefs["jump_section"]   then sectionRefs["jump_section"].Text   = L.jump_section   end
	if sectionRefs["fly_section"]    then sectionRefs["fly_section"].Text    = L.fly_section    end
	if sectionRefs["noclip_section"] then sectionRefs["noclip_section"].Text = L.noclip_section end
	if sectionRefs["esp_section"]    then sectionRefs["esp_section"].Text    = L.esp_section    end

	-- placeholders
	speedBox.PlaceholderText = L.speed_ph
	flyBox.PlaceholderText   = L.fly_ph

	-- botões (respeita estado ON/OFF atual)
	speedLbl.Text  = speedEnabled  and (L.speed_on .. (savedSpeed or ""))  or L.speed_off
	jumpLbl.Text   = infiniteJump  and L.jump_on   or L.jump_off
	flyLbl.Text    = flyEnabled    and L.fly_on     or L.fly_off
	noclipLbl.Text = noclipEnabled and L.noclip_on  or L.noclip_off
	espLbl.Text    = espEnabled    and L.esp_on     or L.esp_off

	-- hint
	zHint.Text = L.hint
end

-- Função que destaca botão de idioma selecionado
local langBtns = {
	BR = {btn = langBR_btn, stroke = langBR_stroke, name = langBR_name},
	US = {btn = langUS_btn, stroke = langUS_stroke, name = langUS_name},
	EU = {btn = langEU_btn, stroke = langEU_stroke, name = langEU_name},
}

local function selectLang(code)
	-- reset todos
	for _, data in pairs(langBtns) do
		tween(data.btn,    0.2, {BackgroundColor3 = C.btnOff})
		tween(data.stroke, 0.2, {Color = C.border, Transparency = 0.6, Thickness = 1})
		tween(data.name,   0.2, {TextColor3 = C.dim})
	end
	-- ativa o selecionado
	local sel = langBtns[code]
	if sel then
		tween(sel.btn,    0.2, {BackgroundColor3 = Color3.fromRGB(30, 25, 55)})
		tween(sel.stroke, 0.2, {Color = Color3.fromRGB(255, 200, 50), Transparency = 0, Thickness = 1.5})
		tween(sel.name,   0.2, {TextColor3 = Color3.fromRGB(255, 200, 50)})
	end
	applyLang(code)
end

langBR_btn.MouseButton1Click:Connect(function() selectLang("BR") end)
langUS_btn.MouseButton1Click:Connect(function() selectLang("US") end)
langEU_btn.MouseButton1Click:Connect(function() selectLang("EU") end)

-- hover nos botões de idioma
for code, data in pairs(langBtns) do
	data.btn.MouseEnter:Connect(function()
		if currentLang ~= code then
			tween(data.btn, 0.15, {BackgroundColor3 = Color3.fromRGB(22, 20, 38)})
			tween(data.stroke, 0.15, {Transparency = 0.3})
		end
	end)
	data.btn.MouseLeave:Connect(function()
		if currentLang ~= code then
			tween(data.btn, 0.15, {BackgroundColor3 = C.btnOff})
			tween(data.stroke, 0.15, {Transparency = 0.6})
		end
	end)
end

---------------------------------------------------------------------------
-- ========================= VELOCIDADE ===================================
---------------------------------------------------------------------------

speedBtn.MouseButton1Click:Connect(function()
	if not humanoid then return end
	speedEnabled = not speedEnabled
	if speedEnabled then
		local v = tonumber(speedBox.Text)
		if v and v > 0 then
			savedSpeed = v
			humanoid.WalkSpeed = v
			speedSet(true)
			speedLbl.Text = LANG[currentLang].speed_on .. v
		else
			speedEnabled = false
		end
	else
		savedSpeed = nil
		humanoid.WalkSpeed = defaultSpeed
		speedSet(false)
		speedLbl.Text = LANG[currentLang].speed_off
	end
end)

RunService.RenderStepped:Connect(function()
	if speedEnabled and humanoid and savedSpeed then
		if humanoid.WalkSpeed ~= savedSpeed then
			humanoid.WalkSpeed = savedSpeed
		end
	end
end)

---------------------------------------------------------------------------
-- ========================= PULO INFINITO ================================
---------------------------------------------------------------------------

jumpBtn.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	jumpSet(infiniteJump)
	jumpLbl.Text = infiniteJump and LANG[currentLang].jump_on or LANG[currentLang].jump_off
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

---------------------------------------------------------------------------
-- ========================= FLY ==========================================
---------------------------------------------------------------------------

flyBtn.MouseButton1Click:Connect(function()
	if not rootPart then return end
	flyEnabled = not flyEnabled
	if flyEnabled then
		bodyVelocity = Instance.new("BodyVelocity", rootPart)
		bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bodyGyro = Instance.new("BodyGyro", rootPart)
		bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		flySet(true)
		flyLbl.Text = LANG[currentLang].fly_on
	else
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro     then bodyGyro:Destroy()     end
		bodyVelocity = nil
		bodyGyro     = nil
		flySet(false)
		flyLbl.Text = LANG[currentLang].fly_off
	end
end)

RunService.RenderStepped:Connect(function()
	if flyEnabled and bodyVelocity and bodyGyro then
		local sp  = tonumber(flyBox.Text) or 50
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		bodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * sp or Vector3.zero
		bodyGyro.CFrame = cam.CFrame
	end
end)

---------------------------------------------------------------------------
-- ========================= NOCLIP =======================================
---------------------------------------------------------------------------

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipSet(noclipEnabled)
	noclipLbl.Text = noclipEnabled and LANG[currentLang].noclip_on or LANG[currentLang].noclip_off
end)

RunService.Stepped:Connect(function()
	if noclipEnabled and character then
		for _, p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

---------------------------------------------------------------------------
-- ========================= ESP + LINHAS =================================
---------------------------------------------------------------------------

local espEnabled = false
local espCache   = {}
local lineCache  = {}

-- GUI de linhas 2D
local lineGui = Instance.new("ScreenGui")
lineGui.Name = "ESP_LINES"
lineGui.ResetOnSpawn = false
lineGui.IgnoreGuiInset = true

local okLine = pcall(function() lineGui.Parent = CoreGui end)
if not okLine then lineGui.Parent = player.PlayerGui end

local function createLine()
	local line = Instance.new("Frame", lineGui)
	line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	line.BorderSizePixel = 0
	line.AnchorPoint = Vector2.new(0.5, 0)
	line.Visible = false
	-- gradiente na linha (roxo → vermelho)
	local g = Instance.new("UIGradient", line)
	g.Color = ColorSequence.new(Color3.fromRGB(180, 0, 255), Color3.fromRGB(255, 50, 50))
	g.Rotation = 0
	return line
end

local function updateLine(line, from, to)
	local dx = to.X - from.X
	local dy = to.Y - from.Y
	local dist = math.sqrt(dx*dx + dy*dy)
	local angle = math.atan2(dy, dx)
	line.Size = UDim2.new(0, dist, 0, 2)
	line.Position = UDim2.new(0, from.X, 0, from.Y)
	line.Rotation = math.deg(angle)
	line.Visible = true
end

local function addESP(char)
	if espCache[char] then return end
	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(255, 0, 0)
	h.OutlineColor = Color3.fromRGB(255, 80, 80)
	h.FillTransparency = 0.5
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = char
	espCache[char] = h
	lineCache[char] = createLine()
end

local function removeESP()
	for _, h    in pairs(espCache)  do if h    then h:Destroy()    end end
	for _, line in pairs(lineCache) do if line then line:Destroy()  end end
	espCache  = {}
	lineCache = {}
end

RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	if not rootPart   then return end
	local cam        = workspace.CurrentCamera
	local screenSize = cam.ViewportSize
	local origin     = Vector2.new(screenSize.X / 2, screenSize.Y)
	for char, line in pairs(lineCache) do
		if not char or not char.Parent then
			if line then line:Destroy() end
			lineCache[char] = nil
		else
			local tr = char:FindFirstChild("HumanoidRootPart")
			if tr then
				local sp, onScreen = cam:WorldToViewportPoint(tr.Position)
				if onScreen then
					updateLine(line, origin, Vector2.new(sp.X, sp.Y))
				else
					line.Visible = false
				end
			end
		end
	end
end)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espSet(espEnabled)
	espLbl.Text = espEnabled and LANG[currentLang].esp_on or LANG[currentLang].esp_off
	if espEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				addESP(plr.Character)
			end
		end
	else
		removeESP()
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(1)
		if espEnabled then addESP(char) end
	end)
end)

---------------------------------------------------------------------------
-- FINAL
---------------------------------------------------------------------------

print("SKY HUB v2.0 carregado! Pressione Z para abrir.")

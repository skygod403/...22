--[[ SKY HUB v3.0 ]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player = Players.LocalPlayer

-- parent seguro
local function GP()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg then return cg end
	return player:WaitForChild("PlayerGui")
end

-- tween helper
local function TW(obj, t, props)
	TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props):Play()
end

-- cores
local C = {
	bg      = Color3.fromRGB(8,   8,  12),
	panel   = Color3.fromRGB(14,  14, 22),
	border  = Color3.fromRGB(80,  60, 200),
	a1      = Color3.fromRGB(120, 80, 255),
	a2      = Color3.fromRGB(0,  200, 255),
	a3      = Color3.fromRGB(255, 60, 120),
	green   = Color3.fromRGB(0,  255, 160),
	white   = Color3.fromRGB(230, 230, 255),
	dim     = Color3.fromRGB(100, 100, 140),
	btnOff  = Color3.fromRGB(22,  22,  36),
	btnOn   = Color3.fromRGB(30,  15,  60),
	gold    = Color3.fromRGB(255, 200,  50),
}

-- keys
local KEYS_URL  = "https://raw.githubusercontent.com/skygod403/...22/refs/heads/main/keys_validas.txt"
local ADMIN_KEY = "Script_Sky_HUB"
local isAdmin   = false

local function verificarKey(k)
	k = k:gsub("%s+","")
	if k == ADMIN_KEY then isAdmin=true return true,"ADMIN" end
	local ok,res = pcall(function() return game:HttpGet(KEYS_URL) end)
	if not ok then return false,"Erro de conexao!" end
	for linha in res:gmatch("[^\n]+") do
		if linha:gsub("%s+","") == k then return true,"OK" end
	end
	return false,"Key invalida ou expirada!"
end

-- helpers UI
local function corner(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 10) end
local function stroke(p,t,c) local s=Instance.new("UIStroke",p) s.Thickness=t or 1.5 s.Color=c or C.a1 return s end
local function grad(p,c0,c1,r) local g=Instance.new("UIGradient",p) g.Color=ColorSequence.new(c0,c1) g.Rotation=r or 135 end

-- ================================================================
-- TELA DE KEY
-- ================================================================
local pinGui = Instance.new("ScreenGui")
pinGui.Name="SKY_PIN" pinGui.ResetOnSpawn=false pinGui.IgnoreGuiInset=true
pinGui.Parent = GP()

local pinBg = Instance.new("Frame", pinGui)
pinBg.Size=UDim2.new(1,0,1,0) pinBg.BackgroundColor3=Color3.fromRGB(0,0,0)
pinBg.BackgroundTransparency=1 pinBg.BorderSizePixel=0

local pinFrame = Instance.new("Frame", pinGui)
pinFrame.Size=UDim2.new(0,320,0,240)
pinFrame.Position=UDim2.new(0.5,-160,0.6,-120)
pinFrame.BackgroundColor3=C.bg
pinFrame.BackgroundTransparency=1
pinFrame.BorderSizePixel=0
corner(pinFrame,18)
grad(pinFrame, Color3.fromRGB(12,8,24), Color3.fromRGB(5,5,14), 160)
local pinStroke = stroke(pinFrame, 1.5, C.a1)

-- aparecer suave
task.delay(0.1, function()
	TW(pinFrame, 0.5, {BackgroundTransparency=0, Position=UDim2.new(0.5,-160,0.5,-120)})
end)

local pinGlow = Instance.new("Frame", pinFrame)
pinGlow.Size=UDim2.new(0.7,0,0,1) pinGlow.Position=UDim2.new(0.15,0,0,0)
pinGlow.BackgroundColor3=C.a1 pinGlow.BackgroundTransparency=0.2 pinGlow.BorderSizePixel=0

local pinTitle = Instance.new("TextLabel", pinFrame)
pinTitle.Size=UDim2.new(1,0,0,44) pinTitle.Position=UDim2.new(0,0,0,12)
pinTitle.BackgroundTransparency=1 pinTitle.Text="SKY"
pinTitle.Font=Enum.Font.GothamBlack pinTitle.TextSize=30 pinTitle.TextColor3=C.a1

local pinSub = Instance.new("TextLabel", pinFrame)
pinSub.Size=UDim2.new(1,0,0,18) pinSub.Position=UDim2.new(0,0,0,54)
pinSub.BackgroundTransparency=1 pinSub.Text="VERIFICACAO DE ACESSO"
pinSub.Font=Enum.Font.Gotham pinSub.TextSize=10 pinSub.TextColor3=C.dim

local pinWrap = Instance.new("Frame", pinFrame)
pinWrap.Size=UDim2.new(1,-24,0,38) pinWrap.Position=UDim2.new(0,12,0,82)
pinWrap.BackgroundColor3=C.panel pinWrap.BorderSizePixel=0
corner(pinWrap,9) stroke(pinWrap,1,C.border)

local pinBox = Instance.new("TextBox", pinWrap)
pinBox.Size=UDim2.new(1,-16,1,0) pinBox.Position=UDim2.new(0,8,0,0)
pinBox.BackgroundTransparency=1 pinBox.PlaceholderText="Cole sua key aqui..."
pinBox.PlaceholderColor3=C.dim pinBox.Text="" pinBox.Font=Enum.Font.GothamBold
pinBox.TextSize=13 pinBox.TextColor3=C.white pinBox.ClearTextOnFocus=false

local pinBtn = Instance.new("TextButton", pinFrame)
pinBtn.Size=UDim2.new(1,-24,0,42) pinBtn.Position=UDim2.new(0,12,0,132)
pinBtn.BackgroundColor3=C.a1 pinBtn.BorderSizePixel=0
pinBtn.Text="ENTRAR" pinBtn.Font=Enum.Font.GothamBlack
pinBtn.TextSize=14 pinBtn.TextColor3=Color3.new(1,1,1)
pinBtn.AutoButtonColor=false corner(pinBtn,10)
grad(pinBtn, C.a1, C.border, 90)

pinBtn.MouseEnter:Connect(function() TW(pinBtn,0.15,{BackgroundColor3=C.a2}) end)
pinBtn.MouseLeave:Connect(function() TW(pinBtn,0.15,{BackgroundColor3=C.a1}) end)

local pinFoot = Instance.new("TextLabel", pinFrame)
pinFoot.Size=UDim2.new(1,0,0,18) pinFoot.Position=UDim2.new(0,0,0,210)
pinFoot.BackgroundTransparency=1 pinFoot.Text="SKY HUB  v3.0"
pinFoot.Font=Enum.Font.Gotham pinFoot.TextSize=9 pinFoot.TextColor3=C.dim

-- animação borda
task.spawn(function()
	local cols={C.a1,C.a2,C.a3,C.green}
	while pinFrame.Parent do
		for _,c in ipairs(cols) do
			TW(pinStroke,1.2,{Color=c}) TW(pinTitle,1.2,{TextColor3=c}) TW(pinGlow,1.2,{BackgroundColor3=c})
			task.wait(1.2)
		end
	end
end)

local unlocked = false

-- ================================================================
-- VERIFICAÇÃO AO CLICAR
-- ================================================================
pinBtn.MouseButton1Click:Connect(function()
	if pinBtn.Text == "VERIFICANDO..." then return end
	pinBtn.Text="VERIFICANDO..." pinBtn.Active=false

	task.spawn(function()
		local ok, msg = verificarKey(pinBox.Text)
		if ok then
			-- some o painel
			TW(pinFrame, 0.3, {BackgroundTransparency=1, Position=UDim2.new(0.5,-160,0.4,-120)})
			TW(pinBg, 0.3, {BackgroundTransparency=0})
			task.wait(0.5)

			-- ── TELA DE BEM-VINDO ──
			local wGui = Instance.new("ScreenGui")
			wGui.Name="SKY_WELCOME" wGui.ResetOnSpawn=false wGui.IgnoreGuiInset=true
			wGui.Parent = GP()

			local wBg = Instance.new("Frame", wGui)
			wBg.Size=UDim2.new(1,0,1,0) wBg.BackgroundColor3=Color3.fromRGB(0,0,0)
			wBg.BackgroundTransparency=0 wBg.BorderSizePixel=0 wBg.ZIndex=1

			local wTop = Instance.new("TextLabel", wGui)
			wTop.Size=UDim2.new(1,0,0,30) wTop.Position=UDim2.new(0,0,0.34,0)
			wTop.BackgroundTransparency=1 wTop.Text="BEM-VINDO AO"
			wTop.Font=Enum.Font.GothamBold wTop.TextSize=18
			wTop.TextColor3=C.dim wTop.TextTransparency=1 wTop.ZIndex=5

			local wMain = Instance.new("TextLabel", wGui)
			wMain.Size=UDim2.new(1,0,0,80) wMain.Position=UDim2.new(0,0,0.41,0)
			wMain.BackgroundTransparency=1 wMain.Text="SKY HUB"
			wMain.Font=Enum.Font.GothamBlack wMain.TextSize=64
			wMain.TextColor3=C.a1 wMain.TextTransparency=1 wMain.ZIndex=5

			local wLine = Instance.new("Frame", wGui)
			wLine.Size=UDim2.new(0,0,0,2)
			wLine.Position=UDim2.new(0.5,0,0.60,0)
			wLine.AnchorPoint=Vector2.new(0.5,0)
			wLine.BackgroundColor3=C.a1
			wLine.BackgroundTransparency=1
			wLine.BorderSizePixel=0 wLine.ZIndex=5

			local wSub = Instance.new("TextLabel", wGui)
			wSub.Size=UDim2.new(1,0,0,24) wSub.Position=UDim2.new(0,0,0.64,0)
			wSub.BackgroundTransparency=1
			wSub.Text = isAdmin and "MODO ADMIN ATIVADO" or "ACESSO LIBERADO"
			wSub.Font=Enum.Font.GothamBold wSub.TextSize=14
			wSub.TextColor3 = isAdmin and C.gold or C.green
			wSub.TextTransparency=1 wSub.ZIndex=5

			-- sequência simples sem loop bloqueante
			task.wait(0.15)
			TW(wTop, 0.5, {TextTransparency=0})
			task.wait(0.3)
			TW(wMain, 0.5, {TextTransparency=0})
			task.wait(0.3)
			TW(wLine, 0.4, {Size=UDim2.new(0,260,0,2), BackgroundTransparency=0.3})
			task.wait(0.25)
			TW(wSub, 0.4, {TextTransparency=0})
			task.wait(0.4)

			-- pulsa cor (task.spawn separado, não bloqueia)
			task.spawn(function()
				local cs={C.a2,C.a3,C.green,C.a1,C.a2,C.a3,C.green,C.a1}
				for _,c in ipairs(cs) do
					TW(wMain,0.35,{TextColor3=c})
					TW(wLine,0.35,{BackgroundColor3=c})
					task.wait(0.35)
				end
			end)

			-- espera 3s enquanto cores pulsam
			task.wait(3)

			-- some tudo
			TW(wTop,  0.3, {TextTransparency=1})
			TW(wMain, 0.3, {TextTransparency=1})
			TW(wSub,  0.3, {TextTransparency=1})
			TW(wLine, 0.3, {BackgroundTransparency=1})
			task.wait(0.2)
			TW(wBg, 0.5, {BackgroundTransparency=1})
			task.wait(0.55)
			wGui:Destroy()
			pinGui:Destroy()
			unlocked = true

		else
			pinBtn.Text="ENTRAR" pinBtn.Active=true
			pinSub.Text="Key invalida ou expirada!"
			TW(pinSub,0.1,{TextColor3=C.a3})
			task.wait(2)
			pinSub.Text="VERIFICACAO DE ACESSO"
			TW(pinSub,0.2,{TextColor3=C.dim})
		end
	end)
end)

repeat task.wait() until unlocked

-- ================================================================
-- TELA PC / CELULAR
-- ================================================================
local deviceGui = Instance.new("ScreenGui")
deviceGui.Name="SKY_DEVICE" deviceGui.ResetOnSpawn=false deviceGui.IgnoreGuiInset=true
deviceGui.Parent = GP()

local devBg = Instance.new("Frame", deviceGui)
devBg.Size=UDim2.new(1,0,1,0) devBg.BackgroundColor3=Color3.fromRGB(0,0,0)
devBg.BackgroundTransparency=0.5 devBg.BorderSizePixel=0

local devFrame = Instance.new("Frame", deviceGui)
devFrame.Size=UDim2.new(0,320,0,190)
devFrame.Position=UDim2.new(0.5,-160,0.5,-95)
devFrame.BackgroundColor3=C.bg devFrame.BorderSizePixel=0
corner(devFrame,18) stroke(devFrame,1.5,C.a1)
grad(devFrame, Color3.fromRGB(12,8,24), Color3.fromRGB(5,5,14), 160)

local devTitle = Instance.new("TextLabel", devFrame)
devTitle.Size=UDim2.new(1,0,0,40) devTitle.Position=UDim2.new(0,0,0,10)
devTitle.BackgroundTransparency=1 devTitle.Text="SKY HUB v3.0"
devTitle.Font=Enum.Font.GothamBlack devTitle.TextSize=20 devTitle.TextColor3=C.a1

local devSub = Instance.new("TextLabel", devFrame)
devSub.Size=UDim2.new(1,0,0,18) devSub.Position=UDim2.new(0,0,0,48)
devSub.BackgroundTransparency=1 devSub.Text="Selecione sua plataforma"
devSub.Font=Enum.Font.Gotham devSub.TextSize=11 devSub.TextColor3=C.dim

local function devBtn(icon, label, xp)
	local btn = Instance.new("TextButton", devFrame)
	btn.Size=UDim2.new(0,128,0,76) btn.Position=UDim2.new(0,xp,0,76)
	btn.BackgroundColor3=C.btnOff btn.BorderSizePixel=0
	btn.Text="" btn.AutoButtonColor=false
	corner(btn,14) stroke(btn,1.5,C.a1)

	local ic = Instance.new("TextLabel", btn)
	ic.Size=UDim2.new(1,0,0,38) ic.Position=UDim2.new(0,0,0,6)
	ic.BackgroundTransparency=1 ic.Text=icon
	ic.Font=Enum.Font.GothamBlack ic.TextSize=30 ic.TextColor3=C.a1

	local lb = Instance.new("TextLabel", btn)
	lb.Size=UDim2.new(1,0,0,18) lb.Position=UDim2.new(0,0,0,52)
	lb.BackgroundTransparency=1 lb.Text=label
	lb.Font=Enum.Font.GothamBold lb.TextSize=12 lb.TextColor3=C.white

	btn.MouseEnter:Connect(function() TW(btn,0.15,{BackgroundColor3=Color3.fromRGB(28,20,50)}) end)
	btn.MouseLeave:Connect(function() TW(btn,0.15,{BackgroundColor3=C.btnOff}) end)
	return btn
end

local pcBtn     = devBtn("PC",     "PC / Teclado", 20)
local mobileBtn = devBtn("CEL",    "Celular",      172)

local chosenMobile = false
local deviceChosen = false

pcBtn.MouseButton1Click:Connect(function()
	chosenMobile=false
	TW(devFrame,0.25,{BackgroundTransparency=1}) TW(devBg,0.25,{BackgroundTransparency=1})
	task.wait(0.3) deviceChosen=true deviceGui:Destroy()
end)
mobileBtn.MouseButton1Click:Connect(function()
	chosenMobile=true
	TW(devFrame,0.25,{BackgroundTransparency=1}) TW(devBg,0.25,{BackgroundTransparency=1})
	task.wait(0.3) deviceChosen=true deviceGui:Destroy()
end)

repeat task.wait() until deviceChosen

-- ================================================================
-- VARIÁVEIS JOGO
-- ================================================================
local character, humanoid, rootPart
local defaultSpeed=16
local speedEnabled=false  local savedSpeed=nil
local infiniteJump=false  local flyEnabled=false
local bodyVel=nil         local bodyGyr=nil
local noclipEnabled=false local espEnabled=false
local antiLagEnabled=false

local function setupChar(char)
	character=char
	humanoid=char:WaitForChild("Humanoid")
	rootPart=char:WaitForChild("HumanoidRootPart")
	defaultSpeed=humanoid.WalkSpeed
	if speedEnabled and savedSpeed then humanoid.WalkSpeed=savedSpeed end
	if bodyVel then bodyVel:Destroy() bodyVel=nil end
	if bodyGyr then bodyGyr:Destroy() bodyGyr=nil end
	flyEnabled=false
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(setupChar)

-- ================================================================
-- GUI PRINCIPAL
-- ================================================================
local gui = Instance.new("ScreenGui")
gui.Name="SKY_GUI" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true
gui.Parent = GP()

local savedPos = UDim2.new(0.5,-150,0.5,-260)

local frame = Instance.new("Frame", gui)
frame.Size=UDim2.new(0,300,0,560) frame.Position=savedPos
frame.BackgroundColor3=C.bg frame.BorderSizePixel=0
frame.Visible=false frame.Active=true frame.Draggable=true
corner(frame,16)
grad(frame, Color3.fromRGB(10,8,20), Color3.fromRGB(5,5,14), 160)

-- sombra DENTRO do frame (se move junto)
local shadow = Instance.new("Frame", frame)
shadow.Size=UDim2.new(1,16,1,16) shadow.Position=UDim2.new(0,-8,0,-8)
shadow.BackgroundColor3=Color3.fromRGB(0,0,0) shadow.BackgroundTransparency=0.55
shadow.BorderSizePixel=0 shadow.ZIndex=frame.ZIndex-1
corner(shadow,20)

-- salva posição ao soltar
frame.InputEnded:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1
	or inp.UserInputType==Enum.UserInputType.Touch then
		savedPos=frame.Position
	end
end)

local frameStroke = stroke(frame,1.5,C.a1)

local topGlow = Instance.new("Frame", frame)
topGlow.Size=UDim2.new(0.6,0,0,1) topGlow.Position=UDim2.new(0.2,0,0,0)
topGlow.BackgroundColor3=C.a1 topGlow.BackgroundTransparency=0.1 topGlow.BorderSizePixel=0

-- HEADER
local header = Instance.new("Frame", frame)
header.Size=UDim2.new(1,0,0,54) header.BackgroundColor3=C.panel header.BorderSizePixel=0
corner(header,16)
local hFix = Instance.new("Frame", header)
hFix.Size=UDim2.new(1,0,0.5,0) hFix.Position=UDim2.new(0,0,0.5,0)
hFix.BackgroundColor3=C.panel hFix.BorderSizePixel=0

local titleSky = Instance.new("TextLabel", header)
titleSky.Size=UDim2.new(0,80,1,0) titleSky.Position=UDim2.new(0,16,0,0)
titleSky.BackgroundTransparency=1 titleSky.Text="SKY"
titleSky.Font=Enum.Font.GothamBlack titleSky.TextSize=22
titleSky.TextColor3=C.a1 titleSky.TextXAlignment=Enum.TextXAlignment.Left

local v3Badge = Instance.new("TextLabel", header)
v3Badge.Size=UDim2.new(0,40,0,16) v3Badge.Position=UDim2.new(0,58,0,8)
v3Badge.BackgroundColor3=C.a1 v3Badge.BackgroundTransparency=0.7
v3Badge.BorderSizePixel=0 v3Badge.Text="v3.0"
v3Badge.Font=Enum.Font.GothamBold v3Badge.TextSize=9 v3Badge.TextColor3=C.white
corner(v3Badge,4)

local adminBadge = Instance.new("TextLabel", header)
adminBadge.Size=UDim2.new(0,56,0,16) adminBadge.Position=UDim2.new(0,102,0,8)
adminBadge.BackgroundColor3=C.gold adminBadge.BorderSizePixel=0
adminBadge.Text="ADMIN" adminBadge.Font=Enum.Font.GothamBold
adminBadge.TextSize=9 adminBadge.TextColor3=C.gold
adminBadge.BackgroundTransparency = isAdmin and 0.5 or 1
adminBadge.TextTransparency       = isAdmin and 0   or 1
corner(adminBadge,4)

local zHint = Instance.new("TextLabel", header)
zHint.Size=UDim2.new(0,100,1,0) zHint.Position=UDim2.new(1,-110,0,0)
zHint.BackgroundTransparency=1 zHint.Text="[Z] fechar"
zHint.Font=Enum.Font.Gotham zHint.TextSize=9
zHint.TextColor3=C.dim zHint.TextXAlignment=Enum.TextXAlignment.Right

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size=UDim2.new(1,0,1,-58) scroll.Position=UDim2.new(0,0,0,58)
scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3 scroll.ScrollBarImageColor3=C.a1

local yy = 10

local function mkSep()
	local s=Instance.new("Frame",scroll)
	s.Size=UDim2.new(1,-24,0,1) s.Position=UDim2.new(0,12,0,yy)
	s.BackgroundColor3=C.border s.BackgroundTransparency=0.7 s.BorderSizePixel=0
	yy=yy+10
end

local function mkSection(text, color)
	local dot=Instance.new("Frame",scroll)
	dot.Size=UDim2.new(0,6,0,6) dot.Position=UDim2.new(0,14,0,yy+9)
	dot.BackgroundColor3=color dot.BorderSizePixel=0 corner(dot,3)
	local lbl=Instance.new("TextLabel",scroll)
	lbl.Size=UDim2.new(1,-32,0,24) lbl.Position=UDim2.new(0,26,0,yy)
	lbl.BackgroundTransparency=1 lbl.Text=text
	lbl.Font=Enum.Font.GothamBold lbl.TextSize=10
	lbl.TextColor3=color lbl.TextXAlignment=Enum.TextXAlignment.Left
	yy=yy+26
	return lbl
end

local function mkBtn(label, color)
	local btn=Instance.new("TextButton",scroll)
	btn.Size=UDim2.new(1,-24,0,36) btn.Position=UDim2.new(0,12,0,yy)
	btn.BackgroundColor3=C.btnOff btn.BorderSizePixel=0
	btn.Text="" btn.AutoButtonColor=false corner(btn,9)
	local bstroke=Instance.new("UIStroke",btn)
	bstroke.Thickness=1 bstroke.Color=color bstroke.Transparency=0.6
	local bdot=Instance.new("Frame",btn)
	bdot.Size=UDim2.new(0,7,0,7) bdot.Position=UDim2.new(0,12,0.5,-3)
	bdot.BackgroundColor3=C.dim bdot.BorderSizePixel=0 corner(bdot,4)
	local blbl=Instance.new("TextLabel",btn)
	blbl.Size=UDim2.new(1,-30,1,0) blbl.Position=UDim2.new(0,26,0,0)
	blbl.BackgroundTransparency=1 blbl.Text=label
	blbl.Font=Enum.Font.GothamBold blbl.TextSize=13
	blbl.TextColor3=C.dim blbl.TextXAlignment=Enum.TextXAlignment.Left
	local function setState(on)
		if on then
			TW(btn,0.2,{BackgroundColor3=C.btnOn})
			TW(bstroke,0.2,{Transparency=0,Color=color})
			TW(bdot,0.2,{BackgroundColor3=color})
			TW(blbl,0.2,{TextColor3=color})
		else
			TW(btn,0.2,{BackgroundColor3=C.btnOff})
			TW(bstroke,0.2,{Transparency=0.6,Color=color})
			TW(bdot,0.2,{BackgroundColor3=C.dim})
			TW(blbl,0.2,{TextColor3=C.dim})
		end
	end
	btn.MouseEnter:Connect(function() TW(btn,0.1,{BackgroundColor3=Color3.fromRGB(28,28,45)}) end)
	btn.MouseLeave:Connect(function() TW(btn,0.1,{BackgroundColor3=C.btnOff}) end)
	yy=yy+44
	return btn, blbl, setState
end

local function mkBox(ph)
	local wrap=Instance.new("Frame",scroll)
	wrap.Size=UDim2.new(1,-24,0,34) wrap.Position=UDim2.new(0,12,0,yy)
	wrap.BackgroundColor3=C.panel wrap.BorderSizePixel=0
	corner(wrap,8) stroke(wrap,1,C.border)
	local box=Instance.new("TextBox",wrap)
	box.Size=UDim2.new(1,-16,1,0) box.Position=UDim2.new(0,8,0,0)
	box.BackgroundTransparency=1 box.PlaceholderText=ph
	box.PlaceholderColor3=C.dim box.Text=""
	box.Font=Enum.Font.Gotham box.TextSize=13
	box.TextColor3=C.white box.ClearTextOnFocus=false
	yy=yy+42
	return box
end

-- seções
mkSection("VELOCIDADE", C.a2)
local speedBox = mkBox("Velocidade (Ex: 100)")
local speedBtn,speedLbl,speedSet = mkBtn("Velocidade  OFF", C.a2)
mkSep()

mkSection("PULO INFINITO", C.green)
local jumpBtn,jumpLbl,jumpSet = mkBtn("Pulo Infinito  OFF", C.green)
mkSep()

mkSection("VOAR", C.a1)
local flyBox = mkBox("Vel. fly (Ex: 60)")
local flyBtn,flyLbl,flySet = mkBtn("Fly  OFF", C.a1)
mkSep()

mkSection("NO-CLIP", C.a3)
local noclipBtn,noclipLbl,noclipSet = mkBtn("No-Clip  OFF", C.a3)
mkSep()

mkSection("ESP PLAYERS", Color3.fromRGB(255,80,80))
local espBtn,espLbl,espSet = mkBtn("ESP  OFF", Color3.fromRGB(255,80,80))
mkSep()

mkSection("ANTI-LAG", Color3.fromRGB(255,165,0))
local antiBtn,antiLbl,antiSet = mkBtn("Anti-Lag  OFF", Color3.fromRGB(255,165,0))
mkSep()

scroll.CanvasSize = UDim2.new(0,0,0,yy+16)

-- ================================================================
-- BOTÃO S (minimizar)
-- ================================================================
local mini = Instance.new("ImageButton", gui)
mini.Size=UDim2.new(0,54,0,54) mini.Position=UDim2.new(0,16,1,-72)
mini.BackgroundColor3=C.bg mini.BorderSizePixel=0
mini.Image="" mini.ZIndex=10 mini.Active=true
corner(mini,14)
grad(mini, Color3.fromRGB(18,10,40), Color3.fromRGB(8,8,18), 135)
local miniStroke = stroke(mini,2,C.a1)

local miniS = Instance.new("TextLabel", mini)
miniS.Size=UDim2.new(1,0,1,0) miniS.BackgroundTransparency=1
miniS.Text="S" miniS.Font=Enum.Font.GothamBlack
miniS.TextSize=26 miniS.TextColor3=C.a1 miniS.ZIndex=12

task.spawn(function()
	local cs={C.a1,C.a2,C.a3,C.green}
	while mini.Parent do
		for _,c in ipairs(cs) do
			TW(miniStroke,1.4,{Color=c}) TW(miniS,1.4,{TextColor3=c})
			task.wait(1.4)
		end
	end
end)

mini.MouseEnter:Connect(function() TW(miniStroke,0.15,{Thickness=2.5}) end)
mini.MouseLeave:Connect(function() TW(miniStroke,0.15,{Thickness=2}) end)

-- toggle
local function toggleGui()
	if frame.Visible then
		savedPos = frame.Position
		frame.Visible = false
	else
		frame.Position = savedPos
		frame.Visible = true
	end
end

mini.MouseButton1Click:Connect(toggleGui)
UserInputService.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if inp.KeyCode==Enum.KeyCode.Z then toggleGui() end
end)

-- animação borda principal
task.spawn(function()
	local cs={C.a1,C.a2,C.a3,C.green}
	while frame.Parent do
		for _,c in ipairs(cs) do
			TW(frameStroke,1.4,{Color=c}) TW(topGlow,1.4,{BackgroundColor3=c})
			task.wait(1.4)
		end
	end
end)

-- ================================================================
-- VELOCIDADE
-- ================================================================
speedBtn.MouseButton1Click:Connect(function()
	if not humanoid then return end
	speedEnabled = not speedEnabled
	if speedEnabled then
		local v=tonumber(speedBox.Text)
		if v and v>0 then
			savedSpeed=v humanoid.WalkSpeed=v
			speedSet(true) speedLbl.Text="Velocidade  ON | "..v
		else speedEnabled=false end
	else
		savedSpeed=nil humanoid.WalkSpeed=defaultSpeed
		speedSet(false) speedLbl.Text="Velocidade  OFF"
	end
end)

RunService.RenderStepped:Connect(function()
	if speedEnabled and humanoid and savedSpeed then
		if humanoid.WalkSpeed~=savedSpeed then humanoid.WalkSpeed=savedSpeed end
	end
end)

-- ================================================================
-- PULO INFINITO
-- ================================================================
jumpBtn.MouseButton1Click:Connect(function()
	infiniteJump=not infiniteJump
	jumpSet(infiniteJump)
	jumpLbl.Text=infiniteJump and "Pulo Infinito  ON" or "Pulo Infinito  OFF"
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ================================================================
-- FLY
-- ================================================================
flyBtn.MouseButton1Click:Connect(function()
	if not rootPart then return end
	flyEnabled=not flyEnabled
	if flyEnabled then
		bodyVel=Instance.new("BodyVelocity",rootPart)
		bodyVel.MaxForce=Vector3.new(1e6,1e6,1e6)
		bodyVel.Velocity=Vector3.zero
		bodyGyr=Instance.new("BodyGyro",rootPart)
		bodyGyr.MaxTorque=Vector3.new(1e6,1e6,1e6)
		flySet(true) flyLbl.Text="Fly  ON"
	else
		if bodyVel then bodyVel:Destroy() bodyVel=nil end
		if bodyGyr then bodyGyr:Destroy() bodyGyr=nil end
		flySet(false) flyLbl.Text="Fly  OFF"
	end
end)

RunService.RenderStepped:Connect(function()
	if not(flyEnabled and bodyVel and bodyGyr) then return end
	local sp=tonumber(flyBox.Text) or 50
	local cam=workspace.CurrentCamera
	local dir=Vector3.zero
	if not chosenMobile then
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
	else
		local mv=humanoid.MoveDirection
		if mv.Magnitude>0.1 then dir=mv end
	end
	bodyVel.Velocity=dir.Magnitude>0 and dir.Unit*sp or Vector3.zero
	bodyGyr.CFrame=cam.CFrame
end)

-- ================================================================
-- NOCLIP
-- ================================================================
noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled=not noclipEnabled
	noclipSet(noclipEnabled)
	noclipLbl.Text=noclipEnabled and "No-Clip  ON" or "No-Clip  OFF"
end)

RunService.Stepped:Connect(function()
	if noclipEnabled and character then
		for _,p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide=false end
		end
	end
end)

-- ================================================================
-- ANTI-LAG
-- ================================================================
antiBtn.MouseButton1Click:Connect(function()
	antiLagEnabled=not antiLagEnabled
	antiSet(antiLagEnabled)
	antiLbl.Text=antiLagEnabled and "Anti-Lag  ON" or "Anti-Lag  OFF"
	if antiLagEnabled then
		pcall(function() game:GetService("Lighting").GlobalShadows=false end)
		for _,o in ipairs(workspace:GetDescendants()) do
			if o:IsA("ParticleEmitter") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then
				o.Enabled=false
			end
		end
	else
		pcall(function() game:GetService("Lighting").GlobalShadows=true end)
		for _,o in ipairs(workspace:GetDescendants()) do
			if o:IsA("ParticleEmitter") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then
				o.Enabled=true
			end
		end
	end
end)

-- ================================================================
-- ESP
-- ================================================================
local espCache={} local lineCache={}

local lineGui=Instance.new("ScreenGui")
lineGui.Name="ESP_LINES" lineGui.ResetOnSpawn=false lineGui.IgnoreGuiInset=true
lineGui.Parent=GP()

local function mkLine()
	local l=Instance.new("Frame",lineGui)
	l.BackgroundColor3=Color3.fromRGB(255,50,50)
	l.BorderSizePixel=0 l.AnchorPoint=Vector2.new(0.5,0)
	l.Visible=false return l
end

local function updateLine(l,from,to)
	local dx=to.X-from.X local dy=to.Y-from.Y
	local dist=math.sqrt(dx*dx+dy*dy)
	l.Size=UDim2.new(0,dist,0,2)
	l.Position=UDim2.new(0,from.X,0,from.Y)
	l.Rotation=math.deg(math.atan2(dy,dx))
	l.Visible=true
end

local function addESP(char)
	if espCache[char] then return end
	local h=Instance.new("Highlight")
	h.FillColor=Color3.fromRGB(255,0,0)
	h.OutlineColor=Color3.fromRGB(255,80,80)
	h.FillTransparency=0.5
	h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent=char espCache[char]=h lineCache[char]=mkLine()
end

local function clearESP()
	for c,h in pairs(espCache) do if h then h:Destroy() end end
	for c,l in pairs(lineCache) do if l then l:Destroy() end end
	espCache={} lineCache={}
end

espBtn.MouseButton1Click:Connect(function()
	espEnabled=not espEnabled
	espSet(espEnabled)
	espLbl.Text=espEnabled and "ESP  ON" or "ESP  OFF"
	if espEnabled then
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=player and p.Character then addESP(p.Character) end
		end
	else clearESP() end
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(c)
		task.wait(1) if espEnabled then addESP(c) end
	end)
end)

RunService.RenderStepped:Connect(function()
	if not espEnabled or not rootPart then return end
	local cam=workspace.CurrentCamera
	local origin=Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
	for char,line in pairs(lineCache) do
		if not char or not char.Parent then
			if line then line:Destroy() end lineCache[char]=nil
		else
			local rp=char:FindFirstChild("HumanoidRootPart")
			if rp then
				local sp,on=cam:WorldToViewportPoint(rp.Position)
				if on then updateLine(line,origin,Vector2.new(sp.X,sp.Y))
				else line.Visible=false end
			end
		end
	end
end)

-- ================================================================
-- FLY MOBILE (botões subir/descer)
-- ================================================================
if chosenMobile then
	local fmGui=Instance.new("ScreenGui")
	fmGui.Name="FLY_MOBILE" fmGui.ResetOnSpawn=false fmGui.IgnoreGuiInset=true
	fmGui.Parent=GP()

	local function fmBtn(icon, pos)
		local b=Instance.new("TextButton",fmGui)
		b.Size=UDim2.new(0,52,0,52) b.Position=pos
		b.BackgroundColor3=Color3.fromRGB(20,20,40)
		b.BackgroundTransparency=0.3 b.BorderSizePixel=0
		b.Text=icon b.Font=Enum.Font.GothamBlack
		b.TextSize=24 b.TextColor3=C.white
		b.AutoButtonColor=false b.ZIndex=15 b.Visible=false
		corner(b,12) stroke(b,1.5,C.a1,0.3)
		return b
	end

	local upBtn   = fmBtn("^", UDim2.new(1,-130,1,-180))
	local downBtn = fmBtn("v", UDim2.new(1,-130,1,-120))

	flyBtn.MouseButton1Click:Connect(function()
		upBtn.Visible   = flyEnabled
		downBtn.Visible = flyEnabled
	end)

	upBtn.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then
			RunService:BindToRenderStep("FlyUp",200,function()
				if flyEnabled and bodyVel then
					bodyVel.Velocity=Vector3.new(bodyVel.Velocity.X,(tonumber(flyBox.Text) or 50)*0.5,bodyVel.Velocity.Z)
				end
			end)
		end
	end)
	upBtn.InputEnded:Connect(function() RunService:UnbindFromRenderStep("FlyUp") end)

	downBtn.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then
			RunService:BindToRenderStep("FlyDown",200,function()
				if flyEnabled and bodyVel then
					bodyVel.Velocity=Vector3.new(bodyVel.Velocity.X,-(tonumber(flyBox.Text) or 50)*0.5,bodyVel.Velocity.Z)
				end
			end)
		end
	end)
	downBtn.InputEnded:Connect(function() RunService:UnbindFromRenderStep("FlyDown") end)
end

print("[SKY HUB v3.0] OK "..(isAdmin and "| ADMIN" or "").." | "..(chosenMobile and "Mobile" or "PC"))

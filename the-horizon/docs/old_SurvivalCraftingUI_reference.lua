local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local TextService=game:GetService("TextService")
local ContextActionService=game:GetService("ContextActionService")
local UserInputService=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
for _,name in ipairs({"IngredientIconTuner","CraftingIngredientTunerUI","CraftingIngredientEditor","HorizonMaterialIconTuner"}) do
local previousTuner=playerGui:FindFirstChild(name)
if previousTuner then previousTuner:Destroy() end
end

local oldGui=playerGui:FindFirstChild("SurvivalCraftingUI")
if oldGui then
oldGui:Destroy()
end

local gui=Instance.new("ScreenGui")
gui.Name="SurvivalCraftingUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ScreenInsets=Enum.ScreenInsets.None
gui.DisplayOrder=11
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Enabled=true
gui.Parent=playerGui

local craftCompleteSound=Instance.new("Sound")
craftCompleteSound.Name="CraftCompleteSound"
craftCompleteSound.SoundId="rbxassetid://100545760361878"
craftCompleteSound.Parent=gui

local canvas=Instance.new("Frame")
canvas.Name="DesignCanvas"
canvas.AnchorPoint=Vector2.new(0.5,0.5)
canvas.Position=UDim2.fromScale(0.5,0.5)
canvas.Size=UDim2.fromOffset(1448,1086)
canvas.BackgroundTransparency=1
canvas.BorderSizePixel=0
canvas.Parent=gui

local canvasScale=Instance.new("UIScale")
canvasScale.Parent=canvas
local updateCraftingProgressScale
local refreshViewportLayout
local cameraConnection
local function updateCamera()
if cameraConnection then
cameraConnection:Disconnect()
end
local camera=workspace.CurrentCamera
if not camera then
return
end
local function updateScale()
local viewport=camera.ViewportSize
canvasScale.Scale=math.min(viewport.X/1906,viewport.Y/1086)
if refreshViewportLayout then refreshViewportLayout() end
if updateCraftingProgressScale then
updateCraftingProgressScale(viewport)
end
end
updateScale()
cameraConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
updateCamera()
local workspaceConnection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateCamera)

local craftingBlur=Instance.new("BlurEffect")
craftingBlur.Name="SurvivalCraftingBlur"
craftingBlur.Size=0
craftingBlur.Parent=Lighting
local worldBlur=craftingBlur

local function getInventoryGui()
return playerGui:FindFirstChild("SurvivalInventoryUI")
end

local function setCraftingVisible(visible)
gui:SetAttribute("CraftingVisible",visible)
local inventoryGui=getInventoryGui()
if inventoryGui then
inventoryGui:SetAttribute("CraftingVisible",visible)
end
end

local function closeInventory()
local inventoryGui=getInventoryGui()
local control=inventoryGui and inventoryGui:FindFirstChild("InventoryControl")
if control and control:IsA("BindableEvent") then
local inventoryCanvas=inventoryGui:FindFirstChild("DesignCanvas")
local inventoryPanel=inventoryCanvas and inventoryCanvas:FindFirstChild("InventoryPanel")
local position
if inventoryGui.Enabled and inventoryPanel and inventoryPanel:IsA("GuiObject") and inventoryPanel.Visible then
position=inventoryPanel.Position
end
control:Fire("Close",true)
return position
end
end

local surfaceColor=Color3.fromRGB(20,20,21)
local slotStrokeColor=Color3.fromRGB(78,79,82)
local dividerColor=Color3.fromRGB(52,53,55)
local primaryTextColor=Color3.fromRGB(242,242,243)
local secondaryTextColor=Color3.fromRGB(220,220,222)
local selectedColor=Color3.fromRGB(246,246,247)
local darkTextColor=Color3.fromRGB(25,25,27)
local inactiveButtonColor=Color3.fromRGB(27,27,29)
local bodyFont=Enum.Font.Gotham
local headingFont=Enum.Font.GothamBold

local function addCorner(parent,radius)
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,radius)
corner.Parent=parent
return corner
end

local function addStroke(parent,color,thickness,transparency)
local stroke=Instance.new("UIStroke")
stroke.Color=color
stroke.Thickness=thickness
stroke.Transparency=transparency or 0
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.LineJoinMode=Enum.LineJoinMode.Round
stroke.Parent=parent
return stroke
end

local function makeText(parent,name,text,position,size,textSize,textColor)
local label=Instance.new("TextLabel")
label.Name=name
label.Position=position
label.Size=size
label.BackgroundTransparency=1
label.BorderSizePixel=0
label.Font=bodyFont
label.Text=text
label.TextColor3=textColor or primaryTextColor
label.TextSize=textSize
label.TextStrokeTransparency=1
label.TextWrapped=false
label.TextScaled=false
label.TextXAlignment=Enum.TextXAlignment.Left
label.TextYAlignment=Enum.TextYAlignment.Center
label.Parent=parent
return label
end

local function fitTextSize(label,text,maxSize,minSize)
local width=math.max(1,label.Size.X.Offset-8)
for size=maxSize,minSize,-1 do
local bounds=TextService:GetTextSize(text,size,label.Font,Vector2.new(10000,label.Size.Y.Offset))
if bounds.X<=width then
label.TextSize=size
return
end
end
label.TextSize=minSize
end

local function makeEmptyIcon(parent,name,position,size)
local icon=Instance.new("ImageLabel")
icon.Name=name
icon.AnchorPoint=Vector2.new(0.5,0.5)
icon.Position=position
icon.Size=size
icon.BackgroundTransparency=1
icon.BorderSizePixel=0
icon.Image=""
icon.ScaleType=Enum.ScaleType.Fit
icon.Parent=parent
return icon
end

local craftingButton = Instance.new("ImageButton")
craftingButton.Name = "OpenCraftingButton"
craftingButton.Position = UDim2.fromOffset(65, 972)
craftingButton.Size = UDim2.fromOffset(80, 80)
craftingButton.BackgroundColor3 = surfaceColor
craftingButton.BackgroundTransparency = 0.25
craftingButton.BorderSizePixel = 0
craftingButton.AutoButtonColor = false
craftingButton.Image = ""
craftingButton.Visible = true
craftingButton.ZIndex = 40
craftingButton.Parent = canvas
addCorner(craftingButton, 10)
local craftingButtonIcon = makeEmptyIcon(craftingButton, "CraftingIcon", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(96, 96))
craftingButtonIcon.Image = "rbxassetid://87751835026907"
craftingButtonIcon.Name = "CraftingIcon"
craftingButtonIcon.ZIndex = 41

local customItemImages={
nail="rbxassetid://100720163739756",
campfire="rbxassetid://90051487646621",
fiber="rbxassetid://85899584797851",
leaf="rbxassetid://94252892154991",
torch="rbxassetid://128672619441958",
seawatercup="rbxassetid://94755334875949",
coconut="rbxassetid://80850807866324",
hide="rbxassetid://137106848150031",
cleanwatercup="rbxassetid://75855735142648",
cookedmeat="rbxassetid://119892341342609",
rawmeat="rbxassetid://78834596178891",
plastic="rbxassetid://126538877519520",
plasticcup="rbxassetid://79794572624392",
woodenshield="rbxassetid://104624286311499",
scrapmetal="rbxassetid://123247338574784",
bow="rbxassetid://103839860687597",
arrow="rbxassetid://87510233891000",
stonearrows="rbxassetid://87510233891000",
stonesword="rbxassetid://99964958308218",
rope="rbxassetid://94728420315409",
spear="rbxassetid://131953404883594",
club="rbxassetid://77142435102160",
stonepickaxe="rbxassetid://103209016597189",
plank="rbxassetid://78387750873126",
stone="rbxassetid://127351259030040",
stoneaxe="rbxassetid://73396827796121",
buildinghammer="rbxassetid://85234448517206",
pickaxe="rbxassetid://103209016597189",
axe="rbxassetid://73396827796121",
sword="rbxassetid://99964958308218",
stonespear="rbxassetid://131953404883594",
woodenspear="rbxassetid://131953404883594",
woodenclub="rbxassetid://77142435102160",
leaves="rbxassetid://94252892154991",
planks="rbxassetid://78387750873126",
nails="rbxassetid://100720163739756",
metalscrap="rbxassetid://123247338574784",
scrap="rbxassetid://123247338574784",
rock="rbxassetid://127351259030040",
cup="rbxassetid://79794572624392",
emptycup="rbxassetid://79794572624392",
}

local itemImageCache={}

local function normalizeItemName(itemName)
return string.lower(tostring(itemName or ""):gsub("[%s_%-]",""))
end

local function findItemImage(itemName)
local customImage=customItemImages[normalizeItemName(itemName)]
if customImage then
return customImage
end

local cached=itemImageCache[itemName]
if cached~=nil then
return cached
end

local image=""
local backpack=player:FindFirstChildOfClass("Backpack")
if backpack then
for _,item in ipairs(backpack:GetChildren()) do
if item:IsA("Tool") and (item.Name==itemName or item:GetAttribute("DisplayName")==itemName) then
image=item.TextureId
break
end
end
end

if image=="" then
for _,item in ipairs(ReplicatedStorage:GetDescendants()) do
if item:IsA("Tool") and (item.Name==itemName or item:GetAttribute("DisplayName")==itemName) then
image=item.TextureId
break
end
end
end

itemImageCache[itemName]=image
return image
end

local demoOwnedAmounts={}

local function getOwnedAmount(itemName)
return demoOwnedAmounts[itemName] or 0
end

local recipes={
{
Name="Stone Pickaxe",
Category="Tools",
Tag="Gathering",
Description="A basic mining tool for breaking stone and gathering ore.",
Materials={},
},
{
Name="Stone Axe",
Category="Tools",
Tag="Gathering",
Description="A basic chopping tool for cutting trees and gathering planks.",
Materials={},
},
{
Name="Building Hammer",
Category="Tools",
Tag="Building",
Description="A tool for planning and placing structures.",
Materials={},
},
{
Name="Stone Spear",
Category="Tools",
Tag="Weapon",
Description="A simple spear for hunting and defending yourself.",
Materials={},
},
{
Name="Wooden Club",
Category="Tools",
Tag="Weapon",
Description="A rough wooden club for close combat.",
Materials={},
},
{
Name="Stone Sword",
Category="Tools",
Tag="Weapon",
Description="A sharper stone weapon for stronger melee attacks.",
Materials={},
},
{
Name="Bow",
Category="Tools",
Tag="Weapon",
Description="A wooden bow for firing arrows.",
Materials={},
},
{
Name="Stone Arrows",
Category="Tools",
Tag="Ammunition",
Description="Stone-tipped arrows for a bow.",
Materials={},
},
{
Name="Wooden Shield",
Category="Tools",
Tag="Defense",
Description="A wooden shield for blocking attacks.",
Materials={{"Planks",6},{"Rope",2},{"Hide",1}},
},
{
Name="Metal Shield",
Category="Tools",
Tag="Defense",
Description="A metal shield for blocking attacks.",
NameOnly=true,
Materials={},
},
{
Name="Hide Helmet",
Category="Armor",
Tag="Armor",
Description="A hide covering for your head.",
NameOnly=true,
Materials={},
},
{
Name="Hide Chestplate",
Category="Armor",
Tag="Armor",
Description="A hide covering for your chest.",
NameOnly=true,
Materials={},
},
{
Name="Hide Gloves",
Category="Armor",
Tag="Armor",
Description="Hide gloves for your hands.",
NameOnly=true,
Materials={},
},
{
Name="Hide Leggings",
Category="Armor",
Tag="Armor",
Description="Hide coverings for your legs.",
NameOnly=true,
Materials={},
},
{
Name="Hide Boots",
Category="Armor",
Tag="Armor",
Description="Hide boots for your feet.",
NameOnly=true,
Materials={},
},
{
Name="Rope",
Category="Resources",
Tag="Material",
Description="A simple binding material made from leaves.",
Materials={},
},
{
Name="Nails",
Category="Resources",
Tag="Material",
Description="Basic metal fasteners used in construction.",
Materials={},
},
{
Name="Cup",
Category="General",
Tag="Utility",
Description="A simple plastic cup for carrying and drinking water.",
Materials={},
},
{
Name="Compass",
Category="General",
Tag="Navigation",
Description="A compass for finding your direction.",
NameOnly=true,
Materials={{"Scrap",3},{"Plastic",1}},
},
{
Name="Map",
Category="General",
Tag="Navigation",
Description="A hide map for finding your way.",
NameOnly=true,
Materials={{"Hide",2},{"Fiber",2}},
},
{
Name="Torch",
Category="General",
Tag="Utility",
Description="A handheld light for exploring dark areas.",
Materials={},
},
}


local ui={Settings={},Objects={},Order={},Scales={},Names={},Dynamic={},ArrowStrokes={},Quantity=1,Filtered={},ScrollTween=nil,ScrollTarget=nil,DetailTween=nil,StripTween=nil,DetailDirection=1,StripDirection=1}
ui.IconNameLayouts={
    Preview={X=0,Y=0,W=0,H=0,WScale=1,HScale=1,Scale=1,TextSize=32},
    Picker={X=0,Y=0,W=0,H=0,WScale=1,HScale=1,Scale=1,TextSize=18},
}
local function uiScaleFor(object)
    local scale=1
    while object and not object:IsA("ScreenGui") do
        local component=object:FindFirstChildOfClass("UIScale")
        if component then scale=scale*component.Scale end
        object=object.Parent
    end
    return math.max(0.001,scale)
end
local function layoutVector(parent,x,y,xScale,yScale)
    local ix,iy=math.round(x),math.round(y)
    xScale=xScale or 0
    yScale=yScale or 0
    if (x~=ix or y~=iy) and parent and parent:IsA("GuiObject") then
        local size=parent:IsA("ScrollingFrame") and parent.AbsoluteCanvasSize or parent.AbsoluteSize
        local scale=uiScaleFor(parent)
        if size.X>0 then xScale+=(x-ix)*scale/size.X end
        if size.Y>0 then yScale+=(y-iy)*scale/size.Y end
    end
    return UDim2.new(xScale,ix,yScale,iy)
end
ui.TextDecorations={}
local function renderText(object,component,layout,textSize)
    local parent=object.Parent
    local parentScale=uiScaleFor(parent)
    local scale=parentScale*layout.Scale
    local parentSize=parent:IsA("ScrollingFrame") and parent.AbsoluteCanvasSize or parent.AbsoluteSize
    local width=math.max(1,math.round((parentSize.X*(layout.WScale or 0)+layout.W*parentScale)*layout.Scale))
    local height=math.max(1,math.round((parentSize.Y*(layout.HScale or 0)+layout.H*parentScale)*layout.Scale))
    textSize=math.clamp(textSize or math.round(layout.TextSize*scale),1,math.min(100,height))
    local text=object.Text
    if text=="" and object:IsA("TextBox") then text=object.PlaceholderText end
    local bounds=TextService:GetTextSize(text,textSize,object.Font,Vector2.new(object.TextWrapped and width or 10000,10000))
    while object.TextWrapped and bounds.Y>height and textSize>1 do
        textSize-=1
        bounds=TextService:GetTextSize(text,textSize,object.Font,Vector2.new(width,10000))
    end
    component.Scale=1/parentScale
    object.TextScaled=false
    object.TextSize=textSize
    object.Size=UDim2.fromOffset(width,height)
    object.Position=layoutVector(parent,layout.X,layout.Y,layout.XScale,layout.YScale)
    local origin=object.AbsolutePosition
    local x,y=origin.X,origin.Y
    if object.TextXAlignment==Enum.TextXAlignment.Center then
        x+=(width-bounds.X)/2
    elseif object.TextXAlignment==Enum.TextXAlignment.Right then
        x+=width-bounds.X
    end
    local textHeight=object.TextWrapped and bounds.Y or textSize
    if object.TextYAlignment==Enum.TextYAlignment.Center then
        y+=(height-textHeight)/2
    elseif object.TextYAlignment==Enum.TextYAlignment.Bottom then
        y+=height-textHeight
    end
    object.Position=layoutVector(parent,layout.X+(math.round(x)-x)/parentScale,layout.Y+(math.round(y)-y)/parentScale,layout.XScale,layout.YScale)
    local decorations=ui.TextDecorations[object]
    if not decorations then
        decorations={}
        for _,child in ipairs(object:GetChildren()) do
            if child:IsA("UIStroke") then
                table.insert(decorations,{Object=child,Thickness=child.Thickness})
            elseif child:IsA("UICorner") then
                table.insert(decorations,{Object=child,CornerRadius=child.CornerRadius})
            end
        end
        ui.TextDecorations[object]=decorations
    end
    for _,decoration in ipairs(decorations) do
        if decoration.Thickness then
            decoration.Object.Thickness=decoration.Thickness*scale
        else
            local radius=decoration.CornerRadius
            decoration.Object.CornerRadius=UDim.new(radius.Scale,radius.Offset*scale)
        end
    end
end
local function registerUI(key,object,x,y,w,h,textSize,ax,ay)
    if x~=nil then
        object.AnchorPoint=Vector2.new(ax or 0,ay or 0)
        object.Position=UDim2.fromOffset(x,y)
        object.Size=UDim2.fromOffset(w,h)
    end
    local position,size=object.Position,object.Size
    local layout={X=position.X.Offset,Y=position.Y.Offset,W=size.X.Offset,H=size.Y.Offset,Scale=1,AX=object.AnchorPoint.X,AY=object.AnchorPoint.Y}
    if position.X.Scale~=0 then layout.XScale=position.X.Scale end
    if position.Y.Scale~=0 then layout.YScale=position.Y.Scale end
    if size.X.Scale~=0 then layout.WScale=size.X.Scale end
    if size.Y.Scale~=0 then layout.HScale=size.Y.Scale end
    if object.Rotation~=0 then layout.Rotation=object.Rotation end
    if textSize then
        layout.TextSize=textSize
        object.TextSize=textSize
        object.TextScaled=false
        object.TextStrokeTransparency=1
    end
    ui.Settings[key]=layout
    ui.Objects[key]=object
    table.insert(ui.Order,key)
    local scale=Instance.new("UIScale")
    scale.Name="CraftingElementScale"
    scale.Parent=object
    ui.Scales[key]=scale
    return object
end
local function registerDynamicUI(key,object,label)
    registerUI(key,object,0,0,0,0)
    ui.Dynamic[key]=true
    ui.Names[key]=label
end
local function dynamicGeometry(key,x,y,w,h)
    local layout=ui.Settings[key]
    local parent=ui.Objects[key].Parent
    return layoutVector(parent,x+layout.X,y+layout.Y),layoutVector(parent,math.max(0.1,w+layout.W),math.max(0.1,h+layout.H))
end
registerUI("OpenCraftingButton",craftingButton)
registerUI("OpenCraftingIcon",craftingButtonIcon)

local panelWidth,panelHeight=1202,774
local headerHeight=94
local craftingPanel=Instance.new("Frame")
craftingPanel.Name="CraftingPanel"
craftingPanel.BackgroundColor3=surfaceColor
craftingPanel.BackgroundTransparency=0.01
craftingPanel.BorderSizePixel=0
craftingPanel.ClipsDescendants=true
craftingPanel.Active=true
craftingPanel.Visible=false
craftingPanel.ZIndex=50
craftingPanel.Parent=canvas
addCorner(craftingPanel,22)
registerUI("Menu",craftingPanel,724,533,panelWidth,panelHeight,nil,0.5,0.5)

local function transparentFrame(parent,name)
    local frame=Instance.new("Frame")
    frame.Name=name
    frame.BackgroundTransparency=1
    frame.BorderSizePixel=0
    frame.ZIndex=51
    frame.Parent=parent
    return frame
end
local craftingBrowser=transparentFrame(craftingPanel,"RecipeBrowser")
craftingBrowser.Size=UDim2.fromScale(1,1)
registerUI("RecipeBrowser",craftingBrowser)
local craftingDetails=transparentFrame(craftingPanel,"RecipeDetails")
craftingDetails.AnchorPoint=Vector2.new(0.5,0.5)
craftingDetails.Position=UDim2.fromScale(0.5,0.5)
craftingDetails.Size=UDim2.fromOffset(1100,750)
registerUI("RecipeDetails",craftingDetails)
ui.DetailMotion=transparentFrame(craftingDetails,"RecipeContentMotion")
ui.DetailMotion.Size=UDim2.fromScale(1,1)

ui.Header=transparentFrame(craftingPanel,"Header")
registerUI("Header",ui.Header,0,0,panelWidth,headerHeight)
ui.Header.BackgroundColor3=Color3.fromRGB(255,255,255)
ui.Header.BackgroundTransparency=0
do
    local gradient=Instance.new("UIGradient")
    gradient.Rotation=90
    gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.96),NumberSequenceKeypoint.new(1,1)})
    gradient.Parent=ui.Header
end
ui.HeaderLine=transparentFrame(craftingPanel,"HeaderDivider")
ui.HeaderLine.BackgroundColor3=dividerColor
ui.HeaderLine.BackgroundTransparency=0
ui.HeaderLine.Position=UDim2.fromOffset(0,headerHeight-2)
ui.HeaderLine.Size=UDim2.new(1,0,0,2)
registerUI("HeaderDivider",ui.HeaderLine)
local headerIcon=makeEmptyIcon(ui.Header,"CraftingHeaderIcon",UDim2.new(),UDim2.new())
headerIcon.Image="rbxassetid://87751835026907"
headerIcon.ZIndex=63
registerUI("HeaderIcon",headerIcon,24,5,72,72)
local craftingTitle=makeText(ui.Header,"CraftingTitle","CRAFTING",UDim2.new(),UDim2.new(),33,primaryTextColor)
craftingTitle.Font=headingFont
craftingTitle.ZIndex=63
registerUI("HeaderTitle",craftingTitle,113,12,300,72,33)

local function makeCross(parent,name,strokeSize)
    local button=Instance.new("TextButton")
    button.Name=name
    button.BackgroundTransparency=1
    button.BorderSizePixel=0
    button.Text=""
    button.AutoButtonColor=false
    button.ZIndex=70
    button.Parent=parent
    for index,rotation in ipairs({45,-45}) do
        local line=Instance.new("Frame")
        line.Name="CrossLine"
        line.AnchorPoint=Vector2.new(0.5,0.5)
        line.Position=UDim2.fromScale(0.5,0.5)
        line.Size=strokeSize
        line.BackgroundColor3=primaryTextColor
        line.BorderSizePixel=0
        line.Rotation=rotation
        line.ZIndex=71
        line.Parent=button
        local key=name.."Stroke"..index
        registerUI(key,line)
        ui.Names[key]=(name=="CloseButton" and "Close" or "Clear search").." · stroke "..index
    end
    return button
end
local craftingClose=makeCross(craftingPanel,"CloseButton",UDim2.fromOffset(2,40))
registerUI("CloseButton",craftingClose,panelWidth-59,49,44,44,nil,0.5,0.5)
addCorner(ui.Objects.CloseButtonStroke1,1)
addCorner(ui.Objects.CloseButtonStroke2,1)

ui.Tabs=transparentFrame(craftingBrowser,"CategoryTabs")
registerUI("CategoryTabs",ui.Tabs,24,headerHeight+12,608,42)
local categoryNames={"Tools","Armor","Resources","General"}
local categoryButtons={}
do
    local x=0
    for _,name in ipairs(categoryNames) do
        local width=math.ceil(TextService:GetTextSize(name,28,bodyFont,Vector2.new(1000,42)).X)
        local button=Instance.new("TextButton")
        button.Name=name
        button.BackgroundTransparency=1
        button.BorderSizePixel=0
        button.AutoButtonColor=false
        button.Font=bodyFont
        button.Text=name
        button.TextColor3=secondaryTextColor
        button.ZIndex=63
        button.Parent=ui.Tabs
        registerUI("Tab"..name,button,x,0,width,42,28)
        categoryButtons[name]={Button=button}
        ui.Names["Tab"..name]="Tab · "..name
        x+=width*1.05+32
    end
end

ui.CategoryUnderline=transparentFrame(ui.Tabs,"SelectedUnderline")
ui.CategoryUnderline.BackgroundColor3=selectedColor
ui.CategoryUnderline.BackgroundTransparency=0
ui.CategoryUnderline.ZIndex=64
registerDynamicUI("CategoryUnderline",ui.CategoryUnderline,"Category underline")

local searchFrame=transparentFrame(craftingBrowser,"SearchFrame")
searchFrame.BackgroundColor3=surfaceColor
searchFrame.BackgroundTransparency=0.01
searchFrame.ZIndex=61
registerUI("Search",searchFrame,759,headerHeight+12,416,42)
addCorner(searchFrame,10)
addStroke(searchFrame,slotStrokeColor,1.5,0)
local searchIcon=makeEmptyIcon(searchFrame,"SearchIcon",UDim2.fromOffset(26,21),UDim2.fromOffset(30,30))
searchIcon.Image="rbxassetid://126441952512098"
searchIcon.ImageColor3=primaryTextColor
searchIcon.ZIndex=63
registerUI("SearchIcon",searchIcon)
local recipeSearch=Instance.new("TextBox")
recipeSearch.Name="RecipeSearch"
recipeSearch.Position=UDim2.fromOffset(48,0)
recipeSearch.Size=UDim2.new(1,-88,1,0)
recipeSearch.BackgroundTransparency=1
recipeSearch.BorderSizePixel=0
recipeSearch.ClearTextOnFocus=false
recipeSearch.Font=bodyFont
recipeSearch.PlaceholderText="Find a recipe..."
recipeSearch.PlaceholderColor3=Color3.fromRGB(166,167,171)
recipeSearch.Text=""
recipeSearch.TextColor3=primaryTextColor
recipeSearch.TextSize=23
recipeSearch.TextScaled=false
recipeSearch.TextStrokeTransparency=1
recipeSearch.TextXAlignment=Enum.TextXAlignment.Left
recipeSearch.ZIndex=63
recipeSearch.Parent=searchFrame
registerUI("SearchText",recipeSearch,nil,nil,nil,nil,23)
ui.SearchClear=makeCross(searchFrame,"ClearSearch",UDim2.new(0,2,0.62,0))
ui.SearchClear.AnchorPoint=Vector2.new(1,0.5)
ui.SearchClear.Position=UDim2.new(1,-4,0.5,0)
ui.SearchClear.Size=UDim2.fromOffset(34,34)
ui.SearchClear.Visible=false
registerUI("SearchClear",ui.SearchClear)
ui.Results=makeText(searchFrame,"ResultsCount","",UDim2.new(),UDim2.new(),18,secondaryTextColor)
ui.Results.TextXAlignment=Enum.TextXAlignment.Right
ui.Results.ZIndex=63
registerUI("SearchResults",ui.Results,0,44,416,22,20)
ui.SearchQuery=""

local detailType=makeText(ui.DetailMotion,"RecipeType","",UDim2.new(),UDim2.new(),23,Color3.fromRGB(168,168,172))
detailType.Font=headingFont
detailType.ZIndex=63
registerUI("ItemType",detailType,1,171,480,26,23)
local detailName=makeText(ui.DetailMotion,"RecipeName","",UDim2.new(),UDim2.new(),34,primaryTextColor)
detailName.Font=headingFont
detailName.TextXAlignment=Enum.TextXAlignment.Left
detailName.ZIndex=63
registerUI("ItemName",detailName,150,130,800,42,34)
local detailDescription=makeText(ui.DetailMotion,"Description","",UDim2.new(),UDim2.new(),22,secondaryTextColor)
detailDescription.Font=Enum.Font.GothamMedium
detailDescription.TextXAlignment=Enum.TextXAlignment.Left
detailDescription.TextWrapped=true
detailDescription.ZIndex=63
registerUI("ItemSubtitle",detailDescription,150,172,800,26,24)
local previewFrame=transparentFrame(ui.DetailMotion,"Preview")
registerUI("ItemPreview",previewFrame,400,202,300,194)
local previewIcon=makeEmptyIcon(previewFrame,"RecipePreviewIcon",UDim2.new(),UDim2.new())
previewIcon.ZIndex=63
registerUI("ItemIcon",previewIcon,0,0,300,194)
ui.PreviewName=makeText(previewIcon,"RecipeIconName","",UDim2.new(),UDim2.fromScale(1,1),32,secondaryTextColor)
ui.PreviewName.Font=Enum.Font.GothamMedium
ui.PreviewName.TextXAlignment=Enum.TextXAlignment.Center
ui.PreviewName.TextWrapped=true
ui.PreviewName.Visible=false
ui.PreviewName.ZIndex=63
ui.PreviewNameScale=Instance.new("UIScale")
ui.PreviewNameScale.Parent=ui.PreviewName
local materialsHeader=makeText(ui.DetailMotion,"MaterialsHeader","YOU NEED",UDim2.new(),UDim2.new(),20,secondaryTextColor)
materialsHeader.Font=headingFont
materialsHeader.TextXAlignment=Enum.TextXAlignment.Center
materialsHeader.ZIndex=63
registerUI("MaterialsHeading",materialsHeader,150,400,800,24,22)

local materialFrames,materialRowScales,materialParts,materialPartScales={},{},{},{}
local materialTextKeys={"Required","Name","Amount"}
local materialTextGaps={6,6,0}
for index=1,6 do
    local frame=transparentFrame(ui.DetailMotion,"Material"..index)
    frame.ZIndex=61
    local scale=Instance.new("UIScale")
    scale.Name="IngredientRowScale"
    scale.Parent=frame
    local icon=makeEmptyIcon(frame,"MaterialIcon",UDim2.new(),UDim2.new())
    icon.ZIndex=63
    local required=makeText(frame,"MaterialRequired"..index,"",UDim2.new(),UDim2.new(),24,primaryTextColor)
    required.ZIndex=63
    local name=makeText(frame,"MaterialName"..index,"",UDim2.new(),UDim2.new(),24,primaryTextColor)
    name.ZIndex=63
    local amount=makeText(frame,"MaterialCount"..index,"",UDim2.new(),UDim2.new(),24,secondaryTextColor)
    amount.ZIndex=63
    materialFrames[index],materialRowScales[index]=frame,scale
    materialParts[index]={Icon=icon,Required=required,Name=name,Amount=amount}
    for _,key in ipairs(materialTextKeys) do
        materialParts[index][key].Font=Enum.Font.GothamMedium
    end
    local scales={}
    for key,object in pairs(materialParts[index]) do
        local partScale=Instance.new("UIScale")
        partScale.Name="IngredientPartScale"
        partScale.Parent=object
        scales[key]=partScale
    end
    materialPartScales[index]=scales
end

ui.Actions=transparentFrame(craftingDetails,"CraftActions")
registerUI("CraftControls",ui.Actions,150,552,800,52)
ui.QuantityGroup=transparentFrame(ui.Actions,"QuantityControls")
registerUI("QuantityControls",ui.QuantityGroup,0,6,198,40)
ui.QuantityGroup.Visible=false
local function quantityButton(name,value)
    local button=Instance.new("TextButton")
    button.Name=name
    button.Text=value
    button.Font=Enum.Font.GothamMedium
    button.TextColor3=primaryTextColor
    button.TextSize=28
    button.BackgroundColor3=surfaceColor
    button.BackgroundTransparency=1
    button.BorderSizePixel=0
    button.AutoButtonColor=false
    button.ZIndex=63
    button.Parent=ui.QuantityGroup
    addCorner(button,7)
    addStroke(button,slotStrokeColor,1.5,0)
    return button
end
ui.Minus=quantityButton("DecreaseQuantity","−")
registerUI("DecreaseQuantity",ui.Minus,0,0,40,40,28)
ui.Plus=quantityButton("IncreaseQuantity","+")
registerUI("IncreaseQuantity",ui.Plus,148,0,40,40,28)
ui.QuantityBox=Instance.new("TextBox")
ui.QuantityBox.Name="CraftQuantity"
ui.QuantityBox.BackgroundTransparency=1
ui.QuantityBox.BorderSizePixel=0
ui.QuantityBox.Text="1"
ui.QuantityBox.ClearTextOnFocus=false
ui.QuantityBox.Font=bodyFont
ui.QuantityBox.TextColor3=primaryTextColor
ui.QuantityBox.TextSize=22
ui.QuantityBox.ZIndex=63
ui.QuantityBox.Parent=ui.QuantityGroup
registerUI("QuantityNumber",ui.QuantityBox,54,0,80,40,24)
addCorner(ui.QuantityBox,7)
addStroke(ui.QuantityBox,slotStrokeColor,1.5,0)

local craftButton=Instance.new("TextButton")
craftButton.Name="CraftButton"
craftButton.BackgroundColor3=selectedColor
craftButton.BackgroundTransparency=0
craftButton.BorderSizePixel=0
craftButton.AutoButtonColor=false
craftButton.Text=""
craftButton.ZIndex=63
craftButton.Parent=ui.Actions
registerUI("CraftButton",craftButton,206,0,388,52)
addCorner(craftButton,9)
local craftText=makeText(craftButton,"Label","CRAFT",UDim2.new(),UDim2.new(),26,darkTextColor)
craftText.Font=headingFont
craftText.TextXAlignment=Enum.TextXAlignment.Center
craftText.ZIndex=64
registerUI("CraftLabel",craftText,0,0,388,52,26)
ui.Time=transparentFrame(ui.Actions,"CraftTime")
registerUI("CraftTime",ui.Time,632,0,168,52)
ui.Clock=makeEmptyIcon(ui.Time,"Clock",UDim2.fromOffset(0,12),UDim2.fromOffset(28,28))
ui.Clock.AnchorPoint=Vector2.new(0,0)
ui.Clock.Image="rbxassetid://123792581170649"
ui.Clock.ZIndex=63
registerUI("ClockIcon",ui.Clock)
do
    local detail=makeEmptyIcon(ui.Clock,"ClockDetail",UDim2.fromScale(0.5,0.5),UDim2.fromScale(1,1))
    detail.Image=ui.Clock.Image
    detail.ImageTransparency=0.25
    detail.ZIndex=64
end
ui.Duration=makeText(ui.Time,"Duration","4s",UDim2.fromOffset(40,0),UDim2.fromOffset(128,52),24,primaryTextColor)
ui.Duration.ZIndex=63
registerUI("CraftDuration",ui.Duration,nil,nil,nil,nil,24)

ui.BottomDivider=transparentFrame(craftingBrowser,"ItemStripDivider")
ui.BottomDivider.BackgroundColor3=dividerColor
ui.BottomDivider.BackgroundTransparency=0
ui.BottomDivider.Position=UDim2.fromOffset(0,panelHeight-130)
ui.BottomDivider.Size=UDim2.new(1,0,0,1)
registerUI("ItemStripDivider",ui.BottomDivider)
ui.Choose=makeText(craftingBrowser,"ChooseAnItem","Items",UDim2.new(),UDim2.new(),16,secondaryTextColor)
ui.Choose.Font=headingFont
ui.Choose.TextXAlignment=Enum.TextXAlignment.Center
ui.Choose.ZIndex=63
registerUI("ChooseItemHeading",ui.Choose,24,panelHeight-126,panelWidth-48,22,20)
ui.Names.ChooseItemHeading="Items heading"
local recipeScroll=Instance.new("ScrollingFrame")
recipeScroll.Name="RecipeScroll"
recipeScroll.BackgroundTransparency=1
recipeScroll.BorderSizePixel=0
recipeScroll.CanvasSize=UDim2.fromOffset(0,0)
recipeScroll.ScrollBarThickness=0
recipeScroll.ScrollBarImageTransparency=1
recipeScroll.TopImage=""
recipeScroll.MidImage=""
recipeScroll.BottomImage=""
recipeScroll.HorizontalScrollBarInset=Enum.ScrollBarInset.None
recipeScroll.VerticalScrollBarInset=Enum.ScrollBarInset.None
recipeScroll.ScrollingDirection=Enum.ScrollingDirection.X
recipeScroll.ElasticBehavior=Enum.ElasticBehavior.Never
recipeScroll.ClipsDescendants=true
recipeScroll.Active=true
recipeScroll.ZIndex=60
recipeScroll.Parent=craftingBrowser
local itemStripWidth=1048
registerUI("ItemStrip",recipeScroll,(panelWidth-itemStripWidth)/2,panelHeight-102,itemStripWidth,86)
ui.StripContent=transparentFrame(recipeScroll,"RecipeContent")
ui.StripContent.Size=UDim2.fromScale(1,1)

local arrowWidth=44
local arrowInset=30
local function arrow(name,direction,x)
    local button=Instance.new("TextButton")
    button.Name=name
    button.BackgroundTransparency=1
    button.BorderSizePixel=0
    button.AutoButtonColor=false
    button.Text=""
    button.ZIndex=63
    button.Parent=craftingBrowser
    registerUI(name,button,x,panelHeight-83,arrowWidth,52)
    local glyph=transparentFrame(button,"ArrowIcon")
    glyph.AnchorPoint=Vector2.new(0.5,0.5)
    glyph.Position=UDim2.new(0.5,-direction*8,0.5,0)
    glyph.Size=UDim2.fromOffset(28,32)
    glyph.ZIndex=64
    registerUI(name.."Icon",glyph)
    local strokes={}
    local thickness=3
    for index,sign in ipairs({-1,1}) do
        local line=transparentFrame(glyph,"Chevron")
        line.AnchorPoint=Vector2.new(0.5,0.5)
        line.Position=UDim2.new(0.5,0,0.5,sign*6)
        line.Size=UDim2.fromOffset(math.sqrt(288)+thickness,thickness)
        line.Rotation=-direction*sign*45
        line.BackgroundColor3=primaryTextColor
        line.BackgroundTransparency=0
        line.ZIndex=64
        addCorner(line,thickness)
        local key=name.."Stroke"..index
        registerUI(key,line)
        ui.Names[key]=(direction<0 and "Left arrow" or "Right arrow").." · stroke "..index
        strokes[index]=line
    end
    ui.ArrowStrokes[button]=strokes
    return button
end
ui.Left=arrow("PreviousItems",-1,arrowInset)
ui.Right=arrow("NextItems",1,panelWidth-arrowWidth-arrowInset)
ui.Empty=makeText(ui.DetailMotion,"NoRecipes","No Items",UDim2.fromOffset(150,280),UDim2.fromOffset(800,50),26,secondaryTextColor)
ui.Empty.TextXAlignment=Enum.TextXAlignment.Center
ui.Empty.ZIndex=63
ui.Empty.Visible=false
registerUI("NoRecipesText",ui.Empty,nil,nil,nil,nil,26)
ui.Names.NoRecipesText="No Items text"

do
    local panel=transparentFrame(ui.DetailMotion,"NoMatchesPanel")
    panel.Position=UDim2.fromOffset(0,252)
    panel.Size=UDim2.new(1,0,0,294)
    panel.Visible=false
    ui.SearchEmpty=panel
    registerUI("NoMatchesPanel",panel)
    ui.Names.NoMatchesPanel="No matches panel"

    local icon=makeEmptyIcon(panel,"NoMatchesIcon",UDim2.new(0.5,0,0,31),UDim2.fromOffset(72,72))
    icon.Image=searchIcon.Image
    icon.ImageColor3=Color3.fromRGB(168,168,171)
    icon.ZIndex=63
    registerUI("NoMatchesIcon",icon)
    ui.Names.NoMatchesIcon="No matches icon"

    local title=makeText(panel,"NoMatchesTitle","",UDim2.fromOffset(36,87),UDim2.new(1,-72,0,54),36,primaryTextColor)
    title.Font=Enum.Font.GothamBold
    title.TextXAlignment=Enum.TextXAlignment.Center
    title.TextTruncate=Enum.TextTruncate.AtEnd
    title.ZIndex=63
    ui.NoMatchesTitle=title
    registerUI("NoMatchesTitle",title,nil,nil,nil,nil,36)
    ui.Names.NoMatchesTitle="No matches title"

    local hint=makeText(panel,"NoMatchesHint","Try searching for a different item.",UDim2.fromOffset(36,155),UDim2.new(1,-72,0,40),26,secondaryTextColor)
    hint.TextXAlignment=Enum.TextXAlignment.Center
    hint.ZIndex=63
    registerUI("NoMatchesHint",hint,nil,nil,nil,nil,26)
    ui.Names.NoMatchesHint="No matches hint"

    local clear=Instance.new("TextButton")
    clear.Name="NoMatchesClear"
    clear.AnchorPoint=Vector2.new(0.5,0)
    clear.Position=UDim2.new(0.5,0,0,230)
    clear.Size=UDim2.fromOffset(228,54)
    clear.BackgroundColor3=surfaceColor
    clear.BorderSizePixel=0
    clear.AutoButtonColor=false
    clear.Text="Clear search"
    clear.TextColor3=primaryTextColor
    clear.Font=Enum.Font.GothamMedium
    clear.ZIndex=63
    clear.Parent=panel
    addCorner(clear,8)
    local outlineColor=Color3.fromRGB(168,168,171)
    local pressedOutlineColor=outlineColor:Lerp(primaryTextColor,0.3)
    local outline=addStroke(clear,outlineColor,1.4,0)
    clear:GetPropertyChangedSignal("GuiState"):Connect(function()
        outline.Color=clear.GuiState==Enum.GuiState.Press and pressedOutlineColor or outlineColor
    end)
    ui.NoMatchesClear=clear
    registerUI("NoMatchesClear",clear,nil,nil,nil,nil,23)
    ui.Names.NoMatchesClear="No matches clear search button"
end

ui.Settings.StripIcons={X=0,Y=0,W=96,H=82,Scale=1}
ui.Settings.StripItems={W=96,H=86,Gap=8,Scale=1}
table.insert(ui.Order,"StripIcons")
table.insert(ui.Order,"StripItems")
ui.Settings.RecipePreviewOffsets={}
local tileData={}
for index,recipe in ipairs(recipes) do
    ui.Settings.RecipePreviewOffsets[recipe.Name]={X=0,Y=0}
    local tile=Instance.new("TextButton")
    tile.Name=recipe.Name:gsub("%s","")
    tile.BackgroundTransparency=1
    tile.BorderSizePixel=0
    tile.AutoButtonColor=false
    tile.Text=""
    tile.ZIndex=61
    tile.Parent=ui.StripContent
    local icon=makeEmptyIcon(tile,"RecipeIcon",UDim2.new(),UDim2.new())
    icon.AnchorPoint=Vector2.new(0,0)
    icon.Image=recipe.NameOnly and "" or findItemImage(recipe.Name)
    icon.ZIndex=63
    local nameText,nameScale
    if recipe.NameOnly then
        nameText=makeText(icon,"RecipeIconName",recipe.Name,UDim2.new(),UDim2.fromScale(1,1),18,secondaryTextColor)
        nameText.Font=Enum.Font.GothamMedium
        nameText.TextXAlignment=Enum.TextXAlignment.Center
        nameText.TextWrapped=true
        nameText.ZIndex=63
        nameScale=Instance.new("UIScale")
        nameScale.Parent=nameText
    end
    local underline=transparentFrame(tile,"SelectedUnderline")
    underline.Position=UDim2.new(0.18,0,1,-3)
    underline.Size=UDim2.new(0.64,0,0,3)
    underline.BackgroundColor3=selectedColor
    underline.BackgroundTransparency=1
    underline.ZIndex=64
    local slotKey="PickerSlot_"..tile.Name
    local iconKey="PickerIcon_"..tile.Name
    local underlineKey="PickerUnderline_"..tile.Name
    registerDynamicUI(slotKey,tile,recipe.Name.." · picker slot")
    registerDynamicUI(iconKey,icon,recipe.Name.." · picker icon")
    registerUI(underlineKey,underline)
    ui.Names[underlineKey]=recipe.Name.." · picker underline"
    tileData[index]={Index=index,Button=tile,Recipe=recipe,Icon=icon,NameText=nameText,NameScale=nameScale,Underline=underline,SlotKey=slotKey,IconKey=iconKey,UnderlineKey=underlineKey}
end
local oldProgressGui=playerGui:FindFirstChild("CraftingProgressTest")
if oldProgressGui then
oldProgressGui:Destroy()
end
local progressGui=Instance.new("ScreenGui")
progressGui.Name="CraftingProgressTest"
progressGui.IgnoreGuiInset=true
progressGui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets
progressGui.ResetOnSpawn=false
progressGui.DisplayOrder=gui.DisplayOrder
progressGui.ZIndexBehavior=gui.ZIndexBehavior
progressGui.Parent=playerGui

local craftingProgress=Instance.new("Frame")
craftingProgress.Name="CraftingProgress"
craftingProgress.BackgroundTransparency=1
craftingProgress.BorderSizePixel=0
craftingProgress.AnchorPoint=Vector2.new(1,0)
craftingProgress.Position=UDim2.new(1,14,0.2,-72)
craftingProgress.Size=UDim2.fromOffset(180,41)
craftingProgress.Visible=false
craftingProgress.ZIndex=200
craftingProgress.Parent=progressGui

local progressContent=Instance.new("Frame")
progressContent.Name="Content"
progressContent.BackgroundTransparency=1
progressContent.BorderSizePixel=0
progressContent.Size=UDim2.fromOffset(220,50)
progressContent.ZIndex=201
progressContent.Parent=craftingProgress

local progressContentScale=Instance.new("UIScale")
progressContentScale.Parent=progressContent

local progressTitle=Instance.new("TextLabel")
progressTitle.Name="Title"
progressTitle.BackgroundTransparency=1
progressTitle.Position=UDim2.fromOffset(0,0)
progressTitle.Size=UDim2.fromOffset(160,16)
progressTitle.Font=Enum.Font.GothamBold
progressTitle.Text=""
progressTitle.TextColor3=Color3.fromRGB(255,255,255)
progressTitle.TextTransparency=1
progressTitle.TextSize=15
progressTitle.TextTruncate=Enum.TextTruncate.None
progressTitle.TextXAlignment=Enum.TextXAlignment.Left
progressTitle.ZIndex=202
progressTitle.Parent=progressContent

local progressAmount=Instance.new("TextLabel")
progressAmount.Name="Amount"
progressAmount.BackgroundTransparency=1
progressAmount.AnchorPoint=Vector2.new(1,0)
progressAmount.Position=UDim2.fromOffset(176,1)
progressAmount.Size=UDim2.fromOffset(52,16)
progressAmount.Font=Enum.Font.GothamBold
progressAmount.Text="x1"
progressAmount.TextColor3=Color3.fromRGB(255,255,255)
progressAmount.TextTransparency=1
progressAmount.TextSize=15
progressAmount.TextXAlignment=Enum.TextXAlignment.Right
progressAmount.ZIndex=202
progressAmount.Parent=progressContent

local progressBarBack=Instance.new("Frame")
progressBarBack.Name="ProgressBar"
progressBarBack.BorderSizePixel=0
progressBarBack.BackgroundColor3=Color3.fromRGB(255,255,255)
progressBarBack.BackgroundTransparency=1
progressBarBack.Position=UDim2.fromOffset(0,20)
progressBarBack.Size=UDim2.fromOffset(176,4)
progressBarBack.ClipsDescendants=true
progressBarBack.ZIndex=202
progressBarBack.Parent=progressContent

local progressBarCorner=Instance.new("UICorner")
progressBarCorner.CornerRadius=UDim.new(1,0)
progressBarCorner.Parent=progressBarBack

local progressBarFill=Instance.new("Frame")
progressBarFill.Name="Fill"
progressBarFill.BorderSizePixel=0
progressBarFill.BackgroundColor3=Color3.fromRGB(255,255,255)
progressBarFill.BackgroundTransparency=0
progressBarFill.Size=UDim2.fromScale(0,1)
progressBarFill.ZIndex=203
progressBarFill.Parent=progressBarBack

local progressFillCorner=Instance.new("UICorner")
progressFillCorner.CornerRadius=UDim.new(1,0)
progressFillCorner.Parent=progressBarFill

local progressDescription=Instance.new("TextLabel")
progressDescription.Name="Description"
progressDescription.BackgroundTransparency=1
progressDescription.Position=UDim2.fromOffset(0,28)
progressDescription.Size=UDim2.fromOffset(216,14)
progressDescription.Font=Enum.Font.GothamMedium
progressDescription.Text="Crafting item..."
progressDescription.TextColor3=Color3.fromRGB(210,210,210)
progressDescription.TextTransparency=1
progressDescription.TextSize=12
progressDescription.TextXAlignment=Enum.TextXAlignment.Left
progressDescription.ZIndex=202
progressDescription.Parent=progressContent

updateCraftingProgressScale=function(viewport)
local shortSide=math.min(viewport.X,viewport.Y)
local responsiveScale
if shortSide<=430 then
responsiveScale=0.82
elseif shortSide<=600 then
responsiveScale=0.9
elseif shortSide<=800 then
responsiveScale=0.98
else
responsiveScale=1.06
end
local finalScale=responsiveScale*1.02
progressContentScale.Scale=finalScale
craftingProgress.Size=UDim2.fromOffset(180*finalScale,41*finalScale)
end
if workspace.CurrentCamera then
updateCraftingProgressScale(workspace.CurrentCamera.ViewportSize)
end

local progressRunId=0
local progressTweens={}
local progressPosition=UDim2.new(1,-7,0.2,-72)
local progressOffPosition=UDim2.new(1,14,0.2,-72)
local craftDuration=4

local function cancelCraftingProgress()
progressRunId+=1
for _,tween in ipairs(progressTweens) do
tween:Cancel()
end
table.clear(progressTweens)
craftingProgress.Visible=false
end

local function playProgressTween(object,duration,style,direction,properties)
local tween=TweenService:Create(object,TweenInfo.new(duration,style,direction),properties)
table.insert(progressTweens,tween)
tween:Play()
return tween
end

local function showCraftingProgress(recipe,amount,onComplete)
cancelCraftingProgress()
local runId=progressRunId
amount=math.max(1,math.floor(tonumber(amount) or 1))
local duration=math.max(0.05,tonumber(recipe.CraftTime) or craftDuration)*amount
progressTitle.Text="Crafting "..recipe.Name
progressAmount.Text="x"..tostring(amount)
local amountBounds=TextService:GetTextSize(progressAmount.Text,15,progressAmount.Font,Vector2.new(10000,16))
progressTitle.Size=UDim2.fromOffset(math.min(160,176-amountBounds.X-8),16)
fitTextSize(progressTitle,progressTitle.Text,15,10)
progressTitle.TextTransparency=1
progressAmount.TextTransparency=1
progressDescription.TextTransparency=1
progressBarBack.BackgroundTransparency=1
progressBarFill.BackgroundTransparency=0
progressBarFill.Size=UDim2.fromScale(0,1)
craftingProgress.Position=progressOffPosition
craftingProgress.Visible=true

playProgressTween(craftingProgress,0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,{Position=progressPosition})
playProgressTween(progressTitle,0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{TextTransparency=0})
playProgressTween(progressAmount,0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{TextTransparency=0})
playProgressTween(progressDescription,0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{TextTransparency=0})
playProgressTween(progressBarBack,0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{BackgroundTransparency=0.8})
local fillTween=playProgressTween(progressBarFill,duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,{Size=UDim2.fromScale(1,1)})
fillTween.Completed:Once(function(state)
if state~=Enum.PlaybackState.Completed or runId~=progressRunId or not craftingProgress.Parent then
return
end
craftCompleteSound:Play()
task.delay(0.65,function()
if runId~=progressRunId or not craftingProgress.Parent then
return
end
local outTween=playProgressTween(craftingProgress,0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.In,{Position=progressOffPosition})
playProgressTween(progressTitle,0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In,{TextTransparency=1})
playProgressTween(progressAmount,0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In,{TextTransparency=1})
playProgressTween(progressDescription,0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In,{TextTransparency=1})
playProgressTween(progressBarBack,0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In,{BackgroundTransparency=1})
playProgressTween(progressBarFill,0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In,{BackgroundTransparency=1})
outTween.Completed:Once(function(outState)
if outState~=Enum.PlaybackState.Completed or runId~=progressRunId or not craftingProgress.Parent then
return
end
craftingProgress.Visible=false
table.clear(progressTweens)
if onComplete then
onComplete()
end
end)
end)
end)
end

local craftingFadeDriver
local craftingFadeEntries={}
local craftingFadeLookup={}
local applyCraftingFade

local function renderCraftingFadeEntry(entry)
local alpha=craftingFadeDriver and craftingFadeDriver.Value or 0
local rendered=1-(1-entry.Base)*(1-alpha)
if entry.Object[entry.Property]~=rendered then
entry.Object[entry.Property]=rendered
end
end

local function setCraftingVisualProperty(object,property,value)
local properties=craftingFadeLookup[object]
local entry=properties and properties[property]
if not entry then
object[property]=value
return
end
if entry.Tween then
entry.Tween:Cancel()
entry.Tween=nil
end
entry.Base=value
if entry.Driver then
entry.Driver.Value=value
end
renderCraftingFadeEntry(entry)
end

local function createCraftingVisualTween(object,info,properties)
local visualProperties=craftingFadeLookup[object]
local directProperties={}
local tweens={}
for property,value in pairs(properties) do
local entry=visualProperties and visualProperties[property]
if entry then
if entry.Tween then
entry.Tween:Cancel()
end
if not entry.Driver then
local driver=Instance.new("NumberValue")
driver.Name="Crafting"..property.."Driver"
driver.Value=entry.Base
driver.Parent=gui
entry.Driver=driver
entry.Connection=driver:GetPropertyChangedSignal("Value"):Connect(function()
entry.Base=driver.Value
renderCraftingFadeEntry(entry)
end)
end
local tween=TweenService:Create(entry.Driver,info,{Value=value})
entry.Tween=tween
table.insert(tweens,tween)
else
directProperties[property]=value
end
end
if next(directProperties) then
table.insert(tweens,TweenService:Create(object,info,directProperties))
end
local combined={}
function combined:Play()
for _,tween in ipairs(tweens) do
tween:Play()
end
end
function combined:Cancel()
for _,tween in ipairs(tweens) do
tween:Cancel()
end
end
return combined
end


do
    local craftingUISettings={
        CategoryUnderline={X=0,Scale=1.15},
        ChooseItemHeading={Y=panelHeight-125.8,TextSize=23},
        ClockIcon={X=2,Y=9,Scale=1.51},
        CraftButton={X=110,Y=0,W=420,H=56,Scale=1},
        CraftControls={X=580,Y=557,W=530,H=56},
        CraftDuration={X=56,Y=1.2,W=55,H=56,TextSize=27},
        CraftLabel={X=0,Y=0,W=420,H=56,Scale=1},
        CraftTime={X=0,Y=0,W=100,H=56,Scale=1},
        HeaderIcon={Scale=1.08},
        HeaderTitle={TextSize=35},
        ItemName={X=-19,Y=199,W=480,TextSize=40},
        ItemPreview={X=80,Y=245,W=400,H=240,Scale=1},
        ItemIcon={X=-25,Y=-12,W=400,H=240,Scale=1.36},
        ItemStrip={X=100,Y=667,Scale=1.16},
        ItemSubtitle={X=-30,Y=573,W=480,H=56,TextSize=26},
        ItemType={X=-18.7,Y=171,TextSize=27},
        MaterialsHeading={X=659,Y=154,W=480,H=30,TextSize=25},
        NextItems={Y=panelHeight-94},
        NextItemsStroke1={W=19},
        NextItemsStroke2={W=19},
        NoMatchesClear={Y=306,Scale=1.32,TextSize=26},
        NoMatchesHint={X=35,Y=211,TextSize=32},
        NoMatchesIcon={Scale=3},
        NoMatchesTitle={Y=149,TextSize=55},
        NoRecipesText={X=95,Y=315,Scale=1.1,TextSize=46},
        OpenCraftingIcon={X=1},
        PreviousItems={Y=panelHeight-94},
        PreviousItemsStroke1={W=19},
        PreviousItemsStroke2={W=19},
        QuantityControls={X=-122,Scale=1.11},
        SearchIcon={Y=20,Scale=1.67},
        SearchResults={X=-22,Y=49,Scale=1.05},
        SearchText={X=50,Y=-2,Scale=1.05},
        TabTools={Scale=1.05},
        TabArmor={Scale=1.05},
        TabResources={Scale=1.05},
        TabGeneral={Scale=1.05},
    }
    for name,settings in pairs(craftingUISettings) do
        local layout=ui.Settings[name]
        if layout then
            for key,value in pairs(settings) do
                layout[key]=value
            end
        end
    end
end

local selectedRecipe=2
local selectedCategory="Tools"
local updateDetailsContent
local selectRecipe
local ingredientLayouts={}
local ingredientPositions={
    {{749,289}},
    {{764,209},{764,379}},
    {{653.5,214},{913.5,214},{778.5,384}},
    {{653.5,214},{913.5,214},{653.5,384},{913.5,384}},
    {{648.1,204},{908.1,204},{648.1,318},{908.1,318},{778.1,432}},
    {{648.1,204},{908.1,204},{648.1,318},{908.1,318},{648.1,432},{908.1,432}},
}
for count,positions in ipairs(ingredientPositions) do
    local rows={}
    local width,scale=190,1.25
    if count==1 then
        width,scale=220,1.35
    elseif count==2 then
        width,scale=220,1.25
    elseif count>=5 then
        width,scale=208,1.15
    end
    local dense=count>=5
    local iconHeight=dense and 64 or 80
    local textY=dense and 66 or 82
    for index,position in ipairs(positions) do
        rows[index]={
            X=position[1],Y=position[2],W=width,H=textY+28,Scale=scale,AutoText=true,
            Icon={X=(width-124)/2,Y=0,W=124,H=iconHeight,Scale=1},
            Required={X=0,Y=textY,W=0,H=28,TextSize=24,Scale=1},
            Name={X=0,Y=textY,W=0,H=28,TextSize=24,Scale=1},
            Amount={X=0,Y=textY,W=0,H=28,TextSize=24,Scale=1},
        }
    end
    ingredientLayouts[count]=rows
end

local function updateCategoryUnderline(animated)
    local button=categoryButtons[selectedCategory].Button
    local layout=ui.Settings["Tab"..selectedCategory]
    local underline=ui.Settings.CategoryUnderline
    local textWidth=button.TextBounds.X/uiScaleFor(ui.Tabs)
    if textWidth<=0 then
        textWidth=TextService:GetTextSize(button.Text,button.TextSize,button.Font,Vector2.new(10000,1000)).X*uiScaleFor(button)/uiScaleFor(ui.Tabs)
    end
    local center=layout.X+layout.W*layout.Scale/2
    local width=textWidth/underline.Scale
    local thickness=3*layout.Scale
    local visibleWidth=math.max(0.1,width+underline.W)*underline.Scale
    local visibleHeight=math.max(0.1,thickness+underline.H)*underline.Scale
    local position,size=dynamicGeometry(
        "CategoryUnderline",
        center-visibleWidth/2,
        layout.Y+layout.H*layout.Scale-visibleHeight,
        width,
        thickness
    )
    if ui.CategoryUnderlineTween then
        ui.CategoryUnderlineTween:Cancel()
        ui.CategoryUnderlineTween=nil
    end
    setCraftingVisualProperty(ui.CategoryUnderline,"BackgroundTransparency",0)
    if animated then
        local tween=TweenService:Create(ui.CategoryUnderline,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=position,Size=size})
        ui.CategoryUnderlineTween=tween
        tween.Completed:Once(function()
            if ui.CategoryUnderlineTween==tween then ui.CategoryUnderlineTween=nil end
        end)
        tween:Play()
    else
        ui.CategoryUnderline.Position=position
        ui.CategoryUnderline.Size=size
    end
end
local function setCategoryVisual(animated)
    for name,data in pairs(categoryButtons) do
        local selected=name==selectedCategory
        local color=selected and primaryTextColor or Color3.fromRGB(194,195,199)
        if animated then
            createCraftingVisualTween(data.Button,TweenInfo.new(0.1),{TextColor3=color}):Play()
        else
            data.Button.TextColor3=color
        end
    end
    updateCategoryUnderline(animated)
end
local function updateSelectionOutline(previousIndex)
    local target=selectedRecipe and tileData[selectedRecipe]
    local previous=previousIndex and tileData[previousIndex]
    local startPosition,startSize
    if previous and target and previous.Button.Visible and target.Button.Visible then
        local line=previous.Underline
        local position,size=line.AbsolutePosition,line.AbsoluteSize
        if size.X>0 and size.Y>0 then
            local parent=target.Button
            local origin=parent.AbsolutePosition
            local scale=uiScaleFor(parent)
            local lineScale=uiScaleFor(target.Underline)
            local anchor=target.Underline.AnchorPoint
            startPosition=layoutVector(parent,(position.X-origin.X+size.X*anchor.X)/scale,(position.Y-origin.Y+size.Y*anchor.Y)/scale)
            startSize=layoutVector(parent,size.X/lineScale,size.Y/lineScale)
        end
    end

    if ui.ItemUnderlineTween then
        ui.ItemUnderlineTween:Cancel()
        ui.ItemUnderlineTween=nil
    end
    for index,data in ipairs(tileData) do
        setCraftingVisualProperty(data.Underline,"BackgroundTransparency",index==selectedRecipe and 0 or 1)
    end
    if not target then return end

    local line=target.Underline
    local layout=ui.Settings[target.UnderlineKey]
    local position=layoutVector(target.Button,layout.X,layout.Y,layout.XScale,layout.YScale)
    local size=layoutVector(target.Button,layout.W,layout.H,layout.WScale,layout.HScale)
    if startPosition then
        line.Position=startPosition
        line.Size=startSize
        local tween=TweenService:Create(line,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=position,Size=size})
        ui.ItemUnderlineTween=tween
        tween.Completed:Once(function()
            if ui.ItemUnderlineTween==tween then ui.ItemUnderlineTween=nil end
        end)
        tween:Play()
    else
        line.Position=position
        line.Size=size
    end
end
local function updateCraftButtonState(canCraft)
    craftButton:SetAttribute("HasMaterials",canCraft)
    craftButton.BackgroundColor3=selectedColor
    craftText.Text="CRAFT"
    craftText.TextColor3=darkTextColor
    craftButton.Active=selectedRecipe~=nil
end
local function setDetailsAlpha(alpha)
    setCraftingVisualProperty(previewIcon,"ImageTransparency",alpha)
    setCraftingVisualProperty(ui.PreviewName,"TextTransparency",alpha)
    setCraftingVisualProperty(detailName,"TextTransparency",alpha)
    setCraftingVisualProperty(detailType,"TextTransparency",alpha)
    setCraftingVisualProperty(detailDescription,"TextTransparency",alpha)
    setCraftingVisualProperty(materialsHeader,"TextTransparency",alpha)
    setCraftingVisualProperty(ui.Empty,"TextTransparency",alpha)
    for _,parts in ipairs(materialParts) do
        setCraftingVisualProperty(parts.Icon,"ImageTransparency",alpha)
        for _,key in ipairs(materialTextKeys) do
            setCraftingVisualProperty(parts[key],"TextTransparency",alpha)
        end
    end
end
local materialMeasureBounds=Vector2.new(10000,1000)
local function measureMaterialText(parts,layout,fit)
    local widths,sizes={},{}
    local total=0
    local scale=uiScaleFor(parts.Name.Parent)
    for index,key in ipairs(materialTextKeys) do
        local label,config=parts[key],layout[key]
        local size=math.max(1,math.round(config.TextSize*config.Scale*scale))
        if fit<1 then size=math.max(1,math.floor(size*fit)) end
        size=math.clamp(size,1,math.max(1,math.min(100,math.round(config.H*config.Scale*scale))))
        local width=TextService:GetTextSize(label.Text,size,label.Font,materialMeasureBounds).X
        widths[index],sizes[index]=width,size
        total+=width+(materialTextGaps[index]>0 and math.max(2,math.round(materialTextGaps[index]*scale)) or 0)
    end
    return widths,total,sizes
end
local displayedMaterials={}
local function showMaterials(materials)
    displayedMaterials=materials
    local config=ingredientLayouts[#materials]
    local widths,totals,sizes={},{},{}
    local fit=1
    for index=1,6 do
        local item=materials[index]
        local frame=materialFrames[index]
        frame.Visible=item~=nil
        if item and config then
            local v=config[index]
            local parts=materialParts[index]
            frame.Position=layoutVector(frame.Parent,v.X,v.Y)
            frame.Size=layoutVector(frame.Parent,v.W,v.H)
            materialRowScales[index].Scale=v.Scale
            local icon=parts.Icon
            icon.AnchorPoint=Vector2.new(0,0)
            icon.Position=layoutVector(frame,v.Icon.X,v.Icon.Y)
            icon.Size=layoutVector(frame,v.Icon.W,v.Icon.H)
            materialPartScales[index].Icon.Scale=v.Icon.Scale
            icon.Image=item.Image
            parts.Required.Text=tostring(item.Required)
            parts.Name.Text=tostring(item.Name)
            parts.Amount.Text="("..tostring(item.Owned)..")"
            widths[index],totals[index],sizes[index]=measureMaterialText(parts,v,1)
            if v.AutoText then
                local scale=uiScaleFor(frame)
                local gaps=math.max(2,math.round(materialTextGaps[1]*scale))+math.max(2,math.round(materialTextGaps[2]*scale))
                local textWidth=math.max(1,totals[index]-gaps)
                fit=math.min(fit,math.max(1,(v.W-8)*scale-gaps)/textWidth)
            end
        end
    end
    if not config then return end
    for index,v in ipairs(config) do
        local frame,parts=materialFrames[index],materialParts[index]
        if v.AutoText and fit<1 then
            widths[index],totals[index],sizes[index]=measureMaterialText(parts,v,fit)
        end
        local scale=uiScaleFor(frame)
        local cursor=(frame.AbsoluteSize.X-totals[index])/2
        for partIndex,key in ipairs(materialTextKeys) do
            local label,t=parts[key],v[key]
            local x,y,width=t.X,t.Y,t.W
            if v.AutoText then
                local measuredWidth=widths[index][partIndex]
                x+=cursor/scale
                width+=(measuredWidth+2)/(scale*t.Scale)
                cursor+=measuredWidth+(materialTextGaps[partIndex]>0 and math.max(2,math.round(materialTextGaps[partIndex]*scale)) or 0)
            end
            renderText(label,materialPartScales[index][key],{X=x,Y=y,W=math.max(0.1,width),H=t.H,Scale=t.Scale,TextSize=t.TextSize},sizes[index][partIndex])
        end
    end
end
ui.DetailDriver=Instance.new("NumberValue")
ui.DetailDriver.Name="RecipeSlideDriver"
ui.DetailDriver.Parent=gui
ui.StripDriver=Instance.new("NumberValue")
ui.StripDriver.Name="RecipeStripSlideDriver"
ui.StripDriver.Parent=gui
ui.DetailConnection=ui.DetailDriver:GetPropertyChangedSignal("Value"):Connect(function()
    local alpha=ui.DetailDriver.Value
    ui.DetailMotion.Position=UDim2.fromOffset(ui.DetailDirection*26*alpha,0)
    setDetailsAlpha(alpha)
end)
local function setStripAlpha(alpha)
    for index,data in ipairs(tileData) do
        setCraftingVisualProperty(data.Icon,"ImageTransparency",alpha)
        if data.NameText then setCraftingVisualProperty(data.NameText,"TextTransparency",alpha) end
        setCraftingVisualProperty(data.Underline,"BackgroundTransparency",index==selectedRecipe and alpha or 1)
    end
end
ui.StripConnection=ui.StripDriver:GetPropertyChangedSignal("Value"):Connect(function()
    local alpha=ui.StripDriver.Value
    ui.StripContent.Position=UDim2.fromOffset(ui.StripDirection*34*alpha,0)
    setStripAlpha(alpha)
end)
local function cancelDetailSlide()
    local tween=ui.DetailTween
    ui.DetailTween=nil
    if tween then tween:Cancel() end
    ui.DetailDriver.Value=0
    ui.DetailMotion.Position=UDim2.fromOffset(0,0)
    setDetailsAlpha(0)
end
local function cancelStripSlide()
    local tween=ui.StripTween
    ui.StripTween=nil
    if tween then tween:Cancel() end
    ui.StripDriver.Value=0
    ui.StripContent.Position=UDim2.fromOffset(0,0)
    setStripAlpha(0)
end
local function playStripSlide(direction)
    ui.StripDirection=direction
    ui.StripDriver.Value=1
    local tween=TweenService:Create(ui.StripDriver,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Value=0})
    ui.StripTween=tween
    tween.Completed:Once(function()
        if ui.StripTween==tween then ui.StripTween=nil end
    end)
    tween:Play()
end
local function stripMetrics()
    local scale=uiScaleFor(recipeScroll)
    local maximum=math.max(0,(recipeScroll.CanvasSize.X.Offset-recipeScroll.Size.X.Offset)*scale)
    return maximum,scale
end
local disabledArrowColor=surfaceColor:Lerp(primaryTextColor,0.35)
local function updateStripArrows()
    local maximum=stripMetrics()
    local position=ui.ScrollTarget or recipeScroll.CanvasPosition.X
    for _,entry in ipairs({{ui.Left,position>0.5},{ui.Right,position<maximum-0.5}}) do
        entry[1].Active=entry[2]
        for _,line in ipairs(ui.ArrowStrokes[entry[1]]) do
            line.BackgroundColor3=entry[2] and primaryTextColor or disabledArrowColor
        end
    end
end
local function cancelStripScroll()
    local tween=ui.ScrollTween
    ui.ScrollTween=nil
    ui.ScrollTarget=nil
    if tween then tween:Cancel() end
    updateStripArrows()
end
ui.CancelNavigation=function()
    cancelDetailSlide()
    cancelStripSlide()
    cancelStripScroll()
    setCategoryVisual(false)
    updateSelectionOutline()
end
local function positionStrip()
    local tile=ui.Settings.StripItems
    local icon=ui.Settings.StripIcons
    local strip=ui.Settings.ItemStrip
    local browser=ui.Settings.RecipeBrowser
    local w,h=tile.W*tile.Scale,tile.H*tile.Scale
    local gap=(tile.Gap or 14)*tile.Scale
    local step=w+gap
    local content=math.max(0,#ui.Filtered*step-gap)
    local panelRight=(ui.Settings.Menu.W-browser.X)/browser.Scale
    local stripRight=math.min(panelRight,ui.Settings.NextItems.X)
    local viewportWidth=math.max(1,math.floor(math.min(strip.W,(stripRight-strip.X)/strip.Scale)))
    local fullSlots=math.floor((viewportWidth+gap)/step)
    if fullSlots>0 and fullSlots<#tileData then
        viewportWidth=math.ceil(fullSlots*step-gap)
    end
    recipeScroll.Size=layoutVector(recipeScroll.Parent,viewportWidth,strip.H,nil,strip.HScale)
    local start=math.max(0,(viewportWidth-content)/2)
    local canvasWidth=math.max(viewportWidth,content)
    local iconX,iconY=icon.X*tile.Scale,icon.Y*tile.Scale
    local iconW,iconH=icon.W*icon.Scale*tile.Scale,icon.H*icon.Scale*tile.Scale
    for visibleIndex,index in ipairs(ui.Filtered) do
        local data=tileData[index]
        local x=start+(visibleIndex-1)*step
        local slotLayout=ui.Settings[data.SlotKey]
        local iconLayout=ui.Settings[data.IconKey]
        local iconRight=iconX+iconLayout.X+math.max(0.1,iconW+iconLayout.W)*iconLayout.Scale
        local right=x+slotLayout.X+math.max(w+slotLayout.W,iconRight)*slotLayout.Scale
        canvasWidth=math.max(canvasWidth,right)
    end
    canvasWidth=math.ceil(canvasWidth)
    ui.StripContent.Size=UDim2.fromOffset(canvasWidth,math.ceil(h))
    recipeScroll.CanvasSize=UDim2.fromOffset(canvasWidth,math.ceil(h))
    for visibleIndex,index in ipairs(ui.Filtered) do
        local data=tileData[index]
        data.Button.Position,data.Button.Size=dynamicGeometry(data.SlotKey,start+(visibleIndex-1)*step,0,w,h)
    end
    for _,data in ipairs(tileData) do
        data.Icon.Position,data.Icon.Size=dynamicGeometry(data.IconKey,iconX,iconY,iconW,iconH)
        if data.NameText then renderText(data.NameText,data.NameScale,ui.IconNameLayouts.Picker) end
    end
    local maximum=stripMetrics()
    recipeScroll.CanvasPosition=Vector2.new(math.clamp(recipeScroll.CanvasPosition.X,0,maximum),0)
    updateStripArrows()
    updateSelectionOutline()
end
local function positionPreviewIcon()
    local layout=ui.Settings.ItemIcon
    local recipe=selectedRecipe and recipes[selectedRecipe]
    local offset=recipe and ui.Settings.RecipePreviewOffsets[recipe.Name]
    local x=layout.X+(offset and offset.X or 0)
    local y=layout.Y+(offset and offset.Y or 0)
    previewIcon.Position=layoutVector(previewFrame,x,y,layout.XScale,layout.YScale)
    renderText(ui.PreviewName,ui.PreviewNameScale,ui.IconNameLayouts.Preview)
end
local function refreshTextRendering()
    for _,key in ipairs(ui.Order) do
        local object,layout=ui.Objects[key],ui.Settings[key]
        if object and layout.TextSize then
            renderText(object,ui.Scales[key],layout)
        end
    end
    renderText(ui.PreviewName,ui.PreviewNameScale,ui.IconNameLayouts.Preview)
end
refreshViewportLayout=function()
    cancelStripScroll()
    positionStrip()
    positionPreviewIcon()
    showMaterials(displayedMaterials)
    refreshTextRendering()
end
local function applyUILayout()
    cancelStripSlide()
    cancelStripScroll()
    for _,key in ipairs(ui.Order) do
        local object=ui.Objects[key]
        if object then
            local v=ui.Settings[key]
            ui.Scales[key].Scale=v.Scale
            if not ui.Dynamic[key] then
                if key~="ItemIcon" then
                    object.Position=layoutVector(object.Parent,v.X,v.Y,v.XScale,v.YScale)
                end
                if key~="ItemStrip" then
                    object.Size=layoutVector(object.Parent,v.W,v.H,v.WScale,v.HScale)
                end
            end
            if v.Rotation then object.Rotation=v.Rotation end
            if v.TextSize then object.TextSize=v.TextSize end
        end
    end
    setCategoryVisual(false)
    positionStrip()
    positionPreviewIcon()
    refreshTextRendering()
end
updateDetailsContent=function()
    local data=selectedRecipe and tileData[selectedRecipe]
    positionPreviewIcon()
    ui.Empty.Visible=data==nil and not ui.SearchEmpty.Visible
    ui.Actions.Visible=data~=nil
    materialsHeader.Visible=data~=nil
    detailType.Visible=data~=nil
    if not data then
        previewIcon.Image=""
        ui.PreviewName.Visible=false
        detailName.Text=""
        detailDescription.Text=""
        refreshTextRendering()
        showMaterials({})
        updateCraftButtonState(false)
        return
    end
    local recipe=data.Recipe
    materialsHeader.Visible=#recipe.Materials>0
    local materials={}
    local enough=true
    for index,material in ipairs(recipe.Materials) do
        if index>6 then break end
        local required=material[2]*ui.Quantity
        local owned=getOwnedAmount(material[1])
        if owned<required then enough=false end
        materials[index]={Name=material[1],Required=required,Owned=owned,Image=findItemImage(material[1]),Enough=owned>=required}
    end
    previewIcon.Image=recipe.NameOnly and "" or findItemImage(recipe.Name)
    ui.PreviewName.Text=recipe.Name
    ui.PreviewName.Visible=recipe.NameOnly==true
    detailName.Text=string.upper(recipe.Name)
    detailType.Text=string.upper(recipe.Tag or recipe.Category)
    detailDescription.Text=recipe.Description or ""
    ui.QuantityBox.Text=tostring(ui.Quantity)
    ui.Duration.Text=tostring((tonumber(recipe.CraftTime) or craftDuration)*ui.Quantity).."s"
    refreshTextRendering()
    showMaterials(materials)
    updateCraftButtonState(enough)
end
selectRecipe=function(index,animated)
    if not index or not tileData[index] then return end
    local previous=selectedRecipe
    local changed=previous~=index
    cancelDetailSlide()
    cancelStripSlide()
    if changed then ui.Quantity=1 end
    selectedRecipe=index
    if changed or not animated then
        updateSelectionOutline(animated and previous or nil)
    end
    updateDetailsContent()
    if applyCraftingFade then applyCraftingFade() end
end
local function layoutFilteredTiles(animated,direction,restore)
    local search=string.lower(ui.SearchQuery)
    cancelStripSlide()
    cancelStripScroll()
    if restore then
        selectedCategory=restore.Category
        selectedRecipe=restore.Recipe
        ui.Quantity=restore.Quantity
        setCategoryVisual(false)
    end
    ui.Filtered={}
    local selectedVisible=false
    recipeScroll:ResetScrollVelocity()
    recipeScroll.CanvasPosition=Vector2.new(0,0)
    for index,data in ipairs(tileData) do
        local categoryMatch=data.Recipe.Category==selectedCategory
        local searchMatch=search=="" or string.find(string.lower(data.Recipe.Name),search,1,true)~=nil
        data.Button.Visible=categoryMatch and searchMatch
        if data.Button.Visible then
            table.insert(ui.Filtered,index)
            if index==selectedRecipe then selectedVisible=true end
        end
    end
    local noMatches=search~="" and #ui.Filtered==0
    ui.SearchEmpty.Visible=noMatches
    if noMatches then
        ui.NoMatchesTitle.Text="No matches for “"..ui.SearchQuery.."”"
    end
    ui.BottomDivider.Visible=not noMatches
    ui.Choose.Visible=not noMatches
    recipeScroll.Visible=not noMatches
    ui.Left.Visible=not noMatches
    ui.Right.Visible=not noMatches
    ui.Results.Text=search~="" and not noMatches and (tostring(#ui.Filtered)..(#ui.Filtered==1 and " result" or " results")) or ""
    positionStrip()
    if restore then
        local maximum,scale=stripMetrics()
        recipeScroll.CanvasPosition=Vector2.new(math.clamp(restore.Scroll*scale,0,maximum),0)
        updateStripArrows()
    end
    if #ui.Filtered==0 then
        cancelDetailSlide()
        selectedRecipe=nil
        updateSelectionOutline()
        updateDetailsContent()
    elseif not selectedVisible then
        selectRecipe(ui.Filtered[1],false)
    elseif restore then
        updateDetailsContent()
    end
    if animated then
        playStripSlide(direction or 1)
    else
        setStripAlpha(0)
    end
end
for index,data in ipairs(tileData) do
    data.Button.Activated:Connect(function() selectRecipe(index,true) end)
end
for name,data in pairs(categoryButtons) do
    data.Button:GetPropertyChangedSignal("TextBounds"):Connect(function()
        if selectedCategory==name and ui.CategoryUnderline.Parent then
            updateCategoryUnderline(ui.CategoryUnderlineTween~=nil)
        end
    end)
    data.Button.Activated:Connect(function()
        if selectedCategory==name then return end
        local oldOrder,newOrder=1,1
        for order,category in ipairs(categoryNames) do
            if category==selectedCategory then oldOrder=order end
            if category==name then newOrder=order end
        end
        selectedCategory=name
        setCategoryVisual(true)
        layoutFilteredTiles(true,newOrder>oldOrder and 1 or -1)
    end)
end
recipeSearch:GetPropertyChangedSignal("Text"):Connect(function()
    local query=recipeSearch.Text:match("^%s*(.-)%s*$")
    ui.SearchClear.Visible=recipeSearch.Text~=""
    if query==ui.SearchQuery then return end

    local restore
    if ui.SearchQuery=="" then
        ui.SearchReturn={
            Category=selectedCategory,
            Recipe=selectedRecipe,
            Quantity=ui.Quantity,
            Scroll=recipeScroll.CanvasPosition.X/uiScaleFor(recipeScroll),
        }
    elseif query=="" then
        restore=ui.SearchReturn
        ui.SearchReturn=nil
    end
    ui.SearchQuery=query
    layoutFilteredTiles(false,nil,restore)
end)
local function clearRecipeSearch()
    recipeSearch:ReleaseFocus()
    recipeSearch.Text=""
end
ui.SearchClear.Activated:Connect(clearRecipeSearch)
ui.NoMatchesClear.Activated:Connect(clearRecipeSearch)
recipeScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateStripArrows)
recipeScroll.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then cancelStripScroll() end
end)
recipeScroll.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseWheel then cancelStripScroll() end
end)
local function moveStrip(direction)
    local maximum,scale=stripMetrics()
    local tile=ui.Settings.StripItems
    local step=(tile.W+(tile.Gap or 14))*tile.Scale*scale
    local current=ui.ScrollTarget or recipeScroll.CanvasPosition.X
    local target=math.clamp(current+direction*step,0,maximum)
    if math.abs(target-current)<0.01 then return end
    cancelStripScroll()
    recipeScroll:ResetScrollVelocity()
    ui.ScrollTarget=target
    local tween=TweenService:Create(recipeScroll,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition=Vector2.new(target,0)})
    ui.ScrollTween=tween
    tween.Completed:Once(function()
        if ui.ScrollTween==tween then
            ui.ScrollTween=nil
            ui.ScrollTarget=nil
            updateStripArrows()
        end
    end)
    updateStripArrows()
    tween:Play()
end
ui.Left.Activated:Connect(function() moveStrip(-1) end)
ui.Right.Activated:Connect(function() moveStrip(1) end)
local function setQuantity(value)
    if value and value==value and math.abs(value)<math.huge then ui.Quantity=math.clamp(math.floor(value),1,999) end
    ui.QuantityBox.Text=tostring(ui.Quantity)
    updateDetailsContent()
end
ui.Minus.Activated:Connect(function() setQuantity(ui.Quantity-1) end)
ui.Plus.Activated:Connect(function() setQuantity(ui.Quantity+1) end)
ui.QuantityBox.FocusLost:Connect(function() setQuantity(tonumber(ui.QuantityBox.Text)) end)
local craftTween=nil
local craftLocked=false
craftButton.Activated:Connect(function()
    if craftLocked or not gui.Parent or not selectedRecipe then return end
    craftLocked=true
    if craftTween then craftTween:Cancel() end
    setCraftingVisualProperty(craftButton,"BackgroundTransparency",0.08)
    craftTween=createCraftingVisualTween(craftButton,TweenInfo.new(0.12),{BackgroundTransparency=0})
    craftTween:Play()
    showCraftingProgress(recipes[selectedRecipe],ui.Quantity,function() craftLocked=false end)
end)
craftingFadeDriver=Instance.new("NumberValue")
craftingFadeDriver.Name="CraftingFadeDriver"
craftingFadeDriver.Value=1
craftingFadeDriver.Parent=gui
local craftingFadeTween

applyCraftingFade=function()
for _,entry in ipairs(craftingFadeEntries) do
renderCraftingFadeEntry(entry)
end
end

local function captureCraftingFade()
local function capture(object,property)
local properties=craftingFadeLookup[object]
if not properties then
properties={}
craftingFadeLookup[object]=properties
end
local entry={
Object=object,
Property=property,
Base=object[property],
}
properties[property]=entry
table.insert(craftingFadeEntries,entry)
end
capture(craftingPanel,"BackgroundTransparency")
for _,object in ipairs(craftingPanel:GetDescendants()) do
if object:IsA("GuiObject") then
capture(object,"BackgroundTransparency")
if object:IsA("ImageLabel") or object:IsA("ImageButton") then
capture(object,"ImageTransparency")
end
if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
capture(object,"TextTransparency")
capture(object,"TextStrokeTransparency")
end
elseif object:IsA("UIStroke") then
capture(object,"Transparency")
end
end
applyCraftingFade()
end
craftingFadeDriver:GetPropertyChangedSignal("Value"):Connect(applyCraftingFade)

local finalPosition=layoutVector(canvas,ui.Settings.Menu.X,ui.Settings.Menu.Y)
local closedPosition=layoutVector(canvas,ui.Settings.Menu.X,ui.Settings.Menu.Y+12)
local craftingOpen=false
local motionId=0
local panelTween=nil
local blurTween=nil
local nextToggleAt=0
local blockingMouseLook=false

local function pointInside(root,point)
if not root.Visible then
return false
end
local position=root.AbsolutePosition
local size=root.AbsoluteSize
return point.X>=position.X
and point.Y>=position.Y
and point.X<=position.X+size.X
and point.Y<=position.Y+size.Y
end

local function gateCraftingMouse(_,inputState,input)
if not craftingOpen or not craftingPanel.Visible then
return Enum.ContextActionResult.Pass
end

if input.UserInputType==Enum.UserInputType.MouseButton2 then
if inputState==Enum.UserInputState.Begin then
blockingMouseLook=pointInside(craftingPanel,UserInputService:GetMouseLocation())
end

local shouldBlock=blockingMouseLook

if inputState==Enum.UserInputState.End
or inputState==Enum.UserInputState.Cancel then
blockingMouseLook=false
end

return shouldBlock
and Enum.ContextActionResult.Sink
or Enum.ContextActionResult.Pass
end

if input.UserInputType==Enum.UserInputType.MouseMovement
and blockingMouseLook then
return Enum.ContextActionResult.Sink
end

return Enum.ContextActionResult.Pass
end

local function setCraftingInputLocked(shouldLock)
ContextActionService:UnbindAction("SurvivalCraftingInputLock")
blockingMouseLook=false

if shouldLock then
ContextActionService:BindActionAtPriority(
"SurvivalCraftingInputLock",
gateCraftingMouse,
false,
Enum.ContextActionPriority.High.Value+100,
Enum.UserInputType.MouseButton2,
Enum.UserInputType.MouseMovement
)
end
end

local function setCraftingOpen(shouldOpen,keepBlur)
if craftingOpen==shouldOpen
and craftingPanel.Visible==shouldOpen then
return
end

ui.CancelNavigation()
motionId+=1
local currentMotionId=motionId
craftingOpen=shouldOpen

if panelTween then
panelTween:Cancel()
end

if blurTween then
blurTween:Cancel()
end
if craftingFadeTween then
craftingFadeTween:Cancel()
end
worldBlur=Lighting:FindFirstChild("SurvivalInventoryBlur") or craftingBlur
if worldBlur~=craftingBlur then
craftingBlur.Size=0
end

if shouldOpen then
setCraftingVisible(true)
local inventoryPosition=closeInventory()
selectRecipe(selectedRecipe,false)

local wasVisible=craftingPanel.Visible
craftingPanel.Visible=true
setCraftingInputLocked(true)

if inventoryPosition or not wasVisible then
craftingPanel.Position=inventoryPosition or closedPosition
end
if not wasVisible then
craftingFadeDriver.Value=1
applyCraftingFade()
end

panelTween=TweenService:Create(
craftingPanel,
TweenInfo.new(0.17,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{
Position=finalPosition,
}
)

blurTween=TweenService:Create(
worldBlur,
TweenInfo.new(0.17,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=9}
)

craftingFadeTween=TweenService:Create(
craftingFadeDriver,
TweenInfo.new(0.17,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Value=0}
)
craftingFadeTween:Play()
panelTween:Play()
blurTween:Play()
else
setCraftingInputLocked(false)

panelTween=TweenService:Create(
craftingPanel,
TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
{
Position=closedPosition,
}
)

blurTween=TweenService:Create(
worldBlur,
TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
{Size=keepBlur and 9 or 0}
)

craftingFadeTween=TweenService:Create(
craftingFadeDriver,
TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
{Value=1}
)
craftingFadeTween:Play()
panelTween:Play()
blurTween:Play()

panelTween.Completed:Connect(function()
if currentMotionId==motionId and not craftingOpen then
craftingPanel.Visible=false
craftingPanel.Position=closedPosition
craftingFadeDriver.Value=1
applyCraftingFade()
setCraftingVisible(false)
end
end)
end
end

local function toggleCrafting()
local now=os.clock()

if now<nextToggleAt then
return
end

nextToggleAt=now+0.4
setCraftingOpen(not craftingOpen,false)
end

craftingButton.Activated:Connect(toggleCrafting)

local inventoryConnections={}
local function bindInventoryButton(button)
local inventoryGui=getInventoryGui()
local inventoryCanvas=inventoryGui and inventoryGui:FindFirstChild("DesignCanvas")
if not inventoryCanvas or button.Parent~=inventoryCanvas
or button.Name~="OpenInventoryButton"
or not button:IsA("GuiButton") or inventoryConnections[button] then
return
end
inventoryConnections[button]=button.Activated:Connect(function()
if craftingOpen then
setCraftingOpen(false,true)
end
end)
if craftingOpen then
setCraftingVisible(true)
closeInventory()
end
end

local inventoryWatcher=playerGui.DescendantAdded:Connect(function(child)
if child.Name=="OpenInventoryButton" then
bindInventoryButton(child)
end
end)
for _,child in ipairs(playerGui:GetDescendants()) do
if child.Name=="OpenInventoryButton" then
bindInventoryButton(child)
end
end

craftingClose.Activated:Connect(function()
setCraftingOpen(false,false)
end)


gui.Destroying:Connect(function()
ui.CancelNavigation()
ui.DetailConnection:Disconnect()
ui.StripConnection:Disconnect()
cancelCraftingProgress()
progressGui:Destroy()
for _,entry in ipairs(craftingFadeEntries) do
if entry.Tween then
entry.Tween:Cancel()
end
if entry.Connection then
entry.Connection:Disconnect()
end
end
if craftTween then
craftTween:Cancel()
end
if craftingFadeTween then
craftingFadeTween:Cancel()
end
if panelTween then
panelTween:Cancel()
end
if blurTween then
blurTween:Cancel()
end
if craftingOpen and worldBlur.Parent then
worldBlur.Size=0
end
ContextActionService:UnbindAction("SurvivalCraftingInputLock")
setCraftingVisible(false)
inventoryWatcher:Disconnect()
for _,connection in pairs(inventoryConnections) do
connection:Disconnect()
end
workspaceConnection:Disconnect()
if cameraConnection then
cameraConnection:Disconnect()
end
craftingBlur:Destroy()
end)


applyUILayout()
setCategoryVisual(false)
layoutFilteredTiles(false)
selectRecipe(selectedRecipe,false)
craftingPanel.Position=closedPosition
craftingFadeDriver.Value=1
applyCraftingFade()
craftingPanel.Visible=false
setCraftingVisible(false)
setCraftingInputLocked(false)
captureCraftingFade()
updateDetailsContent()

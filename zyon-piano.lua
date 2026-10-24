-- ZYON Piano | Cole teclas; [ad] representa um acorde.
-- Adaptador opcional: keypress/keyrelease com codigos virtuais Windows.
-- Compatibilidade com executores e com o piano precisa ser testada no jogo.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
assert(player, "Execute no cliente")
local parent = player:WaitForChild("PlayerGui")
local previous = parent:FindFirstChild("ZyonPiano")
if previous then error("O painel ZYON ja esta aberto. Feche-o antes de executar novamente.") end

local gui = Instance.new("ScreenGui")
gui.Name = "ZyonPiano"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent
local colors = {bg=Color3.fromRGB(16,19,29), panel=Color3.fromRGB(25,30,43),
    text=Color3.fromRGB(234,239,255), muted=Color3.fromRGB(151,163,187),
    accent=Color3.fromRGB(112,101,255)}
local function make(class, props, owner)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k]=v end
    obj.Parent = owner
    return obj
end
local function round(obj, radius)
    make("UICorner", {CornerRadius=UDim.new(0,radius or 10)}, obj)
end
local frame = make("Frame", {Size=UDim2.fromOffset(480,490),
    Position=UDim2.new(.5,-240,.5,-245), BackgroundColor3=colors.bg, BorderSizePixel=0}, gui)
round(frame,16)
make("UISizeConstraint", {MinSize=Vector2.new(280,300),MaxSize=Vector2.new(480,490)},frame)
local scale = make("UIScale", {}, frame)
local function resize()
    local camera=workspace.CurrentCamera
    if camera then scale.Scale=math.min(1,(camera.ViewportSize.X-24)/480,(camera.ViewportSize.Y-24)/490) end
end
resize()
local function label(text,x,y,w,h,size,color)
    return make("TextLabel", {Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundTransparency=1,TextColor3=color or colors.text,Font=Enum.Font.Gotham,
        TextSize=size or 14,TextXAlignment=Enum.TextXAlignment.Left},frame)
end
local title=label("ZYON  /  PIANO",22,16,350,30,21)
title.Font=Enum.Font.GothamBold
title.Active=true
label("Uma nota. Um acorde. Um clique.",22,48,420,22,13,colors.muted)
local function button(text,x,y,w,h,accent)
    local b=make("TextButton", {Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundColor3=accent and colors.accent or colors.panel,TextColor3=colors.text,
        Font=Enum.Font.GothamBold,TextSize=14,BorderSizePixel=0,AutoButtonColor=true},frame)
    round(b)
    return b
end
local close=button("X",420,16,38,30)
local choose=button("ESCOLHER MUSICA  /  11 TITULOS",22,78,436,28,true)
local scroll=make("ScrollingFrame",{Position=UDim2.fromOffset(22,110),Size=UDim2.fromOffset(436,140),
    BackgroundColor3=colors.panel,BorderSizePixel=0,ScrollBarThickness=4,
    CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},frame)
round(scroll)
local editor=make("TextBox",{Position=UDim2.fromOffset(12,10),Size=UDim2.new(1,-28,0,120),
    AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text="",PlaceholderText="a s d [ad] f [sg]",
    PlaceholderColor3=colors.muted,TextColor3=colors.text,TextSize=17,Font=Enum.Font.Code,
    TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
    ClearTextOnFocus=false,MultiLine=true},scroll)
label("Teclas / [acordes] ou texto keypress(...) + rest(...)",22,257,436,20,11,colors.muted)
local loadButton=button("Carregar",22,289,128,36)
local reset=button("Reiniciar",160,289,128,36)
label("Duracao (ms)",305,289,150,16,11,colors.muted)
local duration=make("TextBox",{Position=UDim2.fromOffset(305,308),Size=UDim2.fromOffset(153,28),
    BackgroundColor3=colors.panel,TextColor3=colors.text,Font=Enum.Font.Code,TextSize=14,
    Text="90",ClearTextOnFocus=false,BorderSizePixel=0},frame)
round(duration,6)
local preview=label("Proxima: —",22,344,436,30,19)
local track=make("Frame",{Position=UDim2.fromOffset(22,385),Size=UDim2.fromOffset(436,5),
    BackgroundColor3=colors.panel,BorderSizePixel=0,ClipsDescendants=true},frame)
round(track)
local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=colors.accent,BorderSizePixel=0},track)
local nextButton=button("TOCAR PROXIMA",22,404,436,44,true)
local status=label("Escolha uma musica no catalogo acima.",22,455,436,24,11,colors.muted)
status.TextWrapped=true
local songInfo=label("",34,120,410,120,16)
songInfo.TextWrapped=true
songInfo.TextYAlignment=Enum.TextYAlignment.Top
songInfo.Visible=false
local picker=make("Frame",{Position=UDim2.fromOffset(22,110),Size=UDim2.fromOffset(436,228),
    BackgroundColor3=colors.panel,BorderSizePixel=0,ZIndex=20,Visible=false},frame)
round(picker)
local search=make("TextBox",{Position=UDim2.fromOffset(10,8),Size=UDim2.new(1,-20,0,30),
    BackgroundColor3=colors.bg,Text="",PlaceholderText="Buscar musica...",TextColor3=colors.text,
    PlaceholderColor3=colors.muted,Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false,
    BorderSizePixel=0,ZIndex=21},picker)
round(search,6)
local songList=make("ScrollingFrame",{Position=UDim2.fromOffset(10,46),Size=UDim2.new(1,-20,1,-54),
    BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ZIndex=21},picker)
make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},songList)
-- Apenas metadados publicos. As sequencias sao lidas do servidor original ao selecionar.
local catalog={
    {"Golden Hour","GOLDEN_HOUR"},
    {"Young Girl A","YOUNG_GIRL_A"},
    {"Moonlight Sonata - Third Movement","WHAT_THE_FUCKK"},
    {"Undertale","UNDERTALE"},
    {"Turkish March","TURKISH"},
    {"Unravel (Animenz arr.)","UNRAVEL_EPIC"},
    {"Snowfall","SNOWFALL"},
    {"Bohemian Rhapsody","BOHEMIAN_RHAPSODY"},
    {"Renai Circulation","RENAI_CIRCULATION"},
    {"We Not Like You","WE_NOT_LIKE_U"},
    {"Flight (Man of Steel)","FLIGHT"},
}

local sequence,index,busy,dirty,closed={},1,false,false,false
local loading,selectedSong=false,nil
local cache={}
local held={}
local connections={}
local shifted={ ["!"]="1",["@"]="2",["#"]="3",["$"]="4",["%"]="5",
    ["^"]="6",["&"]="7",["*"]="8",["("]="9",[")"]="0" }
local function decode(char)
    if char:match("^[a-z0-9]$") then return {code=string.byte(char:upper()),shift=false} end
    if char:match("^[A-Z]$") then return {code=string.byte(char),shift=true} end
    if shifted[char] then return {code=string.byte(shifted[char]),shift=true} end
    error("Tecla nao suportada: "..char..". Use letras, numeros ou !@#$%^&*().",0)
end
local function parse(source)
    if source:find("keypress%s*%(") then
        -- Leitura declarativa: nenhum trecho do texto colado e executado.
        -- Subconjunto aceito: keypress("teclas", x/numero, bpm), rest(numero,bpm), finishedSong().
        local chunks,pending,lastDuration={},"",nil
        local function flush()
            if pending~="" then
                table.insert(chunks,#pending>1 and "["..pending.."]" or pending)
                pending="";lastDuration=nil
            end
        end
        local lineNumber=0
        if #source>2000000 then error("Texto muito grande. Limite: 2 MB.",0) end
        for line in (source.."\n"):gmatch("(.-)\n") do
            lineNumber=lineNumber+1
            line=line:gsub("%-%-.*$",""):match("^%s*(.-)%s*$")
            if line~="" then
                local keys,beats=line:match('^keypress%s*%(%s*"([^"\\]*)"%s*,%s*([%w%.]+)%s*,%s*bpm%s*%)%s*;?$')
                if not keys then
                    keys,beats=line:match("^keypress%s*%(%s*'([^'\\]*)'%s*,%s*([%w%.]+)%s*,%s*bpm%s*%)%s*;?$")
                end
                if keys then
                    if beats~="x" and (not tonumber(beats) or tonumber(beats)<=0) then
                        error("Duracao invalida na linha "..lineNumber,0)
                    end
                    if keys=="" or keys:find("[%s%[%]]") then error("Teclas invalidas na linha "..lineNumber,0) end
                    for j=1,#keys do decode(keys:sub(j,j)) end
                    if lastDuration and lastDuration~=beats then flush() end
                    pending=pending..keys;lastDuration=beats
                elseif line:match("^rest%s*%(%s*[%d%.]+%s*,%s*bpm%s*%)%s*;?$") then flush()
                elseif line:match("^finishedSong%s*%(%s*%)%s*;?$") then flush()
                else error("Comando nao suportado na linha "..lineNumber..". Nada foi executado.",0) end
            end
        end
        flush()
        source=table.concat(chunks," ")
        -- As pausas separam etapas; o ritmo e definido pelos cliques.
        -- A duracao de todas as notas usa o campo Duracao (ms).
    end
    local result,i={},1
    while i<=#source do
        local c=source:sub(i,i)
        if c:match("%s") then i=i+1
        else
            local token=c
            if c=="[" then
                local ending=source:find("]",i+1,true)
                if not ending then error("Acorde sem ] na posicao "..i,0) end
                token=source:sub(i+1,ending-1):gsub("%s","")
                if token=="" then error("Acorde vazio na posicao "..i,0) end
                i=ending
            elseif c=="]" then error("] sem abertura na posicao "..i,0) end
            local notes,seen={},{}
            for j=1,#token do
                local note=decode(token:sub(j,j))
                local identity=tostring(note.code)..(note.shift and ":shift" or ":plain")
                if not seen[identity] then table.insert(notes,note);seen[identity]=true end
            end
            table.insert(result,{text=#token>1 and "["..token.."]" or token,notes=notes})
            if #result>20000 then error("Limite: 20000 notas/acordes.",0) end
            i=i+1
        end
    end
    if #result==0 then error("Cole uma sequencia primeiro.",0) end
    return result
end
local function refresh()
    preview.Text="Proxima: "..(sequence[index] and sequence[index].text or (#sequence>0 and "Fim" or "—"))
    fill.Size=UDim2.fromScale(#sequence>0 and (index-1)/#sequence or 0,1)
    nextButton.Text=loading and "CARREGANDO…" or (busy and "TOCANDO…" or (index>#sequence and #sequence>0 and "CONCLUIDO" or "TOCAR PROXIMA"))
end
choose.Activated:Connect(function()
    if loading or busy then return end
    picker.Visible=not picker.Visible
    if not picker.Visible then search:ReleaseFocus() end
end)
local rows={}
for order,entry in ipairs(catalog) do
    local song=entry
    local row=make("TextButton",{Size=UDim2.new(1,-8,0,34),Text="  "..song[1],
        BackgroundColor3=colors.bg,TextColor3=colors.text,Font=Enum.Font.Gotham,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
        BorderSizePixel=0,ZIndex=22,LayoutOrder=order},songList)
    round(row,6)
    table.insert(rows,{button=row,title=song[1]:lower()})
    row.Activated:Connect(function()
        if loading or busy or closed then return end
        loading=true;picker.Visible=false;search:ReleaseFocus();refresh()
        status.Text="Carregando "..song[1].."..."
        local ok,result=pcall(function()
            if cache[song[2]] then return cache[song[2]] end
            local text=game:HttpGet("https://hellohellohell0.com/talentless-raw/SONGS/"..song[2],true)
            if type(text)~="string" or #text==0 then error("Resposta vazia do servidor.",0) end
            local parsed=parse(text)
            cache[song[2]]=parsed
            return parsed
        end)
        loading=false
        if closed then return end
        if not ok then status.Text="Nao carregou: "..tostring(result);refresh();return end
        sequence=result;index=1;dirty=false;selectedSong=song[1]
        scroll.Visible=false;songInfo.Visible=true
        songInfo.Text=song[1].."\n\n"..#sequence.." notas/acordes.\nUse TOCAR PROXIMA para avancar."
        choose.Text=song[1].."  /  TROCAR"
        loadButton.Text="Usar texto"
        status.Text="Musica pronta. Ative o piano e toque por clique."
        refresh()
    end)
end
table.insert(connections,search:GetPropertyChangedSignal("Text"):Connect(function()
    local query=search.Text:lower()
    for _,row in ipairs(rows) do row.button.Visible=row.title:find(query,1,true)~=nil end
    songList.CanvasPosition=Vector2.new(0,0)
end))
local function releaseAll()
    for code in pairs(held) do
        if type(keyrelease)=="function" then pcall(keyrelease,code) end
        held[code]=nil
    end
end
table.insert(connections,editor:GetPropertyChangedSignal("Text"):Connect(function()
    dirty=true;status.Text="Sequencia alterada. Clique em Carregar."
end))
loadButton.Activated:Connect(function()
    if busy or loading then return end
    picker.Visible=false
    if selectedSong then
        selectedSong=nil;scroll.Visible=true;songInfo.Visible=false
        loadButton.Text="Carregar";choose.Text="ESCOLHER MUSICA  /  11 TITULOS"
        dirty=true;status.Text="Cole suas teclas e clique em Carregar.";return
    end
    local ok,result=pcall(parse,editor.Text)
    if not ok then status.Text=tostring(result);return end
    sequence=result;index=1;dirty=false;refresh()
    status.Text=#sequence.." etapas carregadas. Ative o piano antes de tocar."
end)
reset.Activated:Connect(function()
    if busy or loading then return end
    index=1;refresh();status.Text="Sequencia reiniciada."
end)
nextButton.Activated:Connect(function()
    if busy or loading or closed or picker.Visible then return end
    if dirty then status.Text="Clique em Carregar para aplicar a edicao.";return end
    local entry=sequence[index]
    if not entry then status.Text="Carregue uma sequencia ou clique em Reiniciar.";return end
    if type(keypress)~="function" or type(keyrelease)~="function" then
        status.Text="Ambiente sem keypress/keyrelease. Envio de teclas indisponivel.";return
    end
    local ms=tonumber(duration.Text)
    if not ms or ms~=ms then status.Text="Informe uma duracao entre 20 e 2000 ms.";return end
    ms=math.clamp(ms,20,2000);duration.Text=tostring(ms)
    if UIS:GetFocusedTextBox() then UIS:GetFocusedTextBox():ReleaseFocus() end
    busy=true;refresh()
    local ok,err=pcall(function()
        -- Registra antes de pressionar para tentar soltar mesmo se houver erro.
        local function press(code) held[code]=true;keypress(code) end
        -- Shift e global: agrupa notas sem Shift e depois com Shift.
        -- Acordes mistos dependem de o piano registrar Shift no evento KeyDown.
        for _,note in ipairs(entry.notes) do if not note.shift then press(note.code) end end
        local hasShift=false
        for _,note in ipairs(entry.notes) do if note.shift then hasShift=true end end
        if hasShift then
            press(0x10)
            for _,note in ipairs(entry.notes) do
                if note.shift then
                    -- Duas alturas podem compartilhar a mesma tecla fisica (a/A).
                    -- Rearticula a tecla para gerar o segundo KeyDown.
                    if held[note.code] then keyrelease(note.code);held[note.code]=nil end
                    press(note.code)
                end
            end
            keyrelease(0x10);held[0x10]=nil
        end
        task.wait(ms/1000)
    end)
    releaseAll();busy=false
    if closed then return end
    if ok then index=index+1;status.Text=string.format("Enviado %d de %d. Confirme o som no piano.",index-1,#sequence)
    else status.Text="Falha no envio: "..tostring(err) end
    refresh()
end)
local dragging,origin,start
table.insert(connections,title.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true;origin=input.Position;start=frame.Position
    end
end))
table.insert(connections,UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-origin
        frame.Position=UDim2.new(start.X.Scale,start.X.Offset+delta.X,start.Y.Scale,start.Y.Offset+delta.Y)
    end
end))
table.insert(connections,UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end))
local function cleanup()
    if closed then return end
    closed=true;releaseAll()
    for _,connection in ipairs(connections) do connection:Disconnect() end
end
gui.Destroying:Connect(cleanup)
close.Activated:Connect(function() cleanup();gui:Destroy() end)
if type(keypress)~="function" or type(keyrelease)~="function" then
    status.Text="Painel pronto; ambiente sem keypress/keyrelease para tocar."
end

local inspect = require'inspect'
local zip = require'zip'

print(_VERSION)

function show(table)
    print(inspect(table))
end

--io.write('Enter url of video: ')
--local url = io.read()
--io.write('Enter name of video: ')
--local name = io.read()
--


name = "CRITICA"
winw = 900
winh = 1000
mouse_hold = 0

--os.execute("yt2txt".." "..url.." "..name)

--chars = {}
--while true do
    --io.write('Enter name of character(Leave empty when done): ')
    --local char = io.read()
    --if char ~= "" then 
        --chars[#chars+1] = char
    --else
        --break
    --end
--end

function file_exists(file)
  local f = io.open(file, "rb")
    if f then f:close() end
      return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

local lines

local file = name..".pt.vtt"
if file_exists(file) then
    lines = lines_from(file)
end


for k, line in pairs(lines) do
    if string.find(line, "-->") then
        lines[k] = nil
    elseif line == "" then
        lines[k] = nil
    end
end


font = love.graphics.newFont( "ttf/OpenSans-Bold.ttf", 15)
love.graphics.setFont(font)

local global_yoffset = 0


function love.wheelmoved(x, y)
    if y > 0 then
        text = "Mouse wheel moved up"
    elseif y < 0 then
        text = "Mouse wheel moved down"
    end
    global_yoffset = global_yoffset + (y*10)
end

-- Load some default values for our rectangle.
function love.load()
    success = love.window.setMode( winw, winh)
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
    check_mouse_down()
    switch_chars()
    show(actual_char)
end



function text_get_rect(text) 
    x,y = love.mouse.getPosition()
    w = font:getWidth(text)
    h = font:getHeight(text)
end


function mouse_is_in(text, rect_pos, mouse_pos) 
    x,y = unpack(mouse_pos)
    y = y - global_yoffset
    w = font:getWidth(text)
    h = font:getHeight(text)
    if rect_pos.x < x and x < rect_pos.x + w then
        if rect_pos.y < y and y < rect_pos.y + h then
            return true
        end
    end
    return false
end

function check_mouse_down ()
    down = love.mouse.isDown( 1 )
    if down then
        mouse_hold = mouse_hold + 1
    else
        mouse_hold = 0
    end
end

function assign_char(i)
    lines_obj[i].color_rect = actual_char.color
    lines_obj[i].char_id = actual_char.char_id
end




function love.mousepressed(x, y, button, istouch, presses)

    if presses == 1 and button == 1 then
        for i, line_obj in ipairs(lines_obj) do
            local mousein =  mouse_is_in(line_obj.line, line_obj.pos, {x,y})
            if mousein then
                if love.mouse.isDown(1) then
                    assign_char(i)
                end
            end
        end
    end

end

function range(n)
    a = {}    
    for i=1, n do
      a[i] = i
    end
    return a
end

lines_obj = {}

local i = 0
for k, line in pairs(lines) do
    local posx = winw/2-(font:getWidth(line)/2)
    local posy = 100+i*20
    lines_obj[#lines_obj+1] = {line=line, clicked=false, color_rect = {255,255,255}, color_text={0,0,0}, pos ={x=posx,y=posy}, char_id = nil}
    i = i+1
end


chars_colors = {{255,0,0},{0,255,0},{0,0,255}}
chars_names = {"HOMEM", "MULHER", "ANALISTA"}
chars_colors[#chars_colors+1] = {255,255,255}
chars_names[#chars_names+1] = "LIXO"
chars = {}


local i = 0 
for color, name in zip(chars_colors, chars_names) do
    local x = 120 + i*(winw/#chars_names)
    local y = 20
    local pos = {x=x,y=y}
    chars[#chars+1] = {name=name, color=color, clicked=clicked, pos=pos, char_id = i+1}
    i = i + 1
end
actual_char = chars[#chars]
--show(actual_char)

function draw_chars(table)
    for k,char in pairs(table) do
        love.graphics.printf({{0,0,0},char.name}, char.pos.x, char.pos.y, 1000,  "left")
        local mode 
        local color = char.color
        if char.name == "LIXO" then
            color = {0,0,0}
        end
        if char.name == actual_char.name then
            mode = "fill"
        else
            mode = "line"
        end
        love.graphics.setColor(color)
        love.graphics.circle(mode, char.pos.x - 50, char.pos.y + font:getHeight(char.name)/2, 15 )
    end
end

function switch_chars()
    keys = {1,2,3,4,5,6,7,8,9,0}
    down = nil
    for k,v in pairs(keys) do
        key = love.keyboard.isDown(v)
        if key then
            down = v
        end

    end
    if down then 
        if chars[down] then 
            actual_char = chars[down]
        end
    end
end

function draw_text_canvas()
    love.graphics.setCanvas(canvas)
    love.graphics.setBackgroundColor(255,255,255)
    for i, line_obj in ipairs(lines_obj) do
        local mouse_pos = {love.mouse.getPosition()}
        local mousein =  mouse_is_in(line_obj.line, line_obj.pos, mouse_pos)
        local color = line_obj.color_rect
        if mouse_hold > 10 and mousein then
            --lines_obj[i].color_rect = actual_char.color
            --lines_obj[i].char_id = actual_char.char_id
            assign_char(i)
            color = actual_char.color
        end
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", line_obj.pos.x, line_obj.pos.y, font:getWidth(line_obj.line), font:getHeight(line_obj.line))
        love.graphics.printf({{0,0,0},line_obj.line}, line_obj.pos.x, line_obj.pos.y, 1000,  "left")
    end
    return canvas
end

function draw_header_canvas()
    local header_height = 60
    love.graphics.setCanvas(canvas2)
    --love.graphics.setBackgroundColor(255,255,255)
    love.graphics.setColor({255,255,255})
    love.graphics.rectangle("fill", 0, 0, winw, header_height)
    love.graphics.setColor({0,0,0})
    love.graphics.rectangle("line", 0, 0, winw, header_height)
    draw_chars(chars)
    return canvas2

end

canvas = love.graphics.newCanvas(winw, winh)
canvas2 = love.graphics.newCanvas(winw, header_height)

function love.draw()



    canvas2 = draw_header_canvas()
    canvas = draw_text_canvas()


   love.graphics.setCanvas() 
   love.graphics.draw(canvas, 0, global_yoffset)
   --love.graphics.draw(canvas2, 0, 5)
end


function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function love.quit()
    local last_char_id 
    local script = {}
    local script_line = ""
    local lines_obj_filtered = {}
    for k,line_obj in pairs(lines_obj) do
        if line_obj.char_id then
            lines_obj_filtered[#lines_obj_filtered+1] = line_obj
        end
    end
    
    for i, line_obj in ipairs(lines_obj_filtered) do
        if last_char_id == nil then
            last_char_id = line_obj.char_id
            script_line = line_obj.line

        elseif last_char_id == line_obj.char_id then
            script_line = script_line..". "..line_obj.line

        elseif last_char_id ~= line_obj.char_id then
            -- Save last script line
            local char_name = chars[last_char_id].name
            script[#script+1] = {char=char_name, line=script_line}

            script_line = line_obj.line
            last_char_id = line_obj.char_id
        end
        if i == #lines_obj_filtered then
            local char_name = chars[last_char_id].name
            script[#script+1] = {char=char_name, line=script_line}
        end
    end
    local tex_template = readAll("template.tex")

    local string = ""
    for k,line in pairs(script) do
        string = string.."\n\n".."\\mychar{"..line.char.."}: "..line.line
    end

    tex_template = tex_template:gsub("INPUT", string)
    tex_template = tex_template:gsub("TITLE", "CRITICA")



    os.execute("mkdir".." ".."CRITICA")
    os.execute("cd".." ".."CRITICA".." ".."&& mkdir".." ".."meta")

    file = io.open("CRITICA/out.tex", "w")
    io.output(file)
    io.write(tex_template)
    io.close(file)

end

local inspect = require'inspect'
local zip = require'zip'
local file = require'file_handling'

scene = {}
scene.running = true

test = false

function show(var)
    print(inspect(var))
end

function get_url_and_name()
    io.write('Enter url of video: ')
    local url = io.read()
    --love.textinput( text )
    io.write('Enter name of video: ')
    local name = io.read()
    return url, name
end

function download_vtt(url, name)
    os.execute("yt2txt.lua".." "..url.." "..name)
end

function get_vtt_file_lines(video_title)
    local lines
    local file_name = video_title..".pt.vtt"
    if file.exists(file_name) then
        lines = file.read_lines(file_name)
    end
    return lines
end

function filter_vtt(lines)
    for k, line in pairs(lines) do
        if string.find(line, "-->") then
            lines[k] = nil
        elseif line == "" then
            lines[k] = nil
        end
    end
    return lines
end

function get_chars_names()
    local chars = {}
    while true do
        io.write('Enter name of character(Leave empty when done): ')
        local char = io.read()
        if char ~= "" then 
            chars[#chars+1] = char
        else
            break
        end
    end
    return chars
end

function get_chars()
    local chars = {}
    local chars_colors = {{255,0,0},{0,255,0},{0,0,255}}
    if test then
        chars_names = {"HOMEM", "MULHER", "ANALISTA"}
    else
        chars_names = get_chars_names()
    end
    chars_colors[#chars_colors+1] = {255,255,255}
    chars_names[#chars_names+1] = "LIXO"
    local i = 0 
    for name, color in zip(chars_names, chars_colors) do
        local x = 120 + i*(winw/#chars_names)
        local y = 20
        local pos = {x=x,y=y}
        chars[#chars+1] = {name=name, color=color, clicked=clicked, pos=pos, char_id = i+1}
        i = i + 1
    end
    return chars
end

winw = 900
winh = 1000
mouse_hold = 0

local lines_obj, chars
local actual_char


local global_yoffset = 0
local text_canvas, header_canvas
local url, video_title
local font


function get_lines_obj(lines)
    local lines_obj = {}
    local i = 0
    for k, line in pairs(lines) do
        local posx = winw/2-(font:getWidth(line)/2)
        local posy = 100+i*20
        pos = {x=posx,y=posy}
        lines_obj[#lines_obj+1] = {line=line,
                                   clicked=false,
                                   rect= {pos=pos, w=font:getWidth(line), h=font:getHeight(line)},
                                   color_rect = {255,255,255},
                                   color_text={0,0,0},
                                   pos =pos,
                                   char_id = nil}
        i = i+1
    end
    return lines_obj
end

function text_get_rect(text) 
    x,y = love.mouse.getPosition()
    w = font:getWidth(text)
    h = font:getHeight(text)
end

function mouse_is_in(rect, mouse_pos) 
    x, y = unpack(mouse_pos)
    w = rect.w
    h = rect.h
    if rect.pos.x < x and x < rect.pos.x + w then
        if rect.pos.y < y and y < rect.pos.y + h then
            return true
        end
    end
    return false
end
--function mouse_is_in(text, rect_pos, mouse_pos) 
    --x,y = unpack(mouse_pos)
    --y = y - global_yoffset
    --w = font:getWidth(text)
    --h = font:getHeight(text)
    --if rect_pos.x < x and x < rect_pos.x + w then
        --if rect_pos.y < y and y < rect_pos.y + h then
            --return true
        --end
    --end
    --return false
--end

function check_mouse_down ()
    down = love.mouse.isDown( 1 )
    if down then
        mouse_hold = mouse_hold + 1
    else
        mouse_hold = 0
    end
end

function keyboard_switch_chars()
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

function assign_char(i)
    lines_obj[i].color_rect = actual_char.color
    lines_obj[i].char_id = actual_char.char_id
end





function draw_text_canvas()
    love.graphics.setCanvas(text_canvas)
    love.graphics.clear()
    love.graphics.setBackgroundColor(255,255,255)
    for i, line_obj in ipairs(lines_obj) do
        love.graphics.setColor(255,255,255)
        local mouse_pos = {love.mouse.getPosition()}
        local mousein =  mouse_is_in(line_obj.rect, mouse_pos)
        print("Iteration")
        if mousein then print(true) end
        local color = line_obj.color_rect
        if mouse_hold > 10 and mousein then
            assign_char(i)
            color = actual_char.color
        end
        love.graphics.setColor(color)
        fontHeight = font:getHeight(lines_obj.line)
        fontWidth = font:getWidth(line_obj.line)
        love.graphics.rectangle("fill", line_obj.pos.x, line_obj.pos.y, fontWidth, fontHeight )
        love.graphics.printf({{0,0,0},line_obj.line}, line_obj.pos.x, line_obj.pos.y, 1000,  "left")
    end
end

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

function draw_header_canvas()
    local header_height = 60
    love.graphics.setCanvas(header_canvas)
    love.graphics.setColor({255,255,255})
    love.graphics.rectangle("fill", 0, 0, winw, header_height)
    love.graphics.setColor({0,0,0})
    love.graphics.rectangle("line", 0, 0, winw, header_height)
    draw_chars(chars)

end





------------------------------------------------------------------------------
-- Pega tabelas do formato:
--              {{"PERSONAGEM1", "asdasd"},{"PERSONAGEM1", "aaabbbccc"}, {"PERSONAGEM2", "1234"}}
-- Concatena falas do mesmo personagem em sequência:
--              {{"PERSONAGEM1", "asasdasda. aaabbbccc"}, {"PERSONAGEM2", "1234"}}
-- @return table 
function get_movie_script()
    local last_char_id 
    local script = {}
    local script_line = ""
    local lines_obj_filtered = {}
    for k,line_obj in pairs(lines_obj) do
        if line_obj.char_id and line_obj.char_id ~= #chars then
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
    return script
end

function write_latex_file(script)
    local tex_template = file.read_all("template.tex")

    local string = ""
    for k,line in pairs(script) do
        string = string.."\n\n".."\\mychar{"..line.char.."}: "..line.line
    end

    tex_template = tex_template:gsub("INPUT", string)
    show(video_title)
    local temp = video_title:gsub("_"," ")
    tex_template = tex_template:gsub("TITLE", temp)



    os.execute("mkdir".." "..video_title)
    os.execute("cd".." "..video_title.." ".."&& mkdir".." ".."meta")

    fh = io.open(video_title.."/out.tex", "w")
    io.output(fh)
    io.write(tex_template)
    io.close(fh)
end


function love.wheelmoved(x, y)
    if y > 0 then
        text = "Mouse wheel moved up"
    elseif y < 0 then
        text = "Mouse wheel moved down"
    end
    global_yoffset = global_yoffset + (y*10)
end

function scene.mousepressed(x, y, button, istouch, presses)

    if presses == 1 and button == 1 then
        for i, line_obj in ipairs(lines_obj) do
            local mousein =  mouse_is_in(line_obj.rect, {x,y})
            if mousein then
                if love.mouse.isDown(1) then
                    assign_char(i)
                end
            end
        end
    end

end

function scene.load(arg_url, arg_video_title)
    success = love.window.setMode( winw, winh)
    text_canvas = love.graphics.newCanvas(winw, winh*3)
    header_canvas = love.graphics.newCanvas(winw, header_height)
    font = love.graphics.newFont( "ttf/OpenSans-Bold.ttf", 15)
    love.graphics.setFont(font)
    local lines
    if not test then
        --url, video_title = get_url_and_name()
        url = arg_url
        video_title = arg_video_title
        video_title = video_title:gsub(" ","_")
        download_vtt(url, video_title)
    else
        video_title = "CRITICA"
    end
    lines = get_vtt_file_lines(video_title)
    lines = filter_vtt(lines)
    lines_obj = get_lines_obj(lines)

    chars = get_chars()
    actual_char = chars[#chars]
end

function scene.exit_program()
    local script = get_movie_script()
    write_latex_file(script)
end

function listen_enter()
    if love.keyboard.isDown("return") then
        scene.running = false
        scene.exit_program()
        love.event.quit(0)
    end

end

function scene.draw()

    draw_header_canvas()
    draw_text_canvas()

    love.graphics.setCanvas() 
    love.graphics.setColor(255,255,255)
    love.graphics.draw(text_canvas, 0, global_yoffset)
    love.graphics.draw(header_canvas, 0, 5)
end

time_elapsed = 0
function scene.update(dt)
    time_elapsed = time_elapsed + dt
    check_mouse_down()
    keyboard_switch_chars()
    if time_elapsed > 0.7 then 
        listen_enter()
    end
end

function scene.quit()
    scene.exit_program()
end
return scene

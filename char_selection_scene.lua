local utf8 = require("utf8")
local inspect = require'inspect'

local scene = {}

function show(arg)
    print(inspect(arg))
end


local texts = {}
local ready, counter
local ctrl_v_counter
scene.running = true
scene.name = "char_selection_scene"
font = love.graphics.getFont( )
font_height = font:getHeight()


local clicked_index = 1

function add_form(label)
    pos = {x=0, y=font_height + (#texts*(font_height*2))}
    rect = {pos=pos,w=400, h=20}
    texts[#texts+1] = {text="", pos=pos, rect=rect, label=label}
end

function scene.load()
    counter = 0
    ctrl_v_counter = 0
    label = "Enter Char name:" 
    add_form(label)

    -- enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
    love.keyboard.setKeyRepeat(true)
end


function scene.update(dt)
    local url, name = scene.listen_enter()
    if url or name then
        return url, name
    end
    counter = counter + dt
    ctrl_v_counter = ctrl_v_counter + dt
    check_ctrlv()
end

function assign_char(i)
    --texts[i].clicked = not texts[i].clicked
    --texts[i].clicked = true
end

function scene.mousepressed(x, y, button, istouch, presses)

    if presses >= 1 and button == 1 then
        for i, line_obj in ipairs(texts) do
            local mousein =  mouse_is_in(line_obj.rect, {x,y})
            if mousein then
                if love.mouse.isDown(1) then
                    print("Mouse pressed")
                    --assign_char(i)
                    clicked_index = i
                end
            end
        end
    end

end

function scene.textinput(t)
    texts[clicked_index].text = texts[clicked_index].text..t
end

function scene.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        text = texts[clicked_index].text
        local byteoffset = utf8.offset(text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            texts[clicked_index].text = string.sub(text, 1, byteoffset - 1)
            --actual_text = 
        end
    end
    --if key == "return" then
        --pos = {x=0, y=font_height + (#texts*font_height)}
        --texts[#texts+1] = {text=actual_text,pos=pos}
        --actual_text = "Enter video name -- "
    --end
end

function check_ctrlv()
    if ctrl_v_counter > 0.15 then
        if love.keyboard.isDown("v") and love.keyboard.isDown("lctrl") then
            fh = io.popen("xclip -selection clipboard -o")
            out = fh:read("*all")
            texts[clicked_index].text = texts[clicked_index].text..out
        end
        ctrl_v_counter = 0
    end
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

function scene.exit_program()
    url = texts[1].text
    name = texts[2].text
    return url, name
end

function scene.listen_enter()
    if love.keyboard.isDown("return") then
        if texts[clicked_index].text != "" then
            add_form("Enter Char name:")
            clicked_index = clicked_index + 1
        else 
            scene.running = false
        end

    end

end

function scene.draw()
    love.graphics.setBackgroundColor(255,255,255)
    for i,text in ipairs(texts) do
        love.graphics.setColor({0,0,0})
        love.graphics.setLineWidth( 1 )
        fontWidth = font:getWidth(text.text) 
        if i==clicked_index then
            love.graphics.setLineWidth( 4 )
            --love.graphics.setColor({0,0,0})
        end
        label_offset_x = 100
        love.graphics.printf({{0,0,0}, text.label}, text.pos.x+5, text.pos.y+2, love.graphics.getWidth())
        love.graphics.rectangle("line", text.pos.x+label_offset_x, text.pos.y, text.rect.w, text.rect.h)
        love.graphics.printf({{0,0,0}, text.text}, text.pos.x+5+label_offset_x, text.pos.y+2, love.graphics.getWidth())
        love.graphics.setLineWidth( 1 )
    end

end

return scene

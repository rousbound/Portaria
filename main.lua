local file = require'bib.file_handling'

folder_path = file.read_lines("config.txt")[1]

local form_scene = require'form_scene'
local char_selection_scene = require'char_selection_scene'
local script_scene = require'script_scene'

local scenes = {[1]=form_scene, [2]=char_selection_scene, [3]=script_scene}
local scene_index = 1


function love.textinput(t)
    if actual_scene.textinput then
        actual_scene.textinput(t)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    actual_scene.mousepressed(x, y, button, istouch, presses)
end

function love.keypressed(key)
    if actual_scene.keypressed then
        actual_scene.keypressed(key)
    end
end

function love.draw()
    actual_scene.draw()
end

function load_next_scene()
    scene_index = scene_index + 1
    actual_scene = scenes[scene_index]
    actual_scene.load()
end

function love.wheelmoved(x,y)
    if actual_scene.wheelmoved then
        actual_scene.wheelmoved(x,y)
    end
end

function love.update(dt)
    if not actual_scene.running then
        if actual_scene.name == "form_scene" then
            scenes[3].video_title = actual_scene.exit_program()
        elseif actual_scene.name == "char_selection_scene" then
            scenes[3].chars_names = actual_scene.exit_program()
        end
        load_next_scene()
    end
    actual_scene.update(dt)
end

function love.quit()
    if actual_scene.quit then
        actual_scene.quit()
    end
end

function test_bypass()
    scenes[3].video_title = "DEUS"
    scenes[3].chars_names = {"DEUS","MULHER"}
    actual_scene = scenes[3]
end

function love.load()
    actual_scene = form_scene
    --test_bypass()
    actual_scene.load()
end

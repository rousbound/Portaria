local char_selection_scene = require'char_selection_scene'

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
    actual_scene.load(url, video_title)
end

function love.update(dt)
    if not actual_scene.running then
        love.event.quit(1)
    end
    actual_scene.update(dt)
end

function love.quit()
    if actual_scene.quit then
        actual_scene.quit()
    end
end

function love.load()
    actual_scene = char_selelection_scene
    actual_scene.load()
end

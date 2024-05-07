-- Dependencies
push = require 'push'
Class = require 'class'

-- Game modules
require 'Paddle'
require 'Ball'

-- Window dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Game settings
PADDLE_SPEED = 200
gameMode = 'Singleplayer'

-- Initialization function
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    winningPlayer = 0
    gameState = 'start'
end

-- Resize callback function
function love.resize(w, h)
    push:resize(w, h)
end

-- Update function
function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- Collision detection with paddles
        if ball:collides(player1) or ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = ball:collides(player1) and player1.x + 5 or player2.x - 4
            ball.dy = ball.dy < 0 and -math.random(10, 150) or math.random(10, 150)
            sounds['paddle_hit']:play()
        end

        -- Collision detection with walls
        if ball.y <= 0 or ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = ball.y <= 0 and 0 or VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- Score update
        if ball.x < 0 or ball.x > VIRTUAL_WIDTH then
            if ball.x < 0 then
                servingPlayer = 1
                player2Score = player2Score + 1
            else
                servingPlayer = 2
                player1Score = player1Score + 1
            end
            sounds['score']:play()
            gameState = player1Score == 10 or player2Score == 10 and 'done' or 'serve'
            if gameState == 'done' then
                winningPlayer = player1Score == 10 and 1 or 2
            else
                ball:reset()
            end
        end
    end

    -- Paddle movement
    player1.dy = love.keyboard.isDown('w') and -PADDLE_SPEED or love.keyboard.isDown('s') and PADDLE_SPEED or 0

    if gameMode == 'Singleplayer' then
        local targetY = ball.y - (player2.height / 2)                           -- Target is center of the ball
        local distance = targetY - player2.y
        local speedFactor = math.max(0.9, math.min(1, math.abs(distance) / 50)) -- Dynamic speed factor
        local moveSpeed = PADDLE_SPEED * speedFactor                            -- Apply dynamic factor

        if math.abs(distance) > 10 then                                         -- Threshold to prevent tiny, unnecessary movements
            player2.dy = distance > 0 and moveSpeed or -moveSpeed
        else
            player2.dy = 0 -- Stop moving if close enough
        end
    else
        player2.dy = love.keyboard.isDown('up') and -PADDLE_SPEED or love.keyboard.isDown('down') and PADDLE_SPEED or 0
    end

    -- Update objects if playing
    if gameState == 'play' then
        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end

-- Key press handler
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0
            servingPlayer = winningPlayer == 1 and 2 or 1
        end
    elseif key == 'm' then
        if gameState == 'start' then
            gameMode = gameMode == 'Singleplayer' and 'Multiplayer' or 'Singleplayer'
        end
    end
end

-- Render function
function love.draw()
    push:apply('start')
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Current Mode: ' .. gameMode, 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore()
    player1:render()
    player2:render()
    ball:render()
    displayFPS()
    push:apply('end')
end

-- Score display
function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

-- FPS display
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

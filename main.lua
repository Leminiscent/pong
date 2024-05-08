-- Dependencies
push = require 'push'   -- Library for setting up a virtual window
Class = require 'class' -- Library for using classes in Lua

-- Game modules
require 'Paddle' -- Paddle class definition
require 'Ball'   -- Ball class definition

-- Constants for the actual and virtual window dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Game settings
PADDLE_SPEED = 200        -- Movement speed of paddles
gameMode = 'Singleplayer' -- Default game mode

-- Initialization function for setting up the game
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Set graphics filter for pixel art
    love.window.setTitle('Pong')                         -- Set the window title to "Pong"
    math.randomseed(os.time())                           -- Random seed based on current time

    -- Define fonts of different sizes
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont) -- Set the default font

    -- Sound effects
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- Setup the virtual screen with dimensions and window behavior
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- Initialize player paddles and ball
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- Score and game state variables
    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    winningPlayer = 0
    gameState = 'start'
end

-- Function to handle window resizing
function love.resize(w, h)
    push:resize(w, h)
end

-- Update function for game logic
function love.update(dt)
    -- Handle game state transitions and gameplay logic
    if gameState == 'serve' then
        -- Setup ball movement for serving
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- Handle collisions and scoring
        if ball:collides(player1) or ball:collides(player2) then
            -- Invert ball direction and speed it up slightly on paddle collision
            ball.dx = -ball.dx * 1.03
            ball.x = ball:collides(player1) and player1.x + 5 or player2.x - 4
            ball.dy = ball.dy < 0 and -math.random(10, 150) or math.random(10, 150)
            sounds['paddle_hit']:play()
        end
        -- Wall collision logic
        if ball.y <= 0 or ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = ball.y <= 0 and 0 or VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        -- Update scores on out-of-bounds
        if ball.x < 0 or ball.x > VIRTUAL_WIDTH then
            servingPlayer = ball.x < 0 and 1 or 2
            if ball.x < 0 then
                player2Score = player2Score + 1
            else
                player1Score = player1Score + 1
            end
            sounds['score']:play()
            gameState = player1Score == 10 or player2Score == 10 and 'done' or 'serve'
            if gameState == 'done' then
                winningPlayer = player1Score == 10 and 1 or 2
            else
                -- Reset positions for a new serve
                player1:reset(30)
                player2:reset(VIRTUAL_HEIGHT - 30)
                ball:reset()
            end
        end
    end

    -- Paddle movement logic
    if gameState == 'play' then
        player1.dy = love.keyboard.isDown('w') and -PADDLE_SPEED or love.keyboard.isDown('s') and PADDLE_SPEED or 0
        -- Handle paddle movement based on game mode
        if gameMode == 'Singleplayer' then
            -- AI for single player mode
            local targetY = ball.y - (player2.height / 2)
            local distance = targetY - player2.y
            local speedFactor = math.max(0.75, math.min(1, math.abs(distance) / 10))
            local moveSpeed = PADDLE_SPEED * speedFactor
            if math.abs(distance) > 6 then
                player2.dy = distance > 0 and moveSpeed or -moveSpeed
            else
                player2.dy = 0
            end
        else
            -- Multiplayer control
            player2.dy = love.keyboard.isDown('up') and -PADDLE_SPEED or love.keyboard.isDown('down') and PADDLE_SPEED or
                0
        end
        ball:update(dt)
    end

    -- Update paddles
    player1:update(dt)
    player2:update(dt)
end

-- Handle key presses for game state transitions and exiting
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        -- Transition game states based on key presses
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- Reset game to serve state after completion
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0
            servingPlayer = winningPlayer == 1 and 2 or 1
        end
    elseif key == 'm' then
        -- Toggle game mode at start
        if gameState == 'start' then
            gameMode = gameMode == 'Singleplayer' and 'Multiplayer' or 'Singleplayer'
        end
    elseif key == 'r' then
        -- Reset game to initial state
        gameState = 'start'
        player1Score = 0
        player2Score = 0
        servingPlayer = 1
        winningPlayer = 0
        player1:reset(30)
        player2:reset(VIRTUAL_HEIGHT - 30)
        ball:reset()
    end
end

-- Render function for drawing the game
function love.draw()
    push:apply('start')
    -- Clear the screen with a dark background color
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    -- Display text based on game state
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
    -- Display scores and FPS
    displayScore()
    player1:render()
    player2:render()
    ball:render()
    displayFPS()
    push:apply('end')
end

-- Function to display the score
function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

-- Function to display FPS in the corner of the screen
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

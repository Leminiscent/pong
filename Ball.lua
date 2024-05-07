-- Ball class definition using hump.class
Ball = Class {}

-- Initialization of the Ball
function Ball:init(x, y, width, height)
    self.x = x           -- The X coordinate of the ball
    self.y = y           -- The Y coordinate of the ball
    self.width = width   -- Width of the ball
    self.height = height -- Height of the ball
    self.dy = 0          -- Initial Y-axis velocity
    self.dx = 0          -- Initial X-axis velocity
end

-- Check for collision with a paddle
function Ball:collides(paddle)
    -- Horizontal collision detection
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    -- Vertical collision detection
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end
    -- Collision detected
    return true
end

-- Reset ball to the center of the screen with no movement
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
end

-- Update the ball's position based on its velocity
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- Render the ball on the screen
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
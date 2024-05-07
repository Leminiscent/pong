-- Paddle class definition using hump.class
Paddle = Class {}

-- Initialization of the Paddle
function Paddle:init(x, y, width, height)
    self.x = x           -- The X coordinate
    self.y = y           -- The Y coordinate
    self.width = width   -- Width of the paddle
    self.height = height -- Height of the paddle
    self.dy = 0          -- Initial velocity along Y-axis
end

-- Update function to move the paddle
function Paddle:update(dt)
    if self.dy < 0 then
        -- Move up, ensuring the paddle does not go above the screen
        self.y = math.max(0, self.y + self.dy * dt)
    else
        -- Move down, ensuring the paddle does not go below the screen
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

-- Render function to draw the paddle on the screen
function Paddle:render()
    -- Draw a rectangle representing the paddle
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

-- Function to reset the paddle to the passed Y coordinate
function Paddle:reset(y)
    self.y = y
    self.dy = 0
end

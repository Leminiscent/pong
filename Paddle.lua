-- Paddle class

-- Class representing a paddle that can move up and down. Used to control the player's paddle and the AI's paddle.
Paddle = Class {}

-- Constructor for the Paddle class. Initializes a new paddle with specified position and size.
-- @param x (number): The initial x-coordinate of the paddle.
-- @param y (number): The initial y-coordinate of the paddle.
-- @param width (number): The width of the paddle.
-- @param height (number): The height of the paddle.
function Paddle:init(x, y, width, height)
    self.x = x           -- The current X coordinate of the paddle.
    self.y = y           -- The current Y coordinate of the paddle.
    self.width = width   -- The width of the paddle.
    self.height = height -- The height of the paddle.
    self.dy = 0          -- The initial velocity of the paddle along the Y-axis (0 means no movement).
end

-- Updates the position of the paddle based on its velocity and prevents it from moving out of screen bounds.
-- @param dt (number): The delta time in seconds for frame-rate independence.
function Paddle:update(dt)
    if self.dy < 0 then
        -- Move the paddle up, ensuring it does not move above the top of the screen.
        self.y = math.max(0, self.y + self.dy * dt)
    else
        -- Move the paddle down, ensuring it does not move below the bottom of the screen.
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

-- Renders the paddle at its current position.
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height) -- Draws a filled rectangle at paddle's position.
end

-- Resets the paddle to a specified Y coordinate, usually used when starting a new game or round.
-- @param y (number): The Y coordinate to reset the paddle to.
function Paddle:reset(y)
    self.y = y  -- Set the Y coordinate of the paddle.
    self.dy = 0 -- Reset the velocity to 0.
end

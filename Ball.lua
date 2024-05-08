-- Ball class

-- Class definition for the Ball class. Represents a ball that moves around the screen and interacts with paddles and walls.
Ball = Class {}

-- Constructor for the Ball class. Initializes a new ball with specified position and size.
-- @param x (number): The initial x-coordinate of the ball.
-- @param y (number): The initial y-coordinate of the ball.
-- @param width (number): The width of the ball.
-- @param height (number): The height of the ball.
function Ball:init(x, y, width, height)
    self.x = x           -- The current X coordinate of the ball.
    self.y = y           -- The current Y coordinate of the ball.
    self.width = width   -- The width of the ball.
    self.height = height -- The height of the ball.
    self.dy = 0          -- The initial velocity of the ball along the Y-axis.
    self.dx = 0          -- The initial velocity of the ball along the X-axis.
end

-- Checks for collision between the ball and a given paddle.
-- @param paddle (table): The paddle object to check for collision against.
-- @return (boolean): True if there is a collision, false otherwise.
function Ball:collides(paddle)
    -- Checks if the ball is too far to the right or left of the paddle to collide.
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- Checks if the ball is too far above or below the paddle to collide.
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- If neither of the above conditions are true, a collision has occurred.
    return true
end

-- Resets the ball to the center of the screen with no movement.
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2   -- Center the ball horizontally.
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2 -- Center the ball vertically.
    self.dx = 0                                   -- Set horizontal velocity to 0.
    self.dy = 0                                   -- Set vertical velocity to 0.
end

-- Updates the position of the ball based on its velocity.
-- @param dt (number): The delta time in seconds for frame-rate independence.
function Ball:update(dt)
    self.x = self.x + self.dx * dt -- Update the X coordinate based on velocity and delta time.
    self.y = self.y + self.dy * dt -- Update the Y coordinate based on velocity and delta time.
end

-- Renders the ball at its current position.
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

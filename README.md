# Pong

This repository contains the source code for a simple Pong game implemented in Lua using the LÖVE framework. The game includes both singleplayer and multiplayer modes.

## Overview

The game simulates the classic Pong game where two paddles on either side of the screen control the movement to hit a ball back and forth. The objective is to score points by getting the ball past the opponent's paddle.

## Files

The project is divided into several Lua files for clarity and modularity:

- `main.lua`: This is the main entry point of the game. It handles game initialization, input processing, game state management, and rendering.
- `Paddle.lua`: Defines the `Paddle` class, which manages the paddle's attributes and behavior.
- `Ball.lua`: Defines the `Ball` class, which manages the ball's attributes and behavior.

## Game Features

- **Game Modes**: The game can be played in singleplayer mode against a simple AI, or in multiplayer mode with two players.
- **Collision Detection**: Implements basic collision detection between the ball and paddles, as well as the ball and the game's top and bottom walls.
- **Score Tracking**: The game tracks the score of both players, displaying it on the screen.
- **Dynamic Speed**: The ball's speed increases slightly each time it hits a paddle, adding challenge to the gameplay.

## Dependencies

The game requires the following Lua libraries:

- `push`: A library that allows drawing the game in a virtual resolution, making it look like a retro game.
- `class`: Simplifies object-oriented programming in Lua.

## Running the Game

To run the game, you will need to have the LÖVE2D framework installed on your machine. Once installed, you can run the game by navigating to the project's directory and running:

```bash
love .
```

## Controls

- **Singleplayer Mode**:
  - `W` and `S` to move the left paddle up and down.
- **Multiplayer Mode**:
  - Player 1 uses `W` and `S` to move the left paddle.
  - Player 2 uses the `Up` and `Down` arrow keys to move the right paddle.
- **General controls**:
  - `Enter` to start the game or serve the ball.
  - `Escape` to quit the game.
  - `M` to toggle between singleplayer and multiplayer mode.
  - `R` to reset the game to the initial state.

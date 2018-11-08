# Love2D Base Building Example

![Screenshot](/screenshot.png?raw=true "Screenshot")

## Getting started
```
git clone https://github.com/maluramichael/love2d-base-building-example.git
cd love2d-base-building-example
git submodule init
git submodule update
love .
```

## Code
* base.lua - this is the place where the worker put the gathered food
* brain.lua - every worker has a brain. just a simple state machine without logic.
* food.lua - the food on the floor
* hive.lua - iterates over all brains and runs their current state
* main.lua - well this is the entry point. here is getting everything rendered and updated
* states.lua - contains pretty much all logic.
* worker.lua - the dudes that are running around

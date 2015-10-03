-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
scrollSpeed = 2
local options = {
	width = 60,
	height = 20,
	numFrames = 6
}

local sequenceData = {
    { name = "health0", start=1, count=1, time=0,   loopCount=1 },
    { name = "health1", start=1, count=2, time=100, loopCount=1 },
    { name = "health2", start=1, count=3, time=200, loopCount=1 },
    { name = "health3", start=1, count=4, time=300, loopCount=1 },
    { name = "health4", start=1, count=5, time=400, loopCount=1 },
    { name = "health5", start=1, count=6, time=500, loopCount=1 }
	}

-- sequences table
local sequences_healthSheet = {
    -- consecutive frames sequence
    {
        name = "healthSprite",
        start = 1,
        count = 5,
        time = 800,
        loopCount = 0,
        loopDirection = "forward"
    }
}


-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setGravity(0,6)

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local healthSheet = graphics.newImageSheet("health_bar.png", options)
local healthSprite = display.newSprite( healthSheet, sequences_healthSheet)
healthSprite.x = display.contentWidth * .5
healthSprite.y = display.contentHeight * .5

-- Implementation for BUTTONS
local upButton = display.newImage("up.png")
upButton:scale(0.1,0.1)
upButton.x = display.contentWidth * .175
upButton.y = display.contentHeight * .8

local downButton = display.newImage("down.png")
downButton:scale(0.1,0.1)
downButton.x = display.contentWidth * .175
downButton.y = display.contentHeight * .9


local leftButton = display.newImage("left.png")
leftButton:scale(0.1,0.1)
leftButton.x = display.contentWidth * .1
leftButton.y = display.contentHeight * .9


local rightButton = display.newImage("right.png")
rightButton:scale(0.1,0.1)
rightButton.x = display.contentWidth * .25
rightButton.y = display.contentHeight * .9

local motionx = 0
local motiony = 0
local speed = 10


local function stop (event)
	if event.phase == "ended" then

	motionx = 0
	motiony = 0
	end
end

Runtime:addEventListener("touch",stop)

local function movething ( event ) 
	healthSprite.x = healthSprite.x + motionx
	healthSprite.y = healthSprite.y + motiony
end

Runtime:addEventListener("enterFrame", movething)

function upButton:touch()
	motionx = 0
	motiony = -speed
end
upButton:addEventListener("touch",upButton)

function downButton:touch()
	motionx = 0
	motiony = speed
end
downButton:addEventListener("touch",downButton)

function leftButton:touch()
	motionx = -speed
	motiony = 0
end
leftButton:addEventListener("touch",leftButton)

function rightButton:touch()
	motionx = speed
	motiony = 0
end
rightButton:addEventListener("touch",rightButton)


function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view


	
	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW*3, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( .5 )

	local background2 = display.newRect( 0, 0, screenW, screenH )
	background2.anchorX = 1
	background2.anchorY = 0
	background2:setFillColor( .5 )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW*2, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	grass.x, grass.y = 0, display.contentHeight

	local grass2 = display.newImageRect( "grass.png", screenW, 82 )
	grass2.anchorX = 1
	grass2.anchorY = 1
	grass2.x, grass2.y = 0, display.contentHeight
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	physics.addBody( grass2, "static", { friction=0.3, shape=grassShape } )
	physics.addBody(healthSprite)

	local function move(event)
		background.x = background.x - scrollSpeed
		background2.x = background2.x - scrollSpeed
		grass.x = grass.x - scrollSpeed
		grass2.x = grass2.x - scrollSpeed

		if(background.x + background.contentHeight) < 0 then
			background:translate( 320, 0 )
			end
		if(background2.x + background2.contentHeight) < 0 then
			background2:translate( 400, 0 )
			end 
		if(grass.x + grass.contentHeight) < 0 then
			grass:translate( 320, 0 )
			end	
		if(grass2.x + grass2.contentHeight) < 0 then
			grass2:translate( 320, 0 )
			end	
	end
	Runtime:addEventListener( "enterFrame", move )
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert(background2)
	sceneGroup:insert( grass )
	sceneGroup:insert(grass2)

end



function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene

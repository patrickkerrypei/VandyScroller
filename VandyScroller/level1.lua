-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local options = {
	width = 50,
	height = 60,
	numFrames = 2
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

local imgsheetSetup= 
{
width = 100,
height = 100,
numFrames = 3
}

local spriteSheet = graphics.newImageSheet("astronautSpriteSheet.png", imgsheetSetup);

--Now we create a table that holds the sequence data for our animations

local sequenceData = 
{
{ name = "running", start = 1, count = 6, time = 600, loopCount = 0},
{ name = "jumping", start = 7, count = 7, time = 1, loopCount = 1 }
}

--And assign it to the object hero using the display.newSprite function
local hero = display.newSprite(spriteSheet, sequenceData);


x = display.contentWidth/2;
y = display.contentHeight/2;
right = true;
hero.x = x;
hero.y = y;
hero.accel = 0
hero. gravity = -6
local astro = { density=1.0, friction=0.3, bounce=0.2 }
astro.bodyType= "dynamic"

physics.addBody( hero, astro )

hero:setSequence("running");

hero:play();
--rectangle used for our collision detection
--it will always be in front of the hero sprite
--that way we know if the hero hit into anything
local collisionRect = display.newRect(hero.x + 1, hero.y +1, 1, 1)
collisionRect.strokeWidth = 1
collisionRect:setFillColor(140, 140, 140)
collisionRect:setStrokeColor(180, 180, 180)
collisionRect.alpha = 0

-- Implementation for BUTTONS
local upButton;
upButton = display.newImage("up.png")
upButton:scale(0.5,0.5)
upButton.x = display.contentWidth * .105
upButton.y = display.contentHeight * .55

local leftButton;
leftButton = display.newImage("left.png")
leftButton:scale(0.5,0.5)
leftButton.x = display.contentWidth * .03
leftButton.y = display.contentHeight * .55

local rightButton;
rightButton = display.newImage("right.png")
rightButton:scale(0.5,0.5)
rightButton.x = display.contentWidth * .18
rightButton.y = display.contentHeight * .55

hero.x = 0
hero.y = 0
local speed = 10


local function stop (event)
	if event.phase == "ended" then

	hero.x = hero.x
	hero.y = hero.y
	end
end
Runtime:addEventListener("touch",stop)

function upButton:tap()
	hero.y = hero.y -50
	hero.x = hero.x + 20
end
upButton:addEventListener("tap",upButton)

function leftButton:touch()
	hero.x = hero.x -speed
end
leftButton:addEventListener("touch",leftButton)

function rightButton:touch()
	hero.x = hero.x + speed
end
rightButton:addEventListener("touch",rightButton)

local function createWalls()

	local wallThickness = 5

	--top
	wall = display.newRect(0, 0, display.contentWidth * 5, wallThickness-1)
	wall:setFillColor(0,0,0)
	physics.addBody(wall, "static", {friction = 0, bounce = 0})

	--bottom
	wall = display.newRect(0, display.contentHeight - wallThickness, display.contentWidth, wallThickness)
	wall:setFillColor(0,0,0)
	physics.addBody(wall, "static", {friction = 0, bounce = 0})

	--left
	local wall = display.newRect( -44, 0, wallThickness, display.contentHeight * 10)
	wall:setFillColor(0,0,0)
	physics.addBody(wall, "static", {friction = 0, bounce = 0})

	--right
	wall = display.newRect(display.contentWidth - wallThickness + 49, 0, wallThickness, display.contentHeight*5)
	wall:setFillColor(0,0,0)
	physics.addBody(wall, "static", {friction = 0, bounce = 0})
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view


	createWalls()

	
	--adds an image to our game centered at x and y coordinates

	local backgroundfar = display.newImage("bgfar1.png")
	backgroundfar.x = 480
	backgroundfar.y = 160

	local backgroundnear1 = display.newImage("bgnear2.png")
	backgroundnear1.x = 240
	backgroundnear1.y = 160

	local backgroundnear2 = display.newImage("bgnear2.png")
	backgroundnear2.x = 760
	backgroundnear2.y = 160

	--create a new group to hold all of our blocks
	local blocks = display.newGroup()
	local ghosts = display.newGroup()
	local spikes = display.newGroup()
	
	for a = 1, 3, 1 do
    ghost = display.newImage("ghost.png")
    ghost.name = ("ghost" .. a)
    ghost.id = a
    ghost.x = 1
    ghost.y = 600
    ghost.speed = 0
    --variable used to determine if they are in play or not
    ghost.isAlive = false
    --make the ghosts transparent and more... ghostlike!
    ghost.alpha = .5
    ghosts:insert(ghost)
end

--create spikes
for a = 1, 3, 1 do
    spike = display.newImage("spikeBlock.png")
    spike.name = ("spike" .. a)
    spike.id = a
    spike.x = 1
    spike.y = 500
    spike.isAlive = false
    spikes:insert(spike)
end

local blasts = display.newGroup()
--create blasts
for a=1, 5, 1 do
    blast = display.newImage("blast.png")
    blast.name = ("blast" .. a)
    blast.id = a
    blast.x = 200
    blast.y = 500
    blast.isAlive = false
    blasts:insert(blast)
	end
	


	--setup some variables that we will use to position the ground
	local groundMin = 420
	local groundMax = 340
	local groundLevel = groundMin
	local speed = 3;
	local inEvent = 0
	local eventRun = 0

	--this for loop will generate all of your ground pieces, we are going to
	--make 8 in all.
	for a = 1, 8, 1 do
		isDone = false

	--get a random number between 1 and 2, this is what we will use to decide which
	--texture to use for our ground sprites. Doing this will give us random ground
	--pieces so it seems like the ground goes on forever. You can have as many different
	--textures as you want. The more you have the more random it will be, just remember to
	--up the number in math.random(x) to however many textures you have.
	numGen = math.random(2)

	local blockShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	
	print (numGen)
	if(numGen == 1 and isDone == false) then
		newBlock = display.newImage("rocks.jpg")
		physics.addBody( newBlock, "kinematic", { frictional=0.3} )
		isDone = true
	end

	if(numGen == 2 and isDone == false) then
		newBlock = display.newImage("rocks.jpg")
		physics.addBody( newBlock, "kinematic", { frictional=0.3} )
		isDone = true
	end

	--now that we have the right image for the block we are going
	--to give it some member variables that will help us keep track
	--of each block as well as position them where we want them.
	newBlock.name = ("block" .. a)
	newBlock.id = a

	--because a is a variable that is being changed each run we can assign
	--values to the block based on a. In this case we want the x position to
	--be positioned the width of a block apart.
	newBlock.x = (a * 80) - 80
	newBlock.y = groundLevel
	blocks:insert(newBlock)
end


--the update function will control most everything that happens in our game
--this will be called every frame(30 frames per second in our case, which is the Corona SDK default)
local function update( event )
	--updateBackgrounds will call a function made specifically to handle the background movement
	updateBackgrounds()
	updateBlocks()
	updateBlasts()
	updateSpikes()
	updateGhosts()
	checkCollisions()
	speed = speed

end

function checkCollisions()
        --boolean variable so we know if we were on the ground in the last frame
	wasOnGround = onGround

	for a = 1, blocks.numChildren, 1 do
		if(collisionRect.y - 10> blocks[a].y - 170 and blocks[a].x - 40 < collisionRect.x and blocks[a].x + 40 > collisionRect.x) then
			--stop the hero
			speed = 0
		end
	end
	
	--stop the game if the hero runs into a spike wall
	for a = 1, spikes.numChildren, 1 do
		if(spikes[a].isAlive == true) then
			if(collisionRect.y - 10> spikes[a].y - 170 and spikes[a].x - 40 < collisionRect.x and spikes[a].x + 40 > collisionRect.x) then
				--stop the hero
				speed = 0
			end
		end
	end
	
	--make sure the player didn't get hit by a ghost!
	for a = 1, ghosts.numChildren, 1 do
		if(ghosts[a].isAlive == true) then
			if(((  ((hero.y-ghosts[a].y))<70) and ((hero.y - ghosts[a].y) > -70)) and (ghosts[a].x - 40 < collisionRect.x and ghosts[a].x + 40 > collisionRect.x)) then
				--stop the hero
				speed = 0
			end
		end
	end

	for a = 1, blocks.numChildren, 1 do
		if(hero.y >= blocks[a].y - 170 and blocks[a].x < hero.x + 60 and blocks[a].x > hero.x - 60) then
			hero.y = blocks[a].y - 171
			onGround = true
			break
		else
			onGround = false
		end
	end
end

--update the ghosts if they are alive
function updateGhosts()
	for a = 1, ghosts.numChildren, 1 do
		if(ghosts[a].isAlive == true) then
			(ghosts[a]):translate(speed * -1, 0)
			if(ghosts[a].y > hero.y) then
				ghosts[a].y = ghosts[a].y - 1
			end
			if(ghosts[a].y < hero.y) then
				ghosts[a].y = ghosts[a].y + 1
			end
			if(ghosts[a].x < -80) then
				ghosts[a].x = 800
				ghosts[a].y = 600
				ghosts[a].speed = 0
				ghosts[a].isAlive = false;
			end
		end
    end
end

--check to see if the spikes are alive or not, if they are
--then update them appropriately
function updateSpikes()
    for a = 1, spikes.numChildren, 1 do
        if(spikes[a].isAlive == true) then
            (spikes[a]):translate(speed * -1, 0)
            if(spikes[a].x < -80) then
                spikes[a].x = 900
                spikes[a].y = 500
                spikes[a].isAlive = false
            end
        end
    end
end

function updateBlasts()
        --for each blast that we instantiated check to see what it is doing
    for a = 1, blasts.numChildren, 1 do
                --if that blast is not in play we don't need to check anything else
        if(blasts[a].isAlive == true) then
            (blasts[a]):translate(5, 0)
                        --if the blast has moved off of the screen, then kill it and return it to its original place
            if(blasts[a].x > 550) then
                    blasts[a].x = 800
                blasts[a].y = 500
                blasts[a].isAlive = false
            end
        end
                --check for collisions between the blasts and the spikes
        for b = 1, spikes.numChildren, 1 do
            if(spikes[b].isAlive == true) then
                if(blasts[a].y - 25 > spikes[b].y - 120 and blasts[a].y + 25 < spikes[b].y + 120 and spikes[b].x - 40 < blasts[a].x + 25 and spikes[b].x + 40 > blasts[a].x - 25) then
					blasts[a].x = 800
					blasts[a].y = 500
					blasts[a].isAlive = false
					spikes[b].x = 900
					spikes[b].y = 500
					spikes[b].isAlive = false
                end
            end
        end
 
		--check for collisions between the blasts and the ghosts
		for b = 1, ghosts.numChildren, 1 do
			if(ghosts[b].isAlive == true) then
				if(blasts[a].y - 25 > ghosts[b].y - 120 and blasts[a].y + 25 < ghosts[b].y + 120 and ghosts[b].x - 40 < blasts[a].x + 25 and ghosts[b].x + 40 > blasts[a].x - 25) then
					blasts[a].x = 800
					blasts[a].y = 500
					blasts[a].isAlive = false
					ghosts[b].x = 800
					ghosts[b].y = 600
					ghosts[b].isAlive = false
					ghosts[b].speed = 0
				end
            end
        end
    end
end

function touched( event )
    if(event.phase == "began") then
        if(event.x < 241) then
            if(onGround) then
                hero.x = hero.x + 20
            end
        else
            for a=1, blasts.numChildren, 1 do
                if(blasts[a].isAlive == false) then
                    blasts[a].isAlive = true
                    blasts[a].x = hero.x + 50
                    blasts[a].y = hero.y
                    break
                end
            end
        end
    end
end

function updateBlocks()
     for a = 1, blocks.numChildren, 1 do
          if(a > 1) then
               newX = (blocks[a - 1]).x + 79
          else
               newX = (blocks[8]).x + 79 - speed
          end
          if((blocks[a]).x < -40) then
			 if(inEvent == 11) then
				  (blocks[a]).x, (blocks[a]).y = newX, 600
			 else
				  (blocks[a]).x, (blocks[a]).y = newX, groundLevel
			 end
			--by setting up the spikes this way we are guaranteed to
			--only have 3 spikes out at most at a time.
			if(inEvent == 12) then
				for a=1, spikes.numChildren, 1 do
					if(spikes[a].isAlive == true) then
					--do nothing
					else
					spikes[a].isAlive = true
					spikes[a].y = groundLevel - 200
					spikes[a].x = newX
					break
					end
				end
			end
			 checkEvent()
			else
				 (blocks[a]):translate(speed * -1, 0)
			end
		 end
end

function updatehero()
	--if our hero is jumping then switch to the jumping animation
	--if not keep playing the running animation
	if(onGround) then
		if(wasOnGround) then

		else
			hero:prepare("running")
			hero:play()
		end
	else
		hero:prepare("jumping")
		hero:play()
	end

	if(hero.accel > 0) then
		hero.accel = hero.accel - 1
	end

	--update the heros position, accel is used for our jump and
	--gravity keeps the hero coming down. You can play with those 2 variables
	--to make lots of interesting combinations of gameplay like 'low gravity' situations
	hero.y = hero.y - hero.accel
	hero.y = hero.y - hero.gravity

	--update the collisionRect to stay in front of the hero
	collisionRect.y = hero.y
end

function checkEvent()
     --first check to see if we are already in an event, we only want 1 event going on at a time
     if(eventRun > 0) then
          eventRun = eventRun - 1
          if(eventRun == 0) then
               inEvent = 0
          end
     end
     --if we are in an event then do nothing
     if(inEvent > 0 and eventRun > 0) then
          --Do nothing
     else
          check = math.random(100)
          if(check > 80 and check < 99) then
               inEvent = math.random(10)
               eventRun = 1
          end
		  
		  if(check > 98) then
				 inEvent = 11
				 eventRun = 2
			end			
			--the more frequently you want events to happen then
			--greater you should make the checks
			if(check > 72 and check < 81) then
					inEvent = 12
					eventRun = 1
			end
			
			--ghost event
			if(check > 60 and check < 73) then
					inEvent = 13
					eventRun = 1
			end
     end
     --if we are in an event call runEvent to figure out if anything special needs to be done
     if(inEvent > 0) then
          runEvent()
     end
end
--this function is pretty simple it just checks to see what event should be happening, then
--updates the appropriate items. Notice that we check to make sure the ground is within a
--certain range, we don't want the ground to spawn above or below whats visible on the screen.
function runEvent()
     if(inEvent < 6) then
          groundLevel = groundLevel + 40
     end
     if(inEvent > 5 and inEvent < 11) then
          groundLevel = groundLevel - 40
     end
     if(groundLevel < groundMax) then
          groundLevel = groundMax
     end
     if(groundLevel > groundMin) then
          groundLevel = groundMin
     end
	 
	--this will be a little bit different as we want this to really
	--make the game feel even more random. change where the ghosts
	--spawn and how fast they come at the hero.
	--this will be a little bit different as we want this to really
	--make the game feel even more random. change where the ghosts
	--spawn and how fast they come at the hero.
if(inEvent == 13) then
	for a=1, ghosts.numChildren, 1 do
		if(ghosts[a].isAlive == false) then
			ghosts[a].isAlive = true
			ghosts[a].x = 500
			ghosts[a].y = math.random(-50, 400)
			ghosts[a].speed = math.random(2,4)
			break
			end
		end
	end
end

function updateBackgrounds()
	--far background movement
	backgroundfar.x = backgroundfar.x - (speed/55)

	--near background movement
	backgroundnear1.x = backgroundnear1.x - (speed/5)
	if(backgroundnear1.x < -239) then
		backgroundnear1.x = 760
	end

	backgroundnear2.x = backgroundnear2.x - (speed/5)
	if(backgroundnear2.x < -239) then
		backgroundnear2.x = 760
	end
end

--this is how we call the update function, make sure that this line comes after the
--actual function or it will not be able to find it
--timer.performWithDelay(how often it will run in milliseconds, function to call,
--how many times to call(-1 means forever))
timer.performWithDelay(1, update, -1)
Runtime:addEventListener("touch", touched, -1)


--the rest of the code remains the same
function update()

if (right) then
hero.x = hero.x
else
hero.x = hero.x
end
if (hero.x > 480) then
right = false;
hero.xScale = -1;
end
if (hero.x < 0) then
right = true;
hero.xScale = 1;
end
end

timer.performWithDelay(1, update, -1);


	-- all display objects must be inserted into group
	

	sceneGroup:insert(backgroundnear2)
	sceneGroup:insert(backgroundnear1)
	sceneGroup:insert(backgroundfar)
	sceneGroup:insert(spikes)
	sceneGroup:insert(blasts)
	sceneGroup:insert(ghosts)
	sceneGroup:insert(hero)
	sceneGroup:insert(upButton)
	sceneGroup:insert(leftButton)
	sceneGroup:insert(rightButton)
	sceneGroup:insert(collisionRect)
	
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

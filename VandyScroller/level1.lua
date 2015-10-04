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
hero.x = 50;
hero.y = 50;
hero.accel = 0
hero. gravity = -6
local astro = { density=1.0, friction=0.3, bounce=0.2 }
astro.bodyType= "dynamic"

physics.addBody( hero, astro )
hero.isFixedRotation = true

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

hero.x = 0
hero.y = 0
local speed = 10

local function createWalls()

	local wallThickness = 5

	--top
	wall = display.newRect(0, 0, display.contentWidth * 5, wallThickness + 10)
	wall:setFillColor(0,0,0)
	physics.addBody(wall, "static", {friction = 0, bounce = 1})

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
	local meteors = display.newGroup()
	local aliens = display.newGroup()
	
	for a = 1, 3, 1 do
    meteor = display.newImage("meteor.png")
    meteor.name = ("meteor" .. a)
    meteor.id = a
    meteor.x = 1
    meteor.y = 600
    meteor.speed = 0
    --variable used to determine if they are in play or not
    meteor.isAlive = false
    --make the meteors transparent and more... meteorlike!
    meteor.alpha = .5
    meteors:insert(meteor)
end

--create aliens
for a = 1, 3, 1 do
    alien = display.newImage("alien.png")
    alien.name = ("alien" .. a)
    alien.id = a
    alien.x = 100
    alien.y = 500
    alien.isAlive = false
    aliens:insert(alien)
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

--the only difference in the touched function is now if you touch the
--right side of the screen the monster will fire off a little blue bolt
function touched( event )
    if(event.phase == "began") then
        if(event.x < display.contentWidth / 2) then
            hero.y = 0
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

Runtime:addEventListener("touch", touched, -1)

--the update function will control most everything that happens in our game
--this will be called every frame(30 frames per second in our case, which is the Corona SDK default)
local function update( event )
	--updateBackgrounds will call a function made specifically to handle the background movement
	createWalls()
	updateBackgrounds()
	updateBlocks()
	updateBlasts()
	updatealiens()
	updatemeteors()
	checkCollisions()
	

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
	
	--stop the game if the hero runs into an alien
	for a = 1, aliens.numChildren, 1 do
		if(aliens[a].isAlive == true) then
			if(collisionRect.y - 10> aliens[a].y - 170 and aliens[a].x - 40 < collisionRect.x and aliens[a].x + 40 > collisionRect.x) then
				--stop the hero
				speed = 0
			end
		end
	end
	
	
	--make sure the player didn't get hit by a meteor!
	for a = 1, meteors.numChildren, 1 do
		if(meteors[a].isAlive == true) then
			if(((  ((hero.y-meteors[a].y))<70) and ((hero.y - meteors[a].y) > -70)) and (meteors[a].x - 40 < collisionRect.x and meteors[a].x + 40 > collisionRect.x)) then
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

--update the meteors if they are alive
function updatemeteors()
	for a = 1, meteors.numChildren, 1 do
		if(meteors[a].isAlive == true) then
			(meteors[a]):translate(speed * -1, 0)
			if(meteors[a].y > hero.y) then
				meteors[a].y = meteors[a].y - 1
			end
			if(meteors[a].y < hero.y) then
				meteors[a].y = meteors[a].y + 1
			end
			if(meteors[a].x < -80) then
				meteors[a].x = 800
				meteors[a].y = 600
				meteors[a].speed = 1
				meteors[a].isAlive = false;
			end
		end
    end
end

--check to see if the aliens are alive or not, if they are
--then update them appropriately
function updatealiens()
    for a = 1, aliens.numChildren, 1 do
        if(aliens[a].isAlive == true) then
            (aliens[a]):translate(speed * -1, 0)
            if(aliens[a].x < -80) then
                aliens[a].x = 900
                aliens[a].y = 500
                aliens[a].isAlive = false
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
                --check for collisions between the blasts and the aliens
        for b = 1, aliens.numChildren, 1 do
            if(aliens[b].isAlive == true) then
                if(blasts[a].y - 25 > aliens[b].y - 120 and blasts[a].y + 25 < aliens[b].y + 120 and aliens[b].x - 40 < blasts[a].x + 25 and aliens[b].x + 40 > blasts[a].x - 25) then
					blasts[a].x = 800
					blasts[a].y = 500
					blasts[a].isAlive = false
					aliens[b].x = 90
					aliens[b].y = 50
					aliens[b].isAlive = false
                end
            end
        end
 	
		--check for collisions between the blasts and the meteors
		for b = 1, meteors.numChildren, 1 do
			if(meteors[b].isAlive == true) then
				if(blasts[a].y - 25 > meteors[b].y - 120 and blasts[a].y + 25 < meteors[b].y + 120 and meteors[b].x - 40 < blasts[a].x + 25 and meteors[b].x + 40 > blasts[a].x - 25) then
					blasts[a].x = 800
					blasts[a].y = 500
					blasts[a].isAlive = false
					meteors[b].x = 800
					meteors[b].y = 600
					meteors[b].isAlive = false
					meteors[b].speed = 0
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
			--by setting up the aliens this way we are guaranteed to
			--only have 3 aliens out at most at a time.
			if(inEvent == 12) then
				for a=1, aliens.numChildren, 1 do
					if(aliens[a].isAlive == true) then
					--do nothing
					else
					aliens[a].isAlive = true
					aliens[a].y = groundLevel - 200
					aliens[a].x = newX
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
			
			--meteor event
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
	--make the game feel even more random. change where the meteors
	--spawn and how fast they come at the hero.
	--this will be a little bit different as we want this to really
	--make the game feel even more random. change where the meteors
	--spawn and how fast they come at the hero.
if(inEvent == 13) then
	for a=1, meteors.numChildren, 1 do
		if(meteors[a].isAlive == false) then
			meteors[a].isAlive = true
			meteors[a].x = 500
			meteors[a].y = math.random(-50, 400)
			meteors[a].speed = math.random(2,4)
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
	sceneGroup:insert(aliens)
	sceneGroup:insert(blasts)
	sceneGroup:insert(meteors)
	sceneGroup:insert(hero)
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

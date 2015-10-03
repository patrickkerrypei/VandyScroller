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

local spriteSheet = graphics.newImageSheet("monsterSpriteSheet.png", imgsheetSetup);

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

hero:setSequence("running");
physics.addBody(hero)
hero:play();
-- Implementation for BUTTONS
local upButton = display.newImage("up.png")
upButton:scale(0.5,0.5)
upButton.x = display.contentWidth * .175
upButton.y = display.contentHeight * .8 -25

local downButton = display.newImage("down.png")
downButton:scale(0.5,0.5)
downButton.x = display.contentWidth * .175
downButton.y = display.contentHeight * .9 -25

local leftButton = display.newImage("left.png")
leftButton:scale(0.5,0.5)
leftButton.x = display.contentWidth * .1
leftButton.y = display.contentHeight * .9 -25

local rightButton = display.newImage("right.png")
rightButton:scale(0.5,0.5)
rightButton.x = display.contentWidth * .25
rightButton.y = display.contentHeight * .9 -25

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
	hero.x = hero.x +20
	hero.y = hero.y -70

end
upButton:addEventListener("tap",upButton)

function downButton:touch()
	hero.y = hero.y + speed
end
downButton:addEventListener("touch",downButton)

function leftButton:touch()
	hero.x = hero.x -speed
end
leftButton:addEventListener("touch",leftButton)

function rightButton:touch()
	hero.x = hero.x + speed
end
rightButton:addEventListener("touch",rightButton)


function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	
	--takes away the display bar at the top of the screen
	display.setStatusBar(display.HiddenStatusBar)

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

	--setup some variables that we will use to position the ground
	local groundMin = 370
	local groundMax = 310
	local groundLevel = groundMin
	local speed = 3;

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
	newBlock.x = (a * 79) - 79
	newBlock.y = groundLevel
	blocks:insert(newBlock)
end

local bgShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
--the update function will control most everything that happens in our game
--this will be called every frame(30 frames per second in our case, which is the Corona SDK default)
local function update( event )
	--updateBackgrounds will call a function made specifically to handle the background movement
	updateBackgrounds()
	updateBlocks()
	speed = speed

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
     checkEvent()
else
     (blocks[a]):translate(speed * -1, 0)
     checkEvent()
end

     end
end

local inEvent = 0
local eventRun = 0

function checkEvent()
     --first check to see if we are already in an event, we only want 1 event going on at a time
     if(eventRun > 0) then
          --if we are in an event decrease eventRun. eventRun is a variable that tells us how
          --much longer the event is going to take place. Everytime we check we need to decrement
          --it. Then if at this point eventRun is 0 then the event has ended so we set inEvent back
          --to 0.
          eventRun = eventRun - 1
          if(eventRun == 0) then
               inEvent = 0
          end
     end
     --if we are in an event then do nothing
     if(inEvent > 0 and eventRun > 0) then
          --Do nothing
     else
          --if we are not in an event check to see if we are going to start a new event. To do this
          --we generate a random number between 1 and 100. We then check to see if our 'check' is
          --going to start an event. We are using 100 here in the example because it is easy to determine
          --the likelihood that an event will fire(We could just as easilt chosen 10 or 1000).
          --For example, if we decide that an event is going to
          --start everytime check is over 80 then we know that everytime a block is reset there is a 20%
          --chance that an event will start. So one in every five blocks should start a new event. This
          --is where you will have to fit the needs of your game.
          check = math.random(100)
 
          --this first event is going to cause the elevation of the ground to change. For this game we
          --only want the elevation to change 1 block at a time so we don't get long runs of changing
          --elevation that is impossible to pass so we set eventRun to 1.
          if(check > 60 and check < 99) then
               --since we are in an event we need to decide what we want to do. By making inEvent another
               --random number we can now randomly choose which direction we want the elevation to change.
               inEvent = math.random(10)
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
          groundLevel = groundLevel + 20
     end
     if(inEvent > 5 and inEvent < 11) then
          groundLevel = groundLevel - 20
     end
     if(groundLevel < groundMax) then
          groundLevel = groundMax
     end
     if(groundLevel > groundMin) then
          groundLevel = groundMin
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
<<<<<<< HEAD
timer.performWithDelay(1, update, -1)
=======
<<<<<<< HEAD
timer.performWithDelay(1, update,  100)

local hero = display.newSprite(spriteSheet, sequenceData);
x = display.contentWidth/2;
y = display.contentHeight/2;
right = true;
hero.x = x;
hero.y = y;

--Then, instead of using the prepare method, we use setSequence
hero:setSequence("running");
physics.addBody(hero)
hero:play();
=======
timer.performWithDelay(1, update, 100)
>>>>>>> origin/master

>>>>>>> origin/master

--the rest of the code remains the same
function updateHero()

<<<<<<< HEAD
if (right) then
hero.x = hero.x+1;
else
hero.x = hero.x+1 ;
end
if (hero.x > 480) then
right = false;
hero.xScale = -1;
end
if (hero.x < 0) then
right = true;
hero.xScale = 1;
end
=======
	if (right) then
	hero.x = hero.x + 1;
	else
	hero.x = hero.x - 1;
	end
	if (hero.x > 480) then
	right = false;
	hero.xScale = -1;
	end
	if (hero.x < 0) then
	right = true;
	hero.xScale = 1;
	end
>>>>>>> origin/master
end

<<<<<<< HEAD
timer.performWithDelay(1, updateHero, 100);
	
=======
timer.performWithDelay(1, update, -1);


>>>>>>> origin/master
	-- all display objects must be inserted into group

	sceneGroup:insert(backgroundnear1)
	sceneGroup:insert(backgroundfar)
	sceneGroup:insert(backgroundnear2)
	sceneGroup:insert(hero)
<<<<<<< HEAD
end

=======
	sceneGroup:insert(upButton)
	sceneGroup:insert(downButton)
	sceneGroup:insert(leftButton)
	sceneGroup:insert(rightButton)
	
	








end

















>>>>>>> origin/master
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

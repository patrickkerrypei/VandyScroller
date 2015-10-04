-- Health, score and collision calculations
local function healthCalc()
	HP = 100
	score = 0

	if HP <= 0 then
		HP = 100
		score = 0
	end
end

local function getScore()
-- For each "object" destroyed
	--	score = score + 100
-- For each "boss" destroyed
	--	score = score + 500
	if HP == 100 then
		score = score * 1.2
	end 
end

local function onCollision(event)
	if event.phase == "began" then
		HP = HP - 25
	end
end

Runtime.addEventListener("collision", onCollision)

-- End Andrew's junky module

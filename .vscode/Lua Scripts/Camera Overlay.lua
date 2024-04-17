function onTick()
	cameraZoomX = input.getNumber(28)
	cameraIR = input.getBool(30)
	radarEnabled = input.getBool(31)
	radarFollowing = input.getBool(32)
end

function onDraw()
	screenW = screen.getWidth()
	screenH = screen.getHeight()
	screenCenterW = screenW/2
	screenCenterH = screenH/2
	
	screen.setColor(255,255,255,255)
	
	-- Screen Edge
	screen.drawRect(0, 0, screenW-1, screenH-1)
	
	-- Center
	screen.drawRect((screenW/2)-20, (screenH/2)-10, 40, 20)
	
	screen.drawLine(screenCenterW, screenCenterH-2, screenCenterW+2, screenCenterH-2)
	screen.drawLine(screenCenterW, screenCenterH+3, screenCenterW+2, screenCenterH+3)
	
	screen.drawLine(screenCenterW-2, screenCenterH, screenCenterW-2, screenCenterH+2)
	screen.drawLine(screenCenterW+3, screenCenterH, screenCenterW+3, screenCenterH+2)
		
	-- Camera Zoom Readout
	if cameraZoomX < 1 then
		cameraZoomX = 1
	end
	cameraZoomX = math.floor(cameraZoomX)
	if cameraZoomX < 1 then
		cameraZoomX = 1
	end
	
	if cameraZoomX > 9 then
		zoomWidth = 10
	else 
		zoomWidth = 5
	end
	screen.drawTextBox(2, 2, zoomWidth, 7, cameraZoomX, 0, 0)
	screen.drawTextBox(zoomWidth+2, 2, 5, 7, "X", 0, 0)

	-- Radar Mode
	if radarEnabled then
		if radarFollowing then
			screen.drawTextBox(2, 8, 30, 7, "FOLLOW", 0, 0)
		else
			if radarFollowReady then
				screen.drawTextBox(2, 8, 30, 7, "READY", 0, 0)
			else
				screen.drawTextBox(2, 8, 30, 7, "SEARCH", 0, 0)
			end
		end
	end
	
	-- Radar Mode
	if cameraIR then
		screen.drawTextBox(2, 16, 10, 7, "IR", 0, 0)
	end
end

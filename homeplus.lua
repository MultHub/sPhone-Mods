--setup
if not fs.exists("/.sPhone/apps/homeplus/shellIcon") then
	local f = fs.open("/.sPhone/apps/homeplus/shellIcon","w")
	f.write("4fff\nf4ff\n4f44")
	f.close()
end

if not fs.exists("/.sPhone/config/homeplus/icons") then
	local f = fs.open("/.sPhone/config/homeplus/icons","w")
	f.write("{[1] = {\"Shell\", \"/rom/programs/shell\"},}")
	f.close()
end

local iconPos = { --Because i hate math (to rewrite), anyway this is for the standard pocket computer size
	[1] = {3,2,6,4},
	[2] = {9,2,12,4},
	[3] = {15,2,18,4},
	[4] = {21,2,24,4},
	[5] = {3,8,6,10},
	[6] = {9,8,12,10},
	[7] = {15,8,18,10},
	[8] = {21,8,24,10},
	[9] = {3,14,6,16},
	[10] = {9,14,12,16},
	[11] = {15,14,18,16},
	[12] = {21,14,24,16},
}

local objectsDesktop = {}
local objCoords = {}
	
local f = fs.open("/.sPhone/config/homeplus/icons","r")
local objectsDesktop = textutils.unserialise(f.readAll())
f.close()

local function getCoords(iconNumber)
	if iconPos[iconNumber] then
		x = iconPos[iconNumber][1]
		y = iconPos[iconNumber][2]
		maxx = iconPos[iconNumber][3]
		maxy = iconPos[iconNumber][4]
		return x,y,maxx,maxy
	end
	return false
end

function getProgram(x,y)
	for k,v in pairs(objCoords) do
		local px, py, pex, pey = v[1],v[2],v[3],v[4]
		if x >= px and y >= py and x <= pex and y <= pey then
			return objectsDesktop[k][1], objectsDesktop[k][2]
		end
	end
end

local function homeSettings()
	local menu = {
		"Add app",
		"Remove app",
	}
	while true do
		local _, id = sPhone.menu(menu,"Home+","X")
		if id == 0 then
			break
		elseif id == 1 then
			local function redraw()
				term.setBackgroundColor(sPhone.theme["backgroundColor"])
				term.setTextColor(sPhone.theme["text"])
				term.clear()
				sPhone.header("Home+: Add","X")
				for k,v in pairs(iconPos) do
					paintutils.drawFilledBox(v[1],v[2]+1,v[3],v[4]+1,colors.red)
				end
				for k, v in pairs(objCoords) do
					paintutils.drawFilledBox(v[1],v[2]+1,v[3],v[4]+1,colors.lime)
				end
			end
			
			redraw()
			local w, h = term.getSize()
			while true do
				redraw()
				local _,_,x,y = os.pullEvent("mouse_click")
				if y == 1 and x == w then
					break
				else
					local a = getProgram(x-1,y-1)
					if not a then
						for k, v in pairs(iconPos) do
							if (x >= v[1] and y >= v[2]) and (x <= v[3] and y <= v[4]) then
								local iconPoss = k
								term.setBackgroundColor(sPhone.theme["backgroundColor"])
								term.setTextColor(sPhone.theme["text"])
								term.clear()
								sPhone.header("Home+: Add")
								term.setCursorPos(1,3)
								visum.align("center","  Path",false,3)
								visum.align("center","  (Blank to cancel)",false,4)
								term.setCursorPos(2,6)
								write("/")
								local path = read()
								if path ~= "" then
									if not fs.exists("/"..path) then
										sPhone.winOk("App not found")
										return
									else
										visum.align("center","  Name",false,8)
										term.setCursorPos(2,10)
										local name = read()
										local f = fs.open("/.sPhone/config/homeplus/icons","r")
										local ics = textutils.unserialise(f.readAll())
										f.close()
										ics[iconPoss] = {name,path}
										objectsDesktop[iconPoss] = {name,path}
										local f = fs.open("/.sPhone/config/homeplus/icons","w")
										f.write(textutils.serialize(ics))
										f.close()
										sPhone.winOk("Done!")
									end
								end
								break
							end
						end
					end
				end
			end
			break
		elseif id == 2 then
			local function redraw()
				term.setBackgroundColor(sPhone.theme["backgroundColor"])
				term.setTextColor(sPhone.theme["text"])
				term.clear()
				sPhone.header("Home+: Remove","X")
				for k,v in pairs(iconPos) do
					paintutils.drawFilledBox(v[1],v[2]+1,v[3],v[4]+1,colors.red)
				end
				for k, v in pairs(objCoords) do
					paintutils.drawFilledBox(v[1],v[2]+1,v[3],v[4]+1,colors.lime)
				end
			end
			
			redraw()
			local w, h = term.getSize()
			while true do
				redraw()
				local _,_,x,y = os.pullEvent("mouse_click")
				if y == 1 and x == w then
					break
				else
					local a = getProgram(x-1,y-1)
					if a then
						for k, v in pairs(iconPos) do
							if (x >= v[1] and y >= v[2]) and (x <= v[3] and y <= v[4]) then
								local iconPoss = k
								term.setBackgroundColor(sPhone.theme["backgroundColor"])
								term.setTextColor(sPhone.theme["text"])
								term.clear()
								local f = fs.open("/.sPhone/config/homeplus/icons","r")
								local ics = textutils.unserialise(f.readAll())
								f.close()
								ics[iconPoss] = nil
								objectsDesktop[iconPoss] = nil
								local f = fs.open("/.sPhone/config/homeplus/icons","w")
								f.write(textutils.serialize(ics))
								f.close()
								sPhone.winOk("Done!")
							end
						end
					end
				end
			end
			break
		end
	end
end

local function footer()
	local menu = {
		"Settings",
		"Home+ Settings",
		"Lock",
		"Info",
		"Shutdown",
		"Reboot",
	}
	
	while true do
		local name, id = sPhone.menu(menu,"Home","V")
		if id == 0 then
			break
		elseif id == 1 then
			shell.run("/.sPhone/apps/system/settings")
			break
		elseif id == 2 then
			homeSettings()
		elseif id == 3 then
			sPhone.login()
			break
		elseif id == 4 then
			shell.run("/.sPhone/apps/system/info")
			break
		elseif id == 5 then
			os.shutdown()
		elseif id == 6 then
			os.reboot()
		end
	end
end

local function redraw()
	term.setBackgroundColor(sPhone.getTheme("backgroundColor"))
	term.setTextColor(sPhone.getTheme("text"))
	term.clear()
	term.setCursorPos(1,1)
	for k, v in pairs(objectsDesktop) do
		local x, y,endx,endy = getCoords(k)
		objCoords[k] = {x,y,endx,endy}
		local icon = paintutils.loadImage("/.sPhone/apps/homeplus/shellIcon")
		paintutils.drawImage(icon,x,y)
		if #v[1] > 5 then
			term.setCursorPos(endx-3,endy+1)
			name = string.sub(objectsDesktop[k][1],1,5)
			sndName = string.sub(objectsDesktop[k][1],6,(10 or #v[1]))
		else
			name = objectsDesktop[k][1]
			term.setCursorPos(endx-3,endy+1)
		end
		term.setBackgroundColour(colors.white)
		write(name)
		if sndName then
			term.setCursorPos(endx-3,endy+2)
			write(sndName)
		end
	end
	local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()local w,h = term.getSize()
	paintutils.drawLine(1,h,w,h,sPhone.getTheme("header"))
	term.setTextColor(sPhone.getTheme("headerText"))
	term.setCursorPos(12,h)
	write("====")
	term.setCursorPos(w-3,h)
	write("^^^")
	term.setCursorPos(w-6,h)
	write("S")
end

local function main()
	while true do
		redraw()
		local ev = {os.pullEvent()}
		if ev[1] == "key" and ev[2] == keys.leftAlt then
			sPhone.inHome = false
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			term.clear()
			term.setCursorPos(1,1)
			sleep(0.1)
			shell.run("/rom/programs/shell")
			sPhone.inHome = true
		elseif ev[1] == "mouse_click" then
			local x, y = ev[3], ev[4]
			local w,h = term.getSize()
			if y == h then
				if x >= 12 and x <= 15 then
					sPhone.inHome = false
					sleep(0.1)
					shell.run("/.sPhone/apps/appList")
					sPhone.inHome = true
				elseif x == w-6 then
					sPhone.inHome = false
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.white)
					term.clear()
					term.setCursorPos(1,1)
					sleep(0.1)
					shell.run("/.sPhone/apps/store")
					sPhone.inHome = true
				elseif x <= w-1 and x >= w-3 then
					sPhone.inHome = false
					footer()
					sPhone.inHome = true
				end
			else
				local appName, appPath = getProgram(x,y)
				if appName then
					if fs.exists(appPath) then
						sPhone.inHome = false
						term.setBackgroundColor(colors.black)
						term.setTextColor(colors.white)
						term.clear()
						term.setCursorPos(1,1)
						sleep(0.1)
						shell.run(appPath)
						sPhone.inHome = true
					end
				end
			end
		end
	end
end

local function clockUpdate()
	local w,h = term.getSize()
	while true do
		if sPhone.inHome then
			term.setCursorBlink(false)
			term.setBackgroundColor(sPhone.theme["header"])
			term.setTextColor(sPhone.theme["headerText"])
			term.setCursorPos(1,h)
			write("      ")
			term.setCursorPos(1,h)
			write(" "..textutils.formatTime(os.time(),true))
		end
		sleep(0)
	end
end

parallel.waitForAll(main,clockUpdate)

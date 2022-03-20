local chatbox = peripheral.find("chatBox")
local prefix = "!"
local userinput = true

local vote = 0

local function split(s, delim)
	local delim = delim or " "
	local t = {}
	for k, _ in s:gmatch("([^"..delim.."]+)") do
		table.insert(t, k)
	end
	return t
end

function startswith(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

local function containsValue(a, b)	
	for _, i in pairs(a) do
		if i == b then
			return true
		end
	end
	return false
end

local function sendMsg(msg, user, isJson)
	local sec = string.char(167)
	local chatprefix = "%s9ChatBot$sr"

	msg = msg:gsub("&", sec)
	
	if isJson then
		chatbox.sendFormattedMessage(msg, chatprefix)
	elseif user then
		chatbox.sendMessageToPlayer(msg, user, chatprefix)
	else
		chatbox.sendMessage(msg, chatprefix)
	end
end

local function splice(tbl, first, last)
	return {table.unpack(tbl, first, last)}
end

local function doCommand(commandsTable, user, prefix, cmdname, ...)
	local cmd = commandsTable[cmdname]
	--check if user is allowed to use command
	local owners = {
		"1f6a10f6-b3e1-43f6-92f8-4bf562248aae" --"TheStraying11"
	}
	local owner = false

	local admins = {
		"bc1578e3-0f8b-4adf-8549-308f7c2aaf92", --"Moistman42"
		"dfbe3ee2-042d-46b4-8f2c-55a014e3ff2f" --"MudkipMafia"
	}
	local admin = false
	
	local allowed = false
	
	if containsValue(owners, user) then
		owner = true
		admin = true
	elseif containsValue(admins, user) then
		admin = true
	end
	
	if cmd.permissionLevel == "user" then
		if userinput then
			allowed = true
		elseif admin then
			allowed = true
		else
			sendMsg("&aSorry, user input is disabled")
		end
	elseif cmd.permissionLevel == "admin" then
		if admin then
			allowed = true
		else
			sendMsg("&aSorry, you must be a ChatBot administrator to use this command", user)
		end
	end 
	
	if allowed then
		local status, r = pcall(
			cmd.func, user, ...
		)
		
		if not status then
			sendMsg("&aCommand Error", user)
			print(r)
		end
	end
end

local descriptions = {}

local commands = {
	help = {
		func = function(user)
			sendMsg("{\"text\": \"&3&lClick Here\",\"clickEvent\":{\"action\":\"open_url\",\"value\":\"https://pastebin.com/4Pge1v6d\"}, \"_comment\": \"", nil, true)
		end,
		permissionLevel = "user"
	},
	ping = {
		func = function(user)
			sendMsg("&aPong.")
		end,
		desc = "&a{command}: replies with 'Pong.'",
		permissionLevel = "user"
	},
	roll = {
		func = function(user, min, max)
			min = min or 100
			if max == nil then
			    max = min
				min = 0
			end
			math.randomseed(os.epoch("utc"))
			sendMsg("&a"..tostring(math.random(min, max)))
		end,
		desc = "&a{command}: rolls a dice, {command} max, {command} min max, or {command} (rolls 0, 100 by default)",
		permissionLevel = "user"
	},
	flip = {
		func = function(user)
		    local coin
			math.randomseed(os.epoch("utc"))
			if math.random(1, 100) <= 50 then
			    coin = "&aHeads"
			else
				coin = "&aTails" 
			end
			sendMsg(coin)
		end,
		desc = "&a{command}: flips a coin",
		permissionLevel = "user"
	},
	funny = {
		func = function(user, joke)
            local jokestxt = fs.open("jokes.txt", "r")
            local jokes = {}
			local i
			for i = 1, 1534, 1 do
			    table.insert(jokes, jokestxt.readLine())
            end
			jokestxt.close()
			math.randomseed(os.epoch("utc"))
		    joke = joke or math.random(1, #jokes)
			sendMsg("&aJoke Number "..tostring(joke)..": "..(jokes[tonumber(joke)] or "Sorry, joke not found"))
        end,
        desc = "&a{command}: replies with a joke, ({command} number gives specific joke [between 1 and 1534])",
        permissionLevel = "user"
    },
	toggleInput = {
		func = function(user)
			userinput =  (not userinput)
			if userinput then
				sendMsg("&aUser Input Enabled")
			else
				sendMsg("&aUser Input Disabled")
			end	
		end,
		permissionLevel = "admin"
	}
}

while true do
	local event, user, msg, uuid = os.pullEvent("chat")
	local cmd = split(msg)

	cmd = {cmd[1]:sub(1, 1), cmd[1]:sub(2, #cmd[1]), unpack(cmd, 2, #cmd)}

	if cmd[1] ~= prefix then
		cmd = {cmd[1]..cmd[2], unpack(cmd, 3, #cmd)}
	end

	term.write(user..": [")
	for _, v in pairs(splice(cmd, 1, #cmd-1)) do
		term.write("\""..v.."\""..", ")
	end
	print("\""..cmd[#cmd].."\"".."]")


	if cmd[1] == prefix  and commands[cmd[2]] ~= nil then
		doCommand(commands, uuid, unpack(cmd))
	end
end

dofile("json")
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

local function sendMsg(msg, user)
	sec = string.char(167)
	msg = msg:gsub("&", sec)
	user = user or "@a"
	commands.exec(
		string.format(
			"/tellraw %s {\"text\": \"%s9[ChatBot]%sr: %s\"}",
			user,
			sec,
			sec,
			msg
		)
	)
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
			sendMsg("&3&lClick Here\",\"clickEvent\":{\"action\":\"open_url\",\"value\":\"https://pastebin.com/4Pge1v6d\"}, \"_comment\": \"")
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
	discord = {
		func = function(user)
			sendMsg("&3&lClick Here\",\"clickEvent\":{\"action\":\"open_url\",\"value\":\"https://discord.gg/rMyARmpmV5\"}, \"_comment\": \"")
		end,
		desc = "&a{command}: replies with a clickable link for the discord",
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
	},
	--[[vote = {
		func = function(user, votetype)
			s, d = commands.exec("/list")
			players = {}
			for k, v in pairs(splice(d, 2, #d)) do
				for _, i in pairs(split(v, ", ")) do
					print(i)
					table.insert(players, i)
				end
			end
			local votetypes = {
				"day", 
				"night",
				"dawn",
				"dusk",
				"restart",
				"toggledownfall"
			}
			if not containsValue(votetypes, votetype) then
				sendMsg("&aSorry, vote type "..votetype.." is invalid, vote types are: "..table.concat(votetypes, ", "), user)
			else
				local percentage = 1

				if vote == 0 then
					sendMsg("Starting vote for: "..votetype.." "..#players.." votes needed.")
				end
				
				vote = vote + 1

				if vote == #players then
					vote = 0
					if votetype == "day" then
						sendMsg("Vote threshold passed, Running command '/time set day'")
						commands.exec("time set day")
					elseif votetype == "night" then
						sendMsg("Vote threshold passed, Running command '/time set night'")
						commands.exec("time set night")
					elseif votetype == "dusk" then
						sendMsg("Vote threshold passed, Running command '/time set 12000'")
						commands.exec("time set 12000")
					elseif votetype	== "dawn" then
						sendMsg("Vote threshold passed, Running command '/time set 23000'")
						commands.exec("time set 23000")
					elseif votetype == "restart" then
						sendMsg("Vote threshold passed, Running command '/restart'")
						commands.exec("restart")
					elseif votetype == "toggledownfall" then
						sendMsg("Vote threshold passed, Running command '/toggledownfall'")
						commands.exec("toggledownfall")
					end
				end
			end
		end,
		desc = "&a{command}: vote for various things, ({command} [day, night, dawn, dusk, restart, toggledownfall])",
		permissionLevel = "user"
	},
	breedChain = {
		func = function(user, p1, p2, full)
			local url = string.format("http://www.studiolucia.uk/api/eggpath?p1=%s&p2=%s", p1, p2)
			local res = http.get(url)
			local j = decode(res.readAll())
			local paths = j['raw']
			local paste = j['paste']
			local msg
		
			if full ~= nil then
				msg = string.format("&3&lClick Here\",\"clickEvent\":{\"action\":\"open_url\",\"value\":\"%s\"}, \"_comment\": \"", paste)
				sendMsg(msg, user)
			else
				if type(paths[1]) == "table" then
					msg = "&aBreeding Chain: "..paths[1]
				else
					msg = "&aCommand Error: "
					if paths[1]:find("cannot be reached") then
						msg = msg.."No chain found, can both pokemon breed?"
					elseif paths[1]:find("not in G") then
						msg = msg.."One or more pokemon cannot be found, are they spelled correctly?"
					else
						msg = msg.."Unknown"
					end
				end
				sendMsg(msg, user)
			end
		end,
		desc = "&a{command}: Check a breeding chain, i.e. to get IVs from chikorita to dratini, see \"{command} chikorita dratini\", {command} pokemon1 pokemon2, or {command} pokemon1 pokemon2 all (shows all chains instead of just the first one)",
		permissionLevel	= "user"
	}--]]
}

while true do
	local event, user, msg, uuid = os.pullEvent("chat_message")
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

admins = { --there should be an easier way to do this by simply grabbing the list of admins from an ACL https://godoc.org/layeh.com/gumble/gumble#ACLGroup I think the pertinent method is UserAdd?
"wolsne",
"pizza_fart",
"CaptainZidgel",
"Antecedent",
"Slicerogue",
"Okiewaka",
"YungSally",
"Console-",
"Dale",
"dave2"
}

piepan.On("connect", function()
	print("Connection Established Successfully. Awaiting Commands...")
	root = piepan.Channels[0]			--lua indexes at 1, but GO indexes at 0 so all gumble objects will index at 0.
	addup = root:Find("Inhouse Pugs (Nut City)", "Add Up")
	fatkids = root:Find("Inhouse Pugs (Nut City)", "Add Up", "Fat Kids")
	spacebase = root:Find("Inhouse Pugs (Nut City)", "Poopy Joes Space Base")
	connectlobby = root:Find("Inhouse Pugs (Nut City)", "Connection Lobby")
	piepan.Self:Move(spacebase)
	players = {}
	for _,u in piepan:Users() do
		print("Found " .. u.Name .. ", listing in players table.")
		players[u.Name:lower()] = {
		isHere = true, 
		medicImmunity = false,
		object = u,
		lastChannel = u.Channel,
		dontUpdate = false
		} --generate them
	end
	channelTable = {
		room1 = {
			red = {
				object = addup:Find("Pug Server 1", "Red"),
				length = #addup:Find("Pug Server 1", "Red").Users
			},
			blu = {
				object = addup:Find("Pug Server 1", "Blu"),
				length = #addup:Find("Pug Server 1", "Blu").Users
			}
		},
		room2 = {
			red = {
				object = addup:Find("Pug Server 2", "Red"),
				length = #addup:Find("Pug Server 2", "Red").Users
			},
			blu = {
				object = addup:Find("Pug Server 2", "Blu"),
				length = #addup:Find("Pug Server 2", "Blu").Users
			}
		},
		room3 = {
			red = {
				object = addup:Find("Pug Server 3", "Red"),
				length = #addup:Find("Pug Server 3", "Red").Users
			},
			blu = {
				object = addup:Find("Pug Server 3", "Blu"),
				length = #addup:Find("Pug Server 3", "Blu").Users
			}
		}
	}
end)

function senderIsAdmin(s)
	for i,v in ipairs(admins) do
		if v:lower() == s.Name:lower() and s:IsRegistered() then --case insensitive, make sure user is registered for safety
			return true
		end
	end
end

function generateUsersAlpha()
	usersAlpha = {}							--if the users table is empty, generate it
	for _,u in addup:Users() do				--iterates on all users added up, "u" is one user
		table.insert(usersAlpha, u.Name:lower())	--places them into table
	end					
	table.sort(usersAlpha)
end

function randomTable(n)
	math.randomseed(os.time())
	local t = {}
	for i = 1, n, 1 do
		table.insert(t, i)
	end
	local r, tmp
	for i = 1, #t do			--for every item in table
		r = math.random(i, #t)	--r becomes a random number that is the length of ordered or less
		tmp = t[i]				--tmp var stores the ith value of ordered
		t[i] = t[r]		--the ith space of ordered is replaced with the rth item
		t[r] = tmp				--the rth item becomes the ith item. graph: https://imgur.com/a/6pnEMRf
	end
	return t
end

function roll(t)
	print("Trying to get a new medic pick...")
	local i = 1
	local userTesting
	local c1, c2, c3 = channelTable.room1, channelTable.room2, channelTable.room3
	if c1.red.length + c1.blu.length >= 2 then
		if c2.red.length + c2.blu.length >= 2 then
			if c3.red.length + c3.blu.length >= 2 then
				addup:Send("You can't roll, there are already medics.", true)
				print("Someone tried to roll but was denied due to sufficient players.")
				return
			end	
		end		
	end
	while true do
		if i > #addup.Users then		--if iterations surpasses the number of users added up
			print("Run out of people to test")
			addup:Send("Hey uh I think everyone here has played Medic? Not sure though, I might be coded wrong. Do a double check, and if you need to do a medic reset just have an admin do !clearmh", true)
			return
		else
			userTesting = usersAlpha[t[i]]:lower()
			if players[userTesting].medicImmunity == true then
				print(userTesting .. " has immunity, continuing...")
				i = i + 1
			elseif players[userTesting].medicImmunity == false then
				print(userTesting .. " doesn't have immunity, breaking loop.")
				break
			end
		end
	end
	print("Selecting medic: " .. userTesting)
	addup:Send("Medic: " .. userTesting .. " (" .. t[i] .. ")", true)
	local user = players[userTesting]
	user.medicImmunity = true
	if c1.red.length + c1.blu.length < 2 then
		local red = c1.red
		local blu = c1.blu
		print("Moving: " .. user.object.Name)
		if red.length <= 0 then
			user.object:Move(red.object)
			red.length = red.length + 1
			user.dontUpdate = true
		elseif blu.length <= 0 then
			user.object:Move(blu.object)
			blu.length = blu.length + 1
			user.dontUpdate = true
		end
	elseif c2.red.length + c2.blu.length < 2 then
		local red = c2.red
		local blu = c2.blu
		print("Moving: " .. user.object.Name)
		if red.length <= 0 then
			user.object:Move(red.object)
			red.length = red.length + 1
			user.dontUpdate = true
		elseif blu.length <= 0 then
			user.object:Move(blu.object)
			blu.length = blu.length + 1
			user.dontUpdate = true
		end
	elseif c3.red.length + c3.blu.length < 2 then
		local red = c3.red.object
		local blu = c3.blu.object
		print("Moving: " .. user.object.Name)
		if red.length <= 0 then
			user.object:Move(red.object)
			red.length = red.length + 1
			user.dontUpdate = true
		elseif blu.length <= 0 then
			user.object:Move(blu.object)
			blu.length = blu.length + 1
			user.dontUpdate = true
		end
	end
	return
end

piepan.On("message", function(m)
	if m.sender == nil then
		return
	else
		print("MSG RECIEVED: " .. m.Sender.Name .. ": " .. m.Message)
		if m.Message:lower() == "!help" then
			m.Sender:Send("<br />All Registered Users:<br />!help - This context menu<br />!name - Prints your name<br />!pmh - View list of past medics<br /><br />Administrators:<br />!roll - Rolls 2 Medics<br />!cdump 1 - Moves all users from Red/Blu Server 1 Channels to Add-Up<br />!clearmh - Clear past medics")
		end
		if m.Message:lower() == "!name" then
			m.Sender.Channel:Send("Your name is " .. m.Sender.Name .. "!", false)
		end
		if m.Message:lower() == "!pmh" then
			for n,u in pairs(players) do
				if u.medicImmunity then
					m.Sender:Send(n)
				end
			end
		end
		if string.find(m.Message:lower(), "!volunteer", 1) == 1 then	--"!volunteer red 1"
			if m.Sender.Channel == addup or m.Sender.Channel == fatkids then
				local team = m.Message:sub(12, 14)
				local room = tonumber(m.Message:sub(16, 16))
				if room == 1 then room = channelTable.room1 elseif room == 2 then room = channelTable.room2 elseif room == 3 then room = channelTable.room3 end
				if room.red.length + room.blu.length < 3 then
					if team == "red" then
						team = room.red.object
					elseif team == "blu" then
						team = room.blu.object
					end			
					addup:Send(m.Sender.Name .. " has volunteered as medic!", true)
					for _,u in team:Users() do
						players[u.Name:lower()].medicImmunity = false
						u:Move(addup)
					end
					m.Sender:Move(team)
					players[m.Sender.Name:lower()].medicImmunity = true
				else
					addup:Send("Sorry, you can't volunteer for medic since picks have already begun!", false)
				end
			else
				m.Sender:Send("You can't volunteer! You're already medic!")
			end
		end
		if senderIsAdmin(m.sender) then
			if string.find(m.Message:lower(), "!cdump ", 1) == 1 then
				local cnl = tonumber(m.Message:sub(8))
				local room
				if cnl == 1 then
					room = channelTable.room1
				elseif cnl == 2 then
					room = channelTable.room2
				elseif cnl == 3 then
					room = channelTable.room3
				end
				m.Sender.Channel:Send("Attempting to dump channels...", true)
				local red = room.red.object
				local blu = room.blu.object
				for _,u in red:Users() do -- "u" is one user
					u:Move(addup)
				end
				for _,u in blu:Users() do
					u:Move(addup)
				end
				addup:Send("Channel " .. cnl .. " dumped by " .. m.Sender.Name, true)
				red:Link(addup)
				blu:Link(addup)
				--room.red.length, room.blu.length = 0,0
			end
			if string.find(m.Message:lower(), "!roll", 1) == 1 then	
				if #addup.Users + #fatkids.Users < 1 then
					addup:Send("Sorry, there are not enough players to do this pug.", true)
				else
					generateUsersAlpha()
					local toRoll
					if #m.Message < 7 then
						toRoll = 2
					else
						toRoll = tonumber(m.Message:sub(7))
					end
					while toRoll > 0 do
						roll(randomTable(#addup.Users))
						toRoll = toRoll - 1
					end
					addup:Send("Rolled by " .. m.Sender.Name, true)
				end
			end
			if m.Message == "!clearmh" then	--clears medic history
				for k,v in pairs(players) do
					v.medicImmunity = false
				end
				m.Sender.Channel:Send("Medic history cleared by " .. m.Sender.Name, true)
			end
			if string.find(m.Message, "!massadd", 1) == 1 then		--massively add users to med immunity, separated by comma. big boy bandaid.
				local s = m.Message:sub(10)
				for match in (s..','):gmatch("(.-)"..',') do
					players[match:lower()].medicImmunity = true
					print(match:lower() .. " now has medic immunity " .. tostring(players[match:lower()].medicImmunity))
				end
			end	
			if string.find(m.Message:lower(), "!strike", 1) == 1 then
				local player = m.Message:sub(9)
				players[player].medicImmunity = false
				print(m.Sender.Name .. " strikes " .. player)
				addup:Send(m.Sender.Name .. " strikes " .. player .. " from Medic history", true)
			end
			if string.find(m.Message:lower(), "!ami", 1) == 1 then
				local player = m.Message:sub(6)
				players[player].medicImmunity = true
				print(m.Sender.Name .. " gives medic immunity to " .. player)
				addup:Send(m.Sender.Name .. " has given " .. player .. " medic immunity!", true)
			end
			if m.Message == "update" then
				channelTable.room1.red.length, channelTable.room1.blu.length = #addup:Find("Pug Server 1", "Red").Users, #addup:Find("Pug Server 1", "Blu").Users
				channelTable.room2.red.length, channelTable.room2.blu.length = #addup:Find("Pug Server 2", "Red").Users, #addup:Find("Pug Server 2", "Blu").Users
				channelTable.room3.red.length, channelTable.room3.blu.length = #addup:Find("Pug Server 3", "Red").Users, #addup:Find("Pug Server 3", "Blu").Users
			end
			if string.find(m.Message:lower(), "!rng ", 1) == 1 then
				local n1, n2 = m.Message:sub(6, 6), m.Message:sub(8)
				math.randomseed(os.time())
				m.Sender.Channel:Send(tostring(math.random(tonumber(n1), tonumber(n2))), true)
			end
		end
	end
end)

piepan.On("userchange", function(u) --userchange has to be lowercase
	if u.IsConnected then			--a user connection event
		print(u.User.Name .. " has connected")
		connectlobby:Send("Hello " .. u.User.Name, true)--u.User is the user who triggered the event
		local individual = u.User.Name:lower()			--user 'individual' has the name of the connected user in all lowercase
		if players[individual] == nil then				--if user is not saved to the table
			players[individual] = {
			isHere = true,
			medicImmunity = false, 
			object = u.User,
			lastChannel = u.Channel,
			dontUpdate = false
			} --generate them
		else
			players[individual].isHere = true			--otherwise, modify table (Don't clear med immunity)
			players[individual].object = u.User	
		end
	end
	if u.IsDisconnected then							--a user disconnect event
		print(u.User.Name .. " has disconnected.")
		local individual = u.User.Name:lower()
		players[individual].isHere = false				--this user is no longer here
	end
	if u.IsChangeChannel then
		local o = players[u.User.Name:lower()]
		if o.dontUpdate == false then
			local lC = o.lastChannel
			local ct = channelTable
			if u.User.Channel == channelTable.room1.red.object then
				channelTable.room1.red.length = channelTable.room1.red.length + 1
			elseif u.User.Channel == channelTable.room1.blu.object then
				channelTable.room1.blu.length = channelTable.room1.blu.length + 1
			elseif u.User.Channel == channelTable.room2.red.object then
				channelTable.room2.red.length = channelTable.room2.red.length + 1
			elseif u.User.Channel == channelTable.room2.blu.object then
				channelTable.room2.blu.length = channelTable.room2.blu.length + 1
			else
				if lC == ct.room1.red.object then
					ct.room1.red.length = ct.room1.red.length - 1
				elseif lC == ct.room2.red.object then
					ct.room2.red.length = ct.room2.red.length - 1
				elseif lC == ct.room1.blu.object then
					ct.room1.blu.length = ct.room1.blu.length - 1
				elseif lC == ct.room2.blu.object then
					ct.room2.blu.length = ct.room2.blu.length - 1
				end
			end
		else
			o.dontUpdate = false
		end
		o.lastChannel = u.User.Channel
		print(channelTable.room1.red.length)
	end
end)
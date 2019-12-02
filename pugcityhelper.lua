admins = { --there should be an easier way to do this by simply grabbing the list of admins from an ACL https://godoc.org/layeh.com/gumble/gumble#ACLGroup I think the pertinent method is UserAdd?
"wolsne",
"pizza_fart",
"CaptainZidgel",
"Antecedent",
"Slicerogue",
"Okiewaka",
"YungSally",
"Console-",
"Dale"
}

piepan.On("connect", function()
	print("Connection Established Successfully. Awaiting Commands...")
	root = piepan.Channels[0]			--lua indexes at 1, but GO indexes at 0 so all gumble objects will index at 0.
	addup = root:Find("Inhouse Pugs (Nut City)", "Add Up")
	fatkids = root:Find("Inhouse Pugs (Nut City)", "Add Up", "Fat Kids")
	spacebase = root:Find("Inhouse Pugs (Nut City)", "Poopy Joes Space Base")
	pugroomone = root:Find("Inhouse Pugs (Nut City)", "Add Up", "Pug Server 1")
	connectlobby = root:Find("Inhouse Pugs (Nut City)", "Connection Lobby")
	piepan.Self:Move(spacebase)
	players = {}
	for _,u in piepan:Users() do
		print("Found " .. u.Name .. ", listing in players table.")
		players[u.Name:lower()] = {
		isHere = true, 
		medicImmunity = false,
		object = u
		} --generate them
	end
	channelLens = {
		redOneLen = 0,
		bluOneLen = 0
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
	players[userTesting].medicImmunity = true
	local c = channelLens
	if c.redOneLen + c.bluOneLen < 2 then
		local red = pugroomone:Find("Red")
		local blu = pugroomone:Find("Blu")
		print("Moving: " .. players[userTesting].object.Name)
		if c.redOneLen == 0 then
			players[userTesting].object:Move(red)
			c.redOneLen = c.redOneLen + 1
		else
			players[userTesting].object:Move(blu)
		end
	else
		print("Monkeynaut has crashed into CaptainZidgel's house and killed him")
	end
	
end

piepan.On("message", function(m)
	if m.sender == nil then
		return
	else
		if m.Message == "!help" then
			m.Sender:Send("<br />All Registered Users:<br />!help - This context menu<br />!name - Prints your name<br />!pmh - View list of past medics<br /><br />Administrators:<br />!roll - Rolls 2 Medics<br />!cdump 1 - Moves all users from Red/Blu Server 1 Channels to Add-Up<br />!clearmh - Clear past medics")
		end
		if m.Message == "!name" then
			m.Sender.Channel:Send("Your name is " .. m.Sender.Name .. "!", false)
		end
		if m.Message == "!pmh" then
			for n,u in pairs(players) do
				if u.medicImmunity then
					m.Sender.Channel:Send(n, false)
				end
			end
		end
		if senderIsAdmin(m.sender) then
			if string.find(m.Message, "!echo ", 1) == 1 then
				piepan.Self.Channel:Send(m.Message:sub(7), false)
			end
			if m.Message == "!cdump 1" then
				m.Sender.Channel:Send("Attempting to dump channels...", true)
				local red = pugroomone:Find("Red")
				local blu = pugroomone:Find("Blu")
				for _,u in red:Users() do -- "u" is one user
					u:Move(addup)
				end
				for _,u in blu:Users() do
					u:Move(addup)
				end
				addup:Send("Dumped by " .. m.Sender.Name, true)
				channelLens.redOneLen, channelLens.bluOneLen = 0, 0
			end
			if string.find(m.Message, "!roll", 1) == 1 then				  --Since there are no built-in command functions, if you want to use parameters you'll need to use substrings to identify pseudo-parameters.
				if #addup.Users + #fatkids.Users < 1 then --checks if there are enough players to play (piepan strictly only counts the number of users in a specific channel).
					addup:Send("Sorry, there are not enough players to do this pug.", true)
				else
					generateUsersAlpha()
					local toRoll
					if #m.Message < 7 then
						toRoll = 2
					else
						toRoll = tonumber(m.Message:sub(7))
					end
					local red = pugroomone:Find("Red")
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
				addup:Send("Medic history cleared by " .. m.Sender.Name, true)
			end
			if string.find(m.Message, "!strike", 1) == 1 then
				local player = m.Message:sub(9)
				players[player:lower()].medicImmunity = false
				addup:Send(m.Sender.Name .. " strikes " .. player .. " from Medic history", true)
			end
			if string.find(m.Message, "!ami", 1) == 1 then
				local player = m.Message:sub(6):lower()
				players[player].medicImmunity = true
				addup:Send(m.Sender.Name .. " has given " .. player .. " medic immunity!", true)
			end
			if m.Message == "!list" then
				for k,v in pairs(players) do
					print(k)
					print(v.medicImmunity)
				end
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
			players[individual] = {isHere = true, medicImmunity = false, object = u.User} --generate them
		else
			players[individual].isHere = true			--otherwise, modify table (Don't clear med immunity)
		end
	end
	if u.IsDisconnected then							--a user disconnect event
		print(u.User.Name .. " has disconnected.")
		local individual = u.User.Name:lower()
		players[individual].isHere = false				--this user is no longer here
	end
end)
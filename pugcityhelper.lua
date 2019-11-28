-- run this cmd from piepan dir: piepan -server="voice.enslow.me:42069" -username="BOT-Poopy-Joe" -certificate="pjcert.pem" -key="pjkey.pem"  pj\pugcityhelper.lua

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

usersAlpha = {}		--creates a table of users for use in alphabetizing
pastmedics = {}
needtoMed = {}

piepan.On("connect", function()
	print("Loaded Poopy Joe")
	root = piepan.Channels[0]
	addup = root:Find("Inhouse Pugs (Nut City)", "Add Up")
	fatkids = root:Find("Inhouse Pugs (Nut City)", "Add Up", "Fat Kids")
	mowing = root:Find("General", "mowing the lawn")
	spacebase = root:Find("Inhouse Pugs (Nut City)", "Poopy Joes Space Base")
	pugroomone = root:Find("Inhouse Pugs (Nut City)", "Add Up", "Pug Server 1")
	piepan.Self:Move(spacebase)
end)

function senderIsAdmin(s)
	for i,v in ipairs(admins) do
		if v:lower() == s.Name:lower() and s:IsRegistered() then --case insensitive, make sure user is registered for safety
			return true
		end
	end
end

function checkMedsHist(m) --we pass the Name to this param, not the User object
	for _,i in ipairs(pastmedics) do
		print(i)
		if i == m then
			return true
		end
	end
end

function roll()
	 usersAlpha = {}				--if the users table is empty, generate it
		for _,i in addup:Users() do			--iterates on all users added up
			table.insert(usersAlpha, i.Name)--places them into talbe
		end					
		table.sort(usersAlpha)
	
	math.randomseed(os.time())				--seed based on current second
	local n = math.random(1, #addup.Users)	--pick random player
	local u = usersAlpha[n]					--find player based on their position in an alphabetized list (the way mumble sorts users in a channel)
	for _,v in ipairs(pastmedics) do		--iterates on list of previous medics.
		if v:lower() == u:lower() then
			if #pastmedics < #addup.Users then
				return roll()
			else
				print("Something something something")
				break
			end
		end
	end
	print(tostring(n) .. " " .. u)
	table.insert(pastmedics, u)
	return n                                --returns the random number
end

piepan.On("userChange", function(u)
	if u.IsConnected then
		print("Connection")
	end
end)

piepan.On("message", function(m)
	if m.sender == nil then
		return
	else
		if m.Message == "!clearmh" then
			pastmedics = {}
		end
		if m.Message == "!dump" then
			for _,i in ipairs(pastmedics) do
				print(i)
			end
		end
		if m.Message == "!name" then
			m.Sender.Channel:Send("Your name is " .. m.Sender.Name .. "!", false)
		end
		if senderIsAdmin(m.sender) then
			if string.find(m.Message, "!echo ", 1) == 1 then
				piepan.Self.Channel:Send(m.Message:sub(7), false)
			end
			if string.find(m.Message, "!pick ", 1) == 1 then
				
			end
			if m.Message == "!iter" then
				for _,i in fatkids:Users() do
					print(i.Name)
					i:Move(addup)
				end
			end
			if m.Message == "!cdump 1" then
				m.Sender.Channel:Send("Attempting to dump channels...", true)
				local red = pugroomone:Find("Red")
				local blu = pugroomone:Find("Blu")
				for _,i in red:Users() do
					i:Move(addup)
				end
				for _,i in blu:Users() do
					i:Move(addup)
				end
				addup:Send("Dumped by " .. m.Sender.Name, true)
			end
			if m.Message == "!roll" then
				local n1 = roll()
				local n2 = roll()
				redMed = usersAlpha[n1]
				bluMed = usersAlpha[n2]
				addup:Send("Medics are " .. redMed .. " (" .. n1 .. ") and " .. bluMed .. " (" .. n2 .. ")", true) --sends the number and name of the Medics to addup channel.
				addup:Send("Rolled by " .. m.Sender.Name, true)
			end
			if m.Message == "archived!roll" then
				if #addup.Users + #fatkids.Users < 1 then --checks if there are enough players to play (While Mumble counts users in a channel with children included, piepan strictly only counts the number of users in a specific channel. This is helpful).
					addup:Send("Sorry, there are not enough players to do this pug.", true)
				else
					--for _,i in ipairs(usersAlpha) do print(i) end
					math.randomseed(os.time())			--seeds a new random number based on the current second
					local _random = tostring(math.random(1, #addup.Users)) --picks a random int from 1 to the number of users in addup channel
					local _random2 = tostring(math.random(1, #addup.Users))
					while _random2 == _random do							--if number 1 and number 2 are the same, reroll until we get a unique number
						_random2 = tostring(math.random(1, #addup.Users))
					end
					redMed = usersAlpha[tonumber(_random)]
					bluMed = usersAlpha[tonumber(_random2)]
					while checkMedsHist(redMed) do					--when this line is executed, if the condition is met the loop will begin and continue until it is not met, if the condition is not met, the loop will not happen (If I understand while loops correctly)
						local n = _random
						addup:Send("Rolled a dupe, rerolling", true)
						while (_random == n) or (_random == _random2) do
							_random = tostring(math.random(1, #addup.Users))
						end
					end
					while checkMedsHist(blueMed) do
						local n = _random2
						addup:Send("Rolled a dupe, rerolling", true)
						while (_random2 == n) or (_random2 == _random) do
							_random2 = tostring(math.random(1, #addup.Users))
						end
					end
					table.insert(pastmedics, redMed)
					table.insert(pastmedics, bluMed)
					addup:Send(_random .. " " .. _random2, true)			--sends the numbers in plaintext (debugging)
					addup:Send("Medics are " .. redMed .. " (" .. _random .. ") and " .. bluMed .. " (" .. _random2 .. ")", true) --sends the number and name of the Medics to addup channel.
					addup:Send("Rolled by " .. m.Sender.Name, true)
					
					
				end
			end
			if m.Message == "!s" then
				for i,c in piepan.Channels() do
					print(c.Name .. " " .. c.ID)
				end
			end
			if m.Message == "!move" then
				m.Sender:Move(addup)
			end
		end
	end
end)
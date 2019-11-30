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

--inspect = require 'lib.inspect'

--usersAlpha = {}		--creates a table of users for use in alphabetizing
pastmedics = {}

piepan.On("connect", function()
	print("Loaded Poopy Joe")
	root = piepan.Channels[0]			--lua indexes at 1, but GO indexes at 0 so all gumble objects will index at 0.
	addup = root:Find("Inhouse Pugs (Nut City)", "Add Up")
	fatkids = root:Find("Inhouse Pugs (Nut City)", "Add Up", "Fat Kids")
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

function generateUsersAlpha()
	usersAlpha = {}							--if the users table is empty, generate it
	for _,u in addup:Users() do				--iterates on all users added up, "u" is one user
		table.insert(usersAlpha, u.Name:lower())	--places them into table
	end					
	table.sort(usersAlpha)
end

function randomTable(n)
	math.randomseed(os.time())
	local ordered = {}			--ignore the name. just pretend it says "table". by the end of this, the "ordered" table will be completely random.
	for i = 1, n, 1 do
		table.insert(ordered, i)
	end
	local r, tmp
	for i = 1, #ordered do			--for every item in ordered table
		r = math.random(i, #ordered)--r becomes a random number that is the length of ordered or less
		tmp = ordered[i]			--tmp var stores the ith value of ordered
		ordered[i] = ordered[r]		--the ith space of ordered is replaced with the rth item
		ordered[r] = tmp			--the rth item becomes the ith item. graph: https://imgur.com/a/6pnEMRf
	end
	return ordered
end

function roll(t)
	print("Trying to get a new medic pick...")
	local i = 1
	local userTesting
	while true do
		local s = i						--the starting 'i' value, i use this to sense if i changes during a loop 
		userTesting = usersAlpha[t[i]]:lower()
		if #pastmedics >= #addup.Users then
			print("Run out of people to test")
			addup:Send("Hey uh I think everyone here has played Medic? Not sure though, I might be coded wrong. Do a double check, and if you need to do a medic reset just have an admin do !clearmh", true)
			return
		else
			for _,p in ipairs(pastmedics) do
				print("Testing " .. userTesting .. " against " .. p)
				if p == userTesting then
					i = i + 1
					print('They match')
				end
			end
			if s == i then
				print("They didn't match")
				break
			end
		end
	end
	print("Continuing with medic picks... pick: " .. userTesting)
	addup:Send("Medic: " .. userTesting .. " (" .. t[i] .. ")", true)
	table.insert(pastmedics, userTesting:lower())
	return i                               --returns the random number
end

piepan.On("userChange", function(u)
	if u.IsConnected then --cant figure out how to get this to work. It would be nice to automatically add users to usersAlpha on connection, then we would only need to resort on each roll (instead of refinding the entire table), i.e. we could eliminate the for loop that's currently at line 47-49.
		print("Connection")
	end
end)

meds = {}	--current medics (no past meds)

piepan.On("message", function(m)
	if m.sender == nil then
		return
	else
		if m.Message == "!name" then
			m.Sender.Channel:Send("Your name is " .. m.Sender.Name .. "!", false)
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
			end
			if string.find(m.Message, "!roll", 1) == 1 then				  --piepan is not on par with discord bot libraries, so there is no sort of command feature to speak of. Since there are no built-in command functions, if you want to use parameters you'll need to use substrings to identify pseudo-parameters.
				if #addup.Users + #fatkids.Users < 1 then --checks if there are enough players to play (While Mumble counts users in a channel with children included, piepan strictly only counts the number of users in a specific channel. This is helpful).
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
					addup:Send("Rolled by " .. m.Sender.Name, true) --transparency logging
				end
			end
			if m.Message == "!s" then			--prints channels and their ids
				for i,c in piepan.Channels() do
					print(c.Name .. " " .. c.ID)
				end
			end
			if m.Message == "!clearmh" then	--clears medic history
				pastmedics = {}
				addup:Send("Medic history cleared by " .. m.Sender.Name, true)
			end
			if m.Message == "!pmh" then		--prints every past medic (for debugging purposes)
				for _,i in ipairs(pastmedics) do
					print(i)
				end
			end
			if m.Message == "!admins" then
				root:RequestACL()
			end
			
		end
	end
end)
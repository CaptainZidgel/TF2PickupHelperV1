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

function checkMedsHist(newmed) --we pass the Name to this param, not the User object
	for _,oldmedic in ipairs(pastmedics) do
		print(oldmedic)
		if oldmedic == newmed then
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
	for _,i in ipairs(usersAlpha) do
		print(i)
	end
end

function roll()
	math.randomseed(os.time())				--seed based on current second
	local n = math.random(1, #addup.Users)	--pick random player
	local userToTest = usersAlpha[n]		--find player based on their position in an alphabetized list (the way mumble sorts users in a channel)
	for _,pmedic in ipairs(pastmedics) do	--iterates on list of previous medics. pmedic is a previous medic --this whole loop needs to be rewritten i think, to be clear
		if pmedic:lower() == userToTest:lower() then
			if #pastmedics < #addup.Users - 1 then
				return roll()
			else
				print("Run out of players to test")
				break
			end
		end
	end
	--print(tostring(n) .. " " .. userToTest)
	addup:Send("Medic: " .. usersAlpha[n] .. " (" .. n .. ")", true)
	table.insert(pastmedics, userToTest)
	return n                                --returns the random number
end

--[[piepan.On("userChange", function(u)
	if u.IsConnected then --cant figure out how to get this to work. It would be nice to automatically add users to usersAlpha on connection, then we would only need to resort on each roll (instead of refinding the entire table), i.e. we could eliminate the for loop that's currently at line 47-49.
		print("Connection")
	end
end)]]--

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
					local toRoll = tonumber(m.Message:sub(7)) --this essentially gets the "first" parameter, which could be any number of characters
					while toRoll > 0 do
						roll()
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
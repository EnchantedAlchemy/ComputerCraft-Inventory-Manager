--Requires:
--Chatbox
--Chest above Computer
--Inventory Manager

local manager = peripheral.find("inventoryManager")
local owner = manager.getOwner()
local chatBox = peripheral.find("chatBox")
local chatBoxName = "Inventory Manager"
local takePeripheral = peripheral.find("minecraft:chest")
local takeName = peripheral.getName(takePeripheral)
local takeChest = "up"
local trash = "down"

print("\nType \"$help\" or \"$help (command name)\" for information.")

redstone.setOutput("bottom",false)

chatFunctions = {

	privateMessage = function(text, player)
		local chatMessage = {
			{text = "(Private) ", color = "gray", italic = true},
		}
		chatMessage[2] = text
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, player, chatBoxName)
	end

}

chatFunctions.privateMessage({text = "Finished Loading.", color = "aqua", bold = true}, owner)

functions = {

	take = function(commands)
	
		--No item given
		if commands[1] == nil or commands[1] == "" then
			chatFunctions.privateMessage({text = "Enter an item.", color = "red", bold = true}, owner)
			return
		end
	
		--Main command
		local desiredItem = string.lower(commands[1])
		local desiredQuantity = tonumber(commands[2])
		
		if desiredQuantity == nil or desiredQuantity < 1 then 
			desiredQuantity = 1 
		end
		
		if manager.getFreeSlot() ~= -1 then
		
			local item = ""
			for i,v in pairs(takePeripheral.list()) do
				if string.find(v.name, desiredItem) then
					if item == "" or string.len(v.name) < string.len(item) then
						item = v.name
					end
				end	
			end
		
			local value, value2 = manager.addItemToPlayer(takeChest, desiredQuantity, nil, item)
			--Successful
			if value > 0 and value2 == nil then
				chatFunctions.privateMessage({text = "Took "..value.." "..item..".", color = "green", bold = true}, owner)
			--Incorrect Command
			elseif value2 == "ITEM_NOT_FOUND" then
				chatFunctions.privateMessage({text = "Improper item name (mod:item_name)", color = "red", bold = true}, owner)
			--Chest does not have item
			elseif value2 == nil then
				chatFunctions.privateMessage({text = "Chest does not contain item.", color = "red", bold = true}, owner)
			--Other error
			else
				chatFunctions.privateMessage({text = "Error (Show Gamer):".. value2, color = "red", bold = true}, owner)
			end
		--No space in inventory
		else
			chatFunctions.privateMessage({text = "No empty space in inventory.", color = "red", bold = true}, owner)
		end
		
	end,
	
	store = function(commands)
	
		local desiredItem = manager.getItemInHand()
		local desiredQuantity = tonumber(commands[1])
		
		if desiredQuantity == nil or desiredQuantity < 1 then 
			desiredQuantity = desiredItem.count
		end
		
		if desiredItem.name ~= nil then
			local value, value2 = manager.removeItemFromPlayer(takeChest, desiredQuantity, nil, desiredItem.name)
			--Successful
			if value > 0 and value2 == nil then
				chatFunctions.privateMessage({text = "Stored "..value.." "..desiredItem.name..".", color = "green", bold = true}, owner)
			--No Chest
			elseif value2 == "INVENTORY_TO_INVALID" then
				chatFunctions.privateMessage({text = "No chest to store items.", color = "red", bold = true}, owner)
			--Chest has no storage
			elseif value == 0 then
				chatFunctions.privateMessage({text = "Chest is full.", color = "red", bold = true}, owner)
			--Other Error
			else
				chatFunctions.privateMessage({text = "Error (Show Gamer):".. value2, color = "red", bold = true}, owner)
			end
		--No item in hand
		else
			local chatMessage = {
				{text = "(Private) ", color = "gray", italic = true},
				{text = "No item in hand.", color = "red", bold = true}
			}
			chatMessage = textutils.serializeJSON(chatMessage)
			
			chatBox.sendFormattedMessageToPlayer(chatMessage, owner, chatBoxName)	
		end
		
	end,

	del = function(commands)
	
		local desiredItem = manager.getItemInHand()
		local desiredQuantity = tonumber(commands[1])
		
		if desiredQuantity == nil or desiredQuantity < 1 then 
			desiredQuantity = desiredItem.count
		end
		
		if desiredItem.name ~= nil then
			local value, value2 = manager.removeItemFromPlayer(trash, desiredQuantity, nil, desiredItem.name)
			--Successful
			if value > 0 and value2 == nil then
				chatFunctions.privateMessage({text = "Deleted "..value.." "..desiredItem.name..".", color = "green", bold = true}, owner)
				redstone.setOutput("bottom", false)
				os.sleep(0.05)
				redstone.setOutput("bottom", true)
				os.sleep(0.05)
				redstone.setOutput("bottom", false)
			--No Chest
			elseif value2 == "INVENTORY_TO_INVALID" then
				chatFunctions.privateMessage({text = "No trashcan.", color = "red", bold = true}, owner)
			--Chest has no storage
			elseif value == 0 then
				chatFunctions.privateMessage({text = "Trashcan is full?", color = "red", bold = true}, owner)
			--Other Error
			else
				chatFunctions.privateMessage({text = "Error (Show Gamer):".. value2, color = "red", bold = true}, owner)
			end
		--No item in hand
		else
			local chatMessage = {
				{text = "(Private) ", color = "gray", italic = true},
				{text = "No item in hand.", color = "red", bold = true}
			}
			chatMessage = textutils.serializeJSON(chatMessage)
			
			chatBox.sendFormattedMessageToPlayer(chatMessage, owner, chatBoxName)	
		end
		
	end,
	
	list = function(commands)
		message = "\n"
				
		local chatMessage = {
			{text = "\n"}
		}
		
		for i,v in pairs(takePeripheral.list()) do
			local textColor = "aqua"
			if i%2 == 0 then
				textColor = "white"
			end
			local slot = i
			if slot < 10 then slot = "0"..slot end
			chatMessage[#chatMessage+1] = {text = "[Slot "..slot.."] "..v.count.." "..v.name.."\n", color = textColor}
		end
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, owner, chatBoxName)
	end,

	help = function(commands)
		local argument = commands[1]
		local chatMessage = {}
		if argument == nil then
			argument = ""
		end
		
		if string.find(argument, "take") then
			chatMessage = {
				{text = "$take | ", color = "white"}, {text = "mod:item_name", color = "aqua"}, {text = " | ", color = "white"}, {text = "quantity\n", color = "yellow"},
				{text = "\nTakes one (or given amount) of the given item if it is in storage. Attempts to search for the nearest match to the given item name, eg. \"iron\" could find \"iron_ingot\".", color = "gray"}
			}
		elseif string.find(argument, "store") then
			chatMessage = {
				{text = "$store | ", color = "white"}, {text = "quantity\n", color = "yellow"},
				{text = "\nPuts held stack (or given amount) of items in storage.", color = "gray"}
			}
		elseif string.find(argument, "del") then
			chatMessage = {
				{text = "$del | ", color = "white"}, {text = "quantity\n", color = "yellow"},
				{text = "\nDELETES held stack (or given amount) of items.", color = "gray"}
			}	
		elseif string.find(argument, "list") then
			chatMessage = {
				{text = "$list\n", color = "white"},
				{text = "Lists all items in storage\n", color = "gray"},
			}				
		else --No command arg or invalid
			chatMessage = {
				{text = "command | ", color = "white"}, {text = "required args.", color = "aqua"}, {text = " | ", color = "white"}, {text = "optional args.\n", color = "yellow"},
				{text = "$take | ", color = "white"}, {text = "mod:item_name", color = "aqua"}, {text = " | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "Takes one (or given amount) of the given item if it is in storage.\n", color = "gray"},
				{text = "$store | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "Puts held stack (or given amount) of items in storage.\n", color = "gray"},
				{text = "$del | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "DELETES held stack (or given amount) of items.\n", color = "gray"},
				{text = "$list\n", color = "white"}, {text = "Lists all items in storage\n", color = "gray"},
				{text = "$help | ", color = "white"}, {text = "command name", color = "yellow"}
			}
		end
		
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, owner, chatBoxName)
		
	end

}

while true do

	local event, user, message, uuid, isHidden = os.pullEvent("chat")
	if isHidden and user == owner then
		
		local commands = {}
		
		for s in string.gmatch(message, "[%w:_]+") do
			commands[#commands+1] = s
		end
		
		local mainCommand = commands[1]
		table.remove(commands,1)
		
		if functions[mainCommand] ~= nil then
			functions[mainCommand](commands)
		end
		
	end

end

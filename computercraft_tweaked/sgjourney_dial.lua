-- Dialing program for Stargate Journey
-- Tested with the Milky Way Stargate, but should likely work with other Stargates
-- Made by EepyBerry :3

------------------------     FUNCTIONS     ------------------------
function dial(name, address)
    if interface.isWormholeOpen() then
        printError("[ERROR] Cannot dial location: wormhole already open!")
        return
    end

    print("[INFO] Starting dialing sequence to: " .. name)
    redstone.setOutput("top", true) -- This is optional, useful if you'd like to trigger an alarm or something (e.g. using Create's Redstone Links)
    local start = interface.getChevronsEngaged() + 1
    local feedbackCode = interface.getRecentFeedback()
    for chevron = start,#address,1 do
        local symbol = address[chevron]
        -- Check chevron
        if symbol < 0 or symbol > 38 then
            printFeedback(-3)
            interface.disconnectStargate()
            return
        end
        
        -- Rotate towards chevron
        write("  [] Engaging chevron " .. chevron .. "...")
        if chevron % 2 == 0 then
            interface.rotateClockwise(symbol)
        else
            interface.rotateAntiClockwise(symbol)
        end
        -- Wait for chevron to be selected
        while (not interface.isCurrentSymbol(symbol)) do
            sleep(0)
        end
        -- Engage chevron
        sleep(1)
        interface.openChevron()
        sleep(1)
        interface.closeChevron()
        write(" success\n")
        if not printFeedback(interface.getRecentFeedback) then
            printError("[ERROR] Dialing sequence failed, disconnecting Stargate!")
            interface.disconnectStargate()
            return
        end
        sleep(1)
    end
    print("[INFO] Dialing sequence complete!")
    print("[INFO] Opening wormhole to: " .. name .. "\n")
    sleep(3)
    redstone.setOutput("top", false) -- This is optional, useful if you'd like to trigger an alarm or something (e.g. using Create's Redstone Links)
end

function printFeedback(feedbackCode)
    if feedbackCode == -3 then
        printError("  !! Dialing failure: symbol out of bounds")
        return false
    elseif feedbackCode == -4 then
        printError("  !! Dialing failure: incomplete address")
        return false
    elseif feedbackCode == -5 then
        printError("  !! Dialing failure: invalid address")
        return false
    end
    return true
end

function printHelp()
    print("[INFO] Available commands:")
    print("  help            - show this prompt")
    print("  net             - list available locations")
    print("  dial <location> - dial Stargate at location")
    print("  disconnect      - close the Stargate")
    print("  exit            - exit the program\n")

end

function printNetwork(net)
    print("[INFO] Available locations are:")
    for k,v in ipairs(net) do
        print("  " .. v.name)
    end
    print("")
end

------------------------ NETWORK ADDRESSES ------------------------
network = 
{
  { name = "abydos", addr = {26,6,14,31,11,29,0}     },
  { name = "chulak", addr = {8,1,22,14,36,19,0}      },
  { name = "lantea", addr = {18,20,1,15,14,7,19,0}   },
  -- Add your custom addresses here!
  -- Don't forget the "Point of Origin" at the last position (which is always 0)!
}

------------------------   MAIN PROGRAM    ------------------------
print("###################################################")
print("#    +                                       +    #")
print("#  +          STARGATE INTERFACE v1.0          +  #")
print("#    +                                       +    #")
print("###################################################")
print("")

interface = peripheral.find("basic_interface") 
if interface == nil then
  printError("[ERROR] Stargate Interface unavailable")
  return
end
print("[INFO] Stargate Interface ready!")
printHelp()

while true do
    ::continue::
    write("> ")
    input = read()
    sleep(0)
    print("")
    
    if input == "help" then
        printHelp()
        goto continue
    end
    
    -- exit command
    if input == "exit" then
        interface.disconnectStargate()
        print("[INFO] Bye-bye! :3\n")
        return
    end
    
    -- disconnect command
    if input == "disconnect" then
        interface.disconnectStargate()
        print("[INFO] Stargate disconnected.\n")
        goto continue
    end
    
    -- net command
    if input == "net" then
        printNetwork(network)
        goto continue
    end
    
    -- dial command
    local maybeDial = input:find("^dial (.*)")
    if maybeDial ~= nil then
        netAddr = nil
        for k,v in ipairs(network) do
            if v.name == input:sub(6) then
                netAddr = v.addr
                break
            end
        end
        if netAddr == nil then
            printError("[ERROR] Invalid location!")
            printNetwork(network)
        else
            dial(input:sub(6), netAddr)
        end
    end
end

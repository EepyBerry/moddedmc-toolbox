-- Dialing program for Stargate Journey
-- Tested with the Milky Way Stargate, but should likely work with other Stargates
-- Made by EepyBerry :3

--------     FUNCTIONS     --------

function dial(name, address, fastmode)
    if interface.isWormholeOpen() then
        printError("[ERROR] Cannot dial location: wormhole already open!\n")
        return
    end

    print("[INFO] Starting dialing sequence to: " .. name)
    redstone.setOutput("top", true)
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
        
        if fastmode then
            write("  [] Engaging chevron " .. chevron .. "...")
            interface.engageSymbol(symbol)
            write(" success\n")
            sleep(0.5)
        else
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
        end
        if not printFeedback(interface.getRecentFeedback) then
            interface.disconnectStargate()
            return
        end
        sleep(1)
    end
    print("[INFO] Dialing sequence complete!")
    print("[INFO] Opening wormhole to: " .. name .. "\n")
    sleep(3)
    redstone.setOutput("top", false)
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
    print("  help             - show this prompt")
    print("  net              - list available locations")
    print("  dial <location>  - dial Stargate at location")
    print("  fdial <location> - fast-dial Stargate at location")
    print("  disconnect       - close the Stargate")
    print("  exit             - exit the program\n")

end

function printNetwork(net)
    print("[INFO] Available locations are:")
    for k,v in ipairs(net) do
        print("  " .. v.name)
    end
    print("")
end

-------- NETWORK ADDRESSES --------

network = 
{
  { name = "abydos", addr = {26,6,14,31,11,29,0}     },
  { name = "chulak", addr = {8,1,22,14,36,19,0}      },
  { name = "lantea", addr = {18,20,1,15,14,7,19,0}   },
}

--------   MAIN PROGRAM    --------

print("###################################################")
print("#    +                                       +    #")
print("#  +          STARGATE INTERFACE v1.0          +  #")
print("#    +                                       +    #")
print("###################################################\n")

interface = peripheral.find("crystal_interface") -- fast-dialing requires a Crystal Interface at minimum; replace with "basic_interface" if you don't want/need it
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
    
    -- dial/fdial command
    local maybeDial = input:find("^(f?)dial (.*)")
    if maybeDial ~= nil then
        fastDial = (input:sub(1,1) == 'f')
        locIdx = (fastDial and 7 or 6)
        netAddr = nil
        for k,v in ipairs(network) do
            if v.name == input:sub(locIdx) then
                netAddr = v.addr
                break
            end
        end
        if netAddr == nil then
            printError("[ERROR] Invalid location!")
            printNetwork(network)
        else
            dial(input:sub(locIdx), netAddr, fastDial)
        end
    end
end


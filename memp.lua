--By: iiferedon#1337
g_lua.register();

value = 100

--Locate WorldPTR Address
ptr = g_memory.scan_pattern("48 8B 05 ? ? ? ? 45 ? ? ? ? 48 8B 48 08") --WorldPTR
function checkpattern() --Check if WorldPTR is there
    if ptr == 0 then
        g_util.add_toast("WorldPTR Scan Failed!")
    end
end
worldptraddr = g_memory.rip(ptr+3)
readworldptr = g_memory.read_int(worldptraddr) --WorldPTR Address - This is the main address we use to find other pointers/addresses using offsets

--Offsets
pCPed = 8
pCVehicle = 3376
pCHandlingData = 0x938
oAcceleration = 0x4C
oBrakeForce = 0x6C

--Assigning Pointers
pCPedaddress = (readworldptr+pCPed)
pCPedptr = g_memory.read_int(pCPedaddress) --Ped Pointer
pCVehicleaddress = (pCPedptr+pCVehicle) 
pCVehicleaddressptr = g_memory.read_int(pCVehicleaddress) --Vehicle Pointer
pCHandlingDataaddress = (pCVehicleaddressptr+pCHandlingData)
handlecontrolPTR = g_memory.read_int(pCHandlingDataaddress) --Handling Pointer
--------------------------------------------------------------------------------------------------------------
oAccelerationaddress = (handlecontrolPTR+oAcceleration) --Acceleration Value Float (needs to be read as float)
oBrakeForceaddress = (handlecontrolPTR+oBrakeForce) --Brake Force Value Float (needs to be read as float)

--Var Functions
errorstring = "????????" --If address/value cannot be found

local PlayerPed =  PLAYER.PLAYER_ID() --Gets users playerid
local vehiclecheck = PLAYER.IS_PLAYER_IN_ANY_VEHICLE(PlayerPed) --Checks if player is in a vehicle

--Values
function getacceleration()
    if vehiclecheck == true then
    accelerationValue = g_memory.read_float(oAccelerationaddress) --Acceleration Value
        return accelerationValue
    else
        return errorstring
    end
end
    
function getbrakeforce()
    if vehiclecheck == true then
    brakeforceValue = g_memory.read_float(oBrakeForceaddress) --Brake Force Value
        return brakeforceValue
    else
        return errorstring
    end
end

--Addresses
function getworldptr()
    readworldptr = g_memory.read_int(worldptraddr)
    readworldptrhex = string.upper(string.format("%x", readworldptr * 255))
        return readworldptrhex
end

function getpCPedptr()
    if vehiclecheck == true then
    pCPedptr = g_memory.read_int(pCPedaddress)
        return pCPedptr
    else 
        return errorstring
    end
end

function gethandlecontrolPTR()
    if vehiclecheck == true then
    handlecontrolPTR = g_memory.read_int(pCHandlingDataaddress)
        return handlecontrolPTR
    else 
        return errorstring
    end
end

function getpCVehicleaddressptr()
    if vehiclecheck == true then
    pCVehicleaddressptr = g_memory.read_int(pCVehicleaddress)
        return pCVehicleaddressptr
    else 
        return errorstring
    end
end

function getbaseaddress()
    baseaddress = g_memory.get_base_address()
    baseaddresshex = string.upper(string.format("%x", baseaddress * 255))
    return baseaddresshex
end

--GUI
local sessionstart = NETWORK.IS_SESSION_STARTED()

--Update GUI
g_gui.add_input_int("vehicle_options", "Acceleration", 1000, 0, 1, 1, 100, function(int)  accVal = int end)
g_gui.add_input_int("vehicle_options", "Gravity", 500, 0, 10, 1, 100, function(int) gravVal = int end)
g_gui.add_toggle('vehicle_options', 'Debug', function(on) debug = on update() end)

function update() --TBC
relay = 0
end
--Decimal to Hex
function dectohex(decimal)
    local notinveh = decimal
    if vehiclecheck == true then
    local hex = string.upper(string.format("%x", decimal * 255))
        return hex
    else
        return notinveh
    end
end

--Main GUI
function directx() 
	if g_gui.is_open() and debug then --Ff menu is open
		g_imgui.set_next_window_size(vec2(295, 300)) --Set Size
		if  g_imgui.begin_window("Debug", ImGuiWindowFlags_NoResize) then --Begin Window
			g_imgui.begin_child("Debug", vec2(280,260), true) --Begin the Child in window
                    if sessionstart then --Checks if session has started
                        g_imgui.add_text('GTAV.exe address:')   g_imgui.same_line() g_imgui.add_text(getbaseaddress())
                        g_imgui.add_text('WorldPTR -->')   g_imgui.same_line() g_imgui.add_text(getworldptr())
                        g_imgui.add_text('pCPedptr -->')   g_imgui.same_line() g_imgui.add_text(dectohex(getpCPedptr()))
                        g_imgui.add_text('pCHandlingDataptr -->')  g_imgui.same_line() g_imgui.add_text(dectohex(gethandlecontrolPTR()))
                        g_imgui.add_text('pCVehicleaddressptr -->')  g_imgui.same_line() g_imgui.add_text(dectohex(getpCVehicleaddressptr()))
                        g_imgui.separator()
                        g_imgui.add_text('Breakforce Value:')  g_imgui.same_line() g_imgui.add_text(getbrakeforce())
                        g_imgui.add_text('Acceleration Value:')  g_imgui.same_line() g_imgui.add_text(getacceleration())
                    end
            g_imgui.end_child() --Ends the child
			g_imgui.end_window() --Ends the window
		end
	end
end

id = g_hooking.register_D3D_hook(directx); --Registers the D3D hook into cherax

while g_isRunning do
	g_util.yield(1000)
    checkpattern() --Check if WorldPTR is there every 1000ms
end
g_hooking.unregister_hook(id) 
g_lua.unregister();
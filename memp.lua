--By: iiferedon#1337
g_lua.register();

value = 100

--Locate WorldPTR Address
worldptr = g_memory.scan_pattern("48 8B 05 ? ? ? ? 45 ? ? ? ? 48 8B 48 08") --WorldPTR
function checkpattern() --Check if WorldPTR is there
    if worldptr == 0 then
        g_gui.add_toast("WorldPTR Scan Failed!")
    elseif clone_create_ack == 0 then
        g_gui.add_toast("Clone_Create_Ack Scan Failed!")
    elseif game_event == 0 then 
        g_gui.add_toast("Game_Event Scan Failed!")
    end
end

clone_create_ack = g_memory.scan_pattern("48 8b c4 48 89 58 ? 48 89 68 ? 48 89 70 ? 48 89 78 ? 41 54 41 56 41 57 48 83 ec ? 4c 8b fa 49 8b d8") --clone_create_ack
game_event = g_memory.scan_pattern("48 8B DA 48 8B F1 41 81 FF 00") --game_event

worldptraddr = g_memory.rip(worldptr+3)
readworldptr = g_memory.read_int(worldptraddr) --WorldPTR Address - This is the main address we use to find other pointers/addresses using offsets

--Offsets
pCPed = 8;
pCVehicle = 3376;
pCHandlingData = 0x938;

--CHandlingData
oAcceleration = 0x4C;
oBrakeForce = 0x6C;
fMass = 0x000C; --float
fInitialDragCoeff = 0x0010; --float
fDownforceModifier = 0x0014; --float
fPopUpLightRotation = 0x0018;  --float 
lN000019E5 = 0x001C; --float
vecCentreOfMassOffset = 0x0020; --Vector3
N000019E9 = 0x002C; --float
vecInertiaMultiplier = 0x0030; --Vector3
fUnk_0x003C = 0x003C;  --float
fPercentSubmerged = 0x0040; --float
fSubmergedRatio_ = 0x0044; --float
fDriveBiasFront = 0x0048; --float
fDriveBiasRear = 0x004C; --float
nInitialDriveGears = 0x0050; --uint8_t
nPad0x51 = 0x0051; --uint8_t
nPad0x52 = 0x0052; --uint8_t
nPad0x53 = 0x0053; --uint8_t
fDriveInertia = 0x0054; --float
fClutchChangeRateScaleUpShift = 0x0058; --float
lfClutchChangeRateScaleDownShift = 0x005C; --float
fInitialDriveForce = 0x0060; --float
fSuspensionForce = 0x00BC; --int
fSuspensionCompDamp = 0x00C0; --int
fSuspensionReboundDamp = 0x00C4; --int
fSuspensionUpperLimit = 0x00C8; --int
fSuspensionLowerLimit = 0x00CC; --int
fSuspensionRaise = 0x00D0; --int
fSuspensionBiasFront = 0x00D4; --int
fSuspensionBiasRear = 0x00D8; --int


--Assigning Pointers
pCPedaddress = (readworldptr+pCPed);
pCPedptr = g_memory.read_int(pCPedaddress); --Ped Pointer
pCVehicleaddress = (pCPedptr+pCVehicle); 
pCVehicleaddressptr = g_memory.read_int(pCVehicleaddress); --Vehicle Pointer
pCHandlingDataaddress = (pCVehicleaddressptr+pCHandlingData);
handlecontrolPTR = g_memory.read_int(pCHandlingDataaddress); --Handling Pointer
--------------------------------------------------------------------------------------------------------------
--Read and Write Addresses

--General
local oAccelerationaddress = (handlecontrolPTR+oAcceleration); --Acceleration Value Float (needs to be read as float)
local oBrakeForceaddress = (handlecontrolPTR+oBrakeForce); --Brake Force Value Float (needs to be read as float)
local ofDownforceModifieraddress = (handlecontrolPTR+fDownforceModifier);

--Suspension
local fSuspensionForceaddress = (handlecontrolPTR+fSuspensionForce); --int
local fSuspensionCompDampaddress = (handlecontrolPTR+fSuspensionCompDamp); --int
local fSuspensionReboundDampaddress = (handlecontrolPTR+fSuspensionReboundDamp); --int
local fSuspensionUpperLimitaddress = (handlecontrolPTR+fSuspensionUpperLimit); --int
local fSuspensionLowerLimitaddress = (handlecontrolPTR+fSuspensionLowerLimit); --int
local fSuspensionRaiseaddress = (handlecontrolPTR+fSuspensionRaise); --int
local fSuspensionBiasFrontaddress = (handlecontrolPTR+fSuspensionBiasFront); --int
local fSuspensionBiasRearaddress = (handlecontrolPTR+fSuspensionBiasRear); --int

--Global Variables
local errorstring = "????????" --If address/value cannot be found
local PlayerPed =  PLAYER.PLAYER_ID() --Gets local playerid
local vehiclecheck = PLAYER.IS_PLAYER_IN_ANY_VEHICLE(PlayerPed) --Checks if player is in a vehicle
local sessionstart = NETWORK.IS_SESSION_STARTED() --Boolean is session started

--Get Value Functions

function getSuspensioninfo(address)
    if vehiclecheck == true then
        local value = g_memory.read_float(address)
        return value
    else
        return errorstring
    end
end

function getfSuspensionForceaddress()
    if vehiclecheck == true then
    fSuspensionForceaddressValue = g_memory.read_float(fSuspensionForceaddress) --Acceleration Value
        return fSuspensionForceaddressValue
    else
        return errorstring
    end
end

function getfDownforceModifier()
    if vehiclecheck == true then
        downforceValue = g_memory.read_float(ofDownforceModifieraddress) --ofDownforceModifieraddress Value
        return downforceValue
    else
        return errorstring
    end
end

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
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Main GUI
g_gui.add_input_int("vehicle_options", "Acceleration", 10, 1, 1000, 1, 50, function(float)  
local type = "float"
local value = float 
local alias = "Acceleration"
local address = oAccelerationaddress
writetomemory(type, address, value, alias) 
end)

g_gui.add_input_int("vehicle_options", "Downforce", 10, 1, 1000, 1, 50, function(float)  
local type = "float"
local value = float
local alias = "Downforce"
local address = ofDownforceModifieraddress
writetomemory(type, address, value, alias)
end)

g_gui.add_input_int("vehicle_options", "Brakeforce", 10, 1, 1000, 1, 50, function(float)  
local type = "float"
local value = float
local alias = "Brakeforce"
local address = oBrakeForceaddress
writetomemory(type, address, value, alias)
end)

g_gui.add_input_int("vehicle_options", "SuspensionForce", 10, 1, 1000, 1, 50, function(float)  
local type = "float"
local value = float
local alias = "SuspensionForce"
local address = fSuspensionForceaddress
writetomemory(type, address, value, alias)
end)

function writetomemory(type, address, value, alias) --Parse Params
    if sessionstart and vehiclecheck then
        if type == "float" then
        g_memory.write_float(address, value)
        elseif type == "int" then
        g_memory.write_int(address, value)
        end
        g_util.yield(math.random(50, 200))
        --g_gui.add_toast("Memory Wrote to "..alias.." Type: Float ".."Address: "..address.." Value: "..value, 200)
    else
        g_gui.add_toast("You must be in a vehicle")
    end
end

--Decimal to Hex
function dectohex(decimal)
    local notinveh = "error"
    if vehiclecheck == true then
    local hex = string.upper(string.format("%x", decimal * 255))
        return hex
    else
        return notinveh
    end
end

--Debug GUI
function directx() 
	if true then --If menu is open
		g_imgui.set_next_window_size(vec2(330, 400)) --Set Size
		if  g_imgui.begin_window("Debug", ImGuiWindowFlags_NoResize) then --Begin Window
			g_imgui.begin_child("Debug", vec2(320,350), true) --Begin the Child in window
                    if sessionstart and vehiclecheck then --Checks if session has started and in vehicle
                        g_imgui.add_text('GTAV.exe address:')   g_imgui.same_line() g_imgui.add_text(getbaseaddress())
                        g_imgui.add_text('WorldPTR -->')   g_imgui.same_line() g_imgui.add_text(getworldptr())
                        g_imgui.add_text('pCPedptr -->')   g_imgui.same_line() g_imgui.add_text(dectohex(getpCPedptr()))
                        g_imgui.add_text('pCHandlingDataptr -->')  g_imgui.same_line() g_imgui.add_text(dectohex(gethandlecontrolPTR()))
                        g_imgui.add_text('pCVehicleaddressptr -->')  g_imgui.same_line() g_imgui.add_text(dectohex(getpCVehicleaddressptr()))
                        g_imgui.separator()
                        g_imgui.add_text('Acceleration Value:')  g_imgui.same_line() g_imgui.add_text(getacceleration())
                        g_imgui.add_text('Breakforce Value:')  g_imgui.same_line() g_imgui.add_text(getbrakeforce())
                        g_imgui.add_text('Downforce Value:')  g_imgui.same_line() g_imgui.add_text(getfDownforceModifier())
                        g_imgui.separator()
                        g_imgui.add_text('SuspensionForce:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionForceaddress))
                        g_imgui.add_text('SuspensionCompDamp:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionCompDampaddress))
                        g_imgui.add_text('SuspensionReboundDamp:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionReboundDampaddress))
                        g_imgui.add_text('SuspensionUpperLimit:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionUpperLimitaddress))
                        g_imgui.add_text('SuspensionLowerLimit:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionLowerLimitaddress))
                        g_imgui.add_text('SuspensionRaise:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionRaiseaddress))
                        g_imgui.add_text('SuspensionBiasFront:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionBiasFrontaddress))
                        g_imgui.add_text('SuspensionBiasRear:')  g_imgui.same_line() g_imgui.add_text(getSuspensioninfo(fSuspensionBiasRearaddress))
                    else
                        g_imgui.add_text('You must be in a vehicle.')
                    end
            g_imgui.end_child() --Ends the child
			g_imgui.end_window() --Ends the window
		end
	end
end

id = g_hooking.register_D3D_hook(directx); --Registers the D3D hook into cherax

while g_isRunning do
    if vehiclecheck then
        checkpattern()
        g_util.yield(1000)
    end
end

g_hooking.unregister_hook(id) 
g_lua.unregister();

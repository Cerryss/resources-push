local BANK = {
    Data = {}
}

local activeBlips, bankPoints, atmPoints, markerPoints = {}, {}, {}, {}
local playerLoaded, uiActive, inMenu = false, false, false


--===============================================
--==            CUTA TARGET          ==
--===============================================

local atm = {
    -870868698,
    -1126237515,
    -1364697528,
    506770882,
    
}

exports['cuta-target']:AddTargetModel(atm, {
    options = {
        {
            event = "cuta-atm:openatm",
            icon = "fas fa-wallet",
            label = "Open ATM",
        },
    },
    job = {"all"},
    distance = 2.5
}) 

RegisterNetEvent('cuta-atm:openatm')
AddEventHandler('cuta-atm:openatm', function()
    local dict = 'anim@amb@prop_human_atm@interior@male@enter'
	local anim = 'enter'
	local ped = GetPlayerPed(-1)

    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, 0, 0, 0, 0, 0)
    Citizen.Wait(2 * 1000)
    ClearPedTasks(ped)
    BANK:HandleUi(true, atm)
end)

RegisterNetEvent('cuta-atm:openbank')
AddEventHandler('cuta-atm:openbank', function()
    BANK:HandleUi(true, false)
end)
    -- Create Blips
    Citizen.CreateThread(function()
        local tmpActiveBlips = {}
        for i = 1, #Config.Banks do
            if type(Config.Banks[i].Blip) == 'table' and Config.Banks[i].Blip.Enabled then
                local position = Config.Banks[i].Position
                local bInfo = Config.Banks[i].Blip
                local blip = AddBlipForCoord(position.x, position.y, position.z)
                SetBlipSprite(blip, bInfo.Sprite)
                SetBlipScale(blip, bInfo.Scale)
                SetBlipColour(blip, bInfo.Color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(bInfo.Label)
                EndTextCommandSetBlipName(blip)
                tmpActiveBlips[#tmpActiveBlips + 1] = blip
            end
        end

        activeBlips = tmpActiveBlips
    end)

    -- Remove blips
    function BANK:RemoveBlips()
        for i = 1, #activeBlips do
            if DoesBlipExist(activeBlips[i]) then
                RemoveBlip(activeBlips[i])
            end
        end
        activeBlips = {}
    end

    -- Open / Close ui
    function BANK:HandleUi(state, atm)
        atm = atm or false
        SetNuiFocus(state, state)
        inMenu = state
        ClearPedTasks(PlayerPedId())
        if not state then
            SendNUIMessage({
                showMenu = false
            })
            return
        end
        ESX.TriggerServerCallback('esx_banking:getPlayerData', function(data)
            SendNUIMessage({
                showMenu = true,
                openATM = atm,
                datas = {
                    your_money_panel = {
                        accountsData = {{
                            name = "cash",
                            amount = data.money
                        }, {
                            name = "bank",
                            amount = data.bankMoney
                        }}
                    },
                    bankCardData = {
                        bankName = 'Discovery City Bank',
                        cardNumber = "2232 2222 2222 2222",
                        createdDate = "08/08",
                        name = data.playerName
                    },
                    transactionsData = data.transactionHistory
                }
            })
        end)
    end

-- Events
RegisterNetEvent('esx_banking:closebanking', function()
    BANK:HandleUi(false)
end)

RegisterNetEvent('esx_banking:updateMoneyInUI', function(doingType, bankMoney, money)
    SendNUIMessage({
        updateData = true,
        data = {
            type = doingType,
            bankMoney = bankMoney,
            money = money
        }
    })
end)

-- Handlers
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    BANK:CreateBlips()
end)
    -- Disable the script on player logout
    RegisterNetEvent('esx:onPlayerLogout', function()
        playerLoaded = false
    end)

    -- Resource stopping

    RegisterNetEvent('esx:onPlayerDeath', function() BANK:HandleUi(false) end)

-- Nui Callbacks
RegisterNUICallback('close', function(data, cb)
    BANK:HandleUi(false)
    cb('ok')
end)

RegisterNUICallback('clickButton', function(data, cb)
    if not data or not inMenu then
        return cb('ok')
    end

    TriggerServerEvent("esx_banking:doingType", data)
    cb('ok')
end)

RegisterNUICallback('checkPincode', function(data, cb)
    if not data or not inMenu then
        return cb('ok')
    end

    ESX.TriggerServerCallback("esx_banking:checkPincode", function(pincode)
        if pincode then
            cb({
                success = true
            })
        else
            cb({
                error = true
            })
            ESX.ShowNotification('Invalid PIN code', "error")
        end
    end, data)
end)

-- BANK

--- BANK BESAR 1
exports['cuta-target']:AddBoxZone("BankBesar", vector3(241.42, 225.29, 106.29), 4, 4, {
    name="BankBesar",
    heading=272.26,
    debugPoly=false,
    minZ=100.00,
    maxZ=112.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

--- BANK BESAR 2
exports['cuta-target']:AddBoxZone("BankBesar2", vector3(243.01, 224.58, 106.29), 4, 4, {
    name="BankBesar2",
    heading=272.26,
    debugPoly=false,
    minZ=100.00,
    maxZ=112.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

--- BANK BESAR 3
exports['cuta-target']:AddBoxZone("BankBesar3", vector3(246.63, 223.59, 106.29), 4, 4, {
    name="BankBesar3",
    heading=272.26,
    debugPoly=false,
    minZ=100.00,
    maxZ=112.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

--- BANK BIASA
exports['cuta-target']:AddBoxZone("BankRusun", vector3(313.37, -279.82, 54.17), 4, 4, {
    name="BankRusun",
    heading=272.26,
    debugPoly=false,
    minZ=50.00,
    maxZ=60.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

exports['cuta-target']:AddBoxZone("BankMechanic", vector3(-351.41, -49.52, 49.04), 4, 4, {
    name="BankMechanic",
    heading=272.26,
    debugPoly=false,
    minZ=45.00,
    maxZ=60.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

exports['cuta-target']:AddBoxZone("BankTamkot", vector3(149.43, -1040.56, 29.37), 4, 4, {
    name="BankTamkot",
    heading=272.26,
    debugPoly=false,
    minZ=25.00,
    maxZ=36.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

exports['cuta-target']:AddBoxZone("BankReporter", vector3(-1212.73, -330.76, 37.79), 4, 4, {
    name="BankReporter",
    heading=272.26,
    debugPoly=false,
    minZ=25.00,
    maxZ=40.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

exports['cuta-target']:AddBoxZone("BankTollKiri", vector3(-2962.59, 482.64, 15.7), 4, 4, {
    name="BankTollKiri",
    heading=272.26,
    debugPoly=false,
    minZ=25.00,
    maxZ=40.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

exports['cuta-target']:AddBoxZone("BankSS", vector3(1175.59, 2706.9, 38.09), 4, 4, {
    name="BankSS",
    heading=272.26,
    debugPoly=false,
    minZ=25.00,
    maxZ=40.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

exports['cuta-target']:AddBoxZone("BankPaleto", vector3(-113.02, 6470.11, 31.63), 4, 4, {
    name="BankPaleto",
    heading=272.26,
    debugPoly=false,
    minZ=25.00,
    maxZ=40.99,
    }, {
        options = {
            {
                event = "cuta-atm:openbank",
                icon = "fas fa-university",
                label = "Open Bank",
            },
        },
        job = {"all"},
        distance = 2.5
})

local spawnedPeds, netIdTable = {}, {}

-- get keys utils
local function get_key(t)
    local key
    for k, _ in pairs(t) do
        key = k
    end
    return key
end

-- Resource starting
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if Config.EnablePeds then BANK.CreatePeds() end
    local twoMonthMs = (os.time() - 5259487) * 1000
    MySQL.Sync.fetchScalar('DELETE FROM banking WHERE time < ? ', {twoMonthMs})
end)

-- event
RegisterServerEvent('esx_banking:doingType')
AddEventHandler('esx_banking:doingType', function(typeData)
    if source == nil then return end
    if (typeData == nil) then return end

    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local money = xPlayer.getAccount('money').money
    local bankMoney = xPlayer.getAccount('bank').money
    local amount

    local key = get_key(typeData)
    if typeData.deposit then
        amount = tonumber(typeData.deposit)
    elseif typeData.withdraw then
        amount = tonumber(typeData.withdraw)
    elseif typeData.transfer and typeData.transfer.moneyAmount then
        amount = tonumber(typeData.transfer.moneyAmount)
    elseif typeData.pincode then
        amount = tonumber(typeData.pincode)
    end

    if not tonumber(amount) then return end
    amount = ESX.Math.Round(amount)

    if amount == nil or (not typeData.pincode and amount <= 0) then
        TriggerClientEvent("esx:showNotification", source, 'That\'s an invalid amount of money', "error")
    else
        if typeData.deposit and amount <= money then
            -- deposit
            BANK.Deposit(amount, xPlayer)
        elseif typeData.withdraw and bankMoney ~= nil and amount <= bankMoney then
            -- withdraw
            BANK.Withdraw(amount, xPlayer)
        elseif typeData.pincode then
            -- pincode
            BANK.Pincode(amount, identifier)
        elseif typeData.transfer then
            -- transfer
            if tonumber(typeData.transfer.playerId) > 0 and bankMoney >= amount then
                local xTarget = ESX.GetPlayerFromId(tonumber(typeData.transfer.playerId))
                if not BANK.Transfer(xTarget, xPlayer, amount, key) then
                    return
                end
            end
        else
            TriggerClientEvent("esx:showNotification", source, 'Not enough money!', "error")
            return
        end

        money = xPlayer.getAccount('money').money
        bankMoney = xPlayer.getAccount('bank').money
        if typeData.transfer then
            TriggerClientEvent('cuta-ifnotif:Alert', source, "BANK", "You have transferred $ "..amount.. ' to '..typeData.transfer.playerId, 5000, 'success')
        else
            TriggerClientEvent('cuta-ifnotif:Alert', source, "BANK", "You have "..key..' $'..amount, 5000, 'success')
           -- TriggerClientEvent("esx:showNotification", source, TranslateCap(string.format('%s_money', key), typeData.pincode and (string.format("%04d", amount)) or amount), "success")
        end
        if not typeData.pincode then
            BANK.LogTransaction(source, string.upper(key), amount, bankMoney)
        end

        TriggerClientEvent("esx_banking:updateMoneyInUI", source, key, bankMoney, money)
    end
end)

-- register callbacks
ESX.RegisterServerCallback("esx_banking:getPlayerData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local weekAgo = (os.time() - 604800) * 1000
    local transactionHistory = MySQL.Sync.fetchAll(
        'SELECT * FROM banking WHERE identifier = ? AND time > ? ORDER BY time DESC LIMIT 10', {identifier, weekAgo})
    local playerData = {
        playerName = xPlayer.getName(),
        money = xPlayer.getAccount('money').money,
        bankMoney = xPlayer.getAccount('bank').money,
        transactionHistory = transactionHistory
    }

    cb(playerData)
end)

ESX.RegisterServerCallback("esx_banking:checkPincode", function(source, cb, inputPincode)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local pincode = MySQL.Sync.fetchScalar('SELECT COUNT(1) AS pincode FROM users WHERE identifier = ? AND pincode = ?',
        {identifier, inputPincode})
    cb(pincode > 0)
end)

function logTransaction(targetSource,key,amount)
    if targetSource == nil then
        print("ERROR: TargetSource nil!")
        return
    end

    if key == nil then
        print("ERROR: Do you need use these: WITHDRAW,DEPOSIT,TRANSFER_RECEIVE")
        return
    end
    
    if type(key) ~= "string" or key == '' then
        print("ERROR: Do you need use these: WITHDRAW,DEPOSIT,TRANSFER_RECEIVE and can only be string type!")
        return
    end

    if amount == nil then
        print("ERROR: Amount value is nil! Add some numeric value to the amount!")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(tonumber(targetSource))

    if xPlayer ~= nil then
        local bankCurrentMoney = xPlayer.getAccount('bank').money
        BANK.LogTransaction(targetSource, string.upper(key), amount, bankCurrentMoney)  
    else
        print("ERROR: xPlayer is nil!") 
    end
end
exports("logTransaction", logTransaction)

-- bank functions
BANK = {
    DeletePeds = function()
        for i = 1, #spawnedPeds do
            DeleteEntity(spawnedPeds[i])
            spawnedPeds[i] = nil
        end
    end,
    Withdraw = function(amount, xPlayer)
        xPlayer.addAccountMoney('money', amount)
        xPlayer.removeAccountMoney('bank', amount)
    end,
    Deposit = function(amount, xPlayer)
        xPlayer.removeAccountMoney('money', amount)
        xPlayer.addAccountMoney('bank', amount)
    end,
    Transfer = function(xTarget, xPlayer, amount, key)
        if xTarget == nil or xPlayer.source == xTarget.source then
            TriggerClientEvent("esx:showNotification", source, "Can't do it!", "error")
            return false
        end

        xPlayer.removeAccountMoney('bank', amount)
        xTarget.addAccountMoney('bank', amount)
        local bankMoney = xTarget.getAccount('bank').money
        BANK.LogTransaction(xTarget.source, "TRANSFER_RECEIVE", amount, bankMoney)
        TriggerClientEvent("esx:showNotification", xTarget.source, 'You have received $'..amount..' from '..xPlayer.source, "success")

        return true
    end,
    Pincode = function(amount, identifier)
        MySQL.update('UPDATE users SET pincode = ? WHERE identifier = ? ', {amount, identifier})
    end,
    LogTransaction = function(playerId, logType, amount, bankMoney)
        if playerId == nil then
            return
        end
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local identifier = xPlayer.getIdentifier()

        MySQL.insert('INSERT INTO banking (identifier, type, amount, time, balance) VALUES (?, ?, ?, ?, ?)',
            {identifier, logType, amount, os.time() * 1000, bankMoney})
    end   
}

--[[ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)]]--
ESX = exports["base"]:getSharedObject()

local firstNumber = ""
local secondNumber = ""
local operations = {"Addition", "Soustraction", "Multiplication", "Division"}
local operationIndex = 1
local history = {}

local function ResetCalculator()
    firstNumber = ""
    secondNumber = ""
    operationIndex = 1
end

local function ClearHistory()
    history = {}
end

local function Calculate()
    if firstNumber ~= "" and secondNumber ~= "" then
        local num1 = tonumber(firstNumber)
        local num2 = tonumber(secondNumber)
        local result = nil
        local operation = operations[operationIndex]

        if operation == "Addition" then
            result = num1 + num2
        elseif operation == "Soustraction" then
            result = num1 - num2
        elseif operation == "Multiplication" then
            result = num1 * num2
        elseif operation == "Division" then
            if num2 ~= 0 then
                result = num1 / num2
            else
                result = "Erreur"
            end
        end

        if result ~= nil then
            table.insert(history, { first = num1, second = num2, op = operation, res = result })
            return result
        end
    end
    return nil
end

OpenCalculatrice = function()
    local calcu = RageUI.CreateMenu("Calculatrice", "Interaction") 
    local History = RageUI.CreateSubMenu(calcu, "Historique", "Interaction") 
    RageUI.Visible(calcu, true)
    
    Citizen.CreateThread(function()
        while RageUI.Visible(calcu) or RageUI.Visible(History) do 
            Wait(0)
            RageUI.IsVisible(calcu, function()
                RageUI.Button("Premier nombre : " .. firstNumber, nil, {}, true, {
                    onSelected = function()
                        AddTextEntry('FMMC_KEY_TIP1', "Entrez le premier nombre")
                        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 10)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Citizen.Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            firstNumber = GetOnscreenKeyboardResult()
                        end
                    end
                })
                RageUI.Button("Deuxième nombre : " .. secondNumber, nil, {}, true, {
                    onSelected = function()
                        AddTextEntry('FMMC_KEY_TIP1', "Entrez le deuxième nombre")
                        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 10)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Citizen.Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            secondNumber = GetOnscreenKeyboardResult()
                        end
                    end
                })
                RageUI.List("Opération", operations, operationIndex, nil, {}, true, {
                    onListChange = function(Index)
                        operationIndex = Index
                    end
                })
                RageUI.Separator()
                RageUI.Button("Calculer", nil, {}, true, {
                    onSelected = function()
                        local result = Calculate()
                        if result ~= nil then
                            ESX.ShowNotification("Résultat: " .. result)
                        else
                            ESX.ShowNotification("Erreur dans le calcul.")
                        end
                    end
                })
                RageUI.Button("Réinitialiser", nil, {}, true, {
                    onSelected = function()
                        ResetCalculator()
                    end
                })
                RageUI.Button("Historique", nil, {RightLabel = '→→'}, true, {
                    onSelected = function()
                    end
                }, History)
            end)

            RageUI.IsVisible(History, function()
                RageUI.Button("Vider l'historique ⚠️", nil, {}, true, {
                    onSelected = function()
                        ClearHistory()
                        ESX.ShowNotification("Historique vidé.")
                    end
                })
                RageUI.Separator()
                for i, calc in ipairs(history) do
                    local operationSymbol = calc.op == "Addition" and "+" or calc.op == "Soustraction" and "-" or calc.op == "Multiplication" and "*" or calc.op == "Division" and "/"
                    RageUI.Button(string.format("%d %s %d = %s", calc.first, operationSymbol, calc.second, tostring(calc.res)), nil, {}, true, {})
                end
            end)

            if not RageUI.Visible(calcu) and not RageUI.Visible(History) then
                calcu = RMenu:DeleteType('calcu')
            end
        end
    end)
end

RegisterCommand(ConfigCalculatrice.Command, function()
    OpenCalculatrice()
end)
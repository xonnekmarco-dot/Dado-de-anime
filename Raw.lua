
--[[
    OMA FAMILY | ANIME DICE HUB
    Interfaz Rayfield para Roblox
    Idioma: Español
    Compatible con diseño móvil

    IMPORTANTE:
    Los módulos de automatización del juego requieren
    conocer sus RemoteEvents y la estructura real del juego.
    No se inventan eventos ni se envían ataques desconocidos.
]]

--==================================================
-- 1. SERVICIOS
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- 2. CONFIGURACIÓN
--==================================================

local Config = {
    Velocidad = 16,
    Salto = 50,
    AntiAFK = true,

    AutoRoll = false,
    KillAura = false,
    AutoCollect = false,
    AutoSell = false,
    AutoGrade = false,
}

local Connections = {}
local CharacterConnection

--==================================================
-- 3. RAYFIELD UI
--==================================================

local Rayfield

local success, result = pcall(function()
    return loadstring(game:HttpGet(
        "https://sirius.menu/rayfield"
    ))()
end)

if not success or not result then
    warn("[OMA FAMILY] No se pudo cargar Rayfield:", result)
    return
end

Rayfield = result

local Window = Rayfield:CreateWindow({
    Name = "OMA FAMILY | Anime Dice",
    LoadingTitle = "OMA FAMILY",
    LoadingSubtitle = "Anime Dice Hub",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

--==================================================
-- 4. FUNCIONES DE PERSONAJE
--==================================================

local function GetCharacter()
    return Player.Character
end

local function GetHumanoid()
    local Character = GetCharacter()
    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass("Humanoid")
end

local function ApplyMovement()
    local Humanoid = GetHumanoid()
    if not Humanoid then
        return
    end

    Humanoid.WalkSpeed = Config.Velocidad

    -- JumpPower funciona cuando UseJumpPower está activado.
    if Humanoid.UseJumpPower then
        Humanoid.JumpPower = Config.Salto
    else
        -- En juegos que usan JumpHeight, se adapta el valor.
        Humanoid.JumpHeight = Config.Salto
    end
end

Connections.CharacterAdded = Player.CharacterAdded:Connect(
    function()
        task.wait(0.5)
        ApplyMovement()
    end
)

--==================================================
-- 5. ANTI-AFK
--==================================================

local function StartAntiAFK()
    if Connections.AntiAFK then
        Connections.AntiAFK:Disconnect()
        Connections.AntiAFK = nil
    end

    if not Config.AntiAFK then
        return
    end

    Connections.AntiAFK =
        Player.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(
                    Vector2.new(0, 0)
                )
            end)
        end)
end

--==================================================
-- 6. PESTAÑA PRINCIPAL
--==================================================

local MainTab = Window:CreateTab(
    "Principal",
    "house"
)

MainTab:CreateSection("Estado del sistema")

MainTab:CreateParagraph({
    Title = "OMA FAMILY",
    Content =
        "Interfaz preparada para Anime Dice.\n" ..
        "Los automatismos necesitan verificar los eventos reales."
})

MainTab:CreateButton({
    Name = "Actualizar personaje",
    Callback = function()
        ApplyMovement()
        Rayfield:Notify({
            Title = "OMA FAMILY",
            Content = "Se aplicaron los ajustes de movimiento.",
            Duration = 3,
        })
    end,
})

--==================================================
-- 7. PESTAÑA AUTO-ROLL
--==================================================

local RollTab = Window:CreateTab(
    "Auto Roll",
    "dices"
)

RollTab:CreateSection("Tiradas automáticas")

RollTab:CreateToggle({
    Name = "Fast Auto-Roll",
    CurrentValue = false,
    Flag = "OMAAutoRoll",
    Callback = function(Value)
        Config.AutoRoll = Value

        if Value then
            Rayfield:Notify({
                Title = "Auto Roll",
                Content =
                    "Pendiente: verificar el evento real de tirada.",
                Duration = 5,
            })
        end
    end,
})

RollTab:CreateParagraph({
    Title = "Animaciones",
    Content =
        "La interfaz no desactiva animaciones del servidor. " ..
        "Para hacerlo correctamente hay que identificar cómo " ..
        "Anime Dice reproduce la animación del dado."
})

--==================================================
-- 8. PESTAÑA TORRE
--==================================================

local TowerTab = Window:CreateTab(
    "Torre",
    "swords"
)

TowerTab:CreateSection("Combate")

TowerTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "OMAKillAura",
    Callback = function(Value)
        Config.KillAura = Value

        if Value then
            Rayfield:Notify({
                Title = "Combate",
                Content =
                    "Pendiente: verificar el sistema de combate.",
                Duration = 5,
            })
        end
    end,
})

TowerTab:CreateToggle({
    Name = "Fast Tower Farm",
    CurrentValue = false,
    Flag = "OMATowerFarm",
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Torre",
                Content =
                    "Pendiente: verificar enemigos y recompensas.",
                Duration = 5,
            })
        end
    end,
})

TowerTab:CreateParagraph({
    Title = "Configuración requerida",
    Content =
        "No se envían ataques ficticios. Se necesitan los " ..
        "eventos de combate y las condiciones de daño del juego."
})

--==================================================
-- 9. PESTAÑA RECOLECCIÓN
--==================================================

local CollectTab = Window:CreateTab(
    "Recolección",
    "gem"
)

CollectTab:CreateSection("Gemas, cofres y objetos")

CollectTab:CreateToggle({
    Name = "Item & Gem Magnet",
    CurrentValue = false,
    Flag = "OMAItemMagnet",
    Callback = function(Value)
        Config.AutoCollect = Value

        if Value then
            Rayfield:Notify({
                Title = "Recolección",
                Content =
                    "Pendiente: verificar los objetos recogibles.",
                Duration = 5,
            })
        end
    end,
})

CollectTab:CreateParagraph({
    Title = "Recogida de objetos",
    Content =
        "Mover objetos locales no garantiza recogerlos. " ..
        "Se debe verificar el mecanismo de recogida del servidor."
})

--==================================================
-- 10. PESTAÑA INVENTARIO
--==================================================

local InventoryTab = Window:CreateTab(
    "Inventario",
    "backpack"
)

InventoryTab:CreateSection("Filtro de rarezas")

InventoryTab:CreateDropdown({
    Name = "Rareza mínima que conservar",
    Options = {
        "Common",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic",
        "Todas",
    },
    CurrentOption = {"Legendary"},
    MultipleOptions = false,
    Flag = "OMARarityFilter",
    Callback = function(Options)
        print(
            "[OMA FAMILY] Filtro seleccionado:",
            Options[1] or "Legendary"
        )
    end,
})

InventoryTab:CreateToggle({
    Name = "Auto-Sell",
    CurrentValue = false,
    Flag = "OMAAutoSell",
    Callback = function(Value)
        Config.AutoSell = Value

        if Value then
            Rayfield:Notify({
                Title = "Inventario",
                Content =
                    "Desactivado de forma segura hasta verificar " ..
                    "qué personajes se venderían.",
                Duration = 5,
            })
        end
    end,
})

InventoryTab:CreateToggle({
    Name = "Auto-Delete Trash",
    CurrentValue = false,
    Flag = "OMAAutoDelete",
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Inventario",
                Content =
                    "No se eliminarán personajes sin verificar " ..
                    "sus rarezas e identificadores.",
                Duration = 5,
            })
        end
    end,
})

--==================================================
-- 11. PESTAÑA MEJORAS
--==================================================

local UpgradeTab = Window:CreateTab(
    "Mejoras",
    "trending-up"
)

UpgradeTab:CreateSection("Grado del personaje")

UpgradeTab:CreateToggle({
    Name = "Auto-Grade",
    CurrentValue = false,
    Flag = "OMAAutoGrade",
    Callback = function(Value)
        Config.AutoGrade = Value

        if Value then
            Rayfield:Notify({
                Title = "Mejoras",
                Content =
                    "Pendiente: verificar costes, grados y límites.",
                Duration = 5,
            })
        end
    end,
})

UpgradeTab:CreateParagraph({
    Title = "Mejoras seguras",
    Content =
        "Antes de gastar gemas automáticamente hay que conocer " ..
        "el coste por grado, el límite máximo y el personaje objetivo."
})

--==================================================
-- 12. PESTAÑA JUGADOR
--==================================================

local PlayerTab = Window:CreateTab(
    "Jugador",
    "user-round"
)

PlayerTab:CreateSection("Movimiento")

PlayerTab:CreateSlider({
    Name = "Velocidad",
    Range = {16, 100},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Flag = "OMAWalkSpeed",
    Callback = function(Value)
        Config.Velocidad = Value
        ApplyMovement()
    end,
})

PlayerTab:CreateSlider({
    Name = "Salto",
    Range = {25, 150},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "OMAJumpPower",
    Callback = function(Value)
        Config.Salto = Value
        ApplyMovement()
    end,
})

PlayerTab:CreateSection("Utilidades")

PlayerTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "OMAAntiAFK",
    Callback = function(Value)
        Config.AntiAFK = Value
        StartAntiAFK()
    end,
})

--==================================================
-- 13. INICIALIZACIÓN Y LIMPIEZA
--==================================================

ApplyMovement()
StartAntiAFK()

Rayfield:Notify({
    Title = "OMA FAMILY",
    Content = "Anime Dice Hub iniciado correctamente.",
    Duration = 5,
})

-- Para limpiar las conexiones si necesitas cerrar
-- manualmente este sistema desde tu propio código:
local function Cleanup()
    for _, Connection in pairs(Connections) do
        if typeof(Connection) == "RBXScriptConnection" then
            Connection:Disconnect()
        end
    end

    Connections = {}
end

-- No se ejecuta Cleanup() aquí porque cerraría el Anti-AFK.
-- Llama Cleanup() únicamente cuando quieras detener el sistema.

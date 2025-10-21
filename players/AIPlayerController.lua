AIPlayerController = {}
setmetatable(AIPlayerController, { __index = BasePlayerController })
AIPlayerController.__index = AIPlayerController

function AIPlayerController:new(player)
    local controller = BasePlayerController:new(player)
    controller.x = GAME_WIDTH - 250 - SPRITE_SIZE
    controller.y = 375
    controller.mirror = true

    controller.uiX = GAME_WIDTH - 25
    controller.textOffsetX = -25

    controller.idleAnim = resourceManager:newAnimation("evilWizardIdle")
    controller.deathAnim = resourceManager:newAnimation("evilWizardDeath")
    controller.castAnim = resourceManager:newAnimation("evilWizardCast")

    return setmetatable(controller, self)
end

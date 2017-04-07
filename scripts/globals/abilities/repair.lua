-----------------------------------
-- Ability: Repair
-- Uses oil to restore pet's HP.
-- Obtained: Puppetmaster Level 15
-- Recast Time: 3:00
-- Duration: Instant
-----------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/pets");

-----------------------------------
-- onAbilityCheck
-----------------------------------

function onAbilityCheck(player,target,ability)
    if (player:getPet() == nil) then
        return MSGBASIC_REQUIRES_A_PET,0;
    else
        local id = player:getEquipID(SLOT_AMMO);
        if (id >= 18731 and id <= 18733 or id == 19185) then
            return 0,0;
        else
            return MSGBASIC_UNABLE_TO_USE_JA,0;
        end
    end
end;

-----------------------------------
-- onUseAbility
-----------------------------------

function onUseAbility(player,target,ability)

    -- 1st need to get the pet food is equipped in the range slot.
    local rangeObj = player:getEquipID(SLOT_AMMO);
    local totalHealing = 0;
    local regenAmount = 0;
    local regenTime = 0;
    local pet = player:getPet();
    local petCurrentHP = pet:getHP();
    local petMaxHP = pet:getMaxHP();
    
    -- Need to start to calculate the HP to restore to the pet.
    -- Please note that I used this as base for the calculations:
    -- http://ffxiclopedia.wikia.com/wiki/Repair
    
    switch (rangeObj) : caseof {
        [18731] = function (x) -- Automaton Oil
            regenAmount = 10;
            totalHealing = petMaxHP * 0.1;
            regenTime = 30;
            end,
        [18732] = function (x) -- Automaton Oil + 1
            regenAmount = 20;
            totalHealing = petMaxHP * 0.2;
            regenTime = 60;
            end,
        [18733] = function (x) -- Automaton Oil + 2
            regenAmount = 30;
            totalHealing = petMaxHP * 0.3;
            regenTime = 90;
            end,
        [19185] = function (x) -- Automaton Oil + 3
            regenAmount = 40;
            totalHealing = petMaxHP * 0.4;
            regenTime = 120;
            end,
    }
        
    -- Now calculating the bonus based on gear.
    local feet = player:getEquipID(SLOT_FEET);
    local earring1 = player:getEquipID(SLOT_EAR1);    
    local earring2 = player:getEquipID(SLOT_EAR2);

    local function removeStatus()
        --if pet:delStatusEffect(EFFECT_DOOM) then return true end
        if pet:delStatusEffect(EFFECT_PETRIFICATION) then return true end
        --if pet:delStatusEffect(EFFECT_LULLABY) then return true end
        --if pet:delStatusEffect(EFFECT_SLEEP_II) then return true end
        --if pet:delStatusEffect(EFFECT_SLEEP) then return true end
        if pet:delStatusEffect(EFFECT_SILENCE) then return true end
        if pet:delStatusEffect(EFFECT_BANE) then return true end
        if pet:delStatusEffect(EFFECT_CURSE_II) then return true end
        if pet:delStatusEffect(EFFECT_CURSE) then return true end
        if pet:delStatusEffect(EFFECT_PARALYSIS) then return true end
        if pet:delStatusEffect(EFFECT_PLAGUE) then return true end
        if pet:delStatusEffect(EFFECT_POISON) then return true end
        if pet:delStatusEffect(EFFECT_DISEASE) then return true end
        if pet:delStatusEffect(EFFECT_BLINDNESS) then return true end
        if pet:eraseStatusEffect() ~= 255 then return true end
        return false
    end

    local toremove = 0
    
    if (feet == 11387 or feet == 15686 or feet == 28240) then
        toremove = 1
    elseif (feet == 28261 or feet == 23325) then
        toremove = 2
    elseif (feet == 23660) then
        toremove = 3
    end

    while toremove > 0 do
        if not removeStatus() then break end
        toremove = toremove - 1
    end
    
    if (earring1 == 15999 or earring2 == 15999) then  --Check for Guignol Earring
        regenAmount = regenAmount + 0.2 * regenAmount;
    end
        
    local diff = petMaxHP - petCurrentHP;

    if (diff < totalHealing) then
        totalHealing = diff;
    end

    pet:addHP(totalHealing);
    pet:wakeUp();

    -- Apply regen effect.

    pet:delStatusEffect(EFFECT_REGEN);
    pet:addStatusEffect(EFFECT_REGEN,regenAmount,3,regenTime); -- 3 = tick, each 3 seconds.
    player:removeAmmo();

    return totalHealing;
end;

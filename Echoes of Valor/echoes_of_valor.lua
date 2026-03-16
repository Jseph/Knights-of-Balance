require 'herorealms'
require 'decks'
require 'stdlib'
require 'timeoutai'
require 'hardai_2'
require 'aggressiveai'

function p1BuffDef()
    return createGlobalBuff({
        id = "starting_player_logic",
        name = "Starting Player, skills and Ogre",
        abilities = {
            createAbility({
                id = "expend_all_skills_start",
                trigger = startOfGameTrigger,
                effect = moveTarget(loc(ownerPid, skillSacrificePloc)).apply(selectLoc(loc(ownerPid, skillsPloc)))
            }),
            createAbility({
                id = "return_all_skills",
                trigger = endOfTurnTrigger,
                check = getTurnsPlayed(ownerPid).lte(1)
                    .And(selectLoc(loc(ownerPid, discardPloc)).count().lte(0)),
                effect = moveTarget(loc(ownerPid, skillsPloc)).apply(selectLoc(loc(ownerPid, skillSacrificePloc)))
            }),
            createAbility({
                id = "draw_logic_non_elves",
                trigger = endOfTurnTrigger,
                check = selectLoc(loc(ownerPid, buffsPloc)).where(isCardType(elfType)).count().lte(0),
                effect = drawCardsEffect(5)
            }),
            createAbility({
                id = "draw_logic_elf_t1_starter",
                trigger = endOfTurnTrigger,
                check = getTurnsPlayed(ownerPid).lte(1)
                    .And(selectLoc(loc(ownerPid, buffsPloc)).where(isCardType(elfType)).count().gte(1))
                    .And(
                        (selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                            .And(selectLoc(loc(oppPid, handPloc)).count().eq(5)))
                        .Or(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                            .And(selectLoc(loc(oppPid, handPloc)).count().eq(3)))
                    ),
                effect = drawCardsEffect(5)
            }),
            createAbility({
                id = "draw_logic_elf_t1_second",
                trigger = endOfTurnTrigger,
                check = getTurnsPlayed(ownerPid).lte(1)
                    .And(selectLoc(loc(ownerPid, discardPloc)).count().lte(0))
                    .And(selectLoc(loc(ownerPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(3)
            }),
            createAbility({
                id = "draw_logic_elf_t2+",
                trigger = endOfTurnTrigger,
                check = getTurnsPlayed(ownerPid).gte(2)
                    .And(selectLoc(loc(ownerPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(5)
            }),
            createAbility({
                id = "ogre_affordability",
                trigger = startOfGameTrigger,
                check = selectLoc(loc(ownerPid, buffsPloc)).where(isCardType(ogreType)).count().gte(1),
                effect = gainGoldEffect(1)
            })
        }
    })
end

function may_i_carddef()
    return createActionDef({
        id = "may_i",
        name = "May I?",
        types = {actionType, noStealType},
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "noElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc))
                    .union(selectLoc(loc(oppPid, buffsPloc)))
                    .where(isCardType(elfType)).count().lte(0),
                effect = drawCardsEffect(3).seq(drawToLocationEffect(5, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_currentPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)),
                effect = drawCardsEffect(1).seq(drawToLocationEffect(5, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_oppPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(3).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "twoElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(1).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "cleanMarket",
                trigger = onAcquireTrigger,
                effect = sacrificeTarget().apply(selectLoc(centerRowLoc).union(selectLoc(loc(currentPid, discardPloc))).where(isCardType(noStealType)))
                    .seq(moveTarget(loc(currentPid, skillsPloc)).apply(selectLoc(loc(currentPid, skillSacrificePloc))))
                                        .seq(createCardEffect(preventDualAbilityUse(), loc(currentPid, buffsPloc)))
            })
        },
        layout = createLayout({
            name = "May I?",
            art = "art/epicart/dark_offering",
            frame = "frames/coop_campaign_cardframe",
            text = "You start the game.",
        })
    })
end

function allow_me_carddef()
    return createActionDef({
        id = "allow_me",
        name = "Allow Me",
        types = {actionType, noStealType},
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "noElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc))
                    .union(selectLoc(loc(oppPid, buffsPloc)))
                    .where(isCardType(elfType)).count().lte(0),
                effect = drawCardsEffect(3).seq(drawToLocationEffect(5, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_currentPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)),
                effect = drawCardsEffect(1).seq(drawToLocationEffect(5, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_oppPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(3).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "twoElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(1).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "cleanMarket",
                trigger = onAcquireTrigger,
                effect = sacrificeTarget().apply(selectLoc(centerRowLoc).union(selectLoc(loc(currentPid, discardPloc))).where(isCardType(noStealType)))
                    .seq(moveTarget(loc(currentPid, skillsPloc)).apply(selectLoc(loc(currentPid, skillSacrificePloc))))
                    .seq(createCardEffect(preventDualAbilityUse(), loc(currentPid, buffsPloc)))
            }),
        },
        layout = createLayout({
            name = "Allow Me",
            art = "art/epicart/cast_out",
            frame = "frames/coop_campaign_cardframe",
            text = "You start the game.",
        })
    })
end

function after_you_carddef()
    return createActionDef({
        id = "after_you",
        name = "After You",
        types = {actionType, noStealType},
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "noElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc))
                    .union(selectLoc(loc(oppPid, buffsPloc)))
                    .where(isCardType(elfType)).count().lte(0),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_currentPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_oppPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(1, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "twoElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(1, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "cleanMarket",
                trigger = onAcquireTrigger,
                effect = sacrificeTarget().apply(selectLoc(centerRowLoc).union(selectLoc(loc(currentPid, discardPloc))).where(isCardType(noStealType)))
            }),
        },
        layout = createLayout({
            name = "After You",
            art = "art/epicart/inner_peace",
            frame = "frames/coop_campaign_cardframe",
            text = "Opponent starts the game.",
        })
    })
end

function go_ahead_carddef()
    return createActionDef({
        id = "go_ahead",
        name = "Please, Go Ahead",
        types = {actionType, noStealType},
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "noElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc))
                    .union(selectLoc(loc(oppPid, buffsPloc)))
                    .where(isCardType(elfType)).count().lte(0),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_currentPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "oneElf_oppPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(1, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "twoElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = drawCardsEffect(0).seq(drawToLocationEffect(1, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
            }),
            createAbility({
                id = "cleanMarket",
                trigger = onAcquireTrigger,
                effect = sacrificeTarget().apply(selectLoc(centerRowLoc).union(selectLoc(loc(currentPid, discardPloc))).where(isCardType(noStealType)))
            }),
        },
        layout = createLayout({
            name = "Please, Go Ahead",
            art = "art/epicart/blind_faith",
            frame = "frames/coop_campaign_cardframe",
            text = "Opponent starts the game.",
        })
    })
end

function let_s_see_carddef()
    return createActionDef({
        id = "let_s_see",
        name = "Let's See",
        types = {actionType, noStealType},
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "noElves",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)),
                effect = randomEffect({
                    valueItem(1, drawCardsEffect(3).seq(drawToLocationEffect(5, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
                        .seq(moveTarget(loc(currentPid, skillsPloc)).apply(selectLoc(loc(currentPid, skillSacrificePloc))))),
                    valueItem(1, drawCardsEffect(0).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))),
                })
            }),
            createAbility({
                id = "oneElf_currentPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)),
                effect = randomEffect({
                    valueItem(1, drawCardsEffect(1).seq(drawToLocationEffect(5, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
                        .seq(moveTarget(loc(currentPid, skillsPloc)).apply(selectLoc(loc(currentPid, skillSacrificePloc))))),
                    valueItem(1, drawCardsEffect(0).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))),
                })
            }),
            createAbility({
                id = "oneElf_oppPid",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().lte(0)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = randomEffect({
                    valueItem(1, drawCardsEffect(3).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
                        .seq(moveTarget(loc(currentPid, skillsPloc)).apply(selectLoc(loc(currentPid, skillSacrificePloc))))),
                    valueItem(1, drawCardsEffect(0).seq(drawToLocationEffect(1, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))),
                })
            }),
            createAbility({
                id = "twoElves0",
                trigger = onAcquireTrigger,
                check = selectLoc(loc(currentPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)
                    .And(selectLoc(loc(oppPid, buffsPloc)).where(isCardType(elfType)).count().gte(1)),
                effect = randomEffect({
                    valueItem(1, drawCardsEffect(1).seq(drawToLocationEffect(3, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))
                        .seq(moveTarget(loc(currentPid, skillsPloc)).apply(selectLoc(loc(currentPid, skillSacrificePloc))))),
                    valueItem(1, drawCardsEffect(0).seq(drawToLocationEffect(1, loc(oppPid, handPloc))).seq(sacrificeTarget().apply(selectSource()))),
                })
            }),
            createAbility({
                id = "cleanMarket",
                trigger = onSacrificeTrigger,
                effect = sacrificeTarget().apply(selectLoc(centerRowLoc).where(isCardType(noStealType))).seq(sacrificeTarget().apply(selectSource()))
                    .seq(createCardEffect(preventDualAbilityUse(), loc(currentPid, buffsPloc)))
            }),
        },
        layout = createLayout({
            name = "Let's See",
            art = "art/epicart/temporize",
            frame = "frames/coop_campaign_cardframe",
            text = "Let fate decide.",
        })
    })
end

function setupGame(g) 
    registerCards(g, {     --- THIS
        go_ahead_carddef(),
        let_s_see_carddef(),
        allow_me_carddef(),
        after_you_carddef(),
        may_i_carddef(),
    })
    standardSetup(g, {
        description = "Echoes of Valor<br>The Realms Rising Commuity Event<br>Official Script<br>Special Thanks to Emil",
        playerOrder = { plid1, plid2 },
        ai = ai.CreateKillSwitchAi(createAggressiveAI(),  createHardAi2()),
        timeoutAi = createTimeoutAi(),
        opponents = { { plid1, plid2 } },
        centerRow = { "may_i" , "allow_me" , "let_s_see" , "after_you" , "go_ahead" },  --- THIS
        players = {
            {
                id = plid1,
                startDraw = 0,
                init = {
                    fromEnv = plid1
                },
                cards = {
                    buffs = {
                        drawCardsCountAtTurnEndDef(0),--- THIS
                        p1BuffDef(),--- THIS
                        discardCardsAtTurnStartDef(),
                        fatigueCount(40, 1, "FatigueP1")
                    }
                }
            },
            {
                id = plid2,
                --isAi = true,
                startDraw = 0,
                init = {
                    fromEnv = plid2
                },
                cards = {
                    buffs = {
                        forceExplosion(),
                        drawCardsCountAtTurnEndDef(5),
                        discardCardsAtTurnStartDef(),
                        fatigueCount(40, 1, "FatigueP2")
                    }
                }
            }
        }
    })
end

function endGame(g)
end

            function setupMeta(meta)
                meta.name = "echoes_of_valor"
                meta.minLevel = 0
                meta.maxLevel = 0
                meta.introbackground = ""
                meta.introheader = ""
                meta.introdescription = ""
                meta.path = "C:/Users/xTheC/Desktop/Git Repositories/Knights-of-Balance/Echoes of Valor/echoes_of_valor.lua"
                meta.features = {}
end

function forceExplosion()
    --If Player 1 did not choose who was going first, player 2 goes first
    return createGlobalBuff({
        id="forced_explosion",
        name = "Forced Explosion",
        abilities = {
			createAbility({
                id="forced_ex_go",
                cost = sacrificeSelfCost,
                trigger = startOfTurnTrigger,
                effect = ifElseEffect(selectLoc(loc(currentPid, handPloc)).count().gte(1),
                                        nullEffect(),
                                        moveTarget(loc(oppPid, deckPloc)).apply(selectLoc(loc(oppPid, handPloc)).take(5))
                                        .seq(acquireForFreeTarget().apply(selectLoc(centerRowLoc).where(isCardName("may_i"))))
                                    )
            }),
        }
    })
end

function preventDualAbilityUse()
    --		
    return createGlobalBuff({
        id="prevent_dual_ability_use",
        name = "Prevent Dual Ability Use",
        abilities = {},
        cardEffectAbilities = {
			createCardEffectAbility({
                id="prevent_dual_use",
                cost = noCost,
                trigger =  locationChangedCardTrigger,
                activations = multipleActivations,
                effect = ifElseEffect(selectTargets().where(isCardAtLoc(skillSacrificePloc).And(isCardAbility()).And(isCardType(ancestryType).invert())).count().gte(1),
                                        disableTarget({ endOfTurnExpiry }).apply(selectLoc(loc(currentPid, skillsPloc)).where(isCardAbility().And(isCardType(ancestryType).invert())))
                                            .seq(sacrificeSelf()),
                                        nullEffect()
                                )
            }),
        }
    })
end


--Card Overrides
--=======================================================================================================
--
--Fighter
--=======================================================================================================
function fighter_rallying_flag_carddef()
        local cardLayout = createLayout({
            name = "Rallying Flag",
            art = "art/t_fighter_rallying_flag",
            frame = "frames/Warrior_CardFrame",
            cardTypeLabel = "Champion",
            isGuard = true,
            health = 1,
            types = { championType, humanType, fighterType },
            xmlText = [[<vlayout>
                            <box flexibleheight="1">
                                <tmpro text="{gold_1}   {combat_1}" fontsize="60"/>
                            </box>
                        </vlayout>]]
        })
        return createChampionDef({
            id = "fighter_rallying_flag",
            name = "Rallying Flag",
            acquireCost = 0,
            health = 1,
            isGuard = true,
            layout = cardLayout,
            types = { championType, humanType, fighterType },
            factions = {},
            abilities = {
                createAbility({
                    id = "fighter_rallying_flag",
                    trigger = autoTrigger,
                    activations = multipleActivations,
                    cost = expendCost,
                    effect = gainCombatEffect(1).seq(gainGoldEffect(1))
                }),
            }
        })
    end
    --=========================================
    function fighter_helm_of_fury_carddef()
        local cardLayout = createLayout({
            name = "Helm of Fury",
            art = "art/t_fighter_helm_of_fury",
            frame = "frames/Warrior_CardFrame",
            cardTypeLabel = "Magical Armor",
            xmlText =[[<vlayout>
                            <hlayout flexibleheight="1">
                                <box flexiblewidth="1">
                                    <tmpro text="{requiresHealth_20}" fontsize="72"/>
                                </box>
                                <box flexiblewidth="7">
                                    <tmpro text="If you have a guard in play,&lt;br&gt; gain {gold_1} {combat_1}" fontsize="32" />
                                </box>
                            </hlayout>
                    </vlayout>
                        ]]
        })
        local guardChamps = selectLoc(loc(currentPid, inPlayPloc)).where(isGuard()).count()
        local disableHelm = disableTarget({ endOfTurnExpiry }).apply(selectLoc(loc(currentPid, skillsPloc)).where(isCardType(magicArmorType)))
        --
        return createMagicArmorDef({
            id = "fighter_helm_of_fury",
            name = "Helm of Fury",
            types = {fighterType, magicArmorType, treasureType, headType},
            layout = cardLayout,
            layoutPath = "icons/fighter_helm_of_fury",
            abilities = {
                    createAbility({
                        id = "helmGuard",
                        trigger = autoTrigger,
                        check = minHealthCurrent(20).And(guardChamps.gte(1)),
                        effect = gainCombatEffect(1).seq(gainGoldEffect(1)).seq(disableHelm)
                    }),
                    createAbility({
                        id = "helmLateGuard",
                        trigger = onPlayTrigger,
                        activations = singleActivation,
                        check = minHealthCurrent(20),
                        effect = ifElseEffect(guardChamps.gte(1),
                                                gainCombatEffect(1).seq(gainGoldEffect(1)).seq(disableHelm),
                                                nullEffect()) 
                    }),
                    createAbility({
                        id = "helmHeal",
                        trigger = gainedHealthTrigger,
                        activations = singleActivation,
                        check = minHealthCurrent(20),
                        effect = ifElseEffect(guardChamps.gte(1),
                                                gainCombatEffect(1).seq(gainGoldEffect(1)).seq(disableHelm),
                                                nullEffect()) 
                    }),
            }        
        })
end

--Ranger
--=======================================================================================================
function ranger_honed_black_arrow_carddef()
    local cardLayout = createLayout({
        name = "Honed Black Arrow",
        art = "art/t_ranger_honed_black_arrow",
        frame = "frames/Ranger_CardFrame",
        cardTypeLabel = "Item",
        xmlText =[[<vlayout>
                    <hlayout flexibleheight="2">
                            <tmpro text="&lt;space=-0.3em/&gt;{combat_4}" fontsize="60" flexiblewidth="8" />
                    </hlayout>
                    <hlayout flexibleheight="3">
                            <tmpro text="If you have a bow in play, Draw a card." fontsize="28" flexiblewidth="1" />
                    </hlayout>
                </vlayout>]]
    })
    --
    local bowInPlay = selectLoc(loc(currentPid, castPloc)).where(isCardType(bowType)).count()
    --
    return createItemDef({
        id = "ranger_honed_black_arrow",
        name = "Honed Black Arrow",
        acquireCost = 0,
        cardTypeLabel = "Item",
        types = { itemType, noStealType, rangerType, arrowType},
        factions = {},
        layout = cardLayout,
        playLocation = castPloc,
            abilities = {
                createAbility({
					id = "ranger_honed_black_arrow_combat",
					effect =gainCombatEffect(4),
					cost = noCost,
					trigger = onPlayTrigger,
					playAllType = noPlayPlayType,
					tags = { gainCombatTag ,aiPlayAllTag }
				}),
                createAbility({
					id = "ranger_honed_black_arrow_draw",
					effect = drawCardsWithAnimation(1),
					cost = noCost,
					trigger = autoTrigger,
					activations = singleActivation,
					check = selectLoc(currentInPlayLoc).union(selectLoc(currentCastLoc)).where(isCardType(bowType)).count().gte(1),
					tags = { draw1Tag },
					aiPriority = ifInt(
						selectLoc(currentInPlayLoc).
						union(selectLoc(currentCastLoc)).
						where(isCardType(bowType)).count().gte(1), toIntExpression(300), toIntExpression(-1))
				})
                },
    })
end

--Cleric
--=======================================================================================================
function cleric_redeemed_ruinos_carddef()
    local cardLayout = createLayout({
        name = "Redeemed Ruinos",
        art = "art/t_cleric_redeemed_ruinos",
        frame = "frames/Cleric_CardFrame",
        cardTypeLabel = "Champion",
        isGuard = false,
        health = 2,
        types = { championType, noStealType, humanType, clericType, noKillType},
        xmlText = [[<vlayout forceheight="false" spacing="6">
                        <hlayout spacing="10">
                        <text text="When stunned, {health_2}." fontsize="32"/>
                        </hlayout>    
                        <divider/>
                        <hlayout forcewidth="true" spacing="10">
                            <icon text="{expend}" fontsize="52"/>
                            <vlayout  forceheight="false">
                        <icon text="{gold_1}" fontsize="46"/>
                            </vlayout>
                            <icon text=" " fontsize="20"/>
                        </hlayout>
                    </vlayout>
                    ]]
    })
    return createChampionDef({
        id = "cleric_redeemed_ruinos",
        name = "Redeemed Ruinos",
        acquireCost = 0,
        health = 2,
        isGuard = false,
        layout = cardLayout,
        factions = {},
        types = { championType, noStealType, humanType, clericType, noKillType},
        tags = {noAttackButtonTag},
        abilities = {
            createAbility({
                id = "cleric_redeemed_ruinos",
                trigger = autoTrigger,
                activations = multipleActivations,
                cost = expendCost,
                effect = gainGoldEffect(1)
            }),
            createAbility({
                id = "cleric_redeemed_ruinos_stunned",
                trigger = onStunTrigger,
                effect = healPlayerEffect(ownerPid, 2).seq(simpleMessageEffect("2 <sprite name=\"health\"> gained from Redeemed Ruinos")),
                tags = { gainHealthTag }
            })
        }
    })
end

function ruinosDrawBuff()
    return createGlobalBuff({
        id="cleric_redeemed_ruinos_stunned",
        name="Ruinos Draw",
        abilities = {
            createAbility({
                id = "ruinos_draw",
                triggerPriority = 10,
                trigger = startOfTurnTrigger,
                cost = sacrificeSelfCost,
                effect = drawCardsEffect(1)
            }),
        },
        buffDetails = createBuffDetails({
            name = "Redeemed Ruinos",
            art = "art/t_cleric_redeemed_ruinos",
            text = "Draw a card."
        })
    })
end

--=========================================
function cleric_brightstar_shield_carddef()
    local cardLayout = createLayout({
        name = "Brightstar Shield",
        art = "art/t_cleric_brightstar_shield",
        frame = "frames/Cleric_CardFrame",
        cardTypeLabel = "Item",
        xmlText =[[<vlayout>
                    <hlayout flexibleheight="3">
                            <tmpro text="Draw 1.&lt;br&gt; Attach this to a friendly champion.&lt;br&gt;Prepare it and it has +2 {shield}." fontsize="20" flexiblewidth="1" />
                    </hlayout>
                </vlayout>]]
    })
    local fetchShields = moveTarget(loc(ownerPid, discardPloc)).apply(selectLoc(loc(oppPid, asidePloc)))
    -- local fetchShields = moveTarget(loc(ownerPid, discardPloc)).apply(selectLoc(loc(currentPid, asidePloc)))
                            --.seq(moveTarget(loc(ownerPid, discardPloc)).apply(selectLoc(loc(oppPid, asidePloc))))
    --
    local  oneChamp =  prepareTarget().apply(selectLoc(loc(currentPid,inPlayPloc)))
                        .seq(grantHealthTarget(2, { SlotExpireEnum.LeavesPlay }, fetchShields, "shield").apply(selectLoc(loc(currentPid,inPlayPloc))))
                        .seq(moveTarget(asidePloc).apply(selectLoc(loc(currentPid, castPloc)).where(isCardName("cleric_brightstar_shield"))))
    --
    local  multiChamp = pushTargetedEffect({
                            desc="Choose a champion to prepare and gain +2 defense from brightstar shield",
                            min=1,
                            max=1,
                            validTargets = selectLoc(loc(currentPid,inPlayPloc)).where(isCardChampion()),
                            targetEffect = prepareTarget().seq(grantHealthTarget(2, { SlotExpireEnum.LeavesPlay },fetchShields,"shield").apply(selectTargets())),
                        })
                        .seq(moveTarget(asidePloc).apply(selectLoc(loc(currentPid, castPloc)).where(isCardName("cleric_brightstar_shield"))))
    --
    local numChamps =  selectLoc(loc(currentPid,inPlayPloc)).where(isCardChampion()).count()
    --
    return createItemDef({
        id = "cleric_brightstar_shield",
        name = "Brightstar Shield",
        acquireCost = 0,
        cardTypeLabel = "Item",
        types = { itemType, noStealType, clericType, attachmentType},
        factions = {},
        layout = cardLayout,
        playLocation = castPloc,
            abilities = {
                    createAbility({
                        id = "brightMain",
                        trigger = autoTrigger,
                        playAllType = blockPlayType,
                        effect = drawCardsEffect(1).seq(ifElseEffect(numChamps.eq(0),
                                                            nullEffect(),
                                                            ifElseEffect(numChamps.eq(1),
                                                            oneChamp,
                                                            multiChamp)))
                    }),
                },
    })
end

--=========================================
function cleric_shining_breastplate_carddef()
    local card_name = "cleric_shining_breastplate"
	local cardLayout = createLayout({
        name = "Shining Breastplate",
        art = "art/t_cleric_shining_breastplate",
        frame = "frames/Cleric_CardFrame",
        cardTypeLabel = "Magical Armor",
        xmlText =[[<hlayout spacing="1" forcewidth="true">
                    <icon text="{requiresHealth_25}" fontsize="90"/>    
                    <text text="If you are at full health or have +{health} this turn,
                put a champion without a cost from your discard into play." fontsize="18"/>
                    <text text=" " fontsize="80"/>
                </hlayout>]]
    })
	local noCostChamps = selectLoc(loc(currentPid, discardPloc)).where(isCardChampion().And(getCardCost().eq(0)))
    local gainedHealthKey = "gainedHealthThisTurn"
    local gainedHealthSlot = createPlayerSlot({ key = gainedHealthKey, expiry = { endOfTurnExpiry } })
    return createMagicArmorDef({
        id = card_name,
        name = "Shining Breastplate",
        description = "<sprite name=\"Point\"><color=#3BF2FF><b>Available at level </b></color> 9",
        acquireCost = 0,
        types = { clericType, magicArmorType, treasureType, chestType },
        tags = { clericGalleryCardTag },
        level = 9,
        abilities = {
            createAbility({
                id = card_name .. "_auto_armor_on_start_turn_ability",
                effect = pushTargetedEffect(
                    {
                        desc = "Choose a champion without a cost to put in play",
                        validTargets = noCostChamps,
                        min = 0,
                        max = 1,
                        targetEffect = moveTarget(currentInPlayLoc),
                        tags = {toughestTag}                        
                    }
                ),
                trigger = uiTrigger,
                cost = expendCost,
                check = getPlayerHealth(currentPid).eq(getPlayerMaxHealth(currentPid))
                            .Or(hasPlayerSlot(currentPlayer(), gainedHealthKey))
                            .And(noCostChamps.count().gte(1))
                            .And(getPlayerHealth(currentPid).gte(25)),
                tags = { gainCombatTag }
            }),
            createAbility({
                id = card_name .. "_track_health_gained",
                effect = addSlotToPlayerEffect(currentPlayer(), gainedHealthSlot),
                trigger = gainedHealthTrigger,
                cost = noCost,
                tags = { toughestTag }
            }),
        },
        layoutPath = "icons/" .. card_name,
        layout = cardLayout
    })
end

--Thief
--=======================================================================================================
function thief_silent_boots_carddef()
    --
    local cardLayout = createLayout({
						name = "Silent Boots",
						art = "art/t_thief_silent_boots",
						frame = "frames/Thief_armor_frame",
						xmlText = [[<vlayout>
                                    <hlayout flexibleheight="1">
                                        <box flexiblewidth="1.5">
                                            <tmpro text="{requiresHealth_10}" fontsize="72"/>
                                        </box>
                                        <box flexiblewidth="7">
                                            <tmpro text="Reveal the top two cards from the market deck and sacrifice one. You may acquire the other for &lt;br&gt;1 {gold} less or put it back." fontsize="20" />
                                        </box>
                                    </hlayout>
                                </vlayout>]]
    })
    --
    local cardLayoutBuy = createLayout({
                                    name = "Silent Boots",
                                    art = "art/t_thief_silent_boots",
                                    frame = "frames/Thief_armor_frame",
                                    xmlText = [[<vlayout>
                                                    <hlayout flexibleheight="1">
                                                        <box flexiblewidth="7">
                                                            <tmpro text="Acquire for 1 {gold} less." fontsize="26" />
                                                        </box>
                                                    </hlayout>
                                                </vlayout>]]
                            })
    --
    local cardLayoutTopDeck = createLayout({
                                    name = "Silent Boots",
                                    art = "art/t_thief_silent_boots",
                                    frame = "frames/Thief_armor_frame",
                                    xmlText = [[<vlayout>
                                                    <hlayout flexibleheight="1">
                                                        <box flexiblewidth="7">
                                                            <tmpro text="Put it back on the top of the market deck." fontsize="26" />
                                                        </box>
                                                    </hlayout>
                                                </vlayout>]]
                                })
    --                            
    local effReveal =  noUndoEffect().seq(moveTarget(revealPloc).apply(selectLoc(tradeDeckLoc).take(2).reverse())
                            .seq(pushTargetedEffect({
                                    desc="Select one card to Sacrifice. The other card may be acquired for 1 less or put back on top of the market deck.",
                                    min = 1,
                                    max = 1,
                                    validTargets = selectLoc(revealLoc),
                                    targetEffect = sacrificeTarget(),
                                })))
        --
    local checkSelector = selectLoc(revealLoc).Where(isCardAcquirable().And(getCardCost().lte(getPlayerGold(currentPid).add(toIntExpression(1)))))
    --
    local effTopOrBuy = noUndoEffect().seq(pushChoiceEffect({
                                choices={
                                    {
                                        effect = acquireTarget(1,discardPloc).apply(selectLoc(revealLoc)),
                                        layout = cardLayoutBuy,
                                        condition = checkSelector.count().gte(1),                      
                                    },
                                    {
                                        effect = moveTarget(tradeDeckLoc).apply(selectLoc(revealLoc)),            
                                        layout = cardLayoutTopDeck,
                                    }
                                }
                            }))
    --
    return createMagicArmorDef({
        id = "thief_silent_boots",
        name = "Silent Boots",
        types = { magicArmorType, thiefType, feetType, treasureType },
        layout = cardLayout,
        abilities = {
            createAbility({
                id = "triggerBoots",
				trigger = uiTrigger,
                layout = cardLayout,
				promptType = showPrompt,
                check =  minHealthCurrent(10),
                effect = noUndoEffect().seq(effTopOrBuy).seq(effReveal),
        }),
    },
		layoutPath = "icons/thief_silent_boots"
    })
end

--=========================================
function thief_enchanted_garrote_carddef()
    local cardLayout = createLayout({
        name = "Enchanted Garrote",
        art = "art/t_thief_enchanted_garrote",
        frame = "frames/Thief_CardFrame",
        cardTypeLabel = "Item",
        xmlText =[[<vlayout>
                    <hlayout flexibleheight="2.5">
                            <tmpro text="&lt;space=0.2em/&gt;{combat_1} {gold_1}" fontsize="50" flexiblewidth="8" />
                    </hlayout>
                    <hlayout flexibleheight="4">
                            <tmpro text="If you stun a champion this turn, gain {gold_1}" fontsize="20" flexiblewidth="1" />
                    </hlayout>
                </vlayout>]]
    })
    --Discard for chapions, Sacrificed for tokens
    local stunnedChamps = selectLoc(loc(oppPid, discardPloc)).union(selectLoc(loc(oppPid, sacrificePloc))).where(isCardStunned()).count()
    --
    return createItemDef({
        id = "thief_enchanted_garrote",
        name = "Enchanted Garrote",
        acquireCost = 0,
        cardTypeLabel = "Item",
        types = { itemType, noStealType, thiefType, garoteType, weaponType},
        factions = {},
        layout = cardLayout,
        playLocation = castPloc,
            abilities = {
                createAbility({
                    id = "garroteMain",
                    trigger = autoTrigger,
                    check = stunnedChamps.eq(0),
                    effect = gainCombatEffect(1).seq(gainGoldEffect(1)).seq(addSlotToPlayerEffect(currentPid, createPlayerSlot({ key = "champStunnedSlot", expiry = { endOfTurnExpiry } })))
                }),
                createAbility({
                    id = "garroteSlot",
                    trigger = autoTrigger,
                    check = hasPlayerSlot(currentPid, "champStunnedSlot").invert().And(stunnedChamps.gte(1)),
                    effect = gainCombatEffect(1).seq(gainGoldEffect(2))
                }),
                createAbility({
                    id = "garroteStun",
                    trigger = onStunGlobalTrigger,
                    activations = singleActivation,
                    effect = ifElseEffect(hasPlayerSlot(currentPid, "champStunnedSlot").And(stunnedChamps.gte(1)),
                                            gainGoldEffect(1),
                                            nullEffect()) 
                })
                },
    })
end

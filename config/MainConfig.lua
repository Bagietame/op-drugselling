Config = {}
Config.Locale = "en" -- Supported: EN / SK / CS / DE

-- Czech and Slovak languages by: iceyy4400 (discord id: 1057394957897441380)
-- German Language by: nameitsphil (discord id: 457672439510335498)

Config.Debug = false

-- 15% OFF WITH CODE "NEWCUSTOMER" at https://otherplanet.dev
-- Best Gangs Script for FiveM -> https://otherplanet.dev/product/gangs

Config.AdditionalScripts = {
    op_Gangs = true, -- https://otherplanet.dev/product/gangs
}

Config.LevelCommand = "mylevel" -- Check current player level and boost. Set it to false to disable.

Config.dispatchScript = "none" 
-- Supported:
-- none
-- cd_dispatch 
-- codem_dispatch 
-- lb-tablet 
-- ps-dispatch 
-- origen_police
-- piotreq_gpt
-- rcore_dispatch
-- kartik-mdt

Config.CurrencySettings = {
    -- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat
    currency = "USD",
    style = "currency",
    format = "en-US"
}

Config.Misc = {
    AccessMethod = "ox-target", -- Supported: ox-target / qb-target
    Notify = "ox_lib", 
    -- Supported:
    -- op_hud 
    -- okokNotify 
    -- vms_notify 
    -- brutal_notify 
    -- ox_lib 
    -- ESX 
    -- QBCORE 
    -- QBOX
}

Config.DirtyMoney = {
    -- This is Dirty Money item name.
    -- It works only for QB/QBOX
    -- ESX Handles dirty money using balance black_money
    itemName = "black_money"
}

Config.DrugSelling = {
    availableDrugs = {
        -- Create items in your inventory - https://docs.otherplanet.dev
        ["weed"] = {
            itemName = "weed",
            label = "Weed",
            minimumPrice = 50,
            optimalPrice = 80,
            maximumPrice = 100,
            maxAmountPedTransaction = 5,
            handPropName = "prop_weed_bottle",
            icon = "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_weed.png",
        },
        ["meth"] = {
            itemName = "meth",
            label = "Meth",
            minimumPrice = 150,
            optimalPrice = 180,
            maximumPrice = 250,
            maxAmountPedTransaction = 7,
            handPropName = "p_meth_bag_01_s",
            icon = "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_meth.png",
        },
        ["cocaine"] = {
            itemName = "cocaine",
            label = "Cocaine",
            minimumPrice = 450,
            optimalPrice = 580,
            maximumPrice = 700,
            maxAmountPedTransaction = 4,
            handPropName = "p_meth_bag_01_s",
            icon = "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_cocaine.png",
        }
    },
    dispatchCallChance = 15, -- 15% Chance that after transaction dispatch will be called.
    blipData = {
        -- Dispatch Blips Data
        sprite = 51, -- Blip sprite
        color = 1, -- Blip color
    }
}

Config.CornerDealing = {
    Enable = true, 
    SellTimeout = 5, -- Time in second after which next ped will be spawned In Corner Mode.
    Command = "startselling",
}

Config.Leveling = {
    Enable = true,
    LevelEXP = 50, -- One level == 500 exp.
    LevelsList = {
        [1] = 1, -- 1% Boost for level.
        [2] = 2, -- 2% Boost for level.
        [3] = 3, -- 3% Boost for level.
        [4] = 4, -- 4% Boost for level.
        [5] = 5, -- 5% Boost for level.
    }
}

Config.PedTypes = {
    ['addicted'] = {
        label = "Addicted",
        saleEXP = 5, -- EXP per Sale.
        stealDrugChance = 30, -- Chance that ped will steal your drugs!
        buyChance = 80, -- Range 0-100
        refuseChance = 0, -- Range 0-100 (This is refuse without even open of drug dealing menu)
        dispatchCall = false, -- Can this type of ped call dispatch
        colors = {
            -- Label Box next to ped Name.
            border = "#8400ff",
            background = "#8400ff8c"
        }
    },
    ['normal'] = {
        label = "Normal",
        saleEXP = 25, -- EXP per Sale.
        stealDrugChance = 10, -- Chance that ped will steal your drugs!
        buyChance = 50, -- Range 0-100
        refuseChance = 15, -- Range 0-100 (This is refuse without even open of drug dealing menu)
        dispatchCall = true, -- Can this type of ped call dispatch
        colors = {
            -- Label Box next to ped Name.
            border = "#00ccffff",
            background = "#00aeff8c"
        }
    },
    ['party'] = {
        label = "Party",
        saleEXP = 15, -- EXP per Sale.
        stealDrugChance = 10, -- Chance that ped will steal your drugs!
        buyChance = 75, -- Range 0-100
        refuseChance = 5, -- Range 0-100 (This is refuse without even open of drug dealing menu)
        dispatchCall = true, -- Can this type of ped call dispatch
        colors = {
            -- Label Box next to ped Name.
            border = "#ffa600ff",
            background = "#ffbb008c"
        }
    },
    ['snitch'] = {
        label = "Snitch",
        saleEXP = 40,
        stealDrugChance = 0, -- nie kradnie
        buyChance = 20, -- bardzo rzadko kupuje
        refuseChance = 50, -- często od razu odmawia
        dispatchCall = true, -- zawsze duże ryzyko wzywania policji
        colors = {
            border = "#ff0000",
            background = "#ff00008c"
        }
    },
    ['dealer'] = {
        label = "Street Dealer",
        saleEXP = 30,
        stealDrugChance = 20, -- może spróbować cię ograć
        buyChance = 60, -- kupi, ale w większych ilościach
        refuseChance = 10,
        dispatchCall = false, -- nie wzywa psów, bo sam kręci biznes
        colors = {
            border = "#00ff00",
            background = "#00ff008c"
        }
    },
    ['rich'] = {
        label = "Rich Guy",
        saleEXP = 10,
        stealDrugChance = 0,
        buyChance = 90, -- prawie zawsze kupuje
        refuseChance = 0,
        dispatchCall = true, -- czasami zadzwoni, jak się przestraszy
        colors = {
            border = "#ffd700",
            background = "#ffd7008c"
        }
    },
    ['junkie'] = {
        label = "Junkie",
        saleEXP = 5,
        stealDrugChance = 50, -- mega ryzyko kradzieży
        buyChance = 70,
        refuseChance = 10,
        dispatchCall = false, -- nie ogarnia policji
        colors = {
            border = "#8b4513",
            background = "#8b45138c"
        }
    },
    ['undercover'] = {
        label = "Undercover Cop",
        saleEXP = 50,
        stealDrugChance = 0,
        buyChance = 30, -- udaje że kupuje
        refuseChance = 0,
        dispatchCall = true, -- 100% szansa że poleci dispatch
        colors = {
            border = "#2121c4ff",
            background = "#0404ff69"
        }
    },
}

Config.PedsList = {
    -- Other Peds Not Listed Here will be handled like Normal Ped Type.
    -- [Addicted Peds]
    [`a_f_m_skidrow_01`] = 'addicted',
    [`g_m_y_ballasout_01`] = 'addicted',
    [`g_m_y_ballaeast_01`] = 'addicted',
    [`g_m_y_famca_01`] = 'addicted',
    [`g_m_y_famdnf_01`] = 'addicted',
    [`g_m_y_mexgoon_03`] = 'addicted',
    [`g_m_y_pologoon_01`] = 'addicted',
    [`g_m_y_pologoon_02`] = 'addicted',
    [`g_m_y_salvagoon_01`] = 'addicted',
    [`g_m_y_salvagoon_03`] = 'addicted',
    [`g_m_y_strpunk_01`] = 'addicted',

    -- [Party Peds]
    [`a_m_y_hipster_01`] = 'party',
    [`a_f_y_clubcust_01`] = 'party',
    [`a_m_y_clubcust_01`] = 'party',
    [`a_f_y_clubcust_02`] = 'party',
    [`a_m_y_clubcust_02`] = 'party',
    [`a_m_y_clubcust_03`] = 'party',
    [`csb_ramp_hipster`] = 'party',
    [`csb_ramp_mex`] = 'party',

    -- [Snitch Peds]
    [`a_m_m_business_01`] = 'snitch',
    [`a_m_m_eastsa_02`] = 'snitch',
    [`a_f_y_business_01`] = 'snitch',
    [`a_f_y_business_02`] = 'snitch',
    [`csb_reporter`] = 'snitch',

    -- [Dealer Peds]
    [`g_m_y_ballaorig_01`] = 'dealer',
    [`g_m_y_mexgang_01`] = 'dealer',
    [`g_m_y_mexgoon_01`] = 'dealer',
    [`g_m_y_famfor_01`] = 'dealer',
    [`g_m_y_strpunk_02`] = 'dealer',

    -- [Rich Peds]
    [`a_m_m_soucent_01`] = 'rich',
    [`a_m_y_bevhills_01`] = 'rich',
    [`a_f_y_bevhills_01`] = 'rich',
    [`a_f_y_bevhills_02`] = 'rich',
    [`u_m_y_imporage`] = 'rich',
    [`u_m_y_party_01`] = 'rich',

    -- [Junkie Peds]
    [`a_m_y_skater_01`] = 'junkie',
    [`a_m_y_skater_02`] = 'junkie',
    [`a_m_m_tramp_01`] = 'junkie',
    [`a_f_m_tramp_01`] = 'junkie',
    [`a_m_m_trampbeac_01`] = 'junkie',
    [`a_m_m_trampbeac_02`] = 'junkie',
    [`u_m_y_staggrm_01`] = 'junkie',

    -- [Undercover Cop Peds]
    [`s_m_m_ciasec_01`] = 'undercover',
    [`s_m_m_highsec_01`] = 'undercover',
    [`s_m_m_highsec_02`] = 'undercover',
    [`s_m_y_cop_01`] = 'undercover',
    [`csb_undercover`] = 'undercover'
}


-- Black list peds
Config.BlackListPeds = {
    [`a_m_m_skidrow_01`] = true,
}
import React, { useMemo, useState } from "react";
import { motion, Variants } from "framer-motion";
import "./Main.scss";
import { useDealingData } from "../../../data/DrugDealingData";
import { useLocaleState } from "../../../utils/locale";
import { useTypewriter } from "../../../utils/typeWritter";
import { Item } from "../../../data/DrugDealingData";
import { fetchNui } from "../../../utils/fetchNui";
import RangeInput from "./Addon/RangeInput";
import { useFormatMoney } from "../../../utils/formatMoney";

const Main: React.FC = () => {
    const Locale = useLocaleState();
    const dealingData = useDealingData();
    const randomIndex = useMemo(() => Math.floor(Math.random() * 19) + 1, []);
    const [selectedDrug, selectDrug] = useState<Item>(dealingData.playerDrugs[0])
    const [secondPart, setSecondPart] = useState<boolean>(false)
    const [drugPrice, setDrugPrice] = useState<number>(0)
    const formatMoney = useFormatMoney()

    const welcomeText = Locale["dealing_welcometext_" + randomIndex] || "";
    const typedText = useTypewriter(welcomeText, 40);
    const done = typedText.length === welcomeText.length && welcomeText.length > 0;

    const menuInner: Variants = {
        visible: {
            opacity: 1,
            scale: 1,
            y: 0,
            transition: { duration: 0.28, ease: [0.22, 1, 0.36, 1] },
        }
    };

    const btnsContainer: Variants = {
        hidden: { opacity: 0, height: 0 },
        visible: {
            opacity: 1,
            height: "auto",
            transition: { delayChildren: 0.05, staggerChildren: 0.12 },
        },
    };

    const performDrugSell = () => {
        fetchNui('drugSell', {name: selectedDrug.spawn_name, price: drugPrice})
    }

    return (
        <div id="wrapper">
            <div id="drugSellingMenu">
                <motion.div
                    className="menuInner"
                    variants={menuInner}
                    initial="hidden"
                    animate="visible"
                >
                    <div className="Header">
                        <h1>
                            {dealingData.pedName} <span style={{border: `1px solid ${dealingData.pedBorder}`, backgroundColor: dealingData.pedBg}}>{dealingData.pedType}</span>
                        </h1>
                        <p>{Locale['loyality'] ? Locale['loyality'].replace("%a", String(dealingData.playerLevel)).replace("%b", String(dealingData.playerBoost)) : ""}</p>
                    </div>

                    <div id="questionBox">
                        {!secondPart && (
                            <h1>
                                {typedText}
                                {!done && <span className="cursor">|</span>}
                            </h1>
                        )}

                        {(done && !secondPart) && (
                            <motion.div id="btns" variants={btnsContainer} initial="hidden" animate="visible">
                                <button
                                    className="success"
                                    onClick={() => { setDrugPrice(selectedDrug.normalPrice); setSecondPart(true) }}
                                >
                                    {Locale["dealing_answertext_" + randomIndex]}
                                </button>

                                <button
                                    className="error"
                                    onClick={() => { fetchNui('hideFrame') }}
                                >
                                    {Locale["dealing_nvw"]}
                                </button>
                            </motion.div>
                        )}

                        {secondPart && (
                            <motion.div
                                id="inputBox"
                                initial={{ opacity: 0, y: 8 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.22 }}
                            >
                                <motion.div
                                    id="topBox"
                                    initial={{ opacity: 0, y: 6 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.22, delay: 0.05 }}
                                >
                                    <img src={selectedDrug.icon}></img>
                                    <h2>{Locale['pricepergram']}</h2> 
                                    <p>{formatMoney(drugPrice)}</p>
                                </motion.div>

                                <motion.div
                                    className="rangeWrapper"
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    transition={{ duration: 0.18, delay: 0.08 }}
                                >
                                    <RangeInput
                                        id="range2"
                                        name="range2"
                                        min={selectedDrug.priceRangeMin}
                                        max={selectedDrug.priceRangeMax}
                                        step={1}
                                        initial={drugPrice}
                                        onChange={(v) => {
                                            setDrugPrice(v);
                                        }}
                                    />
                                </motion.div>

                                <motion.div
                                    id="btns"
                                    initial="hidden"
                                    animate="visible"
                                    variants={{
                                        hidden: { opacity: 0, y: 6 },
                                        visible: { opacity: 1, y: 0, transition: { staggerChildren: 0.09 } },
                                    }}
                                >
                                    <button className="success2" onClick={() => { performDrugSell() }}>
                                        {Locale["hereyougo"]}
                                    </button>

                                    <button className="error2" onClick={() => { fetchNui('hideFrame') }}>
                                        {Locale["dealing_nvw"]}
                                    </button>
                                </motion.div>
                            </motion.div>
                        )}

                    </div>
                </motion.div>
            </div>

            {(done && !secondPart) && (
                <motion.div
                    id="itemsList"
                    initial="hidden"
                    animate="visible"
                    variants={{
                        hidden: { opacity: 0, y: 10 },
                        visible: {
                            opacity: 1,
                            y: 0,
                            transition: { staggerChildren: 0.1 }
                        }
                    }}
                >
                    {dealingData.playerDrugs.map((drug, index) => (
                        <motion.div
                            key={drug.label ?? index}
                            className={selectedDrug.label === drug.label ? "item selectedItem" : "item"}
                            variants={{
                                hidden: { opacity: 0, y: 8 },
                                visible: { opacity: selectedDrug.label === drug.label ? 1 : 0.5, y: 0 }
                            }}
                            onClick={() => { selectDrug(drug) }}
                        >
                            <img src={drug.icon} alt={drug.label ?? "drug"} />
                            <p>x{drug.amount}</p>
                        </motion.div>
                    ))}
                </motion.div>
            )}

        </div>
    );
};

export default Main;
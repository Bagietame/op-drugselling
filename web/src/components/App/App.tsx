import React, { useState, useEffect } from "react";
import { isEnvBrowser } from "../../utils/misc";
import { fetchNui } from "../../utils/fetchNui";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { useLocale } from "../../utils/locale";
import { SetCurrencyData } from "../../data/CurrencyData";
import { CurrencyData } from "../../data/CurrencyData";
import { AnimatePresence, motion } from "framer-motion";
import Main from "./DrugSelling/Main";
import { DrugDealingData, SetDealingData } from "../../data/DrugDealingData";

import "./App.scss";
import "../../demo/demo"

const App: React.FC = () => {
  const [drugSellingVisible, setDrugSellingVisible] = useState(false);
  const [currencyData, setCurrencyData] = SetCurrencyData()
  const [dealingData, setDealingData] = SetDealingData()

  useNuiEvent<boolean>('setDrugSellingVisible', setDrugSellingVisible);
  useNuiEvent<CurrencyData>('setCurrency', ({ format, style, currency }) => {
    setCurrencyData({
      format: format,
      style: style,
      currency: currency
    })
  })

  useNuiEvent<DrugDealingData>("setDrugDealingData", (data) => {
    setDealingData(data);
  });

  const toggleVisibility = (setter: React.Dispatch<React.SetStateAction<boolean>>) => () => {
    setter((prev) => !prev);
  };

  useEffect(() => {
    if (drugSellingVisible) {
      const keyHandler = (e: KeyboardEvent) => {
        if (["Escape"].includes(e.code)) {
          if (!isEnvBrowser()) fetchNui("hideFrame");
          else setDrugSellingVisible(false);
        }
      };
      window.addEventListener("keydown", keyHandler);

      return () => window.removeEventListener("keydown", keyHandler);
    }
  }, [drugSellingVisible]);

  const [Locale, setLocale] = useLocale()
  useNuiEvent<{
    locale: { [key: string]: string }
  }>('setLanguage', ({ locale }) => {
    const tempLocale = Locale
    for (const name in locale) {
      tempLocale[name] = locale[name]
    }
    setLocale(tempLocale)
    fetchNui('languageConfirmation', {})
  })

  return (
    <>
      {isEnvBrowser() ? <div style={{ position: 'fixed', zIndex: 500000 }}>
        <button onClick={toggleVisibility(setDrugSellingVisible)}>DRUGSELLING</button>
      </div> : ""}

      <div id="mainWrapper">
        <div id="displayElementsLayout" style={drugSellingVisible ? { zIndex: 7000 } : { zIndex: 0 }}>
          <AnimatePresence>
            {drugSellingVisible && (
              <motion.div
                id="displayElementsLayout"
                style={drugSellingVisible ? { zIndex: 5000 } : { zIndex: 0 }}
                initial={{ opacity: 0, y: 300, scale: 0.8 }}
                animate={{ opacity: 1, y: 0, scale: 1.0 }}
                exit={{ opacity: 0, y: 300, scale: 0.8 }}
                transition={{ duration: 0.3, ease: "easeOut" }}
              >
                <Main></Main>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

    </>
  );
};

export default App;
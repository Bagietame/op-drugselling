import { useCurrencyData } from "../data/CurrencyData";

export const useFormatMoney = () => {
  const currencyData = useCurrencyData();

  return (amount: number) => {
      return new Intl.NumberFormat(
          currencyData?.format ?? "en-US",
          {
              style: currencyData?.style ?? "currency",
              currency: currencyData?.currency ?? "USD",
              minimumFractionDigits: 0,
              maximumFractionDigits: 0
          }
      ).format(amount);
  };
};

import { useState, useEffect } from "react";

export const useMoneyAnimation = (targetValue: number, duration = 1500) => {
  const [displayValue, setDisplayValue] = useState(0);
  const formatMoney = useFormatMoney()

  useEffect(() => {
    let startTime: number | null = null;

    const updateValue = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const progress = Math.min((timestamp - startTime) / duration, 1);
      setDisplayValue(Math.floor(progress * targetValue));

      if (progress < 1) {
        requestAnimationFrame(updateValue);
      }
    };

    requestAnimationFrame(updateValue);
  }, [targetValue, duration]);

  return formatMoney(displayValue);
};

export const useMoneyAnimationValueable = (startValue: number, targetValue: number, duration = 800) => {
  const [displayValue, setDisplayValue] = useState(startValue);
  const formatMoney = useFormatMoney()

  useEffect(() => {
    let startTime: number | null = null;

    const updateValue = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const progress = Math.min((timestamp - startTime) / duration, 1);
      setDisplayValue(Math.floor(startValue + progress * (targetValue - startValue)));

      if (progress < 1) {
        requestAnimationFrame(updateValue);
      }
    };

    requestAnimationFrame(updateValue);
  }, [startValue, targetValue, duration]);

  return formatMoney(displayValue);
};

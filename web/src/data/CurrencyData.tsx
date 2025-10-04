import { atom, useAtomValue, useAtom } from "jotai";

export interface CurrencyData {
    format: string;
    style: "decimal" | "currency" | "percent" | "unit";
    currency: string;
}

const CurrencyeAtom = atom<CurrencyData>({
    format: "en-US",
    style: "currency", 
    currency: "USD"
});

export const useCurrencyData = () => useAtomValue(CurrencyeAtom);
export const SetCurrencyData = () => useAtom(CurrencyeAtom);

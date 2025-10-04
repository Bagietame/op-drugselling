import { atom, useAtomValue, useAtom } from "jotai";

export interface Item {
    spawn_name: string,
    label: string,
    amount: number,
    icon: string,
    normalPrice: number,
    priceRangeMin: number,
    priceRangeMax: number,
}

export interface DrugDealingData {
    pedType: string,
    pedBorder: string,
    pedBg: string,
    playerDrugs: Item[],
    pedName: string,
    playerLevel: number,
    playerBoost: number
}

const dealingAtom = atom<DrugDealingData>({
    pedType: "Addicted",
    pedBorder: "#00ccffff",
    pedBg: "#00aeff8c",
    playerLevel: 1,
    playerBoost: 1,
    playerDrugs: [
        {
            spawn_name: "weed",
            label: "Weed",
            amount: 13,
            icon: "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_weed.png",
            normalPrice: 150,
            priceRangeMin: 115,
            priceRangeMax: 240,
        },
        {
            spawn_name: "meth",
            label: "Meth",
            amount: 5,
            icon: "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_meth.png",
            normalPrice: 240,
            priceRangeMin: 200,
            priceRangeMax: 310,
        },
        {
            spawn_name: "cocaine",
            label: "Cocaine",
            amount: 2,
            icon: "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_cocaine.png",
            normalPrice: 240,
            priceRangeMin: 200,
            priceRangeMax: 310,
        },
    ],
    pedName: "Mike Rose",
});

export const useDealingData = () => useAtomValue(dealingAtom);
export const SetDealingData = () => useAtom(dealingAtom);
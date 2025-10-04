import {atom, useAtom, useAtomValue} from "jotai"

const locale = atom<{
    [key: string]: string
}>({})

export const useLocaleState = () => useAtomValue(locale)
export const useLocale = () => useAtom(locale)
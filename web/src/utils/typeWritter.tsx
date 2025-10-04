import { useEffect, useState } from "react";

export function useTypewriter(raw: unknown, speed = 40) {
  const text = typeof raw === "string" ? raw : (raw ?? "").toString();

  const [displayed, setDisplayed] = useState("");

  useEffect(() => {
    setDisplayed("");
    if (!text) return;

    let i = 0;
    const id = setInterval(() => {
      i += 1;
      setDisplayed(text.slice(0, i));
      if (i >= text.length) {
        clearInterval(id);
      }
    }, speed);

    return () => clearInterval(id);
  }, [text, speed]);

  return displayed;
}
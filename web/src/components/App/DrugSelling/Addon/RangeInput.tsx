import React, { useEffect, useRef, useState } from "react";
import "./RangeInput.scss"

type Props = {
  id?: string;
  name?: string;
  min?: number;
  max?: number;
  step?: number;
  initial?: number;
  onChange?: (value: number) => void;
};

const RangeInput: React.FC<Props> = ({
  id,
  name,
  min = 0,
  max = 100,
  step = 1,
  initial,
  onChange,
}) => {
  const start = typeof initial === "number" ? initial : min;
  const [value, setValue] = useState<number>(start);
  const ref = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const pct = ((value - min) / (max - min)) * 100;
    el.style.setProperty("--percent", `${pct}%`);
  }, [value, min, max]);

  useEffect(() => {
    onChange?.(value);
  }, [value, onChange]);

  return (
    <div className="RangeMenu">
      <input
        ref={ref}
        id={id}
        name={name}
        className="RangeMenu__input"
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        onChange={(e) => setValue(Number(e.target.value))}
        aria-valuemin={min}
        aria-valuemax={max}
        aria-valuenow={value}
      />

      <div className="RangeMenu__labels">
        <span>{min}</span>
        <span>{max}</span>
      </div>
    </div>
  );
};

export default RangeInput;
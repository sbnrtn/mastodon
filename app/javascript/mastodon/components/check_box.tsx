interface Props {
  value: string;
  checked: boolean;
  name: string;
  onChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  label: React.ReactNode;
}

export const CheckBox: React.FC<Props> = ({
  name,
  value,
  checked,
  onChange,
  label,
}) => {
  return (
    <label className='check-box'>
      <input
        name={name}
        type='checkbox'
        value={value}
        checked={checked}
        onChange={onChange}
      />

      <span className='character-counter'>{label}</span>
    </label>
  );
};

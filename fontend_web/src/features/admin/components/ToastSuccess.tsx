interface ToastSuccessProps {
  message: string;
  onClose?: () => void;
}

export default function ToastSuccess({ message, onClose }: ToastSuccessProps) {
  return (
    <div className="fixed top-[104px] right-10 w-96 px-4 py-2 bg-lime-50 rounded-sm border border-lime-200 flex justify-between items-center shadow-md animate-fade-in z-50">
      <div className="text-black/90 text-lg font-normal font-['Roboto'] leading-snug">
        {message}
      </div>
      {onClose && (
        <button
          onClick={onClose}
          className="text-lime-700 font-bold text-xl px-2 hover:text-lime-900"
        >
          ×
        </button>
      )}
    </div>
  );
}

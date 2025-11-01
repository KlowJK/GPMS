import { useState } from 'react';
import { UploadCloud } from 'lucide-react';

type Props = { onClose: () => void; onSubmit: (file: File) => Promise<any>; };

export default function ImportStudentsModal({ onClose, onSubmit }: Props) {
  const [file, setFile] = useState<File | null>(null);

  async function handleSubmit() {
    if (!file) return;
    await onSubmit(file);
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[520px]">
        <h2 className="text-xl font-semibold mb-4">Thêm tài khoản</h2>

        <label className="block text-sm text-slate-600 mb-1">File danh sách sinh viên (Excel):</label>
        <div className="w-full border-2 border-dashed rounded-lg p-6 text-center">
          <div className="flex flex-col items-center gap-2">
            <UploadCloud size={24} className="text-slate-400" />
            <input type="file" accept=".xlsx,.xls" onChange={(e) => setFile(e.target.files?.[0] ?? null)} />
            {!file && <div className="text-slate-500 text-sm">Kéo & thả tệp tại đây</div>}
            {file && <div className="mt-1 text-sm">{file.name}</div>}
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button disabled={!file} onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-40">
            Lưu
          </button>
        </div>
      </div>
    </div>
  );
}

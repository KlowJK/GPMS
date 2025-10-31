import { useMemo, useState } from 'react';
import assistantService from '@features/assistants/services/assistantService';
import type { Lecturer, Subject } from '@features/assistants/services/assistantService';

export type LecturerCreatePayload = {
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocVi?: string;
  hocHam?: string;
  email: string;
  matKhau: string;
  idBoMon: string | number;
};
export type LecturerUpdatePayload = Omit<LecturerCreatePayload, 'matKhau'> & {
  laTruongBoMon?: boolean;
};

type Props = {
  initial?: Lecturer;
  subjects: Subject[];
  onClose: () => void;
  onSubmit: (data: LecturerCreatePayload | LecturerUpdatePayload) => Promise<any>;
};

function toId(v: string | number) {
  return typeof v === 'number' ? v : (/^\d+$/.test(v) ? Number(v) : v);
}

export default function LecturerFormModal({ initial, subjects, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);

  const [maGiangVien, setMaGiangVien] = useState(initial?.maGiangVien ?? '');
  const [hoTen, setHoTen] = useState(initial?.hoTen ?? '');
  const [soDienThoai, setSoDienThoai] = useState(initial?.soDienThoai ?? '');
  const [hocVi, setHocVi] = useState(initial?.hocVi ?? '');
  const [hocHam, setHocHam] = useState(initial?.hocHam ?? '');
  const [email, setEmail] = useState(initial?.email ?? '');
  const [matKhau, setMatKhau] = useState('');
  const [idBoMon, setIdBoMon] = useState<string>(String(initial?.idBoMon ?? subjects[0]?.id ?? ''));
  const [laTruongBoMon, setLaTruongBoMon] = useState<boolean>(Boolean(initial?.laTruongBoMon));

  async function handleSubmit() {
    let saved = initial;

    if (isEdit) {
      const payload: LecturerUpdatePayload = {
        maGiangVien, hoTen, soDienThoai, hocVi, hocHam, email, idBoMon, laTruongBoMon,
      };
      saved = await onSubmit(payload);
    } else {
      const payload: LecturerCreatePayload = {
        maGiangVien, hoTen, soDienThoai, hocVi, hocHam, email, matKhau, idBoMon,
      };
      saved = await onSubmit(payload);
    }

    // Gán/huỷ trưởng bộ môn theo checkbox
    try {
      await assistantService.setSubjectHead({
        idBoMon: toId(idBoMon),
        idGiangVien: laTruongBoMon ? (saved?.id ?? initial?.id)! : null,
      });
    } catch {
      /* ignore */
    }

    onClose();
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[760px]">
        <h2 className="text-xl font-semibold mb-4">{isEdit ? 'Sửa tài khoản' : 'Thêm tài khoản'}</h2>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-slate-600 mb-1">Mã giảng viên</label>
            <input className="w-full h-11 rounded border px-3" value={maGiangVien} onChange={e => setMaGiangVien(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Họ và tên</label>
            <input className="w-full h-11 rounded border px-3" value={hoTen} onChange={e => setHoTen(e.target.value)} />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Số điện thoại</label>
            <input className="w-full h-11 rounded border px-3" value={soDienThoai} onChange={e => setSoDienThoai(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Email</label>
            <input type="email" className="w-full h-11 rounded border px-3" value={email} onChange={e => setEmail(e.target.value)} />
          </div>

          {!isEdit && (
            <div>
              <label className="block text-sm text-slate-600 mb-1">Mật khẩu</label>
              <input type="password" className="w-full h-11 rounded border px-3" value={matKhau} onChange={e => setMatKhau(e.target.value)} />
            </div>
          )}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Bộ môn</label>
            <select className="w-full h-11 rounded border px-3 bg-white" value={idBoMon} onChange={e => setIdBoMon(e.target.value)}>
              {subjects.map(s => <option key={`${s.id}`} value={String(s.id)}>{s.tenBoMon}</option>)}
            </select>

            <label className="mt-2 inline-flex items-center gap-2 select-none">
              <input type="checkbox" className="h-4 w-4"
                     checked={laTruongBoMon}
                     onChange={(e) => setLaTruongBoMon(e.target.checked)} />
              <span className="text-sm">Đặt làm Trưởng bộ môn</span>
            </label>
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Học vị</label>
            <input className="w-full h-11 rounded border px-3" value={hocVi} onChange={e => setHocVi(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Học hàm</label>
            <input className="w-full h-11 rounded border px-3" value={hocHam} onChange={e => setHocHam(e.target.value)} />
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white">
            {isEdit ? 'Cập nhật' : 'Lưu'}
          </button>
        </div>
      </div>
    </div>
  );
}

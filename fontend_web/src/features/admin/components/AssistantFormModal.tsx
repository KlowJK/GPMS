import { useMemo, useState } from 'react';
import type { KhoaAssistant } from '@features/admin/services/adminService';

// Payloads đúng yêu cầu BE
export type AssistantCreatePayload = {
  hoTen: string;
  email: string;
  matKhau: string;       // không giới hạn
  soDienThoai?: string;  // không giới hạn
  diaChi?: string;
};
export type AssistantUpdatePayload = Omit<AssistantCreatePayload, 'matKhau'>;

type Props = {
  initial?: (KhoaAssistant & { diaChi?: string });
  onClose: () => void;
  // CHÚ Ý: onSubmit nhận thêm setEmailErr để hiển thị lỗi ngay trong modal
  onSubmit: (
    data: AssistantCreatePayload | AssistantUpdatePayload,
    setEmailErr: (msg?: string) => void
  ) => Promise<any>;
};

export default function AssistantFormModal({ initial, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);

  const [hoTen, setHoTen] = useState(initial?.hoTen ?? '');
  const [email, setEmail] = useState(initial?.email ?? '');
  const [soDienThoai, setSoDienThoai] = useState(initial?.soDienThoai ?? '');
  const [diaChi, setDiaChi] = useState(initial?.diaChi ?? '');
  const [matKhau, setMatKhau] = useState(''); // chỉ hiển thị khi tạo mới
  const [emailErr, setEmailErr] = useState<string | undefined>(undefined);

  function validateEmailFormat(v: string) {
    // regex nhẹ nhàng đủ dùng cho UI
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(v);
  }

  async function handleSubmit() {
    // kiểm tra định dạng email trước
    if (!validateEmailFormat(email)) {
      setEmailErr('Email không hợp lệ');
      return;
    }

    if (!isEdit) {
      const payload: AssistantCreatePayload = { hoTen, email, matKhau, soDienThoai, diaChi };
      await onSubmit(payload, setEmailErr);
    } else {
      const payload: AssistantUpdatePayload = { hoTen, email, soDienThoai, diaChi };
      await onSubmit(payload, setEmailErr);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[560px]">
        <h2 className="text-xl font-semibold mb-4">
          {isEdit ? 'Sửa trợ lý khoa' : 'Thêm trợ lý khoa'}
        </h2>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-slate-600 mb-1">Họ tên</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={hoTen}
              onChange={(e) => setHoTen(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Email</label>
            <input
              type="email"
              className={`w-full h-11 rounded border px-3 ${emailErr ? 'border-red-500' : ''}`}
              value={email}
              onChange={(e) => { setEmail(e.target.value); setEmailErr(undefined); }}
            />
            {emailErr && <p className="mt-1 text-sm text-red-600">{emailErr}</p>}
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Số điện thoại</label>
            {/* không giới hạn/ép kiểu, để type="text" */}
            <input
              type="text"
              className="w-full h-11 rounded border px-3"
              value={soDienThoai}
              onChange={(e) => setSoDienThoai(e.target.value)}
              placeholder="Nhập SĐT"
            />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Địa chỉ</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={diaChi}
              onChange={(e) => setDiaChi(e.target.value)}
            />
          </div>

          {!isEdit && (
            <div className="col-span-2">
              <label className="block text-sm text-slate-600 mb-1">Mật khẩu</label>
              {/* không giới hạn độ dài */}
              <input
                type="password"
                className="w-full h-11 rounded border px-3"
                value={matKhau}
                onChange={(e) => setMatKhau(e.target.value)}
                placeholder="Nhập mật khẩu"
              />
            </div>
          )}
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white">
            {isEdit ? 'Cập nhật' : 'Thêm'}
          </button>
        </div>
      </div>
    </div>
  );
}

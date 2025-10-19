import { useEffect, useState } from 'react'
import universityService, {
  unwrap,
  type Lecturer,
  type LecturerPayload,
  type LecturerRole,          // ← thêm import
} from '@features/admin/services/universityService'

type Mode = 'create' | 'edit'

export default function LecturerFormModal({
  open, mode, initial, onClose, onSaved,
}: {
  open: boolean
  mode: Mode
  initial?: Lecturer | null
  onClose: () => void
  onSaved: () => void
}) {
  const [subjects, setSubjects] = useState<{ id: number; tenBoMon: string; khoaId: number }[]>([])
  const [loading, setLoading] = useState(false)
  const [form, setForm] = useState<LecturerPayload>({
    email: '', maGiangVien: '', hoTen: '', soDienThoai: '',
    matKhau: '', hocHam: '', hocVi: '', vaiTro: 'GIANG_VIEN', boMonId: undefined,
  })

  useEffect(() => {
    if (!open) return
    universityService.getSubjects({ size: 1000 })  // ← service giờ đã nhận params
      .then((res) => {
        const data = unwrap<{ content?: any[] }>(res)
        const list = (data?.content ?? data ?? []) as any[]
        setSubjects(list.map(x => ({ id: x.id, tenBoMon: x.tenBoMon, khoaId: x.khoaId })))
      })
      .catch(() => setSubjects([]))
  }, [open])

  useEffect(() => {
    if (mode === 'edit' && initial) {
      setForm({
        email: initial.email ?? '',
        maGiangVien: initial.maGiangVien ?? '',
        hoTen: initial.hoTen ?? '',
        soDienThoai: initial.soDienThoai ?? '',
        matKhau: '',
        hocHam: initial.hocHam ?? '',
        hocVi: initial.hocVi ?? '',
        vaiTro: initial.vaiTro ?? 'GIANG_VIEN',
        boMonId: initial.boMonId,
      })
    } else if (mode === 'create') {
      setForm(f => ({ ...f, matKhau: '' }))
    }
  }, [mode, initial])

  function update<K extends keyof LecturerPayload>(key: K, val: LecturerPayload[K]) {
    setForm(prev => ({ ...prev, [key]: val }))
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    try {
      if (mode === 'create') {
        await universityService.createLecturer(form)
      } else if (initial?.id != null) {
        const { matKhau, ...rest } = form
        await universityService.updateLecturer(initial.id, rest)
      }
      onSaved()
      onClose()
    } finally {
      setLoading(false)
    }
  }

  if (!open) return null

  return (
    <div className="fixed inset-0 z-[9999] grid place-items-center bg-black/40">
      <div className="bg-white w-[720px] rounded-2xl shadow-xl p-6">
        <h3 className="text-xl font-semibold mb-4">{mode === 'create' ? 'Thêm tài khoản' : 'Sửa tài khoản'}</h3>

        <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-5">
          {/* Mã GV / Họ tên */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Mã giảng viên</label>
            <input className="w-full h-11 rounded-lg border px-3" value={form.maGiangVien}
                   onChange={e => update('maGiangVien', e.target.value)} required />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Họ và tên</label>
            <input className="w-full h-11 rounded-lg border px-3" value={form.hoTen}
                   onChange={e => update('hoTen', e.target.value)} required />
          </div>

          {/* SĐT / Email */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Số điện thoại</label>
            <input className="w-full h-11 rounded-lg border px-3" value={form.soDienThoai ?? ''}
                   onChange={e => update('soDienThoai', e.target.value)} />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Email</label>
            <input type="email" className="w-full h-11 rounded-lg border px-3" value={form.email}
                   onChange={e => update('email', e.target.value)} required />
          </div>

          {/* Mật khẩu chỉ khi thêm mới */}
          {mode === 'create' && (
            <div>
              <label className="block text-sm text-slate-600 mb-1">Mật khẩu</label>
              <input type="password" className="w-full h-11 rounded-lg border px-3" value={form.matKhau ?? ''}
                     onChange={e => update('matKhau', e.target.value)} required />
            </div>
          )}
          {mode === 'create' && <div />}

          {/* Vai trò */}
          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-2">Vai trò</label>
            <div className="flex gap-6">
              {(['GIANG_VIEN', 'TRO_LY_KHOA', 'TRUONG_BO_MON'] as LecturerRole[]).map(r => (
                <label key={r} className="inline-flex items-center gap-2">
                  <input type="radio" name="role" checked={form.vaiTro === r} onChange={() => update('vaiTro', r)} />
                  <span className="text-sm">
                    {r === 'GIANG_VIEN' ? 'Giảng viên' : r === 'TRO_LY_KHOA' ? 'Trợ lý khoa' : 'Trưởng bộ môn'}
                  </span>
                </label>
              ))}
            </div>
          </div>

          {/* Học hàm / Học vị */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Học hàm</label>
            <input className="w-full h-11 rounded-lg border px-3" value={form.hocHam ?? ''}
                   onChange={e => update('hocHam', e.target.value)} />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Học vị</label>
            <input className="w-full h-11 rounded-lg border px-3" value={form.hocVi ?? ''}
                   onChange={e => update('hocVi', e.target.value)} />
          </div>

          {/* Bộ môn */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Bộ môn</label>
            <select className="w-full h-11 rounded-lg border px-3 bg-white"
                    value={form.boMonId ?? ''} onChange={e => update('boMonId', e.target.value ? Number(e.target.value) : undefined)}>
              <option value="">— Chọn bộ môn —</option>
              {subjects.map(s => <option key={s.id} value={s.id}>{s.tenBoMon}</option>)}
            </select>
          </div>
          <div />

          {/* Actions */}
          <div className="col-span-2 flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="px-5 h-10 rounded-lg bg-slate-200">Quay lại</button>
            <button disabled={loading} className="px-5 h-10 rounded-lg bg-blue-600 text-white">
              {mode === 'create' ? 'Lưu' : 'Cập nhật'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

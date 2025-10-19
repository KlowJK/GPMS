import { useEffect, useState } from 'react'
import universityService, { unwrap, mapLecturer, type Lecturer } from '@features/admin/services/universityService'
import LecturerFormModal from '../components/LecturerFormModal'

export default function LecturerAccounts() {
  // search có debounce để tránh spam request
  const [keyword, setKeyword] = useState('')
  const [q, setQ] = useState('') // giá trị sau debounce

  const [rows, setRows] = useState<Lecturer[]>([])
  const [loading, setLoading] = useState(false)

  // modal
  const [open, setOpen] = useState(false)
  const [mode, setMode] = useState<'create' | 'edit'>('create')
  const [current, setCurrent] = useState<Lecturer | null>(null)

  // debounce 300ms
  useEffect(() => {
    const t = setTimeout(() => setQ(keyword.trim()), 300)
    return () => clearTimeout(t)
  }, [keyword])

  async function fetchData() {
    setLoading(true)
    try {
      const res = await universityService.getLecturers({
        page: 0,           // 0-based
        size: 50,
        ...(q ? { q } : {}) // chỉ gửi q khi có giá trị
      })
      const data = unwrap<any>(res)
      console.debug('[lecturers] data:', data)
      const list = (data?.content ?? data ?? []) as any[]
      setRows(list.map(mapLecturer))
    } catch (err: any) {
      console.error('[lecturers] fetch error:', err?.response?.status, err?.response?.data || err)
      setRows([])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q])

  function onAdd() {
    setMode('create'); setCurrent(null); setOpen(true)
  }
  function onEdit(item: Lecturer) {
    setMode('edit'); setCurrent(item); setOpen(true)
  }
  function onSaved() {
    // tải lại; BE đang sort thì bản ghi mới sẽ nằm đầu danh sách
    fetchData()
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-semibold">Danh sách tài khoản giảng viên</h1>
        <div className="flex gap-3">
          <input
            className="h-10 w-[360px] rounded-lg border px-3"
            placeholder="Tìm theo mã/tên/email…"
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
          />
          <button className="h-10 px-4 rounded-lg bg-blue-600 text-white" onClick={onAdd}>
            + Thêm tài khoản
          </button>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow overflow-hidden">
        <table className="min-w-full text-sm">
          <thead className="text-left text-slate-600">
            <tr className="border-b">
              <th className="p-3">Email</th>
              <th className="p-3">Mã giảng viên</th>
              <th className="p-3">Họ tên</th>
              <th className="p-3">Vai trò</th>
              <th className="p-3">Số điện thoại</th>
              <th className="p-3">Học hàm/Học vị</th>
              <th className="p-3">Trạng thái</th>
              <th className="p-3">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr><td className="p-8 text-center text-slate-500" colSpan={8}>Đang tải…</td></tr>
            )}
            {!loading && rows.length === 0 && (
              <tr><td className="p-8 text-center text-slate-500" colSpan={8}>Không có dữ liệu.</td></tr>
            )}
            {!loading && rows.map((u) => (
              <tr key={`${u.id}`} className="border-b hover:bg-slate-50">
                <td className="p-3">{u.email}</td>
                <td className="p-3">{u.maGiangVien}</td>
                <td className="p-3">{u.hoTen}</td>
                <td className="p-3">
                  {u.vaiTro === 'GIANG_VIEN' ? 'Giảng viên'
                    : u.vaiTro === 'TRO_LY_KHOA' ? 'Trợ lý khoa'
                    : 'Trưởng bộ môn'}
                </td>
                <td className="p-3">{u.soDienThoai ?? '—'}</td>
                <td className="p-3">{[u.hocHam, u.hocVi].filter(Boolean).join(' / ') || '—'}</td>
                <td className="p-3">{u.trangThai ?? '—'}</td>
                <td className="p-3">
                  <button className="px-3 py-1 rounded border" onClick={() => onEdit(u)}>Sửa</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {open && (
        <LecturerFormModal
          open={open}
          mode={mode}
          initial={current ?? undefined}
          onClose={() => setOpen(false)}
          onSaved={onSaved}
        />
      )}
    </div>
  )
}

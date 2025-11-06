export type XetDuyetItem = {
  idDeTai: string
  maSV: string
  hoTen: string
  tenLop: string
  soDienThoai?: string
  tenDeTai?: string
  trangThai: 'CHO_XET_DUYET' | 'DA_DUYET' | 'TU_CHOI'
  tongQuanDeTaiUrl?: string | null
  duongDanCv?: string | null
  nhanXet?: string | null
}

import type { PhanTrang } from './PhanTrang'

export type PageXetDuyet = PhanTrang<XetDuyetItem>

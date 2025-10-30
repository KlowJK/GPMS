export type XetDuyetItem = {
  idDeTai: string
  maSV: string
  hoTen: string
  tenLop: string
  soDienThoai?: string
  tenDeTai?: string
  trangThai: 'CHO_XET_DUYET' | 'DA_DUYET' | 'TU_CHOI'
  tongQuanDeTaiUrl?: string | null
  nhanXet?: string | null
}

export type PageXetDuyet = {
  content: XetDuyetItem[]
  number: number
  size: number
  totalElements: number
  totalPages: number
  first: boolean
  last: boolean
}

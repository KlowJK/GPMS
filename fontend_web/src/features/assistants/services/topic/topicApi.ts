import { axios, unwrap, toPage, type Id, type Page, type PageParams }
  from '@/features/assistants/services/base';


/* ========= ĐỢT BẢO VỆ ========= */
export type DefenseRound = {
  id: Id;
  tenDotBaoVe: string;
  hocKi: string;
  namHoc: string;
  thoiGianBatDau: string;   // yyyy-MM-dd
  thoiGianKetThuc: string;  // yyyy-MM-dd
  trangThai?: boolean | null;   // BE cũ (nếu có)
  daKhoa?: boolean | null;      // BE mới có thể trả về: daKhoa/khoa/isLocked/locked
};

export type CreateUpdateDefenseRound = Omit<DefenseRound, 'id'>;

export const listDefenseRounds = (params?: PageParams) =>
  axios.get('/api/dot-bao-ve', { params });

export const createDefenseRound = (body: CreateUpdateDefenseRound) =>
  axios.post('/api/dot-bao-ve', body);

export const updateDefenseRound = (id: Id, body: CreateUpdateDefenseRound) =>
  axios.put(`/api/dot-bao-ve/${id}`, body);

export const deleteDefenseRound = (id: Id) =>
  axios.delete(`/api/dot-bao-ve/${id}`);

/** ✅ Khóa đợt */
export const lockDefenseRound = (id: Id) =>
  axios.put(`/api/dot-bao-ve/${id}/khoa`);

export const importStudentsToRound = (roundId: Id, file: File) => {
  const fd = new FormData();
  fd.append('file', file);
  // gửi kèm cả hai key để BE nào cũng nhận
  fd.append('dotBaoVeId', String(roundId));
  fd.append('idDotBaoVe', String(roundId));
  return axios.post('/api/dot-bao-ve/import-sinh-vien', fd, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
};
/* ========= THỜI GIAN THỰC HIỆN ========= */
export type RoundTime = {
  id: Id;
  congViec: string;
  thoiGianBatDau: string;
  thoiGianKetThuc: string;
  dotBaoVeId: Id;
};
export type CreateRoundTime = Omit<RoundTime, 'id'>;
export type UpdateRoundTime = Omit<RoundTime, 'id'>;

export type RoundTimeUI = RoundTime & { tenDotBaoVe?: string };

export function normalizeRoundTime(x: any): RoundTimeUI {
  const cut = (s: any) => (typeof s === 'string' ? s.slice(0, 10) : '');
  return {
    id: x.id ?? x.thoiGianThucHienId ?? x._id,
    congViec: x.congViec ?? x.task ?? 'NULL',
    thoiGianBatDau: cut(x.thoiGianBatDau ?? x.startDate),
    thoiGianKetThuc: cut(x.thoiGianKetThuc ?? x.endDate),
    dotBaoVeId: x.dotBaoVeId ?? x.idDotBaoVe ?? x.dotBaoVe?.id,
    tenDotBaoVe: x.tenDotBaoVe ?? x.dotBaoVe?.tenDotBaoVe,
  };
}

export const listRoundTimes = (params?: { dotBaoVeId?: Id }) =>
  axios.get('/api/thoi-gian-thuc-hien', { params });

export const createRoundTime = (body: CreateRoundTime) =>
  axios.post('/api/thoi-gian-thuc-hien', body);

export const updateRoundTime = (id: Id, body: UpdateRoundTime) =>
  axios.put(`/api/thoi-gian-thuc-hien/${id}`, body);

export async function listRoundTimesByRound(dotBaoVeId: Id): Promise<RoundTimeUI[]> {
  const res = await listRoundTimes({ dotBaoVeId });
  const raw = unwrap<any>(res);
  const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  const normalized: RoundTimeUI[] = arr.map((x) => normalizeRoundTime(x));
  return normalized.filter((it) => String(it.dotBaoVeId) === String(dotBaoVeId));
}

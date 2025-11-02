import { axios, unwrap, toPage, type Id, type Page, type PageParams }
  from '@/features/assistants/services/base';


/* ========= ĐỢT BẢO VỆ ========= */
export type DefenseRound = {
  id: Id;
  tenDotBaoVe: string;
  hocKi: string;
  namHoc: string;
  thoiGianBatDau: string;
  thoiGianKetThuc: string;
  trangThai?: boolean | null;
  daKhoa?: boolean | null;
  khoa?: boolean | null;
  isLocked?: boolean | null;
  locked?: boolean | null;
};

export type CreateUpdateDefenseRound = Omit<DefenseRound, 'id'>;

export type DefenseRoundUI = DefenseRound & {
  lockedFlag: boolean | null;
  statusText: 'Đang diễn ra' | 'Kết thúc' | '—';
};

export const listDefenseRounds = (params?: PageParams & { namHoc?: string; hocKi?: string }) =>
  axios.get('/api/dot-bao-ve', { params }); // ❗️không tự thêm mặc định

export const createDefenseRound = (body: CreateUpdateDefenseRound) =>
  axios.post('/api/dot-bao-ve', body);

export const updateDefenseRound = (id: Id, body: CreateUpdateDefenseRound) =>
  axios.put(`/api/dot-bao-ve/${id}`, body);

export const deleteDefenseRound = (id: Id) =>
  axios.delete(`/api/dot-bao-ve/${id}`);

/** Toggle khóa/mở đợt */
export const lockDefenseRound = (id: Id) =>
  axios.put(`/api/dot-bao-ve/${id}/khoa`);

/** Import SV – LẤY hocKi & namHoc TỪ OBJECT ROUND */
export const importStudentsToRound = (
  round: Id | { id: Id; hocKi?: string; namHoc?: string },
  file: File
) => {
  const fd = new FormData();

  // file: hỗ trợ cả 'file' lẫn 'dataFile'
  fd.append('file', file);
  fd.append('dataFile', file);

  const id = typeof round === 'object' ? round.id : round;
  const hocKi = typeof round === 'object' ? round.hocKi : undefined;
  const namHoc = typeof round === 'object' ? round.namHoc : undefined;

  // id đợt: gửi cả 2
  fd.append('dotBaoVeId', String(id));
  fd.append('idDotBaoVe', String(id));

  // học kì: alias để BE nào cũng bắt được
  if (hocKi) {
    fd.append('hocKi', hocKi);
    fd.append('hocKy', hocKi);
  }

  // năm học: alias để BE nào cũng bắt được
  if (namHoc) {
    fd.append('namHoc', namHoc);
    fd.append('nam_hoc', namHoc);
  }

  return axios.post('/api/dot-bao-ve/import-sinh-vien', fd, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
};

// ---- Chuẩn hoá hiển thị ----
function pickLockedFlag(x: any): boolean | null {
  return (
    (typeof x?.daKhoa === 'boolean' ? x.daKhoa : undefined) ??
    (typeof x?.khoa === 'boolean' ? x.khoa : undefined) ??
    (typeof x?.isLocked === 'boolean' ? x.isLocked : undefined) ??
    (typeof x?.locked === 'boolean' ? x.locked : undefined) ??
    (typeof x?.trangThai === 'boolean' ? x.trangThai : null)
  );
}
const cut = (s: any) => (typeof s === 'string' ? s.slice(0, 10) : '');

export function normalizeDefenseRound(x: any): DefenseRoundUI {
  const lockedLike = pickLockedFlag(x);
  const statusText =
    lockedLike === true ? 'Kết thúc' :
    lockedLike === false ? 'Đang diễn ra' : '—';

  return {
    id: x.id ?? x.dotBaoVeId ?? x._id,
    tenDotBaoVe: x.tenDotBaoVe ?? x.ten ?? '',
    hocKi: x.hocKi ?? x.hocKy ?? '',
    namHoc: x.namHoc ?? '',
    thoiGianBatDau: cut(x.thoiGianBatDau ?? x.startDate),
    thoiGianKetThuc: cut(x.thoiGianKetThuc ?? x.endDate),
    trangThai: typeof x.trangThai === 'boolean' ? x.trangThai : undefined,
    daKhoa: typeof x.daKhoa === 'boolean' ? x.daKhoa : undefined,
    khoa: typeof x.khoa === 'boolean' ? x.khoa : undefined,
    isLocked: typeof x.isLocked === 'boolean' ? x.isLocked : undefined,
    locked: typeof x.locked === 'boolean' ? x.locked : undefined,
    lockedFlag: lockedLike,
    statusText,
  };
}

export async function listDefenseRoundsNormalized(
  params?: PageParams & { namHoc?: string; hocKi?: string }
): Promise<Page<DefenseRoundUI>> {
  const res = await listDefenseRounds(params);
  const raw = unwrap<any>(res);
  const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  return {
    content: arr.map(normalizeDefenseRound),
    totalElements: raw?.totalElements ?? arr.length ?? 0,
    page: params?.page ?? 0,
    size: params?.size ?? 10,
  };
}
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

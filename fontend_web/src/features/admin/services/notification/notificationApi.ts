// src/features/admin/services/notification/notificationApi.ts
import {
  axios,
  unwrap,
  toPage,
  type Page,
  type PageParams,
} from '@/features/assistants/services/base';

export type NotificationRow = {
  id?: number | string;
  tieuDe: string;
  noiDung: string;
  fileUrl?: string;
  createdAt?: string;
  loaiThongBao?: string;
  khoaId?: number | null;
  [k: string]: any;
};

export type CreateNotificationArgs = {
  tieuDe: string;
  noiDung: string;
  /** Nếu truyền khoaId > 0 → gửi theo khoa; ngược lại = toàn trường */
  khoaId?: number | null;
  kieuNguoiNhan?: 0 | 1;
  file?: File | null;
};

/** POST /api/thong-bao
 *  Gửi qua FormData (file) + query params (tieuDe, noiDung, kieuNguoiNhan, khoaId nếu có)
 */
export async function createNotification(args: CreateNotificationArgs) {
  const { tieuDe, noiDung } = args;

  const hasDept = args.khoaId != null && Number(args.khoaId) > 0;
  const kieuNguoiNhan: 0 | 1 =
    typeof args.kieuNguoiNhan === 'number'
      ? args.kieuNguoiNhan
      : (hasDept ? 1 : 0);

  const fd = new FormData();
  if (args.file) fd.append('file', args.file);

  const params: Record<string, any> = { tieuDe, noiDung, kieuNguoiNhan };
  if (hasDept) {
    params.khoaId = Number(args.khoaId);
    params.idKhoa = Number(args.khoaId); // alias cho backend khác nhau
  }

  return axios.post('/api/thong-bao', fd, {
    params,
    headers: { 'Content-Type': 'multipart/form-data' },
  });
}

/** GET /api/thong-bao/page */
export function listNotifications(
  params: PageParams & { sort?: string[] } = { page: 0, size: 10 }
) {
  return axios.get('/api/thong-bao/page', { params });
}

export async function listNotificationsNormalized(
  params: PageParams & { sort?: string[] } = { page: 0, size: 10 }
): Promise<Page<NotificationRow>> {
  const _params = {
    page: params.page ?? 0,
    size: params.size ?? 10,
    ...(params.sort?.length ? { sort: params.sort } : { sort: ['updatedAt,DESC'] }),
  };

  const res = await listNotifications(_params);
  const raw = unwrap<any>(res);

  const content: any[] = Array.isArray(raw?.content)
    ? raw.content
    : Array.isArray(raw)
    ? raw
    : [];

  const map = (x: any): NotificationRow => ({
    id: x.id ?? x.notificationId ?? x._id,
    tieuDe: x.tieuDe ?? x.title ?? '',
    noiDung: x.noiDung ?? x.content ?? '',
    fileUrl: x.fileUrl ?? x.attachmentUrl ?? x.url ?? undefined,
    createdAt: x.createdAt ?? x.ngayTao ?? x.updatedAt ?? undefined,
    loaiThongBao: x.loaiThongBao ?? x.type ?? undefined,
    khoaId: x.khoaId ?? x.idKhoa ?? null,
    ...x,
  });

  return toPage<NotificationRow>(
    { data: { content: content.map(map), totalElements: raw?.totalElements ?? content.length } },
    { page: _params.page, size: _params.size }
  );
}

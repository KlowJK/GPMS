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
  khoaId?: number | string | null;
  [k: string]: any;
};

export type CreateNotificationArgs = {
  tieuDe: string;
  noiDung: string;
  /** ID khoa (string/number). Bỏ qua hoặc null/'' => gửi toàn trường */
  kieuNguoiNhan?: string | number | null;
  file?: File | null;
};

export async function createNotification(args: CreateNotificationArgs) {
  const fd = new FormData();
  if (args.file) fd.append('file', args.file);

  const params: Record<string, any> = {
    tieuDe: args.tieuDe,
    noiDung: args.noiDung,
  };

  const v = args.kieuNguoiNhan;
  if (v !== undefined && v !== null && String(v) !== '') {
    // giữ dạng string để không mất chính xác với ID rất lớn
    params.kieuNguoiNhan = String(v);
  }

  return axios.post('/api/thong-bao', fd, {
    params,
    headers: { 'Content-Type': 'multipart/form-data' },
  });
}

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

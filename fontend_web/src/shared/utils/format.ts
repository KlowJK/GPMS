export function formatDateTime(value?: string | number | Date | null) {
	if (value == null) return ''
	const d = typeof value === 'string' || typeof value === 'number' ? new Date(value) : value instanceof Date ? value : new Date(String(value))
	if (isNaN(d.getTime())) return ''
	// format: dd-mm-yyyy HH:MM:SS
	const pad = (n: number) => String(n).padStart(2, '0')
	return `${pad(d.getDate())}-${pad(d.getMonth() + 1)}-${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

export function parseISOToDate(value?: string | null) {
	if (!value) return null
	const d = new Date(value)
	return isNaN(d.getTime()) ? null : d
}

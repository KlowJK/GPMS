export interface PhanTrang<T> {
  content: T[]
  number?: number
  size?: number
  totalElements?: number
  totalPages?: number
  first?: boolean
  last?: boolean
  [key: string]: any
}

export default PhanTrang

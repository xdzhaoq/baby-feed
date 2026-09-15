import { acquireLock, heartbeatLock, releaseLock } from '@/api/nursing/lock'

export function formatMinutes(min) {
  if (min === null || min === undefined || min === '') {
    return '—'
  }
  const value = Number(min)
  if (Number.isNaN(value)) {
    return '—'
  }
  const hours = Math.floor(value / 60)
  const minutes = value % 60
  if (hours && minutes) {
    return hours + '小时' + minutes + '分'
  }
  if (hours) {
    return hours + '小时'
  }
  return minutes + '分钟'
}

export function nowDate() {
  const d = new Date()
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

export function dateRangeOf(kind) {
  const end = nowDate()
  if (kind === 'today') {
    return [end, end]
  }
  if (kind === 'week') {
    const d = new Date()
    d.setDate(d.getDate() - 6)
    const pad = n => String(n).padStart(2, '0')
    return [`${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`, end]
  }
  return []
}

export function nowDateTime() {
  const d = new Date()
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

export function createRecordLock(moduleCode) {
  let timer = null
  let recordId = null
  let babyId = null

  function stop() {
    if (timer) {
      clearInterval(timer)
      timer = null
    }
  }

  async function acquire(bid, rid) {
    await release()
    if (!bid || !rid) {
      return
    }
    babyId = bid
    recordId = rid
    await acquireLock({ babyId: bid, moduleCode, recordId: rid })
    timer = setInterval(() => {
      heartbeatLock({ babyId, moduleCode, recordId }).catch(() => {})
    }, 20000)
  }

  async function release() {
    const id = recordId
    recordId = null
    stop()
    if (!id) {
      return
    }
    await releaseLock({ moduleCode, recordId: id }).catch(() => {})
  }

  return { acquire, release }
}

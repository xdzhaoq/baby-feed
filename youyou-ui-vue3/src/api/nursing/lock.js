import request from '@/utils/request'

const noRepeat = { repeatSubmit: false }

export function acquireLock(data) {
  return request({
    url: '/nursing/lock',
    method: 'post',
    data: data,
    headers: noRepeat
  })
}

export function heartbeatLock(data) {
  return request({
    url: '/nursing/lock',
    method: 'put',
    data: data,
    headers: noRepeat
  })
}

export function releaseLock(data) {
  return request({
    url: '/nursing/lock',
    method: 'delete',
    data: data,
    headers: noRepeat
  })
}

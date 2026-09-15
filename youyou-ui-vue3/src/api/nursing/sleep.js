import request from '@/utils/request'

export function listSleep(query) {
  return request({
    url: '/nursing/sleep/list',
    method: 'get',
    params: query
  })
}

export function getSleep(sleepId) {
  return request({
    url: '/nursing/sleep/' + sleepId,
    method: 'get'
  })
}

export function addSleep(data) {
  return request({
    url: '/nursing/sleep',
    method: 'post',
    data: data
  })
}

export function updateSleep(data) {
  return request({
    url: '/nursing/sleep',
    method: 'put',
    data: data
  })
}

export function delSleep(sleepId) {
  return request({
    url: '/nursing/sleep/' + sleepId,
    method: 'delete'
  })
}

export function chartSleep(babyId, days) {
  return request({
    url: '/nursing/sleep/chart',
    method: 'get',
    params: { babyId, days }
  })
}

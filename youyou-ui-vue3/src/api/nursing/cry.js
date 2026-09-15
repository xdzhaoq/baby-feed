import request from '@/utils/request'

export function listCry(query) {
  return request({
    url: '/nursing/cry/list',
    method: 'get',
    params: query
  })
}

export function getCry(cryId) {
  return request({
    url: '/nursing/cry/' + cryId,
    method: 'get'
  })
}

export function addCry(data) {
  return request({
    url: '/nursing/cry',
    method: 'post',
    data: data
  })
}

export function updateCry(data) {
  return request({
    url: '/nursing/cry',
    method: 'put',
    data: data
  })
}

export function delCry(cryId) {
  return request({
    url: '/nursing/cry/' + cryId,
    method: 'delete'
  })
}

export function chartCry(babyId, days) {
  return request({
    url: '/nursing/cry/chart',
    method: 'get',
    params: { babyId, days }
  })
}

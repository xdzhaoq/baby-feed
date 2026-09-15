import request from '@/utils/request'

export function listDiaper(query) {
  return request({
    url: '/nursing/diaper/list',
    method: 'get',
    params: query
  })
}

export function getDiaper(diaperId) {
  return request({
    url: '/nursing/diaper/' + diaperId,
    method: 'get'
  })
}

export function addDiaper(data) {
  return request({
    url: '/nursing/diaper',
    method: 'post',
    data: data
  })
}

export function updateDiaper(data) {
  return request({
    url: '/nursing/diaper',
    method: 'put',
    data: data
  })
}

export function delDiaper(diaperId) {
  return request({
    url: '/nursing/diaper/' + diaperId,
    method: 'delete'
  })
}

export function chartDiaper(babyId, days) {
  return request({
    url: '/nursing/diaper/chart',
    method: 'get',
    params: { babyId, days }
  })
}

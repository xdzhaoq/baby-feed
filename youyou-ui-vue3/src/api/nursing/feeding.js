import request from '@/utils/request'

export function listFeeding(query) {
  return request({
    url: '/nursing/feeding/list',
    method: 'get',
    params: query
  })
}

export function getFeeding(feedingId) {
  return request({
    url: '/nursing/feeding/' + feedingId,
    method: 'get'
  })
}

export function addFeeding(data) {
  return request({
    url: '/nursing/feeding',
    method: 'post',
    data: data
  })
}

export function updateFeeding(data) {
  return request({
    url: '/nursing/feeding',
    method: 'put',
    data: data
  })
}

export function delFeeding(feedingId) {
  return request({
    url: '/nursing/feeding/' + feedingId,
    method: 'delete'
  })
}

export function chartFeeding(babyId, days) {
  return request({
    url: '/nursing/feeding/chart',
    method: 'get',
    params: { babyId, days }
  })
}

import request from '@/utils/request'

export function listGrowth(query) {
  return request({
    url: '/nursing/growth/list',
    method: 'get',
    params: query
  })
}

export function chartGrowth(babyId) {
  return request({
    url: '/nursing/growth/chart',
    method: 'get',
    params: { babyId }
  })
}

export function getGrowth(growthId) {
  return request({
    url: '/nursing/growth/' + growthId,
    method: 'get'
  })
}

export function addGrowth(data) {
  return request({
    url: '/nursing/growth',
    method: 'post',
    data: data
  })
}

export function updateGrowth(data) {
  return request({
    url: '/nursing/growth',
    method: 'put',
    data: data
  })
}

export function delGrowth(growthId) {
  return request({
    url: '/nursing/growth/' + growthId,
    method: 'delete'
  })
}

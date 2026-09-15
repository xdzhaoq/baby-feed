import request from '@/utils/request'

export function listCareToday(query) {
  return request({
    url: '/nursing/care/today',
    method: 'get',
    params: query
  })
}

export function addCareItem(data) {
  return request({
    url: '/nursing/care',
    method: 'post',
    data: data
  })
}

export function toggleCare(data) {
  return request({
    url: '/nursing/care/toggle',
    method: 'put',
    data: data
  })
}

export function delCareItem(itemId, babyId) {
  return request({
    url: '/nursing/care/' + itemId,
    method: 'delete',
    params: { babyId }
  })
}

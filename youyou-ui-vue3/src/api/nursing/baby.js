import request from '@/utils/request'

export function listBaby(query) {
  return request({
    url: '/nursing/baby/list',
    method: 'get',
    params: query
  })
}

export function listMineBaby() {
  return request({
    url: '/nursing/baby/mine',
    method: 'get'
  })
}

export function getBaby(babyId) {
  return request({
    url: '/nursing/baby/' + babyId,
    method: 'get'
  })
}

export function addBaby(data) {
  return request({
    url: '/nursing/baby',
    method: 'post',
    data: data
  })
}

export function updateBaby(data) {
  return request({
    url: '/nursing/baby',
    method: 'put',
    data: data
  })
}

export function delBaby(babyId) {
  return request({
    url: '/nursing/baby/' + babyId,
    method: 'delete'
  })
}

import request from '@/utils/request'

export function listHealth(query) {
  return request({
    url: '/nursing/health/list',
    method: 'get',
    params: query
  })
}

export function getHealth(checkId) {
  return request({
    url: '/nursing/health/' + checkId,
    method: 'get'
  })
}

export function addHealth(data) {
  return request({
    url: '/nursing/health',
    method: 'post',
    data: data
  })
}

export function updateHealth(data) {
  return request({
    url: '/nursing/health',
    method: 'put',
    data: data
  })
}

export function listVaccine(babyId) {
  return request({
    url: '/nursing/health/vaccine',
    method: 'get',
    params: { babyId }
  })
}

export function markVaccine(data) {
  return request({
    url: '/nursing/health/vaccine',
    method: 'put',
    data: data
  })
}

export function addVaccineSchedule(babyId, data) {
  return request({
    url: '/nursing/health/vaccine/schedule',
    method: 'post',
    params: { babyId },
    data: data
  })
}

export function delVaccineSchedule(scheduleId, babyId) {
  return request({
    url: '/nursing/health/vaccine/schedule/' + scheduleId,
    method: 'delete',
    params: { babyId }
  })
}

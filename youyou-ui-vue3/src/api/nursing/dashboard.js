import request from '@/utils/request'

export function getTodayOverview(babyId) {
  return request({
    url: '/nursing/dashboard/today',
    method: 'get',
    params: { babyId }
  })
}

export function getAdminOverview() {
  return request({
    url: '/nursing/dashboard/admin',
    method: 'get'
  })
}

export function listKnowledge(category, keyword) {
  return request({
    url: '/nursing/knowledge/list',
    method: 'get',
    params: { category, keyword }
  })
}

export function getKnowledge(kbId) {
  return request({
    url: '/nursing/knowledge/' + kbId,
    method: 'get'
  })
}

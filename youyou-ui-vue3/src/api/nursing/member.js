import request from '@/utils/request'

export function listMember(query) {
  return request({
    url: '/nursing/member/list',
    method: 'get',
    params: query
  })
}

export function getMember(memberId) {
  return request({
    url: '/nursing/member/' + memberId,
    method: 'get'
  })
}

export function addMember(data) {
  return request({
    url: '/nursing/member',
    method: 'post',
    data: data
  })
}

export function updateMember(data) {
  return request({
    url: '/nursing/member',
    method: 'put',
    data: data
  })
}

export function changeMemberStatus(data) {
  return request({
    url: '/nursing/member/changeStatus',
    method: 'put',
    data: data
  })
}

export function resetMemberPwd(data) {
  return request({
    url: '/nursing/member/resetPwd',
    method: 'put',
    data: data
  })
}

export function memberHeartbeat(babyId) {
  return request({
    url: '/nursing/member/heartbeat',
    method: 'put',
    params: { babyId }
  })
}

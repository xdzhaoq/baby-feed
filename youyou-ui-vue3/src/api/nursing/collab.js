import request from '@/utils/request'

export function listHandover(query) {
  return request({
    url: '/nursing/handover/list',
    method: 'get',
    params: query
  })
}

export function addHandover(data) {
  return request({
    url: '/nursing/handover',
    method: 'post',
    data: data
  })
}

export function listMessage(query) {
  return request({
    url: '/nursing/message/list',
    method: 'get',
    params: query
  })
}

export function addMessage(data) {
  return request({
    url: '/nursing/message',
    method: 'post',
    data: data
  })
}

export function listUnreadMentions(babyId) {
  return request({
    url: '/nursing/message/unread',
    method: 'get',
    params: { babyId }
  })
}

export function markMentionRead(mentionId) {
  return request({
    url: '/nursing/message/mention/' + mentionId + '/read',
    method: 'put'
  })
}

export function markAllMentionsRead(babyId) {
  return request({
    url: '/nursing/message/readAll',
    method: 'put',
    params: { babyId }
  })
}

export function listOperLog(query) {
  return request({
    url: '/nursing/operlog/list',
    method: 'get',
    params: query
  })
}

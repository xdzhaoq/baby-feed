import request from '@/utils/request'
import { saveAs } from 'file-saver'
import { getToken } from '@/utils/auth'

/** 浏览器预览地址：走后端代理，不直连 RustFS */
export function mediaPreviewSrc(mediaId) {
  if (!mediaId) {
    return ''
  }
  const token = getToken()
  const query = token ? ('?token=' + encodeURIComponent(token)) : ''
  return import.meta.env.VITE_APP_BASE_API + '/nursing/media/preview/' + mediaId + query
}

export function listMedia(query) {
  return request({
    url: '/nursing/media/list',
    method: 'get',
    params: query
  })
}

export function uploadMedia(formData, onUploadProgress) {
  return request({
    url: '/nursing/media/upload',
    method: 'post',
    data: formData,
    timeout: 300000,
    headers: { 'Content-Type': 'multipart/form-data', repeatSubmit: false },
    onUploadProgress
  })
}

export function updateMedia(data) {
  return request({
    url: '/nursing/media',
    method: 'put',
    data: data
  })
}

export function delMedia(mediaIds, babyId) {
  return request({
    url: '/nursing/media/' + mediaIds,
    method: 'delete',
    params: { babyId }
  })
}

export function downloadMediaFile(mediaId, filename) {
  return request({
    url: '/nursing/media/download/' + mediaId,
    method: 'get',
    responseType: 'blob',
    timeout: 300000
  }).then(data => {
    saveAs(new Blob([data]), filename)
  })
}

export function downloadMediaBatch(babyId, mediaIds) {
  return request({
    url: '/nursing/media/download/batch',
    method: 'post',
    params: { babyId },
    data: mediaIds,
    responseType: 'blob',
    timeout: 300000,
    headers: { repeatSubmit: false }
  }).then(data => {
    saveAs(new Blob([data], { type: 'application/zip' }), 'baby-album.zip')
  })
}

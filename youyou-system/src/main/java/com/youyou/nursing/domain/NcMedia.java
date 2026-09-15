package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

/** 宝宝相册元数据 nc_media */
public class NcMedia extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long mediaId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    private String fileName;
    private String objectKey;
    private String mimeType;
    private Long fileSize;
    private String mediaType;
    private String tagCode;
    @Size(max = 500, message = "描述不能超过500个字符")
    private String description;
    private Long healthCheckId;
    private Long uploaderId;
    private String uploaderName;
    private String delFlag;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date healthCheckDate;

    public Long getMediaId() { return mediaId; }
    public void setMediaId(Long mediaId) { this.mediaId = mediaId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public String getObjectKey() { return objectKey; }
    public void setObjectKey(String objectKey) { this.objectKey = objectKey; }
    public String getMimeType() { return mimeType; }
    public void setMimeType(String mimeType) { this.mimeType = mimeType; }
    public Long getFileSize() { return fileSize; }
    public void setFileSize(Long fileSize) { this.fileSize = fileSize; }
    public String getMediaType() { return mediaType; }
    public void setMediaType(String mediaType) { this.mediaType = mediaType; }
    public String getTagCode() { return tagCode; }
    public void setTagCode(String tagCode) { this.tagCode = tagCode; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Long getHealthCheckId() { return healthCheckId; }
    public void setHealthCheckId(Long healthCheckId) { this.healthCheckId = healthCheckId; }
    public Long getUploaderId() { return uploaderId; }
    public void setUploaderId(Long uploaderId) { this.uploaderId = uploaderId; }
    public String getUploaderName() { return uploaderName; }
    public void setUploaderName(String uploaderName) { this.uploaderName = uploaderName; }
    public String getDelFlag() { return delFlag; }
    public void setDelFlag(String delFlag) { this.delFlag = delFlag; }
    public Date getHealthCheckDate() { return healthCheckDate; }
    public void setHealthCheckDate(Date healthCheckDate) { this.healthCheckDate = healthCheckDate; }
}

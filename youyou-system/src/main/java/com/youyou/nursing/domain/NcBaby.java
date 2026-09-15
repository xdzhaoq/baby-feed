package com.youyou.nursing.domain;

import java.math.BigDecimal;
import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.youyou.common.core.domain.BaseEntity;

/**
 * 宝宝档案 nc_baby
 */
public class NcBaby extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long babyId;

    @NotBlank(message = "宝宝姓名不能为空")
    @Size(max = 50, message = "宝宝姓名不能超过50个字符")
    private String babyName;

    private String nickname;

    private String gender;

    @NotNull(message = "出生日期不能为空")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date birthDate;

    private BigDecimal birthWeightKg;

    private BigDecimal birthHeightCm;

    private BigDecimal birthHeadCm;

    private Long momUserId;

    private String momUserName;

    private String mediaDir;

    private String status;

    private String delFlag;

    private Integer rev;

    /** 妈妈称呼（创建时必填，不落单独字段，写入成员 display_name / 用户昵称） */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String momDisplayName;

    /** 妈妈初始密码（仅新建账号时使用，已存在妈妈不改密） */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String momPassword;

    /** 列表查询：当前登录人，非超管只看自己的宝宝 */
    private Long queryUserId;

    private Boolean queryAdmin;

    public Long getBabyId()
    {
        return babyId;
    }

    public void setBabyId(Long babyId)
    {
        this.babyId = babyId;
    }

    public String getBabyName()
    {
        return babyName;
    }

    public void setBabyName(String babyName)
    {
        this.babyName = babyName;
    }

    public String getNickname()
    {
        return nickname;
    }

    public void setNickname(String nickname)
    {
        this.nickname = nickname;
    }

    public String getGender()
    {
        return gender;
    }

    public void setGender(String gender)
    {
        this.gender = gender;
    }

    public Date getBirthDate()
    {
        return birthDate;
    }

    public void setBirthDate(Date birthDate)
    {
        this.birthDate = birthDate;
    }

    public BigDecimal getBirthWeightKg()
    {
        return birthWeightKg;
    }

    public void setBirthWeightKg(BigDecimal birthWeightKg)
    {
        this.birthWeightKg = birthWeightKg;
    }

    public BigDecimal getBirthHeightCm()
    {
        return birthHeightCm;
    }

    public void setBirthHeightCm(BigDecimal birthHeightCm)
    {
        this.birthHeightCm = birthHeightCm;
    }

    public BigDecimal getBirthHeadCm()
    {
        return birthHeadCm;
    }

    public void setBirthHeadCm(BigDecimal birthHeadCm)
    {
        this.birthHeadCm = birthHeadCm;
    }

    public Long getMomUserId()
    {
        return momUserId;
    }

    public void setMomUserId(Long momUserId)
    {
        this.momUserId = momUserId;
    }

    public String getMomUserName()
    {
        return momUserName;
    }

    public void setMomUserName(String momUserName)
    {
        this.momUserName = momUserName;
    }

    public String getMediaDir()
    {
        return mediaDir;
    }

    public void setMediaDir(String mediaDir)
    {
        this.mediaDir = mediaDir;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getDelFlag()
    {
        return delFlag;
    }

    public void setDelFlag(String delFlag)
    {
        this.delFlag = delFlag;
    }

    public Integer getRev()
    {
        return rev;
    }

    public void setRev(Integer rev)
    {
        this.rev = rev;
    }

    public String getMomDisplayName()
    {
        return momDisplayName;
    }

    public void setMomDisplayName(String momDisplayName)
    {
        this.momDisplayName = momDisplayName;
    }

    public String getMomPassword()
    {
        return momPassword;
    }

    public void setMomPassword(String momPassword)
    {
        this.momPassword = momPassword;
    }

    public Long getQueryUserId()
    {
        return queryUserId;
    }

    public void setQueryUserId(Long queryUserId)
    {
        this.queryUserId = queryUserId;
    }

    public Boolean getQueryAdmin()
    {
        return queryAdmin;
    }

    public void setQueryAdmin(Boolean queryAdmin)
    {
        this.queryAdmin = queryAdmin;
    }
}

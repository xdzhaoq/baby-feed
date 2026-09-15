package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.youyou.common.core.domain.BaseEntity;

/**
 * 宝宝家庭成员 nc_baby_member
 */
public class NcBabyMember extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long memberId;

    @NotNull(message = "宝宝不能为空")
    private Long babyId;

    private Long userId;

    @NotBlank(message = "角色标签不能为空")
    private String roleTag;

    @NotBlank(message = "称呼不能为空")
    @Size(max = 30, message = "称呼不能超过30个字符")
    private String displayName;

    private String status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date lastHeartbeat;

    /** 新建家人时的登录名 */
    private String userName;

    /** 新建家人时的初始密码 */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;

    /** 关联查询 */
    private String nickName;

    private String avatar;

    private String userStatus;

    /** 1 在线 0 离线 */
    private String onlineFlag;

    public Long getMemberId()
    {
        return memberId;
    }

    public void setMemberId(Long memberId)
    {
        this.memberId = memberId;
    }

    public Long getBabyId()
    {
        return babyId;
    }

    public void setBabyId(Long babyId)
    {
        this.babyId = babyId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getRoleTag()
    {
        return roleTag;
    }

    public void setRoleTag(String roleTag)
    {
        this.roleTag = roleTag;
    }

    public String getDisplayName()
    {
        return displayName;
    }

    public void setDisplayName(String displayName)
    {
        this.displayName = displayName;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public Date getLastHeartbeat()
    {
        return lastHeartbeat;
    }

    public void setLastHeartbeat(Date lastHeartbeat)
    {
        this.lastHeartbeat = lastHeartbeat;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getPassword()
    {
        return password;
    }

    public void setPassword(String password)
    {
        this.password = password;
    }

    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }

    public String getAvatar()
    {
        return avatar;
    }

    public void setAvatar(String avatar)
    {
        this.avatar = avatar;
    }

    public String getUserStatus()
    {
        return userStatus;
    }

    public void setUserStatus(String userStatus)
    {
        this.userStatus = userStatus;
    }

    public String getOnlineFlag()
    {
        return onlineFlag;
    }

    public void setOnlineFlag(String onlineFlag)
    {
        this.onlineFlag = onlineFlag;
    }
}

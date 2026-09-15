package com.youyou.framework.aspectj;

import java.lang.reflect.Method;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import com.youyou.common.annotation.Log;
import com.youyou.common.constant.HttpStatus;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.common.enums.BusinessType;
import com.youyou.common.utils.ServletUtils;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.service.INcCollabService;

/**
 * 护理业务操作写入 nc_oper_log，按宝宝/模块在协作中心筛选。
 */
@Aspect
@Order(2)
@Component
public class NursingOperLogAspect
{
    private static final Logger log = LoggerFactory.getLogger(NursingOperLogAspect.class);

    @Autowired
    private INcCollabService collabService;

    @AfterReturning(pointcut = "@annotation(controllerLog)", returning = "jsonResult")
    public void afterReturning(JoinPoint joinPoint, Log controllerLog, Object jsonResult)
    {
        try
        {
            HttpServletRequest request = ServletUtils.getRequest();
            if (request == null)
            {
                return;
            }
            String uri = request.getRequestURI();
            if (uri == null || uri.indexOf("/nursing/") < 0)
            {
                return;
            }
            if (jsonResult instanceof AjaxResult)
            {
                Object code = ((AjaxResult) jsonResult).get(AjaxResult.CODE_TAG);
                if (code instanceof Integer && ((Integer) code).intValue() != HttpStatus.SUCCESS)
                {
                    return;
                }
            }
            if (controllerLog.businessType() == BusinessType.OTHER)
            {
                return;
            }
            String module = moduleOf(uri);
            if (StringUtils.isEmpty(module) || skipModule(module))
            {
                return;
            }
            Long babyId = resolveBabyId(joinPoint, request);
            if (babyId == null)
            {
                return;
            }
            String action = actionOf(controllerLog.businessType());
            String summary = controllerLog.title();
            if (StringUtils.isNotEmpty(action))
            {
                summary = summary + " · " + actionLabel(action);
            }
            collabService.insertOperLog(babyId, module, action, summary);
        }
        catch (Exception e)
        {
            log.warn("写入护理操作日志失败: {}", e.getMessage());
        }
    }

    private boolean skipModule(String module)
    {
        return "lock".equals(module) || "dashboard".equals(module) || "knowledge".equals(module)
                || "operlog".equals(module) || "handover".equals(module) || "message".equals(module);
    }

    private String moduleOf(String uri)
    {
        int idx = uri.indexOf("/nursing/");
        if (idx < 0)
        {
            return null;
        }
        String rest = uri.substring(idx + "/nursing/".length());
        int slash = rest.indexOf('/');
        return slash < 0 ? rest : rest.substring(0, slash);
    }

    private String actionOf(BusinessType type)
    {
        if (type == BusinessType.INSERT)
        {
            return NursingConstants.ACTION_CREATE;
        }
        if (type == BusinessType.UPDATE)
        {
            return NursingConstants.ACTION_UPDATE;
        }
        if (type == BusinessType.DELETE)
        {
            return NursingConstants.ACTION_DELETE;
        }
        return type.name().toLowerCase();
    }

    private String actionLabel(String action)
    {
        if (NursingConstants.ACTION_CREATE.equals(action))
        {
            return "新增";
        }
        if (NursingConstants.ACTION_UPDATE.equals(action))
        {
            return "修改";
        }
        if (NursingConstants.ACTION_DELETE.equals(action))
        {
            return "删除";
        }
        return action;
    }

    private Long resolveBabyId(JoinPoint joinPoint, HttpServletRequest request)
    {
        Long id = parseLong(request.getHeader("X-Baby-Id"));
        if (id != null)
        {
            return id;
        }
        id = parseLong(request.getParameter("babyId"));
        if (id != null)
        {
            return id;
        }
        Object[] args = joinPoint.getArgs();
        if (args == null)
        {
            return null;
        }
        for (Object arg : args)
        {
            if (arg == null || arg instanceof MultipartFile || arg instanceof MultipartFile[]
                    || arg instanceof HttpServletRequest || arg instanceof HttpServletResponse)
            {
                continue;
            }
            try
            {
                Method method = arg.getClass().getMethod("getBabyId");
                Object value = method.invoke(arg);
                if (value instanceof Number)
                {
                    return ((Number) value).longValue();
                }
            }
            catch (Exception ignored)
            {
            }
        }
        return null;
    }

    private Long parseLong(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return null;
        }
        try
        {
            return Long.valueOf(value.trim());
        }
        catch (NumberFormatException e)
        {
            return null;
        }
    }
}

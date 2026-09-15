package com.youyou.nursing.service.impl;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.amazonaws.ClientConfiguration;
import com.amazonaws.Protocol;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.service.INcOssService;
import com.youyou.system.service.ISysConfigService;

@Service
public class NcOssServiceImpl implements INcOssService
{
    private static final Logger log = LoggerFactory.getLogger(NcOssServiceImpl.class);

    private static final long DEFAULT_MAX = 104857600L;

    @Autowired
    private ISysConfigService configService;

    private volatile AmazonS3 cachedClient;

    private volatile String cachedFingerprint;

    @Override
    public long maxFileSize()
    {
        String value = configService.selectConfigByKey("nursing.oss.maxFileSize");
        if (StringUtils.isEmpty(value))
        {
            return DEFAULT_MAX;
        }
        try
        {
            return Long.parseLong(value.trim());
        }
        catch (NumberFormatException e)
        {
            return DEFAULT_MAX;
        }
    }

    @Override
    public void putObject(String objectKey, InputStream in, long size, String contentType)
    {
        AmazonS3 client = client();
        String bucket = bucket();
        ensureBucket(client, bucket);
        ObjectMetadata meta = new ObjectMetadata();
        meta.setContentLength(size);
        if (StringUtils.isNotEmpty(contentType))
        {
            meta.setContentType(contentType);
        }
        try
        {
            client.putObject(bucket, objectKey, in, meta);
        }
        catch (Exception e)
        {
            log.error("RustFS 上传失败 key={}", objectKey, e);
            throw new ServiceException("家庭相册存储未就绪，请检查 RustFS 是否已启动");
        }
    }

    @Override
    public void deleteObject(String objectKey)
    {
        if (StringUtils.isEmpty(objectKey))
        {
            return;
        }
        try
        {
            client().deleteObject(bucket(), objectKey);
        }
        catch (Exception e)
        {
            log.warn("RustFS 删除对象失败 key={}", objectKey, e);
            throw new ServiceException("家庭相册文件删除失败，请稍后重试");
        }
    }

    @Override
    public void writeObject(String objectKey, OutputStream out) throws IOException
    {
        S3Object object = null;
        try
        {
            object = client().getObject(bucket(), objectKey);
            IOUtils.copy(object.getObjectContent(), out);
            out.flush();
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            log.error("RustFS 读取失败 key={}", objectKey, e);
            throw new ServiceException("家庭相册文件暂时无法读取，请检查 RustFS");
        }
        finally
        {
            if (object != null)
            {
                try
                {
                    object.close();
                }
                catch (Exception ignored)
                {
                }
            }
        }
    }

    private AmazonS3 client()
    {
        String endpoint = required("nursing.oss.endpoint", "请配置 RustFS 地址 nursing.oss.endpoint");
        String accessKey = required("nursing.oss.accessKey", "请配置 RustFS AccessKey");
        String secretKey = required("nursing.oss.secretKey", "请配置 RustFS SecretKey");
        String region = configService.selectConfigByKey("nursing.oss.region");
        if (StringUtils.isEmpty(region))
        {
            region = "us-east-1";
        }
        String fingerprint = endpoint + "|" + accessKey + "|" + secretKey + "|" + region;
        AmazonS3 local = cachedClient;
        if (local != null && fingerprint.equals(cachedFingerprint))
        {
            return local;
        }
        synchronized (this)
        {
            if (cachedClient != null && fingerprint.equals(cachedFingerprint))
            {
                return cachedClient;
            }
            try
            {
                Protocol protocol = endpoint.toLowerCase().startsWith("https") ? Protocol.HTTPS : Protocol.HTTP;
                ClientConfiguration conf = new ClientConfiguration();
                conf.setProtocol(protocol);
                conf.setSignerOverride("AWSS3V4SignerType");
                conf.setMaxErrorRetry(2);
                AmazonS3 created = AmazonS3ClientBuilder.standard()
                        .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(accessKey, secretKey)))
                        .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(endpoint, region))
                        .withPathStyleAccessEnabled(true)
                        .withClientConfiguration(conf)
                        .disableChunkedEncoding()
                        .build();
                cachedClient = created;
                cachedFingerprint = fingerprint;
                return created;
            }
            catch (Exception e)
            {
                log.error("初始化 RustFS 客户端失败", e);
                throw new ServiceException("家庭相册存储未就绪，请检查 RustFS 是否已启动");
            }
        }
    }

    private void ensureBucket(AmazonS3 client, String bucket)
    {
        try
        {
            if (!client.doesBucketExistV2(bucket))
            {
                client.createBucket(bucket);
            }
        }
        catch (Exception e)
        {
            log.error("RustFS 存储桶不可用 bucket={}", bucket, e);
            throw new ServiceException("家庭相册存储未就绪，请检查 RustFS 是否已启动");
        }
    }

    private String bucket()
    {
        String bucket = configService.selectConfigByKey("nursing.oss.bucket");
        if (StringUtils.isEmpty(bucket))
        {
            return "nursing";
        }
        return bucket.trim();
    }

    private String required(String key, String message)
    {
        String value = configService.selectConfigByKey(key);
        if (StringUtils.isEmpty(value))
        {
            throw new ServiceException(message);
        }
        return value.trim();
    }
}

package com.youyou.nursing.service;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * 家庭服务器 RustFS（S3 兼容）。对象键必须落在宝宝 media_dir 下。
 */
public interface INcOssService
{
    long maxFileSize();

    void putObject(String objectKey, InputStream in, long size, String contentType);

    void deleteObject(String objectKey);

    void writeObject(String objectKey, OutputStream out) throws IOException;
}

package com.admqr.misstory;

import android.text.TextUtils;
import android.util.Log;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

public class JacksonUtil {

    private static final String TAG = "JacksonUtil";

    private static JacksonUtil instance;
    private ObjectMapper objectMapper;

    public static JacksonUtil getInstance() {
        if (instance == null) {
            instance = new JacksonUtil();
        }

        return instance;
    }

    public JacksonUtil() {
        objectMapper = new ObjectMapper();
        objectMapper
                .configure(
                        DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT,
                        true);
        objectMapper.configure(
                DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
    }

    public synchronized <T> T readValue(String content, Class<T> valueType) {
        if (TextUtils.isEmpty(content)) {
            return null;
        }

        try {
            return objectMapper.readValue(content, valueType);
        } catch (JsonParseException e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        } catch (JsonMappingException e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        } catch (IOException e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        }

        return null;
    }

    public synchronized <T> T readValue(String content,
                                        TypeReference<T> typeReference) {
        if (TextUtils.isEmpty(content)) {
            return null;
        }

        try {
            return objectMapper.readValue(content, typeReference);
        } catch (JsonParseException e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        } catch (JsonMappingException e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        } catch (IOException e) {
            Log.e(TAG, e.getMessage());
            Log.w(TAG, content);
        }

        return null;
    }

    public synchronized String writeValueAsString(Object object) {

        if (null == object) {
            return null;
        }

        try {
            return objectMapper.writeValueAsString(object);
        } catch (JsonGenerationException e) {
            Log.e(TAG, e.getMessage());
        } catch (JsonMappingException e) {
            Log.e(TAG, e.getMessage());
        } catch (IOException e) {
            Log.e(TAG, e.getMessage());
        }

        return null;
    }

    public ObjectMapper getObjectMapper() {
        return objectMapper;
    }
}

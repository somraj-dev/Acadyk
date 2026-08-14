package com.acadyk.infrastructure.redis

import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.redis.connection.RedisConnectionFactory
import org.springframework.data.redis.core.RedisTemplate
import org.springframework.data.redis.core.script.DefaultRedisScript
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer
import org.springframework.data.redis.serializer.StringRedisSerializer
import org.springframework.stereotype.Component
import org.springframework.stereotype.Service
import java.time.Duration
import java.util.Collections
import java.util.UUID

@Configuration
class RedisConfig {

    @Bean
    fun redisTemplate(
        connectionFactory: RedisConnectionFactory,
        objectMapper: ObjectMapper
    ): RedisTemplate<String, Any> {
        val template = RedisTemplate<String, Any>()
        template.connectionFactory = connectionFactory

        val stringSerializer = StringRedisSerializer()
        val jsonSerializer = GenericJackson2JsonRedisSerializer(objectMapper)

        template.keySerializer = stringSerializer
        template.valueSerializer = jsonSerializer
        template.hashKeySerializer = stringSerializer
        template.hashValueSerializer = jsonSerializer
        template.afterPropertiesSet()
        return template
    }
}

/**
 * Enterprise Redis Distributed Lock for atomic operations.
 * Uses atomic SET with NX (Not Exists) and PX (Milliseconds TTL),
 * and safe release via Lua script to prevent releasing locks owned by other threads.
 */
@Component
class RedisDistributedLock(
    private val redisTemplate: RedisTemplate<String, Any>
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    private val releaseScript = DefaultRedisScript<Long>(
        "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end",
        Long::class.java
    )

    /**
     * Acquire a distributed lock.
     * @return lock token if acquired, null if failed/busy
     */
    fun acquireLock(lockKey: String, expireDuration: Duration = Duration.ofSeconds(10)): String? {
        val token = UUID.randomUUID().toString()
        val formattedKey = "lock:$lockKey"
        return try {
            val success = redisTemplate.opsForValue().setIfAbsent(formattedKey, token, expireDuration)
            if (success == true) token else null
        } catch (e: Exception) {
            logger.warn("Redis distributed lock failed to connect (fallback mode): ${e.message}")
            token // Allow execution in offline/dev fallback
        }
    }

    /**
     * Release a distributed lock safely using owner token.
     */
    fun releaseLock(lockKey: String, token: String): Boolean {
        val formattedKey = "lock:$lockKey"
        return try {
            val result = redisTemplate.execute(
                releaseScript,
                Collections.singletonList(formattedKey),
                token
            )
            result == 1L
        } catch (e: Exception) {
            logger.warn("Redis distributed lock release warning: ${e.message}")
            true
        }
    }

    /**
     * Execute critical block with distributed lock
     */
    fun <T> withLock(lockKey: String, expireDuration: Duration = Duration.ofSeconds(10), action: () -> T): T {
        val token = acquireLock(lockKey, expireDuration)
            ?: throw IllegalStateException("Could not acquire lock for $lockKey. Resource is busy.")
        try {
            return action()
        } finally {
            releaseLock(lockKey, token)
        }
    }
}

/**
 * Redis Sliding Window Rate Limiter
 */
@Component
class RedisRateLimiter(
    private val redisTemplate: RedisTemplate<String, Any>
) {
    fun isAllowed(key: String, limit: Int, windowDuration: Duration = Duration.ofMinutes(1)): Boolean {
        val rateLimitKey = "ratelimit:$key"
        return try {
            val currentCount = redisTemplate.opsForValue().increment(rateLimitKey)
            if (currentCount == 1L) {
                redisTemplate.expire(rateLimitKey, windowDuration)
            }
            (currentCount ?: 0L) <= limit
        } catch (_: Exception) {
            true // Fail open in dev/fallback
        }
    }
}

/**
 * Cache-Aside Helper for frequently accessed profiles and metadata
 */
@Service
class RedisCacheService(
    private val redisTemplate: RedisTemplate<String, Any>
) {
    fun <T> getOrFetch(key: String, ttl: Duration = Duration.ofHours(1), fetcher: () -> T): T {
        val cached = get(key)
        if (cached != null) {
            @Suppress("UNCHECKED_CAST")
            return cached as T
        }
        val fetched = fetcher()
        if (fetched != null) {
            set(key, fetched, ttl)
        }
        return fetched
    }

    fun set(key: String, value: Any, ttl: Duration = Duration.ofHours(1)) {
        try {
            redisTemplate.opsForValue().set("cache:$key", value, ttl)
        } catch (_: Exception) {}
    }

    fun get(key: String): Any? {
        return try {
            redisTemplate.opsForValue().get("cache:$key")
        } catch (_: Exception) {
            null
        }
    }

    fun evict(key: String) {
        try {
            redisTemplate.delete("cache:$key")
        } catch (_: Exception) {}
    }

    fun evictPattern(pattern: String) {
        try {
            val keys = redisTemplate.keys("cache:$pattern*")
            if (!keys.isNullOrEmpty()) {
                redisTemplate.delete(keys)
            }
        } catch (_: Exception) {}
    }
}

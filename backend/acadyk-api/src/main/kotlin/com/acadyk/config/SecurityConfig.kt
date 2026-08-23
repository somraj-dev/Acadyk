package com.acadyk.config

import com.acadyk.security.FirebaseAuthFilter
import com.acadyk.security.RateLimitingFilter
import org.springframework.http.HttpMethod
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
class SecurityConfig(
    private val firebaseAuthFilter: FirebaseAuthFilter,
    private val rateLimitingFilter: RateLimitingFilter
) {

    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .cors { it.configurationSource(corsConfigurationSource()) }
            .csrf { it.disable() }
            .httpBasic { it.disable() }
            .formLogin { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(
                        "/api/v1/auth/**",
                        "/api/v1/admin/auth/**",
                        "/api/v1/media/public/**",
                        "/ws/**",
                        "/actuator/**"
                    ).permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/v1/posts/**").permitAll()
                    .anyRequest().authenticated()
            }
            .addFilterBefore(rateLimitingFilter, UsernamePasswordAuthenticationFilter::class.java)
            .addFilterBefore(firebaseAuthFilter, UsernamePasswordAuthenticationFilter::class.java)

        return http.build()
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val envOrigins = System.getenv("CORS_ALLOWED_ORIGINS")?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() }
        val configuration = CorsConfiguration().apply {
            if (!envOrigins.isNullOrEmpty()) {
                val (wildcards, exacts) = envOrigins.partition { it.contains("*") }
                if (exacts.isNotEmpty()) {
                    allowedOrigins = exacts
                }
                if (wildcards.isNotEmpty()) {
                    allowedOriginPatterns = wildcards
                }
            } else {
                allowedOriginPatterns = listOf("*")
                allowedOrigins = null
            }
            allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
            allowedHeaders = listOf(
                "Authorization",
                "Content-Type",
                "X-Requested-With",
                "Accept",
                "Origin",
                "Access-Control-Request-Method",
                "Access-Control-Request-Headers",
                "X-Request-ID",
                "X-Correlation-ID"
            )
            exposedHeaders = listOf("Authorization", "Content-Disposition", "X-Request-ID", "X-Correlation-ID")
            allowCredentials = true
            maxAge = 3600L
        }
        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/**", configuration)
        return source
    }
}

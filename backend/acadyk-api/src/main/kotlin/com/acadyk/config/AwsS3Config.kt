package com.acadyk.config

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.presigner.S3Presigner

@Configuration
class AwsS3Config(
    @Value("\${aws.s3.region:us-east-1}") private val region: String,
    @Value("\${aws.s3.accessKey:}") private val accessKey: String,
    @Value("\${aws.s3.secretKey:}") private val secretKey: String
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @Bean
    fun awsCredentialsProvider(): AwsCredentialsProvider {
        return if (accessKey.isNotBlank() && secretKey.isNotBlank() && accessKey != "test") {
            logger.info("Using static AWS credentials provider")
            StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey))
        } else {
            logger.info("Using default AWS IAM role / container credentials provider (least privilege)")
            DefaultCredentialsProvider.create()
        }
    }

    @Bean
    fun s3Client(credentialsProvider: AwsCredentialsProvider): S3Client {
        return try {
            S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(credentialsProvider)
                .build()
        } catch (e: Exception) {
            logger.warn("S3Client initialization fallback: ${e.message}")
            S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create("mock", "mock")))
                .build()
        }
    }

    @Bean
    fun s3Presigner(credentialsProvider: AwsCredentialsProvider): S3Presigner {
        return try {
            S3Presigner.builder()
                .region(Region.of(region))
                .credentialsProvider(credentialsProvider)
                .build()
        } catch (e: Exception) {
            logger.warn("S3Presigner initialization fallback: ${e.message}")
            S3Presigner.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create("mock", "mock")))
                .build()
        }
    }
}

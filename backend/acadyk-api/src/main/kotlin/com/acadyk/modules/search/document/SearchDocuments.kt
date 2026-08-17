package com.acadyk.modules.search.document

import org.springframework.data.annotation.Id
import org.springframework.data.elasticsearch.annotations.Document
import org.springframework.data.elasticsearch.annotations.Field
import org.springframework.data.elasticsearch.annotations.FieldType
import java.time.Instant

@Document(indexName = "acadyk_profiles", createIndex = false)
data class ProfileSearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val fullName: String,

    @Field(type = FieldType.Keyword)
    val username: String,

    @Field(type = FieldType.Text)
    val headline: String? = null,

    @Field(type = FieldType.Text)
    val bio: String? = null,

    @Field(type = FieldType.Text)
    val collegeName: String? = null,

    @Field(type = FieldType.Keyword)
    val major: String? = null,

    @Field(type = FieldType.Keyword)
    val location: String? = null,

    @Field(type = FieldType.Keyword)
    val skills: List<String> = emptyList(),

    @Field(type = FieldType.Integer)
    val graduationYear: Int? = null,

    @Field(type = FieldType.Keyword)
    val profilePhotoUrl: String? = null
)

@Document(indexName = "acadyk_posts", createIndex = false)
data class PostSearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val content: String,

    @Field(type = FieldType.Keyword)
    val authorId: String,

    @Field(type = FieldType.Text)
    val authorName: String,

    @Field(type = FieldType.Keyword)
    val postType: String = "text",

    @Field(type = FieldType.Keyword)
    val tags: List<String> = emptyList(),

    @Field(type = FieldType.Date)
    val createdAt: Instant = Instant.now()
)

@Document(indexName = "acadyk_opportunities", createIndex = false)
data class OpportunitySearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val title: String,

    @Field(type = FieldType.Text)
    val companyName: String,

    @Field(type = FieldType.Keyword)
    val opportunityType: String,

    @Field(type = FieldType.Text)
    val description: String,

    @Field(type = FieldType.Keyword)
    val location: String? = null,

    @Field(type = FieldType.Boolean)
    val isRemote: Boolean = false,

    @Field(type = FieldType.Keyword)
    val experienceLevel: String? = null,

    @Field(type = FieldType.Keyword)
    val skills: List<String> = emptyList(),

    @Field(type = FieldType.Date)
    val deadline: Instant? = null,

    @Field(type = FieldType.Date)
    val createdAt: Instant = Instant.now()
)

@Document(indexName = "acadyk_events", createIndex = false)
data class EventSearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val title: String,

    @Field(type = FieldType.Text)
    val description: String? = null,

    @Field(type = FieldType.Keyword)
    val eventType: String = "workshop",

    @Field(type = FieldType.Keyword)
    val category: String = "Technical",

    @Field(type = FieldType.Keyword)
    val location: String? = null,

    @Field(type = FieldType.Boolean)
    val isVirtual: Boolean = false,

    @Field(type = FieldType.Date)
    val startTime: Instant = Instant.now()
)

@Document(indexName = "acadyk_communities", createIndex = false)
data class CommunitySearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val name: String,

    @Field(type = FieldType.Keyword)
    val slug: String,

    @Field(type = FieldType.Text)
    val description: String? = null,

    @Field(type = FieldType.Keyword)
    val category: String = "academic",

    @Field(type = FieldType.Integer)
    val membersCount: Int = 1
)

@Document(indexName = "acadyk_startups", createIndex = false)
data class StartupSearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val name: String,

    @Field(type = FieldType.Keyword)
    val slug: String,

    @Field(type = FieldType.Text)
    val pitch: String,

    @Field(type = FieldType.Text)
    val description: String? = null,

    @Field(type = FieldType.Keyword)
    val stage: String = "Idea",

    @Field(type = FieldType.Keyword)
    val industry: String = "Technology"
)

@Document(indexName = "acadyk_companies", createIndex = false)
data class CompanySearchDocument(
    @Id
    val id: String,

    @Field(type = FieldType.Text, analyzer = "standard")
    val name: String,

    @Field(type = FieldType.Keyword)
    val industry: String = "Technology",

    @Field(type = FieldType.Keyword)
    val location: String? = null,

    @Field(type = FieldType.Text)
    val description: String? = null,

    @Field(type = FieldType.Boolean)
    val verified: Boolean = true
)

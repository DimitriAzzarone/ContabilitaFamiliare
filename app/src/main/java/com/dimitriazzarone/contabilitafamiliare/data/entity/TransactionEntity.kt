package com.dimitriazzarone.contabilitafamiliare.data.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

enum class TransactionType {
    INCOME,
    EXPENSE
}

@Entity(tableName = "transactions")
data class TransactionEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val type: TransactionType,
    val amountCents: Long,
    val category: String,
    val description: String,
    val note: String?,
    val dateEpochDay: Long,
    val createdAt: Long
)

package com.dimitriazzarone.contabilitafamiliare.data.repository

import com.dimitriazzarone.contabilitafamiliare.data.dao.TransactionDao
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionEntity
import kotlinx.coroutines.flow.Flow

class TransactionRepository(
    private val dao: TransactionDao
) {
    fun observeAll(): Flow<List<TransactionEntity>> = dao.observeAll()

    fun observeForMonth(
        startEpochDay: Long,
        endEpochDay: Long
    ): Flow<List<TransactionEntity>> = dao.observeForMonth(startEpochDay, endEpochDay)

    fun observeMonthlyIncome(
        startEpochDay: Long,
        endEpochDay: Long
    ): Flow<Long> = dao.observeMonthlyIncome(startEpochDay, endEpochDay)

    fun observeMonthlyExpense(
        startEpochDay: Long,
        endEpochDay: Long
    ): Flow<Long> = dao.observeMonthlyExpense(startEpochDay, endEpochDay)

    suspend fun insert(transaction: TransactionEntity): Long = dao.insert(transaction)

    suspend fun delete(transaction: TransactionEntity) = dao.delete(transaction)

    suspend fun deleteAll() = dao.deleteAll()
}

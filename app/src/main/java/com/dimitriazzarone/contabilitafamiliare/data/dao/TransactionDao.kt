package com.dimitriazzarone.contabilitafamiliare.data.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface TransactionDao {
    @Insert
    suspend fun insert(transaction: TransactionEntity): Long

    @Delete
    suspend fun delete(transaction: TransactionEntity)

    @Query("DELETE FROM transactions")
    suspend fun deleteAll()

    @Query("SELECT * FROM transactions ORDER BY dateEpochDay DESC, createdAt DESC")
    fun observeAll(): Flow<List<TransactionEntity>>

    @Query(
        """
        SELECT * FROM transactions
        WHERE dateEpochDay BETWEEN :startEpochDay AND :endEpochDay
        ORDER BY dateEpochDay DESC, createdAt DESC
        """
    )
    fun observeForMonth(
        startEpochDay: Long,
        endEpochDay: Long
    ): Flow<List<TransactionEntity>>

    @Query(
        """
        SELECT COALESCE(SUM(amountCents), 0) FROM transactions
        WHERE type = 'INCOME'
          AND dateEpochDay BETWEEN :startEpochDay AND :endEpochDay
        """
    )
    fun observeMonthlyIncome(
        startEpochDay: Long,
        endEpochDay: Long
    ): Flow<Long>

    @Query(
        """
        SELECT COALESCE(SUM(amountCents), 0) FROM transactions
        WHERE type = 'EXPENSE'
          AND dateEpochDay BETWEEN :startEpochDay AND :endEpochDay
        """
    )
    fun observeMonthlyExpense(
        startEpochDay: Long,
        endEpochDay: Long
    ): Flow<Long>
}

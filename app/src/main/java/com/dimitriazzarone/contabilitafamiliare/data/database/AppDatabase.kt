package com.dimitriazzarone.contabilitafamiliare.data.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverter
import androidx.room.TypeConverters
import com.dimitriazzarone.contabilitafamiliare.data.dao.TransactionDao
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionEntity
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionType

class DatabaseConverters {
    @TypeConverter
    fun fromTransactionType(value: TransactionType): String = value.name

    @TypeConverter
    fun toTransactionType(value: String): TransactionType = TransactionType.valueOf(value)
}

@Database(
    entities = [TransactionEntity::class],
    version = 1,
    exportSchema = true
)
@TypeConverters(DatabaseConverters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun transactionDao(): TransactionDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "contabilita_familiare.db"
                ).build().also { INSTANCE = it }
            }
    }
}

package com.dimitriazzarone.contabilitafamiliare.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionEntity
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionType
import com.dimitriazzarone.contabilitafamiliare.data.repository.TransactionRepository
import java.math.BigDecimal
import java.math.RoundingMode
import java.time.LocalDate
import java.time.YearMonth
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class MainUiState(
    val transactions: List<TransactionEntity> = emptyList(),
    val incomeCents: Long = 0,
    val expenseCents: Long = 0
) {
    val balanceCents: Long get() = incomeCents - expenseCents
}

sealed interface UiEvent {
    data object TransactionSaved : UiEvent
    data object TransactionDeleted : UiEvent
    data object AllDataDeleted : UiEvent
}

class MainViewModel(
    private val repository: TransactionRepository
) : ViewModel() {
    private val currentMonth = YearMonth.now()
    private val startEpochDay = currentMonth.atDay(1).toEpochDay()
    private val endEpochDay = currentMonth.atEndOfMonth().toEpochDay()

    val uiState: StateFlow<MainUiState> = combine(
        repository.observeForMonth(startEpochDay, endEpochDay),
        repository.observeMonthlyIncome(startEpochDay, endEpochDay),
        repository.observeMonthlyExpense(startEpochDay, endEpochDay)
    ) { transactions, income, expense ->
        MainUiState(
            transactions = transactions,
            incomeCents = income,
            expenseCents = expense
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = MainUiState()
    )

    val events = MutableSharedFlow<UiEvent>()

    fun addTransaction(
        type: TransactionType,
        amountText: String,
        description: String,
        category: String,
        date: LocalDate,
        note: String?
    ): Result<Unit> {
        val amountCents = parseAmountToCents(amountText)
            ?: return Result.failure(IllegalArgumentException("Inserisci un importo valido maggiore di zero."))
        if (description.isBlank()) {
            return Result.failure(IllegalArgumentException("Inserisci una descrizione."))
        }
        if (category.isBlank()) {
            return Result.failure(IllegalArgumentException("Seleziona una categoria."))
        }

        viewModelScope.launch {
            repository.insert(
                TransactionEntity(
                    type = type,
                    amountCents = amountCents,
                    category = category.trim(),
                    description = description.trim(),
                    note = note?.trim()?.takeIf { it.isNotEmpty() },
                    dateEpochDay = date.toEpochDay(),
                    createdAt = System.currentTimeMillis()
                )
            )
            events.emit(UiEvent.TransactionSaved)
        }
        return Result.success(Unit)
    }

    fun deleteTransaction(transaction: TransactionEntity) {
        viewModelScope.launch {
            repository.delete(transaction)
            events.emit(UiEvent.TransactionDeleted)
        }
    }

    fun deleteAllData() {
        viewModelScope.launch {
            repository.deleteAll()
            events.emit(UiEvent.AllDataDeleted)
        }
    }

    private fun parseAmountToCents(raw: String): Long? {
        val cleaned = raw.trim().replace(" ", "")

        val normalized = when {
            cleaned.count { it == ',' } == 1 &&
                cleaned.count { it == '.' } == 0 ->
                cleaned.replace(',', '.')

            cleaned.count { it == '.' } == 1 &&
                cleaned.count { it == ',' } == 0 ->
                cleaned

            cleaned.contains(',') && cleaned.contains('.') -> {
                val decimalSeparator =
                    if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) ',' else '.'
                val groupingSeparator =
                    if (decimalSeparator == ',') '.' else ','

                cleaned
                    .replace(groupingSeparator.toString(), "")
                    .replace(decimalSeparator, '.')
            }

            else -> cleaned
        }

        if (normalized.isBlank()) return null

        return runCatching {
            val value = BigDecimal(normalized)
            if (value <= BigDecimal.ZERO || value.scale() > 2) return null
            value.setScale(2, RoundingMode.UNNECESSARY)
                .movePointRight(2)
                .longValueExact()
        }.getOrNull()
    }

    class Factory(
        private val repository: TransactionRepository
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            require(modelClass.isAssignableFrom(MainViewModel::class.java))
            return MainViewModel(repository) as T
        }
    }
}

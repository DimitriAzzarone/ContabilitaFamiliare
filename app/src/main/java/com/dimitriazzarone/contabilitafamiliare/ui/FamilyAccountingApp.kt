package com.dimitriazzarone.contabilitafamiliare.ui

import android.app.DatePickerDialog
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.School
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionEntity
import com.dimitriazzarone.contabilitafamiliare.data.entity.TransactionType
import com.dimitriazzarone.contabilitafamiliare.viewmodel.MainUiState
import com.dimitriazzarone.contabilitafamiliare.viewmodel.MainViewModel
import com.dimitriazzarone.contabilitafamiliare.viewmodel.UiEvent
import java.text.NumberFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

private val incomeCategories = listOf(
    "Stipendio",
    "Pensione",
    "Rimborso",
    "Rendita",
    "Regalo",
    "Altra entrata"
)

private val expenseCategories = listOf(
    "Casa",
    "Alimentazione",
    "Trasporti",
    "Salute",
    "Scuola",
    "Assicurazioni",
    "Imposte",
    "Abbonamenti",
    "Tempo libero",
    "Altra uscita"
)

private enum class AppSection {
    HOME,
    EDUCATION,
    PRIVACY
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun FamilyAccountingApp(
    viewModel: MainViewModel
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }

    var section by remember { mutableStateOf(AppSection.HOME) }
    var showAddForm by remember { mutableStateOf(false) }
    var transactionToDelete by remember { mutableStateOf<TransactionEntity?>(null) }
    var showFirstDeleteAllConfirmation by remember { mutableStateOf(false) }
    var showSecondDeleteAllConfirmation by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            val message = when (event) {
                UiEvent.TransactionSaved -> "Movimento salvato."
                UiEvent.TransactionDeleted -> "Movimento eliminato."
                UiEvent.AllDataDeleted -> "Tutti i dati sono stati cancellati."
            }
            snackbarHostState.showSnackbar(message)
        }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = when (section) {
                                AppSection.HOME -> "Contabilità Familiare"
                                AppSection.EDUCATION -> "Educazione finanziaria"
                                AppSection.PRIVACY -> "Privacy e dati"
                            },
                            fontWeight = FontWeight.Bold
                        )
                    }
                },
                navigationIcon = {
                    if (section != AppSection.HOME) {
                        TextButton(onClick = { section = AppSection.HOME }) {
                            Text("Indietro")
                        }
                    }
                },
                actions = {
                    if (section == AppSection.HOME) {
                        IconButton(
                            onClick = { section = AppSection.EDUCATION },
                            modifier = Modifier.semantics {
                                contentDescription = "Apri educazione finanziaria"
                            }
                        ) {
                            Icon(Icons.Default.School, contentDescription = null)
                        }
                        IconButton(
                            onClick = { section = AppSection.PRIVACY },
                            modifier = Modifier.semantics {
                                contentDescription = "Apri privacy e dati"
                            }
                        ) {
                            Icon(Icons.Default.Info, contentDescription = null)
                        }
                    }
                }
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) },
        floatingActionButton = {
            if (section == AppSection.HOME && !showAddForm) {
                ExtendedFloatingActionButton(
                    onClick = { showAddForm = true },
                    icon = { Icon(Icons.Default.Add, contentDescription = null) },
                    text = { Text("Aggiungi movimento") },
                    modifier = Modifier.navigationBarsPadding()
                )
            }
        }
    ) { padding ->
        when (section) {
            AppSection.HOME -> HomeScreen(
                modifier = Modifier.padding(padding),
                uiState = uiState,
                showAddForm = showAddForm,
                onShowAddForm = { showAddForm = true },
                onCancelAdd = { showAddForm = false },
                onSave = { type, amount, description, category, date, note ->
                    viewModel.addTransaction(type, amount, description, category, date, note)
                        .onSuccess { showAddForm = false }
                },
                onDelete = { transactionToDelete = it }
            )

            AppSection.EDUCATION -> EducationScreen(
                modifier = Modifier.padding(padding)
            )

            AppSection.PRIVACY -> PrivacyScreen(
                modifier = Modifier.padding(padding),
                onDeleteAll = { showFirstDeleteAllConfirmation = true }
            )
        }
    }

    transactionToDelete?.let { transaction ->
        AlertDialog(
            onDismissRequest = { transactionToDelete = null },
            title = { Text("Eliminare il movimento?") },
            text = {
                Text("Vuoi eliminare “${transaction.description}”? Questa operazione non può essere annullata.")
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.deleteTransaction(transaction)
                        transactionToDelete = null
                    }
                ) {
                    Text("Elimina")
                }
            },
            dismissButton = {
                TextButton(onClick = { transactionToDelete = null }) {
                    Text("Annulla")
                }
            }
        )
    }

    if (showFirstDeleteAllConfirmation) {
        AlertDialog(
            onDismissRequest = { showFirstDeleteAllConfirmation = false },
            title = { Text("Cancella tutti i dati") },
            text = {
                Text("Questa funzione elimina definitivamente tutti i movimenti salvati sul dispositivo.")
            },
            confirmButton = {
                Button(
                    onClick = {
                        showFirstDeleteAllConfirmation = false
                        showSecondDeleteAllConfirmation = true
                    }
                ) {
                    Text("Continua")
                }
            },
            dismissButton = {
                TextButton(onClick = { showFirstDeleteAllConfirmation = false }) {
                    Text("Annulla")
                }
            }
        )
    }

    if (showSecondDeleteAllConfirmation) {
        AlertDialog(
            onDismissRequest = { showSecondDeleteAllConfirmation = false },
            title = { Text("Conferma definitiva") },
            text = {
                Text("Selezionando “Cancella definitivamente”, tutti i movimenti saranno rimossi senza possibilità di recupero.")
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.deleteAllData()
                        showSecondDeleteAllConfirmation = false
                        section = AppSection.HOME
                    }
                ) {
                    Text("Cancella definitivamente")
                }
            },
            dismissButton = {
                TextButton(onClick = { showSecondDeleteAllConfirmation = false }) {
                    Text("Mantieni i dati")
                }
            }
        )
    }
}

@Composable
private fun HomeScreen(
    modifier: Modifier,
    uiState: MainUiState,
    showAddForm: Boolean,
    onShowAddForm: () -> Unit,
    onCancelAdd: () -> Unit,
    onSave: (
        TransactionType,
        String,
        String,
        String,
        LocalDate,
        String?
    ) -> Result<Unit>,
    onDelete: (TransactionEntity) -> Unit
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp, 12.dp, 16.dp, 112.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text(
                text = "Gestisci entrate, uscite e bilancio con semplicità",
                style = MaterialTheme.typography.bodyLarge
            )
        }

        item {
            MonthlySummary(uiState)
        }

        if (showAddForm) {
            item {
                AddTransactionForm(
                    onSave = onSave,
                    onCancel = onCancelAdd
                )
            }
        } else {
            item {
                Button(
                    onClick = onShowAddForm,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.Add, contentDescription = null)
                    Spacer(Modifier.size(8.dp))
                    Text("Aggiungi movimento")
                }
            }
        }

        item {
            Text(
                text = "Operazioni del mese",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
        }

        if (uiState.transactions.isEmpty()) {
            item {
                OutlinedCard(modifier = Modifier.fillMaxWidth()) {
                    Text(
                        text = "Non ci sono ancora movimenti nel mese corrente.",
                        modifier = Modifier.padding(20.dp)
                    )
                }
            }
        } else {
            items(uiState.transactions, key = { it.id }) { transaction ->
                TransactionRow(
                    transaction = transaction,
                    onDelete = { onDelete(transaction) }
                )
            }
        }
    }
}

@Composable
private fun MonthlySummary(
    uiState: MainUiState
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "Riepilogo del mese corrente",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SummaryCard(
                label = "Entrate",
                value = formatEuro(uiState.incomeCents),
                modifier = Modifier.weight(1f)
            )
            SummaryCard(
                label = "Uscite",
                value = formatEuro(uiState.expenseCents),
                modifier = Modifier.weight(1f)
            )
        }
        SummaryCard(
            label = "Saldo",
            value = formatEuro(uiState.balanceCents),
            modifier = Modifier.fillMaxWidth(),
            supportingText = if (uiState.balanceCents >= 0) "Saldo positivo o in equilibrio" else "Saldo negativo"
        )
    }
}

@Composable
private fun SummaryCard(
    label: String,
    value: String,
    modifier: Modifier,
    supportingText: String? = null
) {
    Card(
        modifier = modifier,
        shape = MaterialTheme.shapes.large
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(label, style = MaterialTheme.typography.labelLarge)
            Text(
                value,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )
            supportingText?.let {
                Text(it, style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}

@Composable
private fun TransactionRow(
    transaction: TransactionEntity,
    onDelete: () -> Unit
) {
    val isIncome = transaction.type == TransactionType.INCOME
    OutlinedCard(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = transaction.description,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = "${transaction.category} · ${formatDate(LocalDate.ofEpochDay(transaction.dateEpochDay))}",
                    style = MaterialTheme.typography.bodyMedium
                )
                transaction.note?.let {
                    Text(
                        text = it,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                Text(
                    text = if (isIncome) "Entrata" else "Uscita",
                    style = MaterialTheme.typography.labelMedium
                )
            }
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = (if (isIncome) "+ " else "− ") + formatEuro(transaction.amountCents),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                IconButton(
                    onClick = onDelete,
                    modifier = Modifier.semantics {
                        contentDescription = "Elimina ${transaction.description}"
                    }
                ) {
                    Icon(Icons.Default.Delete, contentDescription = null)
                }
            }
        }
    }
}

@Composable
private fun AddTransactionForm(
    onSave: (
        TransactionType,
        String,
        String,
        String,
        LocalDate,
        String?
    ) -> Result<Unit>,
    onCancel: () -> Unit
) {
    var type by remember { mutableStateOf(TransactionType.EXPENSE) }
    var amount by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var category by remember { mutableStateOf("") }
    var date by remember { mutableStateOf(LocalDate.now()) }
    var note by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    val categories = if (type == TransactionType.INCOME) incomeCategories else expenseCategories

    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Nuovo movimento",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                if (type == TransactionType.INCOME) {
                    Button(onClick = {
                        type = TransactionType.INCOME
                        category = ""
                    }) { Text("+ Entrata") }
                } else {
                    OutlinedButton(onClick = {
                        type = TransactionType.INCOME
                        category = ""
                    }) { Text("+ Entrata") }
                }

                if (type == TransactionType.EXPENSE) {
                    Button(onClick = {
                        type = TransactionType.EXPENSE
                        category = ""
                    }) { Text("− Uscita") }
                } else {
                    OutlinedButton(onClick = {
                        type = TransactionType.EXPENSE
                        category = ""
                    }) { Text("− Uscita") }
                }
            }

            OutlinedTextField(
                value = amount,
                onValueChange = { amount = it },
                label = { Text("Importo in euro") },
                placeholder = { Text("Esempio: 12,50") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = description,
                onValueChange = { description = it },
                label = { Text("Descrizione") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )

            Text(
                text = "Categoria",
                style = MaterialTheme.typography.labelLarge
            )
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                categories.forEach { item ->
                    AssistChip(
                        onClick = { category = item },
                        label = {
                            Text(if (category == item) "✓ $item" else item)
                        }
                    )
                }
            }

            DateField(
                date = date,
                onDateSelected = { date = it }
            )

            OutlinedTextField(
                value = note,
                onValueChange = { note = it },
                label = { Text("Nota facoltativa") },
                minLines = 2,
                modifier = Modifier.fillMaxWidth()
            )

            errorMessage?.let {
                Text(
                    text = it,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodyMedium
                )
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                TextButton(onClick = onCancel) {
                    Text("Annulla")
                }
                Spacer(Modifier.size(8.dp))
                Button(
                    onClick = {
                        errorMessage = null
                        onSave(
                            type,
                            amount,
                            description,
                            category,
                            date,
                            note
                        ).onFailure {
                            errorMessage = it.message ?: "Controlla i dati inseriti."
                        }
                    }
                ) {
                    Text("Salva")
                }
            }
        }
    }
}

@Composable
private fun DateField(
    date: LocalDate,
    onDateSelected: (LocalDate) -> Unit
) {
    val context = LocalContext.current
    OutlinedButton(
        onClick = {
            DatePickerDialog(
                context,
                { _, year, month, day ->
                    onDateSelected(LocalDate.of(year, month + 1, day))
                },
                date.year,
                date.monthValue - 1,
                date.dayOfMonth
            ).show()
        },
        modifier = Modifier.fillMaxWidth()
    ) {
        Text("Data: ${formatDate(date)}")
    }
}

@Composable
private fun EducationScreen(
    modifier: Modifier
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Text(
                        "Entrate, uscite e saldo",
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        "Le entrate sono i soldi che ricevi. Le uscite sono i soldi che spendi. Il saldo è la differenza tra entrate e uscite. Un saldo positivo indica che nel periodo è entrato più denaro di quanto ne sia uscito."
                    )
                    HorizontalDivider()
                    Text("Esempio", fontWeight = FontWeight.SemiBold)
                    Text("Entrate: 1.500 €")
                    Text("Uscite: 1.200 €")
                    Text("Saldo: 300 €")
                }
            }
        }
        item {
            OutlinedCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Questi contenuti hanno finalità educative e organizzative. Non costituiscono consulenza finanziaria, fiscale o professionale.",
                    modifier = Modifier.padding(18.dp)
                )
            }
        }
    }
}

@Composable
private fun PrivacyScreen(
    modifier: Modifier,
    onDeleteAll: () -> Unit
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        "Privacy nella fase 1",
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold
                    )
                    Text("• I dati sono salvati localmente sul dispositivo.")
                    Text("• L’app non chiede password bancarie.")
                    Text("• Nessun dato viene inviato online.")
                    Text("• I dati non vengono venduti.")
                    Text("• Non è richiesto alcun account.")
                    Text("• Non sono presenti pubblicità.")
                    Text("• Non sono presenti analytics.")
                    Text("• In questa fase non sono implementati PIN, biometria o cifratura aggiuntiva del database.")
                }
            }
        }
        item {
            OutlinedCard(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        "Funzioni future, non attive",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        "Operazioni ricorrenti, scadenze e notifiche, obiettivo di risparmio, esportazioni CSV e PDF, fotografie degli scontrini, profili familiari, condivisione tra dispositivi, sincronizzazione bancaria, importazione estratti conto, PIN e biometria, backup e categorie personalizzate."
                    )
                }
            }
        }
        item {
            Button(
                onClick = onDeleteAll,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Cancella tutti i dati")
            }
        }
    }
}

private fun formatEuro(cents: Long): String {
    val formatter = NumberFormat.getCurrencyInstance(Locale.ITALY)
    return formatter.format(cents.toBigDecimal().movePointLeft(2))
}

private fun formatDate(date: LocalDate): String =
    date.format(DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ITALY))

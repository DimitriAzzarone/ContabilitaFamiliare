package com.dimitriazzarone.contabilitafamiliare

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.lifecycle.viewmodel.compose.viewModel
import com.dimitriazzarone.contabilitafamiliare.data.database.AppDatabase
import com.dimitriazzarone.contabilitafamiliare.data.repository.TransactionRepository
import com.dimitriazzarone.contabilitafamiliare.ui.FamilyAccountingApp
import com.dimitriazzarone.contabilitafamiliare.ui.theme.ContabilitaFamiliareTheme
import com.dimitriazzarone.contabilitafamiliare.viewmodel.MainViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val repository = TransactionRepository(
            AppDatabase.getInstance(applicationContext).transactionDao()
        )

        setContent {
            ContabilitaFamiliareTheme {
                val mainViewModel: MainViewModel = viewModel(
                    factory = MainViewModel.Factory(repository)
                )
                FamilyAccountingApp(viewModel = mainViewModel)
            }
        }
    }
}

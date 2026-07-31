#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

EXPECTED_ORIGIN="DimitriAzzarone/ContabilitaFamiliare"
EXPECTED_BRANCH="main"
BACKUP_DIR=".contabilita-familiare-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

fail() {
  printf 'ERRORE: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

command -v git >/dev/null 2>&1 || fail "Git non è disponibile. Installarlo manualmente prima di eseguire questo script."

git rev-parse --show-toplevel >/dev/null 2>&1 || fail "La directory corrente non è dentro un repository Git."
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
[ -n "$ORIGIN_URL" ] || fail "Il remote origin non è configurato."

case "$ORIGIN_URL" in
  *github.com/DimitriAzzarone/ContabilitaFamiliare.git|*github.com/DimitriAzzarone/ContabilitaFamiliare)
    ;;
  *)
    fail "Origin non corrisponde a ${EXPECTED_ORIGIN}. Valore trovato: ${ORIGIN_URL}"
    ;;
esac

CURRENT_BRANCH="$(git branch --show-current)"
[ "$CURRENT_BRANCH" = "$EXPECTED_BRANCH" ] || fail "Il ramo corrente deve essere main. Ramo trovato: ${CURRENT_BRANCH:-detached HEAD}"

mkdir -p "$BACKUP_PATH"

if [ ! -f .gitignore ]; then
  : > .gitignore
fi

if ! grep -Fxq "${BACKUP_DIR}/" .gitignore; then
  printf '\n%s\n' "${BACKUP_DIR}/" >> .gitignore
fi

backup_if_exists() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "${BACKUP_PATH}/$(dirname "$path")"
    cp -R "$path" "${BACKUP_PATH}/${path}"
  fi
}

FILES_TO_WRITE=(
  ".gitignore"
  "settings.gradle.kts"
  "build.gradle.kts"
  "gradle.properties"
  "app/build.gradle.kts"
  "app/proguard-rules.pro"
  "app/src/main/AndroidManifest.xml"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/MainActivity.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/entity/TransactionEntity.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/dao/TransactionDao.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/database/AppDatabase.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/repository/TransactionRepository.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/viewmodel/MainViewModel.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/FamilyAccountingApp.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme/Color.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme/Theme.kt"
  "app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme/Type.kt"
  "app/src/main/res/values/strings.xml"
  "app/src/main/res/values/themes.xml"
  "app/src/main/res/values/colors.xml"
  "app/src/main/res/xml/backup_rules.xml"
  "app/src/main/res/xml/data_extraction_rules.xml"
  "app/src/main/res/drawable/ic_launcher_foreground.xml"
  "app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
  "app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml"
  ".github/workflows/android.yml"
  "README.md"
)

for file in "${FILES_TO_WRITE[@]}"; do
  backup_if_exists "$file"
done

mkdir -p \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/entity \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/dao \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/database \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/repository \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/viewmodel \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme \
  app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui \
  app/src/main/res/values \
  app/src/main/res/drawable \
  app/src/main/res/mipmap-anydpi-v26 \
  .github/workflows

cat > settings.gradle.kts <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ContabilitaFamiliare"
include(":app")
EOF

cat > build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    id("com.google.devtools.ksp") version "2.0.21-1.0.28" apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.dimitriazzarone.contabilitafamiliare"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.dimitriazzarone.contabilitafamiliare"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.12.01")

    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.activity:activity-compose:1.10.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    debugImplementation("androidx.compose.ui:ui-tooling")

    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
EOF

cat > app/proguard-rules.pro <<'EOF'
# Nessuna regola personalizzata necessaria nella fase 1.
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.ContabilitaFamiliare">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

mkdir -p app/src/main/res/xml

cat > app/src/main/res/xml/backup_rules.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="database" path="." />
    <exclude domain="sharedpref" path="." />
</full-backup-content>
EOF

cat > app/src/main/res/xml/data_extraction_rules.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup disableIfNoEncryptionCapabilities="true">
        <exclude domain="database" path="." />
        <exclude domain="sharedpref" path="." />
    </cloud-backup>
    <device-transfer>
        <exclude domain="database" path="." />
        <exclude domain="sharedpref" path="." />
    </device-transfer>
</data-extraction-rules>
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/entity/TransactionEntity.kt <<'EOF'
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
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/dao/TransactionDao.kt <<'EOF'
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
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/database/AppDatabase.kt <<'EOF'
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
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/data/repository/TransactionRepository.kt <<'EOF'
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
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/viewmodel/MainViewModel.kt <<'EOF'
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
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/MainActivity.kt <<'EOF'
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
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme/Color.kt <<'EOF'
package com.dimitriazzarone.contabilitafamiliare.ui.theme

import androidx.compose.ui.graphics.Color

val Navy = Color(0xFF12324A)
val NavyLight = Color(0xFFD6E7F2)
val Green = Color(0xFF087F5B)
val GreenLight = Color(0xFFCDEFE3)
val Orange = Color(0xFFB65E00)
val OrangeLight = Color(0xFFFFE2C2)
val Red = Color(0xFFB3261E)
val RedLight = Color(0xFFFFDAD6)
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme/Type.kt <<'EOF'
package com.dimitriazzarone.contabilitafamiliare.ui.theme

import androidx.compose.material3.Typography

val AppTypography = Typography()
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/theme/Theme.kt <<'EOF'
package com.dimitriazzarone.contabilitafamiliare.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val LightColors = lightColorScheme(
    primary = Navy,
    secondary = Green,
    tertiary = Orange,
    error = Red
)

private val DarkColors = darkColorScheme(
    primary = NavyLight,
    secondary = GreenLight,
    tertiary = OrangeLight,
    error = RedLight
)

@Composable
fun ContabilitaFamiliareTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colors = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColors
        else -> LightColors
    }

    MaterialTheme(
        colorScheme = colors,
        typography = AppTypography,
        content = content
    )
}
EOF

cat > app/src/main/java/com/dimitriazzarone/contabilitafamiliare/ui/FamilyAccountingApp.kt <<'EOF'
package com.dimitriazzarone.contabilitafamiliare.ui

import android.app.DatePickerDialog
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
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

@OptIn(ExperimentalMaterial3Api::class)
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
EOF

cat > app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">Contabilità Familiare</string>
</resources>
EOF

cat > app/src/main/res/values/colors.xml <<'EOF'
<resources>
    <color name="launcher_background">#12324A</color>
</resources>
EOF

cat > app/src/main/res/values/themes.xml <<'EOF'
<resources>
    <style name="Theme.ContabilitaFamiliare" parent="android:style/Theme.Material.Light.NoActionBar">
        <item name="android:fontFamily">sans</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:statusBarColor">@color/launcher_background</item>
        <item name="android:navigationBarColor">@color/launcher_background</item>
        <item name="android:windowActionModeOverlay">true</item>
        <item name="android:windowNoTitle">true</item>
    </style>
</resources>
EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M20,52 L54,24 L88,52 L82,52 L82,84 L62,84 L62,64 L46,64 L46,84 L26,84 L26,52 Z" />
    <path
        android:fillColor="#087F5B"
        android:pathData="M70,32 A16,16 0,1 0,70,64 A16,16 0,1 0,70,32" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M67,38 L73,38 L73,43 C78,44 81,47 81,52 C81,58 77,61 70,61 C64,61 60,58 59,53 L65,51 C66,55 68,56 71,56 C74,56 76,55 76,52 C76,49 74,48 69,47 C63,46 60,43 60,39 C60,34 64,31 67,30 Z" />
</vector>
EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > .github/workflows/android.yml <<'EOF'
name: Android CI

on:
  workflow_dispatch:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configura Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - name: Configura Android SDK
        uses: android-actions/setup-android@v3

      - name: Configura Gradle
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: "8.10.2"

      - name: Elenca progetti Gradle
        run: gradle projects --stacktrace

      - name: Compila APK debug
        run: gradle assembleDebug --stacktrace

      - name: Verifica APK
        run: test -f app/build/outputs/apk/debug/app-debug.apk

      - name: Carica APK
        uses: actions/upload-artifact@v4
        with:
          name: Contabilita-Familiare-debug-${{ github.ref_name }}
          path: app/build/outputs/apk/debug/app-debug.apk
          if-no-files-found: error
EOF

cat > README.md <<'EOF'
# Contabilità Familiare

Applicazione Android locale per registrare entrate e uscite, vedere il bilancio mensile e imparare concetti essenziali di educazione finanziaria con un linguaggio semplice e non giudicante.

## Destinatari

- giovani maggiorenni che iniziano a gestire stipendio, affitto e bollette;
- coppie e famiglie;
- persone poco esperte di contabilità;
- corsi di educazione finanziaria.

Paese iniziale: Italia.  
Valuta iniziale: EUR – Euro.

## Tecnologie

- Kotlin;
- Jetpack Compose;
- Material 3;
- Room;
- Kotlin Coroutines;
- Flow;
- ViewModel;
- Java 17;
- compileSdk 35;
- targetSdk 35;
- minSdk 26;
- GitHub Actions.

## Struttura

- `data/entity`: entità Room e tipo del movimento;
- `data/dao`: query di inserimento, eliminazione, osservazione e riepilogo mensile;
- `data/database`: database Room e converter;
- `data/repository`: accesso semplice ai dati;
- `viewmodel`: stato UI e operazioni;
- `ui`: schermata principale, form, pannelli educativi e privacy;
- `ui/theme`: tema chiaro/scuro e colori.

## Database Room

Il database locale `contabilita_familiare.db` contiene la tabella `transactions`.

Campi:

- `id: Long`;
- `type: INCOME` oppure `EXPENSE`;
- `amountCents: Long`;
- `category: String`;
- `description: String`;
- `note: String?`;
- `dateEpochDay: Long`;
- `createdAt: Long`.

## Modello monetario

Gli importi sono salvati come centesimi interi tramite `Long`. L’app non usa `Float` o `Double` per la persistenza monetaria. Il form accetta la virgola italiana oppure il punto e converte l’importo con `BigDecimal`, senza arrotondamenti silenziosi.

## Funzioni implementate

- inserimento reale di entrate e uscite;
- categorie iniziali separate;
- data e nota facoltativa;
- validazione di importo, descrizione e categoria;
- bilancio del mese corrente;
- totale entrate;
- totale uscite;
- saldo;
- elenco mensile ordinato dal più recente;
- eliminazione con conferma;
- cancellazione completa con doppia conferma;
- persistenza locale Room;
- aggiornamento automatico tramite Flow;
- messaggi di conferma;
- modulo introduttivo di educazione finanziaria;
- pannello privacy;
- tema automatico chiaro/scuro;
- icona launcher originale.

## Funzioni non implementate

Sono future e non hanno pulsanti attivi:

- operazioni ricorrenti;
- scadenze e notifiche;
- obiettivo di risparmio;
- esportazione CSV;
- esportazione PDF;
- fotografie degli scontrini;
- profili familiari;
- condivisione tra dispositivi;
- sincronizzazione bancaria;
- importazione estratti conto;
- PIN e biometria;
- backup;
- categorie personalizzate.

## Privacy

- dati salvati localmente;
- nessuna password bancaria;
- nessun dato inviato online;
- nessuna vendita dei dati;
- nessun account;
- nessuna pubblicità;
- nessuna analytics;
- nessun permesso runtime;
- nessun permesso Internet.

Il database Room non viene dichiarato cifrato, perché nella fase 1 non è stata implementata una cifratura aggiuntiva.

## Limiti

L’app non esegue operazioni bancarie, non prepara dichiarazioni fiscali, non effettua pagamenti e non sostituisce commercialisti, fiduciari o consulenti finanziari.

## Disclaimer

Questi contenuti hanno finalità educative e organizzative. Non costituiscono consulenza finanziaria, fiscale o professionale.

## Build con GitHub Actions

Il workflow `.github/workflows/android.yml` si avvia:

- manualmente con `workflow_dispatch`;
- su push verso `main`;
- su pull request verso `main`.

Esegue:

```text
gradle projects --stacktrace
gradle assembleDebug --stacktrace
```

Verifica il file:

```text
app/build/outputs/apk/debug/app-debug.apk
```

e lo carica come Artifact:

```text
Contabilita-Familiare-debug-${{ github.ref_name }}
```

La build non deve essere considerata riuscita finché GitHub Actions non è verde e l’Artifact APK non è disponibile.

## Percorso APK

```text
app/build/outputs/apk/debug/app-debug.apk
```

## Test manuali richiesti

1. Installare l’APK sul dispositivo.
2. Inserire un’entrata.
3. Inserire un’uscita.
4. Verificare entrate, uscite e saldo.
5. Chiudere completamente l’app.
6. Riaprire l’app.
7. Verificare la persistenza dei movimenti.
8. Eliminare un movimento e verificare la conferma.
9. Usare “Cancella tutti i dati” e verificare entrambe le conferme.

## Roadmap

Le funzioni future saranno aggiunte progressivamente soltanto dopo una base stabile, testata e compilata con successo.
EOF

cat > .gitignore <<EOF
$(grep -vFx "${BACKUP_DIR}/" .gitignore || true)
${BACKUP_DIR}/
.gradle/
.idea/
local.properties
.DS_Store
build/
app/build/
captures/
.externalNativeBuild/
.cxx/
EOF

STATIC_ROOT="app/src/main/java/com/dimitriazzarone/contabilitafamiliare"

require_pattern() {
  local pattern="$1"
  local path="$2"
  grep -R -q -- "$pattern" "$path" || fail "Controllo statico fallito: manca '${pattern}' in ${path}"
}

require_fixed_pattern() {
  local pattern="$1"
  local path="$2"
  grep -R -F -q -- "$pattern" "$path" ||
    fail "Controllo statico fallito: manca '${pattern}' in ${path}"
}

forbid_pattern() {
  local pattern="$1"
  shift
  if grep -R -n -i -E --exclude='contabilita-familiare-bootstrap-v1.sh' -- "$pattern" "$@" >/dev/null 2>&1; then
    fail "Controllo statico fallito: trovato contenuto vietato '${pattern}'"
  fi
}

require_pattern "@Entity" "$STATIC_ROOT"
require_pattern "@Dao" "$STATIC_ROOT"
require_pattern "@Database" "$STATIC_ROOT"
require_pattern "Room.databaseBuilder" "$STATIC_ROOT"
require_pattern "Flow" "$STATIC_ROOT"
require_pattern "amountCents: Long" "$STATIC_ROOT"
require_pattern "INCOME" "$STATIC_ROOT"
require_pattern "EXPENSE" "$STATIC_ROOT"
require_pattern "AlertDialog" "$STATIC_ROOT/ui"
require_pattern "deleteAllData" "$STATIC_ROOT"
require_pattern "finalità educative e organizzative" "app/src/main"
require_pattern "DELETE FROM transactions" "$STATIC_ROOT"
require_pattern "observeMonthlyIncome" "$STATIC_ROOT"
require_pattern "observeMonthlyExpense" "$STATIC_ROOT"

require_fixed_pattern   'val cleaned = raw.trim().replace(" ", "")'   "$STATIC_ROOT/viewmodel/MainViewModel.kt"
require_fixed_pattern   "cleaned.count { it == ',' }"   "$STATIC_ROOT/viewmodel/MainViewModel.kt"
require_fixed_pattern   "cleaned.lastIndexOf(',')"   "$STATIC_ROOT/viewmodel/MainViewModel.kt"
require_fixed_pattern   "replace(decimalSeparator, '.')"   "$STATIC_ROOT/viewmodel/MainViewModel.kt"

if grep -F -q -- '.replace(".", "")' "$STATIC_ROOT/viewmodel/MainViewModel.kt"; then
  fail "Controllo statico fallito: MainViewModel.kt contiene ancora la vecchia rimozione del punto."
fi

if grep -F -q -- 'tools:targetApi' app/src/main/res/values/themes.xml; then
  fail "Controllo statico fallito: themes.xml contiene tools:targetApi."
fi

if grep -F -q -- 'xmlns:tools' app/src/main/res/values/themes.xml; then
  fail "Controllo statico fallito: themes.xml contiene xmlns:tools."
fi

if grep -R -n -- "android.permission.INTERNET" app/src/main/AndroidManifest.xml >/dev/null 2>&1; then
  fail "Controllo statico fallito: il Manifest contiene il permesso INTERNET."
fi

forbid_pattern "Firebase" app README.md .github
forbid_pattern "https?://" app/src/main/java README.md
forbid_pattern "password[[:space:]]+bancari(e|a)[[:space:]]+(salvat|memorizzat)" app/src/main README.md
forbid_pattern "API[ _-]*key" app/src/main README.md
forbid_pattern "(^|[^[:alnum:]_])base64([^[:alnum:]_]|$)" app README.md .github
forbid_pattern "(^|[^[:alnum:]_])tar([^[:alnum:]_]|$)" app README.md .github
forbid_pattern "(^|[^[:alnum:]_])gzip([^[:alnum:]_]|$)" app README.md .github
forbid_pattern "(^|[^[:alnum:]_])payload([^[:alnum:]_]|$)" app README.md .github

if grep -nE '(^|[[:space:]])git[[:space:]]+(reset|clean|add|commit|push)([[:space:]]|$)' "$0" \
  | grep -v "forbid_pattern" >/dev/null 2>&1; then
  fail "Lo script contiene un comando Git vietato."
fi

info "Progetto Contabilità Familiare creato o aggiornato."
info "Backup dei file preesistenti: ${BACKUP_PATH}"
info "Nessuna compilazione, installazione, aggiunta all'indice, commit o pubblicazione è stata eseguita."
info "Controlli statici completati con successo."

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

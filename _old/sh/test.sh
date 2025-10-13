#!/bin/bash

# Ottiene il Vendor ID e lo memorizza in una variabile.
# Usiamo lscpu, filtriamo la riga con "Vendor ID" e prendiamo la terza parola.
vendor=$(lscpu | grep "Vendor ID" | awk '{print $3}')

# Utilizziamo una struttura "case" per verificare il valore della variabile 'vendor'.
case "$vendor" in
  "GenuineIntel")
    echo "⚙️  La tua CPU è Intel."
    # Qui puoi aggiungere comandi specifici per CPU Intel
    ;;
  "AuthenticAMD")
    echo "⚙️  La tua CPU è AMD."
    # Qui puoi aggiungere comandi specifici per CPU AMD
    ;;
  *)
    echo "❓ Vendor della CPU non riconosciuto: $vendor"
    # Qui puoi gestire tutti gli altri casi
    ;;
esac
#!/bin/bash
set -e


# Funzione per controllare se lo script è in esecuzione in un terminale interattivo.
# Restituisce 0 (true) se lo standard output (file descriptor 1) è un terminale.
is_terminal() {
    [ -t 1 ]
}

# La tua funzione di logging (invariata)
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"

    # Qui chiamiamo la funzione is_terminal() definita sopra
    if is_terminal; then
        local color
        case "$level" in
            INFO)  color="\033[1;34m" ;;  # Blu
            WARN)  color="\033[1;33m" ;;  # Giallo
            ERROR) color="\033[1;31m" ;;  # Rosso
            DEBUG) color="\033[0;36m" ;;  # Ciano
            *)     color="\033[0m"     ;; # Reset
        esac
        # Usare 'echo -e' è fondamentale per interpretare i codici di escape \033
        echo -e "[$level] ${color}${message}\033[0m" >&2
    else
        echo "[$level] $message" >&2
    fi
}

# --- ESEMPIO DI UTILIZZO ---
# log INFO "Questo è un messaggio informativo."
# log WARN "Attenzione, qualcosa sta per succedere."
# log ERROR "Si è verificato un errore critico!"
# log DEBUG "Dettagli per il debug."
# log CUSTOM "Un messaggio con un livello non definito."



#!/bin/bash

# Skrypt do czyszczenia starych procesów lftp aktualnego użytkownika
# Usuwa procesy lftp starsze niż 3 dni

# Kolory do wyświetlania
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funkcja do logowania
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Sprawdź czy użytkownik ma uprawnienia
if [[ $EUID -eq 0 ]]; then
    warn "Skrypt jest uruchamiany jako root. Będzie działał na wszystkich procesach lftp."
fi

# Pobierz aktualnego użytkownika
CURRENT_USER=$(whoami)
log "Sprawdzanie procesów lftp dla użytkownika: $CURRENT_USER"

# Znajdź procesy lftp starsze niż 3 dni (259200 sekund = 3 dni)
DAYS_THRESHOLD=3
SECONDS_THRESHOLD=$((DAYS_THRESHOLD * 24 * 60 * 60))

log "Szukanie procesów lftp starszych niż $DAYS_THRESHOLD dni..."

# Pobierz listę procesów lftp z informacjami o czasie uruchomienia
# Format: PID USER ELAPSED CMD
LFTP_PROCESSES=$(ps -eo pid,user,etime,cmd | grep -E '\blftp\b' | grep -v grep | grep "^[[:space:]]*[0-9]*[[:space:]]*$CURRENT_USER")

if [[ -z "$LFTP_PROCESSES" ]]; then
    log "Nie znaleziono żadnych procesów lftp dla użytkownika $CURRENT_USER"
    exit 0
fi

log "Znalezione procesy lftp:"
echo "$LFTP_PROCESSES"
echo

# Funkcja do konwersji czasu elapsed na sekundy
elapsed_to_seconds() {
    local elapsed="$1"
    local total_seconds=0
    
    # Obsługa różnych formatów czasu elapsed
    if [[ $elapsed =~ ^([0-9]+)-([0-9]+):([0-9]+):([0-9]+)$ ]]; then
        # Format: DD-HH:MM:SS
        local days=${BASH_REMATCH[1]}
        local hours=${BASH_REMATCH[2]}
        local minutes=${BASH_REMATCH[3]}
        local seconds=${BASH_REMATCH[4]}
        total_seconds=$((days * 86400 + hours * 3600 + minutes * 60 + seconds))
    elif [[ $elapsed =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
        # Format: HH:MM:SS
        local hours=${BASH_REMATCH[1]}
        local minutes=${BASH_REMATCH[2]}
        local seconds=${BASH_REMATCH[3]}
        total_seconds=$((hours * 3600 + minutes * 60 + seconds))
    elif [[ $elapsed =~ ^([0-9]+):([0-9]+)$ ]]; then
        # Format: MM:SS
        local minutes=${BASH_REMATCH[1]}
        local seconds=${BASH_REMATCH[2]}
        total_seconds=$((minutes * 60 + seconds))
    else
        # Nieznany format, zwróć 0
        total_seconds=0
    fi
    
    echo $total_seconds
}

# Sprawdź każdy proces
killed_count=0
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        # Wyodrębnij PID, użytkownika i czas elapsed
        pid=$(echo "$line" | awk '{print $1}')
        user=$(echo "$line" | awk '{print $2}')
        elapsed=$(echo "$line" | awk '{print $3}')
        cmd=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}')
        
        # Konwertuj czas elapsed na sekundy
        elapsed_seconds=$(elapsed_to_seconds "$elapsed")
        
        log "Sprawdzanie procesu PID: $pid, Czas działania: $elapsed ($elapsed_seconds sekund)"
        
        # Jeśli proces działa dłużej niż próg, zabij go
        if [[ $elapsed_seconds -gt $SECONDS_THRESHOLD ]]; then
            warn "Proces PID $pid działa zbyt długo (${elapsed}). Próba zakończenia..."
            
            # Sprawdź czy proces nadal istnieje
            if kill -0 "$pid" 2>/dev/null; then
                # Najpierw spróbuj delikatnie (SIGTERM)
                if kill -TERM "$pid" 2>/dev/null; then
                    log "Wysłano SIGTERM do procesu $pid"
                    sleep 5
                    
                    # Sprawdź czy proces się zakończył
                    if kill -0 "$pid" 2>/dev/null; then
                        # Jeśli nadal działa, użyj SIGKILL
                        warn "Proces $pid nadal działa. Wymuszanie zakończenia (SIGKILL)..."
                        if kill -KILL "$pid" 2>/dev/null; then
                            log "Proces $pid został zakończony (SIGKILL)"
                            ((killed_count++))
                        else
                            error "Nie można zakończyć procesu $pid"
                        fi
                    else
                        log "Proces $pid został zakończony (SIGTERM)"
                        ((killed_count++))
                    fi
                else
                    error "Nie można wysłać sygnału do procesu $pid"
                fi
            else
                warn "Proces $pid już nie istnieje"
            fi
        else
            log "Proces PID $pid jest wystarczająco świeży (${elapsed})"
        fi
    fi
done <<< "$LFTP_PROCESSES"

# Podsumowanie
echo
if [[ $killed_count -gt 0 ]]; then
    log "Zakończono $killed_count starych procesów lftp"
else
    log "Nie zakończono żadnych procesów lftp"
fi

log "Skrypt zakończony"

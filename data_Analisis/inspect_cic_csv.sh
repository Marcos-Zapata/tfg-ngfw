#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso:
  inspect_cic_csv.sh [--only-labels] archivo1.csv [archivo2.csv ...]
  inspect_cic_csv.sh [--only-labels] /ruta/a/*.csv

Qué hace:
  - Detecta el índice de la columna "Label" ignorando espacios alrededor.
  - Muestra el header y cuántas columnas hay.
  - (Por defecto) Muestra algunos valores únicos de Label y cuenta por etiqueta.
  - Con --only-labels acelera y sólo imprime índice y conteos.

Notas:
  - No carga el CSV completo en memoria.
  - Soporta finales de línea Windows (\r).
  - Asume separador coma (CSV estándar del CICDDoS2019).
USAGE
}

ONLY_LABELS=0
if [[ "${1-}" == "--only-labels" ]]; then
  ONLY_LABELS=1
  shift
fi

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

process_csv () {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "[WARN] No existe: $f" >&2
    return
  fi

  echo "============================================================"
  echo "Archivo: $f"

  # Header (primera línea) sin \r
  local header
  header=$(head -n 1 "$f" | tr -d '\r')
  if [[ -z "$header" ]]; then
    echo "[ERROR] Header vacío" >&2
    return
  fi
  echo "Header:"
  echo "$header"

  # Número de columnas en header
  local ncols
  ncols=$(awk -F, 'NR==1{print NF; exit}' "$f")
  echo "Columnas: $ncols"

  # Índice de la columna Label (ignorando espacios alrededor del nombre)
  # Guardamos en variable 'idx' para que tengas tu misma sintaxis si quieres
  local idx
  idx=$(awk -F, 'NR==1{
      gsub(/\r/,"");
      for(i=1;i<=NF;i++){
        # copia del campo
        c=$i
        # trim espacios
        sub(/^[[:space:]]+/,"",c); sub(/[[:space:]]+$/,"",c)
        if (c=="Label"){ print i; exit }
      }
    }' "$f")

  if [[ -z "${idx:-}" ]]; then
    echo "[ERROR] No se encontró columna Label en: $f" >&2
    return
  fi
  echo "Índice de 'Label': $idx (1=primera columna)"

  if [[ $ONLY_LABELS -eq 1 ]]; then
    # Sólo imprimir conteos por etiqueta
    echo "Conteo por etiqueta:"
    awk -F, -v L="$idx" 'NR>1{
        gsub(/\r/,"");
        lab=$L
        gsub(/^[[:space:]]+/,"",lab); gsub(/[[:space:]]+$/,"",lab)
        c[lab]++
      }
      END{
        for (k in c) printf "%12d  %s\n", c[k], k
      }' "$f" | sort -nr
    return
  fi

  # Mostrar algunos valores únicos de Label
  echo "Valores únicos de Label (primeros 20):"
  awk -F, -v L="$idx" 'NR>1{gsub(/\r/,""); lab=$L; gsub(/^[[:space:]]+|[[:space:]]+$/,"",lab); print lab}' "$f" \
     | sort -u | head -n 20

  # Conteo por etiqueta (ordenado desc)
  echo "Conteo por etiqueta:"
  awk -F, -v L="$idx" 'NR>1{
      gsub(/\r/,"");
      lab=$L
      gsub(/^[[:space:]]+/,"",lab); gsub(/[[:space:]]+$/,"",lab)
      c[lab]++
    }
    END{
      for (k in c) printf "%12d  %s\n", c[k], k
    }' "$f" | sort -nr

  # Ejemplo: las primeras 3 filas (completas) tras el header
  echo "Primeras 3 filas de datos (raw):"
  tail -n +2 "$f" | head -n 3
}

# Recorre todos los argumentos (pueden ser globs)
for path in "$@"; do
  # si es glob sin expandir, que bash lo trate como literal? mejor expandimos nosotros:
  shopt -s nullglob
  files=( $path )
  shopt -u nullglob

  if [[ ${#files[@]} -eq 0 ]]; then
    # si no se expandió, intenta como literal
    files=( "$path" )
  fi

  for f in "${files[@]}"; do
    process_csv "$f"
  done
done


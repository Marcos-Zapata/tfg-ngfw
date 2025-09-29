import pandas as pd
import sys
import os

def count_rows(file_path, chunksize=200_000):
    """Cuenta filas de un CSV leyendo por chunks para no saturar RAM."""
    total = 0
    for chunk in pd.read_csv(file_path, chunksize=chunksize, dtype=str):
        total += len(chunk)
    return total

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 count_rows_chunks.py <archivo.csv>")
        sys.exit(1)

    file_path = sys.argv[1]
    if not os.path.isfile(file_path):
        print(f"❌ No se encontró el archivo: {file_path}")
        sys.exit(1)

    total = count_rows(file_path)
    print(f"✅ {file_path} tiene {total} registros")

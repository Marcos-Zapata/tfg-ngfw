import pandas as pd
from collections import Counter
import sys
import os 

file_path = sys.argv[1]

# Verificar que existe
if not os.path.isfile(file_path):
    raise SystemExit(f"❌ El archivo no existe: {file_path}")

# Buscar la columna 'Label'
cols = pd.read_csv(file_path, nrows=0).columns
label_col = next((c for c in cols if c.strip().lower() == "label"), None)
if label_col is None:
    raise SystemExit(f"❌ No se encontró columna 'Label' en {file_path}")

counts = Counter()

for chunk in pd.read_csv(
    file_path,
    usecols=[" Label"],   # a veces la columna se llama " Label" con espacio delante
    dtype=str,
    chunksize=200_000     # ajusta según tu RAM, empieza con 200k
):
    counts.update(chunk[" Label"].dropna())

print("Valores únicos:", list(counts.keys()))
print("Conteo:")
for k, v in counts.items():
    print(k, v)

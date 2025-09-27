import pandas as pd
from collections import Counter
import os 

file_path = "/home/zapata/CICDDoS2019/01-12/"

# Pedir al usuario el archivo
filename = input("Introduce el nombre del archivo CSV (ej: 03-11.csv): ").strip()

# Construir la ruta completa
file_path = os.path.join(file_path, filename)

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

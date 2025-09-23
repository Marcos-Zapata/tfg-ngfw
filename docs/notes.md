# Apuntes TFG – Preparación de Entorno

## 1. Preparación entorno en WSL
Paquetes necesarios en una instalación base de Ubuntu (WSL):

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget unzip
```

Estos paquetes permiten compilar dependencias, descargar recursos y manejar archivos comprimidos.

---

## 2. Librerías de Python y entorno virtual (venv)

Instalar herramientas de Python en WSL:

```bash
sudo apt install -y python3.12 python3.12-venv python3-pip
```

### Creación del entorno virtual
Cada máquina de desarrollo tendrá su propio entorno virtual (excluido del repositorio por `.gitignore`):

```bash
python3.11 -m venv .venv
```

Esto crea la carpeta `.venv/` dentro del proyecto.

### Activar / desactivar entorno
- Activar:
  ```bash
  source .venv/bin/activate
  ```
- Desactivar:
  ```bash
  deactivate
  ```

Cuando está activo, `python` y `pip` apuntan al entorno virtual, aislando las dependencias del resto del sistema.

---

## 3. Gestión de dependencias con pip-tools

El flujo recomendado es usar dos archivos:

- **`requirements.in`** → Lista de dependencias principales (ej. `scapy==2.5.0`).  
- **`requirements.txt`** → Versión compilada con dependencias exactas (lockfile).  

### Ejemplo `requirements.in`
```text
scapy==2.5.0
fastapi==0.115.0
uvicorn==0.30.6
requests==2.32.3
```

### Compilar a `requirements.txt`
Primero, instalar `pip-tools`:
```bash
pip install pip-tools
```

Después, generar el lock:
```bash
pip-compile requirements.in -o requirements.txt
```

Esto crea un `requirements.txt` con las versiones exactas de todas las dependencias y sub-dependencias.

### Instalar dependencias
```bash
pip install -r requirements.txt
```

---

## 4. Añadir nuevas librerías

Cuando se necesita una nueva dependencia:

1. Añadirla a `requirements.in`  
   ```bash
   echo "numpy==2.1.0" >> requirements.in
   ```

2. Regenerar el lock  
   ```bash
   pip-compile requirements.in -o requirements.txt
   ```

3. Instalar en el entorno  
   ```bash
   pip install -r requirements.txt
   ```

4. Subir cambios al repositorio  
   ```bash
   git add requirements.in requirements.txt
   git commit -m "chore(deps): add numpy 2.1.0"
   git push
   ```

En otra máquina, basta con hacer:
```bash
git pull
source .venv/bin/activate
pip install -r requirements.txt
```
y se tendrá el mismo entorno de librerías.

---

## 5. Buenas prácticas

- Nunca subir `.venv/` al repositorio.  
- Siempre usar `requirements.txt` como fuente de instalación.  
- Mantener `requirements.in` lo más limpio posible (solo dependencias directas).  
- Documentar en `notes.md` las librerías que se añadan y su propósito.  

---

## 6. Resumen rápido

```bash
# Crear entorno virtual
python3.11 -m venv .venv
source .venv/bin/activate

# Instalar pip-tools
pip install pip-tools

# Compilar dependencias
pip-compile requirements.in -o requirements.txt
pip install -r requirements.txt

# Añadir nueva librería
echo "scapy==2.5.0" >> requirements.in
pip-compile requirements.in -o requirements.txt
pip install -r requirements.txt
```

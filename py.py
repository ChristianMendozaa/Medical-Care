import os

def print_structure(directory, indent=0):
    try:
        # Obtener la lista de archivos y carpetas en el directorio
        entries = os.listdir(directory)
        for entry in entries:
            path = os.path.join(directory, entry)
            # Agregar indentación para representar la jerarquía
            print(' ' * indent + '|-- ' + entry)
            # Si es un directorio, llamar a la función recursivamente
            if os.path.isdir(path):
                print_structure(path, indent + 4)
    except PermissionError:
        print(' ' * indent + '|-- [Permission Denied]')

# Cambia "." por la ruta raíz de tu proyecto si es necesario
project_root = "lib"
print(f"Estructura de directorios y archivos de: {project_root}\n")
print_structure(project_root)

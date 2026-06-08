#!/bin/bash
# ─────────────────────────────────────────
#  Instalador de FastVisor
#  Visor de imágenes QML para Dolphin/KDE
# ─────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QML_FILE="$SCRIPT_DIR/fastVisor.qml"
BIN_DIR="$HOME/.local/bin"
SERVICEMENU_DIR="$HOME/.local/share/kio/servicemenus"
DESKTOP_FILE="$SERVICEMENU_DIR/fastvisor.desktop"

# ── Colores ──
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Instalador FastVisor para Dolphin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. Verificar que existe fastVisor.qml ──
if [ ! -f "$QML_FILE" ]; then
    echo -e "${RED}✗ No se encontró fastVisor.qml en el mismo directorio que este script.${NC}"
    echo "  Asegúrate de que ambos archivos estén juntos."
    exit 1
fi
echo -e "${GREEN}✓ fastVisor.qml encontrado${NC}"

# ── 2. Verificar que qml está instalado ──
if ! command -v qml &>/dev/null && ! command -v qml6 &>/dev/null; then
    echo -e "${RED}✗ No se encontró el ejecutable 'qml' o 'qml6'.${NC}"
    echo "  Instálalo con tu gestor de paquetes:"
    echo "    Fedora/RHEL:  sudo dnf install qt6-qtdeclarative"
    echo "    Ubuntu/Debian: sudo apt install qml6-module-qtquick"
    echo "    Arch:         sudo pacman -S qt6-declarative"
    exit 1
fi

# Detecta cuál usar
QML_BIN=$(command -v qml6 2>/dev/null || command -v qml)
echo -e "${GREEN}✓ QML ejecutable: $QML_BIN${NC}"

# ── 3. Crear directorios ──
mkdir -p "$BIN_DIR"
mkdir -p "$SERVICEMENU_DIR"
echo -e "${GREEN}✓ Directorios listos${NC}"

# ── 4. Copiar fastVisor.qml ──
cp "$QML_FILE" "$BIN_DIR/fastVisor.qml"
chmod 755 "$BIN_DIR/fastVisor.qml"
echo -e "${GREEN}✓ fastVisor.qml copiado a $BIN_DIR${NC}"

# ── 5. Crear el .desktop con la ruta real del usuario ──
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Service
MimeType=image/jpeg;image/png;image/webp;image/gif;image/bmp;image/tiff;image/svg+xml;image/avif;
Actions=abrirVisor
X-KDE-ServiceTypes=KonqPopupMenu/Plugin

[Desktop Action abrirVisor]
Name=Abrir en FastVisor
Name[es]=Abrir en FastVisor
Icon=image-viewer
Exec=$QML_BIN $HOME/.local/bin/fastVisor.qml %F
EOF

chmod 755 "$DESKTOP_FILE"
echo -e "${GREEN}✓ fastvisor.desktop creado en $SERVICEMENU_DIR${NC}"

# ── 6. Actualizar caché de KDE ──
echo ""
echo -e "${YELLOW}⟳ Actualizando caché de KDE...${NC}"
if command -v kbuildsycoca6 &>/dev/null; then
    kbuildsycoca6 --noincremental 2>/dev/null && echo -e "${GREEN}✓ Caché actualizada${NC}"
elif command -v kbuildsycoca5 &>/dev/null; then
    kbuildsycoca5 --noincremental 2>/dev/null && echo -e "${GREEN}✓ Caché actualizada${NC}"
else
    echo -e "${YELLOW}⚠ No se pudo actualizar la caché automáticamente.${NC}"
    echo "  Cierra sesión y vuelve a entrar para aplicar los cambios."
fi

# ── 7. Mensaje final ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}  ✓ FastVisor instalado correctamente${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Uso:"
echo "  • Clic derecho sobre una imagen en Dolphin"
echo "  • Selecciona 'Abrir en FastVisor'"
echo ""
echo "  Para asignar un atajo de teclado:"
echo "  Dolphin → Configuración → Configurar atajos"
echo "  → busca 'FastVisor'"
echo ""

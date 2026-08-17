#!/bin/bash
# ⛔ MUERTO — NO CORRER. Ver software/sflow-next (SFlow v3 es la version viva).
#
# Este script firma AD-HOC e instala sobre /Applications/SFlow.app con el MISMO
# bundle ID que v3. Correrlo pisa la app bien firmada con una ad-hoc y macOS
# revoca Accesibilidad/Microfono — es el origen medido de "siempre tengo que
# volver a habilitar permisos en cada actualizacion" (17 ago 2026). De hecho el
# propio script automatizaba el ritual: abria el panel de Accesibilidad al final
# porque SABIA que lo iba a romper.
#
# Se conserva como referencia historica del v1/v2 Python. Si de verdad hace falta
# revivirlo, cambia primero el destino y el bundle ID para que no colisione con v3.
echo "⛔ install.sh de SFlow v1/v2 esta DESACTIVADO (firma ad-hoc → revoca TCC de v3)."
echo "   La version viva es ~/Developer/software/sflow-next: usa ahi scripts/install.sh."
exit 1

# install.sh — Build, install, kill old proc, launch new, open Accessibility.
# Use this instead of `build.sh` when you actually want the running SFlow
# to update. `build.sh` only produces the bundle; this completes the dance.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

bash build.sh

echo ""
echo "=== INSTALL ==="
ditto dist/SFlow.app /Applications/SFlow.app
xattr -cr /Applications/SFlow.app
echo "  → /Applications/SFlow.app"

echo ""
echo "=== KILL OLD INSTANCE ==="
# Why: a running SFlow process keeps using the OLD binary in memory; macOS
# also revokes Accessibility for the new ad-hoc-signed binary, so paste
# breaks silently. Killing forces the user into a clean re-permission flow.
OLD_PID=$(pgrep -f "/Applications/SFlow.app/Contents/MacOS/SFlow" || true)
if [ -n "$OLD_PID" ]; then
    echo "  Matando PID $OLD_PID..."
    kill -TERM $OLD_PID 2>/dev/null || true
    sleep 0.4
    # SIGKILL fallback if still alive
    kill -KILL $OLD_PID 2>/dev/null || true
    echo "  Listo."
else
    echo "  No hay instancia corriendo."
fi

echo ""
echo "=== LAUNCH NEW INSTANCE ==="
open -n /Applications/SFlow.app
sleep 0.6
echo "  Lanzada."

echo ""
echo "=== ACCESSIBILITY PANEL ==="
# After every ad-hoc rebuild, macOS revokes Accessibility for the new binary
# hash. Open the panel so the user can re-add SFlow with one click.
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" || true
echo "  Panel abierto. Quita SFlow (-) y vuelvelo a agregar (+)"
echo "  apuntando a /Applications/SFlow.app"
echo ""
echo "  Luego repite en: Privacy & Security → Input Monitoring"
echo ""
echo "=== INSTALL COMPLETO ==="

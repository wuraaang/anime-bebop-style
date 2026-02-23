#!/bin/bash
# setup-bebop.sh - One-shot installer for Cowboy Bebop Style workflow
# Downloads all required models and custom nodes for ComfyUI
#
# Usage: bash setup-bebop.sh [/path/to/ComfyUI]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# ── 1. Detect ComfyUI path ──────────────────────────────────────────
COMFY_DIR="${1:-}"
if [ -z "$COMFY_DIR" ]; then
    # Try common locations
    for candidate in \
        "$(pwd)" \
        "/workspace/ComfyUI" \
        "/workspace/runpod-slim/ComfyUI" \
        "$HOME/ComfyUI" \
        "/opt/ComfyUI"; do
        if [ -f "$candidate/main.py" ] && [ -d "$candidate/models" ]; then
            COMFY_DIR="$candidate"
            break
        fi
    done
fi

if [ -z "$COMFY_DIR" ] || [ ! -f "$COMFY_DIR/main.py" ]; then
    fail "Could not find ComfyUI installation. Pass the path as argument:\n  bash setup-bebop.sh /path/to/ComfyUI"
fi

info "ComfyUI found at: $COMFY_DIR"

# ── 2. Create model directories ─────────────────────────────────────
DIRS=(
    "$COMFY_DIR/models/checkpoints"
    "$COMFY_DIR/models/loras"
    "$COMFY_DIR/models/upscale_models"
    "$COMFY_DIR/models/ultralytics/bbox"
    "$COMFY_DIR/models/sams"
    "$COMFY_DIR/custom_nodes"
)

for d in "${DIRS[@]}"; do
    mkdir -p "$d"
done
ok "Model directories ready"

# ── 3. Download function ────────────────────────────────────────────
download() {
    local url="$1"
    local dest="$2"
    local name
    name="$(basename "$dest")"

    if [ -f "$dest" ]; then
        ok "Already exists: $name"
        return 0
    fi

    info "Downloading $name ..."

    # Try curl first
    if command -v curl &>/dev/null; then
        if curl -L --fail --progress-bar -o "$dest.tmp" "$url" 2>&1; then
            mv "$dest.tmp" "$dest"
            ok "Downloaded: $name"
            return 0
        fi
        rm -f "$dest.tmp"
        warn "curl failed for $name, trying aria2c..."
    fi

    # Fallback to aria2c
    if command -v aria2c &>/dev/null; then
        local dir
        dir="$(dirname "$dest")"
        if aria2c -x 16 -s 16 -d "$dir" -o "$name" "$url" 2>&1; then
            ok "Downloaded: $name (aria2c)"
            return 0
        fi
        rm -f "$dest"
    fi

    fail "Failed to download $name from $url"
}

# ── 4. Download all models ──────────────────────────────────────────
echo ""
info "=== Downloading models ==="

# Checkpoint: Illustrious XL v2.0
download \
    "https://civitai.com/api/download/models/795765?type=Model&format=SafeTensor&size=full&fp=fp16" \
    "$COMFY_DIR/models/checkpoints/illustriousXLV20_v20Stable.safetensors"

# LoRA: Cowboy Bebop Style
download \
    "https://civitai.com/api/download/models/1241218?type=Model&format=SafeTensor" \
    "$COMFY_DIR/models/loras/cowboy-bebop-style-illustriousxl.safetensors"

# Upscale: RealESRGAN x4plus Anime 6B
download \
    "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth" \
    "$COMFY_DIR/models/upscale_models/RealESRGAN_x4plus_anime_6B.pth"

# Face detector: YOLOv8m
download \
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
    "$COMFY_DIR/models/ultralytics/bbox/face_yolov8m.pt"

# SAM: ViT-B
download \
    "https://huggingface.co/spaces/jbrinkma/segment-anything/resolve/main/sam_vit_b_01ec64.pth" \
    "$COMFY_DIR/models/sams/sam_vit_b_01ec64.pth"

# ── 5. Install custom nodes ─────────────────────────────────────────
echo ""
info "=== Installing custom nodes ==="

install_node() {
    local repo="$1"
    local name
    name="$(basename "$repo" .git)"

    if [ -d "$COMFY_DIR/custom_nodes/$name" ]; then
        ok "Already installed: $name"
        return 0
    fi

    info "Cloning $name ..."
    git clone "$repo" "$COMFY_DIR/custom_nodes/$name" 2>&1

    # Install requirements if present
    if [ -f "$COMFY_DIR/custom_nodes/$name/requirements.txt" ]; then
        info "Installing requirements for $name ..."
        pip install -r "$COMFY_DIR/custom_nodes/$name/requirements.txt" 2>&1
    fi

    ok "Installed: $name"
}

install_node "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
install_node "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"

# ── 6. Done ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Cowboy Bebop Style workflow setup complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Models installed in:  $COMFY_DIR/models/"
echo "  Custom nodes in:      $COMFY_DIR/custom_nodes/"
echo ""
echo "  Next steps:"
echo "    1. Restart ComfyUI if it's running"
echo "    2. Load workflow/bebop-avatar-workflow.json"
echo "    3. Generate!"
echo ""

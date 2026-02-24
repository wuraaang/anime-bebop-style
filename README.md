# Cowboy Bebop Style — ComfyUI Workflows

Two ComfyUI workflows for generating **Cowboy Bebop style** anime art. One script installs everything.

![Sample Output](images/sample-output.png)

> *"See you space cowboy..."*

---

## Included Workflows

### 1. Outpainting — Bebop Background
Generate a **Cowboy Bebop style anime background** around a portrait photo.
Upload a photo, the pipeline removes the background, outpaints a Bebop-style scene, and composites the original portrait back at full quality.

**Output:** 1344x768 (16:9) — YouTube thumbnails, banners, video backgrounds.

### 2. Avatar — Bebop Character
Generate a **full anime character portrait** from scratch in Cowboy Bebop style.
21-node pipeline: base generation → latent upscale → HiRes fix → FaceDetailer → Ultimate SD Upscale x2.

**Output:** ~2080x3040px — YouTube avatars, talking head, profile pictures.

---

## What you get

- Widescreen anime backgrounds with your portrait composited in (outpainting)
- High-res anime character portraits in Bebop style (avatar)
- Ideal for: YouTube thumbnails, channel banners, talking head content, stream overlays, profile pics

---

## Pipelines

### Outpainting Pipeline

```
LoadImage (portrait)
    |
    +---> BiRefNet Matting ──> mask
    |                           |
    +---> ImagePadForOutpaint (1344x768, feathering 48)
    |         |
    |    VAEEncodeForInpaint
    |         |
    |    KSampler (30 steps, CFG 7, euler_ancestral, denoise 1.0)
    |         |
    |    VAEDecode ──> outpainted image
    |                       |
    +---> Pad Original (1344x768, feathering 0)
              |              |
         InvertMask    ImageCompositeMasked
                             |
                      Preview + Save (1344x768)
```

### Avatar Pipeline

```
Checkpoint (Illustrious XL) + LoRA (Bebop Style) + CLIP Skip -2
    |
    +---> Positive/Negative Prompts
    |         |
    |    EmptyLatentImage (832x1216)
    |         |
    |    KSampler - Base (30 steps, CFG 5.5, euler_ancestral)
    |         |
    |    LatentUpscale x1.25
    |         |
    |    KSampler - HiRes Refine (20 steps, CFG 8, euler, denoise 0.45)
    |         |
    |    VAEDecode
    |         |
    |    FaceDetailer (YOLOv8 + SAM, denoise 0.25)
    |         |
    |    Ultimate SD Upscale x2 (RealESRGAN Anime 6B)
    |         |
    |    Save Output (~2080x3040px)
```

---

## Models Required

| Model | Used by | Destination |
|---|---|---|
| **Illustrious XL v2.0** | Both | `models/checkpoints/` |
| **Cowboy Bebop Style LoRA** | Both | `models/loras/` |
| **face_yolov8m.pt** | Avatar | `models/ultralytics/bbox/` |
| **sam_vit_b_01ec64.pth** | Avatar | `models/sams/` |
| **RealESRGAN_x4plus_anime_6B.pth** | Avatar | `models/upscale_models/` |

> BiRefNet Matting model (outpainting) is auto-downloaded on first run.

---

## Custom Nodes Required

| Node | Purpose | Used by |
|---|---|---|
| **ComfyUI_BiRefNet_ll** | Background removal (matting) | Outpainting |
| **ComfyUI-KJNodes** | ImagePadForOutpaintTargetSize | Outpainting |
| **ComfyUI-Impact-Pack** | FaceDetailer, SAMLoader, UltralyticsDetectorProvider | Avatar |
| **ComfyUI_UltimateSDUpscale** | UltimateSDUpscale tiled upscaling | Avatar |

---

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/wuraaang/anime-bebop-style.git
cd anime-bebop-style

# 2. Run the setup script (downloads models + installs custom nodes + copies workflows)
bash setup-bebop.sh /path/to/ComfyUI

# 3. Restart ComfyUI

# 4. Load a workflow from the ComfyUI menu
#    - bebop-outpaint-workflow.json  → upload a portrait photo
#    - bebop-avatar-workflow.json    → just hit Queue
```

---

## Prompting Guide

**Trigger word (mandatory for both workflows):** `cowboy_bebop_style`

### Outpainting Prompts

**Positive (background description):**
```
cowboy_bebop_style; interior of the Bebop spaceship lounge;
sitting on a worn leather couch; warm amber backlighting from a large window behind;
golden hour sunlight streaming through glass; cyberpunk cityscape visible through window;
dim moody interior lighting; retro-futuristic room details;
anime background; masterpiece; best quality; highly detailed background
```

**Negative:**
```
worst quality; low quality; blurry; deformed; watermark; text; logo; signature;
jpeg artifacts; out of frame; cropped; bright flat lighting; white background;
plain background; empty background; person; character; face; body; extra limbs
```

| Parameter | Value |
|---|---|
| Output resolution | 1344x768 (16:9) |
| LoRA strength | 0.8 |
| Steps / CFG | 30 / 7 |
| Sampler | euler_ancestral |

### Avatar Prompts

**Positive (character description):**
```
masterpiece, best quality, amazing quality, cowboy_bebop_style,
(1girl:1.3), (beautiful woman:1.2), (feminine face:1.3), solo, portrait, bust shot,
looking at viewer, sharp amber eyes, (long flowing violet hair:1.2),
gold hoop earrings, oversized black leather jacket, dark red crop top,
simple dark background, retro anime, 90s anime aesthetic,
(cel shading:1.2), (flat color:1.2), (bold lineart:1.1), 2d, highres
```

**Negative:**
```
worst quality, low quality, blurry, deformed, extra fingers, bad anatomy,
watermark, text, signature, 3d, realistic, photorealistic, nsfw,
male, man, masculine, multiple characters, red marks, face markings
```

| Parameter | Value |
|---|---|
| Output resolution | ~2080x3040px |
| LoRA strength | 1.0 |
| Base: Steps / CFG | 30 / 5.5 (euler_ancestral) |
| HiRes: Steps / CFG | 20 / 8.0 (euler, denoise 0.45) |
| FaceDetailer denoise | 0.25 |
| Final upscale | x2 RealESRGAN Anime 6B |

---

## Tips

- **Outpainting:** negative excludes `person; face; body` so only background is generated. Adjust positive to change the scene.
- **Avatar:** vary the seed for completely different characters. LoRA 0.8–1.0 controls Bebop style intensity.
- The composite step (outpainting) preserves original portrait quality
- Dark background on avatar = ideal for talking head / LongCat / SadTalker

---

## License

MIT — models have their own licenses, check original pages.

# Cowboy Bebop Outpainting — ComfyUI Workflow

Generate **Cowboy Bebop style anime backgrounds** around a portrait photo using ComfyUI.
Upload a photo, the pipeline removes the background, outpaints a Bebop-style scene around the subject, and composites the original portrait back at full quality.

Output: **1344x768 (16:9)** — ready for YouTube thumbnails, banners, and video backgrounds.

![Sample Output](images/sample-output.png)

> *"See you space cowboy..."*

---

## What you get

A widescreen anime background in Cowboy Bebop style with your portrait composited in — ideal for:
- YouTube thumbnails & channel banners
- Video backgrounds for talking head content
- Stream overlays
- Social media covers

---

## Pipeline

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

The composite step pastes the original portrait pixels back over the outpainted result,
so the subject stays sharp while only the background is AI-generated.

---

## Models Required

| Model | Link | Destination |
|---|---|---|
| **Illustrious XL v2.0** | [CivitAI](https://civitai.com/models/795765) | `models/checkpoints/` |
| **Cowboy Bebop Style LoRA** | [CivitAI](https://civitai.com/models/1747626) | `models/loras/` |

> BiRefNet Matting model is auto-downloaded on first run by the `AutoDownloadBiRefNetModel` node.

---

## Custom Nodes Required

| Node | Purpose | URL |
|---|---|---|
| **ComfyUI_BiRefNet_ll** | Background removal (matting) | [GitHub](https://github.com/lldacing/ComfyUI_BiRefNet_ll) |
| **ComfyUI-KJNodes** | ImagePadForOutpaintTargetSize | [GitHub](https://github.com/kijai/ComfyUI-KJNodes) |

---

## Quick Start

```bash
# 1. Run the setup script (downloads models + installs custom nodes)
bash setup-bebop.sh /path/to/ComfyUI

# 2. Restart ComfyUI

# 3. Load the workflow
#    File > Load > workflow/bebop-outpaint-workflow.json

# 4. Upload a portrait photo in the "Portrait Source" node and queue
```

---

## Prompting Guide

**Trigger word (mandatory):** `cowboy_bebop_style`

**Positive prompt (background description):**
```
cowboy_bebop_style; interior of the Bebop spaceship lounge;
sitting on a worn leather couch; warm amber backlighting from a large window behind;
golden hour sunlight streaming through glass; cyberpunk cityscape visible through window;
dim moody interior lighting; retro-futuristic room details; old CRT monitors on the walls;
dark atmospheric shadows; dramatic rim lighting on edges;
anime background; masterpiece; best quality; highly detailed background
```

**Negative prompt:**
```
worst quality; low quality; blurry; deformed; watermark; text; logo; signature;
jpeg artifacts; out of frame; cropped; bright flat lighting; white background;
plain background; empty background; person; character; face; body; extra limbs
```

**Key settings:**

| Parameter | Value |
|---|---|
| Output resolution | 1344x768 (16:9) |
| LoRA strength | 0.8 |
| Steps | 30 |
| CFG | 7 |
| Sampler | euler_ancestral |
| Scheduler | normal |
| Denoise | 1.0 |
| Feathering (outpaint) | 48 |
| BiRefNet model | Matting |

---

## Tips

- The negative prompt excludes `person; character; face; body` so the outpainting only generates background
- Adjust the positive prompt to change the scene (bar, rooftop, cockpit, etc.)
- LoRA 0.7-0.9 controls Bebop style intensity
- The composite step preserves original portrait quality — only the background is AI-generated

---

## License

MIT — models have their own licenses, check original pages.

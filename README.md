# 🚀 Cowboy Bebop Anime Avatar — ComfyUI Workflow

Generate high quality **Cowboy Bebop style anime portraits** using ComfyUI.
Full pipeline with HiRes Fix, FaceDetailer and RealESRGAN upscale.

![Sample Output](images/sample-output.png)

> *"See you space cowboy..."*

---

## ✨ What you get

A clean, high-resolution 90s anime cel shading portrait — ideal for:
- YouTube faceless channel avatar
- Talking head animation (LongCat, SadTalker)
- Thumbnails & channel branding
- Profile pictures

---

## 📦 Models Required

| Model | Link | Destination |
|---|---|---|
| **Illustrious XL v2.0** | [CivitAI](https://civitai.com/models/795765) | `models/checkpoints/` |
| **Cowboy Bebop Style LoRA** | [CivitAI](https://civitai.com/models/1747626) | `models/loras/` |
| **face_yolov8m.pt** | [HuggingFace](https://huggingface.co/Bingsu/adetailer) | `models/ultralytics/bbox/` |
| **sam_vit_b_01ec64.pth** | [Meta](https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth) | `models/sams/` |
| **RealESRGAN_x4plus_anime_6B.pth** | [GitHub](https://github.com/xinntao/Real-ESRGAN/releases/tag/v0.2.2.4) | `models/upscale_models/` |

---

## 🔌 Custom Nodes Required

Install via **ComfyUI Manager**:
- `ComfyUI-Impact-Pack` — FaceDetailer
- `ComfyUI_UltimateSDUpscale` — UltimateSDUpscale

---

## 🚀 Pipeline

```
EmptyLatentImage (832x1216)
        ↓
KSampler — 30 steps, CFG 5.5, euler_ancestral     ← Main generation
        ↓
LatentUpscaleBy x1.25                              ← HiRes Fix prep
        ↓
KSampler — 20 steps, CFG 8.0, euler, denoise 0.45 ← HiRes Fix refine
        ↓
VAEDecode
        ↓
FaceDetailer (YOLOv8 + SAM, denoise 0.25)         ← Face cleanup
        ↓
UltimateSDUpscale x2 (RealESRGAN Anime6B)         ← Final upscale ~2080x3040
        ↓
SaveImage
```

---

## 🎨 Prompting Guide

**Trigger word (mandatory):** `cowboy_bebop_style`

**Positive prompt:**
```
masterpiece, best quality, amazing quality, cowboy_bebop_style,
(1girl:1.3), (beautiful woman:1.2), (feminine face:1.3), fair skin, female,
solo, portrait, bust shot, looking at viewer, confident smirk,
(long flowing white hair:1.2), sharp green eyes,
gold hoop earrings, gold chain necklace,
oversized dark jacket, black crop top, simple dark background,
retro anime, 90s anime aesthetic, cel shading, flat color, 2d,
soft dramatic lighting, highres
```

**Negative prompt:**
```
worst quality, low quality, blurry, deformed, extra fingers, bad anatomy,
watermark, text, signature, 3d, realistic, photorealistic, nsfw,
male, man, masculine, artifacts, distorted face, multiple characters
```

> ⚠️ Do NOT use `scars`, `face markings` or `red marks` — causes red artifacts with FaceDetailer.

**Key settings:**

| Parameter | Value |
|---|---|
| CLIP skip | -2 |
| LoRA strength | 1.0 |
| Resolution | 832x1216 |
| CFG main | 5.5 |
| CFG HiRes | 8.0 |
| Sampler main | euler_ancestral |
| Sampler refine | euler |
| Scheduler | normal |
| HiRes denoise | 0.45 |
| FaceDetailer denoise | 0.25 |
| Upscale | 2x RealESRGAN Anime6B |

---

## 💡 Tips

- Try different seeds — character varies a lot
- LoRA 0.8–1.0 controls Bebop style intensity
- Use plain dark background for talking head animation (LongCat compatible)

---

## 📄 License

MIT — models have their own licenses, check original pages.

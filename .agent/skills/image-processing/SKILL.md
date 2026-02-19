---
name: Image Processing
description: Skill for server-side image processing — covering Sharp (Node.js), Pillow (Python), resizing, cropping, watermarking, format conversion, thumbnail generation, and optimization.
---

# Image Processing Skill

## Overview
Server-side image processing for resizing, cropping, watermarking, format conversion, and optimization.

## Sharp (Node.js — Recommended)
```typescript
import sharp from "sharp";

// Resize
await sharp("input.jpg")
  .resize(800, 600, { fit: "cover", position: "center" })
  .jpeg({ quality: 85, progressive: true })
  .toFile("output.jpg");

// Thumbnail
await sharp(inputBuffer)
  .resize(200, 200, { fit: "cover" })
  .webp({ quality: 80 })
  .toBuffer();

// Watermark
const watermark = await sharp("watermark.png").resize(200).toBuffer();
await sharp("photo.jpg")
  .composite([{ input: watermark, gravity: "southeast", blend: "over" }])
  .toFile("watermarked.jpg");

// Format conversion
await sharp("photo.png").webp({ quality: 85 }).toFile("photo.webp");
await sharp("photo.jpg").avif({ quality: 60 }).toFile("photo.avif");

// Get metadata
const metadata = await sharp("photo.jpg").metadata();
console.log(metadata.width, metadata.height, metadata.format);

// Batch processing
async function processUpload(buffer: Buffer, filename: string) {
  const variants = [
    { name: "thumb", width: 150, height: 150 },
    { name: "medium", width: 800, height: 600 },
    { name: "large", width: 1920, height: 1080 },
  ];

  return Promise.all(variants.map(async (v) => {
    const output = await sharp(buffer)
      .resize(v.width, v.height, { fit: "inside", withoutEnlargement: true })
      .webp({ quality: 85 })
      .toBuffer();
    return { name: `${v.name}-${filename}.webp`, buffer: output, size: output.length };
  }));
}

// Express upload middleware
import multer from "multer";
const upload = multer({ limits: { fileSize: 10 * 1024 * 1024 }, fileFilter: (_, file, cb) => {
  if (file.mimetype.startsWith("image/")) cb(null, true);
  else cb(new Error("Only images allowed"));
}});

app.post("/upload", upload.single("image"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No file" });
  const variants = await processUpload(req.file.buffer, req.file.originalname);
  // Upload variants to S3/storage...
  res.json({ images: variants.map(v => ({ name: v.name, size: v.size })) });
});
```

## Pillow (Python)
```python
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# Resize
img = Image.open("input.jpg")
img = img.resize((800, 600), Image.LANCZOS)
img.save("output.jpg", quality=85, optimize=True)

# Thumbnail (preserves aspect ratio)
img.thumbnail((200, 200), Image.LANCZOS)

# Crop
img = img.crop((left, top, right, bottom))

# Watermark
base = Image.open("photo.jpg")
watermark = Image.open("watermark.png").resize((200, 50))
base.paste(watermark, (base.width - 210, base.height - 60), watermark)
base.save("watermarked.jpg")

# Format conversion
Image.open("photo.png").save("photo.webp", "webp", quality=85)
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Sharp** | Fastest Node.js option (libvips-based) |
| **WebP/AVIF** | Prefer modern formats for web |
| **Progressive JPEG** | Enable for better perceived loading |
| **Variants** | Generate thumb, medium, large on upload |
| **Streaming** | Process as streams/buffers, not files |
| **Validation** | Validate MIME type and file size |
| **EXIF orientation** | Sharp auto-rotates by default |
| **Lazy loading** | Serve appropriate size per viewport |

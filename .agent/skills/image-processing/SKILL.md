---
name: Image Processing
description: Skill for server-side image processing — covering Sharp (Node.js), Pillow (Python), resizing, cropping, watermarking, format conversion, thumbnail generation, and optimization.
---

# Image Processing Skill

## Overview
Server-side image processing is essential for user uploads, thumbnails, avatars, watermarking, and format optimization. Sharp (Node.js) and Pillow (Python) are the most popular libraries, offering high-performance image manipulation.

**References**:
- [Sharp Documentation](https://sharp.pixelplumbing.com/)
- [Pillow Documentation](https://pillow.readthedocs.io/)

---

## Sharp (Node.js)

### Setup
```bash
npm install sharp
```

### Resize & Optimize
```typescript
// src/lib/image-processor.ts
import sharp from 'sharp';
import path from 'path';
import crypto from 'crypto';

interface ProcessedImage {
  filename: string;
  path: string;
  width: number;
  height: number;
  size: number;
  format: string;
}

// ── Resize and optimize uploaded image ──
async function processUpload(
  buffer: Buffer,
  originalName: string,
): Promise<ProcessedImage> {
  const hash = crypto.randomBytes(8).toString('hex');
  const filename = `${hash}.webp`;
  const outputPath = path.join(process.env.UPLOAD_DIR!, filename);

  const result = await sharp(buffer)
    .resize(1200, 1200, {
      fit: 'inside',            // Maintain aspect ratio, fit within bounds
      withoutEnlargement: true, // Don't upscale small images
    })
    .webp({ quality: 80 })     // Convert to WebP for smaller size
    .toFile(outputPath);

  return {
    filename,
    path: outputPath,
    width: result.width,
    height: result.height,
    size: result.size,
    format: 'webp',
  };
}

// ── Generate thumbnails (multiple sizes) ──
async function generateThumbnails(
  buffer: Buffer,
  baseName: string,
): Promise<Record<string, ProcessedImage>> {
  const sizes = {
    sm: { width: 150, height: 150 },
    md: { width: 400, height: 400 },
    lg: { width: 800, height: 800 },
  };

  const results: Record<string, ProcessedImage> = {};

  for (const [size, dimensions] of Object.entries(sizes)) {
    const filename = `${baseName}_${size}.webp`;
    const outputPath = path.join(process.env.UPLOAD_DIR!, filename);

    const result = await sharp(buffer)
      .resize(dimensions.width, dimensions.height, {
        fit: 'cover',           // Crop to fill exact dimensions
        position: 'centre',
      })
      .webp({ quality: size === 'sm' ? 60 : 80 })
      .toFile(outputPath);

    results[size] = {
      filename,
      path: outputPath,
      width: result.width,
      height: result.height,
      size: result.size,
      format: 'webp',
    };
  }

  return results;
}

// ── Avatar processing (square crop + circle mask) ──
async function processAvatar(buffer: Buffer, userId: string): Promise<ProcessedImage> {
  const size = 200;
  const filename = `avatar_${userId}.webp`;
  const outputPath = path.join(process.env.UPLOAD_DIR!, 'avatars', filename);

  // Create circular mask
  const circleMask = Buffer.from(
    `<svg width="${size}" height="${size}">
      <circle cx="${size / 2}" cy="${size / 2}" r="${size / 2}" fill="white"/>
    </svg>`
  );

  const result = await sharp(buffer)
    .resize(size, size, { fit: 'cover', position: 'centre' })
    .composite([{
      input: circleMask,
      blend: 'dest-in',
    }])
    .webp({ quality: 80 })
    .toFile(outputPath);

  return {
    filename,
    path: outputPath,
    width: size,
    height: size,
    size: result.size,
    format: 'webp',
  };
}

// ── Watermark ──
async function addWatermark(
  inputBuffer: Buffer,
  watermarkPath: string,
): Promise<Buffer> {
  const image = sharp(inputBuffer);
  const metadata = await image.metadata();

  // Resize watermark to 20% of image width
  const watermarkWidth = Math.round((metadata.width || 800) * 0.2);
  const watermark = await sharp(watermarkPath)
    .resize(watermarkWidth)
    .ensureAlpha(0.5)  // 50% opacity
    .toBuffer();

  return image
    .composite([{
      input: watermark,
      gravity: 'southeast',  // Bottom-right corner
      blend: 'over',
    }])
    .toBuffer();
}

// ── Format conversion ──
async function convertFormat(
  buffer: Buffer,
  format: 'webp' | 'jpeg' | 'png' | 'avif',
  quality: number = 80,
): Promise<Buffer> {
  let pipeline = sharp(buffer);

  switch (format) {
    case 'webp':
      pipeline = pipeline.webp({ quality });
      break;
    case 'jpeg':
      pipeline = pipeline.jpeg({ quality, mozjpeg: true });
      break;
    case 'png':
      pipeline = pipeline.png({ compressionLevel: 9 });
      break;
    case 'avif':
      pipeline = pipeline.avif({ quality });
      break;
  }

  return pipeline.toBuffer();
}

// ── Get image metadata ──
async function getMetadata(buffer: Buffer) {
  const metadata = await sharp(buffer).metadata();
  return {
    width: metadata.width,
    height: metadata.height,
    format: metadata.format,
    size: metadata.size,
    hasAlpha: metadata.hasAlpha,
    orientation: metadata.orientation,
  };
}
```

### Upload Handler (Express)
```typescript
// src/routes/upload.ts
import multer from 'multer';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },  // 10MB
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`File type ${file.mimetype} not allowed`));
    }
  },
});

app.post('/api/upload/image', upload.single('image'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image provided' });
  }

  const processed = await processUpload(req.file.buffer, req.file.originalname);
  const thumbnails = await generateThumbnails(req.file.buffer, processed.filename.replace('.webp', ''));

  res.json({
    original: processed,
    thumbnails,
  });
});

app.post('/api/upload/avatar', upload.single('avatar'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image provided' });
  }

  const avatar = await processAvatar(req.file.buffer, req.user.id);

  await db.user.update({
    where: { id: req.user.id },
    data: { avatarUrl: `/uploads/avatars/${avatar.filename}` },
  });

  res.json({ avatar });
});
```

### S3 Upload Integration
```typescript
// Upload processed image to S3
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

const s3 = new S3Client({ region: process.env.AWS_REGION });

async function uploadToS3(buffer: Buffer, key: string, contentType: string): Promise<string> {
  await s3.send(new PutObjectCommand({
    Bucket: process.env.AWS_S3_BUCKET!,
    Key: key,
    Body: buffer,
    ContentType: contentType,
    CacheControl: 'public, max-age=31536000, immutable',
  }));

  return `https://${process.env.AWS_S3_BUCKET}.s3.amazonaws.com/${key}`;
}

// Process and upload
const optimized = await sharp(buffer).resize(1200, 1200, { fit: 'inside' }).webp({ quality: 80 }).toBuffer();
const url = await uploadToS3(optimized, `images/${filename}`, 'image/webp');
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **WebP format** | Convert to WebP for 25-35% smaller files vs JPEG |
| **Memory buffer** | Use `multer.memoryStorage()` for processing before disk |
| **Size limits** | Max 10MB upload, validate in multer |
| **MIME validation** | Check file type in multer fileFilter |
| **Thumbnails** | Generate sm/md/lg on upload, serve appropriate size |
| **Lazy processing** | For high traffic, queue image processing (BullMQ) |
| **CDN caching** | Upload to S3/CloudFront with immutable Cache-Control |
| **No enlargement** | `withoutEnlargement: true` to prevent upscaling |
| **Metadata strip** | Sharp strips EXIF metadata by default (privacy) |
| **Error handling** | Catch corrupt/invalid image errors gracefully |

---

## Rules Integration
- **Processing**: Sharp for resize, crop, convert, watermark, metadata
- **Formats**: WebP (recommended), JPEG (mozjpeg), PNG, AVIF
- **Uploads**: Multer memory storage, MIME validation, size limits
- **Storage**: Local filesystem or S3 with CDN caching
- **Thumbnails**: Generate multiple sizes on upload

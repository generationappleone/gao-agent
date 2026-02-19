---
name: MCP Server — ImageSorcery
description: MCP Server for ImageSorcery — enables AI assistants to process, transform, resize, convert, and manipulate images through MCP tools.
---

# MCP Server — ImageSorcery

## Overview
ImageSorcery MCP Server provides AI assistants with image processing capabilities including resizing, cropping, format conversion, watermarking, and various image transformations.

## Tools Provided

| Tool | Description |
|------|-------------|
| `resize_image` | Resize image to specified dimensions |
| `crop_image` | Crop image to a region |
| `convert_format` | Convert between image formats (PNG, JPG, WebP, etc.) |
| `rotate_image` | Rotate image by degrees |
| `flip_image` | Flip image horizontally or vertically |
| `add_watermark` | Add text or image watermark |
| `compress_image` | Optimize image file size |
| `get_metadata` | Get image EXIF and metadata |
| `apply_filter` | Apply visual filters (blur, sharpen, grayscale) |
| `generate_thumbnail` | Create thumbnail versions |

## Configuration

```json
{
  "mcpServers": {
    "imagesorcery": {
      "command": "npx",
      "args": ["-y", "imagesorcery-mcp"],
      "env": {}
    }
  }
}
```

## Use Cases
- Batch image processing and optimization
- Image format conversion for web deployment
- Thumbnail generation for content management
- Watermark application for brand protection
- Image metadata extraction and analysis

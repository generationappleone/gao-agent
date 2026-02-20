---
name: MongoDB
description: Skill for designing and developing MongoDB databases, covering document modeling, aggregation pipelines, indexing strategies, schema validation, transactions, and operational best practices.
---

# MongoDB Skill

## Overview
MongoDB is a document-oriented NoSQL database that stores data in flexible JSON-like documents (BSON). It provides powerful querying, aggregation pipelines, indexing, replication, sharding, and transactions. MongoDB excels at handling semi-structured data and rapid development.

**References**:
- [MongoDB Documentation](https://www.mongodb.com/docs/manual/)
- [Mongoose ODM](https://mongoosejs.com/docs/)
- [MongoDB Aggregation](https://www.mongodb.com/docs/manual/aggregation/)

---

## Setup

```yaml
# docker-compose.yml
services:
  mongodb:
    image: mongo:7
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
      MONGO_INITDB_DATABASE: myapp
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped

volumes:
  mongo_data:
```

```typescript
// src/lib/mongoose.ts
import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/myapp';

export async function connectDB() {
  if (mongoose.connection.readyState >= 1) return;

  await mongoose.connect(MONGODB_URI, {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  });

  mongoose.connection.on('error', (err) => console.error('MongoDB error:', err));
  console.log('MongoDB connected');
}
```

---

## Schemas & Models

```typescript
// src/models/User.ts
import mongoose, { Schema, Document } from 'mongoose';
import bcrypt from 'bcrypt';

export interface IUser extends Document {
  email: string;
  password: string;
  name: string;
  role: 'user' | 'admin' | 'editor';
  avatar?: string;
  comparePassword(candidate: string): Promise<boolean>;
}

const UserSchema = new Schema<IUser>({
  email:    { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true, minlength: 8, select: false },
  name:     { type: String, required: true, trim: true },
  role:     { type: String, enum: ['user', 'admin', 'editor'], default: 'user' },
  avatar:   { type: String },
}, {
  timestamps: true,
  toJSON: { transform: (_, ret) => { delete ret.password; delete ret.__v; return ret; } },
});

// Index for search
UserSchema.index({ name: 'text', email: 'text' });

// Hash password
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

UserSchema.methods.comparePassword = async function (candidate: string): Promise<boolean> {
  return bcrypt.compare(candidate, this.password);
};

export const User = mongoose.model<IUser>('User', UserSchema);
```

```typescript
// src/models/Product.ts
import mongoose, { Schema, Document } from 'mongoose';

export interface IProduct extends Document {
  name: string;
  slug: string;
  description?: string;
  price: number;
  stock: number;
  category: mongoose.Types.ObjectId;
  status: 'draft' | 'active' | 'archived';
  rating: number;
  ratingCount: number;
  images: string[];
  metadata?: Record<string, any>;
}

const ProductSchema = new Schema<IProduct>({
  name:        { type: String, required: true, maxlength: 200 },
  slug:        { type: String, required: true, unique: true },
  description: { type: String },
  price:       { type: Number, required: true, min: 0 },
  stock:       { type: Number, required: true, min: 0, default: 0 },
  category:    { type: Schema.Types.ObjectId, ref: 'Category', required: true },
  status:      { type: String, enum: ['draft', 'active', 'archived'], default: 'draft' },
  rating:      { type: Number, default: 0 },
  ratingCount: { type: Number, default: 0 },
  images:      [{ type: String }],
  metadata:    { type: Schema.Types.Mixed },
}, { timestamps: true });

ProductSchema.index({ status: 1, category: 1 });
ProductSchema.index({ price: 1 });
ProductSchema.index({ rating: -1 });
ProductSchema.index({ name: 'text', description: 'text' });

// Auto-generate slug
ProductSchema.pre('save', function (next) {
  if (this.isModified('name') && !this.slug) {
    this.slug = this.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  }
  next();
});

export const Product = mongoose.model<IProduct>('Product', ProductSchema);
```

---

## CRUD Operations

```typescript
// src/services/product.service.ts

// ── List with filters + pagination ──
export async function listProducts(options: {
  category?: string; search?: string; status?: string;
  sortBy?: string; page?: number; limit?: number;
}) {
  const { page = 1, limit = 20 } = options;
  const filter: any = {};

  if (options.status) filter.status = options.status;
  if (options.category) filter.category = options.category;
  if (options.search) {
    filter.$text = { $search: options.search };
  }

  const sort: any = (() => {
    switch (options.sortBy) {
      case 'price_asc': return { price: 1 };
      case 'price_desc': return { price: -1 };
      case 'rating': return { rating: -1 };
      default: return { createdAt: -1 };
    }
  })();

  const [data, total] = await Promise.all([
    Product.find(filter)
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(limit)
      .populate('category', 'name slug')
      .lean(),
    Product.countDocuments(filter),
  ]);

  return { data, total, page, totalPages: Math.ceil(total / limit) };
}

// ── Create ──
export async function createProduct(data: CreateProductInput) {
  return Product.create(data);
}

// ── Update ──
export async function updateProduct(id: string, data: Partial<IProduct>) {
  return Product.findByIdAndUpdate(id, data, { new: true, runValidators: true });
}
```

---

## Aggregation Pipelines

```typescript
// ── Monthly revenue ──
export async function getMonthlyRevenue(months = 12) {
  return Order.aggregate([
    { $match: { status: { $nin: ['cancelled'] }, createdAt: { $gte: new Date(Date.now() - months * 30 * 24 * 60 * 60 * 1000) } } },
    { $group: {
      _id: { year: { $year: '$createdAt' }, month: { $month: '$createdAt' } },
      revenue: { $sum: '$total' },
      orderCount: { $sum: 1 },
      avgOrderValue: { $avg: '$total' },
      uniqueCustomers: { $addToSet: '$userId' },
    }},
    { $project: {
      _id: 0, year: '$_id.year', month: '$_id.month',
      revenue: 1, orderCount: 1, avgOrderValue: { $round: ['$avgOrderValue', 0] },
      uniqueCustomers: { $size: '$uniqueCustomers' },
    }},
    { $sort: { year: -1, month: -1 } },
  ]);
}

// ── Top products by sales ──
export async function getTopProducts(limit = 10) {
  return Order.aggregate([
    { $match: { status: { $nin: ['cancelled'] } } },
    { $unwind: '$items' },
    { $group: {
      _id: '$items.productId',
      totalSold: { $sum: '$items.quantity' },
      totalRevenue: { $sum: '$items.total' },
    }},
    { $sort: { totalRevenue: -1 } },
    { $limit: limit },
    { $lookup: { from: 'products', localField: '_id', foreignField: '_id', as: 'product' } },
    { $unwind: '$product' },
    { $project: { name: '$product.name', price: '$product.price', totalSold: 1, totalRevenue: 1 } },
  ]);
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Schema design** | Embed for 1:few, reference for 1:many |
| **Indexes** | Create indexes for common query patterns |
| **Text search** | Use text indexes for full-text search |
| **lean()** | Use `.lean()` for read-only queries (faster) |
| **populate** | Select only needed fields in populate |
| **Aggregation** | Use pipelines for complex analytics |
| **Timestamps** | Enable `{ timestamps: true }` on schemas |
| **Validation** | Schema-level validation (required, min, enum) |
| **Password** | Use `select: false` and pre-save hash |
| **Connection** | Connection pooling with `maxPoolSize` |

---

## Rules Integration
- **Schemas**: Mongoose with validation, hooks, methods, indexes
- **CRUD**: Find with filters, pagination, populate, lean
- **Aggregation**: Revenue reports, top products, analytics
- **Security**: Password hashing, field selection, validation
- **Performance**: Compound indexes, text search, connection pool

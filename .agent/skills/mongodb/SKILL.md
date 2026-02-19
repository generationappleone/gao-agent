---
name: MongoDB
description: Skill for designing and developing MongoDB databases, covering document modeling, aggregation pipelines, indexing strategies, schema validation, transactions, and operational best practices.
---

# MongoDB Skill

## Overview
MongoDB is a document-oriented NoSQL database. Use this skill for applications requiring flexible schemas, embedded documents, horizontal scaling, or real-time analytics.

## Setup & Connection
```bash
# Docker
docker run -d --name mongo -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=secret mongo:7

# Connection string
mongodb://admin:secret@localhost:27017/mydb?authSource=admin&retryWrites=true
```

## Document Design Patterns

### Embed vs. Reference Decision Guide
| Criteria | Embed | Reference |
|----------|-------|-----------|
| Access pattern | Always accessed together | Accessed independently |
| Data growth | Bounded (1:few) | Unbounded (1:many, many:many) |
| Update frequency | Rarely updated | Frequently updated independently |
| Document size | Keeps doc < 16MB | Data would exceed 16MB |
| Consistency | Eventual is OK | Strong consistency needed |

### Schema Validation (MUST use)
```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "firstName", "lastName", "createdAt"],
      properties: {
        _id: { bsonType: "binData" },
        email: { bsonType: "string", pattern: "^.+@.+\\..+$" },
        firstName: { bsonType: "string", maxLength: 100 },
        lastName: { bsonType: "string", maxLength: 100 },
        isActive: { bsonType: "bool" },
        addresses: {
          bsonType: "array",
          maxItems: 10,
          items: {
            bsonType: "object",
            required: ["street", "city", "country"],
            properties: {
              street: { bsonType: "string" },
              city: { bsonType: "string" },
              country: { bsonType: "string", maxLength: 2 }
            }
          }
        },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" },
        deletedAt: { bsonType: ["date", "null"] }
      }
    }
  }
});
```

## Aggregation Pipeline
```javascript
// Monthly revenue with growth calculation
db.orders.aggregate([
  { $match: { status: "completed", deletedAt: null } },
  { $group: {
      _id: { $dateToString: { format: "%Y-%m", date: "$createdAt" } },
      revenue: { $sum: "$totalAmount" },
      count: { $sum: 1 }
  }},
  { $sort: { _id: 1 } },
  { $setWindowFields: {
      sortBy: { _id: 1 },
      output: { prevRevenue: { $shift: { output: "$revenue", by: -1 } } }
  }},
  { $addFields: {
      growthPct: {
        $cond: [
          { $eq: ["$prevRevenue", null] }, null,
          { $round: [{ $multiply: [{ $divide: [{ $subtract: ["$revenue", "$prevRevenue"] }, "$prevRevenue"] }, 100] }, 2] }
        ]
      }
  }}
]);
```

## Indexing Strategy
```javascript
// Single field
db.users.createIndex({ email: 1 }, { unique: true, partialFilterExpression: { deletedAt: null } });

// Compound (follow ESR rule: Equality → Sort → Range)
db.orders.createIndex({ userId: 1, status: 1, createdAt: -1 });

// Text search
db.products.createIndex({ name: "text", description: "text" });

// TTL (auto-expire documents)
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
```

## Transactions (Multi-Document)
```javascript
const session = client.startSession();
try {
  session.startTransaction();
  await orders.insertOne(orderDoc, { session });
  await products.updateOne(
    { _id: productId },
    { $inc: { stockQuantity: -quantity } },
    { session }
  );
  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  throw error;
} finally {
  session.endSession();
}
```

## Rules Integration
- **Database**: UUID for `_id`, schema validation, camelCase fields, audit fields, soft delete
- **Security**: Authentication enabled, SCRAM-SHA-256, field-level encryption, network restrictions

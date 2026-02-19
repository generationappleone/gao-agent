---
name: GraphQL
description: Skill for building GraphQL APIs — covering schema design, queries, mutations, subscriptions, resolvers, Apollo Server/Client, type definitions, pagination, error handling, and security best practices.
---

# GraphQL Skill

## Overview
GraphQL is a query language for APIs and a runtime for executing queries. This skill covers GraphQL specification, Apollo ecosystem, and best practices.

**Reference**: [GraphQL Specification](https://spec.graphql.org/)

## Schema Definition (SDL)
```graphql
# schema.graphql
type Query {
  user(id: ID!): User
  users(page: Int = 1, limit: Int = 20, filter: UserFilter): UserConnection!
  me: User!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
  login(email: String!, password: String!): AuthPayload!
}

type Subscription {
  userCreated: User!
  messageReceived(channelId: ID!): Message!
}

type User {
  id: ID!
  name: String!
  email: String!
  role: Role!
  posts(limit: Int = 10): [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  tags: [String!]!
}

# Enums
enum Role { ADMIN USER MODERATOR }

# Input types
input CreateUserInput {
  name: String!
  email: String!
  password: String!
  role: Role = USER
}

input UpdateUserInput {
  name: String
  email: String
}

input UserFilter {
  role: Role
  search: String
}

# Pagination (Relay-style)
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# Auth
type AuthPayload {
  token: String!
  user: User!
}

# Custom scalars
scalar DateTime
scalar JSON
```

## Apollo Server (Node.js)
```typescript
// server.ts
import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";

const typeDefs = `#graphql
  type Query { users: [User!]! }
  type User { id: ID!, name: String!, email: String! }
`;

const resolvers = {
  Query: {
    users: async (_: unknown, __: unknown, context: Context) => {
      return context.db.user.findMany();
    },
  },
};

const server = new ApolloServer({ typeDefs, resolvers });
const { url } = await startStandaloneServer(server, {
  context: async ({ req }) => ({
    db: prisma,
    user: await getUserFromToken(req.headers.authorization),
  }),
  listen: { port: 4000 },
});
```

## Resolvers
```typescript
const resolvers = {
  Query: {
    user: async (_, { id }, ctx) => ctx.db.user.findUnique({ where: { id } }),
    users: async (_, { page, limit, filter }, ctx) => {
      const where = filter?.role ? { role: filter.role } : {};
      const [items, total] = await Promise.all([
        ctx.db.user.findMany({ where, skip: (page - 1) * limit, take: limit }),
        ctx.db.user.count({ where }),
      ]);
      return { edges: items.map(n => ({ node: n, cursor: n.id })), totalCount: total };
    },
  },
  Mutation: {
    createUser: async (_, { input }, ctx) => {
      if (!ctx.user) throw new GraphQLError("Unauthorized", { extensions: { code: "UNAUTHENTICATED" } });
      return ctx.db.user.create({ data: input });
    },
  },
  // Field resolver
  User: {
    posts: async (parent, { limit }, ctx) => {
      return ctx.db.post.findMany({ where: { authorId: parent.id }, take: limit });
    },
  },
};
```

## Apollo Client (React)
```typescript
// client setup
import { ApolloClient, InMemoryCache, ApolloProvider, gql, useQuery, useMutation } from "@apollo/client";

const client = new ApolloClient({
  uri: "/graphql",
  cache: new InMemoryCache(),
  headers: { authorization: `Bearer ${token}` },
});

// Query hook
const GET_USERS = gql`
  query GetUsers($page: Int, $limit: Int) {
    users(page: $page, limit: $limit) {
      edges { node { id name email } }
      totalCount
    }
  }
`;

function UserList() {
  const { data, loading, error } = useQuery(GET_USERS, { variables: { page: 1, limit: 20 } });
  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;
  return <ul>{data.users.edges.map(({ node }) => <li key={node.id}>{node.name}</li>)}</ul>;
}

// Mutation hook
const CREATE_USER = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) { id name email }
  }
`;

function CreateForm() {
  const [createUser, { loading }] = useMutation(CREATE_USER, {
    refetchQueries: [{ query: GET_USERS }],
  });
  const handleSubmit = (data: CreateUserInput) => createUser({ variables: { input: data } });
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Input types** | Use `input` for mutations, never raw args |
| **Relay pagination** | Use Connection/Edge/PageInfo pattern |
| **N+1 prevention** | Use DataLoader for batching field resolvers |
| **Error handling** | Use `GraphQLError` with `extensions.code` |
| **Auth in context** | Authenticate in context factory, authorize in resolvers |
| **Depth limiting** | Limit query depth to prevent abuse |
| **Complexity analysis** | Assign cost to fields, limit total query cost |
| **Persisted queries** | Use in production to reduce payload size |
| **Schema-first** | Define schema in SDL, generate types |
| **Fragment usage** | Use fragments for reusable field selections |

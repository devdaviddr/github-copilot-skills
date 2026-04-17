# nextjs-app-builder

Security: Generated apps may require environment configuration (.env.local, .env). Do not commit environment files or secrets from generated projects. Add sensitive files like .env.local to the generated project's .gitignore and rotate any leaked credentials.

Scaffolds a complete full-stack Next.js 14 App Router application from scratch — including pages, API routes, an in-memory database, typed entities, reusable components, and styling — all driven by a guided conversational prompt.

---

## Prerequisites

- Node.js 18+
- npm or pnpm

The generated app itself has no external database or auth dependencies; all data lives in memory and resets on server restart.

---

## Invoking the skill

In GitHub Copilot Chat:

```
/nextjs-app-builder
```

Or describe what you want:

```
Build me a Next.js app for managing a product catalogue with a products list page and a product detail page.
```

---

## What the skill prompts you for

| Group | Questions |
|-------|-----------|
| **Project identity** | App name, short description, output directory |
| **Pages & routes** | Route paths, page titles, dynamic segments |
| **Features** | Per-page actions (list, create, delete, filter), shared features (search, toasts, dark mode) |
| **Data entities** | Entity names, fields with types, relationships |
| **UI & styling** | Tailwind vs CSS modules, component library, nav layout, color theme, extra npm packages |

The skill asks one group at a time and confirms a summary before generating anything.

---

## What gets generated

```
<app-slug>/
├── package.json
├── tsconfig.json
├── next.config.ts
├── tailwind.config.ts
├── postcss.config.js
├── .eslintrc.json
├── .gitignore
├── README.md
└── src/
    ├── lib/
    │   ├── db.ts          ← in-memory CRUD store (Map-based, seeded with sample data)
    │   └── utils.ts       ← cn(), formatDate(), etc.
    ├── types/
    │   └── index.ts       ← TypeScript interfaces for every entity
    ├── components/
    │   ├── layout/        ← Navbar / Sidebar / Footer
    │   └── ui/            ← Button, Card, Modal, Toast
    ├── app/
    │   ├── layout.tsx     ← root layout with nav
    │   ├── globals.css
    │   ├── page.tsx       ← home page
    │   ├── <route>/
    │   │   └── page.tsx   ← one folder per additional page
    │   └── api/
    │       └── <entity>/
    │           ├── route.ts        ← GET list, POST create
    │           └── [id]/route.ts   ← GET one, PUT update, DELETE remove
    └── hooks/
        └── use<Entity>.ts ← typed data-fetching hook per entity
```

---

## In-memory database

`src/lib/db.ts` uses a plain `Map<string, Entity>` per entity. Each map is seeded with 2–3 sample records so the UI has data immediately. Because the store lives in the Node.js process, **data resets whenever the dev server restarts**. This is intentional — swap out `db.ts` for a real database adapter when you're ready.

---

## Quick start (after generation)

```bash
cd outputs/nextjs-apps/<app-slug>
npm install
npm run dev
# Open http://localhost:3000
```

---

## Limitations

- No authentication or authorization.
- No persistent storage (data resets on restart).
- No file uploads.
- No real-time updates (no websockets).

These are all intentional — the goal is a clean, runnable starting point with zero infrastructure overhead.

---

## Example invocations

**Minimal:**
```
/nextjs-app-builder
App: task-manager
Pages: /, /tasks, /tasks/[id]
Entities: Task (title: string, done: boolean, priority: low|medium|high)
Styling: Tailwind, top navbar
```

**Conversational:**
```
/nextjs-app-builder
```
*(The skill will ask you each question in turn.)*

---

## Output location

By default, generated apps are written to:

```
outputs/nextjs-apps/<app-slug>/
```

You can specify a custom output directory during the intake phase.

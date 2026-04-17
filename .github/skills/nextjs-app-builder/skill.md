---
name: nextjs-app-builder
description: Scaffolds a full-stack Next.js 14 App Router application from scratch. Prompts the user for app name, pages, features, data entities, and UI style, then generates all source files with an in-memory database and no authentication.
---

When the user invokes this skill, follow the intake and generation flow below exactly.

---

## Phase 1 — Information Gathering

Ask questions **one group at a time**. Do not proceed to the next group until the current one is answered. Mark required fields with *.

### Group 1 — Project Identity
- App name* (used for the folder name and `package.json` name; auto-slug to kebab-case)
- Short description* (one sentence — goes in `package.json` and README)
- Output directory* (default: `outputs/nextjs-apps/<app-slug>/`)

### Group 2 — Pages & Routes
Ask the user to list every page they want. For each page collect:
- Route path* (e.g., `/`, `/dashboard`, `/products`, `/products/[id]`)
- Page title* (human-readable heading shown on the page)
- Purpose / what it displays* (one sentence)
- Any dynamic segment? (yes/no → capture param name if yes, e.g., `id`)

Allow the user to list multiple pages at once (comma- or newline-separated). Re-prompt with "Any more pages? Type `done` when finished." until they say `done`.

### Group 3 — Features & Functionality
For each page identified in Group 2, ask:
- What **actions** can a user take on this page? (e.g., view list, create item, delete item, filter/search)
- Should the page fetch data from an API route, or is it static content?

Then ask globally:
- Are there any **shared features** across pages? (e.g., global search bar, navigation sidebar, toast notifications, modal dialogs, dark mode toggle)

### Group 4 — Data Entities
Ask the user to describe each data entity the app needs. For each entity collect:
- Entity name* (e.g., `Product`, `Task`, `User`)
- Fields* (name, type, required/optional) — accept natural language like "title: string, price: number, inStock: boolean"
- Relationships (e.g., "Task belongs to Project") — skip if none

Allow multiple entities. Re-prompt until the user says `done`.

Auto-add a generated `id` (string UUID) and `createdAt` (ISO timestamp) to every entity unless the user opts out.

### Group 5 — UI & Styling
- Styling approach: Tailwind CSS (default), plain CSS modules, or other
- Component library: none (default), shadcn/ui, or other
- Layout: sidebar nav, top navbar, or minimal (no persistent nav)
- Color theme / brand color (optional — hex or color name; default: slate/blue Tailwind palette)
- Any extra npm packages to include? (e.g., `react-hook-form`, `zod`, `date-fns`)

### Group 6 — Confirmation
Print a structured summary of everything collected:

```
App:         <name> (<slug>)
Output:      <directory>
Pages:       <count> pages
Entities:    <count> entities
Styling:     <choice>
Components:  <choice>
Nav:         <choice>
Packages:    <list>
```

Ask: "Does this look right? Type `yes` to generate, or describe any changes."

If the user requests changes, update the relevant group data and re-display the summary. Repeat until confirmed.

---

## Phase 2 — Code Generation

After confirmation, generate **all files listed below** in the output directory. Write each file completely — no placeholders, no `// TODO` comments, no truncation. Every file must be valid, runnable code.

### File tree to generate

```
<app-slug>/
├── package.json
├── tsconfig.json
├── next.config.ts
├── tailwind.config.ts          (if Tailwind chosen)
├── postcss.config.js           (if Tailwind chosen)
├── .eslintrc.json
├── .gitignore
├── README.md
├── src/
│   ├── lib/
│   │   ├── db.ts               ← in-memory store
│   │   └── utils.ts            ← shared helpers (cn, formatDate, etc.)
│   ├── types/
│   │   └── index.ts            ← TypeScript interfaces for all entities
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Navbar.tsx      (if top navbar chosen)
│   │   │   ├── Sidebar.tsx     (if sidebar chosen)
│   │   │   └── Footer.tsx
│   │   └── ui/
│   │       ├── Button.tsx
│   │       ├── Card.tsx
│   │       ├── Modal.tsx       (if modals needed)
│   │       └── Toast.tsx       (if toasts needed)
│   ├── app/
│   │   ├── layout.tsx          ← root layout with nav + font
│   │   ├── globals.css
│   │   ├── page.tsx            ← home page
│   │   ├── <route>/
│   │   │   └── page.tsx        ← one folder per additional page
│   │   └── api/
│   │       └── <entity>/
│   │           └── route.ts    ← REST handlers per entity
│   └── hooks/
│       └── use<Entity>.ts      ← one custom hook per entity
```

### Generation rules

**`src/lib/db.ts` — in-memory database**
- Export one `Map<string, Entity>` per entity, e.g. `const products = new Map<string, Product>()`.
- Seed each map with 2–3 realistic sample records on module load (so the UI is never empty).
- Export typed CRUD functions for each entity:
  - `getAll<Entity>(): Entity[]`
  - `getById<Entity>(id: string): Entity | undefined`
  - `create<Entity>(data: Omit<Entity, 'id' | 'createdAt'>): Entity` — generates `id` with `crypto.randomUUID()` and `createdAt` with `new Date().toISOString()`
  - `update<Entity>(id: string, data: Partial<Omit<Entity, 'id' | 'createdAt'>>): Entity | undefined`
  - `delete<Entity>(id: string): boolean`
- All data is ephemeral (resets on server restart). Add a comment at the top of the file explaining this.

**`src/app/api/<entity>/route.ts` — API routes**
- Use Next.js 14 Route Handlers (`GET`, `POST` in `route.ts`; `GET`, `PUT`, `DELETE` in `[id]/route.ts`).
- Return `NextResponse.json(...)` with appropriate HTTP status codes.
- Validate required fields on `POST`/`PUT`: return `400` with `{ error: "..." }` if missing.
- Never return stack traces in responses.

**Page components (`src/app/<route>/page.tsx`)**
- Mark client components with `'use client'` only when they use hooks or browser APIs.
- Prefer Server Components for read-only pages (fetch from API route using `fetch`).
- Use the custom hook from `src/hooks/use<Entity>.ts` for client-side data fetching and mutations.
- Each page must include:
  - A clear `<h1>` with the page title
  - Loading state (skeleton or spinner)
  - Empty state message when the list is empty
  - Error state if the fetch fails

**`src/hooks/use<Entity>.ts`**
- Use `useState` + `useEffect` to fetch from the API on mount.
- Export typed helpers: `create`, `update`, `remove`, `refresh`.
- Handle loading, error, and data states.

**Styling**
- If Tailwind: use utility classes directly. Include `tailwind.config.ts` with content paths. Use `cn()` from `src/lib/utils.ts` (clsx + tailwind-merge) for conditional classes.
- If plain CSS modules: generate a `.module.css` file alongside each component.
- Navigation: generate the chosen layout (top navbar or sidebar) and include it in `app/layout.tsx`.

**`package.json`**
- `"next": "14.x"`, `"react": "^18"`, `"react-dom": "^18"`, `"typescript": "^5"`
- Add `tailwindcss`, `postcss`, `autoprefixer` if Tailwind chosen.
- Add any extra packages the user requested.
- Scripts: `dev`, `build`, `start`, `lint`.

**`README.md`**
- App name and description.
- Prerequisites (Node 18+).
- Install and run instructions: `npm install && npm run dev`.
- List of all pages and their routes.
- Note about in-memory database: data resets on server restart.

---

## Phase 3 — Post-generation

After all files are written:

1. Print a file-tree summary showing every file created.
2. Print the quick-start instructions:
   ```
   cd <output-directory>
   npm install
   npm run dev
   # Open http://localhost:3000
   ```
3. Ask: "Would you like me to add anything else — extra pages, a new entity, or any changes to the generated code?"
4. If the user requests additions or changes, apply them immediately to the relevant files only — do not regenerate the entire project.

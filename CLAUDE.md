# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an SAP Cloud Application Programming Model (CAP) project using `@sap/cds`. It uses SQLite for local development and Express as the HTTP server.

## Commands

```bash
npm install          # install dependencies
cds watch            # start dev server with hot reload (preferred for development)
cds serve            # start server with mocks and in-memory DB
npx eslint .         # lint JavaScript/TypeScript files
```

## Project Structure

CAP projects follow a strict convention-based layout:

- `db/` — CDS domain models (`.cds` files) and seed data (`.csv` files)
- `srv/` — CDS service definitions (`.cds`) and service handlers (`.js`/`.ts`)
- `app/` — UI5/Fiori frontend applications

CAP auto-discovers files in these directories — no explicit registration needed.

## CAP Conventions

- **Schema**: define entities in `db/schema.cds`. Entities automatically get CRUD via OData.
- **Services**: expose entities in `srv/*.cds` with `service ... { entity ... as projection on ...}`.
- **Handlers**: implement custom logic in `srv/*.js` by exporting a function receiving `srv` (the service instance).
- **Seed data**: place CSV files named `<namespace>-<EntityName>.csv` in `db/data/` for automatic loading.
- **In-memory SQLite** is used by default during `cds watch`; a persistent `.db` file is used with `cds serve`.

## ESLint

Config extends `@sap/cds` recommended rules via `eslint.config.mjs`. Supports JS, TS, and CSV file types (validators are commented out in `.vscode/settings.json` until `npm install` is run).

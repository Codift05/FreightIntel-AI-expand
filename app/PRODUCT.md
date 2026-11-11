# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Primary users for this flow are Finance Managers and finance staff recording revenue and costs against freight shipments. Owners and directors review company financial performance. Operations staff manage shipments.

## Product Purpose

FreightIntel AI helps Indonesian freight-forwarding companies manage shipments and related financial transactions, understand shipment profit, and review financial performance.

## Positioning

Revenue and costs link to shipments so profit and margin can be understood per shipment and across the company.

## Operating Context

Finance staff record customer revenue and vendor costs, including invoice details, tax, and shipment associations. The product is planned for a single-company pilot before broader multi-company use.

## Capabilities and Constraints

- The product targets Android and iOS from one Flutter codebase. This design pass uses the running Android emulator as its review baseline.
- The current Flutter app is a frontend prototype. It uses demo data and has no backend connection.
- Current flows include demo login, dashboard, shipment list/detail/create, finance overview, and an insight placeholder.
- The PRD defines later phases for payments, reports, notifications, company/RBAC, analytics, and AI features. Follow `../docs/PRD.md` §13 for ordering.
- Financial calculations use pre-tax DPP. Gross profit is revenue minus cost. Money must use decimal semantics, not floating point, when implemented with persistent data.
- Payment status derives from accumulated payments. A shipment with transactions must be archived or voided, not permanently deleted.
- Company data must remain isolated by `company_id` when the backend is built.
- All demo figures and records must be identified honestly as examples, not presented as live company data.

## Brand Commitments

- Product name: FreightIntel AI.
- User-facing copy is in Bahasa Indonesia.
- Existing brand assets and app identity are in `../docs/` and `assets/`.

## Evidence on Hand

- Product requirements: `../docs/PRD.md`.
- Current frontend scope and roadmap: `../docs/FRONTEND.md`.
- Current app behavior and demo data: `lib/`.
- The repository contains no real company transaction data. Do not invent customer evidence or financial claims.

## Product Principles

- Financial values and profit calculations must be accurate and auditable.
- Shipment, customer, vendor, and financial records must remain linked.
- Tenant isolation is a backend requirement, including for analytics.
- Show the limits of demo data clearly.

## Accessibility & Inclusion

- Use Material 3 and respect Android system insets and back navigation.
- Keep controls touch-accessible and screens usable with larger system font sizes.
- Data screens need loading, populated, empty, and error-with-retry states as specified in the PRD.

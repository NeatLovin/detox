# Detox — règles projet

App Flutter gamifiée anti-addictions pour une escouade privée de potes. Android d'abord, iOS via Codemagic.

## Stack
Flutter / Dart 3 · Riverpod (codegen) · go_router · freezed · Supabase (Auth OTP, Postgres, RLS, Realtime, pg_cron)

## Architecture
- lib/features/<feature>/{domain,data,presentation}
- Les écrans passent par des repositories exposés en providers. Jamais d'appel Supabase direct dans un widget.
- Logique métier = fonctions pures dans domain/, toujours testées.

## Règles non négociables
- XP / HP / niveau / feed : écrits UNIQUEMENT par des fonctions et triggers SQL. Jamais par le client.
- RLS sur chaque table. addictions et relapses visibles par le propriétaire seul.
- Addiction privée : son label ne sort jamais vers l'escouade.
- Aucune clé service_role / secret dans l'app ou le repo. env.json est gitignoré.
- Schéma modifié uniquement via une nouvelle migration dans supabase/migrations/. Jamais d'édition d'une migration déjà poussée.
- Pas de `supabase db push` distant sans accord explicite.

## Conventions
- UI en français (ARB app_fr.arb), code et commentaires en anglais.
- Conventional Commits.
- Ton de l'app : motivant, jamais culpabilisant. Une rechute ne retire jamais d'XP.

## Commandes
- Codegen : dart run build_runner build -d
- Qualité : flutter analyze && flutter test
- Run : flutter run --dart-define-from-file=env.json
- DB locale : supabase start / supabase db reset

# detox
Gamified Flutter app to quit addictions and build healthy habits with your squad.

> **Detox** — arrête avec ton escouade. Level up chaque jour.

Une app mobile entre potes (2 à 10) pour décrocher du porno, du snus, de la clope, de la beuh, du sucre, de l'alcool… Chaque jour clean rapporte de l'XP, les paliers donnent des bonus, l'escouade se tire vers le haut avec un classement hebdo et un feed en temps réel. Une rechute coûte des HP, **jamais** d'XP ni de niveau : on repart.

## Captures

| Accueil | Escouade | Rechute |
|---|---|---|
| _(capture à venir)_ | _(capture à venir)_ | _(capture à venir)_ |

## Fonctionnalités V0

- Connexion par email + code OTP à 6 chiffres
- Onboarding : pseudo, avatar emoji, addictions suivies (catalogue + custom, option « privée »)
- Escouade privée : créer, rejoindre par code, partager le code
- Accueil : carte joueur (niveau, XP animée, HP, état KO), timer live par addiction, CHF économisés, unités évitées, record, prochain palier
- Rechute en 2 taps, note optionnelle, partage optionnel (le nom d'une addiction privée ne sort jamais)
- Escouade : podium et classement XP de la semaine, feed temps réel, réglages
- Profil : pseudo/emoji, ajouter / modifier / archiver ses addictions, déconnexion

Toute la gamification (XP, HP, niveaux, paliers, feed) est calculée **côté serveur** par des fonctions et triggers Postgres.

## Stack

Flutter (Android + iOS) · Dart 3 · Riverpod (codegen) · go_router · freezed / json_serializable · Supabase (Auth OTP, Postgres + RLS, Realtime, pg_cron) · flutter_animate · Material 3 (thème sombre)

## Structure

```
lib/
├── main.dart, app.dart
├── core/           env, client Supabase, router, thème, l10n, session, utils
├── features/
│   ├── auth/         domain · data · presentation
│   ├── onboarding/
│   ├── squad/
│   ├── addictions/
│   ├── gamification/
│   └── profile/
└── shared/         widgets communs (XpBar, HpBar, StatTile, EmptyState…)

supabase/
├── migrations/     schéma, fonctions de gamification, RLS / grants / realtime / cron
├── seed.sql        3 users fictifs pour le dev local
└── templates/      email OTP
```

Règles du projet : voir [`CLAUDE.md`](CLAUDE.md). Mise en route (Supabase, Android, iOS) : voir [`SETUP.md`](SETUP.md).

## Commandes

```bash
flutter pub get
dart run build_runner build -d          # codegen (freezed, riverpod, json)
flutter analyze && dart analyze         # dart analyze exécute riverpod_lint
flutter test
flutter run --dart-define-from-file=env.json

supabase start && supabase db reset     # DB locale + seed (Docker requis)
tool/sql_tests/run.sh                   # tests SQL anti-triche (Postgres local, vars PG*)
```

## Roadmap

- **V1 — Tenir le coup** : bouton SOS (respiration, message à l'escouade), journal de cravings, notifications push.
- **V2 — Hygiène de vie** : quêtes quotidiennes (eau, sport, sommeil), Health Connect / HealthKit, badges.
- **V3 — Mode coop et garde-fous** : boss raid d'escouade, challenges entre potes, blocage d'apps, avatar animé, offline-first.

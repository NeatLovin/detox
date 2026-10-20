# detox
Gamified Flutter app to quit addictions and build healthy habits — with a public leaderboard.

> **Detox** — arrête avec tes potes. Level up chaque jour.

Une app mobile pour décrocher du porno, du snus, de la clope, de la beuh, du sucre, de l'alcool… et tenir un bon rythme de vie. Chaque jour clean, chaque envie résistée, chaque quête bouclée rapporte de l'XP. Tout le monde voit le classement général et les profils publics des autres. Une rechute coûte des HP, **jamais** d'XP ni de niveau : on repart.

## Captures

| Accueil | Classement | SOS |
|---|---|---|
| _(capture à venir)_ | _(capture à venir)_ | _(capture à venir)_ |

## Fonctionnalités

- Connexion par email + code OTP à 6 chiffres
- Onboarding : pseudo, avatar emoji, addictions suivies (catalogue + custom, option « privée »)
- Accueil : carte joueur (niveau, XP, HP), engagement du matin, timer live par addiction, CHF économisés, record, prochain palier, bouton **SOS**, « Noter une envie »
- **SOS** : compte à rebours de 5 min, respiration guidée, raisons perso, ancrage 5-4-3-2-1, soutiens reçus en direct
- **Journal des envies** : intensité, déclencheur, part des envies résistées, déclencheur n°1
- **Quêtes du jour** : eau, sport, sommeil, pas, méditation, lecture, sans écran, perso ; séries 🔥 et bonus « journée bouclée »
- **Classement général** (XP total) et **feed global** temps réel ; profils publics : niveau, XP, HP, badges, addictions non privées
- **Profil privé** : reste dans le classement (pseudo, niveau, XP), mais profil, feed et SOS invisibles pour les autres
- **13 badges**, rechute en 2 taps (le nom d'une addiction privée ne sort jamais)

Toute la gamification (XP, HP, niveaux, paliers, badges, feed) est calculée **côté serveur** par des fonctions et triggers Postgres, avec des plafonds journaliers anti-farming.

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
│   ├── community/    classement, feed, profils joueurs
│   ├── cravings/
│   ├── quests/
│   ├── sos/
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

- **V1 — Tenir le coup** ✅ : SOS, journal des envies, quêtes du jour, engagement du matin, badges, classement général.
- **V2 — Hygiène de vie** : notifications push (SOS, rappels), Health Connect / HealthKit pour remplir les quêtes automatiquement, heatmap des envies.
- **V3 — Défis et garde-fous** : challenges entre joueurs, blocage d'apps, avatar animé, offline-first.

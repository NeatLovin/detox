# SETUP — ce que tu dois faire à la main

Tout le reste (code, migrations, tests) est déjà dans le repo. Ces étapes demandent ton compte ou ta machine.

> Ordre conseillé : **active pg_cron (étape 3) avant de pousser le schéma (étape 4)**, comme ça la migration programme directement le job horaire.

---

## 1. Créer le projet Supabase

1. Va sur <https://supabase.com/dashboard> → **New project**.
2. Nom : `detox`. Région : **Central EU (Frankfurt)**. Choisis un mot de passe DB solide et garde-le (il sera demandé par `supabase link`).
3. Une fois le projet prêt, ouvre **Project Settings → API Keys** et note :
   - l'**URL** du projet (`https://<ref>.supabase.co`) ;
   - la clé **publishable** (`sb_publishable_…`) ou la clé **anon** legacy.
   - ⚠️ Ne copie **jamais** la clé `service_role` / `secret` dans l'app ou le repo.
4. Note aussi le **project ref** (la partie `<ref>` de l'URL).

## 2. Activer l'auth email par code OTP

1. **Authentication → Sign In / Providers → Email** : le provider Email doit être activé.
   - **Email OTP Length** : `6`.
   - Laisse « Confirm email » activé, ça fonctionne avec le code.
2. **Authentication → Emails → Templates** : modifie **Magic Link** *et* **Confirm signup** pour afficher le code au lieu du lien. Exemple de corps :

   ```html
   <h2>Ton code Detox</h2>
   <p>Entre ce code dans l'app :</p>
   <p style="font-size:32px;font-weight:bold;letter-spacing:6px">{{ .Token }}</p>
   ```

   Sujet : `Ton code Detox`. (Même contenu que `supabase/templates/otp.html`.)
3. **Fortement conseillé** : l'envoi d'emails par défaut de Supabase est limité à quelques emails par heure, c'est trop juste pour 8 personnes. Configure un SMTP gratuit (Resend, Brevo…) dans **Authentication → Emails → SMTP Settings**.

## 3. Activer l'extension pg_cron

**Database → Extensions** → cherche `pg_cron` → **Enable**.

C'est elle qui attribue l'XP des jours clean toutes les heures (`private.award_clean_days()`).

> Si tu as déjà poussé le schéma (étape 4) avant d'activer pg_cron, ouvre le **SQL Editor** et lance une fois :
>
> ```sql
> select cron.schedule('award-clean-days', '5 * * * *', 'select private.award_clean_days()');
> ```

## 4. Pousser le schéma avec la CLI Supabase

```bash
npm install -g supabase        # ou : brew install supabase/tap/supabase
supabase login                 # ouvre le navigateur
supabase link --project-ref <ref>
supabase db push               # applique supabase/migrations/*.sql
```

- `db push` n'applique **pas** `seed.sql` (les faux users restent en local).
- Vérifie dans **Database → Cron Jobs** (ou `select * from cron.job;`) que `award-clean-days` existe.

## 5. Remplir `env.json`

À la racine du repo :

```bash
cp env.example.json env.json
```

puis remplace les valeurs :

```json
{
  "SUPABASE_URL": "https://<ref>.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_…"
}
```

`env.json` est dans `.gitignore`, il ne sera jamais commité.

## 6. Lancer sur Android

1. Installe Flutter (stable) et Android Studio (pour le SDK Android) : <https://docs.flutter.dev/get-started/install>. Vérifie avec `flutter doctor`.
2. Sur ton téléphone : active le **mode développeur** et le **débogage USB**, branche-le.
3. Dans le repo :

   ```bash
   flutter pub get
   flutter run --dart-define-from-file=env.json
   ```

4. Pour envoyer l'app aux potes Android :

   ```bash
   flutter build apk --release --dart-define-from-file=env.json
   ```

   Le fichier est dans `build/app/outputs/flutter-apk/app-release.apk`. Envoie-le, ils l'installent en autorisant les « sources inconnues ». (Il est signé avec la clé debug, ce qui suffit hors Play Store.)

## 7. Builder l'iOS sans Mac (Codemagic)

1. Il faut un **Apple Developer Program** (99 $/an) pour installer l'app sur un iPhone via TestFlight.
2. Crée un compte sur <https://codemagic.io> et connecte le repo GitHub `NeatLovin/detox`.
3. Dans **Teams → Integrations → Developer Portal**, ajoute une clé **App Store Connect API** (générée dans App Store Connect → Users and Access → Integrations).
4. Crée l'app dans App Store Connect avec le bundle id `ch.neatlovin.detox`.
5. Dans le workflow Flutter de Codemagic :
   - plateforme **iOS**, mode **Release**, signature **automatique** ;
   - ajoute une variable d'environnement secrète `ENV_JSON` contenant le contenu de ton `env.json`, et un script *pre-build* : `echo "$ENV_JSON" > env.json` ;
   - arguments de build : `--dart-define-from-file=env.json` ;
   - publication : **App Store Connect → TestFlight**.
6. Lance le build. Ton pote iOS reçoit l'invitation TestFlight par email.

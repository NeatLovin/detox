# SETUP — ce que tu dois faire à la main

Tout le reste (code, migrations, tests) est déjà dans le repo. Ces étapes demandent ton compte ou ta machine.

> Ordre conseillé : **active pg_cron (étape 3) avant de pousser le schéma (étape 4)**, comme ça la migration programme directement le job horaire.

---

## 0. Parcours sans PC (tout depuis le navigateur)

Deux workflows GitHub Actions remplacent les étapes 4 à 6 :

| Workflow | Déclenchement | Ce qu'il fait |
|---|---|---|
| `Android APK` | chaque push sur `main`, ou à la main | lance les tests, build un APK release signé, le publie dans **Releases** |
| `Supabase db push` | à la main uniquement | `dry-run` liste les migrations en attente, `apply` les pousse |

**Secrets à créer** dans GitHub → *Settings → Secrets and variables → Actions → New repository secret* :

| Secret | Où le trouver |
|---|---|
| `SUPABASE_URL` | étape 1.3 |
| `SUPABASE_ANON_KEY` | étape 1.3 (clé publishable ou anon) |
| `SUPABASE_PROJECT_REF` | étape 1.4 |
| `SUPABASE_DB_PASSWORD` | mot de passe DB choisi à l'étape 1.2 |
| `SUPABASE_ACCESS_TOKEN` | supabase.com → avatar → **Account → Access Tokens** → *Generate new token* |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | fichier de signature fourni à part (jamais dans le repo) |

**Ordre :**
1. Étapes 1, 2 et 3 ci-dessous dans le dashboard Supabase.
2. Crée les 9 secrets.
3. *Actions → Supabase db push → Run workflow* avec `dry-run`, vérifie la liste, puis relance avec `apply`.
4. *Actions → Android APK → Run workflow* (ou push sur `main`).
5. Sur le téléphone, connecté à GitHub : **github.com/NeatLovin/detox/releases** → dernière release → télécharge `detox-build-N.apk` → ouvre-le → autorise « Installer des applis inconnues » pour le navigateur.

> Le repo étant privé, chaque pote doit soit avoir accès au repo, soit recevoir l'APK de ta part (WhatsApp, Drive…). Toutes les versions sont signées avec la même clé : une mise à jour s'installe par-dessus l'ancienne.

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

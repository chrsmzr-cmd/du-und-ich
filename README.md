# Chris & Juana – Karte

Eure gemeinsame Karte: Standorte, Entfernung und Countdown bis zum nächsten Wiedersehen.
Der Standort kommt per GPS, beim Öffnen der Seite und zusätzlich automatisch über einen iPhone-Kurzbefehl.

Dateien:

- `index.html` – die App
- `config.js` – deine Supabase-Adresse und dein Key (Schritt 2)
- `icon.png` – Symbol für den Home-Bildschirm
- `supabase.sql` – richtet die Datenbank ein

Einrichtung dauert etwa 20 Minuten und muss nur einmal gemacht werden.

---

## 1. Datenbank bei Supabase anlegen

1. Auf [supabase.com](https://supabase.com) kostenlos registrieren und ein neues Projekt anlegen (Region: Frankfurt).
2. Links **SQL Editor** öffnen, den kompletten Inhalt von `supabase.sql` einfügen und auf **Run** tippen.
3. Unten erscheint eine Tabelle mit zwei Zeilen: `chris` und `juana`, jeweils mit einem **Code**.
   Diese Codes sind eure Schlüssel. Kopiert sie euch sicher weg und teilt sie mit niemandem sonst.
4. Unter **Project Settings → API** findest du:
   - die **Project URL** (`https://xxxx.supabase.co`)
   - den **anon key** bzw. **publishable key**

## 2. Zugangsdaten eintragen

> **Bei euch schon erledigt.** `config.js` enthält bereits eure Project URL und euren Key. Den Rest dieses Abschnitts brauchst du nur, falls du die Werte später ändern willst.

Die App muss wissen, wo eure Datenbank liegt. Dafür gibt es die kleine Datei `config.js`. Sie sieht so aus:

```js
window.CJ_CONFIG = {
  url: 'https://DEIN-PROJEKT.supabase.co',
  key: 'DEIN-KEY'
};
```

Dort ersetzt du die zwei Platzhalter durch deine Werte aus Schritt 1.4. Du hast zwei Möglichkeiten:

**Einfachste Variante: Claude macht es.** Schick mir im Chat die **Project URL** und den **Key**. Ich trage beides ein und schicke dir die fertigen Dateien zurück. Das ist unbedenklich, denn dieser Key ist für die Öffentlichkeit gedacht. Die Codes aus der Ergebnistabelle schickst du mir **nicht**.

**Selbst machen, direkt auf GitHub** (nach Schritt 3, ohne Programme auf dem Computer):

1. In deinem Repository auf GitHub die Datei `config.js` antippen.
2. Oben rechts auf den **Stift** tippen (*Edit this file*).
3. `https://DEIN-PROJEKT.supabase.co` markieren und deine Project URL einfügen.
4. `DEIN-KEY` markieren und deinen Key einfügen.
5. Die Anführungszeichen `'…'` drumherum müssen stehen bleiben. So sieht es danach etwa aus:
   ```js
   window.CJ_CONFIG = {
     url: 'https://abcdefghijkl.supabase.co',
     key: 'sb_publishable_AbC123…'
   };
   ```
6. Oben rechts auf **Commit changes** und im Fenster nochmal auf **Commit changes** tippen.

Nach etwa einer Minute ist die Änderung online. Wenn die App noch „Noch nicht eingerichtet“ zeigt, einmal neu laden.

Der Key darf öffentlich sein. Ohne einen eurer persönlichen Codes kommt niemand an eure Daten.

## 3. Online stellen mit GitHub Pages

1. Auf GitHub ein neues Repository anlegen, z. B. `wir-zwei`.
2. Die Dateien `index.html`, `config.js`, `icon.png` und `supabase.sql` hochladen (**Add file → Upload files**).
3. **Settings → Pages → Branch: main / root → Save**.
4. Nach ein bis zwei Minuten läuft die Seite unter `https://DEIN-NAME.github.io/wir-zwei/`.

## 4. Aufs Handy holen

Jeder von euch macht das auf dem eigenen iPhone:

1. Die Seite in **Safari** öffnen.
2. **Teilen → Zum Home-Bildschirm**.
3. Die App vom Home-Bildschirm aus öffnen, den eigenen Code eingeben, **Verbinden**.
4. Bei der Frage nach dem Standort **Erlauben** wählen.

Wichtig: Die App auf dem Home-Bildschirm hat einen eigenen Speicher. Den Code also dort eingeben, nicht nur in Safari.

Ab jetzt wird dein Standort jedes Mal gesendet, wenn du die App öffnest (höchstens alle 10 Minuten). Mit dem Pfeil oben rechts schickst du ihn sofort.

## 5. Automatisch im Hintergrund: Kurzbefehl

Damit der Pin auch stimmt, wenn ihr die App länger nicht öffnet.

### Kurzbefehl bauen

In der App **Kurzbefehle** → **+** → Name: *Standort an die Karte*

1. Aktion **Aktuellen Standort abrufen** hinzufügen.
2. Aktion **Inhalte von URL abrufen** hinzufügen:
   - **URL:** `https://rytsjrhfqqbwkcojbpgt.supabase.co/rest/v1/rpc/cj_update_location`
   - Auf den Pfeil tippen und einstellen:
     - **Methode:** POST
     - **Header:**
       - `apikey` = `sb_publishable_sDTrZxNi6uHdkvGYzYMhig_jcxexR6W`
       - `Content-Type` = `application/json`
     - **Hauptteil anfordern:** JSON, mit diesen Feldern (alle vom Typ **Text**):

       | Schlüssel | Wert |
       |---|---|
       | `p_token` | dein Code |
       | `p_lat` | Aktueller Standort → **Breitengrad** |
       | `p_lng` | Aktueller Standort → **Längengrad** |
       | `p_place` | Aktueller Standort → **Stadt** |

     Die Werte für Breitengrad, Längengrad und Stadt wählst du, indem du auf das Feld tippst, die Variable *Aktueller Standort* auswählst und dann auf sie tippst, um die Eigenschaft zu wählen.
3. Einmal mit ▶︎ testen. Als Antwort kommt Text mit `"me"`, und auf der Karte springt dein Pin.

### Automation einrichten

**Kurzbefehle → Automation → Neue Automation**, dann zum Beispiel:

- **Tageszeit:** täglich 8:00 und 19:00 (zwei Automationen)
- oder **Verlassen** / **Ankommen** bei deiner Wohnung
- oder **App:** beim Öffnen von WhatsApp

Jeweils **Sofort ausführen** wählen und **Bei Ausführung benachrichtigen** ausschalten. Als Aktion den Kurzbefehl *Standort an die Karte* auswählen.

---

## Gut zu wissen

- **Genauigkeit:** Standorte werden auf etwa 1 km gerundet gespeichert.
- **Zeitzonen:** Das Wiedersehen wird als fester Zeitpunkt gespeichert. Jeder sieht es in seiner eigenen Ortszeit.
- **Supabase-Pause:** Kostenlose Projekte pausieren nach 7 Tagen ohne Nutzung. Die Kurzbefehl-Automation hält das Projekt wach. Falls es doch pausiert, im Supabase-Dashboard auf **Restore** tippen.
- **Code verloren?** Im SQL Editor `select who, token from cj_people;` ausführen.
- **Neuen Code erzeugen** (z. B. wenn einer bekannt geworden ist): `update cj_people set token = gen_random_uuid() where who = 'chris';` und danach den neuen Code in App und Kurzbefehl eintragen.
- **Ohne GPS:** Über die Suche oder die Nadel (Stecknadel-Symbol) könnt ihr den Standort auch von Hand setzen.

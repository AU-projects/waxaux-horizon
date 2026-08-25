# CLAUDE.md — WaxAux (tema Shopify Horizon)

Questo file dà a Claude Code il contesto per lavorare su questo repo: un fork del tema Shopify **Horizon**, collegato via GitHub a un tema in bozza sullo store Shopify di WaxAux. Il repo è la base di sviluppo — ogni push aggiorna la bozza, non lo store live.

## Contesto del progetto

- Store: **WaxAux** — accessori per dischi in vinile (buste, pulizia, hardware per giradischi, slipmat)
- Tono/stile: cool, underground, tecnico — evitare linguaggio promozionale/da vetrina generica
- Tema base: Horizon (fork), in fase di restyling verso l'identità WaxAux
- Il tema collegato via GitHub è in **bozza**: ogni push sincronizza automaticamente. La pubblicazione è un'azione manuale separata nell'admin Shopify.
- Sviluppo su computer non permanente: aspettarsi setup ripetuto di `git clone` a inizio sessione.

## Design system WaxAux

Fonte: design handoff su Claude Design (`design_handoff_waxaux_storefront/`), wireframes "turn 2" (approvate, direzione "louder").

- **Mint** `#6FDDA0` — superficie piena, non un accento: hero, header banner, section band, price tag
- **Nero** `#111` — testo, regoli 2px, CTA invertite
- **Crema** `#f0eee9`, grigi caldi `#e4e2dc` / `#6f6e69` / `#8a8a85`
- **Type** — Jost (geometrico, richiama il wordmark) per tutto il display; JetBrains Mono (o alternativa mono più vicina disponibile nel font picker Shopify: Space Mono / IBM Plex Mono) per le etichette maiuscole piccole e i numerali
- **Motivi ripresi dal logo** — CTA e numerali con angoli pill/arrotondati, divisori a barre "waveform" (vedi `sections/waveform-divider.liquid`), tile immagine con "U-stroke" arrotondato sul fondo
- **Regole** — bordi sezione 2px solid `#111`; niente ombre morbide, niente gradienti
- I conteggi articoli sono stati rimossi deliberatamente dal design (es. "Shop the shelf") — non serve un conteggio dinamico lì

## Struttura del tema (standard Shopify OS 2.0)

```
layout/       # theme.liquid e varianti — wrapper globale di ogni pagina
templates/    # JSON che compongono le pagine (index, product, collection, ecc.)
sections/     # blocchi Liquid riutilizzabili e configurabili nell'editor tema
snippets/     # frammenti Liquid inclusi da sections/templates, non editabili da editor
assets/       # CSS, JS, immagini, font
config/       # settings_schema.json (opzioni personalizzatore tema) e settings_data.json
locales/      # stringhe di traduzione (en.default.json, it.json, ecc.)
```

## Mappa schermate → file repo

| Schermata (design) | File repo |
| --- | --- |
| Home | `templates/index.json`, `sections/hero.liquid`/`sections/section.liquid`, `sections/shop-the-shelf.liquid`, `sections/stat-badge.liquid`, `sections/waveform-divider.liquid` |
| Collection | `templates/collection.json`, `assets/facets.js`, `assets/waxaux-theme.css` |
| Product | `templates/product.json`, `assets/component-quantity-selector.js`, `assets/waxaux-theme.css` |
| Header / footer | `sections/header-group.json`, `sections/footer-group.json`, `assets/header.js`, `assets/header-menu.js` |
| Token di brand (mint, Jost) | `config/settings_schema.json` (custom properties), `assets/waxaux-theme.css` |

## Convenzioni Liquid da rispettare

- **Non modificare la logica core di Horizon** (cart, checkout redirect, gestione varianti) senza necessità reale — è testata e ottimizzata; preferire override via sezioni/snippet nuovi piuttosto che riscrivere l'esistente.
- Nuove sezioni: creare file dedicati in `sections/`, con `{% schema %}` completo (settings, blocks, presets) per essere editabili dall'editor tema.
- Usare sempre gli helper Liquid nativi per prezzi/valute (`money` filter), non hardcodare formattazioni.
- Immagini: usare sempre `image_tag` o `image_url` con `srcset` responsive, mai `<img src="...">` diretto — per performance e compatibilità CDN Shopify.
- CSS: preferire i design token esposti come custom properties (via `config/settings_schema.json` → CSS vars) invece di hardcodare hex nei CSS delle sezioni, così restano coerenti col personalizzatore tema.
- JS: Horizon usa web components nativi (custom elements) per l'interattività — seguire questo pattern invece di introdurre jQuery o framework esterni.
- Non toccare `config/settings_data.json` a mano: è lo stato salvato dall'editor tema (font, colori, logo scelti dal merchant), va lasciato gestire da Shopify. Questo vale anche per i push via `shopify theme push`: **escludere sempre `config/settings_data.json`** con `--ignore="config/settings_data.json"`, altrimenti un push sovrascrive silenziosamente le impostazioni salvate dall'editor.

## ⚠️ Non sovrascrivere le modifiche fatte nel theme editor

Il merchant può modificare **qualsiasi** file tema dall'editor Shopify online (non solo font/colori in `settings_data.json` — anche testi, layout e impostazioni dentro `templates/*.json` quando trascina/modifica blocchi). Queste modifiche vengono sincronizzate verso GitHub automaticamente (commit `"Update from Shopify for theme..."`), ma **solo dopo** che Shopify le processa — se nel frattempo pushi da un checkout locale non aggiornato, il push sovrascrive silenziosamente quel lavoro, senza errori, senza conflitti visibili.

Regola pratica: **fare sempre `git pull origin main` prima di iniziare a modificare file del tema**, e di nuovo **subito prima di ogni `shopify theme push`**. Usare `scripts/safe-theme-push.sh <store> <theme-id>` invece di chiamare `shopify theme push` a mano — fa pull-prima, push con l'`--ignore` corretto, e pull-dopo per assorbire il commit di sync automaticamente, nell'ordine giusto.

## Workflow git

- Branch `main` collegato al tema in bozza su Shopify — ogni push sincronizza automaticamente in entrambe le direzioni (Shopify ripubblica su GitHub commit "Update from Shopify for theme..." dopo ogni sync riuscita). Prima di pushare, fare `git pull` per integrare questi commit.
- La validazione server-side di Shopify è più severa di `shopify theme check` (es. su default fuori range, valori vuoti in campi url/color): un push può fallire in modo silenzioso o con errori solo lato Shopify. Dopo un push importante, verificare visivamente sul draft (`shopify theme push` stampa l'URL di preview).
- Commit piccoli e descrittivi: la cronologia serve anche da diff visivo rispetto a Horizon originale.
- Prima di modifiche strutturali importanti, considerare un branch separato non collegato, per testare senza sporcare la bozza sincronizzata.

## Comandi utili

```bash
shopify theme dev                                          # anteprima live con hot-reload
scripts/safe-theme-push.sh <store> <theme-id>               # modo sicuro per pushare: pull → check → push (con --ignore settings_data.json) → pull → git push
shopify theme check                                         # linter Liquid ufficiale — eseguire prima di ogni push importante
```

## Cosa NON fare

- Non modificare direttamente file nel tema pubblicato/live dall'editor Shopify online — tutte le modifiche strutturali passano da qui (repo → bozza → pubblicazione).
- Non introdurre dipendenze esterne pesanti (framework JS, librerie CSS) senza necessità — Horizon è già ottimizzato per performance.
- Non rimuovere `{% schema %}` o setting esistenti usati da altre sezioni senza verificare le dipendenze.
- Non usare sezioni Horizon che richiedono media obbligatorio (es. `hero`, blocco `image`) quando serve uno sfondo colore pieno senza immagine: mostrano sempre un'illustrazione placeholder anche fuori dall'editor. Usare `sections/section.liquid` (generica, senza media obbligatorio) in quei casi.

# CLAUDE.md — Urban Jungle Store (tema Shopify Horizon)

Questo file dà a Claude Code il contesto per lavorare su questo repo: un fork del tema Shopify **Horizon**, collegato via GitHub a un tema in bozza sullo store Shopify (Urban Jungle Store). Il tema live attuale è l'Horizon nativo, non ancora modificato — questo repo è la base di sviluppo per personalizzarlo.

## Contesto del progetto

- Store: Urban Jungle Store — e-commerce sneaker, apparel e accessori
- Tono/stile desiderato: cool, underground — evitare linguaggio promozionale/da vetrina generica
- Tema base: Horizon (fork pulito, nessuna modifica applicata ancora)
- Il tema collegato via GitHub è in **bozza**: ogni push aggiorna la bozza, non lo store live. La pubblicazione è un'azione manuale separata nell'admin Shopify.
- Sviluppo attualmente su computer non permanente: aspettarsi setup ripetuto di `git clone` a inizio sessione.

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

## Convenzioni Liquid da rispettare

- **Non modificare la logica core di Horizon** (cart, checkout redirect, gestione varianti) senza necessità reale — è testata e ottimizzata; preferire override via sezioni/snippet nuovi piuttosto che riscrivere l'esistente.
- Nuove sezioni: creare file dedicati in `sections/`, con `{% schema %}` completo (settings, blocks, presets) per essere editabili dall'editor tema.
- Usare sempre gli helper Liquid nativi per prezzi/valute (`money` filter), non hardcodare formattazioni.
- Immagini: usare sempre `image_tag` o `image_url` con `srcset` responsive, mai `<img src="...">` diretto — per performance e compatibilità CDN Shopify.
- CSS: seguire il sistema di custom properties già presente in Horizon (variabili `--color-*`, `--font-*` in `assets/base.css` o simili) invece di introdurre valori hardcoded, per restare coerenti col personalizzatore tema.
- JS: Horizon usa web components nativi (custom elements) per l'interattività — seguire questo pattern invece di introdurre jQuery o framework esterni.
- Non toccare `config/settings_data.json` a mano: è lo stato salvato dall'editor tema, va lasciato gestire da Shopify.

## Workflow git

- Branch `main` collegato al tema in bozza su Shopify — ogni push sincronizza automaticamente.
- Commit piccoli e descrittivi: la cronologia serve anche da diff visivo rispetto a Horizon originale.
- Prima di modifiche strutturali importanti, considerare un branch separato non collegato, per testare senza sporcare la bozza sincronizzata.

## Comandi utili

```bash
shopify theme dev          # anteprima live con hot-reload, punta allo store collegato
shopify theme pull         # sincronizza lo stato attuale del tema live (usare con cautela una volta iniziate le modifiche)
shopify theme check        # linter Liquid ufficiale — eseguire prima di ogni push importante
```

## Cosa NON fare

- Non modificare direttamente file nel tema pubblicato/live dall'editor Shopify online — tutte le modifiche strutturali passano da qui (repo → bozza → pubblicazione).
- Non introdurre dipendenze esterne pesanti (framework JS, librerie CSS) senza necessità — Horizon è già ottimizzato per performance.
- Non rimuovere `{% schema %}` o setting esistenti usati da altre sezioni senza verificare le dipendenze.

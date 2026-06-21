# dunnwithlovequilting.com

Static website for **Dunn With Love Quilting** — free-motion longarm quilting in Des Moines, WA.

Built with [Hugo](https://gohugo.io) and deployed to GitHub Pages on the custom domain `dunnwithlovequilting.com`.

---

## Local development

The repo ships with a `site.sh` wrapper that covers the everyday commands:

```bash
./site.sh dev          # live-reload dev server at http://localhost:1313
./site.sh build        # production build to ./public
./site.sh preview      # build, then serve ./public on http://localhost:1314
./site.sh check        # clean build with warnings — run before pushing
./site.sh clean        # remove build artifacts
./site.sh invoice      # open the printable invoice template in your browser
./site.sh help         # full command list
```

Underneath, it's just Hugo — `hugo server` and `hugo --minify --gc` work fine too.

### Requirements

- Hugo **extended** ≥ 0.142 (`brew install hugo`)
- That's it — no Node, no Tailwind toolchain, no database.

---

## Project layout

```
.
├── .github/workflows/deploy.yml   # Build + deploy on push to main
├── assets/
│   ├── css/main.css               # Site styles (palette sampled from the logo)
│   └── images/logo.png            # Source logo — Hugo processes it
├── content/                       # Markdown pages (one per route)
├── layouts/                       # HTML templates and partials
│   ├── _default/baseof.html
│   ├── _default/single.html
│   ├── _default/list.html
│   ├── index.html                 # Home page
│   ├── partials/
│   │   ├── header.html
│   │   ├── footer.html
│   │   ├── pricing-block.html
│   │   ├── contact-form.html
│   │   ├── lightwidget-embed.html
│   │   └── seo/                   # JSON-LD + meta tags
│   └── shortcodes/                # {{< pricing >}}, {{< contact-form >}}, {{< lightwidget >}}
├── static/
│   ├── CNAME                      # Custom domain (do not delete)
│   ├── favicon.ico
│   └── apple-touch-icon.png
├── static/private/invoice/
│   └── index.html                 # Hidden printable invoice page (noindex, not linked anywhere)
└── hugo.toml                      # All site config and tunables
```

---

## Placeholders to fill in before launch

Open `hugo.toml` and replace every `REPLACE_ME`:

| Param           | Where to get it                                                                 |
| --------------- | ------------------------------------------------------------------------------- |
| `formspreeId`   | Sign up at <https://formspree.io>, create a form, copy the ID (after `/f/`)     |
| `lightwidgetId` | Create a widget at <https://lightwidget.com> pointed at the public IG account   |
| `instagramUrl`  | Public Instagram profile URL                                                    |
| `pinterestUrl`  | Public Pinterest profile URL (or remove the line if no Pinterest)               |

You can deploy with placeholders still in place; the form and gallery will show friendly "configure me" messages instead of breaking.

### Recommended once the form is live

In Formspree's dashboard, toggle on **reCAPTCHA**. Without it, the 50/month free quota can be burned through by spam in a few weeks.

---

## Editing content

Each page is a Markdown file under `content/`. Front matter sets the title, subtitle, and SEO description; the body is normal Markdown. Shortcodes drop in pre-built blocks:

- `{{< pricing >}}` — the pricing card grid (kept in one place via `partials/pricing-block.html`)
- `{{< contact-form >}}` — the Formspree form
- `{{< lightwidget >}}` — the Instagram gallery embed

You can edit these files directly on GitHub.com from your browser if you don't want to keep Hugo running locally — GitHub Actions will rebuild and redeploy on every commit to `main`.

---

## Deployment (GitHub Pages)

This repo is set up to deploy via GitHub Pages using a workflow in `.github/workflows/deploy.yml`. Every push to `main` rebuilds the site and publishes it.

### One-time setup

1. **Push this repo** to `https://github.com/codeorganic/<repo-name>`.

2. **GitHub → Settings → Pages**:
   - Source: **GitHub Actions**.
   - Custom domain: **`dunnwithlovequilting.com`** → Save.
   - After the DNS check turns green (5 min – 1 hour), enable **Enforce HTTPS**.

3. **GoDaddy DNS** (`dunnwithlovequilting.com` → DNS):

   First, remove any existing parking A record on `@` and turn off Domain Forwarding (Domain Settings → Forwarding → trash). Forwarding overrides A records and is the #1 reason custom GitHub Pages domains fail on GoDaddy.

   Then add:

   | Type  | Name | Value                       | TTL    |
   | ----- | ---- | --------------------------- | ------ |
   | A     | @    | 185.199.108.153             | 1 hour |
   | A     | @    | 185.199.109.153             | 1 hour |
   | A     | @    | 185.199.110.153             | 1 hour |
   | A     | @    | 185.199.111.153             | 1 hour |
   | CNAME | www  | `codeorganic.github.io.`    | 1 hour |

   Optional IPv6 (improves reach):

   ```
   AAAA  @  2606:50c0:8000::153
   AAAA  @  2606:50c0:8001::153
   AAAA  @  2606:50c0:8002::153
   AAAA  @  2606:50c0:8003::153
   ```

4. **Verify** from a terminal:

   ```bash
   dig +short dunnwithlovequilting.com         # → the four 185.199.x.153 IPs
   dig +short www.dunnwithlovequilting.com     # → codeorganic.github.io
   curl -I https://dunnwithlovequilting.com    # → HTTP/2 200 from GitHub
   ```

### Where Formspree submissions land

In the Formspree dashboard, point the form's notification email at whatever inbox you want (a personal Gmail is fine). That address is private — it never appears on the website. Customers reach you only through the contact form.

---

## SEO checklist after going live

1. **Google Search Console** — add `dunnwithlovequilting.com` as a Domain property, verify with the DNS TXT record GoDaddy lets you add. Submit `https://dunnwithlovequilting.com/sitemap.xml`.
2. **Google Rich Results Test** — paste the homepage and confirm `LocalBusiness` parses with no errors: <https://search.google.com/test/rich-results>.
3. **Pinterest Rich Pin Validator** — paste the gallery URL and confirm the article-type Rich Pin renders: <https://developers.pinterest.com/tools/url-debugger/>.
4. **Lighthouse** — open Chrome DevTools → Lighthouse → run "Performance, Accessibility, SEO" on the live homepage. Target ≥ 90 Perf, ≥ 95 A11y, 100 SEO.

### Strongly recommended next step (not built in)

**Google Business Profile** at <https://www.google.com/business/>. Free, ~30 minutes to set up, drives more local-quilting traffic than the website itself does. Use the same business name, address (or service area), phone, and hours. Verification is by phone or postcard.

---

## Invoices (private page)

The invoice template lives at a **hidden URL** on the live site:

```
https://dunnwithlovequilting.com/private/invoice/
```

- Nothing on the site links to it.
- It's not in `sitemap.xml` (it's a static file, not a content page).
- The HTML carries `<meta name="robots" content="noindex, nofollow">`.
- `robots.txt` includes `Disallow: /private/` so well-behaved crawlers skip it.

It's "security through obscurity" — anyone with the URL can reach it, so don't share it. If you ever want stronger protection, the natural next step is moving the page to Cloudflare Pages or Netlify with a password gate. For now: just don't paste the URL in public.

### Workflow

1. Open the URL on any device (or run `./site.sh invoice` to open it locally via the dev server).
2. Edit the contenteditable fields (customer, dimensions, notes, payment info).
3. Totals recalculate live as you type.
4. **Print → Save as PDF**. Email the PDF to your customer.

When you outgrow this (around 20+ invoices/month, or when you want online payment links and saved customer history), [Wave](https://waveapps.com) is the natural next step — free forever for invoicing in the US.

---

## License

Site content © Dunn With Love Quilting. Site code is private.

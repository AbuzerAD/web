# Abuzer Ditta — Portfolio

An interactive one-page portfolio for Abuzer Ditta, a Senior Product / UX-UI Designer.
The visual language is a HyperOS 3-inspired "liquid glass" system: sapphire accents on a cool
off-white canvas (near-black ink in dark mode), a dark cosmic hero, IBM Plex Sans typography, pill-shaped
controls, unified rounded corners and layered depth — all without heavy blur on content.

The site is fully static — plain HTML, CSS and vanilla JavaScript, with **no build step and no
dependencies**. The only remote asset is the IBM Plex Sans webfont from Google Fonts.

## Structure

| Path | Purpose |
| --- | --- |
| `index.html` | Page markup, copy, section content and inline SVG icon sprite |
| `styles.css` | Design tokens, themes, layout, components, responsive/print rules |
| `script.js` | Filtering, dialogs, command palette and every index-page interaction |
| `data/projects.js` | Single source of truth for all fifteen projects |
| `work/` | One dedicated case-study page per project, plus `work/index.html` |
| `logos.html` | Logo and icon gallery, generated from the Dribbble archive |
| `assets/case.css` | Styles for case-study pages and the logo gallery |
| `assets/case.js` | Theme, navigation and scroll behaviour for the sub-pages |
| `assets/work/` | Project artwork downloaded from the Behance portfolio |
| `assets/logos/` | Logo and icon images downloaded from Dribbble |
| `tools/build.py` | Optional generator that writes `work/*.html` and `logos.html` |
| `tools/icons.py` | Re-fetches the Google Material Symbols paths into the inline SVG sprite |

## Run it locally

Open `index.html` directly, or serve the folder so relative paths behave exactly as they will
in production:

```bash
# Ruby (pre-installed on macOS)
ruby -run -e httpd . -p 8787
# then visit http://localhost:8787

# or Python
python3 -m http.server 8787
```

A local server is recommended: the browser clipboard API used by the “copy email” button only
works on `localhost` or HTTPS.

## Deploy

Any static host works because there is nothing to compile:

- **GitHub Pages** — push the folder to a repo, then Settings → Pages → deploy from `main` / root.
- **Netlify / Vercel** — drag the folder onto the dashboard, or connect the repo with no build
  command and publish directory `.`.
- **Cloudflare Pages** — connect the repo, leave the build command empty, output directory `/`.

Before publishing, deploy over HTTPS so the clipboard, fonts and share links all behave.

## What is interactive

- **Selected work carousel** — top 5 projects in a scroll-snap carousel with prev/next
  controls and dots, plus a “Browse all 15 case studies” link to `work/index.html`.
- **Case-study dialog** — every card opens a quick-view with role, tools, overview and scope,
  plus a **Read full case study** link to that project's dedicated page. Deep links (`#p-<id>`)
  open a project directly, and the dialog supports **Next project**.
- **Case-study pages** — `work/<id>.html` gives each project a full page with hero, facts,
  overview, achievement, scope, related work and next-project navigation.
- **Logo gallery** — `logos.html` shows 84 marks from Dribbble, each linking to the original shot.
- **Command palette** — `⌘K` / `Ctrl+K` or the header search button. Search sections, projects,
  skills and social links from the keyboard.
- **Experience accordion** — eleven roles expand to show responsibilities, focus areas and a key achievement.
- **Skills** — filter cards by discipline (research, design, systems).
- **Toolkit** — animated proficiency meters that fill when scrolled into view.
- **Process** — five tabbed stages (Discover → Deliver) with deliverables for each.
- **Recommendations** — quote carousel with previous/next controls and auto-advance.
- **Theme** — light/dark toggle, remembered in `localStorage` and applied before first paint to
  avoid a flash.
- **Contact** — click-to-copy email, phone link, local Dearborn, MI time, social links and a project
  brief form that composes a `mailto:` message in the visitor’s email app.
- **Chrome** — sticky header with scroll progress, active-section highlighting, scroll reveal,
  animated hero stats, back-to-top and a reduced-motion fallback.
- **Hero background** — 14-image rotating carousel (5 s per image, pure CSS crossfade) with a
  dark overlay for readable text; contact section reuses a single image.
- **Resume** — downloadable PDF (`assets/Abuzer-Ditta-Resume.pdf`) with a hero CTA button.
- **Favicon** — derived from the brand logo’s red slash mark.

## Editing content

The page is deliberately split so content stays easy to change.

### Projects

All fifteen projects live in `window.PROJECTS` in `data/projects.js`, which both the work grid
and the case-study pages read. Each entry supports:

```js
{
  id: "hyke-distributor",      // URL slug used by #p-<id>
  title: "HYKE Distributor Dashboard",
  client: "HYKE",
  cats: ["product", "web"],    // filters: product | mobile | web | brand
  catLabel: "Product · Web",
  role: "Senior Product Designer — …",
  tools: "Figma, Sketch",
  summary: "One-line card description.",
  overview: "Longer case-study paragraph.",
  scope: ["Bullet one", "Bullet two"],
  achievement: "One-line key achievement shown as a callout in the dialog.",
  image: "assets/work/example.jpg", // omit to use a generated gradient tile
  alt: "Description for screen readers",
  link: "https://www.behance.net/…",
  linkLabel: "Behance",
  tile: ["#dff7e8", "#b9ecd0"], // gradient for the no-image fallback
  initials: "HD",

  // optional — only used by the dedicated case-study page
  sections: [
    { title: "Approach", body: ["Paragraph one.", "Paragraph two."], items: ["Optional bullet"] }
  ],
  gallery: [
    { image: "assets/work/extra-1.jpg", alt: "Screenshot of …", caption: "Optional caption" }
  ]
}
```

Add `sections` or `gallery` to an entry and regenerate the pages to add real long-form content
to a case study. Both are skipped entirely when absent, so no empty headings are rendered.

Filter counts, the result total and the case-study dialog all derive from this array, so adding
or removing an entry updates the whole gallery automatically. If a project has no `image`, it
gets a branded gradient tile using `tile` and `initials`.

### Case-study pages and the logo gallery

The pages under `work/` and `logos.html` are generated so they stay consistent:

```bash
python3 tools/build.py
```

- Reads `data/projects.js` and `tools/logos.json`.
- Writes `work/index.html`, one `work/<id>.html` per project, and `logos.html`.
- Deployment still needs no build step — the generated HTML is committed.

The logo gallery reads `tools/logos.json`, which holds the Dribbble shot id, title, link and
image path for each mark. Add a shot by appending an entry and dropping its image into
`assets/logos/`.

### Everything else

- **Hero copy, stats, marquee** — `index.html`, hero section. Stats use `data-count` for the
  count-up target.
- **Experience** — the accordion items in `index.html` under `#experience`.
- **Skills** — the cards in `#skills`; each has a `data-skill-cat` used by the filters.
- **Toolkit meters** — change `data-pct` on the percentage label; the bar reads the same value.
- **Process** — the tabs and panels in `#process`.
- **Recommendations** — the quote slides in `#recommendations`.
- **Contact details** — the email/phone links and `EMAIL` constant in `script.js`.
- **Colors, spacing, radii, type** — CSS custom properties at the top of `styles.css`, with
  `[data-theme="dark"]` overrides immediately below.
- **Footer year** — filled automatically from the visitor’s clock.

## Imagery

The artwork in `assets/work/` was downloaded from Abuzer’s public
[Behance](https://www.behance.net/abuzerad) portfolio and is used here for the portfolio itself.
Projects without available artwork use CSS gradient tiles rather than borrowed images. Replace
an image by dropping a new file into `assets/work/` and pointing the project’s `image` field at it.

## Accessibility and quality

- Skip link, semantic landmarks, labelled controls and visible focus states.
- `prefers-reduced-motion` disables reveals, counters and carousel auto-advance.
- Dialogs use native `<dialog>` with Escape/backdrop close and focus management.
- Light and dark palettes are checked for readable contrast; print styles are included.
- Lighthouse: **100 accessibility, 100 best practices, 100 SEO** on the local build.
- The work grid degrades to a short `noscript` note linking to Behance and Dribbble.

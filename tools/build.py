#!/usr/bin/env python3
"""
Generate the static case-study pages and the logo gallery.

Run from the repository root:

    python3 tools/build.py

Inputs
  data/projects.js   window.PROJECTS = [...]  (source of truth for the work grid)
  tools/logos.json   Dribbble shot metadata for the logo gallery

Outputs
  work/index.html             index of all case studies
  work/<id>.html              one page per project
  logos.html                  logo gallery
"""

import html
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSET_VERSION = "20261126f"

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------


def read(path):
    with open(os.path.join(ROOT, path), encoding="utf-8") as fh:
        return fh.read()


def write(path, content):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as fh:
        fh.write(content)


def esc(value):
    return html.escape(str(value), quote=True)


def load_projects():
    raw = read("data/projects.js")
    start = raw.index("window.PROJECTS = ") + len("window.PROJECTS = ")
    end = raw.rindex(";")
    return json.loads(raw[start:end])


def sprite():
    """Take the icon symbols the case pages need from index.html."""
    index = read("index.html")
    block = re.search(r'<svg class="svg-sprite".*?</svg>', index, re.S).group(0)
    wanted = [
        "i-arrow",
        "i-external",
        "i-sun",
        "i-moon",
        "i-up",
        "i-spark",
        "i-close",
        "i-down",
        "i-dribbble",
        "i-behance",
    ]
    symbols = re.findall(r"<symbol .*?</symbol>", block, re.S)
    keep = [s for s in symbols if re.search(r'id="([^"]+)"', s).group(1) in wanted]
    return (
        '<svg class="svg-sprite" aria-hidden="true" focusable="false"><defs>'
        + "".join(keep)
        + "</defs></svg>"
    )


def brand_svg():
    """Inline the logo, tinted with currentColor so it works in both themes."""
    index = read("index.html")
    svg = re.search(r'<svg class="brand__mark".*?</svg>', index, re.S).group(0)
    svg = svg.replace('fill="#003049"', 'fill="currentColor"')
    svg = svg.replace('aria-label="Abuzer"', 'aria-label="Abuzer Ditta"')
    return svg


def head(title, description, rel="../", extra_schema=None):
    schema = ""
    if extra_schema:
        schema = (
            '<script type="application/ld+json">\n'
            + json.dumps(extra_schema, ensure_ascii=False, indent=2)
            + "\n</script>\n"
        )
    return f"""<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>{esc(title)}</title>
<meta name="description" content="{esc(description)}" />
<meta name="theme-color" content="#f4f7fd" />
<meta property="og:title" content="{esc(title)}" />
<meta property="og:description" content="{esc(description)}" />
<meta property="og:type" content="article" />
<script>
  (function () {{
    try {{
      var saved = localStorage.getItem("ad-theme");
      if (saved === "dark" || saved === "light") document.documentElement.dataset.theme = saved;
    }} catch (e) {{}}
  }})();
</script>
{schema}<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 32 32%27%3E %3Crect width=%2732%27 height=%2732%27 rx=%279%27 fill=%27%23050c18%27/%3E %3Cg transform=%27translate(7,3) scale(1.35)%27 fill=%27%23d62828%27%3E %3Cpath d=%27M4.46,12.98c-.64-.21-.91-.57-.91-1.21v-3.07c0-.6.27-.76.9-.56l3.76,1.22v-2.84l-3.76-1.22c-2.45-.79-3.75.08-3.75,2.51v3c0,2.48,1.29,4.22,3.72,5l6.4,2.07v-2.83l-6.38-2.06Z%27/%3E %3Cpath d=%27M2.15,.73v2.84l6.38,2.06c.64.21.91.57.91,1.21v3.07c0,.6-.27.76-.9.56l-3.76-1.22v2.84l3.76,1.22c2.45.79,3.74-.08,3.74-2.51v-3c0-2.48-1.29-4.21-3.72-5L2.15,.73Z%27/%3E %3C/g%3E %3C/svg%3E" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="{rel}styles.css?v={ASSET_VERSION}" />
<link rel="stylesheet" href="{rel}assets/case.css?v={ASSET_VERSION}" />
</head>
<body>
<a class="skip-link" href="#main">Skip to content</a>
"""


def header(rel="../", current=""):
    def cls(name):
        return "nav__link is-current" if name == current else "nav__link"

    return f"""{sprite()}
<header class="site-header">
  <div class="container header__inner">
    <a class="brand" href="{rel}index.html" aria-label="Abuzer Ditta — home">
      {brand_svg()}
    </a>

    <nav class="nav" id="site-nav" aria-label="Primary">
      <a href="{rel}index.html#work" class="{cls('work')}">Work</a>
      <a href="{rel}index.html#experience" class="{cls('experience')}">Experience</a>
      <a href="{rel}index.html#skills" class="{cls('skills')}">Skills</a>
      <a href="{rel}index.html#process" class="{cls('process')}">Process</a>
      <a href="{rel}logos.html" class="{cls('logos')}">Logos</a>
      <a href="{rel}index.html#contact" class="{cls('contact')}">Contact</a>
    </nav>

    <div class="header__actions">
      <button class="icon-btn" type="button" id="theme-toggle" aria-label="Switch to dark theme" aria-pressed="false">
        <svg class="ico ico--sun" aria-hidden="true"><use href="#i-sun"/></svg>
        <svg class="ico ico--moon" aria-hidden="true"><use href="#i-moon"/></svg>
      </button>
      <a class="btn btn--sm btn--header" href="{rel}index.html#contact">Let's talk <svg class="ico" aria-hidden="true"><use href="#i-arrow"/></svg></a>
      <button class="nav-toggle" type="button" id="nav-toggle" aria-expanded="false" aria-controls="site-nav" aria-label="Open menu">
        <span></span><span></span><span></span>
      </button>
    </div>
  </div>
</header>
"""


def footer(rel="../"):
    return f"""<footer class="site-footer">
  <div class="container footer__inner">
    <div class="footer__brand">
      {brand_svg()}
      <div>
        <p class="footer__name">Abuzer Ditta</p>
        <p class="footer__copy">© <span id="year">2026</span> · Designed and built by me.</p>
      </div>
    </div>

    <p class="footer__hobbies">Off the clock: guitar, badminton, films, sketching, swimming, motion, photography, travel.</p>

    <div class="footer__links">
      <a href="{rel}index.html#work">Work</a>
      <a href="{rel}work/index.html">Case studies</a>
      <a href="{rel}logos.html">Logos</a>
      <a href="{rel}index.html#contact">Contact</a>
      <a href="https://www.linkedin.com/in/abuzerad" target="_blank" rel="noopener">LinkedIn <svg class="ico" aria-hidden="true"><use href="#i-external"/></svg></a>
    </div>
  </div>
</footer>

<script src="{rel}assets/case.js?v={ASSET_VERSION}"></script>
</body>
</html>
"""


def tile(project, rel):
    """Gradient placeholder for projects without artwork."""
    initials = esc(project.get("initials") or project["title"][:2].upper())
    colors = project.get("tile") or ["#1b4fd8", "#0a1424"]
    return (
        f'<div class="case-card__tile" style="background:linear-gradient(140deg,{colors[0]},{colors[1]})">'
        f"{initials}</div>"
    )


def media(project, rel, klass="case-card__media"):
    image = project.get("image")
    if image:
        return (
            f'<div class="{klass}"><img src="{rel}{esc(image)}" alt="{esc(project.get("alt", project["title"]))}" '
            f'loading="lazy" decoding="async" /></div>'
        )
    return f'<div class="{klass}">{tile(project, rel)}</div>'


# --------------------------------------------------------------------------
# case study page
# --------------------------------------------------------------------------


def case_page(project, index, projects):
    rel = "../"
    pid = project["id"]
    title = project["title"]
    client = project["client"]
    cat_label = project["catLabel"]
    summary = project["summary"]
    overview = project["overview"]
    achievement = project.get("achievement", "")
    scope = project.get("scope", [])
    link = project.get("link", "")
    link_label = project.get("linkLabel", "Behance")

    next_project = projects[(index + 1) % len(projects)]
    related = [projects[(index + offset) % len(projects)] for offset in (1, 2, 3)]

    toc = ['<a href="#overview">Overview</a>']
    if scope:
        toc.append('<a href="#scope">Scope</a>')
    if project.get("sections"):
        toc.append('<a href="#detail">Project detail</a>')
    if project.get("gallery"):
        toc.append('<a href="#gallery">Gallery</a>')

    body = [
        f'<section class="cs-section" id="overview">'
        f"<h2>Overview</h2><p>{esc(overview)}</p></section>"
    ]

    if achievement:
        body.append(
            '<div class="achievement">'
            '<span class="achievement__icon" aria-hidden="true">'
            '<svg class="ico"><use href="#i-spark"/></svg></span>'
            "<p><span class=\"achievement__label\">Key achievement</span>"
            f"{esc(achievement)}</p></div>"
        )

    if scope:
        items = "".join(f"<li>{esc(item)}</li>" for item in scope)
        body.append(
            f'<section class="cs-section" id="scope"><h2>Scope &amp; responsibilities</h2>'
            f'<ul class="cs-list">{items}</ul></section>'
        )

    for section in project.get("sections") or []:
        parts = [f'<section class="cs-section" id="detail">']
        if section.get("title"):
            parts.append(f"<h2>{esc(section['title'])}</h2>")
        for paragraph in section.get("body") or []:
            parts.append(f"<p>{esc(paragraph)}</p>")
        if section.get("items"):
            parts.append(
                '<ul class="cs-list">'
                + "".join(f"<li>{esc(item)}</li>" for item in section["items"])
                + "</ul>"
            )
        parts.append("</section>")
        body.append("".join(parts))

    gallery = project.get("gallery") or []
    if gallery:
        figures = "".join(
            f'<figure><img src="{rel}{esc(item["image"])}" alt="{esc(item.get("alt", ""))}" '
            f'loading="lazy" decoding="async" />'
            + (f"<figcaption>{esc(item['caption'])}</figcaption>" if item.get("caption") else "")
            + "</figure>"
            for item in gallery
        )
        body.append(
            f'<section class="cs-section" id="gallery"><h2>Gallery</h2>'
            f'<div class="cs-gallery">{figures}</div></section>'
        )

    external = ""
    if link:
        external = (
            f'<a class="btn btn--ghost" href="{esc(link)}" target="_blank" rel="noopener">'
            f'View on {esc(link_label)} <svg class="ico" aria-hidden="true"><use href="#i-external"/></svg></a>'
        )

    cover = ""
    if project.get("image"):
        cover = (
            f'<figure class="cs-cover container">'
            f'<img src="{rel}{esc(project["image"])}" alt="{esc(project.get("alt", title))}" '
            f'fetchpriority="high" decoding="async" />'
            f"</figure>"
        )
    else:
        colors = project.get("tile") or ["#1b4fd8", "#0a1424"]
        cover = (
            f'<figure class="cs-cover container">'
            f'<div class="case-card__tile" style="aspect-ratio:16/9;border-radius:var(--radius-lg);'
            f'background:linear-gradient(140deg,{colors[0]},{colors[1]});font-size:56px">'
            f'{esc(project.get("initials") or title[:2].upper())}</div>'
            f"</figure>"
        )

    related_cards = "".join(
        f'<a class="cs-card" href="{p["id"]}.html">'
        + media(p, rel)
        + f'<span class="cs-card__title">{esc(p["title"])}</span>'
        + f'<span class="cs-card__meta">{esc(p["catLabel"])}</span></a>'
        for p in related
    )

    schema = {
        "@context": "https://schema.org",
        "@type": "CreativeWork",
        "name": title,
        "about": client,
        "description": summary,
        "creator": {"@type": "Person", "name": "Abuzer Ditta"},
    }

    return (
        head(f"{title} — Case study · Abuzer Ditta", summary, rel, schema)
        + header(rel, "work")
        + f"""<main id="main" class="page-main">
  <article>
    <header class="cs-hero">
      <div class="container">
        <a class="cs-back" href="./index.html">
          <svg class="ico" aria-hidden="true" style="transform:rotate(180deg)"><use href="#i-arrow"/></svg>
          All case studies
        </a>
        <p class="cs-kicker">{esc(client)} · {esc(cat_label)}</p>
        <h1 class="cs-title">{esc(title)}</h1>
        <p class="cs-lede">{esc(summary)}</p>
        <dl class="cs-facts">
          <div><dt>Client</dt><dd>{esc(client)}</dd></div>
          <div><dt>Role</dt><dd>{esc(project.get("role", ""))}</dd></div>
          <div><dt>Tools</dt><dd>{esc(project.get("tools", ""))}</dd></div>
          <div><dt>Discipline</dt><dd>{esc(cat_label)}</dd></div>
        </dl>
      </div>
    </header>

    {cover}

    <div class="container cs-layout">
      <aside class="cs-aside">
        <h2>On this page</h2>
        <nav class="cs-toc" aria-label="On this page">
          {"".join(toc)}
        </nav>
        {external}
      </aside>

      <div class="cs-body">
        {"".join(body)}
      </div>
    </div>
  </article>

  <nav class="cs-next" aria-label="Next case study">
    <div class="container cs-next__inner">
      <div>
        <p class="cs-next__label">Next case study</p>
        <a class="cs-next__link" href="{next_project["id"]}.html">
          {esc(next_project["title"])}
          <svg class="ico" aria-hidden="true"><use href="#i-arrow"/></svg>
        </a>
      </div>
      <a class="btn btn--ghost" href="./index.html">All case studies</a>
    </div>
  </nav>

  <section class="cs-related container">
    <h2>More work</h2>
    <div class="cs-cards">{related_cards}</div>
  </section>
</main>
"""
        + footer(rel)
    )


# --------------------------------------------------------------------------
# case study index
# --------------------------------------------------------------------------


def cases_index(projects):
    rel = "../"
    cards = []
    for project in projects:
        cards.append(
            f'<a class="case-card" href="{project["id"]}.html">'
            + media(project, rel)
            + f'<p class="case-card__kicker">{esc(project["client"])} · {esc(project["catLabel"])}</p>'
            + f'<h2 class="case-card__title">{esc(project["title"])}</h2>'
            + f'<p class="case-card__summary">{esc(project["summary"])}</p>'
            + '<span class="case-card__cta">Read case study <svg class="ico" aria-hidden="true"><use href="#i-arrow"/></svg></span>'
            + "</a>"
        )

    return (
        head(
            "Case studies — Abuzer Ditta",
            "In-depth case studies across product design, platforms, mobile apps and brand identity work.",
            rel,
        )
        + header(rel, "work")
        + f"""<main id="main" class="page-main">
  <section class="cases-hero container">
    <p class="cs-kicker">The work</p>
    <h1>Case studies, in depth.</h1>
    <p>Long-form write-ups of selected projects — the problem, the decisions and what changed. Open any card for the full story.</p>
  </section>

  <section class="container">
    <div class="cases-grid">
      {"".join(cards)}
    </div>
  </section>
</main>
"""
        + footer(rel)
    )


# --------------------------------------------------------------------------
# logo gallery
# --------------------------------------------------------------------------


def humanise(slug):
    words = re.sub(r"[-_]+", " ", slug).strip().split()
    return " ".join(w if w.isupper() else w[:1].upper() + w[1:] for w in words)


def logos_page():
    shots = json.load(open(os.path.join(ROOT, "tools/logos.json"), encoding="utf-8"))
    shots.sort(key=lambda shot: int(shot["id"]), reverse=True)
    tiles = []
    for shot in shots:
        name = (shot.get("title") or humanise(shot["slug"])).strip()
        path = f"assets/logos/{shot['id']}-{shot['slug']}.webp"
        tiles.append(
            f'<a class="logo-tile" href="{esc(shot["url"])}" target="_blank" rel="noopener">'
            f'<img src="{path}" alt="{esc(shot.get("alt") or name)}" loading="lazy" decoding="async" />'
            f"<span>{esc(name)}</span></a>"
        )

    return (
        head(
            "Logos & marks — Abuzer Ditta",
            "Logo, icon and calligraphy work from the Dribbble archive.",
            "",
        )
        + header("", "logos")
        + f"""<main id="main" class="page-main">
  <section class="logos-hero container">
    <p class="cs-kicker">Logos &amp; marks</p>
    <h1>Marks, icons and letterforms.</h1>
    <p>Logo design, app icons and calligraphy from the studio archive. Click any mark to open it on Dribbble.</p>
    <span class="logos-count">{len(shots)} marks · Dribbble</span>
  </section>

  <section class="container">
    <div class="logos-grid">
      {"".join(tiles)}
    </div>
  </section>
</main>
"""
        + footer("")
    )


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------


def main():
    projects = load_projects()

    for i, project in enumerate(projects):
        write(f"work/{project['id']}.html", case_page(project, i, projects))

    write("work/index.html", cases_index(projects))
    write("logos.html", logos_page())

    print(f"generated {len(projects)} case studies + index + logo gallery ({len(json.load(open(os.path.join(ROOT, 'tools/logos.json'))))} logos)")


if __name__ == "__main__":
    main()

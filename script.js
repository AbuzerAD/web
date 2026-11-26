/* =========================================================
   Abuzer Ditta — portfolio behaviour
   ========================================================= */
(() => {
  "use strict";

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const html = document.documentElement;
  const EMAIL = "abuzer@me.com";

  const escapeHtml = (value) =>
    String(value).replace(/[&<>"']/g, (char) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    }[char]));

  /* ---------------------------------------------------------
     Project data — edit titles, copy and links here.
     Images live in assets/work/.
     --------------------------------------------------------- */
  const PROJECTS = Array.isArray(window.PROJECTS) ? window.PROJECTS : [];

  /* ---------------------------------------------------------
     Theme
     --------------------------------------------------------- */
  const themeBtn = $("#theme-toggle");
  const metaTheme = document.querySelector('meta[name="theme-color"]');

  const setTheme = (theme, persist = true) => {
    html.dataset.theme = theme;
    const dark = theme === "dark";
    if (themeBtn) {
      themeBtn.setAttribute("aria-pressed", String(dark));
      themeBtn.setAttribute("aria-label", dark ? "Switch to light theme" : "Switch to dark theme");
    }
    if (metaTheme) metaTheme.setAttribute("content", dark ? "#05080f" : "#f4f7fd");
    if (persist) {
      try { localStorage.setItem("ad-theme", theme); } catch (error) { /* private mode */ }
    }
  };

  setTheme(html.dataset.theme === "dark" ? "dark" : "light", false);
  if (themeBtn) {
    themeBtn.addEventListener("click", () => {
      setTheme(html.dataset.theme === "dark" ? "light" : "dark");
    });
  }

  /* ---------------------------------------------------------
     Header, progress and back-to-top
     --------------------------------------------------------- */
  const header = $(".site-header");
  const progressBar = $("#progress-bar");
  const toTop = $("#to-top");
  let scrollTicking = false;

  const onScroll = () => {
    const y = window.scrollY;
    if (header) header.classList.toggle("is-scrolled", y > 8);
    if (progressBar) {
      const max = document.documentElement.scrollHeight - window.innerHeight;
      progressBar.style.width = `${max > 0 ? Math.min(100, (y / max) * 100) : 0}%`;
    }
    if (toTop) toTop.classList.toggle("is-visible", y > 720);
    scrollTicking = false;
  };

  window.addEventListener("scroll", () => {
    if (!scrollTicking) {
      scrollTicking = true;
      window.requestAnimationFrame(onScroll);
    }
  }, { passive: true });
  onScroll();

  if (toTop) {
    toTop.addEventListener("click", () => {
      window.scrollTo({ top: 0, behavior: reduceMotion ? "auto" : "smooth" });
    });
  }

  /* ---------------------------------------------------------
     Mobile navigation
     --------------------------------------------------------- */
  const navToggle = $("#nav-toggle");
  const nav = $("#site-nav");

  const closeNav = () => {
    if (!nav || !navToggle) return;
    nav.classList.remove("is-open");
    navToggle.setAttribute("aria-expanded", "false");
    navToggle.setAttribute("aria-label", "Open menu");
  };

  if (nav && navToggle) {
    navToggle.addEventListener("click", () => {
      const isOpen = navToggle.getAttribute("aria-expanded") === "true";
      if (isOpen) {
        closeNav();
      } else {
        nav.classList.add("is-open");
        navToggle.setAttribute("aria-expanded", "true");
        navToggle.setAttribute("aria-label", "Close menu");
      }
    });

    nav.addEventListener("click", (event) => {
      if (event.target.closest("a")) closeNav();
    });

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && nav.classList.contains("is-open")) {
        closeNav();
        navToggle.focus();
      }
    });

    document.addEventListener("click", (event) => {
      if (!nav.classList.contains("is-open")) return;
      if (nav.contains(event.target) || navToggle.contains(event.target)) return;
      closeNav();
    });

    window.addEventListener("resize", () => {
      if (window.innerWidth > 980) closeNav();
    });
  }

  /* ---------------------------------------------------------
     Work carousel (top 5)
     --------------------------------------------------------- */
  const track = $("#work-carousel-track");
  const prevBtn = $("#work-prev");
  const nextBtn = $("#work-next");
  const dotsEl = $("#work-dots");
  const featured = PROJECTS.slice(0, 5);

  const projectCard = (project) => {
    const media = project.image
      ? `<img src="${project.image}" alt="${escapeHtml(project.alt)}" width="808" height="632" loading="lazy" decoding="async">`
      : `<div class="work-card__tile" style="--tile-a:${project.tile[0]};--tile-b:${project.tile[1]}" aria-hidden="true"><span>${project.initials}</span></div>`;

    return `
      <div class="work-carousel__slide">
        <article class="work-card" data-cats="${project.cats.join(" ")}" data-search="${escapeHtml(
          `${project.title} ${project.client} ${project.summary} ${project.tools} ${project.cats.join(" ")}`.toLowerCase()
        )}">
          <a class="work-card__link" href="#p-${project.id}" data-project="${project.id}" aria-haspopup="dialog">
            <div class="work-card__media">
              ${media}
              <span class="work-card__tag">${project.catLabel}</span>
              <span class="work-card__open">Open case study <svg class="ico" aria-hidden="true"><use href="#i-arrow"/></svg></span>
            </div>
            <div class="work-card__body">
              <div class="work-card__top">
                <h3>${project.title}</h3>
                <span class="work-card__arrow" aria-hidden="true"><svg class="ico"><use href="#i-arrow"/></svg></span>
              </div>
              <p>${project.summary}</p>
              <span class="work-card__client">${project.client} · ${project.role.split("—")[0].trim()}</span>
            </div>
          </a>
        </article>
      </div>`;
  };

  const updateDots = () => {
    if (!track || !dotsEl) return;
    const slideW = track.querySelector(".work-carousel__slide")?.offsetWidth || 1;
    const gap = 18;
    const idx = Math.round(track.scrollLeft / (slideW + gap));
    $$(".work-carousel__dot", dotsEl).forEach((dot, i) => {
      const active = i === idx;
      dot.classList.toggle("is-active", active);
      dot.setAttribute("aria-selected", String(active));
    });
  };

  if (track) {
    track.innerHTML = featured.map(projectCard).join("");

    if (dotsEl) {
      dotsEl.innerHTML = featured.map((project, i) => `
        <button class="work-carousel__dot" type="button" role="tab"
          aria-label="Show ${escapeHtml(project.title)}" aria-selected="${i === 0 ? "true" : "false"}">
        </button>`).join("");
      $$(".work-carousel__dot", dotsEl).forEach((dot, i) => {
        dot.addEventListener("click", () => {
          const slide = track.querySelectorAll(".work-carousel__slide")[i];
          if (slide) track.scrollTo({ left: slide.offsetLeft, behavior: "smooth" });
        });
      });
    }

    const scrollBySlide = (dir) => {
      const slide = track.querySelector(".work-carousel__slide");
      if (!slide) return;
      const amount = slide.offsetWidth + 18;
      track.scrollBy({ left: dir * amount, behavior: "smooth" });
    };
    if (prevBtn) prevBtn.addEventListener("click", () => scrollBySlide(-1));
    if (nextBtn) nextBtn.addEventListener("click", () => scrollBySlide(1));

    const carousel = $("#work-carousel");
    if (carousel) {
      carousel.addEventListener("keydown", (event) => {
        if (event.key === "ArrowLeft") { event.preventDefault(); scrollBySlide(-1); }
        if (event.key === "ArrowRight") { event.preventDefault(); scrollBySlide(1); }
      });
    }

    track.addEventListener("scroll", updateDots, { passive: true });
    updateDots();
  }

  /* ---------------------------------------------------------
     Logos carousel (home)
     --------------------------------------------------------- */
  const logosTrack = $("#logos-carousel-track");
  const logosPrev = $("#logos-prev");
  const logosNext = $("#logos-next");
  const logosCounter = $("#logos-counter");

  const renderLogoTile = (shot) => {
    const name = (shot.title || shot.slug.replace(/[-_]+/g, " ")).trim();
    const path = `assets/logos/${shot.id}-${shot.slug}.webp`;
    return `<div class="logos-carousel__slide"><a class="logo-tile" href="${escapeHtml(shot.url)}" target="_blank" rel="noopener"><img src="${path}" alt="${escapeHtml(shot.alt || name)}" loading="lazy" decoding="async" /><span>${escapeHtml(name)}</span></a></div>`;
  };

  const updateLogosCounter = () => {
    if (!logosTrack || !logosCounter) return;
    const slide = logosTrack.querySelector(".logos-carousel__slide");
    if (!slide) return;
    const per = Math.max(1, Math.floor(logosTrack.clientWidth / (slide.offsetWidth + 14)));
    const idx = Math.round(logosTrack.scrollLeft / (slide.offsetWidth + 14));
    const total = logosTrack.querySelectorAll(".logos-carousel__slide").length;
    const start = idx + 1;
    const end = Math.min(total, idx + per);
    logosCounter.textContent = `${start} – ${end} of ${total}`;
  };

  if (logosTrack) {
    fetch("tools/logos.json")
      .then((r) => r.json())
      .then((shots) => {
        const top = (Array.isArray(shots) ? shots : []).slice(0, 18);
        logosTrack.innerHTML = top.map(renderLogoTile).join("");
        updateLogosCounter();
      })
      .catch(() => {
        logosTrack.innerHTML = '<p class="work-empty">Could not load logos.</p>';
      });

    const scrollByPage = (dir) => {
      const slide = logosTrack.querySelector(".logos-carousel__slide");
      if (!slide) return;
      const per = Math.max(1, Math.floor(logosTrack.clientWidth / (slide.offsetWidth + 14)));
      logosTrack.scrollBy({ left: dir * (slide.offsetWidth + 14) * per, behavior: "smooth" });
    };
    if (logosPrev) logosPrev.addEventListener("click", () => scrollByPage(-1));
    if (logosNext) logosNext.addEventListener("click", () => scrollByPage(1));
    logosTrack.addEventListener("scroll", updateLogosCounter, { passive: true });
    window.addEventListener("resize", updateLogosCounter);
  }

  /* ---------------------------------------------------------
     Logos carousel (home) — top 8
     --------------------------------------------------------- */
  const logosTrack = $("#logos-carousel-track");
  const logosPrev = $("#logos-prev");
  const logosNext = $("#logos-next");
  const logosCounter = $("#logos-counter");

  const renderLogoTile = (shot) => {
    const name = (shot.title || shot.slug.replace(/[-_]+/g, " ")).trim();
    const path = `assets/logos/${shot.id}-${shot.slug}.webp`;
    return `<div class="logos-carousel__slide"><a class="logo-tile" href="${escapeHtml(shot.url)}" target="_blank" rel="noopener"><img src="${path}" alt="${escapeHtml(shot.alt || name)}" loading="lazy" decoding="async" /><span>${escapeHtml(name)}</span></a></div>`;
  };

  const updateLogosCounter = () => {
    if (!logosTrack || !logosCounter) return;
    const slide = logosTrack.querySelector(".logos-carousel__slide");
    if (!slide) return;
    const per = Math.max(1, Math.floor(logosTrack.clientWidth / (slide.offsetWidth + 14)));
    const idx = Math.round(logosTrack.scrollLeft / (slide.offsetWidth + 14));
    const total = logosTrack.querySelectorAll(".logos-carousel__slide").length;
    const start = idx + 1;
    const end = Math.min(total, idx + per);
    logosCounter.textContent = `${start} – ${end} of ${total}`;
  };

  if (logosTrack) {
    fetch("tools/logos.json")
      .then((r) => r.json())
      .then((shots) => {
        const top = (Array.isArray(shots) ? shots : []).slice(0, 8);
        logosTrack.innerHTML = top.map(renderLogoTile).join("");
        updateLogosCounter();
      })
      .catch(() => {
        logosTrack.innerHTML = '<p class="work-empty">Could not load logos.</p>';
      });

    const scrollByPage = (dir) => {
      const slide = logosTrack.querySelector(".logos-carousel__slide");
      if (!slide) return;
      const per = Math.max(1, Math.floor(logosTrack.clientWidth / (slide.offsetWidth + 14)));
      logosTrack.scrollBy({ left: dir * (slide.offsetWidth + 14) * per, behavior: "smooth" });
    };
    if (logosPrev) logosPrev.addEventListener("click", () => scrollByPage(-1));
    if (logosNext) logosNext.addEventListener("click", () => scrollByPage(1));
    logosTrack.addEventListener("scroll", updateLogosCounter, { passive: true });
    window.addEventListener("resize", updateLogosCounter);
  }

  /* ---------------------------------------------------------
     Project dialog
     --------------------------------------------------------- */
  const projectModal = $("#project-modal");
  let currentProject = 0;

  const diskTile = (project) =>
    `<div class="work-card__tile" style="--tile-a:${project.tile[0]};--tile-b:${project.tile[1]}" aria-hidden="true"><span>${project.initials}</span></div>`;

  const openProject = (id, updateUrl = true) => {
    if (!projectModal) return;
    const index = PROJECTS.findIndex((project) => project.id === id);
    if (index < 0) return;
    currentProject = index;
    const project = PROJECTS[index];

    $("#pm-kicker").textContent = `${project.client} · ${project.catLabel}`;
    $("#pm-title").textContent = project.title;
    $("#pm-summary").textContent = project.summary;
    $("#pm-role").textContent = project.role;
    $("#pm-tools").textContent = project.tools;
    $("#pm-overview").textContent = project.overview;
    $("#pm-scope").innerHTML = project.scope.map((item) => `<li>${escapeHtml(item)}</li>`).join("");

    const achievement = $("#pm-achievement");
    const achievementText = $("#pm-achievement-text");
    if (achievement && achievementText) {
      achievementText.textContent = project.achievement || "";
      achievement.hidden = !project.achievement;
    }

    $("#pm-media").innerHTML = project.image
      ? `<img src="${project.image}" alt="${escapeHtml(project.alt)}" width="808" height="632" decoding="async">`
      : diskTile(project);

    const pageLink = $("#pm-page");
    if (pageLink) pageLink.href = `work/${project.id}.html`;

    const link = $("#pm-link");
    link.href = project.link;
    link.innerHTML = `View on ${project.linkLabel} <svg class="ico" aria-hidden="true"><use href="#i-external"/></svg>`;

    if (!projectModal.open) projectModal.showModal();
    document.body.classList.add("is-locked");

    if (updateUrl) {
      history.replaceState(null, "", `#p-${project.id}`);
    }

    const close = $("#pm-close");
    if (close) close.focus({ preventScroll: true });
  };

  if (projectModal) {
    const pmClose = $("#pm-close");
    if (pmClose) pmClose.addEventListener("click", () => projectModal.close());

    projectModal.addEventListener("click", (event) => {
      if (event.target === projectModal) projectModal.close();
    });

    projectModal.addEventListener("close", () => {
      if (!projectModal.open && !($("#palette") && $("#palette").open)) {
        document.body.classList.remove("is-locked");
      }
      if (window.location.hash.startsWith("#p-")) {
        history.replaceState(null, "", window.location.pathname + window.location.search);
      }
    });

    const next = $("#pm-next");
    if (next) {
      next.addEventListener("click", () => {
        const project = PROJECTS[(currentProject + 1) % PROJECTS.length];
        openProject(project.id);
      });
    }

    if (grid) {
      grid.addEventListener("click", (event) => {
        const link = event.target.closest("a[data-project]");
        if (!link) return;
        event.preventDefault();
        openProject(link.dataset.project);
      });
    }

    const deepLink = window.location.hash.match(/^#p-(.+)$/);
    if (deepLink) {
      window.requestAnimationFrame(() => openProject(deepLink[1], false));
    }
  }

  window.addEventListener("hashchange", () => {
    const match = window.location.hash.match(/^#p-(.+)$/);
    if (match && projectModal) {
      openProject(match[1], false);
    } else if (projectModal && projectModal.open) {
      projectModal.close();
    }
  });

  /* ---------------------------------------------------------
     Command palette
     --------------------------------------------------------- */
  const paletteDialog = $("#palette");
  const paletteInput = $("#palette-input");
  const paletteList = $("#palette-list");
  let paletteVisible = [];
  let paletteIndex = 0;

  const PALETTE_ITEMS = [
    { group: "Sections", label: "Selected work", hint: "Projects", icon: "i-arrow", type: "section", target: "#work" },
    { group: "Sections", label: "Experience", hint: "11 roles", icon: "i-arrow", type: "section", target: "#experience" },
    { group: "Sections", label: "Skills & toolkit", hint: "Capabilities", icon: "i-arrow", type: "section", target: "#skills" },
    { group: "Sections", label: "Design process", hint: "How I work", icon: "i-arrow", type: "section", target: "#process" },
    { group: "Sections", label: "Contact", hint: "Start a project", icon: "i-arrow", type: "section", target: "#contact" },
    ...PROJECTS.map((project) => ({
      group: "Projects",
      label: project.title,
      hint: project.catLabel,
      icon: "i-spark",
      type: "project",
      id: project.id,
      keywords: `${project.client} ${project.summary}`,
    })),
    { group: "Links", label: "Copy email address", hint: EMAIL, icon: "i-copy", type: "copy" },
    { group: "Links", label: "LinkedIn profile", hint: "abuzerad", icon: "i-linkedin", type: "href", href: "https://www.linkedin.com/in/abuzerad" },
    { group: "Links", label: "Behance portfolio", hint: "abuzerad", icon: "i-behance", type: "href", href: "https://www.behance.net/abuzerad" },
    { group: "Links", label: "Dribbble shots", hint: "abuzerad", icon: "i-dribbble", type: "href", href: "https://dribbble.com/abuzerad" },
  ];

  const updatePaletteActive = () => {
    if (!paletteList) return;
    const items = $$(".palette__item", paletteList);
    items.forEach((item, index) => {
      const active = index === paletteIndex;
      item.classList.toggle("is-active", active);
      item.setAttribute("aria-selected", String(active));
      if (active) {
        item.scrollIntoView({ block: "nearest" });
        if (paletteInput) paletteInput.setAttribute("aria-activedescendant", item.id);
      }
    });
  };

  const renderPalette = (term = "") => {
    if (!paletteList) return;
    const query = term.trim().toLowerCase();
    paletteVisible = PALETTE_ITEMS.filter((item) => {
      if (!query) return true;
      return `${item.label} ${item.hint} ${item.keywords || ""}`.toLowerCase().includes(query);
    });
    paletteIndex = 0;

    if (!paletteVisible.length) {
      paletteList.innerHTML = `<p class="palette__empty">No matches. Try “work”, “mobile”, “HYKE” or “email”.</p>`;
      if (paletteInput) paletteInput.removeAttribute("aria-activedescendant");
      return;
    }

    let markup = "";
    let lastGroup = "";
    paletteVisible.forEach((item, index) => {
      if (item.group !== lastGroup) {
        markup += `<p class="palette__group" role="presentation">${item.group}</p>`;
        lastGroup = item.group;
      }
      markup += `
        <button class="palette__item" type="button" role="option" id="palette-item-${index}" data-index="${index}" aria-selected="false">
          <svg class="ico" aria-hidden="true"><use href="#${item.icon}"/></svg>
          <span>${escapeHtml(item.label)}</span>
          <small>${escapeHtml(item.hint)}</small>
        </button>`;
    });
    paletteList.innerHTML = markup;
    updatePaletteActive();
  };

  const activatePalette = (item) => {
    if (!item) return;
    if (paletteDialog) paletteDialog.close();

    if (item.type === "section") {
      const target = document.querySelector(item.target);
      if (target) target.scrollIntoView({ behavior: reduceMotion ? "auto" : "smooth", block: "start" });
    } else if (item.type === "project") {
      openProject(item.id);
    } else if (item.type === "copy") {
      copyEmail();
    } else if (item.type === "href") {
      window.open(item.href, "_blank", "noopener");
    }
  };

  const openPalette = () => {
    if (!paletteDialog) return;
    if (typeof closeNav === "function") closeNav();
    if (projectModal && projectModal.open) projectModal.close();
    renderPalette("");
    if (!paletteDialog.open) paletteDialog.showModal();
    document.body.classList.add("is-locked");
    window.requestAnimationFrame(() => {
      if (paletteInput) {
        paletteInput.value = "";
        paletteInput.focus();
      }
    });
  };

  if (paletteDialog) {
    const opener = $("#palette-open");
    if (opener) opener.addEventListener("click", openPalette);

    if (paletteInput) {
      paletteInput.addEventListener("input", () => renderPalette(paletteInput.value));
      paletteInput.addEventListener("keydown", (event) => {
        if (event.key === "ArrowDown") {
          event.preventDefault();
          paletteIndex = Math.min(paletteIndex + 1, paletteVisible.length - 1);
          updatePaletteActive();
        } else if (event.key === "ArrowUp") {
          event.preventDefault();
          paletteIndex = Math.max(paletteIndex - 1, 0);
          updatePaletteActive();
        } else if (event.key === "Home") {
          event.preventDefault();
          paletteIndex = 0;
          updatePaletteActive();
        } else if (event.key === "End") {
          event.preventDefault();
          paletteIndex = paletteVisible.length - 1;
          updatePaletteActive();
        } else if (event.key === "Enter") {
          event.preventDefault();
          activatePalette(paletteVisible[paletteIndex]);
        }
      });
    }

    if (paletteList) {
      paletteList.addEventListener("click", (event) => {
        const item = event.target.closest(".palette__item");
        if (!item) return;
        activatePalette(paletteVisible[Number(item.dataset.index)]);
      });
    }

    paletteDialog.addEventListener("click", (event) => {
      if (event.target === paletteDialog) paletteDialog.close();
    });

    paletteDialog.addEventListener("close", () => {
      if (!paletteDialog.open && !(projectModal && projectModal.open)) {
        document.body.classList.remove("is-locked");
      }
    });
  }

  document.addEventListener("keydown", (event) => {
    const target = document.activeElement;
    const typing = target && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName);
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      openPalette();
    } else if (event.key === "/" && !typing) {
      event.preventDefault();
      openPalette();
    }
  });

  /* ---------------------------------------------------------
     Reveal on scroll + staggering
     --------------------------------------------------------- */
  $$(".skill-grid, .toolkit__grid, .education__grid, .timeline, .work-grid").forEach((parent) => {
    $$(":scope > .reveal", parent).forEach((el, index) => {
      el.style.setProperty("--i", `${Math.min(index, 6) * 55}ms`);
    });
  });

  const revealEls = $$(".reveal");

  if (reduceMotion || !("IntersectionObserver" in window)) {
    revealEls.forEach((el) => el.classList.add("is-visible"));
  } else {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -6% 0px", threshold: 0.06 });
    revealEls.forEach((el) => revealObserver.observe(el));
  }

  /* ---------------------------------------------------------
     Count-up stats
     --------------------------------------------------------- */
  const animateCount = (el) => {
    const target = Number(el.dataset.count) || 0;
    if (reduceMotion) {
      el.textContent = String(target);
      return;
    }
    const duration = 1100;
    const start = performance.now();
    const tick = (now) => {
      const progress = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = String(Math.round(target * eased));
      if (progress < 1) window.requestAnimationFrame(tick);
    };
    el.textContent = "0";
    window.requestAnimationFrame(tick);
  };

  $$("[data-count]").forEach((el) => {
    if (!("IntersectionObserver" in window)) return;
    const counterObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        animateCount(entry.target);
        observer.disconnect();
      });
    }, { threshold: 0.6 });
    counterObserver.observe(el);
  });

  /* ---------------------------------------------------------
     Toolkit meters
     --------------------------------------------------------- */
  $$(".meter").forEach((meter) => {
    const tool = meter.closest(".tool");
    const pctEl = tool ? $(".tool__pct", tool) : null;
    const target = pctEl ? Number(pctEl.dataset.pct) : 0;

    const fillMeter = () => {
      meter.classList.add("is-on");
      if (!pctEl || reduceMotion) return;
      const duration = 1100;
      const start = performance.now();
      const tick = (now) => {
        const progress = Math.min(1, (now - start) / duration);
        const eased = 1 - Math.pow(1 - progress, 3);
        pctEl.textContent = `${Math.round(target * eased)}%`;
        if (progress < 1) window.requestAnimationFrame(tick);
      };
      pctEl.textContent = "0%";
      window.requestAnimationFrame(tick);
    };

    if (!("IntersectionObserver" in window)) {
      fillMeter();
      return;
    }
    const meterObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        fillMeter();
        observer.disconnect();
      });
    }, { threshold: 0.45 });
    meterObserver.observe(meter);
  });

  /* ---------------------------------------------------------
     Experience accordion
     --------------------------------------------------------- */
  const expItems = $$(".exp");
  expItems.forEach((item) => {
    const head = $(".exp__head", item);
    if (!head) return;
    head.addEventListener("click", () => {
      const wasOpen = item.classList.contains("is-open");
      expItems.forEach((other) => {
        other.classList.remove("is-open");
        const otherHead = $(".exp__head", other);
        if (otherHead) otherHead.setAttribute("aria-expanded", "false");
      });
      if (!wasOpen) {
        item.classList.add("is-open");
        head.setAttribute("aria-expanded", "true");
      }
    });
  });

  /* ---------------------------------------------------------
     Skills filter
     --------------------------------------------------------- */
  const skillFilters = $("#skill-filters");
  if (skillFilters) {
    skillFilters.addEventListener("click", (event) => {
      const chip = event.target.closest(".chip");
      if (!chip) return;
      const filter = chip.dataset.skillFilter;
      $$(".chip", skillFilters).forEach((item) => {
        const active = item === chip;
        item.classList.toggle("is-active", active);
        item.setAttribute("aria-pressed", String(active));
      });
      $$(".skill").forEach((skill) => {
        skill.hidden = filter !== "all" && skill.dataset.skillCat !== filter;
      });
    });
  }

  /* ---------------------------------------------------------
     Process tabs
     --------------------------------------------------------- */
  const processTabs = $$(".process__tab");
  const processPanels = $$(".process__panel");

  const selectStep = (index) => {
    processTabs.forEach((tab, i) => {
      const active = i === index;
      tab.classList.toggle("is-active", active);
      tab.setAttribute("aria-selected", String(active));
      tab.tabIndex = active ? 0 : -1;
    });
    processPanels.forEach((panel, i) => {
      panel.hidden = i !== index;
      panel.classList.toggle("is-active", i === index);
    });
  };

  processTabs.forEach((tab, index) => {
    tab.addEventListener("click", () => selectStep(index));
    tab.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowRight" && event.key !== "ArrowLeft") return;
      event.preventDefault();
      const next = (index + (event.key === "ArrowRight" ? 1 : -1) + processTabs.length) % processTabs.length;
      selectStep(next);
      processTabs[next].focus();
    });
  });

  /* ---------------------------------------------------------
     Recommendations carousel
     --------------------------------------------------------- */
  const quoteSlides = $$(".quote");
  const quoteDots = $("#quote-dots");
  let quoteIndex = 0;
  let quoteTimer = 0;

  const setQuote = (index) => {
    if (!quoteSlides.length) return;
    quoteIndex = (index + quoteSlides.length) % quoteSlides.length;
    quoteSlides.forEach((slide, i) => slide.classList.toggle("is-active", i === quoteIndex));
    $$(".quotes__dot").forEach((dot, i) => {
      dot.classList.toggle("is-active", i === quoteIndex);
      dot.setAttribute("aria-selected", String(i === quoteIndex));
    });
  };

  const restartQuotes = () => {
    if (reduceMotion || quoteSlides.length < 2) return;
    window.clearInterval(quoteTimer);
    quoteTimer = window.setInterval(() => setQuote(quoteIndex + 1), 9000);
  };

  if (quoteDots && quoteSlides.length) {
    quoteSlides.forEach((slide, index) => {
      const dot = document.createElement("button");
      dot.type = "button";
      dot.className = "quotes__dot";
      dot.setAttribute("role", "tab");
      dot.setAttribute("aria-label", `Recommendation ${index + 1}`);
      dot.addEventListener("click", () => {
        setQuote(index);
        restartQuotes();
      });
      quoteDots.appendChild(dot);
    });
    setQuote(0);
    restartQuotes();

    const prev = $("#quote-prev");
    const next = $("#quote-next");
    if (prev) prev.addEventListener("click", () => { setQuote(quoteIndex - 1); restartQuotes(); });
    if (next) next.addEventListener("click", () => { setQuote(quoteIndex + 1); restartQuotes(); });

    const quotes = $(".quotes");
    if (quotes) {
      quotes.addEventListener("mouseenter", () => window.clearInterval(quoteTimer));
      quotes.addEventListener("mouseleave", restartQuotes);
      quotes.addEventListener("focusin", () => window.clearInterval(quoteTimer));
      quotes.addEventListener("focusout", restartQuotes);
    }
  }

  /* ---------------------------------------------------------
     Toast + copy email
     --------------------------------------------------------- */
  let toastTimer = 0;
  const showToast = (message) => {
    const toast = $("#toast");
    if (!toast) return;
    toast.textContent = message;
    toast.classList.add("is-visible");
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => toast.classList.remove("is-visible"), 2800);
  };

  const copyEmail = async () => {
    try {
      await navigator.clipboard.writeText(EMAIL);
      showToast(`Email copied — ${EMAIL}`);
    } catch (error) {
      const field = document.createElement("textarea");
      field.value = EMAIL;
      field.setAttribute("readonly", "");
      field.style.position = "fixed";
      field.style.opacity = "0";
      document.body.appendChild(field);
      field.select();
      try {
        document.execCommand("copy");
        showToast(`Email copied — ${EMAIL}`);
      } catch (fallbackError) {
        showToast(`Email: ${EMAIL}`);
      }
      field.remove();
    }
  };

  document.addEventListener("click", (event) => {
    const trigger = event.target.closest("[data-copy-email]");
    if (!trigger) return;
    event.preventDefault();
    copyEmail();
  });

  /* ---------------------------------------------------------
     Project brief form
     --------------------------------------------------------- */
  const brief = $("#brief");
  if (brief) {
    brief.addEventListener("submit", async (event) => {
      event.preventDefault();
      if (!brief.reportValidity()) return;
      const submitBtn = brief.querySelector('button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = "Sending…";
      }
      try {
        const response = await fetch("https://formsubmit.co/ajax/abuzer.ad@gmail.com", {
          method: "POST",
          body: new FormData(brief),
          headers: { Accept: "application/json" },
        });
        const result = await response.json().catch(() => ({}));
        if (!response.ok || result.success === "false" || result.success === false) {
          if (String(result.message || "").toLowerCase().includes("activat")) {
            showToast("Activation email sent — click the link in your Gmail inbox, then try again.");
          } else {
            throw new Error(result.message || "failed");
          }
          return;
        }
        showToast("Thanks — your brief was sent. I’ll reply soon.");
        brief.reset();
      } catch (error) {
        showToast("Couldn’t send just now — please email abuzer.ad@gmail.com directly.");
      } finally {
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.innerHTML = `Send project brief <svg class="ico" aria-hidden="true"><use href="#i-arrow"/></svg>`;
        }
      }
    });
  }

  /* ---------------------------------------------------------
     Local time, hero rotator and pointer glow
     --------------------------------------------------------- */
  const localTime = $("#local-time");
  const updateTime = () => {
    if (!localTime) return;
    try {
      localTime.textContent = new Intl.DateTimeFormat("en-US", {
        timeZone: "America/New_York",
        hour: "numeric",
        minute: "2-digit",
      }).format(new Date());
    } catch (error) {
      localTime.textContent = "Florida";
    }
  };
  updateTime();
  window.setInterval(updateTime, 60000);

  const rotatorWords = $$("#rotator .rotator__word");
  if (!reduceMotion && rotatorWords.length > 1) {
    let wordIndex = 0;
    window.setInterval(() => {
      const current = rotatorWords[wordIndex];
      wordIndex = (wordIndex + 1) % rotatorWords.length;
      const next = rotatorWords[wordIndex];
      current.classList.remove("is-current");
      current.classList.add("is-leaving");
      next.classList.add("is-current");
      window.setTimeout(() => current.classList.remove("is-leaving"), 500);
    }, 2800);
  }

  const hero = $(".hero");
  const heroGlow = $("#hero-glow");
  if (hero && heroGlow && !reduceMotion && window.matchMedia("(pointer: fine)").matches) {
    let glowFrame = null;
    hero.addEventListener("pointermove", (event) => {
      if (glowFrame) return;
      glowFrame = window.requestAnimationFrame(() => {
        const rect = hero.getBoundingClientRect();
        const x = ((event.clientX - rect.left) / rect.width) * 100;
        const y = ((event.clientY - rect.top) / rect.height) * 100;
        hero.style.setProperty("--mx", `${x}%`);
        hero.style.setProperty("--my", `${y}%`);
        hero.classList.add("has-pointer");
        glowFrame = null;
      });
    });
    hero.addEventListener("pointerleave", () => hero.classList.remove("has-pointer"));
  }

  /* ---------------------------------------------------------
     Active navigation link
     --------------------------------------------------------- */
  const navLinks = $$(".nav__link");
  const navSections = navLinks
    .map((link) => document.querySelector(link.getAttribute("href")))
    .filter(Boolean);

  if ("IntersectionObserver" in window && navSections.length) {
    const setActive = (id) => {
      navLinks.forEach((link) => {
        const active = link.getAttribute("href") === `#${id}`;
        link.classList.toggle("is-active", active);
        if (active) link.setAttribute("aria-current", "true");
        else link.removeAttribute("aria-current");
      });
    };

    const navObserver = new IntersectionObserver((entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
      if (visible) setActive(visible.target.id);
    }, { rootMargin: "-42% 0px -52% 0px", threshold: 0 });

    navSections.forEach((section) => navObserver.observe(section));
  }

  /* ---------------------------------------------------------
     Footer year
     --------------------------------------------------------- */
  const year = $("#year");
  if (year) year.textContent = String(new Date().getFullYear());
})();

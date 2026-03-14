const pptxgen = require("pptxgenjs");
const { calcTextBox } = require("./pptxgenjs_helpers/text");
const {
  imageSizingCrop,
  imageSizingContain,
} = require("./pptxgenjs_helpers/image");
const {
  warnIfSlideHasOverlaps,
  warnIfSlideElementsOutOfBounds,
} = require("./pptxgenjs_helpers/layout");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.author = "OpenAI Codex";
pptx.company = "OpenAI";
pptx.subject = "SEO audit presentatie voor EVM Dakwerken";
pptx.title = "EVM Dakwerken SEO Audit";
pptx.lang = "nl-BE";
pptx.theme = {
  headFontFace: "Aptos Display",
  bodyFontFace: "Aptos",
  lang: "nl-BE",
};

const COLORS = {
  navy: "0F2747",
  blue: "1E5AA8",
  sky: "DCEBFA",
  cyan: "DFF5F3",
  orange: "E6A34A",
  sand: "F6EFE5",
  green: "1F8C6D",
  red: "C44E42",
  yellow: "D39A28",
  ink: "1E293B",
  slate: "64748B",
  line: "D6DFEA",
  white: "FFFFFF",
  pale: "F7F9FC",
};

const IMG = {
  logo: "assets/evm-logo.png",
  hero: "assets/hero.jpeg",
};

function addSlideBase(slide, pageTitle, pageNo) {
  slide.background = { color: COLORS.white };
  slide.addShape(pptx.ShapeType.rect, {
    x: 0,
    y: 0,
    w: 13.333,
    h: 0.44,
    fill: { color: COLORS.navy },
    line: { color: COLORS.navy },
  });
  slide.addText(pageTitle, {
    x: 0.5,
    y: 0.63,
    w: 9.4,
    h: 0.35,
    fontFace: "Aptos Display",
    fontSize: 24,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  slide.addText(`EVM Dakwerken SEO Audit`, {
    x: 0.5,
    y: 7.02,
    w: 3.8,
    h: 0.18,
    fontFace: "Aptos",
    fontSize: 8.5,
    color: COLORS.slate,
    margin: 0,
  });
  slide.addText(String(pageNo), {
    x: 12.35,
    y: 7.0,
    w: 0.35,
    h: 0.18,
    fontFace: "Aptos",
    fontSize: 8.5,
    color: COLORS.slate,
    align: "right",
    margin: 0,
  });
}

function addBodyText(slide, text, x, y, w, fontSize = 13, color = COLORS.ink) {
  const layout = calcTextBox(fontSize, {
    w,
    text,
    fontFace: "Aptos",
    margin: 0,
    breakLine: false,
    paraSpaceAfterPt: 6,
    bulletIndent: fontSize * 0.9,
  });
  slide.addText(text, {
    x,
    y,
    w,
    h: layout.h + 0.02,
    fontFace: "Aptos",
    fontSize,
    color,
    margin: 0,
    breakLine: false,
    valign: "top",
  });
  return layout.h;
}

function addBullets(slide, items, x, y, w, fontSize = 12.5, color = COLORS.ink) {
  const runs = items.map((item) => ({
    text: item,
    options: { bullet: { indent: 14 } },
  }));
  const text = items.join("\n");
  const layout = calcTextBox(fontSize, {
    w,
    text,
    fontFace: "Aptos",
    margin: 0,
    breakLine: true,
    paraSpaceAfterPt: 7,
  });
  slide.addText(runs, {
    x,
    y,
    w,
    h: layout.h + 0.05,
    fontFace: "Aptos",
    fontSize,
    color,
    margin: 0,
    breakLine: true,
    valign: "top",
  });
  return layout.h;
}

function addCard(slide, opts) {
  const {
    x,
    y,
    w,
    h,
    title,
    body,
    fill = COLORS.pale,
    accent = COLORS.blue,
    bodySize = 11.5,
  } = opts;
  slide.addShape(pptx.ShapeType.roundRect, {
    x,
    y,
    w,
    h,
    rectRadius: 0.08,
    fill: { color: fill },
    line: { color: fill },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x,
    y,
    w: 0.1,
    h,
    fill: { color: accent },
    line: { color: accent },
  });
  slide.addText(title, {
    x: x + 0.22,
    y: y + 0.18,
    w: w - 0.34,
    h: 0.32,
    fontFace: "Aptos Display",
    fontSize: 15,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  addBodyText(slide, body, x + 0.22, y + 0.58, w - 0.34, bodySize);
}

function addMetricCard(slide, x, y, w, h, value, label, tone = "blue") {
  const map = {
    blue: { bg: "EAF2FF", fg: COLORS.blue },
    orange: { bg: "FBF1E4", fg: COLORS.orange },
    green: { bg: "E7F6F1", fg: COLORS.green },
    red: { bg: "FCEBE8", fg: COLORS.red },
  };
  const c = map[tone];
  slide.addShape(pptx.ShapeType.roundRect, {
    x,
    y,
    w,
    h,
    rectRadius: 0.08,
    fill: { color: c.bg },
    line: { color: c.bg },
  });
  slide.addText(value, {
    x: x + 0.18,
    y: y + 0.22,
    w: w - 0.36,
    h: 0.36,
    fontFace: "Aptos Display",
    fontSize: 22,
    bold: true,
    color: c.fg,
    margin: 0,
    align: "center",
  });
  slide.addText(label, {
    x: x + 0.18,
    y: y + 0.72,
    w: w - 0.36,
    h: 0.36,
    fontFace: "Aptos",
    fontSize: 10.5,
    color: COLORS.ink,
    align: "center",
    margin: 0,
  });
}

function addSectionLabel(slide, text, x, y, w = 2.2) {
  slide.addText(text, {
    x,
    y,
    w,
    h: 0.22,
    fontFace: "Aptos",
    fontSize: 9,
    bold: true,
    color: COLORS.blue,
    margin: 0,
    allCaps: true,
    charSpace: 1.1,
  });
}

function addScoreBar(slide, x, y, w, label, score, tone = COLORS.blue) {
  slide.addText(label, {
    x,
    y,
    w: 2.25,
    h: 0.22,
    fontFace: "Aptos",
    fontSize: 11,
    color: COLORS.ink,
    margin: 0,
  });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: x + 2.35,
    y: y + 0.02,
    w: w,
    h: 0.18,
    rectRadius: 0.04,
    fill: { color: "E8EEF5" },
    line: { color: "E8EEF5" },
  });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: x + 2.35,
    y: y + 0.02,
    w: (w * score) / 10,
    h: 0.18,
    rectRadius: 0.04,
    fill: { color: tone },
    line: { color: tone },
  });
  slide.addText(`${score}/10`, {
    x: x + 2.35 + w + 0.12,
    y: y - 0.02,
    w: 0.45,
    h: 0.24,
    fontFace: "Aptos",
    fontSize: 10.5,
    bold: true,
    color: COLORS.ink,
    margin: 0,
  });
}

function addTable(slide, rows, x, y, w, colWidths, opts = {}) {
  slide.addTable(rows, {
    x,
    y,
    w,
    colW: colWidths,
    border: { type: "solid", color: COLORS.line, pt: 1 },
    fill: COLORS.white,
    fontFace: "Aptos",
    fontSize: opts.fontSize || 10.5,
    color: COLORS.ink,
    margin: 0.06,
    rowH: opts.rowH || 0.34,
    valign: "mid",
    bold: false,
    autoFit: false,
  });
}

function addRoadmapLane(slide, x, y, w, h, title, fill, bullets) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x,
    y,
    w,
    h,
    rectRadius: 0.08,
    fill: { color: fill },
    line: { color: fill },
  });
  slide.addText(title, {
    x: x + 0.2,
    y: y + 0.18,
    w: w - 0.4,
    h: 0.28,
    fontFace: "Aptos Display",
    fontSize: 16,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  addBullets(slide, bullets, x + 0.18, y + 0.62, w - 0.35, 11.3);
}

function finalize(slide) {
  warnIfSlideHasOverlaps(slide, pptx);
  warnIfSlideElementsOutOfBounds(slide, pptx);
}

// Slide 1
{
  const slide = pptx.addSlide();
  slide.background = { color: COLORS.white };
  slide.addImage({
    path: IMG.hero,
    ...imageSizingCrop(IMG.hero, 0, 0, 13.333, 7.5),
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 0,
    y: 0,
    w: 13.333,
    h: 7.5,
    fill: { color: COLORS.navy, transparency: 28 },
    line: { color: COLORS.navy, transparency: 100 },
  });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 0.65,
    y: 0.72,
    w: 4.5,
    h: 5.95,
    rectRadius: 0.08,
    fill: { color: COLORS.white, transparency: 8 },
    line: { color: COLORS.white, transparency: 100 },
  });
  slide.addImage({
    path: IMG.logo,
    ...imageSizingContain(IMG.logo, 0.9, 0.98, 1.9, 0.82),
  });
  slide.addText("SEO Audit en groeiplan", {
    x: 0.9,
    y: 2.05,
    w: 3.7,
    h: 0.7,
    fontFace: "Aptos Display",
    fontSize: 25,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  slide.addText("EVM Dakwerken", {
    x: 0.9,
    y: 2.85,
    w: 2.9,
    h: 0.4,
    fontFace: "Aptos Display",
    fontSize: 18,
    bold: true,
    color: COLORS.blue,
    margin: 0,
  });
  addBodyText(
    slide,
    "Van brochure-site naar een lokale leadgeneratie-machine voor hellende daken, platte daken, sandwichpanelen en indak zonnepanelen.",
    0.9,
    3.38,
    3.65,
    13
  );
  slide.addText("Auditdatum: 14 maart 2026", {
    x: 0.9,
    y: 6.05,
    w: 2.1,
    h: 0.2,
    fontFace: "Aptos",
    fontSize: 9.5,
    color: COLORS.slate,
    margin: 0,
  });
  slide.addText("Benchmark: Kijzer, Recotex, Cralux", {
    x: 0.9,
    y: 6.32,
    w: 2.8,
    h: 0.2,
    fontFace: "Aptos",
    fontSize: 9.5,
    color: COLORS.slate,
    margin: 0,
  });
  finalize(slide);
}

// Slide 2
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "1. Wat zien we vandaag?", 2);
  addSectionLabel(slide, "Executive summary", 0.5, 1.02);
  addCard(slide, {
    x: 0.5,
    y: 1.35,
    w: 4.0,
    h: 2.1,
    title: "Wat de site nu doet",
    body: "De huidige website werkt vooral als een nette brochure-site. Ze toont het dienstenaanbod en contactgegevens, maar is nog niet ingericht als leadgenererende SEO-machine.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 4.67,
    y: 1.35,
    w: 4.0,
    h: 2.1,
    title: "Grootste SEO-problemen",
    body: "Te weinig pagina's, generieke metadata, bijna geen lokale SEO-structuur, geen blog of cases, slechte alt-tags en zwakke mobiele laadsnelheid.",
    fill: "FFF3EE",
    accent: COLORS.red,
  });
  addCard(slide, {
    x: 8.84,
    y: 1.35,
    w: 4.0,
    h: 2.1,
    title: "Grootste groeikansen",
    body: "Nieuwe dienstpagina's, provincie- en stadspagina's, prijs- en vergelijkingscontent, sterkere interne links en GEO-content voor AI-zoekmachines.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  addMetricCard(slide, 0.7, 4.0, 2.1, 1.35, "12", "Indexeerbare pagina's", "blue");
  addMetricCard(slide, 2.95, 4.0, 2.1, 1.35, "0", "Blogartikels", "red");
  addMetricCard(slide, 5.2, 4.0, 2.1, 1.35, "7,6 s", "Mobiele LCP", "orange");
  addMetricCard(slide, 7.45, 4.0, 2.1, 1.35, "4", "Doelprovincies", "blue");
  addMetricCard(slide, 9.7, 4.0, 2.1, 1.35, "~100", "Aanbevolen paginadoel", "green");
  addCard(slide, {
    x: 0.7,
    y: 5.75,
    w: 11.2,
    h: 0.9,
    title: "Voorzichtige groeiprognose",
    body: "Bij consistente uitvoering is een realistische 6 tot 9 maanden groei: x2 tot x4 organisch verkeer, 5 tot 12 extra leads per maand en 1 tot 2 extra projecten per maand.",
    fill: COLORS.sand,
    accent: COLORS.orange,
    bodySize: 12,
  });
  finalize(slide);
}

// Slide 3
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "2. Huidige website: brochure, geen leadmachine", 3);
  addSectionLabel(slide, "Positionering", 0.5, 1.02);
  addCard(slide, {
    x: 0.6,
    y: 1.34,
    w: 3.85,
    h: 1.35,
    title: "Brochure website",
    body: "Ja. De site toont wie EVM is en wat het doet.",
    fill: "EEF6FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 4.75,
    y: 1.34,
    w: 3.85,
    h: 1.35,
    title: "Marketing website",
    body: "Beperkt. Er is nauwelijks content die zoekverkeer actief aantrekt.",
    fill: "FFF7EC",
    accent: COLORS.orange,
  });
  addCard(slide, {
    x: 8.9,
    y: 1.34,
    w: 3.85,
    h: 1.35,
    title: "Leadgeneratie website",
    body: "Nog niet. Er ontbreken commerciële landingspagina's en funnels.",
    fill: "FCEDEC",
    accent: COLORS.red,
  });
  addSectionLabel(slide, "Belangrijkste observaties", 0.6, 3.0);
  addBullets(
    slide,
    [
      "Homepage is breed en merkgericht, maar niet scherp op zoekintentie of regio.",
      "Dienstenpagina's zijn dun: grofweg 169 tot 318 woorden per pagina.",
      "Contactpagina mist een duidelijke H1 en sterk offertemoment boven de vouw.",
      "De vier doelprovincies worden vrijwel nergens expliciet inhoudelijk genoemd.",
      "Er zijn geen blogartikels, FAQ-pagina's, projectcases of prijsartikelen.",
    ],
    0.6,
    3.32,
    6.0,
    12
  );
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 7.2,
    y: 3.1,
    w: 5.55,
    h: 2.85,
    rectRadius: 0.08,
    fill: { color: "F8FBFF" },
    line: { color: COLORS.line, pt: 1 },
  });
  slide.addText("Live voorbeelden", {
    x: 7.45,
    y: 3.32,
    w: 2.0,
    h: 0.25,
    fontFace: "Aptos Display",
    fontSize: 16,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  addTable(
    slide,
    [
      [
        { text: "Element", options: { bold: true, color: COLORS.white } },
        { text: "Huidige situatie", options: { bold: true, color: COLORS.white } },
      ],
      ["Homepage title", "Home - EVM Dakwerken"],
      ["Zonnepanelen title", "zonnepanelen - EVM Dakwerken"],
      ["Contact H1", "Ontbreekt"],
      ["Blogartikels", "0"],
      ["Lokale landingspagina's", "0"],
    ],
    7.45,
    3.72,
    4.95,
    [1.9, 2.9],
    { fontSize: 10, rowH: 0.34 }
  );
  slide.addText("De site bewijst aanwezigheid, maar wint vandaag nauwelijks niet-merk zoekverkeer.", {
    x: 0.6,
    y: 6.5,
    w: 8.3,
    h: 0.24,
    fontFace: "Aptos",
    fontSize: 12,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  finalize(slide);
}

// Slide 4
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "3. Algemene SEO-score", 4);
  addSectionLabel(slide, "Scorekaart", 0.5, 1.02);
  addScoreBar(slide, 0.7, 1.55, 5.1, "Technische SEO", 5, COLORS.blue);
  addScoreBar(slide, 0.7, 2.0, 5.1, "Content SEO", 3, COLORS.red);
  addScoreBar(slide, 0.7, 2.45, 5.1, "Local SEO", 2, COLORS.red);
  addScoreBar(slide, 0.7, 2.9, 5.1, "Mobile SEO", 6, COLORS.orange);
  addScoreBar(slide, 0.7, 3.35, 5.1, "Structured data", 4, COLORS.orange);
  addScoreBar(slide, 0.7, 3.8, 5.1, "Trust signals", 4, COLORS.orange);
  addCard(slide, {
    x: 7.0,
    y: 1.45,
    w: 5.45,
    h: 1.2,
    title: "Sterkste basispunten",
    body: "Indexatie, canonical tags, basis contactinformatie en desktopperformantie zijn aanwezig.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  addCard(slide, {
    x: 7.0,
    y: 2.85,
    w: 5.45,
    h: 1.2,
    title: "Grootste remmers",
    body: "Te weinig pagina's, te weinig contentdiepte, bijna geen lokale dekking en geen sterke trustlaag op de site.",
    fill: "FFF3EE",
    accent: COLORS.red,
  });
  addCard(slide, {
    x: 7.0,
    y: 4.25,
    w: 5.45,
    h: 1.35,
    title: "Wat dit commercieel betekent",
    body: "EVM is vandaag vooral op merknaam vindbaar. Wie zoekt op dienst + regio komt meestal bij concurrenten of grotere contentspelers uit.",
    fill: COLORS.sand,
    accent: COLORS.orange,
  });
  finalize(slide);
}

// Slide 5
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "4. Core Web Vitals: mobiel is de bottleneck", 5);
  addSectionLabel(slide, "Prestatie", 0.5, 1.02);
  addTable(
    slide,
    [
      [
        { text: "Metric", options: { bold: true, color: COLORS.white } },
        { text: "Doel", options: { bold: true, color: COLORS.white } },
        { text: "Huidig", options: { bold: true, color: COLORS.white } },
        { text: "Beoordeling", options: { bold: true, color: COLORS.white } },
      ],
      ["LCP", "< 2,5 s", "7,6 s mobiel", "Slecht"],
      ["INP", "< 200 ms", "geen velddata; TBT 20 ms", "Neutraal tot goed"],
      ["CLS", "< 0,10", "0,00", "Goed"],
      ["Desktop LCP", "< 2,5 s", "1,8 s", "Goed"],
    ],
    0.7,
    1.45,
    5.65,
    [1.15, 1.15, 1.85, 1.5],
    { fontSize: 11, rowH: 0.38 }
  );
  addCard(slide, {
    x: 0.7,
    y: 4.2,
    w: 5.65,
    h: 1.55,
    title: "Vertaling in mensentaal",
    body: "Mobiel komt de belangrijkste content te laat in beeld. Dat remt zowel SEO als conversie, zeker bij bezoekers die snel willen vergelijken of een offerte willen aanvragen.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 6.8,
    y: 1.45,
    w: 5.8,
    h: 1.55,
    title: "Waarschijnlijkste oorzaak",
    body: "De server is niet extreem traag. Het grootste probleem zit vooral in zware boven-de-vouw afbeeldingen, renderpad en beperkte caching op statische assets.",
    fill: "FFF7EC",
    accent: COLORS.orange,
  });
  addBullets(
    slide,
    [
      "hero- en sliderbeelden omzetten naar WebP of AVIF",
      "CDN toevoegen voor snellere assetlevering",
      "browser caching instellen op afbeeldingen en scripts",
      "enkel de eerste zichtbare afbeelding prioriteit geven",
      "overige beelden onder de vouw lazy loaden",
    ],
    7.0,
    3.45,
    5.1,
    11.8
  );
  slide.addText("CDN = een netwerk van servers dat afbeeldingen en bestanden dichter bij de bezoeker levert, zodat de site sneller laadt.", {
    x: 6.95,
    y: 6.05,
    w: 5.2,
    h: 0.5,
    fontFace: "Aptos",
    fontSize: 11.2,
    color: COLORS.ink,
    margin: 0,
  });
  finalize(slide);
}

// Slide 6
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "5. Afbeelding-SEO en on-page quick wins", 6);
  addSectionLabel(slide, "Before / after", 0.5, 1.02);
  addTable(
    slide,
    [
      [
        { text: "Afbeelding", options: { bold: true, color: COLORS.white } },
        { text: "Huidige alt-tag", options: { bold: true, color: COLORS.white } },
        { text: "Verbetering", options: { bold: true, color: COLORS.white } },
      ],
      ["Hero homepage", "leeg", "dakrenovatie door EVM Dakwerken in provincie Antwerpen"],
      ["Sliderfoto", "hash / bestandsnaam", "plat dak renovatie met waterdichte afwerking"],
      ["Projectfoto", "hash / bestandsnaam", "industrieel dak met sandwichpanelen geplaatst"],
      ["Logo", "leeg", "EVM Dakwerken logo"],
    ],
    0.7,
    1.4,
    6.15,
    [1.5, 1.6, 3.05],
    { fontSize: 10.5, rowH: 0.4 }
  );
  addCard(slide, {
    x: 0.7,
    y: 4.35,
    w: 6.15,
    h: 1.5,
    title: "Waarom dit belangrijk is",
    body: "Goede alt-tags helpen voor SEO, Google Images en toegankelijkheid. Vandaag missen bijna alle betekenisvolle beelden context of bevatten ze alleen bestandsnamen.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addTable(
    slide,
    [
      [
        { text: "Element", options: { bold: true, color: COLORS.white } },
        { text: "Huidig", options: { bold: true, color: COLORS.white } },
        { text: "Aanbevolen", options: { bold: true, color: COLORS.white } },
      ],
      ["Homepage title", "Home - EVM Dakwerken", "Dakwerken Antwerpen | Hellende, Platte en Industriële Daken | EVM Dakwerken"],
      ["Zonnepanelen title", "zonnepanelen - EVM Dakwerken", "Indak zonnepanelen plaatsen | EVM Dakwerken"],
      ["Contact H1", "ontbreekt", "Vraag uw offerte voor dakwerken aan"],
      ["URL", "/nieuwbouw-renovatie/", "/hellend-dak-renoveren/ en /plat-dak-renoveren/"],
    ],
    7.0,
    1.4,
    5.6,
    [1.45, 1.75, 2.4],
    { fontSize: 9.7, rowH: 0.42 }
  );
  addCard(slide, {
    x: 7.0,
    y: 4.35,
    w: 5.6,
    h: 1.5,
    title: "Impact van deze quick wins",
    body: "Deze verbeteringen lossen op zichzelf de groei niet op, maar ze verhogen wel de klikpotentie, begrijpbaarheid en basisrelevantie van de site.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  finalize(slide);
}

// Slide 7
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "6. Concurrentie: online footprint is vandaag te klein", 7);
  addSectionLabel(slide, "Benchmark", 0.5, 1.02);
  slide.addChart(pptx.ChartType.bar, [
    {
      name: "Pagina's in sitemap",
      labels: ["EVM Dakwerken", "Recotex", "Kijzer"],
      values: [12, 169, 1202],
    },
  ], {
    x: 0.7,
    y: 1.5,
    w: 6.0,
    h: 3.8,
    catAxisLabelFontFace: "Aptos",
    catAxisLabelFontSize: 11,
    valAxisLabelFontFace: "Aptos",
    valAxisLabelFontSize: 10,
    chartColors: [COLORS.blue],
    showLegend: false,
    showTitle: false,
    showValue: true,
    dataLabelPosition: "outEnd",
    valGridLine: { color: "DDE5EF", pt: 1 },
    showCatName: true,
  });
  addCard(slide, {
    x: 7.15,
    y: 1.52,
    w: 5.35,
    h: 1.25,
    title: "Kijzer",
    body: "Sterk op werkgebiedpagina's, inspiratiecontent en schaal. Publiek zichtbaar: meer dan 1.200 sitemap-URL's.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 7.15,
    y: 2.95,
    w: 5.35,
    h: 1.25,
    title: "Recotex",
    body: "Compacter dan Kijzer, maar commercieel sterker opgebouwd met diensten, realisaties en ondersteunende content.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  addCard(slide, {
    x: 7.15,
    y: 4.38,
    w: 5.35,
    h: 1.25,
    title: "Wat dit voor EVM betekent",
    body: "De online markt wordt niet gewonnen op merk, maar op pagina-aantal, contentdiepte, lokale dekking en vertrouwen.",
    fill: "FFF7EC",
    accent: COLORS.orange,
  });
  slide.addText("Waarom concurrenten beter ranken", {
    x: 0.7,
    y: 5.75,
    w: 2.9,
    h: 0.24,
    fontFace: "Aptos Display",
    fontSize: 15,
    bold: true,
    color: COLORS.navy,
    margin: 0,
  });
  addBullets(
    slide,
    [
      "meer aparte dienst- en regiopagina's",
      "veel meer blog- en vraagcontent",
      "meer interne links en topical authority",
      "sterkere kans op backlinks en merkmentions",
    ],
    0.7,
    6.08,
    5.8,
    11.8
  );
  finalize(slide);
}

// Slide 8
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "7. Keyword gap: de grootste kansen zitten in niet-merkverkeer", 8);
  addSectionLabel(slide, "Zoekvraag", 0.5, 1.02);
  addTable(
    slide,
    [
      [
        { text: "Zoekwoord", options: { bold: true, color: COLORS.white } },
        { text: "Indicatief volume", options: { bold: true, color: COLORS.white } },
        { text: "Status EVM", options: { bold: true, color: COLORS.white } },
      ],
      ["dakrenovatie Antwerpen", "150", "zwakke zichtbaarheid"],
      ["plat dak Antwerpen", "120", "zwakke zichtbaarheid"],
      ["hellend dak renoveren", "90", "zwakke zichtbaarheid"],
      ["epdm of roofing", "70", "geen geschikte pagina"],
      ["asbest dak vervangen kostprijs", "110", "geen sterke prijscontent"],
      ["dakwerker Vlaams-Brabant", "70", "geen regiohub"],
      ["dakwerker Oost-Vlaanderen", "70", "geen regiohub"],
      ["dakwerker West-Vlaanderen", "60", "geen regiohub"],
    ],
    0.7,
    1.48,
    6.15,
    [2.8, 1.2, 2.15],
    { fontSize: 10.5, rowH: 0.36 }
  );
  addCard(slide, {
    x: 7.0,
    y: 1.5,
    w: 5.55,
    h: 1.2,
    title: "Belangrijk inzicht",
    body: "De huidige site vangt vooral merkverkeer op. De echte SEO-kans zit in zoekopdrachten waar mensen al een concreet probleem of project in gedachten hebben.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 7.0,
    y: 2.92,
    w: 5.55,
    h: 1.2,
    title: "Wat we nodig hebben",
    body: "Commerciële dienstpagina's, prijscontent, FAQ's, vergelijkingen en regiohubs die perfect aansluiten op koopintentie.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  addCard(slide, {
    x: 7.0,
    y: 4.34,
    w: 5.55,
    h: 1.45,
    title: "Voorbeelden van snelle win-content",
    body: "Wat kost een dakrenovatie, EPDM vs roofing, wanneer moet een dak vervangen worden, indak zonnepanelen vs opbouwpanelen.",
    fill: COLORS.sand,
    accent: COLORS.orange,
  });
  finalize(slide);
}

// Slide 9
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "8. Ideale structuur: van 12 naar ongeveer 100 pagina's", 9);
  addSectionLabel(slide, "Nieuwe informatiearchitectuur", 0.5, 1.02);
  const nodes = [
    { x: 0.6, y: 1.55, w: 1.9, h: 0.5, text: "Homepage", fill: "EAF2FF" },
    { x: 2.95, y: 1.55, w: 1.9, h: 0.5, text: "Diensten", fill: "EEF9F5" },
    { x: 5.3, y: 1.55, w: 1.9, h: 0.5, text: "Regio's", fill: "FFF7EC" },
    { x: 7.65, y: 1.55, w: 1.9, h: 0.5, text: "Blog", fill: "F8F0FF" },
    { x: 10.0, y: 1.55, w: 2.1, h: 0.5, text: "Projecten / offerte", fill: "FCEDEC" },
  ];
  nodes.forEach((n) => {
    slide.addShape(pptx.ShapeType.roundRect, {
      x: n.x,
      y: n.y,
      w: n.w,
      h: n.h,
      rectRadius: 0.04,
      fill: { color: n.fill },
      line: { color: n.fill },
    });
    slide.addText(n.text, {
      x: n.x + 0.08,
      y: n.y + 0.15,
      w: n.w - 0.16,
      h: 0.2,
      fontFace: "Aptos",
      fontSize: 11.3,
      bold: true,
      color: COLORS.navy,
      align: "center",
      margin: 0,
    });
  });
  for (let i = 0; i < 4; i++) {
    slide.addShape(pptx.ShapeType.line, {
      x: nodes[i].x + nodes[i].w,
      y: 1.8,
      w: nodes[i + 1].x - (nodes[i].x + nodes[i].w),
      h: 0,
      line: { color: COLORS.line, pt: 2 },
    });
  }
  addCard(slide, {
    x: 0.75,
    y: 2.45,
    w: 2.8,
    h: 2.15,
    title: "Kernservices",
    body: "Dakrenovatie\nPlat dak renoveren\nHellend dak renoveren\nIndustriële daken\nIndak zonnepanelen\nDakisolatie\nAsbestdak vervangen\nDakinspectie",
    fill: "F9FCFF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 3.75,
    y: 2.45,
    w: 2.8,
    h: 2.15,
    title: "Provinciehubs",
    body: "Antwerpen\nVlaams-Brabant\nOost-Vlaanderen\nWest-Vlaanderen",
    fill: "F9FCFF",
    accent: COLORS.green,
  });
  addCard(slide, {
    x: 6.75,
    y: 2.45,
    w: 2.8,
    h: 2.15,
    title: "Steden",
    body: "Antwerpen\nBrasschaat\nSchoten\nKapellen\nWuustwezel\nKalmthout\nLeuven\nGent",
    fill: "F9FCFF",
    accent: COLORS.orange,
  });
  addCard(slide, {
    x: 9.75,
    y: 2.45,
    w: 2.8,
    h: 2.15,
    title: "Contentcluster",
    body: "Prijsartikelen\nVergelijkingen\nFAQ's\nStappenplannen\nProjectcases\nDienst + stad pagina's",
    fill: "F9FCFF",
    accent: COLORS.red,
  });
  addCard(slide, {
    x: 0.75,
    y: 5.2,
    w: 11.8,
    h: 1.15,
    title: "Doelbeeld",
    body: "Ongeveer 100 tot 110 strategische pagina's: genoeg schaal om in meerdere provincies niet-merkverkeer op te bouwen, zonder in irrelevante massapagina's te vervallen.",
    fill: COLORS.sand,
    accent: COLORS.orange,
  });
  finalize(slide);
}

// Slide 10
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "9. Contentstrategie en GEO: zichtbaar worden in Google en AI", 10);
  addSectionLabel(slide, "Pillar + cluster + AI-citeerbare formats", 0.5, 1.02);
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 0.8,
    y: 1.55,
    w: 2.9,
    h: 1.0,
    rectRadius: 0.05,
    fill: { color: "EAF2FF" },
    line: { color: "EAF2FF" },
  });
  slide.addText("Pillar page\nDakrenovatie", {
    x: 1.0,
    y: 1.82,
    w: 2.5,
    h: 0.45,
    fontFace: "Aptos Display",
    fontSize: 18,
    bold: true,
    color: COLORS.navy,
    align: "center",
    margin: 0,
  });
  const clusters = [
    ["Wat kost een dakrenovatie", 4.45, 1.4],
    ["EPDM vs roofing", 4.45, 2.25],
    ["Wanneer moet een dak vervangen worden", 4.45, 3.1],
    ["Dakisolatie bij renovatie", 4.45, 3.95],
    ["Indak zonnepanelen of opbouwpanelen", 4.45, 4.8],
  ];
  clusters.forEach(([text, x, y]) => {
    slide.addShape(pptx.ShapeType.roundRect, {
      x,
      y,
      w: 3.45,
      h: 0.56,
      rectRadius: 0.04,
      fill: { color: "EEF9F5" },
      line: { color: "EEF9F5" },
    });
    slide.addText(text, {
      x: x + 0.15,
      y: y + 0.17,
      w: 3.15,
      h: 0.18,
      fontFace: "Aptos",
      fontSize: 11.2,
      bold: true,
      color: COLORS.ink,
      margin: 0,
    });
    slide.addShape(pptx.ShapeType.line, {
      x: 3.7,
      y: 2.05,
      w: x - 3.7,
      h: y + 0.27 - 2.05,
      line: { color: COLORS.line, pt: 1.3 },
    });
  });
  addCard(slide, {
    x: 8.45,
    y: 1.5,
    w: 4.1,
    h: 1.1,
    title: "Huidige GEO-score",
    body: "Laag. De site heeft bijna geen FAQ's, prijsartikelen, vergelijkingen of stappenplannen die AI-systemen makkelijk kunnen citeren.",
    fill: "FFF3EE",
    accent: COLORS.red,
  });
  addCard(slide, {
    x: 8.45,
    y: 2.85,
    w: 4.1,
    h: 1.1,
    title: "Wat AI graag citeert",
    body: "Directe antwoorden, tabellen, prijsranges, voor- en nadelen, heldere definities en goed gestructureerde FAQ's.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 8.45,
    y: 4.2,
    w: 4.1,
    h: 1.35,
    title: "Snelle GEO-wins",
    body: "Publiceer meteen 3 kernstukken: EPDM vs roofing, Wat kost een dakrenovatie, Wanneer moet een dak vervangen worden.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  finalize(slide);
}

// Slide 11
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "10. Roadmap: wat doen we wanneer?", 11);
  addSectionLabel(slide, "6 maanden", 0.5, 1.02);
  addRoadmapLane(slide, 0.6, 1.5, 4.0, 4.9, "Maand 1-2", "EEF6FF", [
    "titles, meta's en H1's herschrijven",
    "structured data corrigeren",
    "homepage en contact verbeteren",
    "kernservicepagina's bouwen",
    "alt-tags, caching en beeldoptimalisatie aanpakken",
  ]);
  addRoadmapLane(slide, 4.7, 1.5, 4.0, 4.9, "Maand 3-4", "EEF9F5", [
    "provinciehubs publiceren",
    "eerste service + stad pagina's lanceren",
    "blog en FAQ-architectuur opstarten",
    "eerste projectcases live zetten",
    "GBP review- en postritme activeren",
  ]);
  addRoadmapLane(slide, 8.8, 1.5, 4.0, 4.9, "Maand 5-6", "FFF7EC", [
    "lokale clusters uitbreiden",
    "extra blogs en cases publiceren",
    "backlinks en lokale citations opbouwen",
    "content aanscherpen via Search Console inzichten",
    "best scorende pagina's verder uitdiepen",
  ]);
  finalize(slide);
}

// Slide 12
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "11. Impact en opbrengst: een voorzichtige businesscase", 12);
  addSectionLabel(slide, "Conservatief scenario", 0.5, 1.02);
  const funnelX = 0.95;
  const funnelW = [5.7, 4.7, 3.5, 2.4];
  const funnelText = [
    ["+250 tot +450", "extra relevante bezoekers / maand"],
    ["5 tot 13", "extra leads / maand"],
    ["1 tot 2", "extra projecten / maand"],
    ["EUR 15k - 30k", "extra potentiële omzet / maand"],
  ];
  const fills = ["EAF2FF", "EEF9F5", "FFF7EC", "FCEDEC"];
  const accents = [COLORS.blue, COLORS.green, COLORS.orange, COLORS.red];
  let y = 1.55;
  for (let i = 0; i < funnelW.length; i++) {
    slide.addShape(pptx.ShapeType.chevron, {
      x: funnelX,
      y,
      w: funnelW[i],
      h: 0.82,
      fill: { color: fills[i] },
      line: { color: fills[i] },
    });
    slide.addText(funnelText[i][0], {
      x: funnelX + 0.28,
      y: y + 0.18,
      w: funnelW[i] - 0.55,
      h: 0.22,
      fontFace: "Aptos Display",
      fontSize: 18,
      bold: true,
      color: accents[i],
      align: "center",
      margin: 0,
    });
    slide.addText(funnelText[i][1], {
      x: funnelX + 0.28,
      y: y + 0.45,
      w: funnelW[i] - 0.55,
      h: 0.18,
      fontFace: "Aptos",
      fontSize: 10.5,
      color: COLORS.ink,
      align: "center",
      margin: 0,
    });
    y += 1.05;
  }
  addCard(slide, {
    x: 7.2,
    y: 1.58,
    w: 5.2,
    h: 1.25,
    title: "Aannames",
    body: "Voorzichtige aannames: 2% tot 3% leadconversie, 15% tot 20% close rate en een gemiddelde projectwaarde van EUR 15.000.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 7.2,
    y: 3.02,
    w: 5.2,
    h: 1.25,
    title: "Waarom dit voorzichtig is",
    body: "Bij industriële daken of grotere renovaties kan de gemiddelde projectwaarde hoger liggen. De echte upside kan dus groter zijn.",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  addCard(slide, {
    x: 7.2,
    y: 4.46,
    w: 5.2,
    h: 1.4,
    title: "Belangrijkste boodschap",
    body: "SEO hoeft hier geen honderden leads op te leveren om rendabel te zijn. In deze markt maken al 1 à 2 extra projecten per maand een groot verschil.",
    fill: COLORS.sand,
    accent: COLORS.orange,
  });
  finalize(slide);
}

// Slide 13
{
  const slide = pptx.addSlide();
  addSlideBase(slide, "12. Beslisvoorstel: waar starten we?", 13);
  addSectionLabel(slide, "Topprioriteiten", 0.5, 1.02);
  addBullets(
    slide,
    [
      "Nieuwe kernpagina's voor plat dak, hellend dak, sandwichpanelen en indak zonnepanelen",
      "Provincie- en service + stad pagina's voor de prioritaire regio's",
      "Prijs-, vergelijking- en FAQ-content die zowel voor SEO als sales werkt",
      "Technische quick wins: metadata, alt-tags, structured data en caching",
      "Reviewflow, projectcases en GBP-updates voor vertrouwen en lokale zichtbaarheid",
    ],
    0.7,
    1.55,
    6.05,
    12.6
  );
  addCard(slide, {
    x: 7.1,
    y: 1.55,
    w: 5.45,
    h: 1.2,
    title: "Hoe we dit klantvriendelijk presenteren",
    body: "Niet als een technisch rapport, maar als een groeiverhaal: waar staan we, waarom verliezen we zichtbaarheid, wat doen we eerst en wat levert het op.",
    fill: "F3F8FF",
    accent: COLORS.blue,
  });
  addCard(slide, {
    x: 7.1,
    y: 2.95,
    w: 5.45,
    h: 1.2,
    title: "Aanbevolen meetingflow",
    body: "1. Samenvatting\n2. Benchmark\n3. Kansen\n4. Roadmap\n5. Beslissing over fase 1",
    fill: "EEF9F5",
    accent: COLORS.green,
  });
  addCard(slide, {
    x: 7.1,
    y: 4.35,
    w: 5.45,
    h: 1.45,
    title: "Volgende stap",
    body: "Deze deck kan meteen dienen als klantpresentatie. Daarna kunnen we er een kortere salesversie of een uitvoeringsdeck voor intern gebruik van maken.",
    fill: COLORS.sand,
    accent: COLORS.orange,
  });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 0.72,
    y: 5.9,
    w: 11.85,
    h: 0.55,
    rectRadius: 0.04,
    fill: { color: COLORS.navy },
    line: { color: COLORS.navy },
  });
  slide.addText("Aanbevolen boodschap aan de klant: de basis is bruikbaar, maar de echte groei komt pas zodra de site commercieel en lokaal wordt uitgebouwd.", {
    x: 0.95,
    y: 6.07,
    w: 11.4,
    h: 0.18,
    fontFace: "Aptos",
    fontSize: 11.2,
    color: COLORS.white,
    align: "center",
    margin: 0,
  });
  finalize(slide);
}

pptx.writeFile({ fileName: "evm-dakwerken-seo-audit-presentatie.pptx" });

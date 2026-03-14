# JSON-LD Snippets

## Homepage: LocalBusiness + HomeAndConstructionBusiness
```json
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": ["HomeAndConstructionBusiness", "LocalBusiness"],
      "@id": "https://evmdakwerken.be/#business",
      "name": "EVM Dakwerken",
      "url": "https://evmdakwerken.be/",
      "telephone": "+32-468-15-18-13",
      "address": {
        "@type": "PostalAddress",
        "streetAddress": "Kleiput 4",
        "postalCode": "2990",
        "addressLocality": "Wuustwezel",
        "addressRegion": "Antwerpen",
        "addressCountry": "BE"
      },
      "areaServed": [
        "Antwerpen",
        "Wuustwezel",
        "Brasschaat",
        "Kalmthout",
        "Kapellen",
        "Schoten"
      ],
      "description": "EVM Dakwerken helpt met dakrenovatie, platte en hellende daken, dakisolatie, asbestverwijdering, groendaken, indak zonnepanelen en industriele daken."
    },
    {
      "@type": "WebPage",
      "@id": "https://evmdakwerken.be/#webpage",
      "url": "https://evmdakwerken.be/",
      "name": "Dakwerken en Dakrenovatie in Antwerpen | EVM Dakwerken",
      "about": {
        "@id": "https://evmdakwerken.be/#business"
      }
    }
  ]
}
```

## Dienstpagina: Service + BreadcrumbList
```json
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Service",
      "@id": "https://evmdakwerken.be/dakrenovatie/#service",
      "name": "Dakrenovatie",
      "serviceType": "Dakrenovatie voor platte en hellende daken",
      "provider": {
        "@id": "https://evmdakwerken.be/#business"
      },
      "areaServed": ["Antwerpen", "Wuustwezel"],
      "url": "https://evmdakwerken.be/dakrenovatie/"
    },
    {
      "@type": "BreadcrumbList",
      "@id": "https://evmdakwerken.be/dakrenovatie/#breadcrumbs",
      "itemListElement": [
        {
          "@type": "ListItem",
          "position": 1,
          "name": "Home",
          "item": "https://evmdakwerken.be/"
        },
        {
          "@type": "ListItem",
          "position": 2,
          "name": "Dakrenovatie",
          "item": "https://evmdakwerken.be/dakrenovatie/"
        }
      ]
    }
  ]
}
```

## FAQPage
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Wanneer is een dakrenovatie nodig?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Een dakrenovatie is meestal nodig wanneer er lekkages ontstaan, de dakbedekking versleten is, de isolatie niet meer voldoet of de onderbouw schade vertoont."
      }
    },
    {
      "@type": "Question",
      "name": "Kunnen dakisolatie en renovatie gecombineerd worden?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Ja. Dat is vaak de slimste aanpak, omdat u technische problemen oplost en tegelijk het energieverlies via het dak beperkt."
      }
    }
  ]
}
```

## Blogartikel: Article
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Wat kost een dakrenovatie in Antwerpen in 2026?",
  "author": {
    "@type": "Organization",
    "name": "EVM Dakwerken"
  },
  "publisher": {
    "@type": "Organization",
    "name": "EVM Dakwerken"
  },
  "mainEntityOfPage": "https://evmdakwerken.be/blog/wat-kost-een-dakrenovatie-in-antwerpen-in-2026/",
  "about": ["Dakrenovatie", "Antwerpen", "Dakwerken"]
}
```

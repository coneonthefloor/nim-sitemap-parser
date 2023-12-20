# Nim Sitemap Parser
Parses a sitemap retrieving all links. Follows nested sitemaps.

## Installation
    $ nimble sitemapparser

## Changes
    1.0.0 - parses standard xml sitemap

## Usage

```nim
# Request non nested sitemap. The sequence will contain one Sitemap object.
let sitemaps: seq[Sitemap] = waitFor parseSitemap(sitemapURI)
let sitemap: Sitemap = sitemaps[0]

echo("Sitemap Location: " & sitemap.loc)
echo("Sitemap LastModified: " & sitemap.lastMod)
for url in sitemap.entries:
    echo("Location: " & url.loc)
    echo("LastModified: " & url.lastMod)
    echo("Change Frequency: " & url.changefreq)
    echo("Priority: " & intToStr(url.priority))

# Request sitemap index to get a Sitemap object for each sub sitemap.
let sitemaps: seq[Sitemap] = waitFor parseSitemap(nestedSitemapURI)
for sitemap in sitemaps:
    echo("Name: " & sitemap.loc & ", url count: " & intToStr(len(sitemap.entries)))
```
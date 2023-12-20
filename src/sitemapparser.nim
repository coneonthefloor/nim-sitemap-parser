import q, xmltree, httpclient, strutils, logging, asyncdispatch, system

type
  Frequency* = enum
    always = "always"
    hourly = "hourly"
    daily = "daily"
    weekly = "weekly"
    monthly = "monthly"
    yearly = "yearly"
    never = "never"

  SitemapIndexEntry = object
    loc*: string
    lastmod*: string

  SitemapEntry = object
    loc*: string
    lastmod*: string
    changefreq*: Frequency
    priority*: float32

  Sitemap* = object
    loc*: string
    lastmod*: string
    entries*: seq[SitemapEntry]

proc hasURLSet(sitemapContent: string): bool =
  let doc = q(sitemapContent)
  doc.select("urlset").len > 0

proc hasSitemapIndex(sitemapContent: string): bool =
  let doc = q(sitemapContent)
  doc.select("sitemapindex").len > 0

proc getSitemapContent(sitemapUri: string): Future[string] {.async.} =
  var client = newAsyncHttpClient()
  try:
    return await client.getContent(sitemapUri)
  finally:
    client.close()

proc getSitemapIndexEntries(sitemapContent: string): seq[SitemapIndexEntry] =
  let doc = q(sitemapContent)
  for sitemap in doc.select("sitemap"):
    var entry: SitemapIndexEntry
    let sitemapDoc = sitemap.q()
    let loc = sitemapDoc.select("loc")
    if loc.len > 0:
      entry.loc = loc[0].innerText
    else:
      error "Invalid <sitemap/>, no <loc/> provided."
      continue

    let lastmod = sitemapDoc.select("lastmod")
    if lastmod.len > 0:
      entry.lastmod = lastmod[0].innerText

    result.add(entry)

proc getSitemapEntries(sitemapContent: string): seq[SitemapEntry] =
  let doc = q(sitemapContent)
  for url in doc.select("url"):
    var entry: SitemapEntry
    let urlDoc = url.q()
    let loc = urlDoc.select("loc")
    if loc.len > 0:
      entry.loc = loc[0].innerText
    else:
      error "Invalid <url/>, no <loc/> provided."
      continue

    let lastmod = urlDoc.select("lastmod")
    if lastmod.len > 0:
      entry.lastmod = lastmod[0].innerText

    let changefreq = urlDoc.select("changefreq")
    if changefreq.len > 0:
      let text = changefreq[0].innerText
      try:
        entry.changefreq = parseEnum[Frequency](text)
      finally:
        error "Invalid <changefreq/>, value: ", text , ", not recognized."

    let priority = urlDoc.select("priority")
    if priority.len > 0:
      let text = priority[0].innerText
      try:
        entry.priority = parseFloat(text)
      finally:
        error "Invalid <priority/>, value: " , text , ", not parseable."

    result.add(entry)

proc parseSitemap*(
    sitemapURI: string; lastMod: string = ""; isNestedCall: bool = false
): Future[seq[Sitemap]] {.async.} =
  let content = await getSitemapContent(sitemapURI)
  if content.len == 0:
    error "No content recieved from: " , sitemapURI
    return

  let urlsetFound = hasURLSet(content)
  if urlsetFound:
    var sitemap: Sitemap
    sitemap.loc = sitemapURI
    sitemap.lastmod = lastMod
    sitemap.entries = getSitemapEntries(content)
    result.add(sitemap)
    return result

  let sitemapIndexFound = hasSitemapIndex(content)
  if sitemapIndexFound and not isNestedCall:
    var futs: seq[Future[seq[Sitemap]]]
    for entry in getSitemapIndexEntries(content):
      futs &= parseSitemap(entry.loc, entry.lastMod, true)
    for entry in await futs.all():
      if entry.len > 0:
        result.add(entry[0])
    return result

  if not sitemapIndexFound and not urlsetFound:
    error "Invalid sitemap, no <urlset/> or <sitemapindex/> found at: ", sitemapURI

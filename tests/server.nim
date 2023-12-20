import prologue

proc nonNested*(ctx: Context) {.async.} =
  resp readFile("./testdata/non-nested-sitemap.xml")

proc nested*(ctx: Context) {.async.} =
  resp readFile("./testdata/nested-sitemap.xml")

let app = newApp()
app.get("/non-nested/sitemap.xml", nonNested)
app.get("/nested/sitemap.xml", nested)
app.run()
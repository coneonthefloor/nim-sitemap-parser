# Package

version       = "1.0.0"
author        = "coneonthefloor"
description   = "Parse a sitemap to get all listed urls."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["sitemapparser"]


# Dependencies

requires "nim ^= 2.0.0"
requires "q ^= 0.0.8"
requires "prologue ^= 0.6.4"
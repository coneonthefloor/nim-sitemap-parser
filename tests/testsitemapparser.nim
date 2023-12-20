import unittest
import asyncdispatch
import sitemapparser

test "non nested sitemap":
  let testSitemapURI ="http://localhost:8080/non-nested/sitemap.xml"
  let t = waitFor parseSitemap(testSitemapURI)
  check len(t) == 1 # should return one sitemap object
  check len(t[0].entries) == 7 # sitemap should have 7 entries
  check t[0].loc == testSitemapURI # sitemap loc should match request uri

test "nested sitemap":
  let testSitemapURI ="http://localhost:8080/nested/sitemap.xml"
  let t = waitFor parseSitemap(testSitemapURI)
  check len(t) == 1 # should return one sitemap object
  check len(t[0].entries) == 7 # sitemap should have 7 entries
  check t[0].loc == "http://localhost:8080/non-nested/sitemap.xml" # sitemap loc should match the nested sitemap

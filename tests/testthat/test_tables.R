library(testthat)
library(questionr)
context("Tables and cross-tables functions")

data(hdv2003)
data(fecondite)

test_that("Simple freq is correct", {
  tab <- freq(hdv2003$qualif)
  v <- as.numeric(summary(hdv2003$qualif))
  val <- as.numeric(table(hdv2003$qualif))
  expect_equal(names(tab), c("n", "%", "val%"))
  expect_equal(rownames(tab), c(levels(hdv2003$qualif), "NA"))
  expect_equal(tab$n, v)
  expect_equal(tab$`%`, round(v / sum(v) * 100, 1))
  expect_equal(tab$`val%`, c(round(val / sum(val) * 100, 1), NA))
})

test_that("freq with sort, digits, cum, valid and total is correct", {
  tab <- freq(hdv2003$qualif, digits = 2, cum = TRUE, total = TRUE, valid = FALSE, sort = "inc", na.last = FALSE)
  v <- sort(summary(hdv2003$qualif))
  vnum <- as.numeric(v)
  expect_equal(names(tab), c("n", "%", "%cum"))
  expect_equal(rownames(tab), gsub("NA's", "NA", c(names(v), "Total")))
  expect_equal(tab$n, c(vnum, sum(vnum)))
  expect_equal(tab$`%`, c(round(vnum / sum(vnum) * 100, 2), 100))
  expect_equal(tab$`%cum`, c(round(cumsum(vnum) / sum(vnum) * 100, 2), 100))
})

test_that("freq with sort, digits, cum, valid, total and na.last is correct", {
  tab <- freq(hdv2003$qualif, digits = 2, cum = TRUE, total = TRUE, valid = FALSE, sort = "inc", na.last = TRUE)
  v <- sort(summary(hdv2003$qualif))
  v <- c(v[names(v) != "NA's"], v[names(v) == "NA's"])
  vnum <- as.numeric(v)
  expect_equal(names(tab), c("n", "%", "%cum"))
  expect_equal(rownames(tab), gsub("NA's", "NA", c(names(v), "Total")))
  expect_equal(tab$n, c(vnum, sum(vnum)))
  expect_equal(tab$`%`, c(round(vnum / sum(vnum) * 100, 2), 100))
  expect_equal(tab$`%cum`, c(round(cumsum(vnum) / sum(vnum) * 100, 2), 100))
})


test_that("freq with exclude is correct", {
  tab <- freq(hdv2003$qualif, exclude = c(NA, "Cadre", "Autre"))
  v <- hdv2003$qualif[!(hdv2003$qualif %in% c(NA, "Cadre", "Autre"))]
  vtab <- as.numeric(table(v)[!(names(table(v)) %in% c(NA, "Cadre", "Autre"))])
  expect_equal(names(tab), c("n", "%"))
  expect_equal(rownames(tab), setdiff(levels(hdv2003$qualif), c("NA", "Cadre", "Autre")))
  expect_equal(tab$n, vtab)
  expect_equal(tab$`%`, round(vtab / sum(vtab) * 100, 1))
})

test_that("cprop results are correct" , {
  tab <- table(hdv2003$qualif, hdv2003$clso, exclude = NULL)
  etab <- tab[,apply(tab, 2, sum)>0]
  ctab <- cprop(tab, n = TRUE)
  expect_equal(colnames(ctab), c(levels(hdv2003$clso), gettext("All", domain="R-questionr")))
  expect_equal(rownames(ctab), c(levels(hdv2003$qualif), NA, gettext("Total", domain="R-questionr"), "n"))
  m <- prop.table(etab, 2) * 100
  expect_equal(ctab[1:nrow(m), 1:ncol(m)], m)
  margin <- margin.table(etab, 1)
  margin <- as.numeric(round(margin / sum(margin) * 100, 2))
  expect_equal(unname(ctab[1:length(margin), gettext("All", domain="R-questionr")]), margin) 
  n <- apply(etab, 2, sum)
  expect_equal(ctab["n",][1:length(n)], n)
})

test_that("lprop results are correct" , {
  tab <- table(hdv2003$qualif, hdv2003$clso, exclude = NULL)
  etab <- tab[,apply(tab, 2, sum)>0]
  ltab <- lprop(tab, n = TRUE)
  expect_equal(colnames(ltab), c(levels(hdv2003$clso), gettext("Total", domain="R-questionr"), "n"))
  expect_equal(rownames(ltab), c(levels(hdv2003$qualif), NA, gettext("All", domain="R-questionr")))
  m <- prop.table(etab, 1) * 100
  expect_equal(ltab[1:nrow(m), 1:ncol(m)], m)
  margin <- margin.table(etab, 2)
  margin <- as.numeric(round(margin / sum(margin) * 100, 2))
  expect_equal(unname(ltab[gettext("All", domain="R-questionr"), 1:length(margin)]), margin) 
  n <- apply(etab, 1, sum)
  expect_equal(ltab[,"n"][1:length(n)], n)
})



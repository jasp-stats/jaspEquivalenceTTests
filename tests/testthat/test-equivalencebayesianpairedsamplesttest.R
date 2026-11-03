options <- jaspTools::analysisOptions("EquivalenceBayesianPairedSamplesTTest")
options$lowerbound <- -1.5
options$upperbound <- 0
options$descriptives <- TRUE
options$massPriorPosterior <- TRUE
options$priorandposterior <- TRUE
options$plotSequentialAnalysis <- TRUE
options$plotSequentialAnalysisRobustness <- TRUE
options$pairs <- list(c("contNormal", "contGamma"))
set.seed(1)
results <- jaspTools::runAnalysis("EquivalenceBayesianPairedSamplesTTest", "test.csv", options)

test_that("Descriptives table results match", {
  table <- results[["results"]][["equivalenceBayesianDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(100, -0.398760810055084, -0.18874858754, 1.05841360919316, 0.105841360919316,
                                      0.0212636349750834, "contNormal", 100, 1.72889718286736, 2.03296079621,
                                      1.53241112621044, 0.153241112621044, 2.33702440955264, "contGamma"
                                 ))
})

test_that("Equivalence Bayesian Paired Samples T-Test table results match", {
  table <- results[["results"]][["equivalenceBayesianPairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(2.7704775513063, 6.31453935561698e-06, "-", "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (inside vs. all)", "contNormal", "contGamma", 0.00497214808231404,
                                      0.00351845706160769, " ", "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (outside vs. all)", " ", " ", 557.199324203738,
                                      6.2793649495455e-08, " ", "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "Non-overlapping (inside vs. outside)", " ", " "))
})

test_that("Equivalence Mass Table results match", {
  table <- results[["results"]][["equivalenceMassPairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.996816829013877, 0.359799641236534, "<unicode> <unicode> I",
                                      "-", "contNormal", "contGamma", 0.00318317098612253, 0.640200358763466,
                                      "<unicode> <unicode> I", " ", " ", " "))
})

test_that("contNormal - contGamma plot matches", {
  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_contNormal - contGamma"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal-contgamma", dir="EquivalenceBayesianPairedSamplesTTest")
})

# The paired analysis must use the paired t statistic (an earlier version used the independent samples t).
# Reference values: BayesFactor::ttestBF(x, y, paired = TRUE, rscale = 0.707, nullInterval = c(-0.5, 0.5)), e.g.
# BF(inside vs. outside) = 2936.24 (the independent samples t gave 5094.69).
optionsPairedT <- jaspTools::analysisOptions("EquivalenceBayesianPairedSamplesTTest")
optionsPairedT$lowerbound <- -0.5
optionsPairedT$upperbound <- 0.5
optionsPairedT$massPriorPosterior <- TRUE
optionsPairedT$pairs <- list(c("contNormal", "contcor1"))
resultsPairedT <- jaspTools::runAnalysis("EquivalenceBayesianPairedSamplesTTest", "test.csv", optionsPairedT)

test_that("Paired t statistic: Bayesian paired samples table results match BayesFactor::ttestBF", {
  table <- resultsPairedT[["results"]][["equivalenceBayesianPairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(2.55050648882645, 2.24083559592818e-05, "-", "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (inside vs. all)", "contNormal", "contcor1", 0.000868628853380205,
                                      0.0657964066651434, " ", "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (outside vs. all)", " ", " ", 2936.24426462619,
                                      3.89290890860929e-08, " ", "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "Non-overlapping (inside vs. outside)", " ", " "))
})

test_that("Paired t statistic: Equivalence Mass Table results match", {
  table <- resultsPairedT[["results"]][["equivalenceMassPairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.999471762364887, 0.391871875936597, "<unicode> <unicode> I",
                                      "-", "contNormal", "contcor1", 0.000528237635113449, 0.608128124063403,
                                      "<unicode> <unicode> I", " ", " ", " "))
})

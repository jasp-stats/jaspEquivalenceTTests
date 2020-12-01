options <- jaspTools::analysisOptions("EquivalenceBayesianPairedSamplesTTest")
options$descriptives <- TRUE
options$massPriorPosterior <- TRUE
options$priorandposterior <- TRUE
options$plotSequentialAnalysis <- TRUE
options$plotSequentialAnalysisRobustness <- TRUE
options$pairs <- list(c("contNormal", "contGamma"))

set.seed(1)

results <- runAnalysis("EquivalenceBayesianPairedSamplesTTest", "test.csv", options)

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
                                 list(3.47730636520188e-10, 317024.273844527, "-", "<unicode> <unicode> I vs. H<unicode>",
                                      "contNormal", "contGamma", 1.04706316347092, 0.000105284051986773,
                                      " ", "<unicode> <unicode> I vs. H<unicode>", " ", " ", 3.32100916784706e-10,
                                      663888.878137445, " ", "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      " ", " ", 3011132910.08552, 7.32209808255702e-14, " ", "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      " ", " "))
})

test_that("Prior and Posterior Mass table results match", {
  table <- results[["results"]][["equivalenceMassPairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.0449477788241001, "p(<unicode> <unicode> I | H<unicode>)", "-",
                                      "contNormal", "contGamma", 1.5629719740673e-11, "p(<unicode> <unicode> I | H<unicode>, data)",
                                      " ", " ", " ", 0.9550522211759, "p(<unicode> <unicode> I | H<unicode>)",
                                      " ", " ", " ", 0.99999999998437, "p(<unicode> <unicode> I | H<unicode>, data)",
                                      " ", " ", " "))
})

test_that("contNormal - contGamma plot matches", {
  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_contNormal - contGamma"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal-contgamma", dir="EquivalenceBayesianPairedSamplesTTest")
})

# check .hasErrors()

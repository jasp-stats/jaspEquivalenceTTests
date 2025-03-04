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
                                 list(2.76007174511518, 2.71359624686912e-06, "-", "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (inside vs. all)", "contNormal", "contGamma", 0.0108203255834508,
                                      0.000692189922647916, " ", "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (outside vs. all)", " ", " ", 255.08213443564,
                                      5.87239897863078e-08, " ", "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "Non-overlapping (inside vs. outside)", " ", " "))
})

test_that("Equivalence Mass Table results match", {
  table <- results[["results"]][["equivalenceMassPairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.993072823679537, 0.359799641236534, "<unicode> <unicode> I",
                                      "-", "contNormal", "contGamma", 0.00692717632046269, 0.640200358763466,
                                      "<unicode> <unicode> I", " ", " ", " "))
})

test_that("contNormal - contGamma plot matches", {
  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_contNormal - contGamma"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal-contgamma", dir="EquivalenceBayesianPairedSamplesTTest")
})

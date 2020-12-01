options <- analysisOptions("EquivalencePairedSamplesTTest")
options$descriptives <- TRUE
options$equivalenceboundsplot <- TRUE
options$pairs <- list(c("contNormal", "contGamma"))
set.seed(1)
results <- runAnalysis("EquivalencePairedSamplesTTest", "test.csv", options)

test_that("contNormal - contGamma plot matches", {
  plotName <- results[["results"]][["equivalencePairedBoundsContainer"]][["collection"]][["equivalencePairedBoundsContainer_contNormal - contGamma"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal-contgamma", dir="EquivalencePairedSamplesTTest")
})

test_that("Equivalence Bounds table results match", {
  table <- results[["results"]][["equivalencePairedBoundsTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.05, -0.05, -1.37211873031366, "-", "Cohen's d", -0.945815231401643,
                                      "contNormal", "contGamma", 0.0956629548867044, -0.0956629548867044,
                                      -2.53938523225467, "", "Raw", -1.90403353524533, "", ""))
})

test_that("Descriptives table results match", {
  table <- results[["results"]][["equivalencePairedDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(100, "contNormal", -0.18874858754, 1.05841360919316, 0.105841360919316,
                                      100, "contGamma", 2.03296079621, 1.53241112621044, 0.153241112621044
                                 ))
})

test_that("Equivalence Paired Samples T-Test table results match", {
  table <- results[["results"]][["equivalencePairedTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(99, 3.4809614504484e-20, "-", "T-Test", -11.6121720596087, "contNormal",
                                      "contGamma", 99, 1.47774434503596e-21, "", "Upper bound", -12.1121720596087,
                                      "", "", 99, 1, "", "Lower bound", -11.1121720596087, "", ""
                                 ))
})

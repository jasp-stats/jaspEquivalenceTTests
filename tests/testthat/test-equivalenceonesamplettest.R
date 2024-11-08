options <- jaspTools::analysisOptions("EquivalenceOneSampleTTest")
options$variables <- "contGamma"
options$descriptives <- TRUE
options$equivalenceboundsplot <- TRUE
set.seed(1)
results <- jaspTools::runAnalysis("EquivalenceOneSampleTTest", "test.csv", options)

test_that("contGamma plot matches", {
  plotName <- results[["results"]][["equivalenceOneBoundsContainer"]][["collection"]][["equivalenceOneBoundsContainer_contGamma"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contgamma", dir="EquivalenceOneSampleTTest")
})

test_that("Equivalence Bounds table results match", {
  table <- results[["results"]][["equivalenceOneBoundsTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.05, -0.05, 1.10939084832605, "Cohen's d", 1.56510767251645,
                                      "contGamma", 0.0766205563105218, -0.0766205563105218, 1.77852060807581,
                                      "Raw", 2.28740098434418, "contGamma"))
})

test_that("Descriptives table results match", {
  table <- results[["results"]][["equivalenceOneDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(100, 2.03296079621, 1.53241112621044, 0.153241112621044, "contGamma"
                                 ))
})

test_that("Equivalence One Sample T-Test table results match", {
  table <- results[["results"]][["equivalenceOneTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(99, 1.08315413981152e-23, "T-Test", 13.2664189226908, "contGamma",
                                      99, 4.97392579208359e-25, "Upper bound", 13.7664189226908, "contGamma",
                                      99, 1, "Lower bound", 12.7664189226908, "contGamma"))
})

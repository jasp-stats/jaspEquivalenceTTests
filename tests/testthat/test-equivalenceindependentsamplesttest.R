options <- analysisOptions("EquivalenceIndependentSamplesTTest")
options$variables <- "contNormal"
options$groupingVariable <- "contBinom"
options$descriptives <- TRUE
options$equivalenceboundsplot <- TRUE
set.seed(1)
results <- runAnalysis("EquivalenceIndependentSamplesTTest", "test.csv", options)


test_that("contNormal plot matches", {
  plotName <- results[["results"]][["equivalenceBoundsContainer"]][["collection"]][["equivalenceBoundsContainer_contNormal"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal", dir="EquivalenceIndependentSamplesTTest")
})

test_that("Equivalence Bounds table results match", {
  table <- results[["results"]][["equivalenceBoundsTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.05, -0.05, -0.180126797550567, "Cohen's d", 0.487380845343539,
                                      "contNormal", 0.0530338698488416, -0.0530338698488416, -0.193495020233012,
                                      "Raw", 0.520223461720696, ""))
})

test_that("Descriptives table results match", {
  table <- results[["results"]][["equivalenceDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(58, 0, -0.120135614827586, 1.10575982846952, 0.145193378675912,
                                      "contNormal", 42, 1, -0.283499835571428, 0.994612407217046,
                                      0.15347202634745, "contNormal"))
})

test_that("Equivalence Independent Samples T-Test table results match", {
  table <- results[["results"]][["equivalenceIndTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(98, 0.448976320466698, "T-Test", 0.760172707980336, "contNormal",
                                      98, 0.695584187884492, "Upper bound", 0.513393454395275, "",
                                      98, 0.158218835873606, "Lower bound", 1.0069519615654, ""))
})

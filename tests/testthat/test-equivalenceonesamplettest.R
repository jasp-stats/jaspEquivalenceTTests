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
                                      99, 1, "Upper bound", 12.7664189226908, "contGamma",
                                      99, 4.97392579208359e-25, "Lower bound", 13.7664189226908, "contGamma"))
})

# the test value (mu) shifts the t-test and the bound tests; the equivalence bounds are differences from mu
# reference values from plain R, x = contGamma, mu = 1.8, bounds -0.3 and 0.3:
#   t.test(x, mu = 1.8), t.test(x, mu = 1.8 - 0.3, alternative = "greater"), t.test(x, mu = 1.8 + 0.3, alternative = "less"),
#   t.test(x - 1.8, conf.level = 0.9)$conf.int
optionsMu <- jaspTools::analysisOptions("EquivalenceOneSampleTTest")
optionsMu$variables <- "contGamma"
optionsMu$mu <- 1.8
optionsMu$boundstype <- "raw"
optionsMu$lowerbound <- -0.3
optionsMu$upperbound <- 0.3
optionsMu$descriptives <- TRUE
resultsMu <- jaspTools::runAnalysis("EquivalenceOneSampleTTest", "test.csv", optionsMu)

test_that("Equivalence One Sample T-Test table honours the test value", {
  table <- resultsMu[["results"]][["equivalenceOneTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(99, 0.131642180010755, "T-Test", 1.52022386307060, "contGamma",
                                      99, 0.331359782115875, "Upper bound", -0.437475313532762, "contGamma",
                                      99, 0.000376179770983911, "Lower bound", 3.47792303967396, "contGamma"))
})

test_that("Equivalence Bounds table (raw) is relative to the test value", {
  table <- resultsMu[["results"]][["equivalenceOneBoundsTable"]][["data"]]
  rawRow <- Filter(function(row) identical(row[["statistic"]], "Raw"), table)
  jaspTools::expect_equal_tables(rawRow,
                                 list(0.3, -0.3, -0.0214793919241846, "Raw", 0.487400984344185, "contGamma"))
})

test_that("Descriptives table is not shifted by the test value", {
  table <- resultsMu[["results"]][["equivalenceOneDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(100, 2.03296079621, 1.53241112621044, 0.153241112621044, "contGamma"))
})

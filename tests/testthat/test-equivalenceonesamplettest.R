options <- jaspTools::analysisOptions("EquivalenceOneSampleTTest")
options$boundstype <- "cohensD"
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

test_that("Nonzero test values are honored with raw and standardized bounds", {
  x <- 1:5
  dataset <- data.frame(score = c(x, NA))
  se <- sd(x) / sqrt(length(x))
  for (boundsType in c("raw", "cohensD")) {
    options <- jaspTools::analysisOptions("EquivalenceOneSampleTTest")
    options$variables <- "score"
    options$mu <- 3
    options$boundstype <- boundsType
    options$lowerbound <- if (boundsType == "raw") 2.5 else -0.5
    options$upperbound <- if (boundsType == "raw") 3.5 else 0.5
    options$descriptives <- TRUE
    results <- jaspTools::runAnalysis("EquivalenceOneSampleTTest", dataset, options)

    reference <- stats::t.test(x, mu = 3)
    table <- results$results$equivalenceOneTTestTable$data
    expect_equal(table[[1]]$t, unname(reference$statistic))
    expect_equal(table[[1]]$p, reference$p.value)

    # Raw bounds are absolute means; standardized bounds are distances from mu.
    bounds <- if (boundsType == "raw") c(2.5, 3.5) else 3 + c(-0.5, 0.5) * sd(x)
    boundT <- (mean(x) - bounds) / se
    rows <- setNames(table, vapply(table, function(row) row$statistic, ""))
    expect_equal(rows[["Lower bound"]]$t, boundT[1])
    expect_equal(rows[["Lower bound"]]$p, stats::pt(boundT[1], 4, lower.tail = FALSE))
    expect_equal(rows[["Upper bound"]]$t, boundT[2])
    expect_equal(rows[["Upper bound"]]$p, stats::pt(boundT[2], 4))
    raw <- results$results$equivalenceOneBoundsTable$data[[2]]
    expect_equal(c(raw$low, raw$high), bounds)
    expect_equal(c(raw$lower, raw$upper), mean(x) + c(-1, 1) * stats::qt(0.95, 4) * se)
    descriptives <- results$results$equivalenceOneDescriptivesTable$data[[1]]
    expect_equal(c(descriptives$N, descriptives$mean, descriptives$sd, descriptives$se),
                 c(length(x), mean(x), sd(x), se))
  }
})

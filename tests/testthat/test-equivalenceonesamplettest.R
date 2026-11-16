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

test_that("Nonzero test values center the tests and intervals but preserve descriptives", {
  x <- 1:5
  dataset <- data.frame(score = c(x, NA))
  for (boundsType in c("raw", "cohensD")) {
    for (mu in c(3, -2)) {
      options <- jaspTools::analysisOptions("EquivalenceOneSampleTTest")
      options$variables <- "score"
      options$mu <- mu
      options$boundstype <- boundsType
      options$lowerbound <- -0.5
      options$upperbound <- 0.5
      options$descriptives <- TRUE
      options$equivalenceboundsplot <- TRUE
      results <- jaspTools::runAnalysis("EquivalenceOneSampleTTest", dataset, options)

      reference <- stats::t.test(x, mu = mu)
      se <- stats::sd(x) / sqrt(length(x))
      bounds <- c(-0.5, 0.5) * if (boundsType == "raw") 1 else stats::sd(x)
      boundT <- (mean(x) - mu - bounds) / se
      table <- results$results$equivalenceOneTTestTable$data
      expect_equal(vapply(table, function(row) row$t, 0), c(unname(reference$statistic), boundT))
      expect_equal(vapply(table, function(row) row$p, 0),
                   c(reference$p.value, stats::pt(boundT[1], 4, lower.tail = FALSE), stats::pt(boundT[2], 4)))

      rawInterval <- results$results$equivalenceOneBoundsTable$data[[2]]
      expect_equal(c(rawInterval$lower, rawInterval$upper), mean(x) - mu + c(-1, 1) * stats::qt(0.95, 4) * se)
      descriptives <- results$results$equivalenceOneDescriptivesTable$data[[1]]
      expect_equal(c(descriptives$N, descriptives$mean, descriptives$sd, descriptives$se),
                   c(length(x), mean(x), stats::sd(x), se))

      plotName <- results$results$equivalenceOneBoundsContainer$collection$equivalenceOneBoundsContainer_score$data
      plot <- results$state$figures[[plotName]]$obj
      plot$data <- plot$data[1, , drop = FALSE]
      point <- unique(ggplot2::ggplot_build(plot)$data[[3]]$y)
      interval <- results$results$equivalenceOneBoundsTable$data[[if (boundsType == "raw") 2 else 1]]
      expect_equal(point, mean(c(interval$lower, interval$upper)))
    }
  }
})

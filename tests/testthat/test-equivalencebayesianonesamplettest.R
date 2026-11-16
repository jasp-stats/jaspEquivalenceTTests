options <- jaspTools::analysisOptions("EquivalenceBayesianOneSampleTTest")
options$variables <- "contNormal"
options$descriptives <- TRUE
options$massPriorPosterior <- TRUE
options$priorandposterior <- TRUE
options$plotSequentialAnalysis <- TRUE
options$plotSequentialAnalysisRobustness <- TRUE

set.seed(1)
results <- jaspTools::runAnalysis("EquivalenceBayesianOneSampleTTest", "test.csv", options)

test_that("Descriptives table results match", {
  table <- results[["results"]][["equivalenceBayesianDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(100, -0.398760810055084, -0.18874858754, 1.05841360919316, 0.105841360919316,
                                      0.0212636349750834, "contNormal"))
})

test_that("Equivalence Bayesian One Sample T-Test table results match", {
  table <- results[["results"]][["equivalenceBayesianOneTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(2.13498419802031, 4.14303689584495e-05, "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (inside vs. all)", "contNormal", 0.94658405313308,
                                      9.34446156700733e-05, "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (outside vs. all)", "contNormal", 2.25546182713914,
                                      7.84346531429762e-05, "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "Non-overlapping (inside vs. outside)", "contNormal"))
})

test_that("Prior and Posterior Mass Table results match", {
  table <- results[["results"]][["equivalenceMassTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.0959627975255657, 0.0449477788241001, "<unicode> <unicode> I",
                                      "contNormal", 0.904037202474434, 0.9550522211759, "<unicode> <unicode> I",
                                      "contNormal"))
})
test_that("contNormal plot matches", {
  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_contNormal"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal", dir="EquivalenceBayesianOneSampleTTest")
})

test_that("Bayesian one sample test values match centered data", {
  dataset <- data.frame(score = c(1:5, NA))
  for (mu in c(3, -2)) {
    options <- jaspTools::analysisOptions("EquivalenceBayesianOneSampleTTest")
    options$variables <- "score"
    options$mu <- mu
    options$lowerbound <- -0.5
    options$upperbound <- 0.5
    options$massPriorPosterior <- TRUE
    options$plotSequentialAnalysis <- TRUE
    results <- jaspTools::runAnalysis("EquivalenceBayesianOneSampleTTest", dataset, options)

    centeredDataset <- dataset
    centeredDataset$score <- centeredDataset$score - mu
    options$mu <- 0
    centered <- jaspTools::runAnalysis("EquivalenceBayesianOneSampleTTest", centeredDataset, options)
    table <- results$results$equivalenceBayesianOneTTestTable$data
    centeredTable <- centered$results$equivalenceBayesianOneTTestTable$data
    expect_equal(vapply(table, function(row) row$bf, 0), vapply(centeredTable, function(row) row$bf, 0))
    expect_equal(results$results$equivalenceMassTable$data, centered$results$equivalenceMassTable$data)

    plotName <- results$results$equivalenceSequentialContainer$collection$equivalenceSequentialContainer_score$data
    centeredPlotName <- centered$results$equivalenceSequentialContainer$collection$equivalenceSequentialContainer_score$data
    plotData <- lapply(results$state$figures[[plotName]]$obj$subplots, function(plot) plot$data)
    centeredPlotData <- lapply(centered$state$figures[[centeredPlotName]]$obj$subplots, function(plot) plot$data)
    expect_equal(plotData, centeredPlotData)
  }
})

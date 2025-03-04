options <- jaspTools::analysisOptions("EquivalenceBayesianIndependentSamplesTTest")
options$variables <- "contNormal"
options$groupingVariable <- "contBinom"
options$descriptives <- TRUE
options$massPriorPosterior <- TRUE
options$priorandposterior <- TRUE
options$plotSequentialAnalysis <- TRUE
options$plotSequentialAnalysisRobustness <- TRUE
set.seed(1)
results <- jaspTools::runAnalysis("EquivalenceBayesianIndependentSamplesTTest", "test.csv", options)

test_that("Descriptives table results match", {
  table <- results[["results"]][["equivalenceBayesianDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(58, 0, -0.410880340543859, -0.120135614827586, 1.10575982846952,
                                      0.145193378675912, 0.170609110888686, "contNormal", 42, 1, -0.593442880596763,
                                      -0.283499835571428, 0.994612407217046, 0.15347202634745, 0.0264432094539058,
                                      "contNormal"))
})

test_that("Equivalence Bayesian Independent Samples T-Test table results match", {
  table <- results[["results"]][["equivalenceBayesianIndTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(3.61383711052232, 7.45693541923696e-06, "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (inside vs. all)", "contNormal", 0.876984556738344,
                                      3.07281921235097e-05, "<unicode> <unicode> I vs. H<unicode>",
                                      "Overlapping (outside vs. all)", "contNormal", 4.12075341892314,
                                      1.3079234406532e-05, "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "Non-overlapping (inside vs. outside)", "contNormal"))
})

test_that("Prior and Posterior Mass Table results match", {
  table <- results[["results"]][["equivalenceMassTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.162433951150082, 0.0449477788241001, "<unicode> <unicode> I",
                                      "contNormal", 0.837566048849918, 0.9550522211759, "<unicode> <unicode> I",
                                      "contNormal"))
})

test_that("contNormal plot matches", {
  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_contNormal"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal", dir = "EquivalenceBayesianIndependentSamplesTTest")
})

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
                                 list(3.61383711052235, 7.45693549562363e-06, "<unicode> <unicode> I vs. H<unicode>",
                                      "contNormal", 0.876984556738343, 3.07281924382806e-05, "<unicode> <unicode> I vs. H<unicode>",
                                      "contNormal", 4.12075341892317, 1.30792345405118e-05, "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "contNormal", 0.242674069117516, 0.000222093364345461, "<unicode> <unicode> I vs. <unicode> <unicode> I",
                                      "contNormal"))
})

test_that("Prior and Posterior Mass table results match", {
  table <- results[["results"]][["equivalenceMassTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
                                 list(0.0449477788241001, "p(<unicode> <unicode> I | H<unicode>)", "contNormal",
                                      0.162433951150083, "p(<unicode> <unicode> I | H<unicode>, data)",
                                      "contNormal", 0.9550522211759, "p(<unicode> <unicode> I | H<unicode>)",
                                      "contNormal", 0.837566048849917, "p(<unicode> <unicode> I | H<unicode>, data)",
                                      "contNormal"))
})

test_that("contNormal plot matches", {
  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_contNormal"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "contnormal", dir="EquivalenceBayesianIndependentSamplesTTest")
})

# check .hasErrors()

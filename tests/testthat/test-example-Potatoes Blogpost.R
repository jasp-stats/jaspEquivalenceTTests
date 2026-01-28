context("Example: Potatoes Blogpost")

# This test file was auto-generated from a JASP example file.
# The JASP file is stored in the module's examples/ folder.

test_that("EquivalenceBayesianOneSampleTTest (analysis 3) results match", {

  # Load from JASP example file
  jaspFile <- testthat::test_path("..", "..", "examples", "Potatoes Blogpost.jasp")
  opts <- jaspTools::analysisOptions(jaspFile)[[3]]
  dataset <- jaspTools::extractDatasetFromJASPFile(jaspFile)

  # Encode and run analysis
  encoded <- jaspTools:::encodeOptionsAndDataset(opts, dataset)
  set.seed(1)
  results <- jaspTools::runAnalysis("EquivalenceBayesianOneSampleTTest", encoded$dataset, encoded$options, encodedDataset = TRUE)

  table <- results[["results"]][["equivalenceBayesianDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(20, 1020.15491059877, 1026.66666666667, 13.9135803910515, 3.11117115647994,
     1033.17842273456, "jaspColumn1"))

  table <- results[["results"]][["equivalenceBayesianOneTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(1.99999994065344, 7.98219330199393e-06, "<unicode> <unicode> I vs. H<unicode>",
     "Overlapping (inside vs. all)", "jaspColumn1", 5.93465612208633e-08,
     269.0027156057, "<unicode> <unicode> I vs. H<unicode>", "Overlapping (outside vs. all)",
     "jaspColumn1", 33700350.9472144, 9.47431446947096e-13, "<unicode> <unicode> I vs. <unicode> <unicode> I",
     "Non-overlapping (inside vs. outside)", "jaspColumn1"))

  table <- results[["results"]][["equivalenceMassTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(0.999999970326719, 0.5, "<unicode> <unicode> I", "jaspColumn1",
     2.96732806104316e-08, 0.5, "<unicode> <unicode> I", "jaspColumn1"
    ))

  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_jaspColumn1"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "analysis-3_figure-1_jaspcolumn1")

})

test_that("EquivalenceBayesianOneSampleTTest (analysis 4) results match", {

  # Load from JASP example file
  jaspFile <- testthat::test_path("..", "..", "examples", "Potatoes Blogpost.jasp")
  opts <- jaspTools::analysisOptions(jaspFile)[[4]]
  dataset <- jaspTools::extractDatasetFromJASPFile(jaspFile)

  # Encode and run analysis
  encoded <- jaspTools:::encodeOptionsAndDataset(opts, dataset)
  set.seed(1)
  results <- jaspTools::runAnalysis("EquivalenceBayesianOneSampleTTest", encoded$dataset, encoded$options, encodedDataset = TRUE)

  table <- results[["results"]][["equivalenceBayesianDescriptivesTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(20, 1020.15491059877, 1026.66666666667, 13.9135803910515, 3.11117115647994,
     1033.17842273456, "jaspColumn1"))

  table <- results[["results"]][["equivalenceBayesianOneTTestTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(1.99999994074939, 7.9731533922317e-06, "<unicode> <unicode> I vs. H<unicode>",
     "Overlapping (inside vs. all)", "jaspColumn1", 5.92506101959601e-08,
     269.133199798446, "<unicode> <unicode> I vs. H<unicode>", "Overlapping (outside vs. all)",
     "jaspColumn1", 33754925.6308884, 9.44828407351434e-13, "<unicode> <unicode> I vs. <unicode> <unicode> I",
     "Non-overlapping (inside vs. outside)", "jaspColumn1"))

  table <- results[["results"]][["equivalenceMassTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(0.999999970374695, 0.5, "<unicode> <unicode> I", "jaspColumn1",
     2.962530509798e-08, 0.5, "<unicode> <unicode> I", "jaspColumn1"
    ))

  plotName <- results[["results"]][["equivalencePriorPosteriorContainer"]][["collection"]][["equivalencePriorPosteriorContainer_jaspColumn1"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "analysis-4_figure-1_jaspcolumn1")

})


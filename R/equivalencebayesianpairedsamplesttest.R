#
# Copyright (C) 2013-2018 University of Amsterdam
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

EquivalenceBayesianPairedSamplesTTest <- function(jaspResults, dataset, options) {

  ready <- (length(options$pairs) > 0)

  for (pair in options$pairs) {
    if (pair[[1L]] == "" || pair[[2L]] == "")
      ready <- FALSE
  }

  # Read dataset and error checking
  if (ready) {
    dataset <- .ttestReadData(dataset, options, "paired")
    errors  <- .ttestBayesianGetErrorsPerVariable(dataset, options, "paired")
  }

  # Dispatch bounds options
  options <- .equivalenceBayesianBoundsDispatch(options)

  # Compute the results
  equivalenceBayesianPairedTTestResults <- .equivalenceBayesianPairedTTestComputeResults(jaspResults, dataset, options, ready, errors)

  # Output tables and plots
  .equivalenceBayesianPairedTTestTableMain(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready)

  if(options$descriptives && is.null(jaspResults[["equivalenceBayesianDescriptivesTable"]]))
    .equivalenceBayesianPairedTTestTableDescriptives(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready)

  if (options$priorandposterior && is.null(jaspResults[["equivalencePriorPosteriorContainer"]]))
    .equivalencePriorandPosterior(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready, paired = TRUE)

  if (options$plotSequentialAnalysis && is.null(jaspResults[["equivalenceSequentialContainer"]]))
     .equivalencePlotSequentialAnalysis(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready, paired = TRUE)

  if (options$massPriorPosterior && is.null(jaspResults[["equivalenceMassPairedTTestTable"]]))
    .massPriorPosteriorPairedTTestTable(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready)

  return()
}

.equivalenceBayesianPairedTTestComputeResults <- function(jaspResults, dataset, options, ready, errors) {

  if (!ready)
    return(list())

  if (!is.null(jaspResults[["stateEquivalenceBayesianPairedTTestResults"]]))
    return(jaspResults[["stateEquivalenceBayesianPairedTTestResults"]]$object)

  results <- list()

  for (pair in options$pairs) {

    namePair <- paste(pair[[1L]], " - ",  pair[[2L]], sep = "")

    results[[namePair]] <- list()

    if (!isFALSE(errors[[namePair]])) {
      errorMessage <- errors[[namePair]]$message
      results[[namePair]][["status"]] <- "error"
      results[[namePair]][["errorFootnotes"]] <- errorMessage
    } else {
      subDataSet <- dataset[, c(pair[[1L]], pair[[2L]])]
      subDataSet <- subDataSet[complete.cases(subDataSet), ]

      x <- subDataSet[[1L]]
      y <- subDataSet[[2L]]

      # Calculate SD of differences
      differences <- x - y
      sd_diff <- sd(differences)

      # Convert bounds and priors if needed
      optionsConverted <- .equivalenceBayesianConvertRawToSMD(options, sd_diff)

      # Store SD for footnote
      results[[namePair]][["sd"]] <- sd_diff

      # Store converted options for plotting functions
      results[[namePair]][["optionsConverted"]] <- optionsConverted

      r <- try(.generalEquivalenceTtestBF(x       = x,
                                          y       = y,
                                          paired  = TRUE,
                                          options = optionsConverted))

      if (isTryError(r)) {

        errorMessage <- .extractErrorMessage(r)
        results[[namePair]][["status"]]         <- "error"
        results[[namePair]][["errorFootnotes"]] <- errorMessage

      } else if (r[["bfEquivalence"]] < 0 || r[["bfNonequivalence"]] < 0) {

        results[[namePair]][["status"]] <- "error"
        results[[namePair]][["errorFootnotes"]] <- "Not able to calculate Bayes factor while the integration was too unstable"

      } else {

        results[[namePair]][["bfEquivalence"]]                   <- r[["bfEquivalence"]]
        results[[namePair]][["bfNonequivalence"]]                <- r[["bfNonequivalence"]]
        results[[namePair]][["errorPrior"]]                      <- r[["errorPrior"]]
        results[[namePair]][["errorPosterior"]]                  <- r[["errorPosterior"]]
        results[[namePair]][["tValue"]]                          <- r[["tValue"]]
        results[[namePair]][["n1"]]                              <- r[["n1"]]
        results[[namePair]][["n2"]]                              <- r[["n2"]]
        results[[namePair]][["integralEquivalencePosterior"]]    <- r[["integralEquivalencePosterior"]]
        results[[namePair]][["integralEquivalencePrior"]]        <- r[["integralEquivalencePrior"]]
        results[[namePair]][["integralNonequivalencePosterior"]] <- r[["integralNonequivalencePosterior"]]
        results[[namePair]][["integralNonequivalencePrior"]]     <- r[["integralNonequivalencePrior"]]
      }
    }
  }

  # Save results to state
  jaspResults[["stateEquivalenceBayesianPairedTTestResults"]] <- createJaspState(results)
  jaspResults[["stateEquivalenceBayesianPairedTTestResults"]]$dependOn(c("pairs", "missingValues", .equivalenceRegionDependencies, .equivalencePriorDependencies))
  return(results)
}

.equivalenceBayesianPairedTTestTableMain <- function(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready) {

  if(!is.null(jaspResults[["equivalenceBayesianPairedTTestTable"]])) return()

  # Create table
  equivalenceBayesianPairedTTestTable <- createJaspTable(title = gettext("Equivalence Bayesian Paired Samples T-Test"))
  equivalenceBayesianPairedTTestTable$dependOn(c("pairs", "missingValues", .equivalenceRegionDependencies, .equivalencePriorDependencies, "bayesFactorType"))
  equivalenceBayesianPairedTTestTable$position <- 1
  equivalenceBayesianPairedTTestTable$showSpecifiedColumnsOnly <- TRUE

  hypothesis <- switch(options[["alternative"]], "twoSided" = "equal", "greater" = "greater", "less" = "smaller")
  bfTitle <- jaspTTests:::.ttestBayesianGetBFTitle(bfType  = options[["bayesFactorType"]], hypothesis = hypothesis)

  # Add Columns to table
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "variable1",   title = " ",                         type = "string")
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "separator",   title = " ",                         type = "separator")
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "variable2",   title = " ",                         type = "string")
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "type",        title = gettext("Type"),             type = "string")
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "statistic",   title = gettext("Model Comparison"), type = "string")
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "bf",          title = bfTitle,                     type = "number")
  equivalenceBayesianPairedTTestTable$addColumnInfo(name = "error",       title = gettextf("error %%"),        type = "number")

  if (ready)
    equivalenceBayesianPairedTTestTable$setExpectedSize(length(options$pairs))

  # Add scale-specific footnote
  .addEquivalenceBayesianScaleFootnotes(equivalenceBayesianPairedTTestTable, options)

  jaspResults[["equivalenceBayesianPairedTTestTable"]] <- equivalenceBayesianPairedTTestTable

  if (!ready)
    return()

  .equivelanceBayesianPairedTTestFillTableMain(equivalenceBayesianPairedTTestTable, dataset, options, equivalenceBayesianPairedTTestResults)

  return()

}

.equivelanceBayesianPairedTTestFillTableMain <- function(equivalenceBayesianPairedTTestTable, dataset, options, equivalenceBayesianPairedTTestResults) {

  for (pair in options$pairs) {

    namePair <- paste(pair[[1L]], " - ",  pair[[2L]], sep = "")
    results <- equivalenceBayesianPairedTTestResults[[namePair]]

    if (!is.null(results$status)) {
      equivalenceBayesianPairedTTestTable$addFootnote(message = results$errorFootnotes, rowNames = namePair, colNames = "statistic")
      equivalenceBayesianPairedTTestTable$addRows(list(variable1 = pair[[1L]], separator = "-", variable2 = pair[[2L]], statistic = NaN), rowNames = namePair)
    } else {
      error_in_alt <- (results$errorPrior + results$errorPosterior) / results$bfEquivalence
      bfEquivalence <- .recodeBFtype(
        bfOld     = results$bfEquivalence,
        newBFtype = options[["bayesFactorType"]],
        oldBFtype = "BF10"
      )
      equivalenceBayesianPairedTTestTable$addRows(list(variable1     = pair[[1L]],
                                                       separator     = "-",
                                                       variable2     = pair[[2L]],
                                                       type          = gettextf("Overlapping (%1$s vs. %2$s)",
                                                                                if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("inside") else gettext("all"),
                                                                                if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("all")    else gettext("inside")),
                                                       statistic     = "\U003B4 \U02208 I vs. H\u2081",
                                                       bf            = bfEquivalence,
                                                       error         = ifelse(error_in_alt == Inf, "NA", error_in_alt)))

      error_notin_alt <- (results$errorPrior + results$errorPosterior) / results$bfNonequivalence
      bfNonequivalence <- .recodeBFtype(
        bfOld     = results$bfNonequivalence,
        newBFtype = options[["bayesFactorType"]],
        oldBFtype = "BF10"
      )
      equivalenceBayesianPairedTTestTable$addRows(list(variable1     = " ",
                                                       separator     = " ",
                                                       variable2     = " ",
                                                       type          = gettextf("Overlapping (%1$s vs. %2$s)",
                                                                                if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("outside") else gettext("all"),
                                                                                if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("all")     else gettext("outside")),
                                                       statistic     = "\U003B4 \U02209 I vs. H\u2081",
                                                       bf            = bfNonequivalence,
                                                       error         = ifelse(error_notin_alt == Inf, "NA", error_notin_alt)))

      error_in_notin <- (2*(results$errorPrior + results$errorPosterior)) / (results$bfEquivalence / results$bfNonequivalence)
      bfNonoverlapping <- .recodeBFtype(
        bfOld     = results$bfEquivalence / results$bfNonequivalence,
        newBFtype = options[["bayesFactorType"]],
        oldBFtype = "BF10"
      )
      equivalenceBayesianPairedTTestTable$addRows(list(variable1     = " ",
                                                       separator     = " ",
                                                       variable2     = " ",
                                                       type          = gettextf("Non-overlapping (%1$s vs. %2$s)",
                                                                                if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("inside")  else gettext("outside"),
                                                                                if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("outside") else gettext("inside")),
                                                       statistic     = "\U003B4 \U02208 I vs. \U003B4 \U02209 I",
                                                       bf            = bfNonoverlapping,
                                                       error         = ifelse(error_in_notin == Inf, "NA", error_in_notin)))

      # Add per-variable footnotes for raw scale
      .addEquivalenceBayesianScaleFootnotes(equivalenceBayesianPairedTTestTable, options,
                                            sd_val = results$sd, rowName = namePair)
    }
  }

  return()
}

.equivalenceBayesianPairedTTestTableDescriptives <- function(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready) {

  # Create table
  equivalenceBayesianDescriptivesTable <- createJaspTable(title = gettext("Descriptives"))
  equivalenceBayesianDescriptivesTable$dependOn(c("pairs", "descriptives", "missingValues"))
  equivalenceBayesianDescriptivesTable$position <- 2
  equivalenceBayesianDescriptivesTable$showSpecifiedColumnsOnly <- TRUE

  # Add Columns to table
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "variable",   title = " ",                  type = "string")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "N",          title = gettext("N"),         type = "integer")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "mean",       title = gettext("Mean"),      type = "number")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "sd",         title = gettext("SD"),        type = "number")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "se",         title = gettext("SE"),        type = "number")

  title    <- gettextf("95%% Credible Interval")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "lowerCI", type = "number", format = "sf:4;dp:3", title = gettext("Lower"), overtitle = title)
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "upperCI", type = "number", format = "sf:4;dp:3", title = gettext("Upper"), overtitle = title)

  jaspResults[["equivalenceBayesianDescriptivesTable"]] <- equivalenceBayesianDescriptivesTable

  vars <- unique(unlist(options$pairs))

  for (var in vars) {

    data <- na.omit(dataset[[ var ]])
    n    <- length(data)
    mean <- mean(data)
    med  <- median(data)
    sd   <- sd(data)
    se   <- sd/sqrt(n)

    posteriorSummary <- jaspTTests::.posteriorSummaryGroupMean(variable = data, descriptivesPlotsCredibleInterval = 0.95)
    ciLower <- .clean(posteriorSummary[["ciLower"]])
    ciUpper <- .clean(posteriorSummary[["ciUpper"]])

    equivalenceBayesianDescriptivesTable$addRows(list(variable      = var,
                                                      N             = n,
                                                      mean          = mean,
                                                      sd            = sd,
                                                      se            = se,
                                                      lowerCI       = ciLower,
                                                      upperCI       = ciUpper))
  }

  return()
}

.massPriorPosteriorPairedTTestTable <- function(jaspResults, dataset, options, equivalenceBayesianPairedTTestResults, ready) {

  # Create table
  equivalenceMassPairedTTestTable <- createJaspTable(title = gettext("Equivalence Mass Table"))
  equivalenceMassPairedTTestTable$dependOn(c("pairs", "missingValues", "massPriorPosterior",  .equivalenceRegionDependencies, .equivalencePriorDependencies))
  equivalenceMassPairedTTestTable$position <- 3
  equivalenceMassPairedTTestTable$showSpecifiedColumnsOnly <- TRUE

  # Add Columns to table
  equivalenceMassPairedTTestTable$addColumnInfo(name = "variable1",     title = " ",                         type = "string")
  equivalenceMassPairedTTestTable$addColumnInfo(name = "separator",     title = " ",                         type = "separator")
  equivalenceMassPairedTTestTable$addColumnInfo(name = "variable2",     title = " ",                         type = "string")
  equivalenceMassPairedTTestTable$addColumnInfo(name = "section",       title = gettext("Section"),          type = "string")
  equivalenceMassPairedTTestTable$addColumnInfo(name = "priorMass",     title = gettext("Prior Mass"),       type = "number")
  equivalenceMassPairedTTestTable$addColumnInfo(name = "posteriorMass", title = gettext("Posterior Mass"),   type = "number")

  if (ready)
    equivalenceMassPairedTTestTable$setExpectedSize(length(options$pairs))

  jaspResults[["equivalenceMassPairedTTestTable"]] <- equivalenceMassPairedTTestTable

  if (!ready)
    return()

  .equivalenceMassFillPairedTableMain(equivalenceMassPairedTTestTable, dataset, options, equivalenceBayesianPairedTTestResults)

  return()
}

.equivalenceMassFillPairedTableMain <- function(equivalenceMassPairedTTestTable, dataset, options, equivalenceBayesianPairedTTestResults) {
  for (pair in options$pairs) {

    namePair <- paste(pair[[1L]], " - ",  pair[[2L]], sep = "")
    results <- equivalenceBayesianPairedTTestResults[[namePair]]

    if (!is.null(results$status)) {
      equivalenceMassPairedTTestTable$addFootnote(message = results$errorFootnotes, rowNames = namePair, colNames = "mass")
      equivalenceMassPairedTTestTable$addRows(list(variable1 = pair[[1L]], separator = "-", variable2 = pair[[2L]], priorMass = NaN, posteriorMass = NaN), rowNames = namePair)
    } else {
      equivalenceMassPairedTTestTable$addRows(list(variable1     = pair[[1L]],
                                                   separator     = "-",
                                                   variable2     = pair[[2L]],
                                                   section       = "\U003B4 \U02208 I",
                                                   priorMass     = results$integralEquivalencePrior,
                                                   posteriorMass = results$integralEquivalencePosterior))

      equivalenceMassPairedTTestTable$addRows(list(variable1     = " ",
                                                   separator     = " ",
                                                   variable2     = " ",
                                                   section       = "\U003B4 \U02209 I",
                                                   priorMass     = results$integralNonequivalencePrior,
                                                   posteriorMass = results$integralNonequivalencePosterior))

    }
  }
}

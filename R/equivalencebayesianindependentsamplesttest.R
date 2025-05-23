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

EquivalenceBayesianIndependentSamplesTTest <- function(jaspResults, dataset, options) {

  ready <- (length(options$variables) != 0 && options$groupingVariable != "")

  if (ready) {
    dataset <- .ttestReadData(dataset, options, "independent")
    errors  <- .ttestBayesianGetErrorsPerVariable(dataset, options, "independent")
  }

  # Dispatch bounds options
  options <- .equivalenceBayesianBoundsDispatch(options)

  # Compute the results
  equivalenceBayesianIndTTestResults <- .equivalenceBayesianIndTTestComputeResults(jaspResults, dataset, options, ready, errors)

  # Output tables and plots
  if (is.null(jaspResults[["equivalenceBayesianIndTTestTable"]]))
    .equivalenceBayesianIndTTestTableMain(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready)

  if (options$descriptives && is.null(jaspResults[["equivalenceBayesianDescriptivesTable"]]))
    .equivalenceBayesianIndTTestTableDescriptives(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready)

  if (options$priorandposterior && is.null(jaspResults[["equivalencePriorPosteriorContainer"]]))
    .equivalencePriorandPosterior(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready)

  if (options$plotSequentialAnalysis && is.null(jaspResults[["equivalenceSequentialContainer"]]))
    .equivalencePlotSequentialAnalysis(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready)

  if (options$massPriorPosterior && is.null(jaspResults[["equivalenceMassTable"]]))
    .massPriorPosteriorIndpTTestTable(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready)

  return()
}

.equivalenceBayesianIndTTestComputeResults <- function(jaspResults, dataset, options, ready, errors) {

  if (!ready)
    return(list())

  if (!is.null(jaspResults[["stateEquivalenceBayesianIndTTestResults"]]))
    return(jaspResults[["stateEquivalenceBayesianIndTTestResults"]]$object)

  results <- list()

  group  <- options$groupingVariable
  levels <- levels(dataset[[group]])
  g1     <- levels[1L]
  g2     <- levels[2L]

  idxg1  <- dataset[[group]] == g1
  idxg2  <- dataset[[group]] == g2
  idxNAg <- is.na(dataset[[group]])

  for (variable in options$variables) {

    results[[variable]] <- list()

    if(!isFALSE(errors[[variable]])) {

      errorMessage <- errors[[variable]]$message
      results[[variable]][["status"]] <- "error"
      results[[variable]][["errorFootnotes"]] <- errorMessage

    } else {

      # It is necessary to remove NAs
      idxNA      <- is.na(dataset[[variable]]) | idxNAg
      subDataSet <- dataset[!idxNA, variable]

      group1 <- subDataSet[idxg1[!idxNA]]
      group2 <- subDataSet[idxg2[!idxNA]]

      results[[variable]][["n1"]]     <- length(group1)
      results[[variable]][["n2"]]     <- length(group2)
      results[[variable]][["status"]] <- NULL

      r <- try(.generalEquivalenceTtestBF(x       = group1,
                                          y       = group2,
                                          options = options))

      if (isTryError(r)) {
        errorMessage <- .extractErrorMessage(r)
        results[[variable]][["status"]] <- "error"
        results[[variable]][["errorFootnotes"]] <- errorMessage

      } else if (r[["bfEquivalence"]] < 0 || r[["bfNonequivalence"]] < 0) {

        results[[variable]][["status"]] <- "error"
        results[[variable]][["errorFootnotes"]] <- "Not able to calculate Bayes factor while the integration was too unstable"

      } else {
        results[[variable]][["bfEquivalence"]]                   <- r[["bfEquivalence"]]
        results[[variable]][["bfNonequivalence"]]                <- r[["bfNonequivalence"]]
        results[[variable]][["errorPrior"]]                      <- r[["errorPrior"]]
        results[[variable]][["errorPosterior"]]                  <- r[["errorPosterior"]]
        results[[variable]][["tValue"]]                          <- r[["tValue"]]
        results[[variable]][["integralEquivalencePosterior"]]    <- r[["integralEquivalencePosterior"]]
        results[[variable]][["integralEquivalencePrior"]]        <- r[["integralEquivalencePrior"]]
        results[[variable]][["integralNonequivalencePosterior"]] <- r[["integralNonequivalencePosterior"]]
        results[[variable]][["integralNonequivalencePrior"]]     <- r[["integralNonequivalencePrior"]]
      }
    }

  }

  # Save results to state
  jaspResults[["stateEquivalenceBayesianIndTTestResults"]] <- createJaspState(results)
  jaspResults[["stateEquivalenceBayesianIndTTestResults"]]$dependOn(c("variables", "groupingVariable", "missingValues", .equivalenceRegionDependencies, .equivalencePriorDependencies))

  return(results)
}

.equivalenceBayesianIndTTestTableMain <- function(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready) {

  # Create table
  equivalenceBayesianIndTTestTable <- createJaspTable(title = gettext("Equivalence Bayesian Independent Samples T-Test"))
  equivalenceBayesianIndTTestTable$dependOn(c("variables", "groupingVariable", "missingValues", .equivalenceRegionDependencies, .equivalencePriorDependencies, "bayesFactorType"))
  equivalenceBayesianIndTTestTable$position <- 1

  hypothesis <- switch(options[["alternative"]], "twoSided" = "equal", "greater" = "greater", "less" = "smaller")
  bfTitle <- jaspTTests:::.ttestBayesianGetBFTitle(bfType  = options[["bayesFactorType"]], hypothesis = hypothesis)

  # Add Columns to table
  equivalenceBayesianIndTTestTable$addColumnInfo(name = "variable",   title = " ",                          type = "string", combine = TRUE)
  equivalenceBayesianIndTTestTable$addColumnInfo(name = "type",       title = gettext("Type"),              type = "string")
  equivalenceBayesianIndTTestTable$addColumnInfo(name = "statistic",  title = gettext("Model Comparison"),  type = "string")
  equivalenceBayesianIndTTestTable$addColumnInfo(name = "bf",         title = bfTitle,                      type = "number")
  equivalenceBayesianIndTTestTable$addColumnInfo(name = "error",      title = gettextf("error %%"),         type = "number")

  equivalenceBayesianIndTTestTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceBayesianIndTTestTable$setExpectedSize(length(options$variables))

  message <- gettextf("I ranges from %1$s to %2$s",
                      ifelse(options$lowerbound == -Inf, "-\u221E", options$lowerbound),
                      ifelse(options$upperbound == Inf, "\u221E", options$upperbound))
  equivalenceBayesianIndTTestTable$addFootnote(message)

  jaspResults[["equivalenceBayesianIndTTestTable"]] <- equivalenceBayesianIndTTestTable

  if (!ready)
    return()

  .equivelanceBayesianIndTTestFillTableMain(equivalenceBayesianIndTTestTable, dataset, options, equivalenceBayesianIndTTestResults)

  return()
}

.equivelanceBayesianIndTTestFillTableMain <- function(equivalenceBayesianIndTTestTable, dataset, options, equivalenceBayesianIndTTestResults) {

  for (variable in options$variables) {

    results <- equivalenceBayesianIndTTestResults[[variable]]

    if (!is.null(results$status)) {
      equivalenceBayesianIndTTestTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "statistic")
      equivalenceBayesianIndTTestTable$addRows(list(variable = variable, statistic = NaN), rowNames = variable)
    } else {

      error_in_alt  <- (results$errorPrior + results$errorPosterior) / results$bfEquivalence
      bfEquivalence <- .recodeBFtype(
        bfOld     = results$bfEquivalence,
        newBFtype = options[["bayesFactorType"]],
        oldBFtype = "BF10"
      )
      equivalenceBayesianIndTTestTable$addRows(list(variable      = variable,
                                                    type          = gettextf("Overlapping (%1$s vs. %2$s)",
                                                                             if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("inside") else gettext("all"),
                                                                             if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("all")    else gettext("inside")),
                                                    statistic     = "\U003B4 \U02208 I vs. H\u2081",
                                                    bf            = bfEquivalence,
                                                    error         = ifelse(error_in_alt == Inf, "NA", error_in_alt)))

      error_notin_alt  <- (results$errorPrior + results$errorPosterior) / results$bfNonequivalence
      bfNonequivalence <- .recodeBFtype(
        bfOld     = results$bfNonequivalence,
        newBFtype = options[["bayesFactorType"]],
        oldBFtype = "BF10"
      )
      equivalenceBayesianIndTTestTable$addRows(list(variable      = variable,
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
      equivalenceBayesianIndTTestTable$addRows(list(variable      = variable,
                                                    type          = gettextf("Non-overlapping (%1$s vs. %2$s)",
                                                                             if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("inside")  else gettext("outside"),
                                                                             if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("outside") else gettext("inside")),
                                                    statistic     = "\U003B4 \U02208 I vs. \U003B4 \U02209 I", # equivalence vs. nonequivalence"
                                                    bf            = bfNonoverlapping,
                                                    error         = ifelse(error_in_notin == Inf, "NA", error_in_notin)))
    }
  }

  return()
}

.equivalenceBayesianIndTTestTableDescriptives <- function(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready) {

  # Create table
  equivalenceBayesianDescriptivesTable <- createJaspTable(title = gettext("Descriptives"))
  equivalenceBayesianDescriptivesTable$dependOn(c("variables", "groupingVariable", "descriptives", "missingValues"))
  equivalenceBayesianDescriptivesTable$position <- 2

  # Add Columns to table
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "variable",   title = "",                   type = "string", combine = TRUE)
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "level",      title = gettext("Group"),     type = "string")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "N",          title = gettext("N"),         type = "integer")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "mean",       title = gettext("Mean"),      type = "number")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "sd",         title = gettext("SD"),        type = "number")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "se",         title = gettext("SE"),        type = "number")

  title <- gettextf("95%% Credible Interval")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "lowerCI", type = "number", format = "sf:4;dp:3", title = gettext("Lower"), overtitle = title)
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "upperCI", type = "number", format = "sf:4;dp:3", title = gettext("Upper"), overtitle = title)

  equivalenceBayesianDescriptivesTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceBayesianDescriptivesTable$setExpectedSize(length(options$variables))

  jaspResults[["equivalenceBayesianDescriptivesTable"]] <- equivalenceBayesianDescriptivesTable

  if (!ready)
    return()

  .equivalenceBayesianFillDescriptivesTable(equivalenceBayesianDescriptivesTable, dataset, options, equivalenceBayesianIndTTestResults)

  return()
}

.equivalenceBayesianFillDescriptivesTable <- function(equivalenceBayesianDescriptivesTable, dataset, options, equivalenceBayesianIndTTestResults) {

  for (variable in options$variables) {

    results <- equivalenceBayesianIndTTestResults[[variable]]

    if (!is.null((results$status))) {
      equivalenceBayesianDescriptivesTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "level")
      equivalenceBayesianDescriptivesTable$addRows(list(variable = variable, level = NaN), rowNames = variable)
    } else {
      # Get data of the grouping variable
      data    <- dataset[[options$groupingVariable]]
      levels  <- levels(data)
      nlevels <- length(levels)

      for (i in 1:nlevels) {

        # Get data per level
        level <- levels[i]
        groupData <- na.omit(dataset[data == level, variable])

        # Calculate descriptives per level
        n                <- length(groupData)
        mean             <- mean(groupData)
        sd               <- sd(groupData)
        se               <- sd/sqrt(n)
        posteriorSummary <- jaspTTests::.posteriorSummaryGroupMean(variable = groupData, descriptivesPlotsCredibleInterval = 0.95)
        ciLower          <- .clean(posteriorSummary[["ciLower"]])
        ciUpper          <- .clean(posteriorSummary[["ciUpper"]])

        equivalenceBayesianDescriptivesTable$addRows(list(variable      = variable,
                                                          level         = level,
                                                          N             = n,
                                                          mean          = mean,
                                                          sd            = sd,
                                                          se            = se,
                                                          lowerCI       = ciLower,
                                                          upperCI       = ciUpper))
      }
    }
  }

  return()
}

.massPriorPosteriorIndpTTestTable <- function(jaspResults, dataset, options, equivalenceBayesianIndTTestResults, ready) {

  equivalenceMassTable <- createJaspTable(title = gettext("Prior and Posterior Mass Table"))
  equivalenceMassTable$dependOn(c("variables", "groupingVariable", "missingValues", "massPriorPosterior", .equivalenceRegionDependencies, .equivalencePriorDependencies))
  equivalenceMassTable$position <- 3

  equivalenceMassTable$addColumnInfo(name = "variable",         title = " ",                        type = "string", combine = TRUE)
  equivalenceMassTable$addColumnInfo(name = "section",          title = gettext("Section"),         type = "string")
  equivalenceMassTable$addColumnInfo(name = "priorMass",        title = gettext("Prior Mass"),      type = "number")
  equivalenceMassTable$addColumnInfo(name = "posteriorMass",    title = gettext("Posterior Mass"),  type = "number")

  equivalenceMassTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceMassTable$setExpectedSize(length(options$variables))

  jaspResults[["equivalenceMassTable"]] <- equivalenceMassTable

  if (!ready)
    return()

  .equivalenceMassFillTableMain(equivalenceMassTable, dataset, options, equivalenceBayesianIndTTestResults)

  return()

}

.equivalenceMassFillTableMain <- function(equivalenceMassTable, dataset, options, equivalenceBayesianIndTTestResults) {
  for (variable in options$variables) {

    results <- equivalenceBayesianIndTTestResults[[variable]]

    if (!is.null(results$status)) {
      equivalenceMassTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "mass")
      equivalenceMassTable$addRows(list(variable = variable, priorMass = NaN, posteriorMass = NaN), rowNames = variable)
    } else {

      equivalenceMassTable$addRows(list(variable      = variable,
                                        section       = "\U003B4 \U02208 I",
                                        priorMass     = results$integralEquivalencePrior,
                                        posteriorMass = results$integralEquivalencePosterior))

      equivalenceMassTable$addRows(list(variable      = variable,
                                        section       = "\U003B4 \U02209 I",
                                        priorMass     = results$integralNonequivalencePrior,
                                        posteriorMass = results$integralNonequivalencePosterior))
    }
  }
  return()
}

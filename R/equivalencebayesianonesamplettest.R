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

EquivalenceBayesianOneSampleTTest <- function(jaspResults, dataset, options) {

  ready <- (length(options$variables) > 0)

  if (ready) {
    dataset <- .ttestReadData(dataset, options, "one-sample")
    errors <- .ttestBayesianGetErrorsPerVariable(dataset, options, "one-sample")
  }

  # Dispatch bounds options
  options <- .equivalenceBayesianBoundsDispatch(options)

  # Compute the results
  equivalenceBayesianOneTTestResults <- .equivalenceBayesianOneTTestComputeResults(jaspResults, dataset, options, ready, errors)

  # Output tables and plots
  if (is.null(jaspResults[["equivalenceBayesianOneTTestTable"]]))
    .equivalenceBayesianOneTTestTableMain(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready)

  if(options$descriptives && is.null(jaspResults[["equivalenceBayesianDescriptivesTable"]]))
    .equivalenceBayesianOneTTestTableDescriptives(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready)

  if (options$priorandposterior && is.null(jaspResults[["equivalencePriorPosteriorContainer"]]))
    .equivalencePriorandPosterior(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready)

  if (options$plotSequentialAnalysis && is.null(jaspResults[["equivalenceSequentialContainer"]]))
    .equivalencePlotSequentialAnalysis(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready)

  if (options$massPriorPosterior && is.null(jaspResults[["equivalenceMassTable"]]))
    .massPriorPosteriorOneTTestTable(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready)

  return()
}

.equivalenceBayesianOneTTestComputeResults <- function(jaspResults, dataset, options, ready, errors) {

  if (!ready)
    return(list())

  if (!is.null(jaspResults[["stateEquivalenceBayesianOneTTestResults"]]))
    return(jaspResults[["stateEquivalenceBayesianOneTTestResults"]]$object)

  results <- list()

  for (variable in options$variables) {

    results[[variable]] <- list()

    if(!isFALSE(errors[[variable]])) {

       errorMessage <- errors[[variable]]$message
       results[[variable]][["status"]]  <- "error"
       results[[variable]][["errorFootnotes"]] <- errorMessage

    } else {

      x <- dataset[[variable]]
      x <- x[!is.na(x)] - options$mu

      results[[variable]][["n1"]] <- length(x)
      results[[variable]][["n2"]] <- NULL

      r <- try(.generalEquivalenceTtestBF(x       = x,
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
  jaspResults[["stateEquivalenceBayesianOneTTestResults"]] <- createJaspState(results)
  jaspResults[["stateEquivalenceBayesianOneTTestResults"]]$dependOn(c("variables", "groupingVariable", "missingValues", "mu", .equivalenceRegionDependencies, .equivalencePriorDependencies))
  return(results)
}

.equivalenceBayesianOneTTestTableMain <- function(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready) {

  # Create table
  equivalenceBayesianOneTTestTable <- createJaspTable(title = gettext("Equivalence Bayesian One Sample T-Test"))
  equivalenceBayesianOneTTestTable$dependOn(c("variables", "groupingVariable", "missingValues", "mu", .equivalenceRegionDependencies, .equivalencePriorDependencies, "bayesFactorType"))
  equivalenceBayesianOneTTestTable$position <- 1
  equivalenceBayesianOneTTestTable$showSpecifiedColumnsOnly <- TRUE

  hypothesis <- switch(options[["alternative"]], "twoSided" = "equal", "greater" = "greater", "less" = "smaller")
  bfTitle <- jaspTTests:::.ttestBayesianGetBFTitle(bfType  = options[["bayesFactorType"]], hypothesis = hypothesis)

  # Add Columns to table
  equivalenceBayesianOneTTestTable$addColumnInfo(name = "variable",   title = " ",                          type = "string", combine = TRUE)
  equivalenceBayesianOneTTestTable$addColumnInfo(name = "type",       title = gettext("Type"),              type = "string")
  equivalenceBayesianOneTTestTable$addColumnInfo(name = "statistic",  title = gettext("Model Comparison"),  type = "string")
  equivalenceBayesianOneTTestTable$addColumnInfo(name = "bf",         title = bfTitle,                      type = "number")
  equivalenceBayesianOneTTestTable$addColumnInfo(name = "error",      title = gettextf("error %%"),         type = "number")

  if (ready)
    equivalenceBayesianOneTTestTable$setExpectedSize(length(options$variables))

  message <- gettextf("I ranges from %1$s to %2$s",
                      ifelse(options$lowerbound == -Inf, "-\u221E", options$lowerbound),
                      ifelse(options$upperbound == Inf, "\u221E", options$upperbound))
  equivalenceBayesianOneTTestTable$addFootnote(message)

  jaspResults[["equivalenceBayesianOneTTestTable"]] <- equivalenceBayesianOneTTestTable

  if (!ready)
    return()

  .equivelanceBayesianOneTTestFillTableMain(equivalenceBayesianOneTTestTable, dataset, options, equivalenceBayesianOneTTestResults)

  return()
}

.equivelanceBayesianOneTTestFillTableMain <- function(equivalenceBayesianOneTTestTable, dataset, options, equivalenceBayesianOneTTestResults) {

  for (variable in options$variables) {

    results <- equivalenceBayesianOneTTestResults[[variable]]

    if (!is.null(results$status)) {
      equivalenceBayesianOneTTestTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "statistic")
      equivalenceBayesianOneTTestTable$addRows(list(variable = variable, statistic = NaN), rowNames = variable)
    } else {

      error_in_alt <- (results$errorPrior + results$errorPosterior) / results$bfEquivalence
      bfEquivalence <- .recodeBFtype(
        bfOld     = results$bfEquivalence,
        newBFtype = options[["bayesFactorType"]],
        oldBFtype = "BF10"
      )
      equivalenceBayesianOneTTestTable$addRows(list(variable      = variable,
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
      equivalenceBayesianOneTTestTable$addRows(list(variable      = variable,
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
      equivalenceBayesianOneTTestTable$addRows(list(variable      = variable,
                                                    type          = gettextf("Non-overlapping (%1$s vs. %2$s)",
                                                                             if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("inside")  else gettext("outside"),
                                                                             if (options[["bayesFactorType"]] %in% c("BF10", "LogBF10")) gettext("outside") else gettext("inside")),
                                                   statistic      = "\U003B4 \U02208 I vs. \U003B4 \U02209 I", # equivalence vs. nonequivalence"
                                                   bf             = bfNonoverlapping,
                                                   error          = ifelse(error_in_notin == Inf, "NA", error_in_notin)))
    }
  }

  return()
}

.equivalenceBayesianOneTTestTableDescriptives <- function(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready) {
  if(!is.null(jaspResults[["equivalenceBayesianDescriptivesTable"]])) return()

  # Create table
  equivalenceBayesianDescriptivesTable <- createJaspTable(title = gettext("Descriptives"))
  equivalenceBayesianDescriptivesTable$dependOn(c("variables", "descriptives", "missingValues"))
  equivalenceBayesianDescriptivesTable$position <- 2
  equivalenceBayesianDescriptivesTable$showSpecifiedColumnsOnly <- TRUE

  # Add Columns to table
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "variable",   title = "",                   type = "string", combine = TRUE)
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "N",          title = gettext("N"),         type = "integer")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "mean",       title = gettext("Mean"),      type = "number")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "sd",         title = gettext("SD"),        type = "number")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "se",         title = gettext("SE"),        type = "number")

  title <- gettextf("95%% Credible Interval")
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "lowerCI", type = "number", format = "sf:4;dp:3", title = gettext("Lower"), overtitle = title)
  equivalenceBayesianDescriptivesTable$addColumnInfo(name = "upperCI", type = "number", format = "sf:4;dp:3", title = gettext("Upper"), overtitle = title)

  jaspResults[["equivalenceBayesianDescriptivesTable"]] <- equivalenceBayesianDescriptivesTable

  for (variable in options$variables) {

    # Get data of the variable
    data <- dataset[[variable]]

    n    <- length(data)
    mean <- mean(data)
    sd   <- sd(data)
    se   <- sd/sqrt(n)

    posteriorSummary <- jaspTTests::.posteriorSummaryGroupMean(variable = data, descriptivesPlotsCredibleInterval = 0.95)
    ciLower <- .clean(posteriorSummary[["ciLower"]])
    ciUpper <- .clean(posteriorSummary[["ciUpper"]])

    equivalenceBayesianDescriptivesTable$addRows(list(variable      = variable,
                                                      N             = n,
                                                      mean          = mean,
                                                      sd            = sd,
                                                      se            = se,
                                                      lowerCI       = ciLower,
                                                      upperCI       = ciUpper))
  }
}

.massPriorPosteriorOneTTestTable <- function(jaspResults, dataset, options, equivalenceBayesianOneTTestResults, ready) {

  equivalenceMassTable <- createJaspTable(title = gettext("Prior and Posterior Mass Table"))
  equivalenceMassTable$dependOn(c("variables", "mu", "groupingVariable", "missingValues", "massPriorPosterior", .equivalenceRegionDependencies, .equivalencePriorDependencies))
  equivalenceMassTable$position <- 3

  equivalenceMassTable$addColumnInfo(name = "variable",      title = " ",                       type = "string", combine = TRUE)
  equivalenceMassTable$addColumnInfo(name = "section",       title = gettext("Section"),        type = "string")
  equivalenceMassTable$addColumnInfo(name = "priorMass",     title = gettext("Prior Mass"),     type = "number")
  equivalenceMassTable$addColumnInfo(name = "posteriorMass", title = gettext("Posterior Mass"), type = "number")


  equivalenceMassTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceMassTable$setExpectedSize(length(options$variables))

  jaspResults[["equivalenceMassTable"]] <- equivalenceMassTable

  if (!ready)
    return()

  .equivalenceMassFillTableMain(equivalenceMassTable, dataset, options, equivalenceBayesianOneTTestResults)

  return()

}

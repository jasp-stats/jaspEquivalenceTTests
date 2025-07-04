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

EquivalenceIndependentSamplesTTest <- function(jaspResults, dataset, options) {
  ready <- (length(options$variables) != 0 && options$groupingVariable != "")

  # Read dataset and error checking
  if (ready) {
    dataset <- .ttestReadData(dataset, options, "independent")
    .ttestCheckErrors(dataset, options, "independent")
    errors  <- .ttestBayesianGetErrorsPerVariable(dataset, options, "independent")
  }

  # Compute the results
  if(options[['equivalenceRegion']] == "lower"){
    options$lowerbound <- -Inf
    options$upperbound <- options$lower_max
  } else if(options[['equivalenceRegion']] == "upper"){
    options$lowerbound <- options$upper_min
    options$upperbound <- Inf
  }
  equivalenceIndTTestResults <- .equivalenceIndTTestComputeResults(jaspResults, dataset, options, ready, errors)

  # Output tables and plots
  if (is.null(jaspResults[["equivalenceIndTTestTable"]]))
    .equivalenceIndTTestTableMain(jaspResults, dataset, options, equivalenceIndTTestResults, ready)

  if (is.null(jaspResults[["equivalenceBoundsTable"]]))
    .equivalenceIndTTestTableEqb(jaspResults, dataset, options, equivalenceIndTTestResults, ready)

  if (options$descriptives && is.null(jaspResults[["equivalenceDescriptivesTable"]]))
    .equivalenceIndTTestTableDescriptives(jaspResults, dataset, options, equivalenceIndTTestResults, ready)

  if (options$equivalenceboundsplot && is.null(jaspResults[["equivalenceBoundsContainer"]]))
    .equivalencePlotInd(jaspResults, dataset, options, equivalenceIndTTestResults, ready)

  return()
}

.equivalenceIndTTestComputeResults <- function(jaspResults, dataset, options, ready, errors) {

  if (!ready)
    return(list())

  if (!is.null(jaspResults[["stateEquivalenceIndTTestResults"]]))
    return(jaspResults[["stateEquivalenceIndTTestResults"]]$object)

  results <- list()

  for (variable in options$variables) {

    results[[variable]] <- list()

    if (!isFALSE(errors[[variable]])) {
      errorMessage <- errors[[variable]]$message
      results[[variable]][["status"]] <- "error"
      results[[variable]][["errorFootnotes"]] <- errorMessage

    } else {

      tableResults <- try(TOSTER::dataTOSTtwo(data         = dataset,
                                              deps         = (variable),                 # there is a non-standard evaluation - keep the brackets
                                              group        = (options$groupingVariable), # there is a non-standard evaluation - keep the brackets
                                              var_equal    = options$tests == "students",
                                              low_eqbound  = options$lowerbound,
                                              high_eqbound = options$upperbound,
                                              eqbound_type = switch(options$boundstype, "raw" = "raw", "cohensD" = "SMD"),  # bounds type is raw or cohen's d
                                              alpha        = options$alpha,
                                              desc         = TRUE))

      if (isTryError(tableResults)) {
        errorMessage <- .extractErrorMessage(tableResults)
        results[[variable]][["status"]]         <- "error"
        results[[variable]][["errorFootnotes"]] <- errorMessage

      } else {

        variableData <- dataset[[ variable ]]
        groupingData <- dataset[[ options$groupingVariable ]]
        ns  <- tapply(variableData, groupingData, function(x) length(na.omit(x)))

        confIntEffSize <- c(0, 0)

        ciEffSize <- 1 - 2 * options$alpha
        alphaLevel <- 1 - (ciEffSize + 1) / 2

        confIntEffSize <- try(jaspTTests::.confidenceLimitsEffectSizes(ncp = tableResults$tost$asDF$`t[0]`,
                                                       df = tableResults$tost$asDF$`df[0]`, alpha.lower = alphaLevel,
                                                       alpha.upper = alphaLevel)[c(1, 3)])

        if (isTryError(confIntEffSize)) {
          results[[variable]][["status"]]         <- "error"
          results[[variable]][["errorFootnotes"]] <- "Confidence interval could not be computed"

        } else {

          confIntEffSize <- unlist(confIntEffSize) * sqrt((sum(ns)) / (prod(ns)))
          confIntEffSize <- sort(confIntEffSize)

          results[[variable]] <- list(
            ttestTvalue = tableResults$tost$asDF$`t[0]`,
            ttestDf     = tableResults$tost$asDF$`df[0]`,
            ttestP      = tableResults$tost$asDF$`p[0]`,
            upperTvalue = tableResults$tost$asDF$`t[1]`,
            upperDf     = tableResults$tost$asDF$`df[1]`,
            upperP      = tableResults$tost$asDF$`p[1]`,
            lowerTvalue = tableResults$tost$asDF$`t[2]`,
            lowerDf     = tableResults$tost$asDF$`df[2]`,
            lowerP      = tableResults$tost$asDF$`p[2]`,
            lowCohen    = tableResults$eqb$asDF$`low[cohen]`,
            highCohen   = tableResults$eqb$asDF$`high[cohen]`,
            cilCohen    = tableResults$effsize$asDF$`cil[cohen]`,
            ciuCohen    = tableResults$effsize$asDF$`ciu[cohen]`,
            lowRaw      = tableResults$eqb$asDF$`low[raw]`,
            highRaw     = tableResults$eqb$asDF$`high[raw]`,
            cilRaw      = tableResults$effsize$asDF$`cil[raw]`,
            ciuRaw      = tableResults$effsize$asDF$`ciu[raw]`,
            desc        = as.data.frame(tableResults$desc))
        }

      }
    }
  }

  # Save results to state
  jaspResults[["stateEquivalenceIndTTestResults"]] <- createJaspState(results)
  jaspResults[["stateEquivalenceIndTTestResults"]]$dependOn(c("variables", "groupingVariable", "tests", "alpha", "missingValues", "boundstype", .equivalenceRegionDependencies))

  return(results)
}

.equivalenceIndTTestTableMain <- function(jaspResults, dataset, options, equivalenceIndTTestResults, ready) {

  # Create table
  equivalenceIndTTestTable <- createJaspTable(title = gettext("Equivalence Independent Samples T-Test"))
  equivalenceIndTTestTable$dependOn(c("variables", "groupingVariable", "tests", "alpha", "missingValues", "boundstype", .equivalenceRegionDependencies))
  equivalenceIndTTestTable$position <- 1

  # Add Columns to table
  equivalenceIndTTestTable$addColumnInfo(name = "variable",   title = " ",                   type = "string", combine = TRUE)
  equivalenceIndTTestTable$addColumnInfo(name = "statistic",  title = gettext("Statistic"),  type = "string")
  equivalenceIndTTestTable$addColumnInfo(name = "t",          title = gettext("t"),          type = "number")
  equivalenceIndTTestTable$addColumnInfo(name = "df",         title = gettext("df"),         type = "number")
  equivalenceIndTTestTable$addColumnInfo(name = "p",          title = gettext("p"),          type = "pvalue")

  equivalenceIndTTestTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceIndTTestTable$setExpectedSize(length(options$variables))

  jaspResults[["equivalenceIndTTestTable"]] <- equivalenceIndTTestTable

  if (!ready)
    return()

  .equivelanceIndTTestFillTableMain(equivalenceIndTTestTable, dataset, options, equivalenceIndTTestResults)

  return()
}

.equivelanceIndTTestFillTableMain <- function(equivalenceIndTTestTable, dataset, options, equivalenceIndTTestResults) {

  for (variable in options$variables) {

    results <- equivalenceIndTTestResults[[variable]]

    if (!is.null((results$status))) {
      equivalenceIndTTestTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "statistic")
      equivalenceIndTTestTable$addRows(list(variable = variable, statistic = NaN), rowNames = variable)
    } else {

      # T-test:
      equivalenceIndTTestTable$addRows(list(variable      = variable,
                                            statistic     = gettext("T-Test"),
                                            t             = results$ttestTvalue,
                                            df            = results$ttestDf,
                                            p             = results$ttestP),
                                            rowNames = variable)

      # TOST upper:
      equivalenceIndTTestTable$addRows(list(variable      = "",
                                            statistic     = gettext("Upper bound"),
                                            t             = results$upperTvalue,
                                            df            = results$upperDf,
                                            p             = results$upperP))

      # TOST lower:
      equivalenceIndTTestTable$addRows(list(variable      = "",
                                            statistic     = gettext("Lower bound"),
                                            t             = results$lowerTvalue,
                                            df            = results$lowerDf,
                                            p             = results$lowerP))
    }
  }

  return()
}

.equivalenceIndTTestTableEqb <- function(jaspResults, dataset, options, equivalenceIndTTestResults, ready) {

  # Create table
  equivalenceBoundsTable <- createJaspTable(title = gettext("Equivalence Bounds"))
  equivalenceBoundsTable$dependOn(c("variables", "groupingVariable", "tests", "alpha", "missingValues", "boundstype", .equivalenceRegionDependencies))
  equivalenceBoundsTable$position <- 2

  # Add Columns to table
  equivalenceBoundsTable$addColumnInfo(name = "variable",   title = " ",                            type = "string", combine = TRUE)
  equivalenceBoundsTable$addColumnInfo(name = "statistic",  title = gettext("Bounds type"),         type = "string")
  equivalenceBoundsTable$addColumnInfo(name = "low",        title = gettext("Low"),                 type = "number")
  equivalenceBoundsTable$addColumnInfo(name = "high",       title = gettext("High"),                type = "number")

  title <- gettextf("%s%% Confidence Interval", 100 - options$alpha * 100 * 2)
  equivalenceBoundsTable$addColumnInfo(name = "lower", type = "number", format = "sf:4;dp:3", title = gettext("Lower"), overtitle = title)
  equivalenceBoundsTable$addColumnInfo(name = "upper", type = "number", format = "sf:4;dp:3", title = gettext("Upper"), overtitle = title)

  equivalenceBoundsTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceBoundsTable$setExpectedSize(length(options$variables))

  jaspResults[["equivalenceBoundsTable"]] <- equivalenceBoundsTable

  if (!ready)
    return()

  .equivalenceIndTTestFillTableEqb(equivalenceBoundsTable, dataset, options, equivalenceIndTTestResults)

  return()
}

.equivalenceIndTTestFillTableEqb <- function(equivalenceBoundsTable, dataset, options, equivalenceIndTTestResults) {

  for (variable in options$variables) {

    results <- equivalenceIndTTestResults[[variable]]

    if (!is.null((results$status))) {
      equivalenceBoundsTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "statistic")
      equivalenceBoundsTable$addRows(list(variable = variable, statistic = NaN), rowNames = variable)
    } else {
      equivalenceBoundsTable$addRows(list(variable     = variable,
                                          statistic    = gettext("Cohen's d"),
                                          low          = results$lowCohen,
                                          high         = results$highCohen,
                                          lower        = results$cilCohen,
                                          upper        = results$ciuCohen))

      equivalenceBoundsTable$addRows(list(variable     = "",
                                          statistic    = gettext("Raw"),
                                          low          = results$lowRaw,
                                          high         = results$highRaw,
                                          lower        = results$cilRaw,
                                          upper        = results$ciuRaw))
    }
  }

  return()
}

.equivalenceIndTTestTableDescriptives <- function(jaspResults, dataset, options, equivalenceIndTTestResults, ready) {

  # Create table
  equivalenceDescriptivesTable <- createJaspTable(title = gettext("Descriptives"))
  equivalenceDescriptivesTable$dependOn(c("variables", "groupingVariable", "descriptives", "missingValues"))
  equivalenceDescriptivesTable$position <- 3

  # Add Columns to table
  equivalenceDescriptivesTable$addColumnInfo(name = "variable",   title = " ",                  type = "string", combine = TRUE)
  equivalenceDescriptivesTable$addColumnInfo(name = "level",      title = gettext("Group"),     type = "string")
  equivalenceDescriptivesTable$addColumnInfo(name = "N",          title = gettext("N"),         type = "integer")
  equivalenceDescriptivesTable$addColumnInfo(name = "mean",       title = gettext("Mean"),      type = "number")
  equivalenceDescriptivesTable$addColumnInfo(name = "sd",         title = gettext("SD"),        type = "number")
  equivalenceDescriptivesTable$addColumnInfo(name = "se",         title = gettext("SE"),        type = "number")

  equivalenceDescriptivesTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalenceDescriptivesTable$setExpectedSize(length(options$variables))

  jaspResults[["equivalenceDescriptivesTable"]] <- equivalenceDescriptivesTable

  if (!ready)
    return()

  .equivalenceFillDescriptivesTable(equivalenceDescriptivesTable, dataset, options, equivalenceIndTTestResults)

  return()
}

.equivalenceFillDescriptivesTable <- function(equivalenceDescriptivesTable, dataset, options, equivalenceIndTTestResults) {

  for (variable in options$variables) {

    results <- equivalenceIndTTestResults[[variable]]
    amountLevels <- nlevels(factor(dataset[[options[["groupingVariable"]]]]))

    if (!is.null((results$status))) {
      equivalenceDescriptivesTable$addFootnote(message = results$errorFootnotes, rowNames = variable, colNames = "level")
      equivalenceDescriptivesTable$addRows(list(variable = variable, level = NaN), rowNames = variable)
    } else {
      results <- results$desc
      for (i in 1:amountLevels) {

        equivalenceDescriptivesTable$addRows(list(variable      = variable,
                                                  level         = results[[paste0("name[",i,"]")]],
                                                  N             = results[[paste0("n[",i,"]")   ]],
                                                  mean          = results[[paste0("m[",i,"]")   ]],
                                                  sd            = results[[paste0("sd[",i,"]")  ]],
                                                  se            = results[[paste0("se[",i,"]")  ]]))
      }
    }
  }
}

.equivalencePlotInd <- function(jaspResults, dataset, options, equivalenceIndTTestResults, ready) {

  equivalenceBoundsContainer <- createJaspContainer(title = gettext("Equivalence Bounds Plots"))
  equivalenceBoundsContainer$dependOn(c("variables", "groupingVariable", "tests", "alpha", "missingValues", "boundstype", "equivalenceboundsplot", .equivalenceRegionDependencies))
  equivalenceBoundsContainer$position <- 4
  jaspResults[["equivalenceBoundsContainer"]] <- equivalenceBoundsContainer

  if (!ready) {
    return()
  }

  for (variable in options$variables) {

    # Check if the plot for this variable was already created previously:
    if (!is.null(equivalenceBoundsContainer[[variable]]))
      next

    equivalenceIndTTestPlot <- createJaspPlot(title = variable, width = 480, height = 320)
    equivalenceIndTTestPlot$dependOn(options = "boundstype", optionContainsValue = list("variables" = variable))

    # Get results
    results <- equivalenceIndTTestResults[[variable]]

    if (!is.null((results$status))) {
      equivalenceIndTTestPlot$setError(results$errorFootnotes)
    } else {
      # Make plot
      plot <- ggplot2::ggplot(data = dataset, ggplot2::aes_string(x = 0, y = 0))
      if (options[["boundstype"]] == "raw") {
        # TODO: the effect size should be passed directly instead of recomputing from the confidence intervals
        dif <- (results$ciuRaw + results$cilRaw) / 2
        plot <- plot + ggplot2::annotate(geom = "rect", xmin = -20, xmax = 20, ymin = results$lowRaw, ymax = results$highRaw, alpha = .5) +
                        ggplot2::geom_errorbar(ymin = results$cilRaw, ymax = results$ciuRaw, width = .4, size = .8, colour = "black")
        yTicks <- jaspGraphs::getPrettyAxisBreaks(c(results$cilRaw, results$ciuRaw, results$lowRaw, results$highRaw))
      } else {
        # TODO: the effect size should be passed directly instead of recomputing from the confidence intervals
        dif <- (results$ciuCohen + results$cilCohen) / 2
        plot <- plot + ggplot2::annotate(geom = "rect", xmin = -20, xmax = 20, ymin = results$lowCohen, ymax = results$highCohen, alpha = .5) +
                        ggplot2::geom_errorbar(ymin = results$cilCohen, ymax = results$ciuCohen, width = .4, size = .8, colour = "black")
        yTicks <- jaspGraphs::getPrettyAxisBreaks(c(results$cilCohen, results$ciuCohen, results$lowCohen, results$highCohen))
      }
      plot <- plot +
        ggplot2::geom_point(x = 0, y = dif, shape = 21, fill = "black", size = 3, colour = "black") +
        ggplot2::scale_x_discrete(limits = c("", "", "", "", "", "", "")) +
        jaspGraphs::scale_y_continuous(name = variable, breaks = yTicks, limits = range(yTicks)) +
        ggplot2::expand_limits(x = c(-2, 4), y = 0) +
        jaspGraphs::geom_rangeframe() +
        jaspGraphs::themeJaspRaw() +
        ggplot2::theme(axis.text.x  = ggplot2::element_blank(),
                       axis.title.x = ggplot2::element_blank(),
                       axis.ticks.x = ggplot2::element_blank(),
                       axis.line.x  = ggplot2::element_blank())

      equivalenceIndTTestPlot$plotObject <- plot
    }

    equivalenceBoundsContainer[[variable]] <- equivalenceIndTTestPlot
  }

  return()
}

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

EquivalencePairedSamplesTTest <- function(jaspResults, dataset, options) {

  ready <- (length(options$pairs) > 0)

  for (pair in options$pairs) {
    if (pair[[1L]] == "" || pair[[2L]] == "")
      ready <- FALSE
  }

  # Read dataset and error checking
  if (ready) {
    dataset <- .ttestReadData(dataset, options, "paired")
    .ttestCheckErrors(dataset, options, "paired")
    errors  <- .ttestBayesianGetErrorsPerVariable(dataset, options, "paired")
  }

  # Compute the results
  if(options[['equivalenceRegion']] == "lower"){
    options$lowerbound <- -Inf
    options$upperbound <- options$lower_max
  } else if(options[['equivalenceRegion']] == "upper"){
    options$lowerbound <- options$upper_min
    options$upperbound <- Inf
  }
  equivalencePairedTTestResults <- .equivalencePairedTTestComputeResults(jaspResults, dataset, options, ready, errors)

  # Output tables and plots
  if(is.null(jaspResults[["equivalencePairedTTestTable"]]))
    .equivalencePairedTTestTableMain(jaspResults, dataset, options, equivalencePairedTTestResults, ready)

  if(is.null(jaspResults[["equivalencePairedBoundsTable"]]))
    .equivalencePairedTTestTableEqb(jaspResults, dataset, options, equivalencePairedTTestResults, ready)

  if (options$descriptives && is.null(jaspResults[["equivalencePairedDescriptivesTable"]]))
    .equivalencePairedTTestTableDescriptives(jaspResults, dataset, options, equivalencePairedTTestResults, ready)

  if (options$equivalenceboundsplot && is.null(jaspResults[["equivalencePairedBoundsContainer"]]))
    .equivalenceBoundsPlotPaired(jaspResults, dataset, options, equivalencePairedTTestResults, ready)

  return()
}

.equivalencePairedTTestComputeResults <- function(jaspResults, dataset, options, ready, errors) {

  if (!ready)
    return(list())

  if (!is.null(jaspResults[["stateEquivalencePairedTTestResults"]]))
    return(jaspResults[["stateEquivalencePairedTTestResults"]]$object)

  results <- list()

  for (pair in options$pairs) {

    namePair <- paste(pair[[1L]], " - ",  pair[[2L]], sep = "")

    p1 <- pair[[1]]
    p2 <- pair[[2]]
    results[[namePair]] <- list()

    # Check for errors per variable
    if (!isFALSE(errors[[namePair]])) {
      errorMessage <- errors[[namePair]]$message
      results[[namePair]][["status"]]         <- "error"
      results[[namePair]][["errorFootnotes"]] <- errorMessage
    } else {
      tableResults <- try(TOSTER::dataTOSTpaired(data         = dataset,
                                                 pair1        = (p2), # there is a non-standard evaluation - keep the brackets
                                                 pair2        = (p1), # there is a non-standard evaluation - keep the brackets
                                                 low_eqbound  = options$lowerbound,
                                                 high_eqbound = options$upperbound,
                                                 eqbound_type = switch(options$boundstype, "raw" = "raw", "cohensD" = "SMD"),  # bounds type is raw or cohen's d
                                                 alpha        = options$alpha,                                    # default = 0.05
                                                 desc         = TRUE))

      if (isTryError(tableResults)) {
        errorMessage <- .extractErrorMessage(tableResults)
        results[[namePair]][["status"]]         <- "error"
        results[[namePair]][["errorFootnotes"]] <- errorMessage
      } else {

        c1 <- dataset[[ p1 ]]
        c2 <- dataset[[ p2 ]]
        df <- na.omit(data.frame(c1 = c1, c2 = c2))
        c1 <- df$c1
        n  <- length(c1)

        confIntEffSize <- c(0,0)
        ciEffSize <- 1 - 2 * options$alpha
        alphaLevel <- 1 - (ciEffSize + 1) / 2
        d   <- mean(c1 - c2) / sd(c1 - c2)

        confIntEffSize <- jaspTTests::.confidenceLimitsEffectSizes(ncp = tableResults$tost$asDF$t[1],
                                                                   df = tableResults$tost$asDF$df[1],
                                                                   alpha.lower = alphaLevel,
                                                                   alpha.upper = alphaLevel)[c(1, 3)]
        confIntEffSize <- unlist(confIntEffSize) / sqrt(n)
        confIntEffSize <- sort(confIntEffSize)

        results[[namePair]] <- list(
          ttestTvalue = tableResults$tost$asDF$t[1],
          ttestDf     = tableResults$tost$asDF$df[1],
          ttestP      = tableResults$tost$asDF$p[1],
          lowerTvalue = tableResults$tost$asDF$t[2],
          lowerDf     = tableResults$tost$asDF$df[2],
          lowerP      = tableResults$tost$asDF$p[2],
          upperTvalue = tableResults$tost$asDF$t[3],
          upperDf     = tableResults$tost$asDF$df[3],
          upperP      = tableResults$tost$asDF$p[3],
          lowCohen    = tableResults$eqb$asDF$low[1],
          highCohen   = tableResults$eqb$asDF$high[1],
          cilCohen    = tableResults$effsize$asDF$cil[2],
          ciuCohen    = tableResults$effsize$asDF$ciu[2],
          lowRaw      = tableResults$eqb$asDF$low[2],
          highRaw     = tableResults$eqb$asDF$high[2],
          cilRaw      = tableResults$effsize$asDF$cil[1],
          ciuRaw      = tableResults$effsize$asDF$ciu[1],
          desc        = as.data.frame(tableResults$desc))
      }
    }
  }

  # Save results to state
  jaspResults[["stateEquivalencePairedTTestResults"]] <- createJaspState(results)
  jaspResults[["stateEquivalencePairedTTestResults"]]$dependOn(c("pairs", "alpha", "missingValues", "boundstype", .equivalenceRegionDependencies))

  return(results)
}

.equivalencePairedTTestTableMain <- function(jaspResults, dataset, options, equivalencePairedTTestResults, ready) {

  # Create table
  equivalencePairedTTestTable <- createJaspTable(title = gettext("Equivalence Paired Samples T-Test"))
  equivalencePairedTTestTable$dependOn(c("pairs", "alpha", "missingValues", "boundstype", .equivalenceRegionDependencies))
  equivalencePairedTTestTable$position <- 1

  # Add Columns to table
  equivalencePairedTTestTable$addColumnInfo(name = "variable1",   title = " ",                   type = "string")
  equivalencePairedTTestTable$addColumnInfo(name = "separator",   title = " ",                   type = "separator")
  equivalencePairedTTestTable$addColumnInfo(name = "variable2",   title = " ",                   type = "string")
  equivalencePairedTTestTable$addColumnInfo(name = "statistic",   title = "Statistic",           type = "string")
  equivalencePairedTTestTable$addColumnInfo(name = "t",           title = gettext("t"),          type = "number")
  equivalencePairedTTestTable$addColumnInfo(name = "df",          title = gettext("df"),         type = "number")
  equivalencePairedTTestTable$addColumnInfo(name = "p",           title = gettext("p"),          type = "pvalue")

  equivalencePairedTTestTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalencePairedTTestTable$setExpectedSize(length(options$pairs))

  jaspResults[["equivalencePairedTTestTable"]] <- equivalencePairedTTestTable

  if (!ready)
    return()

  .equivelancePairedTTestFillTableMain(equivalencePairedTTestTable, dataset, options, equivalencePairedTTestResults)

  return()
}

.equivelancePairedTTestFillTableMain <- function(equivalencePairedTTestTable, dataset, options, equivalencePairedTTestResults) {

  for (pair in options$pairs) {
    namePair <- paste(pair[[1L]], " - ",  pair[[2L]], sep = "")
    results <- equivalencePairedTTestResults[[namePair]]

    if (!is.null((results$status))) {
      equivalencePairedTTestTable$addFootnote(message = results$errorFootnotes, rowNames = namePair, colNames = "statistic")
      equivalencePairedTTestTable$addRows(list(variable1 = pair[[1L]], separator = "-", variable2 = pair[[2L]], statistic = NaN), rowNames = namePair)
    } else {

      # TOST T-Test
      equivalencePairedTTestTable$addRows(list(variable1 = pair[[1L]],
                                               separator = "-",
                                               variable2 = pair[[2L]],
                                               statistic = gettext("T-Test"),
                                               t         = results$ttestTvalue,
                                               df        = results$ttestDf,
                                               p         = results$ttestP))

      # TOST upper:
      equivalencePairedTTestTable$addRows(list(variable1 = "",
                                               separator = "",
                                               variable2 = "",
                                               statistic = gettext("Upper bound"),
                                               t         = results$upperTvalue,
                                               df        = results$upperDf,
                                               p         = results$upperP))

      # TOST lower:
      equivalencePairedTTestTable$addRows(list(variable1 = "",
                                               separator = "",
                                               variable2 = "",
                                               statistic = gettext("Lower bound"),
                                               t         = results$lowerTvalue,
                                               df        = results$lowerDf,
                                               p         = results$lowerP))

    }
  }

  return()
}

.equivalencePairedTTestTableEqb <- function(jaspResults, dataset, options, equivalencePairedTTestResults, ready) {

  # Create table
  equivalencePairedBoundsTable <- createJaspTable(title = gettext("Equivalence Bounds"))
  equivalencePairedBoundsTable$dependOn(c("pairs", "alpha", "missingValues", "boundstype", .equivalenceRegionDependencies))
  equivalencePairedBoundsTable$position <- 2

  # Add Columns to table
  equivalencePairedBoundsTable$addColumnInfo(name = "variable1",   title = " ",                   type = "string", combine = TRUE)
  equivalencePairedBoundsTable$addColumnInfo(name = "separator",   title = " ",                   type = "string", combine = TRUE)
  equivalencePairedBoundsTable$addColumnInfo(name = "variable2",   title = " ",                   type = "string", combine = TRUE)
  equivalencePairedBoundsTable$addColumnInfo(name = "statistic",   title = gettext("Statistic"),  type = "string")
  equivalencePairedBoundsTable$addColumnInfo(name = "low",         title = gettext("Low"),        type = "number")
  equivalencePairedBoundsTable$addColumnInfo(name = "high",        title = gettext("High"),       type = "number")

  # alpha of 0.05 gives a 90% confidence interval
  title <- gettextf("%s%% Confidence Interval", 100 - options$alpha * 100 * 2)
  equivalencePairedBoundsTable$addColumnInfo(name = "lower", type = "number", format = "sf:4;dp:3", title = gettext("Lower"), overtitle = title)
  equivalencePairedBoundsTable$addColumnInfo(name = "upper", type = "number", format = "sf:4;dp:3", title = gettext("Upper"), overtitle = title)

  equivalencePairedBoundsTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalencePairedBoundsTable$setExpectedSize(length(options$pairs))

  jaspResults[["equivalencePairedBoundsTable"]] <- equivalencePairedBoundsTable

  if (!ready)
    return()

  .equivalencePairedTTestFillTableEqb(equivalencePairedBoundsTable, dataset, options, equivalencePairedTTestResults)

  return()
}

.equivalencePairedTTestFillTableEqb <- function(equivalencePairedBoundsTable, dataset, options, equivalencePairedTTestResults) {

  for (pair in options$pairs) {

    namePair <- paste(pair[[1L]], " - ",  pair[[2L]], sep = "")
    results <- equivalencePairedTTestResults[[namePair]]

    if (!is.null((results$status))) {
      equivalencePairedBoundsTable$addFootnote(message = results$errorFootnotes, rowNames = namePair, colNames = "statistic")
      equivalencePairedBoundsTable$addRows(list(variable1 = pair[[1L]], separator = "-", variable2 = pair[[2L]], statistic = NaN), rowNames = namePair)
    } else {

      equivalencePairedBoundsTable$addRows(list(variable1    = pair[[1L]],
                                                separator    = "-",
                                                variable2    = pair[[2L]],
                                                statistic    = gettext("Cohen's d"),
                                                low          = results$lowCohen,
                                                high         = results$highCohen,
                                                lower        = results$cilCohen,
                                                upper        = results$ciuCohen))

      equivalencePairedBoundsTable$addRows(list(variable1    = "",
                                                separator    = "",
                                                variable2    = "",
                                                statistic    = gettext("Raw"),
                                                low          = results$lowRaw,
                                                high         = results$highRaw,
                                                lower        = results$cilRaw,
                                                upper        = results$ciuRaw))

    }
  }
}

.equivalencePairedTTestTableDescriptives <- function(jaspResults, dataset, options, equivalencePairedTTestResults, ready) {

  # Create table
  equivalencePairedDescriptivesTable <- createJaspTable(title = gettext("Descriptives"))
  equivalencePairedDescriptivesTable$dependOn(c("pairs", "descriptives", "missingValues"))
  equivalencePairedDescriptivesTable$position <- 3

  # Add Columns to table
  equivalencePairedDescriptivesTable$addColumnInfo(name = "level",      title = " ",                  type = "string")
  equivalencePairedDescriptivesTable$addColumnInfo(name = "N",          title = gettext("N"),         type = "integer")
  equivalencePairedDescriptivesTable$addColumnInfo(name = "mean",       title = gettext("Mean"),      type = "number")
  equivalencePairedDescriptivesTable$addColumnInfo(name = "sd",         title = gettext("SD"),        type = "number")
  equivalencePairedDescriptivesTable$addColumnInfo(name = "se",         title = gettext("SE"),        type = "number")

  equivalencePairedDescriptivesTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    equivalencePairedDescriptivesTable$setExpectedSize(length(options$pairs))

  jaspResults[["equivalencePairedDescriptivesTable"]] <- equivalencePairedDescriptivesTable

  if (!ready)
    return()

  .equivalenceFillPairedDescriptivesTable(equivalencePairedDescriptivesTable, dataset, options, equivalencePairedTTestResults)

  return()
}

.equivalenceFillPairedDescriptivesTable <- function(equivalencePairedDescriptivesTable, dataset, options, equivalencePairedTTestResults) {

  vars <- unique(unlist(options$pairs))

  for (var in vars) {

    data <- na.omit(dataset[[ var ]])
    n    <- length(data)
    mean <- mean(data)
    sd   <- sd(data)
    se   <- sd/sqrt(n)

    equivalencePairedDescriptivesTable$addRows(list(level         = var,
                                                    N             = n,
                                                    mean          = mean,
                                                    sd            = sd,
                                                    se            = se))
  }
}

.equivalenceBoundsPlotPaired <- function(jaspResults, dataset, options, equivalencePairedTTestResults, ready) {

  equivalencePairedBoundsContainer <- createJaspContainer(title = gettext("Equivalence Bounds Plots"))
  equivalencePairedBoundsContainer$dependOn(c("pairs", "alpha", "missingValues",  "boundstype", "equivalenceboundsplot", .equivalenceRegionDependencies))
  equivalencePairedBoundsContainer$position <- 4
  jaspResults[["equivalencePairedBoundsContainer"]] <- equivalencePairedBoundsContainer

  if (!ready)
    return()

  for (pair in options$pairs) {

    namePair <- paste(pair[[1L]], " - ", pair[[2L]], sep = "")

    # TODO: broken because of QML updates -- setting pairs dependencies does not work
    # Check if the plot for this variable was already created previously
    # if (!is.null(equivalencePairedBoundsContainer[[namePair]]))
    #    next

    equivalencePairedTTestPlot <- createJaspPlot(title = namePair, width = 480, height = 320)
    # equivalencePairedTTestPlot$dependOn(optionContainsValue = list("pairs" = pair))

    # Get results
    results <- equivalencePairedTTestResults[[namePair]]

    if (!is.null((results$status))) {
      equivalencePairedTTestPlot$setError(results$errorFootnotes)
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
        ggplot2::geom_point(ggplot2::aes_string(x = 0, y = dif), shape = 21, fill = "black", size = 3, colour = "black") +
        ggplot2::scale_x_discrete(limits = c("", "", "", "", "", "", "")) +
        jaspGraphs::scale_y_continuous(name = namePair, breaks = yTicks, limits = range(yTicks)) +
        ggplot2::expand_limits(x = c(-2, 4), y = 0) +
        jaspGraphs::geom_rangeframe() +
        jaspGraphs::themeJaspRaw() +
        ggplot2::theme(axis.text.x  = ggplot2::element_blank(),
                       axis.title.x = ggplot2::element_blank(),
                       axis.ticks.x = ggplot2::element_blank(),
                       axis.line.x  = ggplot2::element_blank())

      equivalencePairedTTestPlot$plotObject <- plot
    }

    equivalencePairedBoundsContainer[[namePair]] <- equivalencePairedTTestPlot
  }

  return()
}

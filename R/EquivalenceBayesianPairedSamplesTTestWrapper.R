#
# Copyright (C) 2013-2025 University of Amsterdam
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

# This is a generated file. Don't change it!

#' Bayesian Equivalence Paired Samples T-Test
#'
EquivalenceBayesianPairedSamplesTTest <- function(
          data = NULL,
          version = "1",
          alternative = "twoSided",
          bayesFactorType = "BF10",
          boundstype = "cohensD",
          defaultStandardizedEffectSize = "cauchy",
          descriptives = FALSE,
          effectSizeStandardized = "default",
          equivalenceRegion = "region",
          informativeCauchyLocation = 0,
          informativeCauchyScale = 0.707,
          informativeNormalMean = 0,
          informativeNormalStd = 0.707,
          informativeStandardizedEffectSize = "cauchy",
          informativeTDf = 1,
          informativeTLocation = 0,
          informativeTScale = 0.707,
          lower_max = 0.05,
          lowerbound = -0.05,
          lowerbound_less = -0.05,
          massPriorPosterior = FALSE,
          missingValues = "excludeAnalysisByAnalysis",
          pairs = list(),
          plotHeight = 300,
          plotSequentialAnalysis = FALSE,
          plotSequentialAnalysisRobustness = FALSE,
          plotWidth = 350,
          priorWidth = 0.707,
          priorandposterior = FALSE,
          priorandposteriorAdditionalInfo = TRUE,
          rawCauchyLocation = 0,
          rawCauchyScale = 0.707,
          rawEffectSize = "cauchy",
          rawNormalMean = 0,
          rawNormalStd = 0.707,
          rawTDf = 1,
          rawTLocation = 0,
          rawTScale = 0.707,
          upper_min = -0.05,
          upperbound = 0.05,
          upperbound_greater = 0.05) {

   options <- mget(names(formals(sys.function())), envir = environment(), inherits = FALSE)
   options[["data"]] <- NULL
   options[["version"]] <- NULL


   if (!jaspBase::jaspResultsCalledFromJasp() && !is.null(data)) {
      jaspBase::storeDataSet(data)
   }

   optionsWithFormula <- c("boundstype", "pairs")
   for (name in optionsWithFormula) {
      if ((name %in% optionsWithFormula) && inherits(options[[name]], "formula")) options[[name]] = jaspBase::jaspFormula(options[[name]], data)   }

   # Options not given in the call get their default from the form, which can depend on the other options.
   options <- options[names(options) %in% names(match.call())[-1L]]
   return(jaspBase::runWrappedAnalysis("jaspEquivalenceTTests", "EquivalenceBayesianPairedSamplesTTest", "EquivalenceBayesianPairedSamplesTTest.qml", options, version, TRUE))
}
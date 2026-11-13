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

#' Equivalence Independent Samples T-Test
#'
EquivalenceIndependentSamplesTTest <- function(
          data = NULL,
          version = "1",
          alpha = 0.05,
          boundstype = "raw",
          descriptives = FALSE,
          equivalenceRegion = "region",
          equivalenceboundsplot = FALSE,
          groupingVariable = list(types = list(), value = ""),
          lower_max = 0.05,
          lowerbound = -0.05,
          missingValues = "excludeAnalysisByAnalysis",
          plotHeight = 300,
          plotWidth = 350,
          tests = "students",
          upper_min = -0.05,
          upperbound = 0.05,
          variables = list(types = list(), value = list())) {

   options <- mget(names(formals(sys.function())), envir = environment(), inherits = FALSE)
   options[["data"]] <- NULL
   options[["version"]] <- NULL


   if (!jaspBase::jaspResultsCalledFromJasp() && !is.null(data)) {
      jaspBase::storeDataSet(data)
   }

   optionsWithFormula <- c("boundstype", "groupingVariable", "variables")
   for (name in optionsWithFormula) {
      if ((name %in% optionsWithFormula) && inherits(options[[name]], "formula")) options[[name]] = jaspBase::jaspFormula(options[[name]], data)   }

   # Options not given in the call get their default from the form, which can depend on the other options.
   options <- options[names(options) %in% names(match.call())[-1L]]
   return(jaspBase::runWrappedAnalysis("jaspEquivalenceTTests", "EquivalenceIndependentSamplesTTest", "EquivalenceIndependentSamplesTTest.qml", options, version, TRUE))
}
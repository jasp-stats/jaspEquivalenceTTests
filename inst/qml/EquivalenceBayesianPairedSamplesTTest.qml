//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP

Form
{

    plotHeight: 300
    plotWidth:  350

    VariablesForm
    {
		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
        AvailableVariablesList { name: "allVariablesList" }
		AssignedPairsVariablesList { name: "pairs"; title: qsTr("Variable Pairs"); allowedColumns: ["scale"] }
    }

    RadioButtonGroup
    {
        name: "equivalenceRegion"
        title: qsTr("Equivalence Region")
        GridLayout
        {
            columns: 3
            rowSpacing: jaspTheme.rowGroupSpacing
            columnSpacing: 0
            visible: alternative.value === "twoSided"

            RadioButton { value: "region"; checked: true; id: region }
            DoubleField { name: "lowerbound"; label: qsTr("from")	; max: upperbound.value; defaultValue: -0.05; id: lowerbound; negativeValues: true; inclusive: JASP.None}
            DoubleField { name: "upperbound"; label: qsTr("to")	; min: lowerbound.value; defaultValue: 0.05;  id: upperbound; negativeValues: true; Layout.leftMargin: jaspTheme.columnGroupSpacing; inclusive: JASP.None}

            RadioButton { value: "lower"; id: lower }
            Label		  { text: qsTr("from %1").arg(" -∞ ")}
            DoubleField { name: "lower_max"; label: qsTr("to"); id: lower_max; defaultValue: 0.05; negativeValues: true; Layout.leftMargin: jaspTheme.columnGroupSpacing; inclusive: JASP.None}

            RadioButton { value: "upper"; id: upper }
            DoubleField { name: "upper_min"; label: qsTr("from"); id: upper_min; defaultValue: -0.05; negativeValues: true}
            Label		  { text: qsTr("to %1").arg(" ∞ "); Layout.leftMargin: jaspTheme.columnGroupSpacing}
         }

        GridLayout
        {
            columns: 2
            rowSpacing: jaspTheme.rowGroupSpacing
            columnSpacing: 0
            visible: alternative.value === "greater"

            Label		{ text: qsTr("from %1").arg(" 0 ")}
            DoubleField { name: "upperbound_greater"; label: qsTr("to")	; min: 0; defaultValue: 0.05; negativeValues: false; Layout.leftMargin: jaspTheme.columnGroupSpacing; inclusive: JASP.None}
        }

        GridLayout
        {
            columns: 2
            rowSpacing: jaspTheme.rowGroupSpacing
            columnSpacing: 0
            visible: alternative.value === "less"

            DoubleField { name: "lowerbound_less"; label: qsTr("from")	; max: 0; defaultValue: -0.05; negativeValues: true; inclusive: JASP.None}
            Label		{ text: qsTr("to %1").arg(" 0 "); Layout.leftMargin: jaspTheme.columnGroupSpacing}
        }
     }

     Group
     {
         title: qsTr("Additional Statistics")
         CheckBox { name: "descriptives";					text: qsTr("Descriptives")	}
         CheckBox { name: "massPriorPosterior";              text: qsTr("Prior and posterior mass") }
     }

    RadioButtonGroup
	{
		name:   "alternative"
		title:  qsTr("Alternative Hypothesis")
        id:     alternative
		RadioButton { value: "twoSided";	label: qsTr("Measure 1 ≠ Measure 2");   checked: true	}
		RadioButton { value: "greater"; 	label: qsTr("Measure 1 > Measure 2")					}
		RadioButton { value: "less";	    label: qsTr("Measure 1 < Measure 2")					}
	}

     Group
     {
         title: qsTr("Plots")
         CheckBox
         {
             name: "priorandposterior";		                        label: qsTr("Prior and posterior")
             CheckBox { name: "priorandposteriorAdditionalInfo";		label: qsTr("Additional info");     checked: true }
         }

         CheckBox
         {
              name: "plotSequentialAnalysis";		                    label: qsTr("Sequential analysis")
              CheckBox { name: "plotSequentialAnalysisRobustness";		label: qsTr("Robustness check") }
          }
     }

    BayesFactorType { }

     RadioButtonGroup
     {
         name: "missingValues"
         title: qsTr("Missing Values")
         RadioButton { value: "excludeAnalysisByAnalysis";	label: qsTr("Exclude cases per dependent variable"); checked: true	}
         RadioButton { value: "excludeListwise";				label: qsTr("Exclude cases listwise")							}
     }

     SubjectivePriors { }
}

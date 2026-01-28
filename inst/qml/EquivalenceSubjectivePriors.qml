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

Section
{
	title: qsTr("Prior")
	property alias effectSizeStandardized: effectSizeStandardized

	RadioButtonGroup
	{
		name: "effectSizeStandardized"
		id:	effectSizeStandardized


		RadioButton
		{
			id: defaultPriors
			label: qsTr("Default"); name: "default"; 
			checked: boundstype.value === "cohensD"
			visible: boundstype.value === "cohensD"
			RadioButtonGroup
			{
				name: "defaultStandardizedEffectSize"
				RadioButton
				{
					label: qsTr("Cauchy"); name: "cauchy"; checked: true; childrenOnSameRow: true
					DoubleField { label: qsTr("scale"); name: "priorWidth"; defaultValue: 0.707; fieldWidth: 50; max: 2; inclusive: JASP.MaxOnly }
				}
			}
		}

		RadioButton
		{
			id: informativePriors
			label: qsTr("Informative"); name: "informative"
			visible: boundstype.value === "cohensD"
			RadioButtonGroup
			{
				name: "informativeStandardizedEffectSize"
				RadioButton
				{
					label: qsTr("Cauchy"); name: "cauchy"; checked: true; childrenOnSameRow: true; id: cauchyInformative
					DoubleField { label: qsTr("location:"); name: "informativeCauchyLocation"; visible: cauchyInformative.checked; defaultValue: 0; min: -3; max: 3 }
					DoubleField { label: qsTr("scale:"); name: "informativeCauchyScale"; visible: cauchyInformative.checked; defaultValue: 0.707; fieldWidth: 50; max: 2; inclusive: JASP.MaxOnly }
				}
				RadioButton
				{
					label: qsTr("Normal"); name: "normal"; childrenOnSameRow: true; id: normalInformative
					DoubleField { label: qsTr("mean:"); name: "informativeNormalMean"; visible: normalInformative.checked; defaultValue: 0; min: -3; max: 3 }
					DoubleField { label: qsTr("std:"); name: "informativeNormalStd"; visible: normalInformative.checked; defaultValue: 0.707; fieldWidth: 50; max: 2 }
				}
				RadioButton
				{
					label: qsTr("t"); name: "t"; childrenOnSameRow: true; id: tInformative
					DoubleField { label: qsTr("location:"); name: "informativeTLocation"; visible: tInformative.checked; defaultValue: 0; min: -3; max: 3 }
					DoubleField { label: qsTr("scale:"); name: "informativeTScale"; visible: tInformative.checked; defaultValue: 0.707; fieldWidth: 50; max: 2; inclusive: JASP.MaxOnly }
					DoubleField { label: qsTr("df:"); name: "informativeTDf"; visible: tInformative.checked; defaultValue: 1; min: 1; max: 100 }
				}
			}
		}

		RadioButton
		{
			id: rawPriors
			label: qsTr("Raw"); name: "raw"
			visible: boundstype.value === "raw"
			checked: boundstype.value === "raw"
			RadioButtonGroup
			{
				name: "rawEffectSize"
				RadioButton
				{
					label: qsTr("Cauchy"); name: "cauchy"; checked: true; childrenOnSameRow: true; id: cauchyRaw
					DoubleField { label: qsTr("location:"); name: "rawCauchyLocation"; visible: cauchyRaw.checked; defaultValue: 0; negativeValues: true }
					DoubleField { label: qsTr("scale:"); name: "rawCauchyScale"; visible: cauchyRaw.checked; defaultValue: 0.707; fieldWidth: 50; negativeValues: false }
				}
				RadioButton
				{
					label: qsTr("Normal"); name: "normal"; childrenOnSameRow: true; id: normalRaw
					DoubleField { label: qsTr("mean:"); name: "rawNormalMean"; visible: normalRaw.checked; defaultValue: 0; negativeValues: true }
					DoubleField { label: qsTr("std:"); name: "rawNormalStd"; visible: normalRaw.checked; defaultValue: 0.707; fieldWidth: 50; negativeValues: false }
				}
				RadioButton
				{
					label: qsTr("t"); name: "t"; childrenOnSameRow: true; id: tRaw
					DoubleField { label: qsTr("location:"); name: "rawTLocation"; visible: tRaw.checked; defaultValue: 0; negativeValues: true }
					DoubleField { label: qsTr("scale:"); name: "rawTScale"; visible: tRaw.checked; defaultValue: 0.707; fieldWidth: 50; negativeValues: false }
					DoubleField { label: qsTr("df:"); name: "rawTDf"; visible: tRaw.checked; defaultValue: 1; min: 1; max: 100 }
				}
			}
		}
	}
}

import QtQuick
import JASP.Module

Description
{
	title:			qsTr("Equivalence T-Tests")
	name:			"jaspEquivalenceTTests"
	description:	qsTr("Test the difference between two means with an interval-null hypothesis")
	version			: "0.19.2"
	author:			"Jill de Ron"
	maintainer:		"Jill de Ron <jillderon93@gmail.com>"
	website:		"https://jasp-stats.org"
	license:		"GPL (>= 2)"
	icon:			"equivalence-module.svg"
	preloadData:	true

	GroupTitle
	{
		title:	qsTr("Classical")
		icon:	"equivalence-module.svg"
	}

	Analysis
	{
		title:	qsTr("Equivalence Independent Samples T-Test")
		menu:	qsTr("Independent Samples T-Test")
		qml:	"EquivalenceIndependentSamplesTTest.qml"
		func:	"EquivalenceIndependentSamplesTTest"
	}
	Analysis
	{
		title:	qsTr("Equivalence Paired Samples T-Test")
		menu:	qsTr("Paired Samples T-Test")
		qml:	"EquivalencePairedSamplesTTest.qml"
		func:	"EquivalencePairedSamplesTTest"
	}
	Analysis
	{
		title:	qsTr("Equivalence One Sample T-Test")
		menu:	qsTr("One Sample T-Test")
		qml:	"EquivalenceOneSampleTTest.qml"
		func:	"EquivalenceOneSampleTTest"
	}

	Separator {}

	GroupTitle
	{
		title:	qsTr("Bayesian")
		icon:	"equivalence-module-bayesian.svg"
	}

	Analysis
	{
		title:	qsTr("Bayesian Equivalence Independent Samples T-Test")
		menu:	qsTr("Independent Samples T-Test")
		qml:	"EquivalenceBayesianIndependentSamplesTTest.qml"
		func:	"EquivalenceBayesianIndependentSamplesTTest"
	}

	Analysis
	{
		title:	qsTr("Bayesian Equivalence Paired Samples T-Test")
		menu:	qsTr("Paired Samples T-Test")
		qml:	"EquivalenceBayesianPairedSamplesTTest.qml"
		func:	"EquivalenceBayesianPairedSamplesTTest"
	}

	Analysis
	{
		title:	qsTr("Bayesian Equivalence One Sample T-Test")
		menu:	qsTr("One Sample T-Test")
		qml:	"EquivalenceBayesianOneSampleTTest.qml"
		func:	"EquivalenceBayesianOneSampleTTest"
	}
}

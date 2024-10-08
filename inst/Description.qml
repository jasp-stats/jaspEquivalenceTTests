import QtQuick 		2.12
import JASP.Module 	1.0

Description
{
	title:			qsTr("Equivalence T-Tests")
	name:			"jaspEquivalenceTTests"
	description:	qsTr("Test the difference between two means with an interval-null hypothesis")
	version			: "0.19.0"
	author:			"Jill de Ron"
	maintainer:		"Jill de Ron <jillderon93@gmail.com>"
	website:		"https://jasp-stats.org"
	license:		"GPL (>= 2)"
	icon:			"equivalence-module.svg"
	preloadData:	true

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

	Analysis
	{
		title:	qsTr("Equivalence Bayesian Independent Samples T-Test")
		menu:	qsTr("Bayesian Independent Samples T-Test")
		qml:	"EquivalenceBayesianIndependentSamplesTTest.qml"
		func:	"EquivalenceBayesianIndependentSamplesTTest"
	}

	Analysis
	{
		title:	qsTr("Equivalence Bayesian Paired Samples T-Test")
		menu:	qsTr("Bayesian Paired Samples T-Test")
		qml:	"EquivalenceBayesianPairedSamplesTTest.qml"
		func:	"EquivalenceBayesianPairedSamplesTTest"
	}

	Analysis
	{
		title:	qsTr("Equivalence Bayesian One Sample T-Test")
		menu:	qsTr("Bayesian One Sample T-Test")
		qml:	"EquivalenceBayesianOneSampleTTest.qml"
		func:	"EquivalenceBayesianOneSampleTTest"
	}
}

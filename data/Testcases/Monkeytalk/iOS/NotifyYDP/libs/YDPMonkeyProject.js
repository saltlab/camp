/***** DO NOT EDIT THIS FILE *****/
// YDPMonkeyProject.js generated by MonkeyTalk

load("libs/MonkeyTalkAPI.js");


var YDPMonkeyProject = {};

/*** script -- TestScenario1 ***/
YDPMonkeyProject.TestScenario1 = function(app) {
	MT.Script.call(this, app, "TestScenario1.mt");
};

YDPMonkeyProject.TestScenario1.prototype = new MT.Script;

YDPMonkeyProject.TestScenario1.prototype.call = function() {
	//run: TestScenario1.mt
	MT.Script.prototype.call(this);
};

MT.Application.prototype.testScenario1 = function() {
	return new YDPMonkeyProject.TestScenario1(this);
};

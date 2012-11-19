Parse.Cloud.define('IncrementProgress', function(request, response) {

	var progressMap = request.user.get('progressMap');
	var rewardID = request.params['rewardID'];
	var rewardProgress;
	var validScan = 0;
	var currentDate = new Date();
	// 3 hours valid window
	//var validScanWindow = new Date(currentDate.getTime() - 10800000);
	var validScanWindow = new Date(currentDate.getTime() - 1);
	// check to see if user has this reward
	if (progressMap.hasOwnProperty(rewardID)) {
		// user has the reward
		rewardProgress = progressMap[rewardID];

		// check to see if the scan is valid
		if (rewardProgress['LastScanTimeStamp'] !== "") {
			var lastScan = new Date(rewardProgress['LastScanTimeStamp']);

			if (validScanWindow >= lastScan) {
				// valid scan
				validScan = 1;
			}
		}
	} else {
		// user doesn't have the reward, create it
		var rewardTxt = '{"Count" : 0, "LastScanTimeStamp" : ""}';
		rewardProgress = eval ("(" + rewardTxt + ")");
		validScan = 1;
	}

	if (validScan === 1) {
		rewardProgress['LastScanTimeStamp'] = currentDate.toString();
		rewardProgress['Count'] = rewardProgress['Count'] + 1;
		progressMap[rewardID] = rewardProgress;

		// start the saving process
		request.user.set("progressMap", progressMap);
		request.user.increment("RewardCatPoints", 1);
		request.user.save(null, {
			success: function(user) {
				response.success();
			},
			error: function(error) {
				response.error('Oups something went wrong with User save.');
			}
		});
	} else {
    	response.error('Scanned the same QR code too soon!');
	}

});

Parse.Cloud.define('redeemReward', function(request, response) {

	var rewardID = request.params['rewardID'];
	var rewardType = request.params['rewardType'];
	var rewardTarget = request.params['target'];
	
	if (rewardType === 'Reward') {
		var progressMap = request.user.get('progressMap');
		var rewardProgress = progressMap[rewardID];
		
		rewardProgress['Count'] = rewardProgress['Count'] - rewardTarget;
		progressMap[rewardID] = rewardProgress;
		
		// start the saving process
		request.user.set("progressMap", progressMap);
		request.user.increment("RewardCatPoints", 5);
		request.user.save(null, {
			success: function(user) {
				response.success();
			},
			error: function(error) {
				response.error('Oops something went wrong with User save.');
			}
		});
	} else {
		request.user.increment("RewardCatPoints", -rewardTarget);
		request.user.save(null, {
			success: function(user) {
				response.success();
			},
			error: function(error) {
				response.error('Oops something went wrong with User save.');
			}
		});
	}
});
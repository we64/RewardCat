Parse.Cloud.define('IncrementProgress', function(request, response) {

	var progressMap = request.user.get('progressMap');
	var rewardID = request.params['rewardID'];
	var rewardProgress;
	var validScan = 0;
	var currentDate = new Date();
	// 3 hours valid window
	//var validScanWindow = new Date(currentDate.getTime() - 10800000);
	var validScanWindow = new Date(currentDate.getTime() - 1);

	console.log("User: " + request.user.id);

	// check to see if user has this reward
	if (progressMap.hasOwnProperty(rewardID)) {
		// user has the reward
		rewardProgress = progressMap[rewardID];
		var lastScan = new Date(rewardProgress['LastScanTimeStamp']);
		
		// check to see if the scan is valid
		if (validScanWindow >= lastScan) {
			// valid scan
			validScan = 1;
		}
	} else {
		// user doesn't have the reward, create it
		var rewardTxt = '{"Count" : 0, "LastScanTimeStamp" : 0}';
		rewardProgress = eval ("(" + rewardTxt + ")");
		validScan = 1;
	}

	if (validScan === 1) {
		rewardProgress['LastScanTimeStamp'] = currentDate.getTime();
		rewardProgress['Count'] = rewardProgress['Count'] + 1;
		progressMap[rewardID] = rewardProgress;
		
		var rewardCatPoints = 1;
		var Reward = Parse.Object.extend("Reward");
		var query = new Parse.Query(Reward);
		query.get(rewardID, {
			success: function(object) {
				rewardCatPoints = object.get("scanPoint");
				var rewardDescription = object.get("description");
				var vendor = object.get("vendor");
				var vendorId = vendor.id;
				var target = object.get("target")

				if (target == 0) {
					response.error('Invalid QR code.');
				}

				request.user.set("progressMap", progressMap);
				request.user.increment("rewardcatPoints", rewardCatPoints);
				
				// save this transaction
				var Transaction = Parse.Object.extend("Transaction");
				var transaction = new Transaction();
				transaction.set("activityType", "Scanned Reward");
				transaction.set("reward", object);
				transaction.set("rewardDelta", 1);
				transaction.set("rewardcatPointsDelta", rewardCatPoints);
				transaction.set("rewardTotalCountAfterAction", rewardProgress['Count']);
				transaction.set("rewardDescription", rewardDescription.description);
				transaction.set("rewardLongDescription", rewardDescription.longDescription);
				transaction.set("user", request.user);
				transaction.set("vendor", vendor);

				Parse.Object.saveAll([request.user, transaction], {
					success: function(list) {
						console.log("Reward Increment User Progress Saved Successfully.");
						console.log("Reward Increment Transaction Saved Successfully.");
						var resultText = '{"rewardDelta" : ' + 1 + ', "rewardcatPointsDelta" : ' + rewardCatPoints + ', "vendorId" : "' + vendorId + '"}';
						response.success(eval ("(" + resultText + ")"));
					},
					error: function(error) {
						console.log("Error: " + error.code + " " + error.message);
						response.error('Oops something went wrong with User and Transaction save.');
					},
				});
			},
			error: function(error) {
				// looks like reward doesn't exist anymore
				console.log("Error: " + error.code + " " + error.message);
				response.error('The reward does not exist anymore. If you feel that this occurred in error, please contact us at support@rewardcat.com.');
			}
		});
	} else {
    	response.error('For security reasons, we have disabled the scanning of the same QR code within a certain time frame. If you feel that this occurred in error, please contact us at support@rewardcat.com.');
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
		request.user.set("progressMap", progressMap);

		var Reward = Parse.Object.extend("Reward");
		var query = new Parse.Query(Reward);
		query.get(rewardID, {
			success: function(object) {
				var rewardDescription = object.get("description");
				var vendor = object.get("vendor");

				// save this transaction
				// this will happen regardless whether user object saves successfully or not
				// this way will hopefully help us reconcile in case of error or disputes
				var Transaction = Parse.Object.extend("Transaction");
				var transaction = new Transaction();
				transaction.set("activityType", "Redeemed Reward");
				transaction.set("reward", object);
				transaction.set("rewardDelta", -rewardTarget);
				transaction.set("rewardTotalCountAfterAction", rewardProgress['Count']);
				transaction.set("user", request.user);
				transaction.set("rewardDescription", rewardDescription.description);
				transaction.set("rewardLongDescription", rewardDescription.longDescription);
				transaction.set("vendor", vendor);
				
				Parse.Object.saveAll([request.user, transaction], {
					success: function(list) {
						console.log("Reward Redeem User Progress Saved Successfully.");
						console.log("Reward Redeem Transaction Saved Successfully.");
						response.success();
					},
					error: function(error) {
						console.log("Error: " + error.code + " " + error.message);
						response.error('Oops something went wrong with User and Transaction save.');
					},
				});
			},
			error: function(error) {
				// looks like reward doesn't exist anymore
				console.log("Error: " + error.code + " " + error.message);
			}
		});
	} else {
		request.user.increment("rewardcatPoints", -rewardTarget);

		var PointReward = Parse.Object.extend("PointReward");
		var query = new Parse.Query(PointReward);
		query.get(rewardID, {
			success: function(object) {
				var rewardDescription = object.get("description");
				var vendor = object.get("vendor");

				// save this transaction
				// this will happen regardless whether user object saves successfully or not
				// this way will hopefully help us reconcile in case of error or disputes
				var Transaction = Parse.Object.extend("Transaction");
				var transaction = new Transaction();
				transaction.set("activityType", "Redeemed PointReward");
				transaction.set("pointReward", object);
				transaction.set("rewardcatPointsDelta", -rewardTarget);
				transaction.set("user", request.user);
				transaction.set("rewardDescription", rewardDescription.description);
				transaction.set("rewardLongDescription", rewardDescription.longDescription);
				transaction.set("vendor", vendor);

				Parse.Object.saveAll([request.user, transaction], {
					success: function(list) {
						console.log("PointReward Redeem User Progress Saved Successfully.");
						console.log("Point Reward Redeem Transaction Saved Successfully.");
						response.success();
					},
					error: function(error) {
						console.log("Error: " + error.code + " " + error.message);
						response.error('Oops something went wrong with User and Transaction save.');
					},
				});
			},
			error: function(error) {
				// looks like reward doesn't exist anymore
				console.log("Error: " + error.code + " " + error.message);
			}
		});		
	}
});

Parse.Cloud.define('MergeDeleteUserAndUpdateTransaction', function(request, response) {

	var bonusPoints = 10;
	var userObjectId = request.params['userObjectId'];
	var username = request.params['username'];
	var progressMap = request.params['progressMap'];
	var rewardcatPoints = request.params['rewardcatPoints'];
	var uuid = request.params['uuid'];
	var actionType = request.params['type'];
	
	request.user.set("progressMap", progressMap);
	request.user.set("uuid", uuid);

	var Transaction = Parse.Object.extend("Transaction");
	var transaction = new Transaction();
	transaction.set("user", request.user);

	// give out sign up or Facebook login point bonus
	if (actionType === "signup") {

		request.user.set("rewardcatPoints", rewardcatPoints + bonusPoints);
		transaction.set("activityType", "Sign Up");
		transaction.set("rewardcatPointsDelta", bonusPoints);
		transaction.save();
	} else if (actionType === "facebook") {

		var createdAtDate = new Date(request.user.createdAt);
		var currentDate = new Date();
		if ((currentDate.getTime() - createdAtDate.getTime()) <= 120000) {
			request.user.set("rewardcatPoints", rewardcatPoints + bonusPoints);
			transaction.set("activityType", "Sign In with Facebook");
			transaction.set("rewardcatPointsDelta", bonusPoints);
			transaction.save();
		} else {
			request.user.set("rewardcatPoints", rewardcatPoints);
		}
	} else {
		request.user.set("rewardcatPoints", rewardcatPoints);
	}

	// start the saving process
	request.user.save(null, {
		success: function(user) {
			console.log("Successfully merged default account into the new registered account.");
			// log into the default account and call destroy to remove it	
			var user = Parse.User.logIn(username, "password", {
				success: function(user) {
					user.destroy({
						success: function(myObject) {
							// Fix Transaction
							// when user sign up with FB or login with an existing account
							// if the default account that has been removed have any transactions
							// we need to update their userObjectId
							var oldUser = new Parse.User();
							oldUser.id = userObjectId;
							var query = new Parse.Query(Transaction);
							query.equalTo("user", oldUser);
							query.find({
								success: function(results) {
									if (results.length > 0) {
										console.log("Found " + results.length + " transactions to update.");
										
										for (var i = 0; i < results.length; i++) {
											results[i].set("user", request.user);
										}
										
										// save all changes
										Parse.Object.saveAll(results, {
											success: function(list) {
												// All the objects were saved.
												console.log("Save All Success");
												response.success();
											},
											error: function(error) {
												// An error occurred while saving one of the objects.
												console.log("Error: " + error.code + " " + error.message);
												response.error('Oops something went wrong with deleting old default user.');
											}
										});
									} else {
										console.log("No transactions to update " + oldUser.id);
										response.success();
									}
								},
								error: function(error) {
									console.log("Looking for old transactions error: " + error.code + " " + error.message);
									response.error('Oops something went wrong with deleting old default user.');
								}
							});
						},
						error: function(myObject, error) {
							// failed to delete user
							console.log("Error: " + error.code + " " + error.message);
							response.error('Oops something went wrong with deleting old default user.');
						}
					});
				}
			});
		},
		error: function(error) {
			console.log("Error: " + error.code + " " + error.message);
			response.error('Oops something went wrong with User save.');
		}
	});
});

// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const userCollection = db.collection('users');
const groupCollection = db.collection('groups');
const metadataCollection = db.collection('metadata');

/////////////////////// GLOBALLY USED ///////////////////////

// Globally used function to convert user reference to JS object.
async function _userRefToObject(userRef) {
  var userSnapshot = await userRef.get();
  var userData = userSnapshot.data();
  userData['user-ref'] = userRef;
  return userData;
}

// Globally used function to update the recommendation schedule.
async function _updateRefreshSchedule() {
  var ts = admin.firestore.Timestamp.now();
  await metadataCollection
      .doc("recommendationrefresh")
      .set({
    "timestamp": ts,
  });
}
/////// EXAMPLE RATCHET CODE TO SET EVERYONE'S ELJEFES-FIRST TO 0 /////
// async function setJefesFirst (){
//   var userRefs = (await userCollection.get()).docs.map(qdoc => {
//     var data = qdoc.data();
//     return qdoc.id;
//   });

//   userRefs.forEach(async function (ref) {
//     await db.doc(`users/${ref}`)
//           .collection("metrics")
//           .doc("eljefes-first")
//           .set({
//             "count" : 0
//           });
//   });

// }


// exports.onetime = functions.pubsub.schedule("58 13 * * *").timeZone('America/New_York').onRun(async context => {
//   await setJefesFirst();
// });


// Scheduled recommendation refresh 12:00pm EST every day.
exports.noonRecRefresh = functions.pubsub.schedule("0 12 * * *")
  .timeZone('America/New_York')
  .onRun(async context => {
    await _updateRefreshSchedule();
  });

// Scheduled recommendation refresh 6:00pm EST every day.
exports.sixRecRefresh = functions.pubsub.schedule("0 18 * * *")
  .timeZone('America/New_York')
  .onRun(async context => {
    await _updateRefreshSchedule();
  });

/////////////////////// PUSH NOTIFICATIONS ///////////////////////

exports.notifyNewMatch = functions.firestore.document('/users/{id}/matched/{matchID}')
  .onCreate(async (snap, context) => {

    var matcheeUser = await _userRefToObject(snap.data()["user-ref"]);
    var matcherUserRef = db.doc(`users/${context.params.id}`);
    var matcherUser = await _userRefToObject(matcherUserRef);


    let tokens = matcheeUser['tokens'];

    // Notification details.
    const payload = {
      notification: {
        title: 'You have a match!',
        body: `Say hello to ${matcherUser['first-name']}!`,
      }
    };

    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        functions.logger.error(
          'Failure sending notification to',
          tokens[index],
          error
        );
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);

  });

exports.notifyNewChatMsg = functions.firestore.document('chats/{id}/messages/{messageID}')
  .onCreate(async (snap, context) => {
    var sender = await _userRefToObject(snap.data()["sender-ref"]);
    var receiver = await _userRefToObject(snap.data()["sendee-ref"]);

    let tokens = receiver['tokens'];

    // Notification details.
    const payload = {
      notification: {
        title: `${sender['first-name']} sent a message.`,
        body: `${snap.data()['content']}`,
      }
    };

    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        functions.logger.error(
          'Failure sending notification to',
          tokens[index],
          error
        );
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);

  });

/////////////////////// USER RECOMMENDATIONS ///////////////////////

// Globally used function to generate recommendations for a given userid.
async function _generateRecommendations(userid) {
  // Get user collection
  var collectionQuery = await userCollection.get();

  // Get current user
  var userRef = userCollection.doc(userid);

  // Get user data of current doc
  var currUser = await _userRefToObject(userRef);

  // Skip over if registration incomplete
  if (!currUser["dating-identity"] || !currUser["dating-interest"]) {
    return null;
  }

  // Get querying parameters based on user info
  var queryIdentity = [];
  var queryInterest = [];
  switch (currUser["dating-identity"]) {
    case 'non-binary':
      {
        switch (currUser["dating-interest"]) {
          case 'everyone':
            {
              queryIdentity = ['man', 'woman', 'non-binary'];
              queryInterest = ['everyone'];
            }
            break;

          case 'man':
            {
              queryIdentity = ['man'];
              queryInterest = ['everyone'];
            }
            break;

          case 'woman':
            {
              queryIdentity = ['woman'];
              queryInterest = ['everyone'];
            }
            break;
        }
      }
      break;

    case 'man':
      {
        switch (currUser["dating-interest"]) {
          case 'everyone':
            {
              queryIdentity = ['man', 'woman', 'non-binary'];
              queryInterest = ['man', 'everyone'];
            }
            break;

          case 'man':
            {
              queryIdentity = ['man'];
              queryInterest = ['man', 'everyone'];
            }
            break;

          case 'woman':
            {
              queryIdentity = ['woman'];
              queryInterest = ['man', 'everyone'];
            }
            break;
        }
      }
      break;

    case 'woman':
      {
        switch (currUser["dating-interest"]) {
          case 'everyone':
            {
              queryIdentity = ['man', 'woman', 'non-binary'];
              queryInterest = ['woman', 'everyone'];
            }
            break;

          case 'man':
            {
              queryIdentity = ['man'];
              queryInterest = ['woman', 'everyone'];
            }
            break;

          case 'woman':
            {
              queryIdentity = ['woman'];
              queryInterest = ['woman', 'everyone'];
            }
            break;
          default:
            {
              queryIdentity = ['man'];
              queryInterest = ['woman'];
            }
            break;
        }
      }
      break;
  }

  // Get outgoing reactions and matches of current user
  var reactionsSnapshot = await userRef.collection('outgoing').get();
  var allReactions = reactionsSnapshot.docs.map(function (qdoc) {
    var data = qdoc.data();
    return data['user-ref'].id;
  });
  var matchesSnapshot = await userRef.collection('matched').get();
  var allMatches = matchesSnapshot.docs.map(function (qdoc) {
    var data = qdoc.data();
    return data['user-ref'].id;
  });
  var blockedSnapshot = await userRef.collection('blocked').get();
  var allBlocked = blockedSnapshot.docs.map(function (qdoc) {
    var data = qdoc.data();
    return data['user-ref'].id;
  });
  var blockedBySnapshot = await userRef.collection('blockedby').get();
  var allBlockedBy = blockedBySnapshot.docs.map(function (qdoc) {
    var data = qdoc.data();
    return data['user-ref'].id;
  });

  // Filter out outgoing reactions and matches from all users
  var allUsers = collectionQuery.docs.map(qdoc => qdoc.id);
  var availableUsers = allUsers.filter(x => !allReactions.includes(x) && !allMatches.includes(x) && !allBlocked.includes(x) && !allBlockedBy.includes(x));
  var availableUsers = availableUsers.filter(x => x != userid);

  // Query for users within interests
  var snapshot;
  if (queryIdentity.length > 1) {
    snapshot = await userCollection
        .where('dating-interest', 'in', queryInterest)
        .get();
  } else {
    snapshot = await userCollection
        .where('dating-identity', '==', queryIdentity[0])
        .where('dating-interest', 'in', queryInterest)
        .get();
  }

  // Get list of potential recommendations
  var snapshotUserRefs = snapshot.docs.map(qdoc => qdoc.id);
  var potentialUserRefs = availableUsers.filter(x => snapshotUserRefs.includes(x));

  // Determine max list length
  var userListMaxLength;
  if (potentialUserRefs.length < 5) {
    userListMaxLength = potentialUserRefs.length;
  } else {
    userListMaxLength = 5;
  }

  // If potential user list over 5, randomly select 5
  var potentialSet = new Set(potentialUserRefs);
  var userList = [];
  while (userList.length < userListMaxLength) {
    var potentialArray = Array.from(potentialSet);
    var selectedUID = potentialArray[Math.floor((Math.random() * potentialArray.length))];
    potentialSet.delete(selectedUID);
    userList.push(selectedUID);
  }

  // Delete all currently stored recommendations.
  var recommendations = await userRef.collection("recommendations").get();
  recommendations.docs.forEach(async function (rec) {
    await rec.ref.delete();
  });

  // Populate recommendations collection with newly generated users.
  var ts = admin.firestore.Timestamp.now();
  userList.forEach(async function (uid) {
    await userRef
        .collection("recommendations")
        .doc(uid)
        .set({
      "timestamp": ts,
      "user-ref": userCollection.doc(uid),
    });
  });
}

// Generate recommendations as soon as user sets up their account.
exports.onRegisterRecommendations = functions.firestore
    .document('users/{userId}/metadata/accountsetup')
    .onCreate(async (change, context) => {
      await _generateRecommendations(context.params.userId);
      return null;
    });

// Generate recommendations on refresh.
exports.onRefreshRecommendations = functions.firestore
    .document('users/{userId}/metadata/lastrecrefresh')
    .onWrite(async (change, context) => {
      if (!change.before.exists) {
        await _generateRecommendations(context.params.userId);
        return null;
      }
      var before = change.before.data();
      var lastRefresh = before["timestamp"].toDate();
      var metadataQuery = await metadataCollection.doc("recommendationrefresh").get();
      var lastSchedule = metadataQuery.data()["timestamp"].toDate();

      if (lastSchedule > lastRefresh) {
        await _generateRecommendations(context.params.userId);
      }
      return null;
    });

/////////////////////// GROUP RECOMMENDATIONS ///////////////////////

// Generate recommendations for every group every X hours.
async function _generateGroupRecommendations(groupid) {
  // Get entire group collection
  var collectionQuery = await groupCollection.get();

  // Get current group
  var groupRef = groupCollection.doc(groupid);

  // Get outgoing reactions and matches
  var reactionsSnapshot =
      await groupRef.collection("outgoing").get();
  var allReactions =
      reactionsSnapshot.docs.map(function (qdoc) {
        var data = qdoc.data();
        return data['group-ref'].id;
      });
  var matchesSnapshot =
      await groupRef.collection("matched").get();
  var allMatches =
      matchesSnapshot.docs.map(function (qdoc) {
        var data = qdoc.data();
        return data['group-ref'].id;
      });

  // Get all group docs in list
  var allGroups = collectionQuery.docs.map(qdoc => qdoc.id);

  // Filter for viable groups
  var availableGroups = allGroups.filter(x => !allReactions.includes(x) && !allMatches.includes(x));
  availableGroups = availableGroups.filter(x => x != groupid);

  // Query based on the given parameters
  var snapshot =
      await groupCollection.where('user-count', '>', 1).get();

  // Create a list of potential recommendations
  var snapshotGIDs = snapshot.docs.map(qdoc => qdoc.id);
  var potentialGIDs =
      availableGroups.filter(x => snapshotGIDs.includes(x));

  // Randomly pick from potentialUIDs. Max 3 picks, unless there are less than
  // 3 potenialUIDs
  var groupListMaxLength;
  if (potentialGIDs.length < 5) {
    groupListMaxLength = potentialGIDs.length;
  } else {
    groupListMaxLength = 5;
  }

  var potentialSet = new Set(potentialGIDs);
  var groupList = [];
  while (groupList.length < groupListMaxLength) {
    var potentialArray = Array.from(potentialSet);
    var selectedGID = potentialArray[Math.floor((Math.random() * potentialArray.length))];
    potentialSet.delete(selectedGID);
    groupList.push(selectedGID);
  }

  // Delete all currently stored recommendations.
  var recommendations = await groupRef.collection("recommendations").get();
  recommendations.docs.forEach(async function (rec) {
    await rec.ref.delete();
  });

  // Populate recommendations collection with newly generated groups.
  var ts = admin.firestore.Timestamp.now();
  groupList.forEach(async function (gid) {
    await groupRef
        .collection("recommendations")
        .doc(gid)
        .set({
      "timestamp": ts,
      "group-ref": groupCollection.doc(gid),
    });
  });
};

// Generate group recommendations on refresh.
exports.onGroupRefreshRecommendations = functions.firestore
    .document('groups/{groupId}/metadata/lastrecrefresh')
    .onWrite(async (change, context) => {
      if (!change.before.exists) {
        return null;
      }
      var before = change.before.data();
      var lastRefresh = before["timestamp"].toDate();
      var metadataQuery = await metadataCollection.doc("recommendationrefresh").get();
      var lastSchedule = metadataQuery.data()["timestamp"].toDate();

      if (lastSchedule > lastRefresh) {
        await _generateGroupRecommendations(context.params.groupId);
      }
      return null;
    });
// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const userCollection = db.collection('users');
const groupCollection = db.collection('groups');

async function _userRefToObject(userRef) {
  var userSnapshot = await userRef.get();
  var userData = userSnapshot.data();
  userData['user-ref'] = userRef;
  return userData;
}

exports.generateRecommendations = functions.pubsub.schedule('every 2 minutes').onRun(async context => {
  console.log('This will be run every 2 minutes!');

  // Loop through all user documents
  var collectionQuery = await userCollection.get();
  collectionQuery.docs.forEach(async function (doc) {

    var currUser = await _userRefToObject(doc.ref);
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

    var reactionsSnapshot = await doc.ref.collection('outgoing').get();
    var allReactions = reactionsSnapshot.docs.map(function (qdoc) {
      var data = qdoc.data();
      if (data['user-ref'].exists) {
        return qdoc.id;
      } else {
        qdoc.delete();
        return "deleted";
      }
    });
    var allUsers = collectionQuery.docs.map(qdoc => qdoc.id);
    var availableUsers = allUsers.filter(x => !allReactions.includes(x));
    var availableUsers = availableUsers.filter(x => x != doc.id);

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

    var snapshotUserRefs = snapshot.docs.map(qdoc => qdoc.id);
    var potentialUserRefs = availableUsers.filter(x => snapshotUserRefs.includes(x));
    var userListMaxLength;
    if (potentialUserRefs.length < 5) {
      userListMaxLength = potentialUserRefs.length;
    } else {
      userListMaxLength = 5;
    }

    var potentialSet = new Set(potentialUserRefs);
    var userList = [];
    while (userList.length < userListMaxLength) {
      var potentialArray = Array.from(potentialSet);
      var selectedUID = potentialArray[Math.floor((Math.random() * potentialArray.length))];
      potentialSet.delete(selectedUID);
      userList.push(selectedUID);
    }

    // Delete all currently stored recommendations.
    var recommendations = await doc.ref.collection("recommendations").get();
    recommendations.docs.forEach(async function (rec) {
      await rec.ref.delete();
    });

    // Populate recommendations collection with newly generated users.
    var ts = admin.firestore.Timestamp.now();
    userList.forEach(async function (uid) {
      await doc.ref
          .collection("recommendations")
          .doc(uid)
          .set({
        "timestamp": ts,
        "user-ref": userCollection.doc(uid),
      });
    });
  });
  return null;
});


exports.generateGroupRecommendations = functions.pubsub.schedule('every 2 minutes').onRun(async context => {
  // Loop through all group documents
  var collectionQuery = await groupCollection.get();
  collectionQuery.docs.forEach(async function (doc) {
    var reactionsSnapshot =
        await doc.ref.collection("outgoing").get();
    var allReactions =
        reactionsSnapshot.docs.map(function (qdoc) {
          var data = qdoc.data();
          if (data['group-ref'].exists) {
            return qdoc.id;
          } else {
            qdoc.delete();
            return "deleted";
          }
        });

    var groupsSnapshot = await groupCollection.get();
    var allGroups = groupsSnapshot.docs.map(qdoc => qdoc.id);

    var availableGroups = allGroups.filter(x => !allReactions.includes(x));
    availableGroups = availableGroups.filter(x => x != doc.id);

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
    var recommendations = await doc.ref.collection("recommendations").get();
    recommendations.docs.forEach(async function (rec) {
      await rec.ref.delete();
    });

    // Populate recommendations collection with newly generated groups.
    var ts = admin.firestore.Timestamp.now();
    groupList.forEach(async function (gid) {
      await doc.ref
          .collection("recommendations")
          .doc(gid)
          .set({
        "timestamp": ts,
        "group-ref": groupCollection.doc(gid),
      });
    });
  });
});
function onPostSave(request, response, modules) {
  
  // Get References to Kinvey Business Logic Modules
  var push = modules.push;
  var collectionAccess = modules.collectionAccess;
  var logger = modules.logger;
  var async = modules.async;
  
  // Pull Information from the Request (the postSave Messages request)
  var senderUsername = request.username;
  var messageId = request.entityId;
  var message = request.body;
  
  // Setup our State Variables
  var recipient = {};

  // This method will fetch the recipient of the message based on the thread
  // id.  This is needed to send the push notification to the correct user
  var getRecipient = function(callback) {
    var recipientId = recipientIdToFetch();
    collectionAccess.collection('user').findOne({ "_id": recipientId }, function(error, user) {
      if(error) {
        logger.info("ERROR Fetching Recipient KCSUser");
        callback(error);
      } else {
        recipient = user;
        callback(null, recipient);
      }
    });
  };
  
  // This method will set the lastMessage on the MessageThread
  var updateLatestMessage = function(callback) {
    var threadId = message.threadId;
    
    // This is how Kinvey stores relationships to other entities
    // We simply need to insert this object for the thread at the
    // specified ID and we have updated the reference
    var lastMessageRef = {
      _type: "KinveyRef",
      _id: messageId,
      _collection: "Messages"
    };
    
    // This method will find and update the thread with the updated
    // reference to the message.  It returns the updated thread from
    // the data store.
    collectionAccess.collection('MessageThreads').findAndModify({ "_id": threadId }, { "_id": 1 }, { $set: { "lastMessage" : lastMessageRef } }, { new: true }, function(error, thread) {
      if(error) {
        logger.error("Could Not Fetch Thread from ID: " + threadId);
      } else {
        callback(null, thread);  
      }
    });
  };
  
  // This checks the threadId and based on the id of the user who saved the
  // message, it will determine the id of the recipient of the message.
  var recipientIdToFetch = function() {
    var threadId = message.threadId;
    var ids = threadId.split(":");
    var recipientId = (ids[0] == message.senderId) ? ids[1] : ids[0];
    return collectionAccess.objectID(recipientId);
  };
  
  // This method creates both the aps and extras objects to be used in the push
  // notification.
  var pushDataFromMessageAndUser = function(user) {
    return {
      aps: {
        alert: notificationAlertMessage(user), 
        badge: 0, 
        sound: "notification.wav"
      },
      extras: {
        messageText: message.message,
        creationDate: message._kmd.ect,
        threadId: message.threadId,
        senderId: message.senderId,
        entityId: messageId
      }
    };
  };
  
  // This method calculates the text of the push notification based on the 
  // sender and the text of the message.
  var notificationAlertMessage = function(user) {
    var alertMessageComponents = [];
    var alertMessage = user.first_name + " ";
    alertMessage += user.last_name + ": ";
    alertMessage += message.message;
    return alertMessage;
  };
  
  // This method is executed after the recipient user has been fetched from the
  // user collection.  It will proceed with making the push notification call to
  // the recipient user with the correct information.
  var callback = function(error, results) {
    if(error) {
      response.body = {
        error: error.message
      };
      response.complete(400);
    } else {
      var pushData = pushDataFromMessageAndUser(results[1]);
      push.sendPayload(recipient, pushData.aps, pushData.extras);
      response.complete(200);
    }
  };
  
  // This kicks off the process to fetch the recipient and update the thread
  // Once that is complete, it will call the callback function to send the
  // push notification.
  async.parallel([updateLatestMessage, getRecipient], callback);
}

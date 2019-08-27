'use strict';

exports.handler = async (event, context, callback) => {
  console.log('Received email address:', event.request.userAttributes.email);

  if (event.request.userAttributes.email !== null) {
    if (event.request.userAttributes.email.match(/[A-Z]+/)) {
      console.log('upper case true');
      callback(new Error('Email address MUST be lower case'));
    } else {
      console.log('lower case true');
      callback(null, event);
    }
  } else {
    console.log('Email evaluated as NULL, exiting with no action');
    callback(new Error('Cannot validate email address'));
  }
};

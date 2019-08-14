const AWS = require('aws-sdk');
const fs = require('fs');
let argv = require('minimist')(process.argv.slice(2));

if(!argv.userPoolId) console.error('userPoolId must be set!');

const UserPoolId = argv.userPoolId;
const region = argv.region || 'eu-west-2';
const profile = argv.profile || 'default';
const fileName = argv.filename || 'script.bat';

let credentials = new AWS.SharedIniFileCredentials({
  profile
});

AWS.config.credentials = credentials;

if (!AWS.config.region) {
  AWS.config.update({
    region
  });
};

const cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider();

getUserGroups()
  .then(groups => {
    let promises = [];

    groups.forEach(group => {
      promises.push(
        getAllUsers(group.GroupName)
        .then(commands => {
          return commands;
        })
        .catch(err => console.log(err, err.stack))
      );
    });

    return Promise.all(promises).then(commandArrays => {
      fs.writeFile(fileName, '', () => {})

      let writeStream = fs.createWriteStream(fileName);
      writeStream.write("@echo off \n" + "echo Adding users to groups... \n");

      for (let i = 0; i < commandArrays.length; i++) {
        let array = commandArrays[i];
        if (array.length) {
          for (let y = 0; y < array.length; y++) {
            let command = array[y];
            writeStream.write(command + "\n");
          }
        }
      }

      writeStream.write("echo Done.");

      writeStream.on('finish', () => {
        console.log(`Successfully created file: ${process.cwd()} ${fileName}`);
      });

      writeStream.end();
    });
  })
  .catch(err => console.log(err, err.stack));

function getUserGroups() {
  let concatData = [];

  let params = {
    UserPoolId,
    Limit: 60
  };

  function recursiveUserGroups(params, resolve, reject) {
    cognitoidentityserviceprovider.listGroups(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        return reject(err);
      } 

      concatData = concatData.concat(data.Groups);
      
      if (!data.NextToken) {
        return resolve(concatData);
      } else {
        params.token = data.NextToken;
        recursiveUserGroups(params, resolve, reject); 
      }
    });
  }

  return new Promise((resolve, reject) => {
    recursiveUserGroups(params, resolve, reject);
  });
};

function getAllUsers(GroupName) {
  let users = [];

  let params = {
    GroupName,
    UserPoolId,
    Limit: 60
  };

  function recursiveUsersInGroup(params, resolve, reject) {
    let commands = [];

    cognitoidentityserviceprovider.listUsersInGroup(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        return reject(err);
      }

      users = users.concat(data.Users);
  
      if (!data.NextToken) {
        for (let i = 0; i < users.length; i++) {
          const user = users[i];
          let command = `call aws cognito-idp admin-add-user-to-group --user-pool-id ${UserPoolId} --group-name ${GroupName} --username ${user.Username}`;

          commands.push(command)
        }

        return resolve(commands);
      } else {
        params.NextToken = data.NextToken;
        recursiveUsersInGroup(params, resolve, reject); 
      }
    });
  }
  
  return new Promise((resolve, reject) => {
    recursiveUsersInGroup(params, resolve, reject);
  });
};
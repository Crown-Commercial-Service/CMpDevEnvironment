const AWS = require('aws-sdk');
const fs = require('fs');
let argv = require('minimist')(process.argv.slice(2));

if (!argv.userPoolId) console.error('userPoolId must be set!');

// Provide params or use defaults -> UserPoolId required
const UserPoolId = argv.userPoolId;
const region = argv.region || 'eu-west-2';
const profile = argv.profile || 'default';
const fileName = argv.filename || 'script.bat';

// Fetch credentials from .aws/credentials
let credentials = new AWS.SharedIniFileCredentials({
  profile
});

// Use correct credentials
AWS.config.credentials = credentials;

// Ensure we're using the given region
if (!AWS.config.region) {
  AWS.config.update({
    region
  });
}

const cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider();

getUserGroups()
  .then(async groups => {
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

    const commandArrays = await Promise.all(promises);
    fs.writeFile(fileName, '', () => {});
    let writeStream = fs.createWriteStream(fileName);
    writeStream.write(
      '@echo off \n' + 'echo Converting emails to lowercase... \n'
    );
    for (let i = 0; i < commandArrays.length; i++) {
      let array = commandArrays[i];
      if (array.length) {
        for (let y = 0; y < array.length; y++) {
          let command = array[y];
          writeStream.write(command + '\n');
        }
      } else {
        writeStream.write(
          'echo 0 users found with uppercase characters in email! \n'
        );
      }
    }
    writeStream.write('echo Done.');
    writeStream.on('finish', () => {
      console.log(`Successfully created file: ${process.cwd()} ${fileName}`);
    });
    writeStream.end();
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
}

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
          let email;

          // Get current users email
          user.Attributes.forEach(att => {
            if (att.Name === 'email') email = att.Value;
          });

          // If user has uppercase email add command to array
          if (email.match(/[A-Z]+/)) {
            let command = `call aws cognito-idp admin-update-user-attributes --user-pool-id ${UserPoolId} --username ${
              user.Username
            } --user-attributes Name="email",Value="${email.toLowerCase()}"`;
            commands.push(command);
          }
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
}

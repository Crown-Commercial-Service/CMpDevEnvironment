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

getAllUsers()
  .then(commands => {
    fs.writeFile(fileName, '', () => {});
    let writeStream = fs.createWriteStream(fileName);

    writeStream.write(
      '@echo off \n' + 'echo Converting emails to lowercase... \n'
    );

    if (commands.length) {
      for (let i = 0; i < commands.length; i++) {
        let command = commands[i];
        writeStream.write(command + '\n');
      }
    } else {
      writeStream.write('echo 0 users found with uppercase emails. \n');
    }

    writeStream.write('echo Done.');
    writeStream.on('finish', () => {
      console.log(`Successfully created file: ${process.cwd()} ${fileName}`);
    });
    writeStream.end();
  })
  .catch(err => console.error(err));

function getAllUsers() {
  let users = [];

  let params = {
    UserPoolId,
    Limit: 60
  };

  function recursiveUsersInPool(params, resolve, reject) {
    let commands = [];

    cognitoidentityserviceprovider.listUsers(params, (err, data) => {
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
            let command = generateCommand(user, email);
            commands.push(command);
          }
        }

        return resolve(commands);
      } else {
        params.NextToken = data.NextToken;
        recursiveUsersInPool(params, resolve, reject);
      }
    });
  }

  return new Promise((resolve, reject) => {
    recursiveUsersInPool(params, resolve, reject);
  });
}

function generateCommand(user, email) {
  return `call aws cognito-idp admin-update-user-attributes --user-pool-id ${UserPoolId} --username ${
    user.Username
  } --user-attributes Name="email",Value="${email.toLowerCase()}"`;
}

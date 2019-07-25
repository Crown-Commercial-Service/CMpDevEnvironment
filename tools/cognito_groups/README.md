# aws-node

Used to generate a script containing aws cli commands to re-add existing users from all user groups after removal. 

Uses the [aws-sdk](https://www.npmjs.com/package/aws-sdk).

## Installation

First ensure node/npm is installed [node](https://nodejs.org/en/download/). Verify by checking version:

```bash
node --version
```

Install packages:

```bash
npm i
```

## Usage
Ensure credentials are set in /aws/credentials

Command parameters:
```bash
node run 
  --userPoolId    # Required 
  --region        # Defaults to eu-west-2
  --profile       # Defaults to 'default'
  --filename      # Defaults to script.bat
```

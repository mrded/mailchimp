#!/usr/bin/env node 

const fs = require('fs');

const hashesPromise = new Promise(function(resolve, reject) {
  const readline = require('readline');

  let hashes = [];

  readline.createInterface({
    input: fs.createReadStream(process.argv[2]),
  }).on('line', function(line) {
    hashes.push(line);
  }).on('close', function() {
    resolve(hashes);
  }).on('error', reject);
}); 

const emailsPromise = new Promise(function(resolve, reject) {
  const csv = require('csv-parser')
  const md5 = require('md5');

  let emails = {};

  fs.createReadStream(process.argv[3])
    .pipe(csv())
    .on('data', function(data) {
      let email = data['Email Address'].toLowerCase().trim();
      emails[md5(email)] = email;
    })
    .on('end', function() {
      resolve(emails);
    })
    .on('error', reject);
});

emailsPromise.then(function(emails) {
  process.stdout.write("Email,Exclude\n");

  return hashesPromise.then(function(hashes) {
    for (hash of hashes) {
      if (emails.hasOwnProperty(hash)) {
        process.stdout.write(emails[hash] + ",economist\n");
      }
    }
  });
});

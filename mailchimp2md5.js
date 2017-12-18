#!/usr/bin/env node 

const csv = require('csv-parser')
const fs = require('fs');
const md5 = require('md5');

fs.createReadStream(process.argv[2])
  .pipe(csv())
  .on('data', function(data) {
    let email = data['Email Address'];
    let hash = md5(email);

    process.stdout.write(hash + "\n");
  });

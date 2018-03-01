#!/usr/bin/env node 

const Mailchimp = require('mailchimp-api-v3');
const ProgressBar = require('progress');

if (!process.env.MAILCHIMP_KEY) {
  throw new Error('MAILCHIMP_KEY is missing');
}

if (!process.env.MAILCHIMP_LIST_ID) {
  throw new Error('MAILCHIMP_LIST_ID is missing');
}

const key = process.env.MAILCHIMP_KEY;
const list_id = process.env.MAILCHIMP_LIST_ID;
const mailchimp = new Mailchimp(key);

function totalEmails() {
  const responsePromise = mailchimp.get('/lists/' + list_id + '/members', {
    status: 'subscribed',
    count: 0
  });

  return responsePromise.then(function(response) {
    return response.total_items;
  });
}

function getEmails(count, offset) {
  const responsePromise = mailchimp.get('/lists/' + list_id + '/members', {
    status: 'subscribed',
    count: count,
    offset: offset,
  });

  return responsePromise.then(function(response) {
    return response.members.map(function(member) {
      return member.email_address;
    });
  });
}

function getAllEmails(offset, progress) {
  return getEmails(50, offset).then(function(emails) {
    progress.tick(emails.length);

    if (emails) {
      return getAllEmails(offset + emails.length, progress).then(function(items) {
        return emails.concat(items);
      });
    }

    return [];
  });
}

console.log('Download Emails from Mailchimp.');

totalEmails().then(function(total) {
  const progress = new ProgressBar('[:bar] :percent (:current / :total) :rate/bps', { width: 250, total: total });

  getAllEmails(0, progress).then(console.log);
});

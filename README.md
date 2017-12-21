Mailchimp Scripts
========================

# Install

    npm i
    ln -s mailchimp-md5.js /usr/local/bin/mailchimp-md5
    ln -s md5-mailchimp.js /usr/local/bin/md5-mailchimp

## Convert email to MD5

    mailchimp-md5 email.cvs > wikijob_$(date +'%d%m%y%H%M%S')_MD5.txt

## Match MD5 hashes with emails

    md5-mailchimp hashes.cvs emails.cvs

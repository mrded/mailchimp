Mailchimp Scripts
========================

# Install

    npm i
    ln -s mailchimp2md5.js /usr/local/bin/mailchimp2md5
    ln -s md52mailchimp.js /usr/local/bin/md52mailchimp

## Convert email to MD5

    mailchimp2md5 email.cvs > wikijob_$(date +'%d%m%y%H%M%S')_MD5.txt

## Match MD5 hashes with emails

    md52mailchimp hashes.cvs emails.cvs

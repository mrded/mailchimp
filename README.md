Mailchimp Scripts
========================

# Install

    npm i
    ln -s mailchimp-md5.js /usr/local/bin/mailchimp-md5
    ln -s md5-mailchimp.js /usr/local/bin/md5-mailchimp

## Convert email to MD5

    mailchimp-md5 email.csv > wikijob_$(date +'%d%m%y%H%M%S')_MD5.txt

## Match MD5 hashes with emails

    md5-mailchimp hashes.csv emails.csv

# How to get suppression list from Economist

1. Export mailchimp list as `email.csv`.
2. Hash emails with md5: `mailchimp-md5 email.csv > wikijob_$(date +'%d%m%y%H%M%S')_MD5.txt`
3. Put a list with hashed emails into `sftp.lolagrove.com` sftp, `economist/upload` folder.
4. Wait.
5. Pull suppression list of hashed emails from `sftp.lolagrove.com` sftp, `economist/download` folder.
6. Match suppression list of hashed emails with mailchimp list: `md5-mailchimp hashes.csv emails.csv > exclude.csv`.
7. Import `exclude.cvs`, to back to mailchimp and mark emails to be excluded from **Economist**.

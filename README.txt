SSH Failure Logging System
Allow text alert notification given a number of failed ssh connections.
Installation
a. Update and Upgrade your system
b. Install and configure ssmtp for email to text notification.
    Set up the ssmtp.conf file by adding the Sender's email, password, and mail hub.
    EOF should resemble:
        FromLineOverride=YES
        AuthUser=(sender email)
        AuthPass=(sender email password)
        mailhub=(sender mail hub ex: smtp.gmail.com:587)
        UseSTARTTLS=YES
    You can go to your email client and ask for an app password
    to avoid using your own password.
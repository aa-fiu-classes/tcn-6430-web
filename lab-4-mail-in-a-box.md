---
layout: page
title: "Lab 4: Mail-in-a-Box"
group: "Lab 4"

---

* toc
{:toc}

## Overview

The goal of this project is to experience "pain" of creating and maintaining an modern email server.
Email, as it was originally designed, already includes a number of components and existing implementations (sendmail, postfix, exim) have even more configuration options and deployment cases.
With today's level of spam, one needs to worry about configuring spam filters (e.g., SpamAssassin), fight ISPs to not block port 25 and not block connections from IP, as well as enable security features (SPF, DKIM, DMARC).

While one can do all of these and more by just installing necessary packages in any of the linux distributions, folks from [Mail-in-a-Box](https://mailinabox.email/) created a set of scripts that can deploy all of the modern things in a matter of minutes.
So, in this lab, we will use that and try to deploy it in Google Cloud VM.
As there are restrictions on uses of port 25 for Google Cloud it will not be a fully functional mail server, but it will work in a limited capacity.

## Tasks

### 1. Create instance for Mail-in-a-Box

- Create instance `box-1`

- Instance type: general-purpose, E2 series, e2-micro in `us-east1-b` zone

- Ubuntu 22.04 LTS image.  **Note that it must be Ubuntu 22.04 LTS, it will not work with any other version**

- Disk space: you can leave the default 10 GB disk

- Firewall rules: you will need to select "Allow HTTP" and "Allow HTTPS", as well as create custom firewall rule to open ports 53/tcp, 53/udp (it is acting also as DNS server), 465/tcp, 587/tcp, 993/tcp, 4190/tcp, and 2525/tcp.

### 2. Delegating mail zone

Mail-in-a-box simplifies all operations, including managing the DNS zone.
For simplicity, we will be using zone  `lab4.<your-delegated-zone>` (e.g., `lab4.a999.tcn6430.iu4.ru`) for this.
You will need to add the following records in your lab2's DNS server configuration.

```
lab4      IN  NS  box.lab4
box.lab4  IN  A   external IP address of the new instance>
```

Note. Don't forget to increase zone's serial number. It will not properly reload otherwise.

Then sign the zone (if you haven't disabled DNSSEC), and reload the config

```
sudo rndc sign <your-zone>
sudo rndc reload
```

You will need to get back to this one more time

### 3. Configuring Mail-in-a-Box

There isn't really much to configure, except running a script that will install everything.
So, just SSH to the instance and run the following:

```
curl -s https://mailinabox.email/setup.sh | sudo bash
```

During the process it is important that you specify the correct name for the zone (`lab4.<your-zone>`) and hostname of the box (`box.lab4.<your-zone>`).  In other words, the answer to the first question should be something like this

```
me@lab4.aXXXX.tcn6430.iu4.ru
```

and for the second

```
box.lab4.aXXXX.tcn6430.iu4.ru
```

It will also ask about the timezone, so pick one that you think you want to live in.  May be Hawaii would be good, or US/Eastern.


Then just wait.  You may sip a coffee.  You will have time to actually make one, drink it, and come back.

Finally, it should ask you for the password and, if everything good with DNS (make sure you have delegated in the parent domain and opened port 53 on the instance), you will be greeted with something like this:

```
-----------------------------------------------

Your Mail-in-a-Box is running.

Please log in to the control panel for further instructions at:

https://XXXXXXXXXXXXXXX/admin

You will be alerted that the website has an invalid certificate. Check that
the certificate fingerprint matches:

3F:2F:FD:6D:E1:56:F8:A0:97:E5:3C:D1:B7:7C:C8:F9:F3:CB:6B:BE:0F:F6:0A:D3:DA:9A:2B:D4:F1:BD:DE:61

Then you can confirm the security exception and continue.
```

### 4. Fine tuning

After the install, you have self-signed TLS certificates and it is a good idea to get a real ones.

Just go to https://box.lab4.aXXXX.tcn6430.iu4.ru/admin -> `System` -> `TLS (SSL) Certificates` and click on `Provision` button.
It should quickly succeed.  If any issues during the provisioning, you can fix the issues, and then click provision again.

You can check system status in `System` -> `Status Checks` tab.

### 4. Checks

At this point, you can try to receive email on your new address, as well as create any number of users and alises.

To see real time progress with mailing operations, you can open `/var/log/mail.log` log file or "tail" it in SSH:

```
sudo tail -f /var/log/mail.log
```

Now. Try sending email to you and then check headers.  You should be able to receive email (at least it worked for the instructor from Gmail and FIU servers).

Try to send email.
This part is expected to fail for various reasons.


## Conclusion / Submission

Submit your report to Canvas quiz, answering the posted question.

Print status report (print to PDF and submit PDF to the quiz).  Most of the things should be in green, except
- "Incoming Mail (SMTP/postfix) is running but is not publicly accessible"
- "Outbound mail (SMTP port 25) seems to be blocked by your network. "
- "MTA-STS policy is missing"

What is dovecot (server)?

What is postfix (server)?

How many and which public/private keys are used by mail-in-a-box services? There are at least three you need to list.

Which IP addresses mail-in-a-box configured in SPF policy to allow sending mail from?

Explain the default DMARC policy mail-in-a-box configured for you

What is graylisting and how it works?

List reasons why you cannot send email our using your new Mail-in-a-Box instance.  There are at least two reasons (and in reality, many more).

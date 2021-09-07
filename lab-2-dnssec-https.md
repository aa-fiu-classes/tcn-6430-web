---
layout: page
title: "Lab 2: DNSSEC and HTTPS"
group: "Lab 2"

---

* toc
{:toc}

## Overview

The goal of this lab is to secure DNS zone from the lab 1 (i.e., enable DNSSEC) and then use the zone to build a micro CDN service.
As a side effect, you will also learn how to create a simple HTTP/Apache server instance and serve simple files from there.
In addition, the lab will also show you how you can secure web server with HTTPS certificate, a different level protection compared to DNSSEC.
We will use tools provided by Let's Encrypt CA and the process is quite simple, involves just running a few commands (but we will have an expected issue with it, for you to analyze).

## Tasks

### 1. DNSSEC

Lab 1 left us hanging about the DNSSEC.  [This document](https://www.digitalocean.com/community/tutorials/how-to-setup-dnssec-on-an-authoritative-bind-dns-server-2) gives a quite comprehensive description of the DNSSEC, its internals, and what should happen to enable and maintain DNSSEC for your zone.
I assume that you already read it.

Luckily, in order to enable DNSSEC in "regular" circumstances, Bind software since its recent version includes a very simple method to work with DNSSEC.
It still requires a little bit of manual work, but only a little bit.
Majority of the complex process is done by Bind software itself.

#### 1.1 Reorganize location 

First thing is that we need to do a bit of reorganization of our zone database.
Bind will be adding new records to the zone and needs write permission to the same folder as the original zone file.
It can be done in various way, the simplest is simply move the zone file to `/var/cache/bind` folder:

    sudo mv /etc/bind/full.path.to.the.zone.db /var/cache/bind

and updating the path in `/etc/bind/named.conf.local`.

#### 1.2 Enabling the magic DNSSEC option

With Bind version 9.16 and newer (the one installed in Ubuntu 20.04 we are using), enabling DNSSEC zone signing is a simple as adding a single line to the zone configuration:

    zone "delegated.domain.name" {
        type master;
        file "/etc/bind/full.path.to.the.zone.db";
        dnssec-policy default;  # this is the line you need to add
    };

and then reload the zone using

    sudo rndc reload

If everything is correct, you should see new files generated in `/var/cache/bind` folder, like these (actual names will include your zone name):

	/var/cache/bind$ ls -1
	Ktcn6430.iu4.ru.+013+45365.key
	Ktcn6430.iu4.ru.+013+45365.private
	managed-keys.bind
	managed-keys.bind.jnl
	tcn6430.iu4.ru
	tcn6430.iu4.ru.signed
	tcn6430.iu4.ru.signed.jnl

If you don't see these, check for errors in Bind logs:

    sudo journalctl -u bind9

You can also check the actual signatures using `dig` command:

    dig +dnssec your.zone ns @localhost

#### 1.3 Submitting DS record

If you get this far, you got the zone signed, but DNSSEC is not yet fully enabled, as the parent zone does not know about that.
In order for the parent zone be aware that you have enabled DNSSEC and want your zone data to be validated, you need to insert a `DS` record to the parent zone.
For our lab, you need to prepare and send the `DS` record to the instructor.

To do so, you just need to run the following command and copy paste the output:

    dnssec-dsfromkey /var/cache/bind/K<your-zone>.+013+45365.key

This command will convert `DNSKEY` record into a `DS` and as soon as instructor adds it to your zone, you will be ready to proceed.


### 2 HTTP Server

Instructions below assume you are working with `http-1` instance that uses Ubuntu 20.04 Linux VMs.
If you are using a different environment (for the lab or in other environment), you can follow the official instructions provided on [certbot website](https://certbot.eff.org/).

### 1. Create a new VM

You would need to create 1 VM HTTP server instance named "http-1" (if you choose different name, you will need to adjust the following instructions):

- Instance type: general-purpose, E2 series, e2-micro in `us-east1-b` zone

- Ubuntu 20.04 LTS image

- Disk space: you can leave the default 10 GB disk

- Firewall rules: make sure you have selected "Allow HTTP traffic" and "Allow HTTPS traffic".  This will automatically add proper firewall tags.

### 2. Configuring VM

You need to install Apache HTTP server and upload some content (cute cat images are highly suggested) to be served from this HTTP instance.

Before you start, note the public IP addresses of the instance. You will need them during configuration of DNS server in the next step.

SSH to the server and start configurations (using Web interface, gcloud command line suite, or just ssh in the command line).

Update/upgrade packages and install `apache` HTTP server:

```
sudo apt update
sudo apt upgrade
sudo apt install apache2
```

With default configuration, the installed Apache HTTP server will serve content from `/var/www/html` folder.
Upload any information (= cats) to this folder and create appropriate `index.html` files.
In addition, for Gradescope verification, create the following files:

- `/var/www/html/instance.txt` with content `http-1` as the first line.
- `/var/www/html/owner.txt` with your name as the content

To test before going to the next step, you can simply type in your web browser the public IP of the instance and path to the file, such as (use IP of your instance!)

    http://your-vm.public.ip.address/instance.txt

### 3. Create DNS Name for Your Server

You already have a working DNS zone, so use it.

You will need to add a single A record for www sub-domain.  For example, it will look like

    www    IN    A    your-vm.public.ip.address

Do not forget to increase the serial number for your zone and then reload the zone using

    sudo rndc reload



If you did not have a zone delegated, but wanted to have some domain name, you could use free services, for examples [Duck DNS](https://www.duckdns.org/).  This is just for your information, if you want it for other purposed.


### 4. Enabling HTTPS

The manual way of enabling HTTPS is as daunting as manual way dealing with DNSSEC (ok, a little bit less daunting, but still).
Luckily, we have an automated way of doing this, thanks to Let's Encrypt CA.

All you need to do is to install a `cerbot` app:
	
    sudo snap install --classic certbot

Done.

Now. A deeeeeeeeeep breath, exhale, and continue.


To get a certificate for your domain and automatically configure Apache server, run the following command (use your delegated domain name!):

    sudo certbot --apache -d www.your-zone

It will prompt for
- your email
- to agree with terms and conditions
- whether you want your email to be shared with Electronic Frontier Foundation.

After that `certbot` will generate public/private key pair, generate certificate request, submit it to Let's Encrypt, and will perform proper validation that you have control over the website.

The final question that `certbot` will ask is how you want HTTPS be activated: just run HTTPS in parallel to HTTP or force traffic be redirected from HTTP to HTTPS.
Either way can work for the lab, forced redirection preferred (option `2` when asked).

### Check Certificate and Prepare Submission

As a final check, type a bit updated URL in the browser (note there is `https://` now):

    https://www.your-zone/instance.txt

After that, open certificate properties (in Chrome, click on "lock" icon and the click on "Certificate"; similar actions in other browsers).
Take a note of certificate serial number, you will need this for the submission.


## Conclusion / Submission

Submit your report to Canvas quiz, answering the posted question.

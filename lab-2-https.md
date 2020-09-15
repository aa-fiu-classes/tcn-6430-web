---
layout: page
title: "Lab 2: HTTP + HTTPS"
group: "Lab 2"

---

* toc
{:toc}

## Overview

The goal of this lab is to create a simple HTTP/Apache server instance serving cat images using the Google Cloud infrastructure.
In addition, you will obtain HTTPS certificate for your HTTP instance using tools provided by Let's Encrypt CA (actually, these are now tools following [ACME standard](https://tools.ietf.org/html/rfc8555)).
The process is quite simple and involves just running a few commands.

<!-- Before these automation tools, it involved a lot of manual generation of certificates, certificate requests, manually sending to a CA, and then properly configuring your apache server to use those certificates. -->

## Tasks

Instructions below assume you are working with `http-1` instance that uses Ubuntu 20.04 Linux VMs.
If you are using a different environment (for the lab or in other environment), you can follow the official instructions provided on [certbot website](https://certbot.eff.org/).


### 1. Create VM

You would need to create 1 VM HTTP server instance named "http-1" (if you choose different name, you will need to adjust the following instructions):

- Instance type: `micro-instance` in `us-east1-b` zone.

- OS: Ubuntu Linux 20.04

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

    http://1.1.1.1/instance.txt

### 3. Create DNS Name for Your Server

There are various way you can do it.  The simplest way for this lab would be to go to [Duck DNS](https://www.duckdns.org/) service and create a DNS name in `.duckdns.org` zone.
After you selected an available name (e.g., `tcn6430-yourname-http-1`), update IP address to the public IP address of your `http-1` instance.

To test that things are going well, type in the browser the selected domain name instead of IP address

    http://tcn6430-yourname-http-1.duckdns.org/instance.txt



### 4. Obtain Certificate 

You will need to install a few more dependencies:

- Add Certbot PPA

    You'll need to add the Certbot PPA to your list of repositories. To do so, run the following commands on the command line on the machine and follow the prompts:
    
        sudo apt-get update
        sudo apt-get install software-properties-common
        sudo add-apt-repository universe
        sudo add-apt-repository ppa:certbot/certbot
        sudo apt-get update

- Install Certbot

	Run this command on the command line on the machine to install Certbot:
	
	    sudo apt-get install certbot python-certbot-apache

Now. A deeeeeeeeeep breath, exhale, and continue.


To get a certificate for your domain and automatically configure Apache server, run the following command (use your delegated domain name!):

    sudo certbot --apache -d tcn6430-yourname-http-1.duckdns.org

It will prompt for
- your email
- to agree with terms and conditions
- whether you want your email to be shared with Electronic Frontier Foundation.

After that `certbot` will generate public/private key pair, generate certificate request, submit it to Let's Encrypt, and will perform proper validation that you have control over the website.

The final question that `certbot` will ask is how you want HTTPS be activated: just run HTTPS in parallel to HTTP or force traffic be redirected from HTTP to HTTPS.
Either way can work for the lab, forced redirection preferred (option `2` when asked).

### Check Certificate and Prepare Submission

As a final check, type a bit updated URL in the browser (note there is `https://` now):

    https://tcn6430-yourname-http-1.duckdns.org/instance.txt

After that, open certificate properties (in Chrome, click on "lock" icon and the click on "Certificate"; similar actions in other browsers).
Take a note of certificate serial number, you will need this for the submission.


## Conclusion / Submission

In Gradescope, submit

- HTTPS URL

- Serial number of the certificate

- Description of any problems, road blocks, what you have learned, what was interesting, not interesting, etc.

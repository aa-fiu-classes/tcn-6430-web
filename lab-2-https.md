---
layout: page
title: "Lab 2: HTTPS"
group: "Lab 2"

---

* toc
{:toc}

## Overview

In this lab, you will obtain HTTPS certificates for your HTTP instances from lab-1.
Using tools provided by Let's Encrypt CA (actually, these are now tools following [ACME standard](https://tools.ietf.org/html/rfc8555)), the process is quite simple and involves just running a few commands.
Before these automation tools, it involved a lot of manual generation of certificates, certificate requests, manually sending to a CA, and then properly configuring your apache server to use those certificates.

## Tasks

### Ensure Firewall Rules

Make sure you have enabled "Allow HTTP traffic" and "Allow HTTPS traffic" checkboxes for `http-1` and `http-2` instance.
Note that we would need both, HTTP and HTTPS in order it to work.

### Install Prerequisites

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

### Obtain Certificate

To get a certificate for your domain and automatically configure Apache server, run the following command (use your delegated domain name!):

    sudo certbot --apache -d www.gXX.tcn6430.iu4.ru

It will prompt for
- your email
- to agree with terms and conditions
- whether you want your email to be shared with Electronic Frontier Foundation.

After that `certbot` will generate public/private key pair, generate certificate request, submit it to Let's Encrypt, and will perform proper validation that you have control over the website.

Because our DNS server points to two different HTTP instances, this step can (should) actually fail. Let's Encrypt is trying to do a proper validation that you own the server from different points of the world.
If it fails, you would need (temporary) change you configuration of your `dns-server-1` instance:

- if you running certbot on `http-1`, set IP address in both `-version1` and `-version2` of zone config to IP address of `http-1` instance;

- if you running certbot on `http-2`, set IP address in both `-version1` and `-version2` of zone config to IP address of `http-2` instance.

For this lab, you only need to do one, so you can just pick HTTP instance you want to work with.

The final question that `certbot` will ask is how you want HTTPS be activated: just run HTTPS in parallel to HTTP or force traffic be redirected from HTTP to HTTPS.
Either way can work for the lab, forced redirection preferred (option `2` when asked).

### Check Certificate and Prepare Submission

In your browser, go to https://www.gXX.tcn6430.iu4.ru/cat.jpg (use your delegated domain name).
If everything works, your favorite cat picture should open correctly.

Open certificate properties (in Chrome, click on "lock" icon and the click on "Certificate"; similar actions in other browsers).
Take a note of certificate serial number.

## Conclusion / Submission

In Gradescope, submit

- HTTPS URL

- Serial number of the certificate

- Description of any problems, road blocks, what you have learned, what was interesting, not interesting, etc.

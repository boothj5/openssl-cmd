#!/bin/bash

openssl rsa -in $1 -pubin -text -noout

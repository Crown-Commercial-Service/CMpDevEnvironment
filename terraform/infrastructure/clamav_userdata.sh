#!/bin/bash

sudo systemctl enable clamd@scan.service
sudo systemctl start clamd@scan.service
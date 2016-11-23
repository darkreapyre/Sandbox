#!/usr/bin/env bash

echo # install RStudio Shiny
# https://github.com/rstudio/shiny-server

R_REPO="deb http://cran.rstudio.com/bin/linux/ubuntu trusty/"
APPS_DIR=/vagrant/apps

sudo add-apt-repository "$R_REPO"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
sudo add-apt-repository -y ppa:marutter/rdev

sudo apt-get -y update
sudo apt-get -y upgrade
# --force-yes to handle the un-verified deb
sudo apt-get -y install r-base-dev --force-yes
sudo apt-get -y clean

# find the lastest build of Shiny Server
sudo wget https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "$APPS_DIR/version.txt"
VERSION=`cat $APPS_DIR/version.txt`

# Install the latest Shiny Server build
sudo wget "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O $APPS_DIR/Shiny_Server-latest.deb

sudo apt-get -y install gdebi
sudo gdebi -n $APPS_DIR/Shiny_Server-latest.deb

# R is too old for CRAN's latest Rcpp
sudo wget http://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_0.10.5.tar.gz -O $APPS_DIR/Rcpp_0.10.5.tar.gz
sudo R CMD INSTALL $APPS_DIR/Rcpp_0.10.5.tar.gz

sudo R -e "install.packages(c('shiny','rmarkdown','knitr', 'rzmq', 'repr', 'IRkernel', 'IRdisplay', 'rjson', 'rPython', 'plyr', 'psych', 'reshape2'), repos=c('http://irkernel.github.io/', 'http://cran.rstudio.com/', 'http://www.freestatistics.org/cran/'))"

sudo cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

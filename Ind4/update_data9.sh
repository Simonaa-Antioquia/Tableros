## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Ind4
sudo mkdir /srv/shiny-server/Ind4


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Ind4

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Ind4/ /srv/shiny-server/Ind4 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Ind4

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server

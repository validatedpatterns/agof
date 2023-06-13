#!/bin/bash
#Create cloudinit info
echo 'idm_cloud_init_metadata_vault: "'$(gzip -c9 < idm_metadata.yml | base64)'"' > idm_vault.yml
echo 'idm_cloud_init_userdata_vault: "'$(gzip -c9 < idm_userdata.yml | base64)'"' >> idm_vault.yml
echo 'sat_cloud_init_metadata_vault: "'$(gzip -c9 < sat_metadata.yml | base64)'"' > sat_vault.yml
echo 'sat_cloud_init_userdata_vault: "'$(gzip -c9 < sat_userdata.yml | base64)'"' >> sat_vault.yml

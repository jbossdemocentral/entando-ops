#!/bin/bash
if [ "$PREPARE_DB" = "true" ]; then
  echo "Entando database rebuild requested. Replacing existing database with database built from Maven project"
  rm -Rf /entando-data/databases/* > /dev/null 2>&1
  mkdir -p /entando-data/databases/ > /dev/null 2>&1
  cp /entando-database-templates/* /entando-data/databases/ -rf
  chmod -Rf ug+rw /entando-data/databases/
elif [ !  -d /entando-data/databases/entandoPort  ]; then
  echo "New Entando instance detected. Copying default Entando Derby database for optional use."
  mkdir -p /entando-data/databases/ > /dev/null 2>&1
  cp /entando-database-templates/* /entando-data/databases/ -rf
  chmod -Rf ug+rw /entando-data/databases/
fi
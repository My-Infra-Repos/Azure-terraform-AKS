
resource "azurerm_subnet" "example-nonprod-db" {
  name                 = "example-nonprod-db-subnet"
  // resource_group_name  = azurerm_resource_group.example-nonprod-db.name
  resource_group_name  = data.terraform_remote_state.rg.outputs.name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.name
  address_prefixes     = [var.address_space]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
resource "azurerm_private_dns_zone" "example-nonprod-db" {
  name                = var.dns_name
  resource_group_name = data.terraform_remote_state.rg.outputs.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example-nonprod-db" {
  name                  = "example-nonprod-dbVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example-nonprod-db.name
  virtual_network_id    = data.terraform_remote_state.vnet.outputs.id
  resource_group_name   = data.terraform_remote_state.rg.outputs.name
}

resource "azurerm_postgresql_flexible_server" "example-nonprod-db" {
  name                   = var.name
  resource_group_name    = data.terraform_remote_state.rg.outputs.name
  location               = var.location
  version                = "14"
  delegated_subnet_id    = azurerm_subnet.example-nonprod-db.id
  private_dns_zone_id    = azurerm_private_dns_zone.example-nonprod-db.id
  administrator_login    = "psqladmin"
  administrator_password = "Moon@2023"
  zone                   = "1"

  storage_mb = 65536
  

  // sku_name   = "GP_Standard_D4s_v3"
  sku_name   =  "GP_Standard_D4ds_v4"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example-nonprod-db]

}

resource "azurerm_postgresql_flexible_server_configuration" "example-nonprod-db" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.example-nonprod-db.id
  // value     = "CUBE,CITEXT,BTREE_GIST"
  value ="address_standardizer, address_standardizer_data_us, amcheck, bloom, btree_gin, btree_gist, citext, cube, dblink, dict_int, dict_xsyn, earthdistance, fuzzystrmatch, hypopg, hstore, intagg, intarray, isn, lo, ltree, orafce, pageinspect, pg_buffercache, pg_cron, pg_freespacemap, pg_partman, pg_prewarm, pg_repack, pg_stat_statements, pg_trgm, pg_hint_plan, pg_visibility, pgaudit, pgcrypto, pglogical, pgrouting, pgrowlocks, pgstattuple, plpgsql, plv8, postgis, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology, postgres_fdw, sslinfo, semver, timescaledb, tsm_system_rows, tsm_system_time, unaccent, uuid-ossp"
}

resource "azurerm_postgresql_flexible_server_database" "pocdb" {
  name      = "pocdb"
  server_id = azurerm_postgresql_flexible_server.example-nonprod-db.id
  collation = "en_US.utf8"
  charset   = "utf8"
  depends_on = [azurerm_postgresql_flexible_server_configuration.example-nonprod-db]
//  provisioner "remote-exec" {
//     inline = [
//     "psql  -d ${azurerm_postgresql_flexible_server_database.pocdb.name} < ./init_scripts/init_postgres.sql",
//     "psql  -d ${azurerm_postgresql_flexible_server_database.pocdb.name} < ./init_scripts/create-system-resources.sql"
//     ]

//     connection {
//     type="ssh"
//     user=azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login
//     password=azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password
//     host=azurerm_private_dns_zone.example-nonprod-db.name
//   }
//   }

}

resource "azurerm_postgresql_flexible_server_database" "workdb" {
  name      = "workdb"
  server_id = azurerm_postgresql_flexible_server.example-nonprod-db.id
  collation = "en_US.utf8"
  charset   = "utf8"
  depends_on = [azurerm_postgresql_flexible_server_configuration.example-nonprod-db]
  // -h ${azurerm_private_dns_zone.example-nonprod-db.name}
// "PGPASSWORD=${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password} 
// -U ${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login} 
// ${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login}
// -p 5432
  //   provisioner "remote-exec" {
  //   inline= [
  //   "psql   -d ${azurerm_postgresql_flexible_server_database.workdb.name} < ./init_scripts/init_postgres.sql",
  //   "psql   -d ${azurerm_postgresql_flexible_server_database.workdb.name} < ./init_scripts/create-system-resources.sql"
  //   ]
  //   connection {
  //   type="ssh"
  //   user=azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login
  //   password=azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password
  //   host=azurerm_private_dns_zone.example-nonprod-db.name
  // }

  // }

}



// resource "null_resource" "setup_init_pocdb" {
//   depends_on = [azurerm_postgresql_flexible_server_database.pocdb] #wait for the db to be ready
//   provisioner "remote-exec" {
//     inline = "PGPASSWORD=${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password} psql -h ${azurerm_private_dns_zone.example-nonprod-db.name} -U ${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login} -p 5432 -d ${azurerm_postgresql_flexible_server_database.pocdb.name} < ./init_scripts/init_postgres.sql"
//   }
  
// }

// resource "null_resource" "setup_system_pocdb" {
//   depends_on = [azurerm_postgresql_flexible_server_database.pocdb,null_resource.setup_init_pocdb] #wait for the db to be ready
//   provisioner "remote-exec" {
//    inline = "PGPASSWORD=${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password} psql -h ${azurerm_private_dns_zone.example-nonprod-db.name} -U ${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login} -p 5432 -d ${azurerm_postgresql_flexible_server_database.pocdb.name} < ./init_scripts/create-system-resources.sql"
//   }
// }

// resource "null_resource" "setup_init_workdb" {
//   depends_on = [azurerm_postgresql_flexible_server_database.workdb] #wait for the db to be ready
//   provisioner "remote-exec" {
//     inline = "PGPASSWORD=${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password} psql -h ${azurerm_private_dns_zone.example-nonprod-db.name} -U ${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login} -p 5432 -d ${azurerm_postgresql_flexible_server_database.workdb.name} < ./init_scripts/init_postgres.sql"
    
//   }
// }

// resource "null_resource" "setup_system_workdb" {
//   depends_on = [azurerm_postgresql_flexible_server_database.workdb,null_resource.setup_init_workdb] #wait for the db to be ready
//   provisioner "remote-exec" {
//     inline = "PGPASSWORD=${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_password} psql -h ${azurerm_private_dns_zone.example-nonprod-db.name} -U ${azurerm_postgresql_flexible_server.example-nonprod-db.administrator_login} -p 5432 -d ${azurerm_postgresql_flexible_server_database.workdb.name} < ./init_scripts/create-system-resources.sql"
//   }
// }

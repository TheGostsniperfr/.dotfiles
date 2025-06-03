{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true; 
    package = pkgs.postgresql_15; 
    initialScript = pkgs.writeText "init.sql" ''
      CREATE ROLE brian WITH LOGIN CREATEDB PASSWORD 'admin';
      CREATE DATABASE brian OWNER brian;
    '';
  };
}

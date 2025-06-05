{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true; 
    package = pkgs.postgresql_15; 
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE brian WITH LOGIN SUPERUSER PASSWORD 'admin';
      CREATE DATABASE brian OWNER brian;
      \c brian
      GRANT ALL PRIVILEGES ON SCHEMA public TO brian;

      CREATE DATABASE arffornia;
      CREATE USER laravel WITH ENCRYPTED PASSWORD 'laravel';
      GRANT ALL PRIVILEGES ON DATABASE arffornia TO laravel;
    '';
  };
}

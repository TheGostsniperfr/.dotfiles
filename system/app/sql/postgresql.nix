{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    initialScript = pkgs.writeText "initial-postgres.sql" ''
      CREATE ROLE brian WITH LOGIN SUPERUSER PASSWORD 'admin';
      CREATE DATABASE brian OWNER brian;

      CREATE USER laravel WITH ENCRYPTED PASSWORD 'laravel';
      CREATE DATABASE arffornia OWNER laravel;
    '';
  };


  systemd.services.postgresql-grants = {
    description = "PostgreSQL grants for Laravel";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];

    serviceConfig = {
      User = "postgres";
      Group = "postgres"; 
      ExecStart = pkgs.writeShellScript "postgresql-grants.sh" ''
        ${pkgs.postgresql_15}/bin/psql <<EOF
        \c arffornia
        ALTER SCHEMA public OWNER TO laravel;
        GRANT USAGE, CREATE ON SCHEMA public TO laravel;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO laravel;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO laravel;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO laravel;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO laravel;
        EOF
      '';
    };

    wantedBy = [ "multi-user.target" ];
  };
}
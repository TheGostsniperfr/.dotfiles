{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    php83
    
    php83Packages.composer

    php83Extensions.pdo
    php83Extensions.pdo_pgsql
    php83Extensions.pgsql
    php83Extensions.mbstring
    php83Extensions.tokenizer
    php83Extensions.xml
    php83Extensions.curl
    php83Extensions.zip
    php83Extensions.fileinfo
    php83Extensions.bcmath
    php83Extensions.opcache
  ];
}

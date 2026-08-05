{ userSettings, ... }:

{
  sops.secrets.notion_perso_token = {
    owner = userSettings.username;
  };

  sops.secrets.notion_eleves_token = {
    owner = userSettings.username;
  };
}

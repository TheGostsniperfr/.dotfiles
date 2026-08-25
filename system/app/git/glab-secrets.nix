{ userSettings, ... }:

{
  sops.secrets.gitlab_com_token = {
    owner = userSettings.username;
  };

  sops.secrets.gitlab_epita_student_token = {
    owner = userSettings.username;
  };

  sops.secrets.gitlab_epita_pro_token = {
    owner = userSettings.username;
  };
}

import { closeMainWindow, open, showHUD } from "@vicinae/api";
import { activeInfra, failToast, loadConfig } from "./infra";

export async function openService(service: string) {
  try {
    const active = activeInfra(loadConfig());
    if (!active) throw new Error("no infra declared");
    const [, infra] = active;
    const url = infra.links[service];
    if (!url) {
      await showHUD(`No ${service} for ${infra.title}`);
      return;
    }
    await open(url);
    await closeMainWindow();
  } catch (err) {
    await failToast(err, `Cannot open ${service}`);
  }
}

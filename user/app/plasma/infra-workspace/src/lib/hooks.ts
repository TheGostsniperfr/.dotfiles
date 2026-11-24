import { useCallback, useEffect, useState } from "react";
import { activeInfra, Config, Infra, loadConfig } from "./infra";

export type Loaded<T> = { data?: T; error?: Error; isLoading: boolean; reload: () => void };

export function useConfig(): { cfg?: Config; error?: Error } {
  const [state] = useState(() => {
    try {
      return { cfg: loadConfig() };
    } catch (error) {
      return { error: error as Error };
    }
  });
  return state;
}

export function useActive(): { cfg?: Config; name?: string; infra?: Infra; error?: Error } {
  const { cfg, error } = useConfig();
  if (!cfg) return { error };
  const active = activeInfra(cfg);
  if (!active) return { cfg, error: new Error("no infra declared in infras.json") };
  return { cfg, name: active[0], infra: active[1] };
}

export function useAsync<T>(fn: () => Promise<T>, deps: unknown[]): Loaded<T> {
  const [state, setState] = useState<{ data?: T; error?: Error; isLoading: boolean }>({ isLoading: true });
  const [tick, setTick] = useState(0);
  useEffect(() => {
    let cancelled = false;
    setState((s) => ({ ...s, isLoading: true }));
    fn().then(
      (data) => !cancelled && setState({ data, isLoading: false }),
      (error: Error) => !cancelled && setState({ error, isLoading: false }),
    );
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, tick]);
  const reload = useCallback(() => setTick((t) => t + 1), []);
  return { ...state, reload };
}

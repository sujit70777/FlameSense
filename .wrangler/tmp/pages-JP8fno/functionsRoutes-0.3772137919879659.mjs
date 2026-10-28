import { onRequest as __api_ask_ts_onRequest } from "/Users/Works/Work From Home/github/FlameSense/functions/api/ask.ts"

export const routes = [
    {
      routePath: "/api/ask",
      mountPath: "/api",
      method: "",
      middlewares: [],
      modules: [__api_ask_ts_onRequest],
    },
  ]
import type { Request as ExpressRequest } from "express";

export const toFetchHeaders = (req: ExpressRequest): Headers => {
  const headers = new Headers();

  for (const [key, value] of Object.entries(req.headers)) {
    if (Array.isArray(value)) {
      for (const entry of value) headers.append(key, entry);
    } else if (value !== undefined) {
      headers.append(key, value);
    }
  }

  return headers;
};

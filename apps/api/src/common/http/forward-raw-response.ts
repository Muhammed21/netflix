import type { Response as ExpressResponse } from "express";

export function forwardRawResponse(
  res: ExpressResponse,
  result: { status: number; headers: Headers; body: ArrayBuffer },
): void {
  res.status(result.status);

  result.headers.forEach((value, key) => {
    const normalizedKey = key.toLowerCase();
    if (normalizedKey === "content-length" || normalizedKey === "set-cookie") {
      return;
    }
    res.setHeader(key, value);
  });

  // Better Auth pose plusieurs en-têtes Set-Cookie (jeton de session et cache).
  // `Headers.forEach` les livre un par un, mais `res.setHeader('set-cookie', …)`
  // appelé en boucle écrase au lieu d'ajouter — il faut donc les transmettre
  // ensemble, en un seul appel, sous forme de tableau.
  const setCookieValues = result.headers.getSetCookie();
  if (setCookieValues.length > 0) {
    res.setHeader("Set-Cookie", setCookieValues);
  }

  res.send(Buffer.from(result.body));
}

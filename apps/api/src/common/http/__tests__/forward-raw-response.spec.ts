import { describe, expect, it } from "vitest";
import type { Response as ExpressResponse } from "express";

import { forwardRawResponse } from "../forward-raw-response.js";

const fakeResponse = () => {
  const headers: Record<string, string | string[]> = {};
  return {
    headers,
    sent: [] as unknown[],
    statusCode: 0,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    setHeader(key: string, value: string | string[]) {
      headers[key] = value;
    },
    send(body: unknown) {
      this.sent.push(body);
    },
  };
};

const result = (headers: Headers, status = 200) => ({
  status,
  headers,
  body: new TextEncoder().encode('{"ok":true}').buffer as ArrayBuffer,
});

describe("forwardRawResponse", () => {
  it("forwards the status code", () => {
    const res = fakeResponse();

    forwardRawResponse(res as unknown as ExpressResponse, result(new Headers(), 201));

    expect(res.statusCode).toBe(201);
  });

  it("forwards every Set-Cookie header, not only the last one", () => {
    const headers = new Headers();
    headers.append("set-cookie", "better-auth.session_token=abc; Path=/; HttpOnly");
    headers.append("set-cookie", "better-auth.session_data=xyz; Path=/; HttpOnly");
    const res = fakeResponse();

    forwardRawResponse(res as unknown as ExpressResponse, result(headers));

    expect(res.headers["Set-Cookie"]).toEqual([
      "better-auth.session_token=abc; Path=/; HttpOnly",
      "better-auth.session_data=xyz; Path=/; HttpOnly",
    ]);
  });

  it("forwards other headers untouched", () => {
    const headers = new Headers({ "content-type": "application/json" });
    const res = fakeResponse();

    forwardRawResponse(res as unknown as ExpressResponse, result(headers));

    expect(res.headers["content-type"]).toBe("application/json");
  });

  it("drops content-length so the rewritten body is not truncated", () => {
    const headers = new Headers({ "content-length": "9999" });
    const res = fakeResponse();

    forwardRawResponse(res as unknown as ExpressResponse, result(headers));

    expect(res.headers["content-length"]).toBeUndefined();
  });

  it("sends the body as a buffer", () => {
    const res = fakeResponse();

    forwardRawResponse(res as unknown as ExpressResponse, result(new Headers()));

    expect(res.sent[0]).toBeInstanceOf(Buffer);
    expect(String(res.sent[0])).toBe('{"ok":true}');
  });
});

const statusByCode = {
  unauthenticated: 401,
  'permission-denied': 403,
  'not-found': 404,
  'already-exists': 409,
  'failed-precondition': 412,
  'invalid-argument': 400,
  internal: 500,
  unavailable: 503,
};

export class AppError extends Error {
  constructor(code, message, options = {}) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.status = options.status ?? statusByCode[code] ?? 500;
    this.details = options.details ?? null;
  }
}

export function isAppError(error) {
  return error instanceof AppError;
}

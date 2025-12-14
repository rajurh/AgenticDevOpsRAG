from typing import Any
import logging

logger = logging.getLogger(__name__)


class AppError(Exception):
    """Base application error with optional HTTP status code."""
    status_code = 500


class ConfigError(AppError):
    status_code = 500


class ExternalAPIError(AppError):
    status_code = 502


class VectorStoreError(AppError):
    status_code = 500


class NotFoundError(AppError):
    status_code = 404


def wrap_error(e: Exception) -> dict:
    """Return structured error info for responses and logs."""
    if isinstance(e, AppError):
        status = e.status_code
    else:
        status = 500
    logger.exception("Error handled: %s", e)
    return {"error": str(e), "status_code": status}

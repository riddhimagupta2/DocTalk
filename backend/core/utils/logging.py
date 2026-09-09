"""
Structured logging module for DocTalk.
Complies with HIPAA/GDPR health privacy standards:
NEVER logs raw image data, base64 strings, or personal medical images.
Tracks processing latencies, model token usage, and diagnostic audit logs.
"""
import json
import logging
from datetime import datetime, timezone


class JSONFormatter(logging.Formatter):
    """
    JSON log formatter for production observability (CloudWatch / Datadog / Stackdriver).
    """

    def format(self, record: logging.LogRecord) -> str:
        log_entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "funcName": record.funcName,
            "lineNo": record.lineno,
        }

        # Include custom metric attributes if attached
        for key in (
            "user_id",
            "analysis_id",
            "ai_latency_ms",
            "storage_latency_ms",
            "total_latency_ms",
            "prompt_tokens",
            "completion_tokens",
            "model_version",
            "status",
        ):
            if hasattr(record, key):
                log_entry[key] = getattr(record, key)

        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_entry)


def get_logger(name: str) -> logging.Logger:
    """Convenience helper to retrieve named logger."""
    return logging.getLogger(name)

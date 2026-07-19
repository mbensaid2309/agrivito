from __future__ import annotations

from dataclasses import dataclass
from threading import Lock

from app.services.ai.exceptions import DiscoveryLimitReachedError


@dataclass(frozen=True)
class PhotoDiagnosisUsageSnapshot:
    diagnoses_used: int
    diagnoses_limit: int
    remaining: int


class PhotoDiagnosisUsageTracker:
    def __init__(self, limit: int = 1) -> None:
        self._limit = limit
        self._usage: dict[str, int] = {}
        self._lock = Lock()

    def consume(self, session_id: str | None) -> PhotoDiagnosisUsageSnapshot:
        key = (session_id or "anonymous").strip() or "anonymous"
        with self._lock:
            used = self._usage.get(key, 0)
            if used >= self._limit:
                raise DiscoveryLimitReachedError()
            used += 1
            self._usage[key] = used
        return PhotoDiagnosisUsageSnapshot(used, self._limit, self._limit - used)

    def release(self, session_id: str | None) -> None:
        key = (session_id or "anonymous").strip() or "anonymous"
        with self._lock:
            used = self._usage.get(key, 0)
            if used <= 1:
                self._usage.pop(key, None)
            else:
                self._usage[key] = used - 1

    def reset(self) -> None:
        with self._lock:
            self._usage.clear()

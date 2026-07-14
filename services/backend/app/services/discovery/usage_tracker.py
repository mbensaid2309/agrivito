from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from threading import Lock

from app.services.ai.exceptions import DiscoveryLimitReachedError


@dataclass(frozen=True)
class DiscoveryUsageSnapshot:
    questions_used: int
    questions_limit: int
    remaining: int


class DiscoveryUsageTracker:
    questions_limit = 3

    def __init__(self) -> None:
        self._counts: dict[str, int] = {}
        self._lock = Lock()

    def consume(self, session_id: str | None) -> DiscoveryUsageSnapshot:
        if session_id is None:
            return DiscoveryUsageSnapshot(
                questions_used=1,
                questions_limit=self.questions_limit,
                remaining=self.questions_limit - 1,
            )

        with self._lock:
            current = self._counts.get(session_id, 0)
            if current >= self.questions_limit:
                raise DiscoveryLimitReachedError("Discovery question limit reached.")
            questions_used = current + 1
            self._counts[session_id] = questions_used

        return DiscoveryUsageSnapshot(
            questions_used=questions_used,
            questions_limit=self.questions_limit,
            remaining=self.questions_limit - questions_used,
        )

    def reset(self) -> None:
        with self._lock:
            self._counts.clear()


@lru_cache
def get_discovery_usage_tracker() -> DiscoveryUsageTracker:
    return DiscoveryUsageTracker()

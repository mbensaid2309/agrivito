from collections import defaultdict
from threading import Lock

from app.services.media.exceptions import MediaDiscoveryLimitReachedError


class DiscoveryPhotoUsageTracker:
    photos_limit = 1

    def __init__(self) -> None:
        self._usage: dict[str, int] = defaultdict(int)
        self._lock = Lock()

    def reserve(self, session_id: str) -> None:
        with self._lock:
            if self._usage[session_id] >= self.photos_limit:
                raise MediaDiscoveryLimitReachedError()
            self._usage[session_id] += 1

    def release(self, session_id: str) -> None:
        with self._lock:
            if self._usage[session_id] <= 1:
                self._usage.pop(session_id, None)
            else:
                self._usage[session_id] -= 1

    def reset(self) -> None:
        with self._lock:
            self._usage.clear()


_tracker = DiscoveryPhotoUsageTracker()


def get_discovery_photo_usage_tracker() -> DiscoveryPhotoUsageTracker:
    return _tracker

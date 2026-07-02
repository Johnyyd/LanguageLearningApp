# =====================================================================
# ⚡ Redis Caching Service with In-Memory Fallback
# =====================================================================

import json
import redis
from typing import Optional, Any
from config import settings

class CacheService:
    """
    Quản lý bộ nhớ đệm (Caching) cho Backend AI Gateway.
    - Ưu tiên sử dụng Redis (trên cổng 1113 hoặc redis container).
    - Tự động chuyển sang In-Memory Dictionary Fallback nếu Redis offline
      giúp hệ thống luôn duy trì tính sẵn sàng cao cho Demo/Portfolio.
    """
    def __init__(self):
        self.redis_client: Optional[redis.Redis] = None
        self.memory_fallback = {}
        self._connect()

    def _connect(self):
        try:
            self.redis_client = redis.from_url(
                settings.REDIS_URL,
                decode_responses=True,
                socket_connect_timeout=2,
                socket_timeout=2
            )
            # Kiểm tra ping nhanh
            self.redis_client.ping()
            print(f"✅ [CacheService] Connected to Redis at {settings.REDIS_URL}")
        except Exception as e:
            print(f"⚠️ [CacheService] Redis offline ({e}). Using In-Memory Fallback Cache.")
            self.redis_client = None

    def get(self, key: str) -> Optional[Any]:
        try:
            if self.redis_client:
                data = self.redis_client.get(key)
                if data:
                    print(f"🎯 [Redis Cache Hit] Key: {key}")
                    return json.loads(data)
        except Exception as e:
            print(f"⚠️ [Redis Error] Get key {key} failed: {e}")
        
        # Fallback check
        if key in self.memory_fallback:
            print(f"🎯 [Memory Cache Hit] Key: {key}")
            return self.memory_fallback[key]
        return None

    def set(self, key: str, value: Any, ttl: int = None) -> bool:
        if ttl is None:
            ttl = settings.CACHE_TTL_SECONDS
        try:
            serialized = json.dumps(value, ensure_ascii=False)
            if self.redis_client:
                self.redis_client.setex(key, ttl, serialized)
                print(f"💾 [Redis Cache Saved] Key: {key} (TTL: {ttl}s)")
                return True
        except Exception as e:
            print(f"⚠️ [Redis Error] Set key {key} failed: {e}")
            self.redis_client = None # Downgrade to fallback
        
        # Fallback save
        self.memory_fallback[key] = value
        print(f"💾 [Memory Cache Saved] Key: {key}")
        return True

    def delete(self, key: str) -> bool:
        try:
            if self.redis_client:
                self.redis_client.delete(key)
        except Exception:
            pass
        self.memory_fallback.pop(key, None)
        return True

    def flush_all(self):
        try:
            if self.redis_client:
                self.redis_client.flushdb()
        except Exception:
            pass
        self.memory_fallback.clear()
        print("🧹 [CacheService] Flushed all cache data.")

# Singleton instance
cache_service = CacheService()

import numpy as np
from typing import List, Dict, Any
import logging

from errors import VectorStoreError

logger = logging.getLogger(__name__)

class InMemoryVectorStore:
    def __init__(self):
        # store entries as dicts: {"id": str, "text": str, "metadata": dict, "embedding": np.ndarray}
        self._items: List[Dict[str, Any]] = []

    def add_documents(self, docs: List[Dict[str, Any]]):
        """Add documents that already include an `embedding` (list/ndarray) property.
        Each doc should have at least: id, text, embedding, metadata (optional)
        """
        try:
            for d in docs:
                if "embedding" not in d or d["embedding"] is None:
                    raise VectorStoreError("Document missing 'embedding' field")
                emb = np.asarray(d["embedding"], dtype=float)
                self._items.append({
                    "id": d.get("id"),
                    "text": d.get("text"),
                    "metadata": d.get("metadata", {}),
                    "embedding": emb,
                })
        except Exception as e:
            logger.exception("Failed to add documents to vector store")
            raise

    def search(self, query_embedding, top_k=3):
        """Return top_k documents by cosine similarity.
        Returns list of items with score field added.
        """
        if len(self._items) == 0:
            return []
        try:
            q = np.asarray(query_embedding, dtype=float)
            # compute cosine similarities
            embs = np.stack([it["embedding"] for it in self._items], axis=0)
            # normalize
            embs_norm = embs / (np.linalg.norm(embs, axis=1, keepdims=True) + 1e-12)
            q_norm = q / (np.linalg.norm(q) + 1e-12)
            sims = embs_norm.dot(q_norm)
            # get top_k indices
            idx = np.argsort(-sims)[:top_k]
            results = []
            for i in idx:
                orig = self._items[i]
                item = {
                    "id": orig.get("id"),
                    "text": orig.get("text"),
                    "metadata": orig.get("metadata", {}),
                    "score": float(sims[i]),
                }
                results.append(item)
            return results
        except Exception as e:
            logger.exception("Vector search failed")
            raise VectorStoreError(str(e))

    def all_documents(self):
        return list(self._items)

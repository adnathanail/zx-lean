import base64
import io
from pathlib import Path

import numpy as np
import pytest
from PIL import Image

from app import app

SNAPSHOTS = Path(__file__).parent / "snapshots"

DIAGRAM = {
    "nodes": [
        {"id": 0, "type": "input", "ioId": 0},
        {"id": 1, "type": "spider", "color": "Z", "phase": "1/2"},
        {"id": 2, "type": "output", "ioId": 0},
    ],
    "edges": [
        {"src": 0, "tgt": 1},
        {"src": 1, "tgt": 2},
    ],
}


def _decode_png(b64: str) -> np.ndarray:
    img = Image.open(io.BytesIO(base64.b64decode(b64))).convert("RGBA")
    return np.array(img, dtype=np.float64)


def _images_match(actual: np.ndarray, expected: np.ndarray, threshold: float = 3.0) -> tuple[bool, float]:
    """Compare images by RMSE. threshold is on 0-255 scale."""
    assert actual.shape == expected.shape, f"Shape mismatch: {actual.shape} vs {expected.shape}"
    rmse = float(np.sqrt(np.mean((actual - expected) ** 2)))
    return rmse < threshold, rmse


def test_diagram_snapshot():
    client = app.test_client()
    resp = client.post("/diagram", json=DIAGRAM)
    data = resp.get_json()
    assert data["status"] == "ok"

    actual = _decode_png(data["image"])
    snapshot_path = SNAPSHOTS / "test_z_spider.png"

    if not snapshot_path.exists():
        # First run: save reference and skip
        snapshot_path.parent.mkdir(parents=True, exist_ok=True)
        Image.fromarray(actual.astype(np.uint8)).save(snapshot_path)
        pytest.skip(f"Saved new snapshot to {snapshot_path}. Re-run to compare.")

    expected = np.array(Image.open(snapshot_path).convert("RGBA"), dtype=np.float64)
    match, rmse = _images_match(actual, expected)
    assert match, f"Image RMSE {rmse:.2f} exceeds threshold. Delete snapshot and re-run to update."

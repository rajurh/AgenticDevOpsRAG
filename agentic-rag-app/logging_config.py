import logging


def configure_logging(level: str = "INFO"):
    level_val = getattr(logging, level.upper(), logging.INFO)
    root = logging.getLogger()
    if root.handlers:
        return root
    root.setLevel(level_val)
    fmt = logging.Formatter("%(asctime)s %(levelname)s %(name)s - %(message)s")
    sh = logging.StreamHandler()
    sh.setFormatter(fmt)
    root.addHandler(sh)
    return root


logger = configure_logging()

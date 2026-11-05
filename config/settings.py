import os

# Base application settings
BASE_URL = os.getenv("APP_BASE_URL", "https://www.saucedemo.com")
BROWSER = os.getenv("BROWSER", "headlesschrome")
DEFAULT_TIMEOUT = int(os.getenv("DEFAULT_TIMEOUT", "10"))
IMPLICIT_WAIT = int(os.getenv("IMPLICIT_WAIT", "2"))

# Visual Testing Configurations
BASELINE_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "baselines")
DIFF_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "reports", "visual_diffs")
VISUAL_DIFF_THRESHOLD_PERCENT = float(os.getenv("VISUAL_DIFF_THRESHOLD", "1.5"))

# AI Configuration (Optional Gemini / OpenAI Vision integration)
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

# Performance SLA thresholds (in seconds)
PAGE_LOAD_SLA_SECONDS = float(os.getenv("PAGE_LOAD_SLA", "4.0"))
TTFB_SLA_SECONDS = float(os.getenv("TTFB_SLA", "1.5"))

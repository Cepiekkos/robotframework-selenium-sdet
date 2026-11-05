"""
PerformanceMetrics: Custom Robot Framework Library for Web Performance Engineering.

Collects W3C Navigation Timing API metrics directly from the browser session,
calculates TTFB, DOM Content Loaded, and Total Page Load Duration, and asserts
performance SLA thresholds against real application personas.
"""

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


class PerformanceMetrics:
    """Robot Framework library for browser performance benchmarking and SLA assertions."""

    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        self.metrics_history = []

    def _get_driver(self):
        sel_lib = BuiltIn().get_library_instance("SeleniumLibrary")
        return sel_lib.driver

    def collect_browser_performance_metrics(self, page_name: str = "Current Page") -> dict:
        """
        Executes JavaScript to retrieve W3C Navigation Timing API level 2 metrics.
        Returns a dictionary containing key web vitals in milliseconds and seconds.
        """
        driver = self._get_driver()

        # Query Navigation Timing API v2, fallback to legacy timing API
        script = """
        const perf = window.performance;
        if (!perf) return null;
        
        const navEntries = perf.getEntriesByType('navigation');
        if (navEntries && navEntries.length > 0) {
            const entry = navEntries[0];
            return {
                ttfb: entry.responseStart - entry.requestStart,
                dom_interactive: entry.domInteractive - entry.startTime,
                dom_content_loaded: entry.domContentLoadedEventEnd - entry.startTime,
                page_load_time: entry.loadEventEnd > 0 ? (entry.loadEventEnd - entry.startTime) : (entry.responseEnd - entry.startTime),
                transfer_size_bytes: entry.transferSize || 0
            };
        } else if (perf.timing) {
            const t = perf.timing;
            const start = t.navigationStart;
            return {
                ttfb: t.responseStart - t.requestStart,
                dom_interactive: t.domInteractive - start,
                dom_content_loaded: t.domContentLoadedEventEnd - start,
                page_load_time: (t.loadEventEnd > 0 ? t.loadEventEnd : t.responseEnd) - start,
                transfer_size_bytes: 0
            };
        }
        return null;
        """

        raw = driver.execute_script(script)
        if not raw:
            logger.warn("Navigation Timing API not available in current browser session.")
            return {}

        metrics = {
            "page_name": page_name,
            "ttfb_ms": round(max(0, raw.get("ttfb", 0)), 2),
            "dom_content_loaded_ms": round(max(0, raw.get("dom_content_loaded", 0)), 2),
            "page_load_time_ms": round(max(0, raw.get("page_load_time", 0)), 2),
            "page_load_time_sec": round(max(0, raw.get("page_load_time", 0)) / 1000.0, 3),
            "ttfb_sec": round(max(0, raw.get("ttfb", 0)) / 1000.0, 3),
            "transfer_kb": round(raw.get("transfer_size_bytes", 0) / 1024.0, 2)
        }

        self.metrics_history.append(metrics)
        self._log_metrics_card(metrics)
        return metrics

    def assert_page_load_sla(self, max_seconds: float, page_name: str = "Current Page"):
        """
        Collects metrics and verifies that the page load time is within the given SLA budget in seconds.
        """
        metrics = self.collect_browser_performance_metrics(page_name)
        actual_sec = metrics.get("page_load_time_sec", 0.0)

        if actual_sec > float(max_seconds):
            raise AssertionError(
                f"Performance SLA breached on '{page_name}'! "
                f"Page Load Time was {actual_sec}s (Budget SLA: {max_seconds}s)."
            )
        logger.info(f"Page Load SLA satisfied for '{page_name}': {actual_sec}s <= {max_seconds}s")

    def assert_ttfb_sla(self, max_seconds: float, page_name: str = "Current Page"):
        """
        Verifies Time To First Byte (TTFB) response latency is within the SLA budget.
        """
        metrics = self.collect_browser_performance_metrics(page_name)
        actual_sec = metrics.get("ttfb_sec", 0.0)

        if actual_sec > float(max_seconds):
            raise AssertionError(
                f"TTFB SLA breached on '{page_name}'! "
                f"Response Start was {actual_sec}s (Budget SLA: {max_seconds}s)."
            )

    def _log_metrics_card(self, m: dict):
        """Logs an interactive HTML performance badge in Robot Framework log."""
        html = f"""
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; border: 1px solid #b8daff; background: #e8f4fd; border-radius: 6px; padding: 12px; margin: 8px 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; border-bottom: 1px solid #b8daff; padding-bottom: 6px;">
                <h4 style="margin: 0; color: #004085;">⚡ Web Performance Metrics: <code>{m.get('page_name')}</code></h4>
                <span style="background: #007bff; color: white; padding: 2px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">Load Time: {m.get('page_load_time_sec')}s</span>
            </div>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; font-size: 12px; color: #004085; text-align: center;">
                <div style="background: white; padding: 6px; border-radius: 4px; border: 1px solid #b8daff;">
                    <div style="font-size: 10px; color: #6c757d; text-transform: uppercase;">TTFB</div>
                    <div style="font-size: 14px; font-weight: bold;">{m.get('ttfb_ms')} ms</div>
                </div>
                <div style="background: white; padding: 6px; border-radius: 4px; border: 1px solid #b8daff;">
                    <div style="font-size: 10px; color: #6c757d; text-transform: uppercase;">DOM Interactive</div>
                    <div style="font-size: 14px; font-weight: bold;">{m.get('dom_content_loaded_ms')} ms</div>
                </div>
                <div style="background: white; padding: 6px; border-radius: 4px; border: 1px solid #b8daff;">
                    <div style="font-size: 10px; color: #6c757d; text-transform: uppercase;">Full Page Load</div>
                    <div style="font-size: 14px; font-weight: bold;">{m.get('page_load_time_ms')} ms</div>
                </div>
                <div style="background: white; padding: 6px; border-radius: 4px; border: 1px solid #b8daff;">
                    <div style="font-size: 10px; color: #6c757d; text-transform: uppercase;">Payload Size</div>
                    <div style="font-size: 14px; font-weight: bold;">{m.get('transfer_kb')} KB</div>
                </div>
            </div>
        </div>
        """
        logger.info(html, html=True)

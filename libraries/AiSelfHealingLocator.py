"""
AiSelfHealingLocator: Custom Robot Framework Library for Self-Healing UI Automation.

Addresses test flakiness and brittle locators by dynamically analyzing the DOM
when element locators fail, calculating semantic and contextual similarity scores,
healing the locator in real-time, and executing the intended user action.
"""

import time
import difflib
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.common.by import By


class AiSelfHealingLocator:
    """Robot Framework custom library providing resilient self-healing element interactions."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, confidence_threshold: float = 0.40):
        self.confidence_threshold = float(confidence_threshold)
        self.healed_history = []

    def _get_selenium_lib(self):
        """Get Robot Framework SeleniumLibrary instance."""
        return BuiltIn().get_library_instance("SeleniumLibrary")

    def _get_driver(self):
        """Get active WebDriver instance."""
        return self._get_selenium_lib().driver

    def smart_click_element(self, locator: str, fallback_tag: str = "button, a, input[type='submit'], [role='button']"):
        """
        Attempts to click an element by standard locator.
        If the locator is broken or missing, self-heals by analyzing the DOM,
        highlights the matched element, and clicks it successfully.
        """
        driver = self._get_driver()
        try:
            # First attempt standard Robot Framework element resolution
            sel_lib = self._get_selenium_lib()
            element = sel_lib.find_element(locator)
            element.click()
            return
        except Exception as ex:
            logger.warn(f"Standard locator failed: '{locator}'. Initiating AI Self-Healing engine...")

        healed_element, healed_details = self._heal_element(locator, candidate_tags=fallback_tag)
        if healed_element:
            self._visual_feedback(healed_element)
            self._log_healed_event("CLICK", locator, healed_details)
            healed_element.click()
        else:
            raise NoSuchElementException(f"Self-Healing could not resolve broken locator '{locator}'.")

    def smart_input_text(self, locator: str, text: str, fallback_tag: str = "input, textarea"):
        """
        Attempts to input text into an element. If the locator fails, heals the locator,
        clears existing content, and enters the text.
        """
        driver = self._get_driver()
        try:
            sel_lib = self._get_selenium_lib()
            element = sel_lib.find_element(locator)
            element.clear()
            element.send_keys(text)
            return
        except Exception:
            logger.warn(f"Standard input locator failed: '{locator}'. Initiating AI Self-Healing engine...")

        healed_element, healed_details = self._heal_element(locator, candidate_tags=fallback_tag)
        if healed_element:
            self._visual_feedback(healed_element)
            self._log_healed_event("INPUT_TEXT", locator, healed_details)
            healed_element.clear()
            healed_element.send_keys(text)
        else:
            raise NoSuchElementException(f"Self-Healing could not resolve broken locator '{locator}'.")

    def smart_wait_until_element_is_visible(self, locator: str, timeout: str = "10s", fallback_tag: str = "*"):
        """
        Waits for element to be visible, with self-healing support if the locator is broken.
        """
        sel_lib = self._get_selenium_lib()
        try:
            sel_lib.wait_until_element_is_visible(locator, timeout)
            return
        except Exception:
            logger.warn(f"Element '{locator}' not visible within {timeout}. Attempting self-healing scan...")

        healed_element, healed_details = self._heal_element(locator, candidate_tags=fallback_tag)
        if healed_element and healed_element.is_displayed():
            self._visual_feedback(healed_element)
            self._log_healed_event("WAIT_VISIBLE", locator, healed_details)
            return True
        raise TimeoutException(f"Element '{locator}' could not be located or healed within {timeout}.")

    def get_self_healing_summary(self) -> list:
        """Returns the list of all healed locators during the test session."""
        return self.healed_history

    def _heal_element(self, broken_locator: str, candidate_tags: str):
        """
        Analyzes DOM candidate elements using fuzzy string matching on text, attributes,
        id, data-test, name, and aria-labels.
        """
        driver = self._get_driver()
        raw_key = self._extract_semantic_clues(broken_locator)

        candidates = driver.find_elements(By.CSS_SELECTOR, candidate_tags)
        best_candidate = None
        highest_score = 0.0
        best_details = {}

        for el in candidates:
            try:
                if not el.is_displayed():
                    continue

                score, matched_attr, attr_val = self._calculate_similarity(el, raw_key)
                if score > highest_score:
                    highest_score = score
                    best_candidate = el
                    best_details = {
                        "score": round(score * 100, 2),
                        "matched_property": matched_attr,
                        "matched_value": attr_val,
                        "tag_name": el.tag_name,
                        "suggested_locator": f"css:[{matched_attr}='{attr_val}']" if matched_attr != "text" else f"xpath://{el.tag_name}[contains(text(),'{attr_val}')]"
                    }
            except Exception:
                continue

        if highest_score >= self.confidence_threshold:
            self.healed_history.append({
                "broken_locator": broken_locator,
                "healed_details": best_details
            })
            return best_candidate, best_details

        return None, None

    def _extract_semantic_clues(self, locator: str) -> str:
        """Strips selector prefixes (css=, id:, xpath=, etc.) and extracts core keywords."""
        cleaned = locator.lower()
        for prefix in ["id:", "id=", "css:", "css=", "xpath:", "xpath=", "name:", "name="]:
            if cleaned.startswith(prefix):
                cleaned = cleaned[len(prefix):]
                break

        # Remove common punct
        cleaned = cleaned.replace("-", " ").replace("_", " ").replace(".", " ").replace("#", " ")
        return cleaned.strip()

    def _calculate_similarity(self, element, target_clue: str):
        """Scores an element against the target semantic clue across attributes."""
        attributes_to_check = [
            ("data-test", element.get_attribute("data-test")),
            ("id", element.get_attribute("id")),
            ("name", element.get_attribute("name")),
            ("placeholder", element.get_attribute("placeholder")),
            ("aria-label", element.get_attribute("aria-label")),
            ("value", element.get_attribute("value")),
            ("text", element.text),
            ("class", element.get_attribute("class"))
        ]

        best_score = 0.0
        best_attr = None
        best_val = None

        target_words = set(target_clue.split())

        for attr_name, attr_val in attributes_to_check:
            if not attr_val:
                continue
            val_clean = attr_val.lower().replace("-", " ").replace("_", " ")
            val_words = set(val_clean.split())

            # 1. Fuzzy SequenceMatcher ratio
            ratio = difflib.SequenceMatcher(None, target_clue, val_clean).ratio()

            # 2. Token overlap & recall
            if target_words and val_words:
                intersection = target_words.intersection(val_words)
                if intersection:
                    # Token recall on the candidate value
                    token_recall = len(intersection) / len(val_words)
                    token_precision = len(intersection) / len(target_words)
                    ratio = max(ratio, token_recall * 0.85, token_precision * 0.75)

            # 3. Substring containment bonus (e.g. 'login' in 'login-button' or 'user' in 'user-name')
            for tw in target_words:
                if len(tw) >= 3 and tw in val_clean:
                    ratio = max(ratio, 0.60)
                    if attr_name in ["data-test", "id", "name"]:
                        ratio = max(ratio, 0.75)

            # High-value selector attribute boost
            if attr_name in ["data-test", "id"]:
                ratio *= 1.15

            ratio = min(ratio, 1.0)

            if ratio > best_score:
                best_score = ratio
                best_attr = attr_name
                best_val = attr_val

        return best_score, best_attr, best_val

    def _visual_feedback(self, element):
        """Draws a pulsed green highlight around the healed element for visual confirmation."""
        driver = self._get_driver()
        try:
            driver.execute_script(
                "arguments[0].style.border='3px dashed #28a745'; arguments[0].style.boxShadow='0 0 10px #28a745';",
                element
            )
            time.sleep(0.15)
        except Exception:
            pass

    def _log_healed_event(self, action: str, broken: str, details: dict):
        """Logs a formatted self-healing card in the Robot Framework execution log."""
        html = f"""
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; border: 1px solid #c3e6cb; background: #d4edda; border-radius: 6px; padding: 12px; margin: 8px 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <h4 style="margin: 0; color: #155724;">🩺 Self-Healing Locator Activated ({action})</h4>
                <span style="background: #28a745; color: white; padding: 3px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">Confidence: {details.get('score')}%</span>
            </div>
            <div style="font-size: 12px; color: #155724;">
                <p style="margin: 3px 0;"><strong>Broken Original Locator:</strong> <code style="background: #f8d7da; color: #721c24; padding: 2px 4px; border-radius: 3px;">{broken}</code></p>
                <p style="margin: 3px 0;"><strong>Dynamically Healed To:</strong> <code style="background: #c3e6cb; color: #155724; padding: 2px 4px; border-radius: 3px;">{details.get('suggested_locator')}</code></p>
                <p style="margin: 3px 0;"><strong>Matched Attribute:</strong> <code>{details.get('matched_property')} = "{details.get('matched_value')}"</code></p>
            </div>
        </div>
        """
        logger.warn(f"[Self-Healing] Repaired locator '{broken}' -> '{details.get('suggested_locator')}' ({details.get('score')}%)")
        logger.info(html, html=True)

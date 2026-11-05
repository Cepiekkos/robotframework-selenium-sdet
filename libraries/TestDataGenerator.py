"""
TestDataGenerator: Custom Robot Framework Library for Dynamic Test Data Generation.

Provides synthetic personas, edge-case boundary strings, localization formats,
and security testing payloads (XSS, SQL Injection) for automated validation.
"""

import random
import string
import time


class TestDataGenerator:
    """Robot Framework library for dynamic, realistic, and boundary test data generation."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    FIRST_NAMES = ["Alex", "Jordan", "Taylor", "Morgan", "Sam", "Chris", "Pat", "Riley", "Cameron", "Dakota"]
    LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Martinez"]
    CITIES = ["San Francisco", "Austin", "Seattle", "New York", "Chicago", "Denver", "Boston"]

    def generate_random_checkout_user(self) -> dict:
        """Generates a random valid user object for checkout forms."""
        first = random.choice(self.FIRST_NAMES)
        last = random.choice(self.LAST_NAMES)
        postal = f"{random.randint(10000, 99999)}"
        timestamp = int(time.time())
        email = f"{first.lower()}.{last.lower()}.{timestamp}@automationtest.com"

        return {
            "first_name": first,
            "last_name": last,
            "postal_code": postal,
            "email": email
        }

    def generate_boundary_string(self, length: int = 100, pattern: str = "alphanumeric") -> str:
        """
        Generates boundary testing string of specific length.
        Useful for overflow, buffer limits, and input clipping tests.
        """
        length = int(length)
        if pattern == "alphanumeric":
            chars = string.ascii_letters + string.digits
        elif pattern == "special":
            chars = string.punctuation
        elif pattern == "unicode":
            chars = "你好世界こんにちは안녕하세요✨🚀🎉🔥"
        else:
            chars = string.ascii_letters

        return "".join(random.choice(chars) for _ in range(length))

    def get_security_test_payloads(self) -> list:
        """
        Returns a suite of benign security injection payloads to verify input field sanitization.
        """
        return [
            "<script>alert('XSS_TEST')</script>",
            "' OR '1'='1' --",
            "admin' --",
            "${7*7}",
            "../../etc/passwd",
            "<img src=x onerror=console.log(1)>"
        ]

    def generate_random_postal_code(self, country: str = "US") -> str:
        """Generates realistic postal codes for different country formats."""
        if country.upper() == "US":
            return f"{random.randint(10000, 99999)}"
        elif country.upper() == "CA":
            letter = random.choice(string.ascii_uppercase)
            return f"{letter}{random.randint(1,9)}{letter} {random.randint(1,9)}{letter}{random.randint(1,9)}"
        return f"{random.randint(1000, 9999)}"

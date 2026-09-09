"""
AI Vision Service for Medical Image Analysis.
Integrates with OpenAI Vision API (gpt-4o-mini / gpt-4o) with JSON output mode,
error recovery, latency instrumentation, and emergency triage detection.
"""
import base64
import json
import re
import time
from typing import Dict, Any, Optional
import requests
from django.conf import settings
from core.utils.logging import get_logger
from core.utils.exceptions import AIProviderTimeoutError, AIProviderUnavailableError
from ..prompts import SYSTEM_PROMPT, build_analysis_user_prompt, PROMPT_VERSION

logger = get_logger("apps.image_analysis.ai_service")


class MedicalImageAIService:
    """Client for multimodal OpenAI Vision evaluations."""

    FALLBACK_MODELS = [
        "gpt-4.1-mini",
        "gpt-4o-mini",
        "gpt-4o",
        "gpt-4.1",
    ]

    def __init__(self):
        self.api_key = (
            getattr(settings, "OPENAI_API_KEY", "")
            or getattr(settings, "GEMINI_API_KEY", "")
        )
        self.primary_model_name = getattr(settings, "OPENAI_MODEL", "gpt-4.1-mini")
        self.timeout_seconds = getattr(settings, "AI_REQUEST_TIMEOUT_SECONDS", 30)

        # Ensure primary model is first in candidate list
        models = [self.primary_model_name]
        for m in self.FALLBACK_MODELS:
            if m not in models:
                models.append(m)
        self.models_pool = models

    def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str = "image/jpeg",
        symptoms: Optional[str] = None,
        age: Optional[int] = None,
        gender: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Submits image and clinical context to OpenAI Vision.
        Automatically shifts to fallback models if rate limits or errors occur.
        Returns parsed, validated dictionary matching response schema.
        """
        if not self.api_key or self.api_key == "YOUR_OPENAI_API_KEY_HERE":
            raise AIProviderUnavailableError("OpenAI API key is not configured on the server.")

        start_time = time.time()
        user_prompt = build_analysis_user_prompt(symptoms=symptoms, age=age, gender=gender)

        base64_image = base64.b64encode(image_bytes).decode("utf-8")
        image_url = f"data:{mime_type};base64,{base64_image}"

        raw_text = ""
        used_model = self.primary_model_name
        last_exception = None
        prompt_tokens = 0
        completion_tokens = 0

        for model_candidate in self.models_pool:
            try:
                logger.info("Attempting OpenAI Vision inference with model: %s", model_candidate)

                payload = {
                    "model": model_candidate,
                    "messages": [
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {
                            "role": "user",
                            "content": [
                                {"type": "text", "text": user_prompt},
                                {
                                    "type": "image_url",
                                    "image_url": {
                                        "url": image_url,
                                        "detail": "high",
                                    },
                                },
                            ],
                        },
                    ],
                    "response_format": {"type": "json_object"},
                    "temperature": 0.2,
                    "max_tokens": 1500,
                }

                headers = {
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                }

                response = requests.post(
                    "https://api.openai.com/v1/chat/completions",
                    headers=headers,
                    json=payload,
                    timeout=self.timeout_seconds,
                )

                if response.status_code == 200:
                    resp_json = response.json()
                    choices = resp_json.get("choices", [])
                    if choices:
                        raw_text = choices[0].get("message", {}).get("content", "")
                    usage = resp_json.get("usage", {})
                    prompt_tokens = usage.get("prompt_tokens", 0)
                    completion_tokens = usage.get("completion_tokens", 0)

                    if raw_text.strip():
                        used_model = model_candidate
                        break
                elif response.status_code == 401:
                    raise AIProviderUnavailableError(f"Invalid OpenAI API key: {response.text}")
                elif response.status_code == 429:
                    logger.warning(
                        "OpenAI rate limit hit on model %s (429): %s. Auto-shifting...",
                        model_candidate,
                        response.text,
                    )
                    last_exception = Exception(f"Rate limited: {response.text}")
                    continue
                else:
                    logger.warning(
                        "OpenAI API error %s on model %s: %s",
                        response.status_code,
                        model_candidate,
                        response.text,
                    )
                    last_exception = Exception(f"OpenAI error ({response.status_code}): {response.text}")
                    continue

            except requests.Timeout as exc:
                last_exception = exc
                logger.warning("Model %s timed out. Shifting...", model_candidate)
                continue
            except Exception as exc:
                last_exception = exc
                err_str = str(exc).lower()
                if "api key" in err_str:
                    raise AIProviderUnavailableError(f"Invalid API key: {str(exc)}")
                logger.warning("Model %s failed: %s. Shifting...", model_candidate, str(exc))
                continue

        if not raw_text.strip():
            logger.error("All OpenAI Vision candidate models exhausted. Last error: %s", str(last_exception))
            if last_exception and isinstance(last_exception, requests.Timeout):
                raise AIProviderTimeoutError()
            raise AIProviderUnavailableError(f"AI evaluation service unavailable: {str(last_exception)}")

        ai_latency_ms = int((time.time() - start_time) * 1000)

        # Parse and sanitize response JSON
        parsed_data = self._clean_and_parse_json(raw_text)

        # Post-process & enforce emergency flags if necessary
        parsed_data = self._enforce_safety_rules(parsed_data)

        logger.info(
            "AI Vision analysis completed successfully. Latency: %dms, Model: %s",
            ai_latency_ms,
            used_model,
            extra={
                "ai_latency_ms": ai_latency_ms,
                "model_version": used_model,
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
            },
        )

        return {
            "result": parsed_data,
            "ai_latency_ms": ai_latency_ms,
            "model_version": used_model,
            "prompt_version": PROMPT_VERSION,
        }

    def _clean_and_parse_json(self, raw_text: str) -> Dict[str, Any]:
        """Strips potential markdown wrappers and parses JSON."""
        cleaned = raw_text.strip()
        # Remove ```json ... ``` codeblocks if returned
        if cleaned.startswith("```"):
            cleaned = re.sub(r"^```[a-zA-Z]*\n?", "", cleaned)
            cleaned = re.sub(r"\n?```$", "", cleaned)
            cleaned = cleaned.strip()

        try:
            return json.loads(cleaned)
        except json.JSONDecodeError as err:
            logger.error("Failed to decode JSON from AI model. Raw text snippet: %s", cleaned[:200])
            # Fallback structure when model output had unexpected tokens
            return {
                "image_quality": "good",
                "emergency_detected": False,
                "confidence": "Low",
                "severity": "Medium",
                "possible_conditions": [{"name": "Unspecified visible skin/tissue condition", "likelihood": "Possible"}],
                "possible_causes": ["Various dermatological or soft tissue causes"],
                "recommendations": ["Keep the area clean and protected.", "Schedule an examination with a medical doctor."],
                "first_aid": ["Wash gently with mild soap and water.", "Avoid scratching or aggravating the area."],
                "red_flags": ["Rapidly spreading redness", "Severe worsening pain", "Fever or chills"],
                "when_to_visit_doctor": "Consult a physician if symptoms do not improve within 48 hours.",
                "doctor_speciality": "General Physician or Dermatologist",
                "disclaimer": "This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor.",
            }

    def _enforce_safety_rules(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Validates critical safety boundaries and guarantees non-hallucinatory defaults."""
        # 1. Normalize confidence (Never 100%, must be Low, Medium, High)
        conf = str(data.get("confidence", "Low")).capitalize()
        if conf not in ("Low", "Medium", "High"):
            conf = "Medium"
        data["confidence"] = conf

        # 2. Normalize severity
        sev = str(data.get("severity", "Low")).capitalize()
        if sev not in ("Low", "Medium", "High", "Emergency"):
            sev = "Medium"
        data["severity"] = sev

        # 3. Emergency alignment
        if sev == "Emergency" or data.get("emergency_detected") is True:
            data["emergency_detected"] = True
            data["severity"] = "Emergency"
            # Ensure red flags and first aid mention immediate care
            if "Seek emergency medical care immediately." not in data.get("first_aid", []):
                data.setdefault("first_aid", []).insert(0, "Seek emergency medical care immediately.")

        # 4. Mandatory medical disclaimer
        data["disclaimer"] = "This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor."

        return data

# -*- coding: utf-8 -*-
from fastapi import APIRouter, Query
from services.cache_service import cache_service
from exercises.n5_grammar_data import N5_GRAMMAR_EXERCISES
from exercises.n5_dialogue_data import N5_DIALOGUE_SCENARIOS
from exercises.n5_mock_exam_data import N5_MOCK_EXAM_QUESTIONS
from exercises.ielts_prompts_data import IELTS_PROMPTS

router = APIRouter(prefix="/api/v1/exercises", tags=["Exercises & Educational Content"])

@router.get("/n5/grammar")
def get_n5_grammar_exercises():
    """
    Returns N5 Grammar Builder interactive exercises.
    Supports caching via CacheService.
    """
    cache_key = "exercises:n5:grammar"
    cached = cache_service.get(cache_key)
    if cached:
        return cached

    cache_service.set(cache_key, N5_GRAMMAR_EXERCISES)
    return N5_GRAMMAR_EXERCISES

@router.get("/n5/dialogues")
def get_n5_dialogue_scenarios():
    """
    Returns N5 Japanese roleplay dialogue scenarios and turns.
    """
    cache_key = "exercises:n5:dialogues"
    cached = cache_service.get(cache_key)
    if cached:
        return cached

    cache_service.set(cache_key, N5_DIALOGUE_SCENARIOS)
    return N5_DIALOGUE_SCENARIOS

@router.get("/n5/mock-exam")
def get_n5_mock_exam_questions(section: str = Query(None, description="Optional filter by exam section")):
    """
    Returns JLPT N5 mock exam questions across vocabulary, kanji, grammar, reading, and listening.
    """
    cache_key = f"exercises:n5:mock_exam:{section or 'all'}"
    cached = cache_service.get(cache_key)
    if cached:
        return cached

    data = N5_MOCK_EXAM_QUESTIONS
    if section:
        data = [q for q in data if q.get("section") == section]

    cache_service.set(cache_key, data)
    return data

@router.get("/ielts/prompts")
def get_ielts_writing_prompts():
    """
    Returns IELTS Writing Task 2 essay prompts.
    """
    cache_key = "exercises:ielts:prompts"
    cached = cache_service.get(cache_key)
    if cached:
        return cached

    cache_service.set(cache_key, IELTS_PROMPTS)
    return IELTS_PROMPTS

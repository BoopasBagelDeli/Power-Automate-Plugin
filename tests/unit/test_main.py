"""
Unit tests for power-automate
"""
import pytest
from power_automate import main

def test_initialize():
    """Test initialization"""
    result = main.initialize()
    assert result is True

def test_get_info():
    """Test get_info function"""
    info = main.get_info()
    assert info["name"] == "power-automate"
    assert "version" in info
    assert "description" in info

"""
Django settings for barbuddy_api project.
"""

import os
import sys
from pathlib import Path
import environ

# -------------------------------------------------------------------------
# 1) Define BASE_DIR a single time
#    (Path(__file__).resolve().parent.parent should be your "backend" folder)
# -------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent

# -------------------------------------------------------------------------
# 2) Set up django-environ and read from .env once
# -------------------------------------------------------------------------
env = environ.Env()
environ.Env.read_env(os.path.join(BASE_DIR, ".env"))

# -------------------------------------------------------------------------
# 3) Now read your SECRET_KEY (and other settings) from .env
# -------------------------------------------------------------------------
SECRET_KEY = env("SECRET_KEY")

# If for some reason you want a fallback in dev, you could do:
# SECRET_KEY = env("SECRET_KEY", default="dev_fallback_key")  # NOT for production

# -------------------------------------------------------------------------
# 4) Add apps directory to Python path (if needed)
# -------------------------------------------------------------------------
sys.path.append(os.path.join(BASE_DIR, "apps"))

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []

# -------------------------------------------------------------------------
# Your installed apps, middleware, etc. remain the same
# -------------------------------------------------------------------------
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "rest_framework_simplejwt",
    "apps.users",
    "apps.bars",
    "apps.events",
    "apps.matches",
    "apps.messaging",
    "barbuddy_api",
]

AUTH_USER_MODEL = "users.User"

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "barbuddy_api.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "barbuddy_api.wsgi.application"

# Database settings...
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "barbuddy_db",
        "USER": "barbuddy_user",
        "PASSWORD": "admin123",
        "HOST": "localhost",
        "PORT": "5432",
    }
}

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
}

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

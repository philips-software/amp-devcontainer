from datetime import datetime

def strftime_filter(value, fmt):
    if value.endswith('Z'):
        value = value[:-1] + '+00:00'

    return datetime.fromisoformat(value).strftime(fmt)

filters = { 'strftime': strftime_filter }

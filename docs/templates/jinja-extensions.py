import datetime

def strftime_filter(value, fmt):
    return datetime.datetime.fromisoformat(value).strftime(fmt)

filters = { 'strftime': strftime_filter }

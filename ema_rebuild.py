__version__ = "1.0.0"

from config import *


def rebuild_emas(ema_engine, minute_prices):
    """
    Rebuild EMA state using 1-minute price series.

    minute_prices: list of floats ordered oldest → newest
    """

    if len(minute_prices) < 120:
        raise Exception("Not enough data to rebuild EMA")

    # ===== EMA1885 (use full 120 minutes)
    ema_engine.values[EMA20_PERIOD] = None
    for price in minute_prices:
        _update_single(ema_engine, EMA20_PERIOD, price)

    # ===== EMA475 (last 15 minutes)
    ema_engine.values[EMA5_PERIOD] = None
    for price in minute_prices[-15:]:
        _update_single(ema_engine, EMA5_PERIOD, price)

    # ===== EMA260 (last 9 minutes)
    ema_engine.values[EMA3_PERIOD] = None
    for price in minute_prices[-9:]:
        _update_single(ema_engine, EMA3_PERIOD, price)


def _update_single(ema_engine, period, price):
    """
    Update a single EMA without touching others.
    """

    if ema_engine.values[period] is None:
        ema_engine.values[period] = price
    else:
        alpha = ema_engine.alpha[period]
        ema_engine.values[period] = alpha * price + (1 - alpha) * ema_engine.values[period]
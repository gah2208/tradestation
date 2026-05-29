__version__ = "1.1.0"
# Copyright 2026 Gregory Howard  all rights reserved.

from datetime import datetime
import math


class EMAEngine:

    def __init__(self, ema_seconds_list):
        """
        ema_seconds_list: list of EMA durations in seconds
        Example: [540, 900, 3600]
        """

        self.targets = ema_seconds_list

        # tau = EMA time constant (same as period in your design)
        self.taus = {t: float(t) for t in ema_seconds_list}

        self.values = {t: None for t in ema_seconds_list}
        self.last_timestamp = None

        # optional slope history storage
        self.history = {t: [] for t in ema_seconds_list}


    def update(self, price, timestamp=None):
        """
        Continuous EMA update using time delta

        alpha = 1 - exp(-dt / tau)
        EMA = EMA_prev + alpha * (price - EMA_prev)
        """

        if timestamp is None:
            timestamp = datetime.now()

        if self.last_timestamp is None:
            # initialize all EMAs to first price
            for t in self.targets:
                self.values[t] = price
            self.last_timestamp = timestamp
            return

        dt = (timestamp - self.last_timestamp).total_seconds()

        # guard against zero or negative time
        if dt <= 0:
            return

        for t in self.targets:

            tau = self.taus[t]

            # continuous-time smoothing factor
            alpha = 1.0 - math.exp(-dt / tau)

            prev = self.values[t]

            if prev is None:
                self.values[t] = price
            else:
                self.values[t] = prev + alpha * (price - prev)

            # store history for slope calculations
            self.history[t].append(self.values[t])

        self.last_timestamp = timestamp


    def get(self, seconds):
        return self.values.get(seconds)


    def get_all(self):
        return self.values.copy()


    def get_slope(self, seconds, lookback_seconds):

        series = self.history.get(seconds, [])

        if len(series) < 2:
            return 0.0

        # number of samples to approximate lookback
        n = min(len(series) - 1, int(lookback_seconds))

        if n <= 0:
            return 0.0

        return (series[-1] - series[-(n + 1)]) / float(n)
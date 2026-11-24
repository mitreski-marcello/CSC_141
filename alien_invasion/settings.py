class Settings:
    """Settings for Galaxy Edition of Alien Invasion."""

    def __init__(self):
        self.screen_width = 1200
        self.screen_height = 800
        self.bg_color = (5, 7, 28)
        self.ship_limit = 3

        # Fireball settings.
        self.bullet_speed = 8.0
        self.bullets_allowed = 5
        self.bullet_width = 18
        self.bullet_height = 30

        self.fleet_drop_speed = 18
        self.speedup_scale = 1.16
        self.score_scale = 1.35
        self.initialize_dynamic_settings()

    def initialize_dynamic_settings(self):
        self.ship_speed = 7.0
        self.alien_speed = 1.15
        self.fleet_direction = 1
        self.alien_points = 50

    def increase_speed(self):
        self.ship_speed *= self.speedup_scale
        self.bullet_speed *= self.speedup_scale
        self.alien_speed *= self.speedup_scale
        self.alien_points = int(self.alien_points * self.score_scale)

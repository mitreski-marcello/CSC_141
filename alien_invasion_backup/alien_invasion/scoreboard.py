import pygame.font
from pygame.sprite import Group
from ship import Ship


class Scoreboard:
    """Draw the score, high score, level, and remaining ships."""

    def __init__(self, ai_game):
        self.ai_game = ai_game
        self.screen = ai_game.screen
        self.screen_rect = self.screen.get_rect()
        self.settings = ai_game.settings
        self.stats = ai_game.stats
        self.text_color = (225, 240, 255)
        self.font = pygame.font.SysFont("consolas", 30, bold=True)
        self.small_font = pygame.font.SysFont("consolas", 22, bold=True)
        self.prep_score()
        self.prep_high_score()
        self.prep_level()
        self.prep_ships()

    def _render_label(self, label, value, font=None):
        font = font or self.font
        return font.render(f"{label}: {value}", True, self.text_color)

    def prep_score(self):
        self.score_image = self._render_label("SCORE", f"{self.stats.score:,}")
        self.score_rect = self.score_image.get_rect()
        self.score_rect.right = self.screen_rect.right - 24
        self.score_rect.top = 18

    def prep_high_score(self):
        self.high_score_image = self._render_label(
            "BEST", f"{self.stats.high_score:,}", self.small_font)
        self.high_score_rect = self.high_score_image.get_rect()
        self.high_score_rect.centerx = self.screen_rect.centerx
        self.high_score_rect.top = 24

    def prep_level(self):
        self.level_image = self._render_label("LEVEL", self.stats.level)
        self.level_rect = self.level_image.get_rect()
        self.level_rect.right = self.screen_rect.right - 24
        self.level_rect.top = self.score_rect.bottom + 8

    def prep_ships(self):
        self.ships = Group()
        for ship_number in range(self.stats.ships_left):
            ship = Ship(self.ai_game)
            ship.image = pygame.transform.smoothscale(ship.image, (34, 34))
            ship.rect = ship.image.get_rect()
            ship.rect.x = 22 + ship_number * 40
            ship.rect.y = 18
            self.ships.add(ship)

    def check_high_score(self):
        if self.stats.score > self.stats.high_score:
            self.stats.high_score = self.stats.score
            self.prep_high_score()

    def show_score(self):
        # Dark translucent strip keeps the HUD readable over the galaxy.
        panel = pygame.Surface((self.screen_rect.width, 68), pygame.SRCALPHA)
        panel.fill((3, 7, 24, 150))
        self.screen.blit(panel, (0, 0))
        self.screen.blit(self.score_image, self.score_rect)
        self.screen.blit(self.high_score_image, self.high_score_rect)
        self.screen.blit(self.level_image, self.level_rect)
        self.ships.draw(self.screen)

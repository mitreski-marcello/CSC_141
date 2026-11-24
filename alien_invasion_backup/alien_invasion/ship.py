from pathlib import Path
import pygame
from pygame.sprite import Sprite


class Ship(Sprite):
    """Player ship for Galaxy Edition."""

    def __init__(self, ai_game):
        super().__init__()
        self.screen = ai_game.screen
        self.settings = ai_game.settings
        self.screen_rect = self.screen.get_rect()
        image_path = Path(__file__).parent / "images" / "ship.png"
        self.image = pygame.image.load(str(image_path)).convert_alpha()
        self.image = pygame.transform.smoothscale(self.image, (76, 76))
        self.rect = self.image.get_rect()
        self.rect.midbottom = self.screen_rect.midbottom
        self.rect.bottom -= 18
        self.x = float(self.rect.x)
        self.moving_right = False
        self.moving_left = False

    def update(self):
        if self.moving_right:
            self.x += self.settings.ship_speed
        if self.moving_left:
            self.x -= self.settings.ship_speed
        self.x = max(0, min(self.x, self.screen_rect.width - self.rect.width))
        self.rect.x = round(self.x)

    def blitme(self):
        self.screen.blit(self.image, self.rect)

    def center_ship(self):
        self.rect.midbottom = self.screen_rect.midbottom
        self.rect.bottom -= 18
        self.x = float(self.rect.x)

import pygame
from pygame.sprite import Sprite


class Bullet(Sprite):
    """A glowing fireball projectile."""

    def __init__(self, ai_game):
        super().__init__()
        self.screen = ai_game.screen
        self.settings = ai_game.settings
        self.rect = pygame.Rect(0, 0, self.settings.bullet_width,
                                self.settings.bullet_height)
        self.rect.midbottom = ai_game.ship.rect.midtop
        self.y = float(self.rect.y)

    def update(self):
        self.y -= self.settings.bullet_speed
        self.rect.y = round(self.y)

    def draw_bullet(self):
        # Draw a soft halo and a bright, tapered fireball.
        cx = self.rect.centerx
        cy = self.rect.centery
        pygame.draw.ellipse(self.screen, (255, 75, 20),
                            (cx - 13, cy - 17, 26, 36))
        pygame.draw.ellipse(self.screen, (255, 175, 35),
                            (cx - 8, cy - 13, 16, 27))
        pygame.draw.ellipse(self.screen, (255, 245, 175),
                            (cx - 4, cy - 9, 8, 17))
        pygame.draw.polygon(self.screen, (255, 105, 20),
                            [(cx, cy - 22), (cx - 8, cy - 4), (cx + 8, cy - 4)])

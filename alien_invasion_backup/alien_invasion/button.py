from pathlib import Path
import pygame


class Button:
    """A custom illustrated neon Play button."""

    def __init__(self, ai_game, msg="PLAY"):
        self.screen = ai_game.screen
        self.image = pygame.image.load(
            str(Path(__file__).parent / "images" / "play_button.png")
        ).convert_alpha()
        self.image = pygame.transform.smoothscale(self.image, (300, 92))
        self.rect = self.image.get_rect()
        self.rect.center = self.screen.get_rect().center
        self.msg = msg

    def draw_button(self):
        self.screen.blit(self.image, self.rect)

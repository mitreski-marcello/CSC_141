import sys
from pathlib import Path
import pygame

from settings import Settings
from game_stats import GameStats
from scoreboard import Scoreboard
from button import Button
from ship import Ship
from bullet import Bullet
from alien import Alien


class AlienInvasion:
    """Run the Galaxy Edition space shooter."""

    def __init__(self):
        pygame.init()
        self.audio_available = False
        try:
            pygame.mixer.init()
            self.audio_available = True
        except pygame.error:
            pass

        self.clock = pygame.time.Clock()
        self.settings = Settings()
        self.screen = pygame.display.set_mode(
            (self.settings.screen_width, self.settings.screen_height))
        pygame.display.set_caption("ALIEN INVASION: GALAXY EDITION")

        root = Path(__file__).parent
        self.background = pygame.image.load(
            str(root / "images" / "galaxy.png")).convert()
        self.background = pygame.transform.smoothscale(
            self.background, (self.settings.screen_width,
                              self.settings.screen_height))
        self.background_y = 0.0
        self.background_speed = 22.0

        self.sounds = {}
        if self.audio_available:
            for name in ("shoot", "explosion", "level_up", "game_over"):
                try:
                    self.sounds[name] = pygame.mixer.Sound(
                        str(root / "sounds" / f"{name}.wav"))
                except (pygame.error, OSError):
                    pass
            try:
                pygame.mixer.music.load(str(root / "sounds" / "space_music.wav"))
                pygame.mixer.music.set_volume(0.22)
                pygame.mixer.music.play(-1)
            except (pygame.error, OSError):
                pass

        self.title_font = pygame.font.SysFont("consolas", 54, bold=True)
        self.info_font = pygame.font.SysFont("consolas", 22, bold=True)

        self.stats = GameStats(self)
        self.sb = Scoreboard(self)
        self.ship = Ship(self)
        self.bullets = pygame.sprite.Group()
        self.aliens = pygame.sprite.Group()
        self._create_fleet()
        self.game_active = False
        self.play_button = Button(self, "PLAY")

    def _play_sound(self, name):
        sound = self.sounds.get(name)
        if sound:
            sound.play()

    def run_game(self):
        while True:
            self._check_events()
            if self.game_active:
                self.ship.update()
                self._update_bullets()
                self._update_aliens()
            self.background_y = (self.background_y +
                                 self.background_speed / 60) % self.settings.screen_height
            self._update_screen()
            self.clock.tick(60)

    def _check_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            elif event.type == pygame.KEYDOWN:
                self._check_keydown_events(event)
            elif event.type == pygame.KEYUP:
                self._check_keyup_events(event)
            elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                self._check_play_button(pygame.mouse.get_pos())

    def _check_play_button(self, mouse_pos):
        if self.play_button.rect.collidepoint(mouse_pos) and not self.game_active:
            self.settings.initialize_dynamic_settings()
            self.stats.reset_stats()
            self.sb.prep_score()
            self.sb.prep_level()
            self.sb.prep_ships()
            self.game_active = True
            self.bullets.empty()
            self.aliens.empty()
            self._create_fleet()
            self.ship.center_ship()
            pygame.mouse.set_visible(False)

    def _check_keydown_events(self, event):
        if event.key in (pygame.K_RIGHT, pygame.K_d):
            self.ship.moving_right = True
        elif event.key in (pygame.K_LEFT, pygame.K_a):
            self.ship.moving_left = True
        elif event.key == pygame.K_q or event.key == pygame.K_ESCAPE:
            pygame.quit()
            sys.exit()
        elif event.key == pygame.K_SPACE:
            if not self.game_active:
                self._check_play_button(self.play_button.rect.center)
            else:
                self._fire_bullet()
        elif event.key == pygame.K_p and not self.game_active:
            self._check_play_button(self.play_button.rect.center)

    def _check_keyup_events(self, event):
        if event.key in (pygame.K_RIGHT, pygame.K_d):
            self.ship.moving_right = False
        elif event.key in (pygame.K_LEFT, pygame.K_a):
            self.ship.moving_left = False

    def _fire_bullet(self):
        if len(self.bullets) < self.settings.bullets_allowed:
            self.bullets.add(Bullet(self))
            self._play_sound("shoot")

    def _update_bullets(self):
        self.bullets.update()
        for bullet in self.bullets.copy():
            if bullet.rect.bottom <= 0:
                self.bullets.remove(bullet)
        collisions = pygame.sprite.groupcollide(self.bullets, self.aliens, True, True)
        if collisions:
            destroyed = sum(len(group) for group in collisions.values())
            self.stats.score += self.settings.alien_points * destroyed
            self.sb.prep_score()
            self.sb.check_high_score()
            self._play_sound("explosion")
        if not self.aliens:
            self.bullets.empty()
            self._create_fleet()
            self.settings.increase_speed()
            self.stats.level += 1
            self.sb.prep_level()
            self._play_sound("level_up")

    def _ship_hit(self):
        if self.stats.ships_left > 0:
            self.stats.ships_left -= 1
            self.sb.prep_ships()
            self.bullets.empty()
            self.aliens.empty()
            self._create_fleet()
            self.ship.center_ship()
            pygame.time.delay(350)
        else:
            self.game_active = False
            pygame.mouse.set_visible(True)
            self._play_sound("game_over")

    def _update_aliens(self):
        self._check_fleet_edges()
        self.aliens.update()
        if pygame.sprite.spritecollideany(self.ship, self.aliens):
            self._ship_hit()
        self._check_aliens_bottom()

    def _check_aliens_bottom(self):
        for alien in self.aliens.sprites():
            if alien.rect.bottom >= self.settings.screen_height:
                self._ship_hit()
                break

    def _create_fleet(self):
        alien = Alien(self)
        alien_width, alien_height = alien.rect.size
        current_x, current_y = alien_width, alien_height + 65
        while current_y < self.settings.screen_height - 3 * alien_height:
            while current_x < self.settings.screen_width - 2 * alien_width:
                self._create_alien(current_x, current_y)
                current_x += 1.65 * alien_width
            current_x = alien_width
            current_y += 1.55 * alien_height

    def _create_alien(self, x_position, y_position):
        new_alien = Alien(self)
        new_alien.x = float(x_position)
        new_alien.rect.x = round(x_position)
        new_alien.rect.y = round(y_position)
        self.aliens.add(new_alien)

    def _check_fleet_edges(self):
        for alien in self.aliens.sprites():
            if alien.check_edges():
                self._change_fleet_direction()
                break

    def _change_fleet_direction(self):
        for alien in self.aliens.sprites():
            alien.rect.y += self.settings.fleet_drop_speed
        self.settings.fleet_direction *= -1

    def _draw_scrolling_background(self):
        y = int(self.background_y)
        self.screen.blit(self.background, (0, y - self.settings.screen_height))
        self.screen.blit(self.background, (0, y))

    def _update_screen(self):
        self._draw_scrolling_background()
        for bullet in self.bullets.sprites():
            bullet.draw_bullet()
        self.ship.blitme()
        self.aliens.draw(self.screen)
        self.sb.show_score()

        if not self.game_active:
            shade = pygame.Surface(self.screen.get_size(), pygame.SRCALPHA)
            shade.fill((2, 4, 20, 115))
            self.screen.blit(shade, (0, 0))
            title = self.title_font.render("GALAXY INVASION", True, (225, 240, 255))
            title_rect = title.get_rect(center=(self.settings.screen_width // 2, 235))
            self.screen.blit(title, title_rect)
            subtitle = self.info_font.render(
                "DEFEND THE GALAXY • SURVIVE THE WAVES", True, (150, 205, 255))
            self.screen.blit(subtitle, subtitle.get_rect(
                center=(self.settings.screen_width // 2, 300)))
            self.play_button.draw_button()
            controls = self.info_font.render(
                "← → or A / D  MOVE     SPACE  FIRE     P  PLAY     Q  QUIT",
                True, (220, 225, 255))
            self.screen.blit(controls, controls.get_rect(
                center=(self.settings.screen_width // 2, 475)))
        pygame.display.flip()


if __name__ == "__main__":
    game = AlienInvasion()
    game.run_game()

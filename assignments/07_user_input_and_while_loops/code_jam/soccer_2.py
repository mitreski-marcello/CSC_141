import pygame  # type: ignore
pygame.init()
clock = pygame.time.Clock()
screen = pygame.display.set_mode((800, 600))
my_image = pygame.image.load("assignments/code_jam/media/soccer_ball_small.png")
image_rect = my_image.get_rect()


running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    screen.fill((173, 216, 230))
    image_rect.x += 5


    if image_rect.x > screen.get_width():
        image_rect.x = -image_rect.width
    screen.blit(my_image, image_rect)
    pygame.display.flip()
    clock.tick(60) #FPS
extends Node2D


# =========================================================
# GAME SETTINGS
# =========================================================

const SCREEN_WIDTH = 900
const SCREEN_HEIGHT = 600

const PADDLE_WIDTH = 20
const PADDLE_HEIGHT = 120
const PADDLE_SPEED = 500.0

const BALL_SIZE = 20
const BALL_SPEED = 400.0

const WINNING_SCORE = 10


# =========================================================
# GAME VARIABLES
# =========================================================

var player1_y = 240.0
var player2_y = 240.0

var ball_position = Vector2(440, 290)
var ball_velocity = Vector2(1, 0.5).normalized() * BALL_SPEED

var player1_score = 0
var player2_score = 0

var game_over = false


# =========================================================
# START
# =========================================================

func _ready():
	reset_ball()
	queue_redraw()


# =========================================================
# GAME LOOP
# =========================================================

func _process(delta):

	# -----------------------------------------------------
	# PLAYER 1 - W / S
	# -----------------------------------------------------

	if Input.is_physical_key_pressed(KEY_W):
		player1_y -= PADDLE_SPEED * delta

	if Input.is_physical_key_pressed(KEY_S):
		player1_y += PADDLE_SPEED * delta


	# -----------------------------------------------------
	# PLAYER 2 - UP / DOWN
	# -----------------------------------------------------

	if Input.is_physical_key_pressed(KEY_UP):
		player2_y -= PADDLE_SPEED * delta

	if Input.is_physical_key_pressed(KEY_DOWN):
		player2_y += PADDLE_SPEED * delta


	# -----------------------------------------------------
	# KEEP PADDLES INSIDE SCREEN
	# -----------------------------------------------------

	player1_y = clamp(
		player1_y,
		10.0,
		SCREEN_HEIGHT - PADDLE_HEIGHT - 10.0
	)

	player2_y = clamp(
		player2_y,
		10.0,
		SCREEN_HEIGHT - PADDLE_HEIGHT - 10.0
	)


	# -----------------------------------------------------
	# DON'T MOVE BALL AFTER GAME OVER
	# -----------------------------------------------------

	if game_over:
		queue_redraw()
		return


	# -----------------------------------------------------
	# MOVE BALL
	# -----------------------------------------------------

	ball_position += ball_velocity * delta


	# -----------------------------------------------------
	# TOP WALL
	# -----------------------------------------------------

	if ball_position.y <= 10:
		ball_position.y = 10
		ball_velocity.y = abs(ball_velocity.y)


	# -----------------------------------------------------
	# BOTTOM WALL
	# -----------------------------------------------------

	if ball_position.y >= SCREEN_HEIGHT - BALL_SIZE - 10:
		ball_position.y = SCREEN_HEIGHT - BALL_SIZE - 10
		ball_velocity.y = -abs(ball_velocity.y)


	# -----------------------------------------------------
	# PLAYER 1 COLLISION
	# -----------------------------------------------------

	if ball_velocity.x < 0:

		if ball_position.x <= 60 and ball_position.x + BALL_SIZE >= 40:

			if (
				ball_position.y + BALL_SIZE >= player1_y
				and ball_position.y <= player1_y + PADDLE_HEIGHT
			):
				ball_position.x = 60
				ball_velocity.x = abs(ball_velocity.x)


	# -----------------------------------------------------
	# PLAYER 2 COLLISION
	# -----------------------------------------------------

	if ball_velocity.x > 0:

		if ball_position.x + BALL_SIZE >= SCREEN_WIDTH - 60:

			if (
				ball_position.y + BALL_SIZE >= player2_y
				and ball_position.y <= player2_y + PADDLE_HEIGHT
			):
				ball_position.x = SCREEN_WIDTH - 60 - BALL_SIZE
				ball_velocity.x = -abs(ball_velocity.x)


	# -----------------------------------------------------
	# PLAYER 2 SCORES
	# BALL LEAVES LEFT SIDE
	# -----------------------------------------------------

	if ball_position.x < -BALL_SIZE:

		player2_score += 1

		if player2_score >= WINNING_SCORE:
			game_over = true
		else:
			reset_ball()


	# -----------------------------------------------------
	# PLAYER 1 SCORES
	# BALL LEAVES RIGHT SIDE
	# -----------------------------------------------------

	if ball_position.x > SCREEN_WIDTH:

		player1_score += 1

		if player1_score >= WINNING_SCORE:
			game_over = true
		else:
			reset_ball()


	# -----------------------------------------------------
	# REDRAW
	# -----------------------------------------------------

	queue_redraw()


# =========================================================
# KEYBOARD INPUT
# =========================================================

func _input(event):

	if event is InputEventKey:

		if event.pressed and not event.echo:

			# R = Restart
			if event.physical_keycode == KEY_R:

				player1_score = 0
				player2_score = 0

				player1_y = 240.0
				player2_y = 240.0

				game_over = false

				reset_ball()

				queue_redraw()


# =========================================================
# RESET BALL
# =========================================================

func reset_ball():

	# Put ball in center
	ball_position = Vector2(
		SCREEN_WIDTH / 2.0 - BALL_SIZE / 2.0,
		SCREEN_HEIGHT / 2.0 - BALL_SIZE / 2.0
	)


	# If Player 1 just scored,
	# send ball toward Player 2

	if player1_score > player2_score:

		ball_velocity = Vector2(1, 0.5).normalized() * BALL_SPEED


	# If Player 2 just scored,
	# send ball toward Player 1

	else:

		ball_velocity = Vector2(-1, 0.5).normalized() * BALL_SPEED


# =========================================================
# DRAW EVERYTHING
# =========================================================

func _draw():

	# -----------------------------------------------------
	# BACKGROUND
	# -----------------------------------------------------

	draw_rect(
		Rect2(
			0,
			0,
			SCREEN_WIDTH,
			SCREEN_HEIGHT
		),
		Color(0.03, 0.03, 0.08)
	)


	# -----------------------------------------------------
	# TOP WALL
	# -----------------------------------------------------

	draw_rect(
		Rect2(
			0,
			0,
			SCREEN_WIDTH,
			10
		),
		Color.WHITE
	)


	# -----------------------------------------------------
	# BOTTOM WALL
	# -----------------------------------------------------

	draw_rect(
		Rect2(
			0,
			SCREEN_HEIGHT - 10,
			SCREEN_WIDTH,
			10
		),
		Color.WHITE
	)


	# -----------------------------------------------------
	# CENTER LINE
	# -----------------------------------------------------

	for y in range(20, SCREEN_HEIGHT - 20, 30):

		draw_rect(
			Rect2(
				SCREEN_WIDTH / 2.0 - 3,
				y,
				6,
				15
			),
			Color.WHITE
		)


	# -----------------------------------------------------
	# PLAYER 1 PADDLE
	# -----------------------------------------------------

	draw_rect(
		Rect2(
			40,
			player1_y,
			PADDLE_WIDTH,
			PADDLE_HEIGHT
		),
		Color.WHITE
	)


	# -----------------------------------------------------
	# PLAYER 2 PADDLE
	# -----------------------------------------------------

	draw_rect(
		Rect2(
			SCREEN_WIDTH - 60,
			player2_y,
			PADDLE_WIDTH,
			PADDLE_HEIGHT
		),
		Color.WHITE
	)


	# -----------------------------------------------------
	# BALL
	# -----------------------------------------------------

	draw_rect(
		Rect2(
			ball_position.x,
			ball_position.y,
			BALL_SIZE,
			BALL_SIZE
		),
		Color.WHITE
	)


	# -----------------------------------------------------
	# SCORE
	# -----------------------------------------------------

	var font = ThemeDB.fallback_font


	draw_string(
		font,
		Vector2(358, 70),
		str(player1_score),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		48,
		Color.WHITE
	)


	draw_string(
		font,
		Vector2(533, 70),
		str(player2_score),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		48,
		Color.WHITE
	)


	# -----------------------------------------------------
	# PLAYER LABELS
	# -----------------------------------------------------

	draw_string(
		font,
		Vector2(40, 580),
		"PLAYER 1 [W / S]",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18,
		Color.WHITE
	)


	draw_string(
		font,
		Vector2(650, 580),
		"PLAYER 2 [UP / DOWN]",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18,
		Color.WHITE
	)


	# -----------------------------------------------------
	# GAME OVER
	# -----------------------------------------------------

	if game_over:

		var winner_text = ""

		if player1_score >= WINNING_SCORE:
			winner_text = "PLAYER 1 WINS!"
		else:
			winner_text = "PLAYER 2 WINS!"


		draw_string(
			font,
			Vector2(300, 300),
			winner_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			36,
			Color.WHITE
		)


		draw_string(
			font,
			Vector2(330, 350),
			"PRESS R TO RESTART",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			22,
			Color.WHITE)

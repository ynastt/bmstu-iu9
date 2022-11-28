import glfw
from OpenGL.GL import *
import math

x_angle = 0
y_angle = 0
r1 = 0
r2 = 0
r3 = 0
r4 = 0
alpha = 60
scale = 0.7
accuracy = 26

matrix = (
    1, 0, -math.cos(math.pi / 4), 0,
    0, 1, -math.sin(math.pi / 4), 0,
    0, 0, -1, 0,
    0, 0, 0, 1,
)


def main():
    if not glfw.init():
        return
    window = glfw.create_window(800, 640, "Lab3", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)

    glfw.set_key_callback(window, callback)
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    while glfw.get_key(window, glfw.KEY_ESCAPE) != glfw.PRESS and not glfw.window_should_close(window):
        display(window)

    glfw.destroy_window(window)
    glfw.terminate()


def callback(window, key, scancode, action, mods):
    global x_angle, y_angle, scale
    if key == glfw.KEY_A:
        y_angle -= 2
    if key == glfw.KEY_D:
        y_angle += 2
    if key == glfw.KEY_W:
        x_angle -= 2
    if key == glfw.KEY_S:
        x_angle += 2
    if key == glfw.KEY_UP:
        scale += 0.05
    if key == glfw.KEY_DOWN:
        scale -= 0.05
    if action == glfw.PRESS and key == glfw.KEY_ENTER:
        mode = glGetIntegerv(GL_POLYGON_MODE)
        if mode[1] == GL_LINE:
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
        else:
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)


def display(window):
    glClearColor(1.0, 1.0, 1.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glEnable(GL_DEPTH_TEST)
    #   projection starts here
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glMultTransposeMatrixf(matrix)
    glRotatef(alpha / 2, 1.0, 0.0, 0.0)
    glTranslatef(0.5, 0.2, -0.5)
    glScalef(0.3, 0.3, 0.3)
    draw_figure()

    glLoadIdentity()
    glMatrixMode(GL_MODELVIEW)

    glPushMatrix()

    glLoadIdentity()
    glRotatef(x_angle, 1.0, 0, 0)
    glRotatef(y_angle, 0, 1.0, 0)
    draw_axis()
    glScalef(scale, scale, scale)
    draw_figure()
    glPopMatrix()
    glfw.swap_buffers(window)
    glfw.poll_events()


def draw_figure():
    draw_curve()
    draw_circle(0.5, r1, accuracy, 'magenta')
    draw_circle(0.0, r2, accuracy, 'orange')
    draw_circle(-0.4, r3, accuracy, 'green')
    draw_circle(-0.6, r4, accuracy, 'aqua')
    draw_tube(0.5, 0.0, r1, r2, accuracy, 'magenta', 'orange')
    draw_tube(0.0, -0.4, r2, r3, accuracy, 'orange', 'green')
    draw_tube(-0.4, -0.6, r3, r4, accuracy, 'green', 'aqua')


def draw_axis():
    glLineWidth(1.0)
    glBegin(GL_LINES)
    glColor4f(1.0, 0.0, 0.0, 1.0)  # x - red
    glVertex3f(1.0, 0.0, 0.0)
    glVertex3f(-1.0, 0.0, 0.0)
    glColor4f(0.0, 0.5, 0.0, 1.0)  # y - green
    glVertex3f(0.0, 1.0, 0.0)
    glVertex3f(0.0, -1.0, 0.0)
    glColor4f(0.0, 0.0, 1.0, 1.0)  # z - blue
    glVertex3f(0.0, 0.0, 1.0)
    glVertex3f(0.0, 0.0, -1.0)
    glEnd()


def draw_curve():
    global r1, r2, r3, r4
    glLineWidth(5.0)
    glBegin(GL_LINE_STRIP)
    glColor4f(1.0, 0.0, 1.0, 1.0)  # magenta
    glVertex3f(0.6, 0.5, 0.0)
    r1 = 0.6
    glColor4f(1.0, 0.5, 0.0, 1.0)  # orange
    glVertex3f(0.3, 0.0, 0.0)
    r2 = 0.3
    glColor4f(0.0, 0.5, 0.0, 1.0)  # green
    glVertex3f(0.7, -0.4, 0.0)
    r3 = 0.7
    glColor4f(0.11, 0.56, 0.7, 1.0)  # aqua
    glVertex3f(0.55, -0.6, 0.0)
    r4 = 0.55
    glEnd()


def draw_circle(y, radius, count, color):
    glLineWidth(1.5)
    glBegin(GL_POLYGON)
    glColor4f(*get_color(color))
    phi = 0.0
    for i in range(count):
        z = radius * math.cos(phi)
        x = radius * math.sin(phi)
        glVertex3f(x, y, z)
        phi = 2 * math.pi * i / count
    z = radius * math.cos(phi)
    x = radius * math.sin(phi)
    glVertex3f(x, y, z)
    glEnd()


def get_color(color):
    r = 0
    g = 0
    b = 0
    if color == 'magenta':
        r = 1.0
        g = 0.0
        b = 1.0
    if color == 'orange':
        r = 1.0
        g = 0.5
        b = 0.0
    if color == 'green':
        r = 0.0
        g = 0.5
        b = 0.0
    if color == 'aqua':
        r = 0.12
        g = 0.55
        b = 0.7
    return r, g, b, 1.0


def draw_tube(h_up, h_bottom, radius_up, radius_bottom, count, color_up, color_bottom):
    glLineWidth(1.5)
    glBegin(GL_TRIANGLE_STRIP)
    phi = 0.0
    for i in range(count + 1):
        init_vertexes(radius_up, radius_bottom, h_up, h_bottom, color_up, color_bottom, phi)
        phi = 2 * math.pi * i / count
    init_vertexes(radius_up, radius_bottom, h_up, h_bottom, color_up, color_bottom, phi)
    glEnd()


def init_vertexes(r1, r2, h1, h2, c1, c2, phi):
        z1 = r1 * math.cos(phi)
        x1 = r1 * math.sin(phi)
        y1 = h1
        z2 = r2 * math.cos(phi)
        x2 = r2 * math.sin(phi)
        y2 = h2
        glColor4f(*get_color(c1))
        glVertex3f(x1, y1, z1)  # up
        glColor4f(*get_color(c2))
        glVertex3f(x2, y2, z2)  # bottom


if __name__ == '__main__':
    main()
